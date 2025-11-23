"""
Enhanced Form Processing Service - FIXED
Processes PDFs, extracts structured data using form-specific parsers

FIX: Now creates Form103Totals records (was missing before!)
"""

import os
from datetime import datetime
from typing import Dict, Optional
import logging
import re

from sqlalchemy.ext.asyncio import AsyncSession

from app.models.base import (
    Document, 
    ProcessingStatusEnum, 
    FormTypeEnum, 
    Form103LineItem, 
    Form103Totals,  # ← Make sure this is imported!
    Form104Data
)
from app.services.pdf_service import pdf_service
from app.services.form_103_parser import form_103_parser
from app.services.form_104_parser import form_104_parser

logger = logging.getLogger(__name__)


class EnhancedFormProcessingService:
    """Service for processing uploaded PDF documents with form-specific parsing"""

    # ---------------------------------------------------------
    # Convert Spanish month name to month number
    # ---------------------------------------------------------
    def _convert_month_to_number(self, month_text: str) -> Optional[int]:
        if not month_text:
            return None

        months = {
            "ENERO": 1, "FEBRERO": 2, "MARZO": 3, "ABRIL": 4,
            "MAYO": 5, "JUNIO": 6, "JULIO": 7, "AGOSTO": 8,
            "SEPTIEMBRE": 9, "OCTUBRE": 10, "NOVIEMBRE": 11, "DICIEMBRE": 12
        }

        m = month_text.strip().upper()
        return months.get(m)

    # ---------------------------------------------------------
    # MAIN PROCESSOR
    # ---------------------------------------------------------
    async def process_uploaded_document(
        self,
        file_path: str,
        original_filename: str,
        file_size: int,
        db: AsyncSession
    ) -> Document:

        logger.info(f"Processing document: {original_filename}")

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
            # Extract text
            logger.info(f"Extracting text from {original_filename}")
            result = await pdf_service.extract_all_text(file_path)

            if not result["success"]:
                document.processing_status = ProcessingStatusEnum.FAILED
                document.processing_error = result.get("error", "Text extraction failed")
                await db.commit()
                return document

            document.extracted_text = result["full_text"]
            document.total_pages = result["total_pages"]
            document.total_characters = result["total_characters"]

            # Detect form type
            form_type = self._detect_form_type(result["full_text"], original_filename)
            document.form_type = form_type

            # Process according to form type
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

    # ---------------------------------------------------------
    # FORM TYPE DETECTION
    # ---------------------------------------------------------
    def _detect_form_type(self, text: str, filename: str) -> FormTypeEnum:
        filename_lower = filename.lower()
        if '103' in filename_lower:
            return FormTypeEnum.FORM_103
        elif '104' in filename_lower:
            return FormTypeEnum.FORM_104

        if re.search(r"1031.*?DECLARACIÓN DE RETENCIONES EN LA FUENTE", text, re.IGNORECASE):
            return FormTypeEnum.FORM_103
        elif re.search(r"2011.*?DECLARACION DE IVA", text, re.IGNORECASE):
            return FormTypeEnum.FORM_104

        return FormTypeEnum.UNKNOWN

    # ---------------------------------------------------------
    # PROCESS FORM 103 - FIXED VERSION
    # ---------------------------------------------------------
    async def _process_form_103(self, document: Document, text: str, db: AsyncSession):
        try:
            parsed = form_103_parser.parse(text)
            document.parsed_data = parsed

            header = parsed.get("header", {})
            document.codigo_verificador = header.get("codigo_verificador")
            document.numero_serial = header.get("numero_serial")

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

            # Convert month text → number
            document.periodo_mes_numero = self._convert_month_to_number(document.periodo_mes)

            # Line items
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

            # ✅ FIX: CREATE Form103Totals (THIS WAS MISSING!)
            totals = parsed.get("totals", {})
            form_103_totals = Form103Totals(
                document_id=document.id,
                subtotal_operaciones_pais=totals.get("subtotal_operaciones_pais", 0.0),
                total_retencion=totals.get("total_retencion", 0.0),
                total_impuesto_pagar=totals.get("total_impuesto_pagar", 0.0),
                total_pagado=totals.get("total_pagado", 0.0)
            )
            db.add(form_103_totals)
            
            logger.info(
                f"✅ Created Form103Totals - "
                f"Subtotal: {form_103_totals.subtotal_operaciones_pais}, "
                f"Retencion: {form_103_totals.total_retencion}, "
                f"Impuesto: {form_103_totals.total_impuesto_pagar}, "
                f"Pagado: {form_103_totals.total_pagado}"
            )

        except Exception as e:
            logger.error(f"Error processing Form 103: {e}")
            raise

    # ---------------------------------------------------------
    # PROCESS FORM 104
    # ---------------------------------------------------------
    async def _process_form_104(self, document: Document, text: str, db: AsyncSession):
        try:
            parsed = form_104_parser.parse(text)
            document.parsed_data = parsed

            header = parsed.get("header", {})
            document.codigo_verificador = header.get("codigo_verificador")
            document.numero_serial = header.get("numero_serial")

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

            # Convert month text → number
            document.periodo_mes_numero = self._convert_month_to_number(document.periodo_mes)

            ventas = parsed.get("ventas", {})
            compras = parsed.get("compras", {})
            totals = parsed.get("totals", {})
            retenciones = parsed.get("retenciones_iva", [])

            form_104_data = Form104Data(
                document_id=document.id,
                ventas_tarifa_diferente_cero_bruto=ventas.get("ventas_tarifa_diferente_cero_bruto", 0.0),
                ventas_tarifa_diferente_cero_neto=ventas.get("ventas_tarifa_diferente_cero_neto", 0.0),
                impuesto_generado=ventas.get("impuesto_generado", 0.0),
                total_ventas_bruto=ventas.get("total_ventas_bruto", 0.0),
                total_ventas_neto=ventas.get("total_ventas_neto", 0.0),
                total_impuesto_generado=ventas.get("total_impuesto_generado", 0.0),
                adquisiciones_tarifa_diferente_cero_bruto=compras.get("adquisiciones_tarifa_diferente_cero_bruto", 0.0),
                adquisiciones_tarifa_diferente_cero_neto=compras.get("adquisiciones_tarifa_diferente_cero_neto", 0.0),
                impuesto_compras=compras.get("impuesto_compras", 0.0),
                adquisiciones_tarifa_cero=compras.get("adquisiciones_tarifa_cero", 0.0),
                total_adquisiciones=compras.get("total_adquisiciones", 0.0),
                credito_tributario_aplicable=compras.get("credito_tributario_aplicable", 0.0),
                retenciones_iva=retenciones,
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


# Singleton
enhanced_form_processing_service = EnhancedFormProcessingService()
