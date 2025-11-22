"""
Enhanced Database Models - COMPATIBLE with original project
Adds Clientes feature fields while maintaining existing structure
"""

from sqlalchemy import Column, Integer, String, DateTime, Text, Float, ForeignKey, JSON, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base
import enum


class ProcessingStatusEnum(str, enum.Enum):
    """Enum for processing status"""
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"


class FormTypeEnum(str, enum.Enum):
    """Enum for form types"""
    FORM_103 = "form_103"
    FORM_104 = "form_104"
    UNKNOWN = "unknown"


class Document(Base):
    """Document model - stores uploaded PDFs and extracted text"""
    __tablename__ = "documents"
    
    id = Column(Integer, primary_key=True, index=True)
    
    # File information
    filename = Column(String(255), nullable=False)
    original_filename = Column(String(255), nullable=False)
    file_path = Column(String(500), nullable=False)
    file_size = Column(Integer, nullable=False)
    
    # Form classification
    form_type = Column(Enum(FormTypeEnum), default=FormTypeEnum.UNKNOWN, index=True)
    
    # Extracted text
    extracted_text = Column(Text, nullable=True)
    total_pages = Column(Integer, nullable=True)
    total_characters = Column(Integer, nullable=True)
    
    # Structured data (JSON)
    parsed_data = Column(JSON, nullable=True)
    
    # Form header data (ORIGINAL FIELDS - keep these names!)
    codigo_verificador = Column(String(100), nullable=True, index=True)
    numero_serial = Column(String(100), nullable=True)
    fecha_recaudacion = Column(DateTime(timezone=True), nullable=True)
    identificacion_ruc = Column(String(50), nullable=True, index=True)
    razon_social = Column(String(500), nullable=True, index=True)  # Already exists! Just add index
    periodo_mes = Column(String(20), nullable=True, index=True)    # Already exists! Just add index
    periodo_anio = Column(String(10), nullable=True, index=True)   # Already exists! Keep index
    
    # NEW FIELDS FOR CLIENTES FEATURE - Add these columns
    periodo_fiscal_completo = Column(String(50), nullable=True)  # e.g., "ABRIL 2025"
    periodo_mes_numero = Column(Integer, nullable=True, index=True)  # 1-12 for sorting
    
    # Processing status
    processing_status = Column(Enum(ProcessingStatusEnum), default=ProcessingStatusEnum.PENDING, index=True)
    processing_error = Column(Text, nullable=True)
    
    # Timestamps (ORIGINAL FIELD NAMES - keep these!)
    uploaded_at = Column(DateTime(timezone=True), server_default=func.now())
    processed_at = Column(DateTime(timezone=True), nullable=True)
    
    # Relationships
    form_103_items = relationship("Form103LineItem", back_populates="document", cascade="all, delete-orphan")
    form_104_data = relationship("Form104Data", back_populates="document", cascade="all, delete-orphan", uselist=False)
    form_103_totals = relationship("Form103Totals", back_populates="document", cascade="all, delete-orphan", uselist=False)
    
    def __repr__(self):
        return f"<Document {self.form_type}: {self.original_filename}>"


class Form103LineItem(Base):
    """Form 103 Line Items - Individual retention entries"""
    __tablename__ = "form_103_line_items"
    
    id = Column(Integer, primary_key=True, index=True)
    document_id = Column(Integer, ForeignKey("documents.id", ondelete="CASCADE"), nullable=False, index=True)
    
    # Line item data
    concepto = Column(String(500), nullable=False)
    codigo_base = Column(String(10), nullable=False)
    base_imponible = Column(Float, nullable=False, default=0.0)
    codigo_retencion = Column(String(10), nullable=False)
    valor_retenido = Column(Float, nullable=False, default=0.0)
    
    # Ordering
    order_index = Column(Integer, nullable=False, default=0)
    
    # Relationship
    document = relationship("Document", back_populates="form_103_items")
    
    def __repr__(self):
        return f"<Form103LineItem: {self.concepto} - {self.valor_retenido}>"


class Form104Data(Base):
    """Form 104 Data - VAT declaration structured data"""
    __tablename__ = "form_104_data"
    
    id = Column(Integer, primary_key=True, index=True)
    document_id = Column(Integer, ForeignKey("documents.id", ondelete="CASCADE"), nullable=False, index=True)
    
    # Ventas (Sales)
    ventas_tarifa_diferente_cero_bruto = Column(Float, default=0.0)
    ventas_tarifa_diferente_cero_neto = Column(Float, default=0.0)
    impuesto_generado = Column(Float, default=0.0)
    total_ventas_bruto = Column(Float, default=0.0)
    total_ventas_neto = Column(Float, default=0.0)
    total_impuesto_generado = Column(Float, default=0.0)
    
    # Compras (Purchases)
    adquisiciones_tarifa_diferente_cero_bruto = Column(Float, default=0.0)
    adquisiciones_tarifa_diferente_cero_neto = Column(Float, default=0.0)
    impuesto_compras = Column(Float, default=0.0)
    adquisiciones_tarifa_cero = Column(Float, default=0.0)
    total_adquisiciones = Column(Float, default=0.0)
    credito_tributario_aplicable = Column(Float, default=0.0)
    
    # Retenciones IVA (VAT Retentions) - stored as JSON
    retenciones_iva = Column(JSON, nullable=True)  # List of {porcentaje: X, valor: Y}
    
    # Totals
    impuesto_causado = Column(Float, default=0.0)
    retenciones_efectuadas = Column(Float, default=0.0)
    subtotal_a_pagar = Column(Float, default=0.0)
    total_impuesto_retenido = Column(Float, default=0.0)
    total_impuesto_pagar_retencion = Column(Float, default=0.0)
    total_consolidado_iva = Column(Float, default=0.0)
    total_pagado = Column(Float, default=0.0)
    
    # Relationship
    document = relationship("Document", back_populates="form_104_data")
    
    def __repr__(self):
        return f"<Form104Data: Total Pagado {self.total_pagado}>"


# NEW TABLE for Form 103 Totals (for yearly accumulator)
class Form103Totals(Base):
    """Form 103 Totals - Summary values for yearly accumulator"""
    __tablename__ = "form_103_totals"
    
    id = Column(Integer, primary_key=True, index=True)
    document_id = Column(Integer, ForeignKey("documents.id", ondelete="CASCADE"), nullable=False, unique=True, index=True)
    
    # Totals extracted from Form 103
    subtotal_operaciones_pais = Column(Float, nullable=True, default=0.0)
    total_retencion = Column(Float, nullable=True, default=0.0)
    total_impuesto_pagar = Column(Float, nullable=True, default=0.0)
    total_pagado = Column(Float, nullable=True, default=0.0)
    
    # Relationship
    document = relationship("Document", back_populates="form_103_totals")
    
    def __repr__(self):
        return f"<Form103Totals: Doc {self.document_id} - Total {self.total_pagado}>"
