"""
Clientes API Endpoints - ASYNC Compatible
Handles client organization, yearly summaries, and exports
"""

from fastapi import APIRouter, Depends, HTTPException, Response
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from typing import List, Dict, Optional
from datetime import datetime
from pydantic import BaseModel

from app.core.database import get_db
from app.models.base import Document, Form103LineItem, Form104Data, Form103Totals, FormTypeEnum

router = APIRouter(prefix="/clientes", tags=["clientes"])


# Pydantic models for requests/responses
class ClientSummary(BaseModel):
    razon_social: str
    document_count: int
    first_year: str
    last_year: str


class FormInfo(BaseModel):
    id: int
    filename: str
    uploaded_at: str
    identificacion_ruc: Optional[str]


class MonthData(BaseModel):
    month: int
    periodo_fiscal: Optional[str]
    forms: Dict[str, Optional[FormInfo]]


class YearData(BaseModel):
    year: str
    months: List[MonthData]


class ClientDocuments(BaseModel):
    razon_social: str
    years: List[YearData]


# API Endpoints

@router.get("/", response_model=List[ClientSummary])
async def get_all_clients(db: AsyncSession = Depends(get_db)):
    """Get list of all unique clients (razon_social)"""
    
    query = select(
        Document.razon_social,
        func.count(Document.id).label('document_count'),
        func.min(Document.periodo_anio).label('first_year'),
        func.max(Document.periodo_anio).label('last_year')
    ).where(
        Document.razon_social.isnot(None)
    ).group_by(
        Document.razon_social
    ).order_by(
        Document.razon_social
    )
    
    result = await db.execute(query)
    clients = result.all()
    
    return [
        ClientSummary(
            razon_social=client.razon_social,
            document_count=client.document_count,
            first_year=client.first_year or "N/A",
            last_year=client.last_year or "N/A"
        )
        for client in clients
    ]


@router.get("/{razon_social}")
async def get_client_documents(
    razon_social: str,
    db: AsyncSession = Depends(get_db)
):
    """Get all documents for a specific client, organized by year and month"""
    
    query = select(Document).where(
        Document.razon_social == razon_social
    ).order_by(
        Document.periodo_anio.desc(),
        Document.periodo_mes_numero.asc()
    )
    
    result = await db.execute(query)
    documents = result.scalars().all()
    
    if not documents:
        raise HTTPException(status_code=404, detail="Client not found")
    
    # Organize by year and month
    organized = {}
    for doc in documents:
        if doc.periodo_anio:
            year = doc.periodo_anio
            if year not in organized:
                organized[year] = {'year': year, 'months': {}}
            
            month = doc.periodo_mes_numero or 0
            if month not in organized[year]['months']:
                organized[year]['months'][month] = {
                    'month': month,
                    'periodo_fiscal': doc.periodo_fiscal_completo,
                    'forms': {'form_103': None, 'form_104': None}
                }
            
            # Map FormTypeEnum to string key
            form_key = 'form_103' if doc.form_type == FormTypeEnum.FORM_103 else 'form_104'
            
            organized[year]['months'][month]['forms'][form_key] = {
                'id': doc.id,
                'filename': doc.original_filename,
                'uploaded_at': doc.uploaded_at.isoformat() if doc.uploaded_at else None,
                'identificacion_ruc': doc.identificacion_ruc
            }
    
    # Convert to list format
    result_years = []
    for year_data in organized.values():
        months_list = [month_data for month_data in year_data['months'].values()]
        months_list.sort(key=lambda x: x['month'])
        year_data['months'] = months_list
        result_years.append(year_data)
    
    result_years.sort(key=lambda x: x['year'], reverse=True)
    
    return {
        'razon_social': razon_social,
        'years': result_years
    }


@router.get("/{razon_social}/yearly-summary/{year}")
async def get_yearly_summary(
    razon_social: str,
    year: str,
    exclude_months: Optional[str] = None,  # Comma-separated month numbers
    db: AsyncSession = Depends(get_db)
):
    """
    Get yearly summary/accumulator for Form 103 and Form 104
    exclude_months: Optional comma-separated list of months to exclude (e.g., "1,5,12")
    """
    
    # Parse excluded months
    excluded = set()
    if exclude_months:
        try:
            excluded = set(int(m.strip()) for m in exclude_months.split(','))
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid exclude_months format")
    
    # Get all Form 103 documents for this client and year
    query_103 = select(Document).where(
        Document.razon_social == razon_social,
        Document.form_type == FormTypeEnum.FORM_103,
        Document.periodo_anio == year
    )
    
    if excluded:
        query_103 = query_103.where(Document.periodo_mes_numero.notin_(excluded))
    
    query_103 = query_103.order_by(Document.periodo_mes_numero)
    
    result = await db.execute(query_103)
    form_103_docs = result.scalars().all()
    
    # Get all Form 104 documents
    query_104 = select(Document).where(
        Document.razon_social == razon_social,
        Document.form_type == FormTypeEnum.FORM_104,
        Document.periodo_anio == year
    )
    
    if excluded:
        query_104 = query_104.where(Document.periodo_mes_numero.notin_(excluded))
    
    query_104 = query_104.order_by(Document.periodo_mes_numero)
    
    result = await db.execute(query_104)
    form_104_docs = result.scalars().all()
    
    # Initialize accumulators
    form_103_summary = {
        'subtotal_operaciones_pais': 0.0,
        'total_retencion': 0.0,
        'total_impuesto_pagar': 0.0,
        'total_pagado': 0.0,
        'monthly_details': []
    }
    
    form_104_summary = {
        'total_ventas_neto': 0.0,
        'total_impuesto_generado': 0.0,
        'total_adquisiciones': 0.0,
        'credito_tributario_aplicable': 0.0,
        'total_impuesto_retenido': 0.0,
        'total_pagado': 0.0,
        'monthly_details': []
    }
    
    # Accumulate Form 103 data
    for doc in form_103_docs:
        # Get totals from database
        query = select(Form103Totals).where(Form103Totals.document_id == doc.id)
        result = await db.execute(query)
        totals_record = result.scalar_one_or_none()
        
        if totals_record:
            month_data = {
                'month': doc.periodo_mes_numero,
                'periodo_fiscal': doc.periodo_fiscal_completo,
                'subtotal_operaciones_pais': totals_record.subtotal_operaciones_pais or 0.0,
                'total_retencion': totals_record.total_retencion or 0.0,
                'total_impuesto_pagar': totals_record.total_impuesto_pagar or 0.0,
                'total_pagado': totals_record.total_pagado or 0.0
            }
            
            form_103_summary['subtotal_operaciones_pais'] += month_data['subtotal_operaciones_pais']
            form_103_summary['total_retencion'] += month_data['total_retencion']
            form_103_summary['total_impuesto_pagar'] += month_data['total_impuesto_pagar']
            form_103_summary['total_pagado'] += month_data['total_pagado']
            form_103_summary['monthly_details'].append(month_data)
    
    # Accumulate Form 104 data
    for doc in form_104_docs:
        query = select(Form104Data).where(Form104Data.document_id == doc.id)
        result = await db.execute(query)
        form_104_data = result.scalar_one_or_none()
        
        if form_104_data:
            month_data = {
                'month': doc.periodo_mes_numero,
                'periodo_fiscal': doc.periodo_fiscal_completo,
                'total_ventas_neto': form_104_data.total_ventas_neto or 0.0,
                'total_impuesto_generado': form_104_data.total_impuesto_generado or 0.0,
                'total_adquisiciones': form_104_data.total_adquisiciones or 0.0,
                'credito_tributario_aplicable': form_104_data.credito_tributario_aplicable or 0.0,
                'total_impuesto_retenido': form_104_data.total_impuesto_retenido or 0.0,
                'total_pagado': form_104_data.total_pagado or 0.0
            }
            
            for key in ['total_ventas_neto', 'total_impuesto_generado', 'total_adquisiciones',
                       'credito_tributario_aplicable', 'total_impuesto_retenido', 'total_pagado']:
                form_104_summary[key] += month_data[key]
            
            form_104_summary['monthly_details'].append(month_data)
    
    # Check for missing months
    present_months_103 = set(doc.periodo_mes_numero for doc in form_103_docs if doc.periodo_mes_numero)
    present_months_104 = set(doc.periodo_mes_numero for doc in form_104_docs if doc.periodo_mes_numero)
    all_months = set(range(1, 13))
    
    missing_months_103 = sorted(all_months - present_months_103 - excluded)
    missing_months_104 = sorted(all_months - present_months_104 - excluded)
    
    return {
        'razon_social': razon_social,
        'year': year,
        'form_103_summary': form_103_summary,
        'form_104_summary': form_104_summary,
        'missing_months': {
            'form_103': missing_months_103,
            'form_104': missing_months_104
        },
        'excluded_months': sorted(excluded)
    }


@router.get("/{razon_social}/validation/{year}")
async def validate_year_completeness(
    razon_social: str,
    year: str,
    db: AsyncSession = Depends(get_db)
):
    """
    Validate that all 12 months have both Form 103 and Form 104
    Returns detailed validation report
    """
    
    query_103 = select(Document).where(
        Document.razon_social == razon_social,
        Document.form_type == FormTypeEnum.FORM_103,
        Document.periodo_anio == year
    )
    result = await db.execute(query_103)
    form_103_docs = result.scalars().all()
    
    query_104 = select(Document).where(
        Document.razon_social == razon_social,
        Document.form_type == FormTypeEnum.FORM_104,
        Document.periodo_anio == year
    )
    result = await db.execute(query_104)
    form_104_docs = result.scalars().all()
    
    present_103 = {doc.periodo_mes_numero: doc for doc in form_103_docs if doc.periodo_mes_numero}
    present_104 = {doc.periodo_mes_numero: doc for doc in form_104_docs if doc.periodo_mes_numero}
    
    month_names = [
        '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ]
    
    validation_report = []
    for month in range(1, 13):
        validation_report.append({
            'month': month,
            'month_name': month_names[month],
            'has_form_103': month in present_103,
            'has_form_104': month in present_104,
            'form_103_id': present_103[month].id if month in present_103 else None,
            'form_104_id': present_104[month].id if month in present_104 else None,
            'is_complete': month in present_103 and month in present_104
        })
    
    complete_months = sum(1 for r in validation_report if r['is_complete'])
    
    return {
        'razon_social': razon_social,
        'year': year,
        'complete_months': complete_months,
        'total_months': 12,
        'is_fully_complete': complete_months == 12,
        'validation_details': validation_report
    }
