"""
Form 103 Parser - FINAL CORRECTED VERSION
✅ Extracts ALL codes:
- Code 349: Subtotal Operaciones País (base)
- Code 399: Subtotal Retención  
- Code 332: Pagos no sujetos a retención
- Code 3440: Otras retenciones - base (2.75%)
- Code 3940: Otras retenciones - retenido (2.75%)
- Code 903: Interés por mora
- Code 904: Multa
- Code 999: Total Pagado
"""

import re
from typing import Dict, List, Optional


class Form103Parser:
    """Parser for Ecuadorian Form 103 - Income Tax Withholdings"""
    
    def parse(self, text: str) -> Dict:
        """
        Parse Form 103 and extract ALL structured data
        
        Returns:
            Dictionary with header, line items, and totals
        """
        result = {
            "form_type": "form_103",
            "header": self._extract_header(text),
            "line_items": self._extract_line_items(text),
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
            "obligacion_tributaria": r"Obligación Tributaria:\s+(\d+\s*-\s*[A-ZÁÉÍÓÚÑ\s]+)",
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
    
    def _extract_line_items(self, text: str) -> List[Dict]:
        """Extract ALL line items with codes and values"""
        line_items = []
        
        # Pattern to match: "Description CODE1 VALUE1 CODE2 VALUE2"
        pattern = r'([A-Za-zÁÉÍÓÚáéíóúñÑ\s\(\)\-,/\.]+?)\s+(\d{3,4})\s+([\d\.,]+)\s+(\d{3,4})\s+([\d\.,]+)'
        
        for match in re.finditer(pattern, text):
            concepto = match.group(1).strip()
            
            # Skip headers and totals
            if any(skip in concepto.upper() for skip in [
                'BASE IMPONIBLE', 'VALOR RETENIDO', 'TOTAL', 'SUBTOTAL', 'CODIGO', 'CONCEPTO'
            ]):
                continue
            
            base_str = match.group(3).replace(',', '')
            valor_str = match.group(5).replace(',', '')
            
            try:
                base_imponible = float(base_str)
                valor_retenido = float(valor_str)
                
                line_items.append({
                    "concepto": concepto,
                    "codigo_base": match.group(2),
                    "base_imponible": base_imponible,
                    "codigo_retencion": match.group(4),
                    "valor_retenido": valor_retenido
                })
            except ValueError:
                continue
        
        # ✅ SPECIAL: Extract Code 332 (single value, no retention pair)
        code_332_pattern = r"Pagos de bienes y servicios no sujetos a retención.*?332\s+([\d\.,]+)"
        match_332 = re.search(code_332_pattern, text, re.IGNORECASE | re.DOTALL)
        if match_332:
            try:
                value_332 = float(match_332.group(1).replace(',', ''))
                line_items.append({
                    "concepto": "Pagos de bienes y servicios no sujetos a retención (Código 332)",
                    "codigo_base": "332",
                    "base_imponible": value_332,
                    "codigo_retencion": "N/A",
                    "valor_retenido": 0.0
                })
            except ValueError:
                pass
        
        return line_items
    
    def _extract_totals(self, text: str) -> Dict:
        """
        Extract summary totals from the form
        ✅ FINAL VERSION: Extracts codes 349, 399, 332, 3440, 3940, 903, 904, 999
        """
        totals = {}
        
        # ✅ Code 349/399: SUBTOTAL OPERACIONES EFECTUADAS EN EL PAÍS
        # Pattern: "SUBTOTAL OPERACIONES EFECTUADAS EN EL PAÍS  349  27710.90  399  374.18"
        subtotal_pattern = r"SUBTOTAL OPERACIONES EFECTUADAS EN EL PAÍS\s+349\s+([\d\.,]+)\s+399\s+([\d\.,]+)"
        match = re.search(subtotal_pattern, text, re.IGNORECASE)
        if match:
            totals["subtotal_operaciones_pais"] = float(match.group(1).replace(',', ''))
            totals["subtotal_retencion"] = float(match.group(2).replace(',', ''))
        else:
            totals["subtotal_operaciones_pais"] = 0.0
            totals["subtotal_retencion"] = 0.0
        
        # ✅ Code 332: Pagos no sujetos a retención (appears as single value)
        code_332_pattern = r"Pagos de bienes y servicios no sujetos a retención.*?332\s+([\d\.,]+)"
        match_332 = re.search(code_332_pattern, text, re.IGNORECASE | re.DOTALL)
        if match_332:
            totals["pagos_no_sujetos"] = float(match_332.group(1).replace(',', ''))
        else:
            totals["pagos_no_sujetos"] = 0.0
        
        # ✅ Code 3440/3940: Otras retenciones - Aplicables el 2,75%
        # Pattern: ". Aplicables el 2,75%  3440  153.40  3940  4.22"
        otras_ret_pattern = r"Aplicables\s+el\s+2,75%\s+3440\s+([\d\.,]+)\s+3940\s+([\d\.,]+)"
        match_otras = re.search(otras_ret_pattern, text, re.IGNORECASE)
        if match_otras:
            totals["otras_retenciones_base"] = float(match_otras.group(1).replace(',', ''))
            totals["otras_retenciones_retenido"] = float(match_otras.group(2).replace(',', ''))
        else:
            totals["otras_retenciones_base"] = 0.0
            totals["otras_retenciones_retenido"] = 0.0
        
        # Total retención (Code 499)
        total_ret_pattern = r"TOTAL DE RETENCIÓN DE IMPUESTO A LA RENTA.*?499\s+([\d\.,]+)"
        match = re.search(total_ret_pattern, text, re.IGNORECASE | re.DOTALL)
        if match:
            totals["total_retencion"] = float(match.group(1).replace(',', ''))
        else:
            totals["total_retencion"] = 0.0
        
        # Total impuesto a pagar (Code 902)
        total_imp_pattern = r"TOTAL IMPUESTO A PAGAR.*?902\s+([\d\.,]+)"
        match = re.search(total_imp_pattern, text, re.IGNORECASE | re.DOTALL)
        if match:
            totals["total_impuesto_pagar"] = float(match.group(1).replace(',', ''))
        else:
            totals["total_impuesto_pagar"] = 0.0
        
        # ✅ Code 903: Interés por mora
        interes_pattern = r"Interés\s+por\s+mora\s+903\s+([\d\.,]+)"
        match = re.search(interes_pattern, text, re.IGNORECASE)
        if match:
            totals["interes_mora"] = float(match.group(1).replace(',', ''))
        else:
            totals["interes_mora"] = 0.0
        
        # ✅ Code 904: Multa
        multa_pattern = r"Multa\s+904\s+([\d\.,]+)"
        match = re.search(multa_pattern, text, re.IGNORECASE)
        if match:
            totals["multa"] = float(match.group(1).replace(',', ''))
        else:
            totals["multa"] = 0.0
        
        # Total pagado (Code 999)
        total_pag_pattern = r"TOTAL PAGADO\s+999\s+([\d\.,]+)"
        match = re.search(total_pag_pattern, text, re.IGNORECASE)
        if match:
            totals["total_pagado"] = float(match.group(1).replace(',', ''))
        else:
            totals["total_pagado"] = 0.0
        
        return totals


# ✅ CRITICAL: Singleton instance export
form_103_parser = Form103Parser()