"""
Form 104 (IVA) Parser Service - FINAL COMPREHENSIVE VERSION
Extracts ALL structured data matching arrow-marked fields in PDF
✅ Captures ALL monetary values from rows: 401, 403, 405, 409, 419, 429, 499, 500, 507, 508, 509, 519, 520, 529, 564, 601, 609, 620, 699, 721-731, 799, 801, 859, 902, 999
"""

import re
from typing import Dict, List


class Form104Parser:
    """Parser for Ecuadorian Form 104 - VAT (IVA) Declaration"""
    
    def parse(self, text: str) -> Dict:
        """
        Parse Form 104 and extract ALL structured data (including zero values)
        Returns all fields marked with arrows in the reference document
        """
        result = {
            "form_type": "form_104",
            "header": self._extract_header(text),
            "ventas": self._extract_ventas(text),
            "compras": self._extract_compras(text),
            "retenciones_iva": self._extract_retenciones(text),
            "totals": self._extract_totals(text)
        }
        
        return result
    
    def _extract_header(self, text: str) -> Dict:
        """Extract header information"""
        header = {}
        
        patterns = {
            "codigo_verificador": r"CÓDIGO VERIFICADOR\s+([A-Z0-9]+)",
            "numero_serial": r"NÚMERO SERIAL\s+(\d+)",
            "fecha_recaudacion": r"FECHA RECAUDACIÓN\s+(\d{2}-\d{2}-\d{4})",
            "obligacion_tributaria": r"Obligación Tributaria:\s+(\d+\s+[A-ZÁÉÍÓÚÑ\s]+)",
            "identificacion": r"Identificación:\s+(\d+)",
            "razon_social": r"Razón Social:\s+([A-ZÁÉÍÓÚÑ\s\.]+?)(?:\n|Período)",
            "periodo_fiscal": r"Período Fiscal:\s+([A-Z]+)\s+(\d{4})",
            "tipo_declaracion": r"Tipo Declaración:\s+([A-Z]+)"
        }
        
        for key, pattern in patterns.items():
            match = re.search(pattern, text, re.IGNORECASE | re.MULTILINE)
            if match:
                if key == "periodo_fiscal":
                    header["periodo_mes"] = match.group(1).strip()
                    header["periodo_anio"] = match.group(2).strip()
                else:
                    header[key] = match.group(1).strip()
        
        return header
    
    def _extract_ventas(self, text: str) -> Dict:
        """
        Extract ALL sales (ventas) values marked with arrows in PDF
        """
        ventas = {}
        
        # ⬅️ Row 401 - Ventas locales tarifa diferente de cero (ARROW MARKED)
        match_401_bruto = re.search(r'\b401\b\s+([\d,\.]+)', text)
        ventas["ventas_tarifa_diferente_cero_bruto"] = self._parse_float(match_401_bruto.group(1)) if match_401_bruto else 0.0
        
        # ⬅️ Row 411 - Ventas neto (ARROW MARKED)
        match_411_neto = re.search(r'\b411\b\s+([\d,\.]+)', text)
        ventas["ventas_tarifa_diferente_cero_neto"] = self._parse_float(match_411_neto.group(1)) if match_411_neto else 0.0
        
        # ⬅️ Row 421 - Impuesto generado (ARROW MARKED)
        match_421_impuesto = re.search(r'\b421\b\s+([\d,\.]+)', text)
        ventas["impuesto_generado"] = self._parse_float(match_421_impuesto.group(1)) if match_421_impuesto else 0.0
        
        # Row 423 - Ajuste a pagar
        match_423 = re.search(r'\b423\b\s+([\d,\.]+)', text)
        ventas["iva_ajuste_pagar"] = self._parse_float(match_423.group(1)) if match_423 else 0.0
        
        # Row 424 - Ajuste a favor
        match_424 = re.search(r'\b424\b\s+([\d,\.]+)', text)
        ventas["iva_ajuste_favor"] = self._parse_float(match_424.group(1)) if match_424 else 0.0
        
        # ⬅️ Row 403 - Ventas tarifa 0% sin derecho (ARROW MARKED)
        match_403 = re.search(r'\b403\b\s+([\d,\.]+)', text)
        ventas["ventas_tarifa_cero_sin_derecho"] = self._parse_float(match_403.group(1)) if match_403 else 0.0
        
        # Row 413 - Ventas tarifa 0% sin derecho (neto)
        match_413 = re.search(r'\b413\b\s+([\d,\.]+)', text)
        ventas["ventas_tarifa_cero_sin_derecho_neto"] = self._parse_float(match_413.group(1)) if match_413 else 0.0
        
        # ⬅️ Row 405 - Ventas tarifa 0% con derecho (ARROW MARKED)
        match_405 = re.search(r'\b405\b\s+([\d,\.]+)', text)
        ventas["ventas_tarifa_cero_con_derecho"] = self._parse_float(match_405.group(1)) if match_405 else 0.0
        
        # Row 415 - Ventas tarifa 0% con derecho (neto)
        match_415 = re.search(r'\b415\b\s+([\d,\.]+)', text)
        ventas["ventas_tarifa_cero_con_derecho_neto"] = self._parse_float(match_415.group(1)) if match_415 else 0.0
        
        # ⬅️ Row 409 - TOTAL VENTAS (Bruto) (ARROW MARKED)
        match_409_bruto = re.search(r'\b409\b\s+([\d,\.]+)', text)
        ventas["total_ventas_bruto"] = self._parse_float(match_409_bruto.group(1)) if match_409_bruto else 0.0
        
        # ⬅️ Row 419 - TOTAL VENTAS (Neto) (ARROW MARKED)
        match_419_neto = re.search(r'\b419\b\s+([\d,\.]+)', text)
        ventas["total_ventas_neto"] = self._parse_float(match_419_neto.group(1)) if match_419_neto else 0.0
        
        # ⬅️ Row 429 - TOTAL IMPUESTO GENERADO (ARROW MARKED)
        match_429_impuesto = re.search(r'\b429\b\s+([\d,\.]+)', text)
        ventas["total_impuesto_generado"] = self._parse_float(match_429_impuesto.group(1)) if match_429_impuesto else 0.0
        
        # Row 431 - Transferencias no objeto o exentas
        match_431 = re.search(r'\b431\b\s+([\d,\.]+)', text)
        ventas["transferencias_no_objeto_exentas"] = self._parse_float(match_431.group(1)) if match_431 else 0.0
        
        # Row 434 - Ingresos por reembolso
        match_434 = re.search(r'\b434\b\s+([\d,\.]+)', text)
        ventas["ingresos_reembolso"] = self._parse_float(match_434.group(1)) if match_434 else 0.0
        
        # Row 482 - Total impuesto generado (verificación)
        match_482 = re.search(r'\b482\b\s+([\d,\.]+)', text)
        ventas["total_impuesto_generado_482"] = self._parse_float(match_482.group(1)) if match_482 else 0.0
        
        # Row 483 - Impuesto a liquidar del mes anterior
        match_483 = re.search(r'\b483\b\s+([\d,\.]+)', text)
        ventas["impuesto_liquidar_mes_anterior"] = self._parse_float(match_483.group(1)) if match_483 else 0.0
        
        # Row 484 - Impuesto a liquidar en este mes
        match_484 = re.search(r'\b484\b\s+([\d,\.]+)', text)
        ventas["impuesto_liquidar_este_mes"] = self._parse_float(match_484.group(1)) if match_484 else 0.0
        
        # ⬅️ Row 499 - TOTAL IMPUESTO A LIQUIDAR (ARROW MARKED)
        match_499 = re.search(r'\b499\b\s+([\d,\.]+)', text)
        ventas["total_impuesto_liquidar"] = self._parse_float(match_499.group(1)) if match_499 else 0.0
        
        return ventas
    
    def _extract_compras(self, text: str) -> Dict:
        """
        Extract ALL purchases (adquisiciones) values marked with arrows in PDF
        """
        compras = {}
        
        # ⬅️ Row 500 - Adquisiciones tarifa diferente de cero con derecho (Bruto) (ARROW MARKED)
        match_500_bruto = re.search(r'\b500\b\s+([\d,\.]+)', text)
        compras["adquisiciones_tarifa_diferente_cero_bruto"] = self._parse_float(match_500_bruto.group(1)) if match_500_bruto else 0.0
        
        # ⬅️ Row 510 - Adquisiciones tarifa diferente de cero con derecho (Neto) (ARROW MARKED)
        match_510_neto = re.search(r'\b510\b\s+([\d,\.]+)', text)
        compras["adquisiciones_tarifa_diferente_cero_neto"] = self._parse_float(match_510_neto.group(1)) if match_510_neto else 0.0
        
        # ⬅️ Row 520 - Impuesto compras (IVA on purchases) (ARROW MARKED)
        match_520_impuesto = re.search(r'\b520\b\s+([\d,\.]+)', text)
        compras["impuesto_compras"] = self._parse_float(match_520_impuesto.group(1)) if match_520_impuesto else 0.0
        
        # Row 502 - Otras adquisiciones sin derecho (bruto)
        match_502 = re.search(r'\b502\b\s+([\d,\.]+)', text)
        compras["otras_adquisiciones_sin_derecho"] = self._parse_float(match_502.group(1)) if match_502 else 0.0
        
        # Row 512 - Otras adquisiciones sin derecho (neto)
        match_512 = re.search(r'\b512\b\s+([\d,\.]+)', text)
        compras["otras_adquisiciones_sin_derecho_neto"] = self._parse_float(match_512.group(1)) if match_512 else 0.0
        
        # Row 522 - Impuesto otras adquisiciones sin derecho
        match_522 = re.search(r'\b522\b\s+([\d,\.]+)', text)
        compras["impuesto_otras_adquisiciones"] = self._parse_float(match_522.group(1)) if match_522 else 0.0
        
        # Row 526 - Ajuste positivo al crédito
        match_526 = re.search(r'\b526\b\s+([\d,\.]+)', text)
        compras["ajuste_positivo_credito"] = self._parse_float(match_526.group(1)) if match_526 else 0.0
        
        # Row 527 - Ajuste negativo al crédito
        match_527 = re.search(r'\b527\b\s+([\d,\.]+)', text)
        compras["ajuste_negativo_credito"] = self._parse_float(match_527.group(1)) if match_527 else 0.0
        
        # ⬅️ Row 507 - Adquisiciones tarifa 0% (ARROW MARKED)
        match_507 = re.search(r'\b507\b\s+([\d,\.]+)', text)
        compras["adquisiciones_tarifa_cero"] = self._parse_float(match_507.group(1)) if match_507 else 0.0
        
        # Row 517 - Adquisiciones tarifa 0% (neto)
        match_517 = re.search(r'\b517\b\s+([\d,\.]+)', text)
        compras["adquisiciones_tarifa_cero_neto"] = self._parse_float(match_517.group(1)) if match_517 else 0.0
        
        # ⬅️ Row 508 - Adquisiciones RISE (ARROW MARKED)
        match_508 = re.search(r'\b508\b\s+([\d,\.]+)', text)
        compras["adquisiciones_rise"] = self._parse_float(match_508.group(1)) if match_508 else 0.0
        
        # Row 518 - Adquisiciones RISE (neto)
        match_518 = re.search(r'\b518\b\s+([\d,\.]+)', text)
        compras["adquisiciones_rise_neto"] = self._parse_float(match_518.group(1)) if match_518 else 0.0
        
        # ⬅️ Row 509 - TOTAL ADQUISICIONES (Bruto) (ARROW MARKED)
        match_509_bruto = re.search(r'\b509\b\s+([\d,\.]+)', text)
        compras["total_adquisiciones"] = self._parse_float(match_509_bruto.group(1)) if match_509_bruto else 0.0
        
        # ⬅️ Row 519 - TOTAL ADQUISICIONES (Neto) (ARROW MARKED)
        match_519_neto = re.search(r'\b519\b\s+([\d,\.]+)', text)
        compras["total_adquisiciones_neto"] = self._parse_float(match_519_neto.group(1)) if match_519_neto else 0.0
        
        # ⬅️ Row 529 - Total impuesto compras (ARROW MARKED)
        match_529 = re.search(r'\b529\b\s+([\d,\.]+)', text)
        compras["total_impuesto_compras"] = self._parse_float(match_529.group(1)) if match_529 else 0.0
        
        # Row 531 - Adquisiciones no objeto de IVA
        match_531 = re.search(r'\b531\b\s+([\d,\.]+)', text)
        compras["adquisiciones_no_objeto"] = self._parse_float(match_531.group(1)) if match_531 else 0.0
        
        # Row 532 - Adquisiciones exentas
        match_532 = re.search(r'\b532\b\s+([\d,\.]+)', text)
        compras["adquisiciones_exentas"] = self._parse_float(match_532.group(1)) if match_532 else 0.0
        
        # Row 535 - Pagos netos por reembolso
        match_535 = re.search(r'\b535\b\s+([\d,\.]+)', text)
        compras["pagos_reembolso"] = self._parse_float(match_535.group(1)) if match_535 else 0.0
        
        # Row 563 - Factor proporcionalidad
        match_563 = re.search(r'\b563\b\s+([\d,\.]+)', text)
        compras["factor_proporcionalidad"] = self._parse_float(match_563.group(1)) if match_563 else 0.0
        
        # ⬅️ Row 564 - Crédito tributario aplicable (ARROW MARKED - MOST IMPORTANT)
        match_564 = re.search(r'\b564\b\s+([\d,\.]+)', text)
        compras["credito_tributario_aplicable"] = self._parse_float(match_564.group(1)) if match_564 else 0.0
        
        # Row 565 - Valor IVA no considerado como crédito
        match_565 = re.search(r'\b565\b\s+([\d,\.]+)', text)
        compras["iva_no_credito"] = self._parse_float(match_565.group(1)) if match_565 else 0.0
        
        return compras
    
    def _extract_retenciones(self, text: str) -> List[Dict]:
        """
        Extract ALL VAT retentions marked with arrows in PDF
        """
        retenciones = []
        
        # Map of retention percentages to their row codes (ALL ARROW MARKED)
        retention_patterns = {
            "10": r'\b721\b\s+([\d,\.]+)',
            "20": r'\b723\b\s+([\d,\.]+)',
            "30": r'\b725\b\s+([\d,\.]+)',    # ⬅️ ARROW MARKED
            "50": r'\b727\b\s+([\d,\.]+)',
            "70": r'\b729\b\s+([\d,\.]+)',    # ⬅️ ARROW MARKED
            "100": r'\b731\b\s+([\d,\.]+)'    # ⬅️ ARROW MARKED
        }
        
        for percentage, pattern in retention_patterns.items():
            match = re.search(pattern, text, re.IGNORECASE)
            valor = 0.0
            if match:
                try:
                    valor = self._parse_float(match.group(1))
                except:
                    valor = 0.0
            
            # Include ALL retention lines (even zeros)
            retenciones.append({
                "porcentaje": int(percentage),
                "valor": valor
            })
        
        return retenciones
    
    def _extract_totals(self, text: str) -> Dict:
        """
        Extract ALL summary totals marked with arrows in PDF
        """
        totals = {}
        
        # Row 601 - Impuesto causado (Tax caused)
        match_601 = re.search(r'\b601\b\s+([\d,\.]+)', text)
        totals["impuesto_causado"] = self._parse_float(match_601.group(1)) if match_601 else 0.0
        
        # Row 602 - Crédito tributario aplicable
        match_602 = re.search(r'\b602\b\s+([\d,\.]+)', text)
        totals["credito_tributario_602"] = self._parse_float(match_602.group(1)) if match_602 else 0.0
        
        # Row 603 - Compensación IVA medio electrónico
        match_603 = re.search(r'\b603\b\s+([\d,\.]+)', text)
        totals["compensacion_iva_electronico"] = self._parse_float(match_603.group(1)) if match_603 else 0.0
        
        # Row 605 - Saldo crédito mes anterior - adquisiciones
        match_605 = re.search(r'\b605\b\s+([\d,\.]+)', text)
        totals["saldo_credito_anterior_adquisiciones"] = self._parse_float(match_605.group(1)) if match_605 else 0.0
        
        # Row 606 - Saldo crédito mes anterior - retenciones
        match_606 = re.search(r'\b606\b\s+([\d,\.]+)', text)
        totals["saldo_credito_anterior_retenciones"] = self._parse_float(match_606.group(1)) if match_606 else 0.0
        
        # Row 607 - Saldo crédito mes anterior - compensación electrónico
        match_607 = re.search(r'\b607\b\s+([\d,\.]+)', text)
        totals["saldo_credito_anterior_electronico"] = self._parse_float(match_607.group(1)) if match_607 else 0.0
        
        # Row 608 - Saldo crédito mes anterior - compensación zonas afectadas
        match_608 = re.search(r'\b608\b\s+([\d,\.]+)', text)
        totals["saldo_credito_anterior_zonas"] = self._parse_float(match_608.group(1)) if match_608 else 0.0
        
        # ⬅️ Row 609 - Retenciones en la fuente efectuadas (ARROW MARKED)
        match_609 = re.search(r'\b609\b\s+([\d,\.]+)', text)
        totals["retenciones_efectuadas"] = self._parse_float(match_609.group(1)) if match_609 else 0.0
        
        # Row 610 - Ajuste IVA devuelto medio electrónico
        match_610 = re.search(r'\b610\b\s+([\d,\.]+)', text)
        totals["ajuste_iva_devuelto_electronico"] = self._parse_float(match_610.group(1)) if match_610 else 0.0
        
        # Row 612 - Ajuste IVA devuelto/rechazado - adquisiciones
        match_612 = re.search(r'\b612\b\s+([\d,\.]+)', text)
        totals["ajuste_iva_devuelto_adquisiciones"] = self._parse_float(match_612.group(1)) if match_612 else 0.0
        
        # Row 613 - Ajuste IVA devuelto/rechazado - retenciones
        match_613 = re.search(r'\b613\b\s+([\d,\.]+)', text)
        totals["ajuste_iva_devuelto_retenciones"] = self._parse_float(match_613.group(1)) if match_613 else 0.0
        
        # Row 614 - Ajuste IVA otras instituciones públicas
        match_614 = re.search(r'\b614\b\s+([\d,\.]+)', text)
        totals["ajuste_iva_otras_instituciones"] = self._parse_float(match_614.group(1)) if match_614 else 0.0
        
        # Row 615 - Saldo crédito para próximo mes - adquisiciones
        match_615 = re.search(r'\b615\b\s+([\d,\.]+)', text)
        totals["saldo_credito_proximo_adquisiciones"] = self._parse_float(match_615.group(1)) if match_615 else 0.0
        
        # Row 617 - Saldo crédito para próximo mes - retenciones
        match_617 = re.search(r'\b617\b\s+([\d,\.]+)', text)
        totals["saldo_credito_proximo_retenciones"] = self._parse_float(match_617.group(1)) if match_617 else 0.0
        
        # Row 618 - Saldo crédito para próximo mes - compensación electrónico
        match_618 = re.search(r'\b618\b\s+([\d,\.]+)', text)
        totals["saldo_credito_proximo_electronico"] = self._parse_float(match_618.group(1)) if match_618 else 0.0
        
        # Row 619 - Saldo crédito para próximo mes - zonas afectadas
        match_619 = re.search(r'\b619\b\s+([\d,\.]+)', text)
        totals["saldo_credito_proximo_zonas"] = self._parse_float(match_619.group(1)) if match_619 else 0.0
        
        # ⬅️ Row 620 - SUBTOTAL A PAGAR (ARROW MARKED - KEY VALUE)
        match_620 = re.search(r'\b620\b\s+([\d,\.]+)', text)
        totals["subtotal_a_pagar"] = self._parse_float(match_620.group(1)) if match_620 else 0.0
        
        # Row 622 - IVA devuelto por transacciones adultos mayores
        match_622 = re.search(r'\b622\b\s+([\d,\.]+)', text)
        totals["iva_devuelto_adultos_mayores"] = self._parse_float(match_622.group(1)) if match_622 else 0.0
        
        # Row 624 - IVA pagado no compensado
        match_624 = re.search(r'\b624\b\s+([\d,\.]+)', text)
        totals["iva_pagado_no_compensado"] = self._parse_float(match_624.group(1)) if match_624 else 0.0
        
        # Row 625 - Ajuste crédito tributario superior 5 años
        match_625 = re.search(r'\b625\b\s+([\d,\.]+)', text)
        totals["ajuste_credito_superior_5_anos"] = self._parse_float(match_625.group(1)) if match_625 else 0.0
        
        # ⬅️ Row 699 - TOTAL IMPUESTO A PAGAR POR PERCEPCION (ARROW MARKED)
        match_699 = re.search(r'\b699\b\s+([\d,\.]+)', text)
        totals["total_impuesto_pagar_percepcion"] = self._parse_float(match_699.group(1)) if match_699 else 0.0
        
        # ⬅️ Row 799 - TOTAL IMPUESTO RETENIDO (ARROW MARKED)
        match_799 = re.search(r'\b799\b\s+([\d,\.]+)', text)
        totals["total_impuesto_retenido"] = self._parse_float(match_799.group(1)) if match_799 else 0.0
        
        # ⬅️ Row 801 - TOTAL IMPUESTO A PAGAR POR RETENCIÓN (ARROW MARKED)
        match_801 = re.search(r'\b801\b\s+([\d,\.]+)', text)
        totals["total_impuesto_pagar_retencion"] = self._parse_float(match_801.group(1)) if match_801 else 0.0
        
        # ⬅️ Row 859 - TOTAL CONSOLIDADO IVA (ARROW MARKED - VERY IMPORTANT)
        match_859 = re.search(r'\b859\b\s+([\d,\.]+)', text)
        totals["total_consolidado_iva"] = self._parse_float(match_859.group(1)) if match_859 else 0.0
        
        # Row 887 - Field marker
        match_887 = re.search(r'\b887\b\s+([\d,\.]+)', text)
        if match_887:
            totals["field_887"] = self._parse_float(match_887.group(1))
        
        # ⬅️ Row 902 - TOTAL IMPUESTO A PAGAR (ARROW MARKED)
        match_902 = re.search(r'\b902\b\s+([\d,\.]+)', text)
        totals["total_impuesto_a_pagar"] = self._parse_float(match_902.group(1)) if match_902 else 0.0
        
        # Row 903 - Interés por mora
        match_903 = re.search(r'\b903\b\s+([\d,\.]+)', text)
        totals["interes_mora"] = self._parse_float(match_903.group(1)) if match_903 else 0.0
        
        # Row 904 - Multa
        match_904 = re.search(r'\b904\b\s+([\d,\.]+)', text)
        totals["multa"] = self._parse_float(match_904.group(1)) if match_904 else 0.0
        
        # ⬅️ Row 999 - TOTAL PAGADO (ARROW MARKED - MOST IMPORTANT VALUE)
        match_999 = re.search(r'\b999\b\s+([\d,\.]+)', text)
        totals["total_pagado"] = self._parse_float(match_999.group(1)) if match_999 else 0.0
        
        return totals
    
    def _parse_float(self, value_str: str) -> float:
        """
        Helper method to parse float values from text
        Handles formats like: 1,234.56 or 1234.56
        """
        try:
            # Remove commas and parse
            clean_str = value_str.replace(',', '').strip()
            return float(clean_str)
        except (ValueError, AttributeError):
            return 0.0


# ✅ CRITICAL: Singleton instance export
form_104_parser = Form104Parser()