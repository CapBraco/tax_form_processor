"""
Form 104 API - FIXED: Dual Access
✅ Allows everyone to view form data
✅ Verifies ownership only for saved documents (registered users)
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_
from typing import Optional

from app.core.database import get_db
from app.core.security import get_current_user_optional  # ← CHANGED: Optional
from app.models.base import User, Document, Form104Data

router = APIRouter(prefix="/form-104", tags=["form-104"])


@router.get("/{document_id}/data")
async def get_form_104_data(
    document_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional)  # ← CHANGED: Optional
):
    """
    Get Form 104 data
    ✅ FIXED: If logged in, verify ownership. If guest, they can't access saved docs.
    """
    
    # Get document
    result = await db.execute(
        select(Document).where(Document.id == document_id)
    )
    document = result.scalar_one_or_none()
    
    if not document:
        raise HTTPException(status_code=404, detail="Document not found")
    
    # If document has a user_id (saved document), verify ownership
    if document.user_id:
        if not current_user or document.user_id != current_user.id:
            raise HTTPException(
                status_code=404,
                detail="Document not found or you don't have permission to access it"
            )
    
    # Get Form 104 data
    form_result = await db.execute(
        select(Form104Data).where(Form104Data.document_id == document_id)
    )
    form_data = form_result.scalar_one_or_none()
    
    if not form_data:
        raise HTTPException(status_code=404, detail="Form 104 data not found for this document")
    
    return {
        "document_id": document_id,
        # Ventas (Sales)
        "ventas_tarifa_diferente_cero_bruto": float(form_data.ventas_tarifa_diferente_cero_bruto or 0),
        "ventas_tarifa_diferente_cero_neto": float(form_data.ventas_tarifa_diferente_cero_neto or 0),
        "impuesto_generado": float(form_data.impuesto_generado or 0),
        "total_ventas_bruto": float(form_data.total_ventas_bruto or 0),
        "total_ventas_neto": float(form_data.total_ventas_neto or 0),
        "total_impuesto_generado": float(form_data.total_impuesto_generado or 0),
        # Compras (Purchases)
        "adquisiciones_tarifa_diferente_cero_bruto": float(form_data.adquisiciones_tarifa_diferente_cero_bruto or 0),
        "adquisiciones_tarifa_diferente_cero_neto": float(form_data.adquisiciones_tarifa_diferente_cero_neto or 0),
        "impuesto_compras": float(form_data.impuesto_compras or 0),
        "adquisiciones_tarifa_cero": float(form_data.adquisiciones_tarifa_cero or 0),
        "total_adquisiciones": float(form_data.total_adquisiciones or 0),
        "credito_tributario_aplicable": float(form_data.credito_tributario_aplicable or 0),
        # Retenciones IVA
        "retenciones_iva": form_data.retenciones_iva,
        # Totals
        "impuesto_causado": float(form_data.impuesto_causado or 0),
        "retenciones_efectuadas": float(form_data.retenciones_efectuadas or 0),
        "subtotal_a_pagar": float(form_data.subtotal_a_pagar or 0),
        "total_impuesto_retenido": float(form_data.total_impuesto_retenido or 0),
        "total_impuesto_pagar_retencion": float(form_data.total_impuesto_pagar_retencion or 0),
        "total_consolidado_iva": float(form_data.total_consolidado_iva or 0),
        "total_pagado": float(form_data.total_pagado or 0)
    }


@router.get("/{document_id}/complete")
async def get_form_104_complete(
    document_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional)  # ← CHANGED: Optional
):
    """
    Get complete Form 104 data with document info
    ✅ FIXED: If logged in, verify ownership. If guest, they can't access saved docs.
    """
    
    # Get document
    result = await db.execute(
        select(Document).where(Document.id == document_id)
    )
    document = result.scalar_one_or_none()
    
    if not document:
        raise HTTPException(status_code=404, detail="Document not found")
    
    # If document has a user_id (saved document), verify ownership
    if document.user_id:
        if not current_user or document.user_id != current_user.id:
            raise HTTPException(
                status_code=404,
                detail="Document not found or you don't have permission to access it"
            )
    
    # Get Form 104 data
    form_result = await db.execute(
        select(Form104Data).where(Form104Data.document_id == document_id)
    )
    form_data = form_result.scalar_one_or_none()
    
    if not form_data:
        raise HTTPException(status_code=404, detail="Form 104 data not found for this document")
    
    return {
        "document": {
            "id": document.id,
            "filename": document.original_filename,
            "razon_social": document.razon_social,
            "identificacion_ruc": document.identificacion_ruc,
            "periodo": document.periodo_fiscal_completo
        },
        "ventas": {
            "ventas_tarifa_diferente_cero_bruto": float(form_data.ventas_tarifa_diferente_cero_bruto or 0),
            "ventas_tarifa_diferente_cero_neto": float(form_data.ventas_tarifa_diferente_cero_neto or 0),
            "impuesto_generado": float(form_data.impuesto_generado or 0),
            "total_ventas_bruto": float(form_data.total_ventas_bruto or 0),
            "total_ventas_neto": float(form_data.total_ventas_neto or 0),
            "total_impuesto_generado": float(form_data.total_impuesto_generado or 0)
        },
        "compras": {
            "adquisiciones_tarifa_diferente_cero_bruto": float(form_data.adquisiciones_tarifa_diferente_cero_bruto or 0),
            "adquisiciones_tarifa_diferente_cero_neto": float(form_data.adquisiciones_tarifa_diferente_cero_neto or 0),
            "impuesto_compras": float(form_data.impuesto_compras or 0),
            "adquisiciones_tarifa_cero": float(form_data.adquisiciones_tarifa_cero or 0),
            "total_adquisiciones": float(form_data.total_adquisiciones or 0),
            "credito_tributario_aplicable": float(form_data.credito_tributario_aplicable or 0)
        },
        "retenciones_iva": form_data.retenciones_iva,
        "totals": {
            "impuesto_causado": float(form_data.impuesto_causado or 0),
            "retenciones_efectuadas": float(form_data.retenciones_efectuadas or 0),
            "subtotal_a_pagar": float(form_data.subtotal_a_pagar or 0),
            "total_impuesto_retenido": float(form_data.total_impuesto_retenido or 0),
            "total_impuesto_pagar_retencion": float(form_data.total_impuesto_pagar_retencion or 0),
            "total_consolidado_iva": float(form_data.total_consolidado_iva or 0),
            "total_pagado": float(form_data.total_pagado or 0)
        }
    }