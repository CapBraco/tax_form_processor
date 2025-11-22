"""
Reprocess Existing Documents - ASYNC Compatible
Extracts razon_social, periodo data from existing PDFs
Run after migration: python backend/app/scripts/reprocess_documents.py
"""

import asyncio
import sys
import os
import re

# Add parent directory to path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))

from sqlalchemy import select
from app.core.database import AsyncSessionLocal
from app.models.base import Document, Form103Totals, FormTypeEnum


# Spanish month mapping
MONTH_MAP = {
    'ENERO': 1, 'FEBRERO': 2, 'MARZO': 3, 'ABRIL': 4,
    'MAYO': 5, 'JUNIO': 6, 'JULIO': 7, 'AGOSTO': 8,
    'SEPTIEMBRE': 9, 'OCTUBRE': 10, 'NOVIEMBRE': 11, 'DICIEMBRE': 12
}


def extract_periodo_info(text: str) -> tuple:
    """
    Extract periodo fiscal from text
    Returns: (periodo_fiscal_completo, periodo_mes_numero)
    """
    if not text:
        return None, None
    
    # Look for patterns like "Período Fiscal: ABRIL 2025" or "PERIODO FISCAL ABRIL 2025"
    patterns = [
        r'Período\s+Fiscal[:\s]*([A-Z]+)\s+(\d{4})',
        r'PERIODO\s+FISCAL[:\s]*([A-Z]+)\s+(\d{4})',
        r'Periodo[:\s]*([A-Z]+)\s+(\d{4})',
    ]
    
    for pattern in patterns:
        match = re.search(pattern, text, re.IGNORECASE)
        if match:
            month_str = match.group(1).strip().upper()
            year = match.group(2)
            
            # Get month number
            month_num = MONTH_MAP.get(month_str)
            
            if month_num:
                periodo_completo = f"{month_str} {year}"
                return periodo_completo, month_num
    
    return None, None


def extract_form_103_totals(text: str) -> dict:
    """Extract Form 103 totals from text"""
    totals = {
        'subtotal_operaciones_pais': 0.0,
        'total_retencion': 0.0,
        'total_impuesto_pagar': 0.0,
        'total_pagado': 0.0
    }
    
    if not text:
        return totals
    
    patterns = {
        'subtotal_operaciones_pais': r'Subtotal\s+Operaciones\s+País\s*[\$:]?\s*([\d,]+\.?\d*)',
        'total_retencion': r'Total\s+Retención\s*[\$:]?\s*([\d,]+\.?\d*)',
        'total_impuesto_pagar': r'Total\s+Impuesto\s+a\s+Pagar\s*[\$:]?\s*([\d,]+\.?\d*)',
        'total_pagado': r'Total\s+Pagado\s*[\$:]?\s*([\d,]+\.?\d*)'
    }
    
    for key, pattern in patterns.items():
        match = re.search(pattern, text, re.IGNORECASE)
        if match:
            value_str = match.group(1).replace(',', '')
            try:
                totals[key] = float(value_str)
            except ValueError:
                totals[key] = 0.0
    
    return totals


async def reprocess_documents():
    """Reprocess all existing documents to extract new fields"""
    
    print("🔄 Starting document reprocessing...\n")
    
    async with AsyncSessionLocal() as db:
        try:
            # Get all documents
            result = await db.execute(select(Document))
            documents = result.scalars().all()
            
            print(f"📄 Found {len(documents)} documents to process\n")
            
            processed_count = 0
            updated_count = 0
            error_count = 0
            
            for doc in documents:
                try:
                    print(f"📝 Processing: {doc.original_filename} (ID: {doc.id})")
                    
                    updated = False
                    
                    # Extract periodo fiscal info if extracted_text exists
                    if doc.extracted_text:
                        periodo_completo, mes_numero = extract_periodo_info(doc.extracted_text)
                        
                        if periodo_completo:
                            doc.periodo_fiscal_completo = periodo_completo
                            doc.periodo_mes_numero = mes_numero
                            updated = True
                            print(f"   ✓ Período: {periodo_completo} (Mes #{mes_numero})")
                        
                        # Extract Form 103 totals if it's a Form 103
                        if doc.form_type == FormTypeEnum.FORM_103:
                            totals_data = extract_form_103_totals(doc.extracted_text)
                            
                            # Check if Form103Totals already exists
                            result = await db.execute(
                                select(Form103Totals).where(Form103Totals.document_id == doc.id)
                            )
                            existing_totals = result.scalar_one_or_none()
                            
                            if existing_totals:
                                # Update existing
                                existing_totals.subtotal_operaciones_pais = totals_data['subtotal_operaciones_pais']
                                existing_totals.total_retencion = totals_data['total_retencion']
                                existing_totals.total_impuesto_pagar = totals_data['total_impuesto_pagar']
                                existing_totals.total_pagado = totals_data['total_pagado']
                                print(f"   ✓ Updated Form 103 totals (Total: ${totals_data['total_pagado']:.2f})")
                            else:
                                # Create new
                                form_103_totals = Form103Totals(
                                    document_id=doc.id,
                                    subtotal_operaciones_pais=totals_data['subtotal_operaciones_pais'],
                                    total_retencion=totals_data['total_retencion'],
                                    total_impuesto_pagar=totals_data['total_impuesto_pagar'],
                                    total_pagado=totals_data['total_pagado']
                                )
                                db.add(form_103_totals)
                                print(f"   ✓ Created Form 103 totals (Total: ${totals_data['total_pagado']:.2f})")
                            
                            updated = True
                    
                    if updated:
                        updated_count += 1
                        print(f"   ✅ Successfully updated\n")
                    else:
                        print(f"   ⏭️  No updates needed\n")
                    
                    processed_count += 1
                    
                except Exception as e:
                    print(f"   ❌ Error: {e}\n")
                    error_count += 1
                    continue
            
            # Commit all changes
            await db.commit()
            
            print(f"\n📊 Reprocessing Summary:")
            print(f"   📝 Processed: {processed_count}")
            print(f"   ✅ Updated: {updated_count}")
            print(f"   ❌ Errors: {error_count}")
            print(f"   📄 Total: {len(documents)}")
            
            # Show unique clients found
            result = await db.execute(
                select(Document.razon_social).where(Document.razon_social.isnot(None)).distinct()
            )
            unique_clients = result.scalars().all()
            
            print(f"\n👥 Found {len(unique_clients)} unique clients:")
            for client in unique_clients:
                if client:
                    print(f"   - {client}")
            
            print("\n✨ Reprocessing completed!")
            print("\n📋 Next steps:")
            print("1. Check the Clientes section in your frontend")
            print("2. Verify client organization is working")
            print("3. Test yearly summaries")
            
        except Exception as e:
            print(f"\n❌ Fatal error: {e}")
            await db.rollback()


if __name__ == "__main__":
    asyncio.run(reprocess_documents())
