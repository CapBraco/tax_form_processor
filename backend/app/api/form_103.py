"""
Form 103 API - FIXED: Dual Access
✅ Allows everyone to view form data
✅ Verifies ownership only for saved documents (registered users)
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_
from typing import Optional

from app.core.database import get_db
from app.core.security import get_current_user_optional  # ← CHANGED: Optional
from app.models.base import User, Document, Form103Totals, Form103LineItem

router = APIRouter(prefix="/form-103", tags=["form-103"])


@router.get("/{document_id}/totals")
async def get_form_103_totals(
    document_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional)  # ← CHANGED: Optional
):
    """
    Get Form 103 totals
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
    
    # Get Form 103 totals
    totals_result = await db.execute(
        select(Form103Totals).where(Form103Totals.document_id == document_id)
    )
    totals = totals_result.scalar_one_or_none()
    
    if not totals:
        raise HTTPException(status_code=404, detail="Form 103 data not found for this document")
    
    return {
        "document_id": document_id,
        "subtotal_operaciones_pais": float(totals.subtotal_operaciones_pais or 0),
        "subtotal_retencion": float(totals.subtotal_retencion or 0),
        "total_retencion": float(totals.total_retencion or 0),
        "total_impuesto_pagar": float(totals.total_impuesto_pagar or 0),
        "interes_mora": float(totals.interes_mora or 0),
        "multa": float(totals.multa or 0),
        "total_pagado": float(totals.total_pagado or 0),
        "pagos_no_sujetos": float(totals.pagos_no_sujetos or 0),
        "otras_retenciones_base": float(totals.otras_retenciones_base or 0),
        "otras_retenciones_retenido": float(totals.otras_retenciones_retenido or 0)
    }


@router.get("/{document_id}/line-items")
async def get_form_103_line_items(
    document_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional)  # ← CHANGED: Optional
):
    """
    Get Form 103 line items
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
    
    # Get line items
    items_result = await db.execute(
        select(Form103LineItem)
        .where(Form103LineItem.document_id == document_id)
        .order_by(Form103LineItem.order_index)
    )
    line_items = items_result.scalars().all()
    
    return {
        "document_id": document_id,
        "total_items": len(line_items),
        "line_items": [
            {
                "order_index": item.order_index,
                "concepto": item.concepto,
                "codigo_base": item.codigo_base,
                "base_imponible": float(item.base_imponible or 0),
                "codigo_retencion": item.codigo_retencion,
                "valor_retenido": float(item.valor_retenido or 0)
            }
            for item in line_items
        ]
    }


@router.get("/{document_id}/complete")
async def get_form_103_complete(
    document_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional)  # ← CHANGED: Optional
):
    """
    Get complete Form 103 data (totals + line items)
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
    
    # Get totals
    totals_result = await db.execute(
        select(Form103Totals).where(Form103Totals.document_id == document_id)
    )
    totals = totals_result.scalar_one_or_none()
    
    # Get line items
    items_result = await db.execute(
        select(Form103LineItem)
        .where(Form103LineItem.document_id == document_id)
        .order_by(Form103LineItem.order_index)
    )
    line_items = items_result.scalars().all()
    
    return {
        "document": {
            "id": document.id,
            "filename": document.original_filename,
            "razon_social": document.razon_social,
            "identificacion_ruc": document.identificacion_ruc,
            "periodo": document.periodo_fiscal_completo
        },
        "totals": {
            "subtotal_operaciones_pais": float(totals.subtotal_operaciones_pais or 0) if totals else 0,
            "subtotal_retencion": float(totals.subtotal_retencion or 0) if totals else 0,
            "total_retencion": float(totals.total_retencion or 0) if totals else 0,
            "total_impuesto_pagar": float(totals.total_impuesto_pagar or 0) if totals else 0,
            "interes_mora": float(totals.interes_mora or 0) if totals else 0,
            "multa": float(totals.multa or 0) if totals else 0,
            "total_pagado": float(totals.total_pagado or 0) if totals else 0,
            "pagos_no_sujetos": float(totals.pagos_no_sujetos or 0) if totals else 0,
            "otras_retenciones_base": float(totals.otras_retenciones_base or 0) if totals else 0,
            "otras_retenciones_retenido": float(totals.otras_retenciones_retenido or 0) if totals else 0
        },
        "line_items": [
            {
                "order_index": item.order_index,
                "concepto": item.concepto,
                "codigo_base": item.codigo_base,
                "base_imponible": float(item.base_imponible or 0),
                "codigo_retencion": item.codigo_retencion,
                "valor_retenido": float(item.valor_retenido or 0)
            }
            for item in line_items
        ]
    }