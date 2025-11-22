"""
Simplified PDF Processing Service
Just extracts all text from PDFs using pdfplumber
"""

import pdfplumber
import os
from typing import Dict
import logging

logger = logging.getLogger(__name__)


class PDFProcessingService:
    """Simple service for extracting text from PDFs"""
    
    async def extract_all_text(self, pdf_path: str) -> Dict:
        """
        Extract all text from PDF
        
        Args:
            pdf_path: Path to the PDF file
            
        Returns:
            Dictionary with extracted text and metadata
        """
        try:
            text_parts = []
            total_pages = 0
            
            with pdfplumber.open(pdf_path) as pdf:
                total_pages = len(pdf.pages)
                
                for page_num, page in enumerate(pdf.pages, 1):
                    page_text = page.extract_text()
                    if page_text:
                        text_parts.append(f"=== Page {page_num} ===\n{page_text}\n")
            
            full_text = "\n".join(text_parts)
            
            logger.info(f"Successfully extracted text from {pdf_path}")
            
            return {
                "success": True,
                "full_text": full_text,
                "total_pages": total_pages,
                "total_characters": len(full_text),
                "file_size": os.path.getsize(pdf_path)
            }
            
        except Exception as e:
            logger.error(f"Error extracting text from {pdf_path}: {e}")
            return {
                "success": False,
                "error": str(e),
                "full_text": "",
                "total_pages": 0,
                "total_characters": 0
            }


# Create singleton instance
pdf_service = PDFProcessingService()
