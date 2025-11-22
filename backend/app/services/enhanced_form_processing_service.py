"""
Enhanced Form Processing Service
Processes PDFs, extracts structured data using form-specific parsers
"""

import os
from datetime import datetime
from typing import Dict
import logging
import re

from sqlalchemy.ext.asyncio import AsyncSession

from app.models.base import Document, ProcessingStatusEnum, FormTypeEnum, Form103LineItem, Form104Data
from app.services.pdf_service import pdf_service
from app.services.form_103_parser import form_103_parser
from app.services.form_104_parser import form_104_parser

logger = logging.getLogger(__name__)


class EnhancedFormProcessingService:
    """Service for processing uploaded PDF documents with form-specific parsing"""
    
    async def process_uploaded_document(
        self,
        file_path: str,
        original_filename: str,
        file_size: int,
        db: AsyncSession
    ) -> Document:
        """
        Process an uploaded PDF:
        1. Extract text from PDF
        2. Detect form type
        3. Parse structured data
        4. Save to database
        
        Args:
            file_path: Path to the uploaded PDF file
            original_filename: Original filename
            file_size: File size in bytes
            db: Database session
            
        Returns:
            Document model instance
        """
        logger.info(f"Processing document: {original_filename}")
        
        # Create initial document record
        document = Document(
            filename=os.path.basename(file_path),
            original_filename=original_filename,
            file_path=file_path,
            file_size=file_size,
            processing_status=ProcessingStatusEnum.PROCESSING
        )
        db.add(document)
        await db.commit()
        await db.refresh(document)
        
        try:
            # Extract text from PDF
            logger.info(f"Extracting text from {original_filename}")
            result = await pdf_service.extract_all_text(file_path)
            
            if not result["success"]:
                document.processing_status = ProcessingStatusEnum.FAILED
                document.processing_error = result.get("error", "Text extraction failed")
                await db.commit()
                return document
            
            # Update document with extracted text
            document.extracted_text = result["full_text"]
            document.total_pages = result["total_pages"]
            document.total_characters = result["total_characters"]
            
            # Detect form type
            form_type = self._detect_form_type(result["full_text"], original_filename)
            document.form_type = form_type
            
            # Parse structured data based on form type
            if form_type == FormTypeEnum.FORM_103:
                await self._process_form_103(document, result["full_text"], db)
            elif form_type == FormTypeEnum.FORM_104:
                await self._process_form_104(document, result["full_text"], db)
            
            document.processing_status = ProcessingStatusEnum.COMPLETED
            document.processed_at = datetime.utcnow()
            
            logger.info(f"Successfully processed: {original_filename} as {form_type}")
            
        except Exception as e:
            logger.error(f"Error processing document {original_filename}: {e}")
            document.processing_status = ProcessingStatusEnum.FAILED
            document.processing_error = str(e)
        
        await db.commit()
        await db.refresh(document)
        return document
    
    def _detect_form_type(self, text: str, filename: str) -> FormTypeEnum:
        """Detect form type from text content and filename"""
        
        # Check filename first
        filename_lower = filename.lower()
        if '103' in filename_lower:
            return FormTypeEnum.FORM_103
        elif '104' in filename_lower:
            return FormTypeEnum.FORM_104
        
        # Check content
        if re.search(r"1031.*?DECLARACIÓN DE RETENCIONES EN LA FUENTE", text, re.IGNORECASE):
            return FormTypeEnum.FORM_103
        elif re.search(r"2011.*?DECLARACION DE IVA", text, re.IGNORECASE):
            return FormTypeEnum.FORM_104
        
        return FormTypeEnum.UNKNOWN
    
    async def _process_form_103(self, document: Document, text: str, db: AsyncSession):
        """Process Form 103 specific data"""
        try:
            # Parse form 103
            parsed = form_103_parser.parse(text)
            
            # Store parsed data as JSON
            document.parsed_data = parsed
            
            # Extract header fields
            header = parsed.get("header", {})
            document.codigo_verificador = header.get("codigo_verificador")
            document.numero_serial = header.get("numero_serial")
            
            # Parse fecha_recaudacion
            fecha_str = header.get("fecha_recaudacion")
            if fecha_str:
                try:
                    document.fecha_recaudacion = datetime.strptime(fecha_str, "%d-%m-%Y")
                except:
                    pass
            
            document.identificacion_ruc = header.get("identificacion")
            document.razon_social = header.get("razon_social")
            document.periodo_mes = header.get("periodo_mes")
            document.periodo_anio = header.get("periodo_anio")
            
            # Store line items
            for idx, item in enumerate(parsed.get("line_items", [])):
                line_item = Form103LineItem(
                    document_id=document.id,
                    concepto=item["concepto"],
                    codigo_base=item["codigo_base"],
                    base_imponible=item["base_imponible"],
                    codigo_retencion=item["codigo_retencion"],
                    valor_retenido=item["valor_retenido"],
                    order_index=idx
                )
                db.add(line_item)
            
            logger.info(f"Processed {len(parsed.get('line_items', []))} line items for Form 103")
            
        except Exception as e:
            logger.error(f"Error processing Form 103: {e}")
            raise
    
    async def _process_form_104(self, document: Document, text: str, db: AsyncSession):
        """Process Form 104 specific data"""
        try:
            # Parse form 104
            parsed = form_104_parser.parse(text)
            
            # Store parsed data as JSON
            document.parsed_data = parsed
            
            # Extract header fields
            header = parsed.get("header", {})
            document.codigo_verificador = header.get("codigo_verificador")
            document.numero_serial = header.get("numero_serial")
            
            # Parse fecha_recaudacion
            fecha_str = header.get("fecha_recaudacion")
            if fecha_str:
                try:
                    document.fecha_recaudacion = datetime.strptime(fecha_str, "%d-%m-%Y")
                except:
                    pass
            
            document.identificacion_ruc = header.get("identificacion")
            document.razon_social = header.get("razon_social")
            document.periodo_mes = header.get("periodo_mes")
            document.periodo_anio = header.get("periodo_anio")
            
            # Create Form104Data record
            ventas = parsed.get("ventas", {})
            compras = parsed.get("compras", {})
            totals = parsed.get("totals", {})
            retenciones = parsed.get("retenciones_iva", [])
            
            form_104_data = Form104Data(
                document_id=document.id,
                # Ventas
                ventas_tarifa_diferente_cero_bruto=ventas.get("ventas_tarifa_diferente_cero_bruto", 0.0),
                ventas_tarifa_diferente_cero_neto=ventas.get("ventas_tarifa_diferente_cero_neto", 0.0),
                impuesto_generado=ventas.get("impuesto_generado", 0.0),
                total_ventas_bruto=ventas.get("total_ventas_bruto", 0.0),
                total_ventas_neto=ventas.get("total_ventas_neto", 0.0),
                total_impuesto_generado=ventas.get("total_impuesto_generado", 0.0),
                # Compras
                adquisiciones_tarifa_diferente_cero_bruto=compras.get("adquisiciones_tarifa_diferente_cero_bruto", 0.0),
                adquisiciones_tarifa_diferente_cero_neto=compras.get("adquisiciones_tarifa_diferente_cero_neto", 0.0),
                impuesto_compras=compras.get("impuesto_compras", 0.0),
                adquisiciones_tarifa_cero=compras.get("adquisiciones_tarifa_cero", 0.0),
                total_adquisiciones=compras.get("total_adquisiciones", 0.0),
                credito_tributario_aplicable=compras.get("credito_tributario_aplicable", 0.0),
                # Retenciones
                retenciones_iva=retenciones,
                # Totals
                impuesto_causado=totals.get("impuesto_causado", 0.0),
                retenciones_efectuadas=totals.get("retenciones_efectuadas", 0.0),
                subtotal_a_pagar=totals.get("subtotal_a_pagar", 0.0),
                total_impuesto_retenido=totals.get("total_impuesto_retenido", 0.0),
                total_impuesto_pagar_retencion=totals.get("total_impuesto_pagar_retencion", 0.0),
                total_consolidado_iva=totals.get("total_consolidado_iva", 0.0),
                total_pagado=totals.get("total_pagado", 0.0)
            )
            db.add(form_104_data)
            
            logger.info(f"Processed Form 104 with total pagado: {form_104_data.total_pagado}")
            
        except Exception as e:
            logger.error(f"Error processing Form 104: {e}")
            raise


# Create singleton instance
enhanced_form_processing_service = EnhancedFormProcessingService()
