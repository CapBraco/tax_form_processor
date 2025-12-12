"""
Form 104 API - COMPLETE VERSION WITH ALL 127 FIELDS
✅ Allows everyone to view form data
✅ Verifies ownership only for saved documents (registered users)
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import Optional

from app.core.database import get_db
from app.core.security import get_current_user_optional
from app.models.base import User, Document, Form104Data


router = APIRouter(prefix="/form-104", tags=["form-104"])


# Helper function to extract all fields from Form104Data model
def _extract_all_form_104_fields(form_data: Form104Data) -> dict:
    """
    Extracts all fields from a Form104Data object, dynamically handling types
    and ensuring floats/defaults (0.0 or [] for JSON).
    """
    data = {}

    for column in Form104Data.__table__.columns:

        # Exclude internal SQLAlchemy/DB columns
        if column.name in ["id", "document_id"]:
            continue

        value = getattr(form_data, column.name)

        if value is None:
            column_type_name = column.type.__class__.__name__

            if column_type_name == "Float":
                data[column.name] = 0.0
            elif column_type_name == "Integer":
                data[column.name] = 0
            elif column.name == "retenciones_iva":
                data[column.name] = []
            else:
                data[column.name] = None
        else:
            if column.type.__class__.__name__ == "Float":
                data[column.name] = float(value)
            else:
                data[column.name] = value

    return data


@router.get("/{document_id}/data")
async def get_form_104_data(
    document_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional)
):
    """
    Get Form 104 data - returns a flat dictionary of ALL 127 fields.
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

    # Extract all fields using the helper function
    data_payload = _extract_all_form_104_fields(form_data)
    data_payload["document_id"] = document_id

    return data_payload


@router.get("/{document_id}/complete")
async def get_form_104_complete(
    document_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional)
):
    """
    Get complete Form 104 data with document info, structured by section.
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

    # Extract all fields
    all_fields = _extract_all_form_104_fields(form_data)

    # GROUPING LOGIC

    ventas_fields = [
        k for k in all_fields.keys()
        if k.startswith((
            "ventas_", "activos_fijos_0_", "exportaciones_", "transferencias_",
            "notas_credito_", "ingresos_reembolso_"
        ))
    ]

    liquidacion_fields = [
        k for k in all_fields.keys()
        if k.startswith((
            "transferencias_contado_", "impuesto_liquidar_", "mes_pagar_",
            "tamano_copci", "total_impuesto_liquidar_"
        ))
    ]

    compras_fields = [
        k for k in all_fields.keys()
        if k.startswith((
            "adquisiciones_", "activos_fijos_diferente_", "impuesto_activos_fijos_",
            "importaciones_", "pagos_reembolso_", "factor_", "iva_no_considerado_",
            "ajuste_positivo_", "ajuste_negativo_"
        ))
    ]

    exportaciones_isd_fields = [
        k for k in all_fields.keys()
        if k.startswith(("importaciones_materias_primas_", "proporcion_"))
    ]

    excluded_fields = (
        ventas_fields +
        liquidacion_fields +
        compras_fields +
        exportaciones_isd_fields +
        ["retenciones_iva"]
    )

    totals_fields = [
        k for k in all_fields.keys() if k not in excluded_fields
    ]

    return {
        "document": {
            "id": document.id,
            "filename": document.original_filename,
            "razon_social": document.razon_social,
            "identificacion_ruc": document.identificacion_ruc,
            "periodo": document.periodo_fiscal_completo
        },
        "ventas": {k: all_fields[k] for k in ventas_fields},
        "liquidacion": {k: all_fields[k] for k in liquidacion_fields},
        "compras": {k: all_fields[k] for k in compras_fields},
        "exportaciones_isd": {k: all_fields[k] for k in exportaciones_isd_fields},
        "retenciones_iva": all_fields.get("retenciones_iva", []),
        "totals": {k: all_fields[k] for k in totals_fields}
    }