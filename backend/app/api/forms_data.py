"""
Updated Forms Data API Endpoints
✅ NOW INCLUDES: Codes 332, 3440, 3940 in Form 103 responses
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import Optional

from app.core.database import get_db
from app.models.base import Document, Form103LineItem, Form104Data, Form103Totals, FormTypeEnum

router = APIRouter(tags=["forms-data"])


@router.get("/form-103/{document_id}")
async def get_form_103_data(document_id: int, db: AsyncSession = Depends(get_db)):
    """
    Get Form 103 data with complete line items and ALL totals
    ✅ NOW INCLUDES: Code 332, 3440, 3940
    """
    # Fetch document
    doc_query = select(Document).where(Document.id == document_id, Document.form_type == FormTypeEnum.FORM_103)
    doc_result = await db.execute(doc_query)
    document = doc_result.scalar_one_or_none()
    
    if not document:
        raise HTTPException(status_code=404, detail="Form 103 document not found")
    
    # Fetch line items
    items_query = select(Form103LineItem).where(Form103LineItem.document_id == document_id).order_by(Form103LineItem.order_index)
    items_result = await db.execute(items_query)
    line_items = items_result.scalars().all()
    
    # Fetch totals
    totals_query = select(Form103Totals).where(Form103Totals.document_id == document_id)
    totals_result = await db.execute(totals_query)
    totals = totals_result.scalar_one_or_none()
    
    # Build response
    return {
        "document_id": document.id,
        "filename": document.original_filename,
        "razon_social": document.razon_social,
        "periodo": f"{document.periodo_mes} {document.periodo_anio}" if document.periodo_mes else "N/A",
        "fecha_recaudacion": document.fecha_recaudacion.isoformat() if document.fecha_recaudacion else "N/A",
        "line_items": [
            {
                "id": item.id,
                "concepto": item.concepto,
                "codigo_base": item.codigo_base,
                "base_imponible": item.base_imponible,
                "codigo_retencion": item.codigo_retencion,
                "valor_retenido": item.valor_retenido,
                "order_index": item.order_index
            }
            for item in line_items
        ],
        # ✅ UPDATED: Now includes ALL 7 fields
        "totals": {
            "subtotal_operaciones": totals.subtotal_operaciones_pais if totals else 0.0,
            "subtotal_retencion": totals.subtotal_retencion if totals else 0.0,  # ✅ Code 332
            "total_retencion": totals.total_retencion if totals else 0.0,
            "total_impuesto_pagar": totals.total_impuesto_pagar if totals else 0.0,
            "interes_mora": totals.interes_mora if totals else 0.0,  # ✅ Code 3440
            "multa": totals.multa if totals else 0.0,  # ✅ Code 3940
            "total_pagado": totals.total_pagado if totals else 0.0
        } if totals else None
    }


@router.get("/form-104/{document_id}")
async def get_form_104_data(document_id: int, db: AsyncSession = Depends(get_db)):
    """
    Get Form 104 data with COMPLETE parsed data
    ✅ Returns ALL fields extracted by the parser (75+ fields)
    """
    # Fetch document
    doc_query = select(Document).where(Document.id == document_id, Document.form_type == FormTypeEnum.FORM_104)
    doc_result = await db.execute(doc_query)
    document = doc_result.scalar_one_or_none()
    
    if not document:
        raise HTTPException(status_code=404, detail="Form 104 document not found")
    
    # Fetch structured data from database
    data_query = select(Form104Data).where(Form104Data.document_id == document_id)
    data_result = await db.execute(data_query)
    form_data = data_result.scalar_one_or_none()
    
    # ✅ NEW: Get COMPLETE parsed data from JSON field
    parsed_data = document.parsed_data or {}
    
    # Build base response from database fields
    response = {
        "document_id": document.id,
        "filename": document.original_filename,
        "razon_social": document.razon_social,
        "periodo": f"{document.periodo_mes} {document.periodo_anio}" if document.periodo_mes else "N/A",
        "fecha_recaudacion": document.fecha_recaudacion.isoformat() if document.fecha_recaudacion else "N/A",
    }
    
    if form_data:
        # Start with database structured fields
        response["ventas"] = {
            "ventas_tarifa_diferente_cero_bruto": form_data.ventas_tarifa_diferente_cero_bruto,
            "ventas_tarifa_diferente_cero_neto": form_data.ventas_tarifa_diferente_cero_neto,
            "impuesto_generado": form_data.impuesto_generado,
            "total_ventas_bruto": form_data.total_ventas_bruto,
            "total_ventas_neto": form_data.total_ventas_neto,
            "total_impuesto_generado": form_data.total_impuesto_generado
        }
        
        response["compras"] = {
            "adquisiciones_tarifa_diferente_cero_bruto": form_data.adquisiciones_tarifa_diferente_cero_bruto,
            "adquisiciones_tarifa_diferente_cero_neto": form_data.adquisiciones_tarifa_diferente_cero_neto,
            "impuesto_compras": form_data.impuesto_compras,
            "adquisiciones_tarifa_cero": form_data.adquisiciones_tarifa_cero,
            "total_adquisiciones": form_data.total_adquisiciones,
            "credito_tributario_aplicable": form_data.credito_tributario_aplicable
        }
        
        response["retenciones_iva"] = form_data.retenciones_iva or []
        
        response["totals"] = {
            "impuesto_causado": form_data.impuesto_causado,
            "retenciones_efectuadas": form_data.retenciones_efectuadas,
            "subtotal_a_pagar": form_data.subtotal_a_pagar,
            "total_impuesto_retenido": form_data.total_impuesto_retenido,
            "total_impuesto_pagar_retencion": form_data.total_impuesto_pagar_retencion,
            "total_consolidado_iva": form_data.total_consolidado_iva,
            "total_pagado": form_data.total_pagado
        }
        
        # ✅ NEW: MERGE with complete parsed data from JSON
        # This adds ALL the fields that the parser extracted but aren't in the DB model
        if parsed_data:
            # Merge ventas fields
            if "ventas" in parsed_data:
                response["ventas"].update(parsed_data["ventas"])
            
            # Merge compras fields
            if "compras" in parsed_data:
                response["compras"].update(parsed_data["compras"])
            
            # Merge totals fields
            if "totals" in parsed_data:
                response["totals"].update(parsed_data["totals"])
            
            # Retenciones should already be complete from DB
            if "retenciones_iva" in parsed_data and not response["retenciones_iva"]:
                response["retenciones_iva"] = parsed_data["retenciones_iva"]
    else:
        # No structured data in database, return from parsed_data JSON only
        response["ventas"] = parsed_data.get("ventas", {})
        response["compras"] = parsed_data.get("compras", {})
        response["retenciones_iva"] = parsed_data.get("retenciones_iva", [])
        response["totals"] = parsed_data.get("totals", {})
    
    return response


@router.get("/list-by-form-type/{form_type}")
async def list_documents_by_form_type(
    form_type: str,
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db)
):
    """List all documents of a specific form type"""
    # Map string to enum
    form_type_enum = FormTypeEnum.FORM_103 if form_type == "form_103" else FormTypeEnum.FORM_104
    
    query = select(Document).where(Document.form_type == form_type_enum).order_by(Document.uploaded_at.desc()).offset(skip).limit(limit)
    result = await db.execute(query)
    documents = result.scalars().all()
    
    return [
        {
            "id": doc.id,
            "filename": doc.original_filename,
            "razon_social": doc.razon_social,
            "periodo": f"{doc.periodo_mes} {doc.periodo_anio}" if doc.periodo_mes else "N/A",
            "uploaded_at": doc.uploaded_at.isoformat() if doc.uploaded_at else None,
            "processing_status": doc.processing_status.value
        }
        for doc in documents
    ]