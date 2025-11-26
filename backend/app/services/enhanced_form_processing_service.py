"""
Enhanced Form Processing Service - FIXED VERSION
✅ Fixes period extraction for "Período Fiscal: ABRIL 2025" format
✅ Fixes Form 104 classification for "2011 DECLARACION DE IVA"
✅ Includes all 10 Form 103 totals fields
"""

import pdfplumber
import re
from typing import Dict, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from datetime import datetime
import logging

from app.models.base import Document, Form103Totals, Form103LineItem, Form104Data, ProcessingStatusEnum, FormTypeEnum
from app.services.form_103_parser import form_103_parser
from app.services.form_104_parser import form_104_parser

logger = logging.getLogger(__name__)


class EnhancedFormProcessingService:
    """Service for processing PDF forms and storing structured data"""
    
    async def process_uploaded_document(
        self,
        file_path: str,
        original_filename: str,
        file_size: int,
        db: AsyncSession
    ) -> Document:
        """Process a newly uploaded document: extract text, classify form type, parse data"""
        try:
            # Extract text from PDF
            text, total_pages, total_chars = self._extract_text_with_metadata(file_path)
            
            # Classify form type
            form_type = self._classify_form_type(text)
            
            # Create initial document record
            document = Document(
                filename=file_path.split("/")[-1].replace("\\", "/").split("/")[-1],
                original_filename=original_filename,
                file_path=file_path,
                file_size=file_size,
                form_type=form_type,
                extracted_text=text,
                total_pages=total_pages,
                total_characters=total_chars,
                processing_status=ProcessingStatusEnum.PROCESSING
            )
            
            db.add(document)
            await db.flush()
            
            # Parse form-specific data
            if form_type == FormTypeEnum.FORM_103:
                await self._process_form_103(document, text, db)
            elif form_type == FormTypeEnum.FORM_104:
                await self._process_form_104(document, text, db)
            
            # Extract header information (razon_social, periodo, etc.)
            self._extract_header_info(document, text)
            
            # Mark as completed
            document.processing_status = ProcessingStatusEnum.COMPLETED
            document.processed_at = datetime.utcnow()
            
            await db.commit()
            await db.refresh(document)
            
            logger.info(f"✅ Successfully processed document {document.id}: {form_type.value}")
            logger.info(f"   Period: {document.periodo_fiscal_completo}")
            logger.info(f"   Client: {document.razon_social}")
            
            return document
            
        except Exception as e:
            logger.error(f"Error processing document: {str(e)}")
            if 'document' in locals():
                document.processing_status = ProcessingStatusEnum.FAILED
                document.processing_error = str(e)
                await db.commit()
            raise
    
    def _extract_text_with_metadata(self, file_path: str) -> tuple[str, int, int]:
        """Extract text from PDF and get metadata"""
        text_parts = []
        
        with pdfplumber.open(file_path) as pdf:
            total_pages = len(pdf.pages)
            for page in pdf.pages:
                text_parts.append(page.extract_text() or "")
        
        full_text = "\n".join(text_parts)
        total_chars = len(full_text)
        
        return full_text, total_pages, total_chars
    
    def _classify_form_type(self, text: str) -> FormTypeEnum:
        """
        Determine form type based on text content
        ✅ FIXED: Now detects "2011 DECLARACION DE IVA" as Form 104
        """
        text_upper = text.upper()
        
        # Form 103 patterns
        if "DECLARACIÓN DE RETENCIONES EN LA FUENTE DEL IMPUESTO A LA RENTA" in text_upper:
            return FormTypeEnum.FORM_103
        elif "DECLARACION DE RETENCIONES EN LA FUENTE" in text_upper:
            return FormTypeEnum.FORM_103
        elif "1031" in text_upper and "RETENCIONES" in text_upper:
            return FormTypeEnum.FORM_103
        elif "103" in text_upper and "RETENCIONES" in text_upper:
            return FormTypeEnum.FORM_103
        
        # Form 104 patterns
        elif "DECLARACIÓN DEL IMPUESTO AL VALOR AGREGADO" in text_upper:
            return FormTypeEnum.FORM_104
        elif "DECLARACION DEL IMPUESTO AL VALOR AGREGADO" in text_upper:  # Without accent
            return FormTypeEnum.FORM_104
        # ✅ NEW: Detect "2011 DECLARACION DE IVA" format
        elif "2011" in text_upper and "IVA" in text_upper:
            return FormTypeEnum.FORM_104
        elif "104" in text_upper and "IVA" in text_upper:
            return FormTypeEnum.FORM_104
        
        else:
            logger.warning(f"Could not classify form type from text: {text_upper[:200]}")
            return FormTypeEnum.UNKNOWN
    
    def _extract_header_info(self, document: Document, text: str):
        """
        Extract header information from form text
        ✅ FIXED: Now handles "Período Fiscal: ABRIL 2025" format
        """
        # Extract RUC
        ruc_match = re.search(r'(?:RUC|Identificación|No\. Identificación)[:\s]*(\d{13})', text, re.IGNORECASE)
        if ruc_match:
            document.identificacion_ruc = ruc_match.group(1)
        
        # Extract Razon Social (stop at newline to avoid capturing next field)
        razon_match = re.search(
            r'(?:Razón Social|Apellidos y Nombres)[:\s]*([A-ZÁÉÍÓÚÑ\.]+(?:\s+[A-ZÁÉÍÓÚÑ\.]+)*(?:\s+(?:S\.A\.S\.|S\.A\.|CIA\.|LTDA\.|C\.A\.|S\.C\.|CIA\. LTDA\.))?)',
            text,
            re.IGNORECASE
        )
        if razon_match:
            razon_social_raw = razon_match.group(1).strip()
            document.razon_social = razon_social_raw.split('\n')[0].strip()
        
        # ✅ FIXED: Extract Period - now handles "Período Fiscal: ABRIL 2025"
        # Try multiple patterns
        periodo_patterns = [
            # Pattern 1: "Período Fiscal: ABRIL 2025"
            r'Período\s+Fiscal[:\s]+(ENERO|FEBRERO|MARZO|ABRIL|MAYO|JUNIO|JULIO|AGOSTO|SEPTIEMBRE|OCTUBRE|NOVIEMBRE|DICIEMBRE)\s+(\d{4})',
            # Pattern 2: "Período: ABRIL 2025" or "Mes: ABRIL 2025"
            r'(?:Período|Mes)[:\s]+(ENERO|FEBRERO|MARZO|ABRIL|MAYO|JUNIO|JULIO|AGOSTO|SEPTIEMBRE|OCTUBRE|NOVIEMBRE|DICIEMBRE)\s+(\d{4})',
            # Pattern 3: More flexible - just month and year near "Período"
            r'(?:Período|Mes).*?(ENERO|FEBRERO|MARZO|ABRIL|MAYO|JUNIO|JULIO|AGOSTO|SEPTIEMBRE|OCTUBRE|NOVIEMBRE|DICIEMBRE)\s+(\d{4})',
        ]
        
        periodo_match = None
        for pattern in periodo_patterns:
            periodo_match = re.search(pattern, text, re.IGNORECASE)
            if periodo_match:
                break
        
        if periodo_match:
            month_name = periodo_match.group(1).upper()
            year = periodo_match.group(2)
            
            # Map month names to numbers
            month_map = {
                'ENERO': 1, 'FEBRERO': 2, 'MARZO': 3, 'ABRIL': 4,
                'MAYO': 5, 'JUNIO': 6, 'JULIO': 7, 'AGOSTO': 8,
                'SEPTIEMBRE': 9, 'OCTUBRE': 10, 'NOVIEMBRE': 11, 'DICIEMBRE': 12
            }
            
            month_num = month_map.get(month_name, 0)
            
            # ✅ Set all period fields correctly
            document.periodo_fiscal_completo = f"{month_name} {year}"
            document.periodo_mes = month_name
            document.periodo_anio = year
            document.periodo_mes_numero = month_num
            
            logger.info(f"📅 Extracted period: {document.periodo_fiscal_completo}")
        else:
            logger.warning(f"⚠️ Could not extract period from text: {text[:500]}")
        
        # Extract fecha recaudacion
        fecha_match = re.search(r'(?:Fecha de Recaudación)[:\s]*(\d{2}[-/]\d{2}[-/]\d{4})', text, re.IGNORECASE)
        if fecha_match:
            try:
                fecha_str = fecha_match.group(1).replace('-', '/')
                document.fecha_recaudacion = datetime.strptime(fecha_str, '%d/%m/%Y')
            except:
                pass
    
    async def _process_form_103(self, document: Document, text: str, db: AsyncSession) -> Dict:
        """Process Form 103 - Income Tax Withholdings"""
        # Parse form data
        parsed_data = form_103_parser.parse(text)
        
        # Update document with parsed data
        document.parsed_data = parsed_data
        
        # Save totals with all 10 fields
        totals = parsed_data.get("totals", {})
        
        result = await db.execute(
            select(Form103Totals).filter(Form103Totals.document_id == document.id)
        )
        existing_totals = result.scalar_one_or_none()
        
        if existing_totals:
            # Update existing record
            existing_totals.subtotal_operaciones_pais = totals.get("subtotal_operaciones_pais", 0.0)
            existing_totals.subtotal_retencion = totals.get("subtotal_retencion", 0.0)
            existing_totals.total_retencion = totals.get("total_retencion", 0.0)
            existing_totals.total_impuesto_pagar = totals.get("total_impuesto_pagar", 0.0)
            existing_totals.interes_mora = totals.get("interes_mora", 0.0)
            existing_totals.multa = totals.get("multa", 0.0)
            existing_totals.total_pagado = totals.get("total_pagado", 0.0)
            existing_totals.pagos_no_sujetos = totals.get("pagos_no_sujetos", 0.0)
            existing_totals.otras_retenciones_base = totals.get("otras_retenciones_base", 0.0)
            existing_totals.otras_retenciones_retenido = totals.get("otras_retenciones_retenido", 0.0)
        else:
            # Create new totals record
            form_103_totals = Form103Totals(
                document_id=document.id,
                subtotal_operaciones_pais=totals.get("subtotal_operaciones_pais", 0.0),
                subtotal_retencion=totals.get("subtotal_retencion", 0.0),
                total_retencion=totals.get("total_retencion", 0.0),
                total_impuesto_pagar=totals.get("total_impuesto_pagar", 0.0),
                interes_mora=totals.get("interes_mora", 0.0),
                multa=totals.get("multa", 0.0),
                total_pagado=totals.get("total_pagado", 0.0),
                pagos_no_sujetos=totals.get("pagos_no_sujetos", 0.0),
                otras_retenciones_base=totals.get("otras_retenciones_base", 0.0),
                otras_retenciones_retenido=totals.get("otras_retenciones_retenido", 0.0)
            )
            db.add(form_103_totals)
        
        # Save line items
        line_items = parsed_data.get("line_items", [])
        
        result = await db.execute(
            select(Form103LineItem).filter(Form103LineItem.document_id == document.id)
        )
        existing_items = result.scalars().all()
        for item in existing_items:
            await db.delete(item)
        
        for idx, item_data in enumerate(line_items):
            line_item = Form103LineItem(
                document_id=document.id,
                concepto=item_data.get("concepto", ""),
                codigo_base=item_data.get("codigo_base", ""),
                base_imponible=item_data.get("base_imponible", 0.0),
                codigo_retencion=item_data.get("codigo_retencion", ""),
                valor_retenido=item_data.get("valor_retenido", 0.0),
                order_index=idx
            )
            db.add(line_item)
        
        return {
            "status": "success",
            "form_type": "form_103",
            "totals_count": 10,
            "line_items_count": len(line_items)
        }
    
    async def _process_form_104(self, document: Document, text: str, db: AsyncSession) -> Dict:
        """
        Process Form 104 - VAT Declaration
        ✅ FIXED: Passes correct data structure to save methods
        """
        # Parse form data
        parsed_data = form_104_parser.parse(text)
        
        # Update document with parsed data
        document.parsed_data = parsed_data
        
        # Check if Form104Data record exists
        result = await db.execute(
            select(Form104Data).filter(Form104Data.document_id == document.id)
        )
        existing_data = result.scalar_one_or_none()
        
        if existing_data:
            # Update existing record
            self._update_form_104_data(existing_data, parsed_data)
        else:
            # Create new record - pass parsed_data directly
            form_104_data = Form104Data(
                document_id=document.id,
                **self._extract_form_104_fields(parsed_data)
            )
            db.add(form_104_data)
        
        return {
            "status": "success",
            "form_type": "form_104",
            "fields_extracted": len(parsed_data)
        }
    
    def _extract_form_104_fields(self, monetary_values: Dict) -> Dict:
        """
        Extract Form 104 fields from monetary values
        ✅ FIXED: Only includes fields that exist in Form104Data model
        """
        # Get parsed data from form_104_parser
        ventas = monetary_values.get("ventas", {})
        compras = monetary_values.get("compras", {})
        totals = monetary_values.get("totals", {})
        retenciones = monetary_values.get("retenciones_iva", [])
        
        return {
            # Ventas fields
            "ventas_tarifa_diferente_cero_bruto": ventas.get("ventas_tarifa_diferente_cero_bruto", 0.0),
            "ventas_tarifa_diferente_cero_neto": ventas.get("ventas_tarifa_diferente_cero_neto", 0.0),
            "impuesto_generado": ventas.get("impuesto_generado", 0.0),
            "total_ventas_bruto": ventas.get("total_ventas_bruto", 0.0),
            "total_ventas_neto": ventas.get("total_ventas_neto", 0.0),
            "total_impuesto_generado": ventas.get("total_impuesto_generado", 0.0),
            
            # Compras fields
            "adquisiciones_tarifa_diferente_cero_bruto": compras.get("adquisiciones_tarifa_diferente_cero_bruto", 0.0),
            "adquisiciones_tarifa_diferente_cero_neto": compras.get("adquisiciones_tarifa_diferente_cero_neto", 0.0),
            "impuesto_compras": compras.get("impuesto_compras", 0.0),
            "adquisiciones_tarifa_cero": compras.get("adquisiciones_tarifa_cero", 0.0),
            "total_adquisiciones": compras.get("total_adquisiciones", 0.0),
            "credito_tributario_aplicable": compras.get("credito_tributario_aplicable", 0.0),
            
            # Retenciones IVA (as JSON)
            "retenciones_iva": retenciones,
            
            # Totals fields (ONLY fields that exist in database)
            "impuesto_causado": totals.get("impuesto_causado", 0.0),
            "retenciones_efectuadas": totals.get("retenciones_efectuadas", 0.0),
            "subtotal_a_pagar": totals.get("subtotal_a_pagar", 0.0),
            "total_impuesto_retenido": totals.get("total_impuesto_retenido", 0.0),
            "total_impuesto_pagar_retencion": totals.get("total_impuesto_pagar_retencion", 0.0),
            "total_consolidado_iva": totals.get("total_consolidado_iva", 0.0),
            "total_pagado": totals.get("total_pagado", 0.0),
            
            # ❌ REMOVED: These fields don't exist in Form104Data model
            # "total_impuesto_pagar_percepcion": ...
            # "total_impuesto_a_pagar": ...
            # "interes_mora": ...
            # "multa": ...
        }
    
    def _update_form_104_data(self, data_obj: Form104Data, parsed_data: Dict):
        """
        Update existing Form104Data object
        ✅ FIXED: Only updates fields that exist in Form104Data model
        """
        # Get sections from parsed data
        ventas = parsed_data.get("ventas", {})
        compras = parsed_data.get("compras", {})
        totals = parsed_data.get("totals", {})
        retenciones = parsed_data.get("retenciones_iva", [])
        
        # Update ventas fields
        data_obj.ventas_tarifa_diferente_cero_bruto = ventas.get("ventas_tarifa_diferente_cero_bruto", 0.0)
        data_obj.ventas_tarifa_diferente_cero_neto = ventas.get("ventas_tarifa_diferente_cero_neto", 0.0)
        data_obj.impuesto_generado = ventas.get("impuesto_generado", 0.0)
        data_obj.total_ventas_bruto = ventas.get("total_ventas_bruto", 0.0)
        data_obj.total_ventas_neto = ventas.get("total_ventas_neto", 0.0)
        data_obj.total_impuesto_generado = ventas.get("total_impuesto_generado", 0.0)
        
        # Update compras fields
        data_obj.adquisiciones_tarifa_diferente_cero_bruto = compras.get("adquisiciones_tarifa_diferente_cero_bruto", 0.0)
        data_obj.adquisiciones_tarifa_diferente_cero_neto = compras.get("adquisiciones_tarifa_diferente_cero_neto", 0.0)
        data_obj.impuesto_compras = compras.get("impuesto_compras", 0.0)
        data_obj.adquisiciones_tarifa_cero = compras.get("adquisiciones_tarifa_cero", 0.0)
        data_obj.total_adquisiciones = compras.get("total_adquisiciones", 0.0)
        data_obj.credito_tributario_aplicable = compras.get("credito_tributario_aplicable", 0.0)
        
        # Update retenciones IVA
        data_obj.retenciones_iva = retenciones
        
        # Update totals fields (ONLY fields that exist in database)
        data_obj.impuesto_causado = totals.get("impuesto_causado", 0.0)
        data_obj.retenciones_efectuadas = totals.get("retenciones_efectuadas", 0.0)
        data_obj.subtotal_a_pagar = totals.get("subtotal_a_pagar", 0.0)
        data_obj.total_impuesto_retenido = totals.get("total_impuesto_retenido", 0.0)
        data_obj.total_impuesto_pagar_retencion = totals.get("total_impuesto_pagar_retencion", 0.0)
        data_obj.total_consolidado_iva = totals.get("total_consolidado_iva", 0.0)
        data_obj.total_pagado = totals.get("total_pagado", 0.0)
        

# Singleton instance
enhanced_form_processing_service = EnhancedFormProcessingService()