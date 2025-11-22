"""
Form 103 (Retenciones) Parser Service
Extracts structured data from Ecuadorian Form 103 tax declarations
"""

import re
from typing import Dict, List, Optional
from datetime import datetime


class Form103Parser:
    """Parser for Ecuadorian Form 103 - Income Tax Withholdings"""
    
    def parse(self, text: str) -> Dict:
        """
        Parse Form 103 and extract all structured data
        
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
        """
        Extract all line items with codes, base imponible, and valor retenido
        
        Returns list of dictionaries with:
        - codigo: Field code (302, 303, etc.)
        - concepto: Description of the concept
        - base_imponible: Taxable base
        - codigo_retencion: Retention code
        - valor_retenido: Amount withheld
        """
        line_items = []
        
        # Pattern to match lines with concept, codes and values
        # Matches: Concept text | code | base_value | code | retention_value
        pattern = r'([A-Za-zÁÉÍÓÚáéíóúñÑ\s\(\)\-,/\.]+?)\s+(\d{3,4})\s+([\d\.,]+)\s+(\d{3,4})\s+([\d\.,]+)'
        
        for match in re.finditer(pattern, text):
            concepto = match.group(1).strip()
            
            # Skip if it's a header or total line
            if any(skip in concepto.upper() for skip in ['BASE IMPONIBLE', 'VALOR RETENIDO', 'TOTAL', 'SUBTOTAL']):
                continue
            
            # Clean up numeric values
            base_str = match.group(3).replace(',', '')
            valor_str = match.group(5).replace(',', '')
            
            try:
                base_imponible = float(base_str)
                valor_retenido = float(valor_str)
                
                # Only include if there's actual value
                if base_imponible > 0 or valor_retenido > 0:
                    line_items.append({
                        "concepto": concepto,
                        "codigo_base": match.group(2),
                        "base_imponible": base_imponible,
                        "codigo_retencion": match.group(4),
                        "valor_retenido": valor_retenido
                    })
            except ValueError:
                continue
        
        return line_items
    
    def _extract_totals(self, text: str) -> Dict:
        """Extract summary totals from the form"""
        totals = {}
        
        patterns = {
            "subtotal_operaciones": r"SUBTOTAL OPERACIONES EFECTUADAS EN EL PAÍS\s+\d+\s+([\d\.,]+)\s+\d+\s+([\d\.,]+)",
            "total_retencion": r"TOTAL DE RETENCIÓN DE IMPUESTO A LA RENTA\s+[\d\s\+]+\s+\d+\s+([\d\.,]+)",
            "total_impuesto_pagar": r"TOTAL IMPUESTO A PAGAR\s+[\d\s\-]+\s+\d+\s+([\d\.,]+)",
            "intereses": r"Interés por mora\s+\d+\s+([\d\.,]+)",
            "multa": r"Multa\s+\d+\s+([\d\.,]+)",
            "total_pagado": r"TOTAL PAGADO\s+\d+\s+([\d\.,]+)"
        }
        
        for key, pattern in patterns.items():
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                # Get the last captured group (the amount)
                value_str = match.group(match.lastindex).replace(',', '')
                try:
                    totals[key] = float(value_str)
                except ValueError:
                    totals[key] = 0.0
        
        return totals


# Singleton instance
form_103_parser = Form103Parser()
