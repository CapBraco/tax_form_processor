"""
Forms Data API - Get structured data from Form 103 and 104
"""

from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pydantic import BaseModel

from app.core.database import get_db
from app.models.base import Document, Form103LineItem, Form104Data, FormTypeEnum

router = APIRouter()


# Response Models
class Form103LineItemResponse(BaseModel):
    """Response model for Form 103 line item"""
    id: int
    concepto: str
    codigo_base: str
    base_imponible: float
    codigo_retencion: str
    valor_retenido: float
    order_index: int
    
    class Config:
        from_attributes = True


class Form103DataResponse(BaseModel):
    """Complete Form 103 data response"""
    document_id: int
    filename: str
    razon_social: str
    periodo: str
    fecha_recaudacion: str
    line_items: List[Form103LineItemResponse]
    totals: dict


class Form104VentasResponse(BaseModel):
    """Form 104 sales data"""
    ventas_tarifa_diferente_cero_bruto: float
    ventas_tarifa_diferente_cero_neto: float
    impuesto_generado: float
    total_ventas_bruto: float
    total_ventas_neto: float
    total_impuesto_generado: float


class Form104ComprasResponse(BaseModel):
    """Form 104 purchases data"""
    adquisiciones_tarifa_diferente_cero_bruto: float
    adquisiciones_tarifa_diferente_cero_neto: float
    impuesto_compras: float
    adquisiciones_tarifa_cero: float
    total_adquisiciones: float
    credito_tributario_aplicable: float


class Form104TotalsResponse(BaseModel):
    """Form 104 totals"""
    impuesto_causado: float
    retenciones_efectuadas: float
    subtotal_a_pagar: float
    total_impuesto_retenido: float
    total_impuesto_pagar_retencion: float
    total_consolidado_iva: float
    total_pagado: float


class Form104DataResponse(BaseModel):
    """Complete Form 104 data response"""
    document_id: int
    filename: str
    razon_social: str
    periodo: str
    fecha_recaudacion: str
    ventas: Form104VentasResponse
    compras: Form104ComprasResponse
    retenciones_iva: List[dict]
    totals: Form104TotalsResponse


@router.get("/form-103/{document_id}", response_model=Form103DataResponse)
async def get_form_103_data(
    document_id: int,
    db: AsyncSession = Depends(get_db)
):
    """
    Get structured data from Form 103 (Retenciones)
    
    Returns all line items with BASE IMPONIBLE and VALOR RETENIDO
    """
    # Get document
    doc_result = await db.execute(
        select(Document).where(
            Document.id == document_id,
            Document.form_type == FormTypeEnum.FORM_103
        )
    )
    document = doc_result.scalar_one_or_none()
    
    if not document:
        raise HTTPException(status_code=404, detail="Form 103 document not found")
    
    # Get line items
    items_result = await db.execute(
        select(Form103LineItem)
        .where(Form103LineItem.document_id == document_id)
        .order_by(Form103LineItem.order_index)
    )
    line_items = items_result.scalars().all()
    
    # Build response
    periodo = f"{document.periodo_mes} {document.periodo_anio}" if document.periodo_mes else "N/A"
    fecha = document.fecha_recaudacion.strftime("%d-%m-%Y") if document.fecha_recaudacion else "N/A"
    
    return Form103DataResponse(
        document_id=document.id,
        filename=document.original_filename,
        razon_social=document.razon_social or "N/A",
        periodo=periodo,
        fecha_recaudacion=fecha,
        line_items=[
            Form103LineItemResponse.from_orm(item) for item in line_items
        ],
        totals=document.parsed_data.get("totals", {}) if document.parsed_data else {}
    )


@router.get("/form-104/{document_id}", response_model=Form104DataResponse)
async def get_form_104_data(
    document_id: int,
    db: AsyncSession = Depends(get_db)
):
    """
    Get structured data from Form 104 (IVA)
    
    Returns sales, purchases, retentions, and totals
    """
    # Get document
    doc_result = await db.execute(
        select(Document).where(
            Document.id == document_id,
            Document.form_type == FormTypeEnum.FORM_104
        )
    )
    document = doc_result.scalar_one_or_none()
    
    if not document:
        raise HTTPException(status_code=404, detail="Form 104 document not found")
    
    # Get Form104Data
    data_result = await db.execute(
        select(Form104Data).where(Form104Data.document_id == document_id)
    )
    form_data = data_result.scalar_one_or_none()
    
    if not form_data:
        raise HTTPException(status_code=404, detail="Form 104 data not found")
    
    # Build response
    periodo = f"{document.periodo_mes} {document.periodo_anio}" if document.periodo_mes else "N/A"
    fecha = document.fecha_recaudacion.strftime("%d-%m-%Y") if document.fecha_recaudacion else "N/A"
    
    return Form104DataResponse(
        document_id=document.id,
        filename=document.original_filename,
        razon_social=document.razon_social or "N/A",
        periodo=periodo,
        fecha_recaudacion=fecha,
        ventas=Form104VentasResponse(
            ventas_tarifa_diferente_cero_bruto=form_data.ventas_tarifa_diferente_cero_bruto,
            ventas_tarifa_diferente_cero_neto=form_data.ventas_tarifa_diferente_cero_neto,
            impuesto_generado=form_data.impuesto_generado,
            total_ventas_bruto=form_data.total_ventas_bruto,
            total_ventas_neto=form_data.total_ventas_neto,
            total_impuesto_generado=form_data.total_impuesto_generado
        ),
        compras=Form104ComprasResponse(
            adquisiciones_tarifa_diferente_cero_bruto=form_data.adquisiciones_tarifa_diferente_cero_bruto,
            adquisiciones_tarifa_diferente_cero_neto=form_data.adquisiciones_tarifa_diferente_cero_neto,
            impuesto_compras=form_data.impuesto_compras,
            adquisiciones_tarifa_cero=form_data.adquisiciones_tarifa_cero,
            total_adquisiciones=form_data.total_adquisiciones,
            credito_tributario_aplicable=form_data.credito_tributario_aplicable
        ),
        retenciones_iva=form_data.retenciones_iva or [],
        totals=Form104TotalsResponse(
            impuesto_causado=form_data.impuesto_causado,
            retenciones_efectuadas=form_data.retenciones_efectuadas,
            subtotal_a_pagar=form_data.subtotal_a_pagar,
            total_impuesto_retenido=form_data.total_impuesto_retenido,
            total_impuesto_pagar_retencion=form_data.total_impuesto_pagar_retencion,
            total_consolidado_iva=form_data.total_consolidado_iva,
            total_pagado=form_data.total_pagado
        )
    )


@router.get("/list-by-form-type/{form_type}")
async def list_documents_by_form_type(
    form_type: str,
    db: AsyncSession = Depends(get_db)
):
    """
    List all documents of a specific form type
    
    - **form_type**: "form_103" or "form_104"
    """
    try:
        form_type_enum = FormTypeEnum(form_type)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid form type. Use 'form_103' or 'form_104'")
    
    # Get documents
    result = await db.execute(
        select(Document)
        .where(Document.form_type == form_type_enum)
        .order_by(Document.uploaded_at.desc())
    )
    documents = result.scalars().all()
    
    # Build response
    docs_list = []
    for doc in documents:
        periodo = f"{doc.periodo_mes} {doc.periodo_anio}" if doc.periodo_mes else "N/A"
        fecha = doc.fecha_recaudacion.strftime("%d-%m-%Y") if doc.fecha_recaudacion else "N/A"
        
        docs_list.append({
            "id": doc.id,
            "filename": doc.original_filename,
            "razon_social": doc.razon_social or "N/A",
            "periodo": periodo,
            "fecha_recaudacion": fecha,
            "processing_status": doc.processing_status.value,
            "uploaded_at": doc.uploaded_at.isoformat() if doc.uploaded_at else None
        })
    
    return {
        "form_type": form_type,
        "total": len(docs_list),
        "documents": docs_list
    }
