"""
Form 104 (IVA) Parser Service
Extracts structured data from Ecuadorian Form 104 VAT declarations
"""

import re
from typing import Dict, List
from datetime import datetime


class Form104Parser:
    """Parser for Ecuadorian Form 104 - VAT (IVA) Declaration"""
    
    def parse(self, text: str) -> Dict:
        """
        Parse Form 104 and extract all structured data
        
        Returns:
            Dictionary with header, sales, purchases, retentions, and totals
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
        """Extract sales (ventas) information"""
        ventas = {}
        
        # Extract from RESUMEN DE VENTAS section
        patterns = {
            "ventas_tarifa_diferente_cero_bruto": r"Ventas locales.*?tarifa diferente de cero\s+\d+\s+([\d\.,]+)",
            "ventas_tarifa_diferente_cero_neto": r"Ventas locales.*?tarifa diferente de cero\s+\d+\s+[\d\.,]+\s+\d+\s+([\d\.,]+)",
            "impuesto_generado": r"Ventas locales.*?tarifa diferente de cero\s+\d+\s+[\d\.,]+\s+\d+\s+[\d\.,]+\s+\d+\s+([\d\.,]+)",
            "total_ventas_bruto": r"TOTAL VENTAS Y OTRAS OPERACIONES\s+\d+\s+([\d\.,]+)",
            "total_ventas_neto": r"TOTAL VENTAS Y OTRAS OPERACIONES\s+\d+\s+[\d\.,]+\s+\d+\s+([\d\.,]+)",
            "total_impuesto_generado": r"TOTAL VENTAS Y OTRAS OPERACIONES\s+\d+\s+[\d\.,]+\s+\d+\s+[\d\.,]+\s+\d+\s+([\d\.,]+)"
        }
        
        for key, pattern in patterns.items():
            match = re.search(pattern, text, re.IGNORECASE | re.DOTALL)
            if match:
                value_str = match.group(1).replace(',', '')
                try:
                    ventas[key] = float(value_str)
                except ValueError:
                    ventas[key] = 0.0
        
        return ventas
    
    def _extract_compras(self, text: str) -> Dict:
        """Extract purchases (adquisiciones) information"""
        compras = {}
        
        patterns = {
            "adquisiciones_tarifa_diferente_cero_bruto": r"Adquisiciones y pagos.*?tarifa diferente de cero.*?con derecho\s+\d+\s+([\d\.,]+)",
            "adquisiciones_tarifa_diferente_cero_neto": r"Adquisiciones y pagos.*?tarifa diferente de cero.*?con derecho\s+\d+\s+[\d\.,]+\s+\d+\s+([\d\.,]+)",
            "impuesto_compras": r"Adquisiciones y pagos.*?tarifa diferente de cero.*?con derecho\s+\d+\s+[\d\.,]+\s+\d+\s+[\d\.,]+\s+\d+\s+([\d\.,]+)",
            "adquisiciones_tarifa_cero": r"Adquisiciones y pagos.*?tarifa 0%\s+\d+\s+([\d\.,]+)\s+\d+\s+([\d\.,]+)",
            "total_adquisiciones": r"TOTAL ADQUISICIONES Y PAGOS\s+\d+\s+([\d\.,]+)",
            "credito_tributario_aplicable": r"Crédito tributario aplicable en este período.*?\s+\d+\s+([\d\.,]+)"
        }
        
        for key, pattern in patterns.items():
            match = re.search(pattern, text, re.IGNORECASE | re.DOTALL)
            if match:
                value_str = match.group(1).replace(',', '')
                try:
                    compras[key] = float(value_str)
                except ValueError:
                    compras[key] = 0.0
        
        return compras
    
    def _extract_retenciones(self, text: str) -> List[Dict]:
        """Extract VAT retentions by percentage"""
        retenciones = []
        
        retention_patterns = {
            "10": r"Retención del 10%\s+\d+\s+([\d\.,]+)",
            "20": r"Retención del 20%\s+\d+\s+([\d\.,]+)",
            "30": r"Retención del 30%\s+\d+\s+([\d\.,]+)",
            "50": r"Retención del 50%\s+\d+\s+([\d\.,]+)",
            "70": r"Retención del 70%\s+\d+\s+([\d\.,]+)",
            "100": r"Retención del 100%\s+\d+\s+([\d\.,]+)"
        }
        
        for percentage, pattern in retention_patterns.items():
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                value_str = match.group(1).replace(',', '')
                try:
                    valor = float(value_str)
                    if valor > 0:
                        retenciones.append({
                            "porcentaje": int(percentage),
                            "valor": valor
                        })
                except ValueError:
                    continue
        
        return retenciones
    
    def _extract_totals(self, text: str) -> Dict:
        """Extract summary totals"""
        totals = {}
        
        patterns = {
            "impuesto_causado": r"Impuesto causado.*?\s+\d+\s+([\d\.,]+)",
            "retenciones_efectuadas": r"Retenciones en la fuente de IVA que le han sido efectuadas en este período\s+\d+\s+([\d\.,]+)",
            "subtotal_a_pagar": r"SUBTOTAL A PAGAR.*?\s+\d+\s+([\d\.,]+)",
            "total_impuesto_retenido": r"TOTAL IMPUESTO RETENIDO\s+[\d\s\+]+\s+\d+\s+([\d\.,]+)",
            "total_impuesto_pagar_retencion": r"TOTAL IMPUESTO A PAGAR POR RETENCIÓN.*?\s+\d+\s+([\d\.,]+)",
            "total_consolidado_iva": r"TOTAL CONSOLIDADO DE IMPUESTO AL VALOR AGREGADO\s+[\d\s\+]+\s+\d+\s+([\d\.,]+)",
            "total_pagado": r"TOTAL PAGADO\s+\d+\s+([\d\.,]+)"
        }
        
        for key, pattern in patterns.items():
            match = re.search(pattern, text, re.IGNORECASE | re.DOTALL)
            if match:
                value_str = match.group(1).replace(',', '')
                try:
                    totals[key] = float(value_str)
                except ValueError:
                    totals[key] = 0.0
        
        return totals


# Singleton instance
form_104_parser = Form104Parser()
