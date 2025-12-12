"""
Enhanced Database Models - FULLY FIXED
All relationships corrected - ready to use
"""

from sqlalchemy import Column, Integer, String, DateTime, Text, Float, ForeignKey, JSON, Enum, Boolean, BigInteger
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import JSONB
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
    razon_social = Column(String(500), nullable=True, index=True)
    periodo_mes = Column(String(20), nullable=True, index=True)
    periodo_anio = Column(String(10), nullable=True, index=True)
    
    # NEW FIELDS FOR CLIENTES FEATURE
    periodo_fiscal_completo = Column(String(50), nullable=True)
    periodo_mes_numero = Column(Integer, nullable=True, index=True)
    
    # Processing status
    processing_status = Column(Enum(ProcessingStatusEnum), default=ProcessingStatusEnum.PENDING, index=True)
    processing_error = Column(Text, nullable=True)
    
    # Timestamps
    uploaded_at = Column(DateTime(timezone=True), server_default=func.now())
    processed_at = Column(DateTime(timezone=True), nullable=True)
    
    # ✅ User relationship
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=True, index=True)
    user = relationship("User", back_populates="documents")
    session_id = Column(String, nullable=True, index=True)
    
    # Relationships to forms
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
    
    # ✅ User relationship - NO back_populates since User doesn't have form_103_items
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=True, index=True)
    
    # Relationship to document
    document = relationship("Document", back_populates="form_103_items")
    
    def __repr__(self):
        return f"<Form103LineItem: {self.concepto} - {self.valor_retenido}>"


class Form104Data(Base):
    """
    ✅ UPDATED: Form 104 Data - VAT declaration structured data (All 127 fields)
    """
    __tablename__ = "form_104_data"
    
    id = Column(Integer, primary_key=True, index=True)
    document_id = Column(Integer, ForeignKey("documents.id", ondelete="CASCADE"), nullable=False, unique=True, index=True)
    
    # ===================================
    # EXISTING FIELDS (KEPT FOR BACKWARD COMPATIBILITY)
    # ===================================
    
    # Ventas (Sales)
    ventas_tarifa_diferente_cero_bruto = Column(Float, default=0.0) # Code 401: Mapped to ventas_locales_bruto in parser
    ventas_tarifa_diferente_cero_neto = Column(Float, default=0.0) # Code 411: Mapped to ventas_locales_neto in parser
    impuesto_generado = Column(Float, default=0.0) # Code 421: Mapped to impuesto_generado_ventas_locales in parser
    total_ventas_bruto = Column(Float, default=0.0) # Code 409
    total_ventas_neto = Column(Float, default=0.0) # Code 419
    total_impuesto_generado = Column(Float, default=0.0) # Code 429
    
    # Compras (Purchases)
    adquisiciones_tarifa_diferente_cero_bruto = Column(Float, default=0.0) # Code 500: Mapped to adquisiciones_diferente_0_con_derecho_bruto in parser
    adquisiciones_tarifa_diferente_cero_neto = Column(Float, default=0.0) # Code 510: Mapped to adquisiciones_diferente_0_con_derecho_neto in parser
    impuesto_compras = Column(Float, default=0.0) # Code 520: Mapped to impuesto_adquisiciones_diferente_0 in parser
    adquisiciones_tarifa_cero = Column(Float, default=0.0) # (No direct single code, often derived/summary)
    total_adquisiciones = Column(Float, default=0.0) # Code 509: Mapped to total_adquisiciones_bruto in parser
    credito_tributario_aplicable = Column(Float, default=0.0) # Code 564
    
    # Totals
    impuesto_causado = Column(Float, default=0.0) # Code 601
    retenciones_efectuadas = Column(Float, default=0.0) # Code 609
    subtotal_a_pagar = Column(Float, default=0.0) # Code 620
    total_impuesto_retenido = Column(Float, default=0.0) # Code 799
    total_impuesto_pagar_retencion = Column(Float, default=0.0) # Code 801
    total_consolidado_iva = Column(Float, default=0.0) # Code 859
    total_pagado = Column(Float, default=0.0) # Code 999
    
    # Retenciones IVA (VAT Retentions) - stored as JSON
    retenciones_iva = Column(JSON, nullable=True)

    # ===================================
    # NEW FIELDS FROM MIGRATION (100+ added)
    # ===================================
    
    # VENTAS SECTION
    ventas_activos_fijos_bruto = Column(Float, default=0.0) # 402
    ventas_activos_fijos_neto = Column(Float, default=0.0) # 412
    impuesto_generado_activos_fijos = Column(Float, default=0.0) # 422
    ventas_tarifa_5_bruto = Column(Float, default=0.0) # 425
    ventas_tarifa_5_neto = Column(Float, default=0.0) # 435
    impuesto_generado_tarifa_5 = Column(Float, default=0.0) # 445
    iva_ajuste_pagar = Column(Float, default=0.0) # 423
    iva_ajuste_favor = Column(Float, default=0.0) # 424
    ventas_0_sin_derecho_bruto = Column(Float, default=0.0) # 403
    ventas_0_sin_derecho_neto = Column(Float, default=0.0) # 413
    activos_fijos_0_sin_derecho_bruto = Column(Float, default=0.0) # 404
    activos_fijos_0_sin_derecho_neto = Column(Float, default=0.0) # 414
    ventas_0_con_derecho_bruto = Column(Float, default=0.0) # 405
    ventas_0_con_derecho_neto = Column(Float, default=0.0) # 415
    activos_fijos_0_con_derecho_bruto = Column(Float, default=0.0) # 406
    activos_fijos_0_con_derecho_neto = Column(Float, default=0.0) # 416
    exportaciones_bienes_bruto = Column(Float, default=0.0) # 407
    exportaciones_bienes_neto = Column(Float, default=0.0) # 417
    exportaciones_servicios_bruto = Column(Float, default=0.0) # 408
    exportaciones_servicios_neto = Column(Float, default=0.0) # 418
    transferencias_no_objeto_bruto = Column(Float, default=0.0) # 431
    transferencias_no_objeto_neto = Column(Float, default=0.0) # 441
    notas_credito_0_compensar = Column(Float, default=0.0) # 442 (Ventas)
    notas_credito_diferente_0_bruto = Column(Float, default=0.0) # 443
    notas_credito_diferente_0_impuesto = Column(Float, default=0.0) # 453
    ingresos_reembolso_bruto = Column(Float, default=0.0) # 434
    ingresos_reembolso_neto = Column(Float, default=0.0) # 444
    ingresos_reembolso_impuesto = Column(Float, default=0.0) # 454
    
    # LIQUIDACIÓN SECTION
    transferencias_contado_mes = Column(Float, default=0.0) # 480
    transferencias_credito_mes = Column(Float, default=0.0) # 481
    impuesto_liquidar_mes_anterior = Column(Float, default=0.0) # 483
    impuesto_liquidar_este_mes = Column(Float, default=0.0) # 484
    impuesto_liquidar_proximo_mes = Column(Float, default=0.0) # 485
    mes_pagar_iva_credito = Column(Integer, default=0) # 486
    tamano_copci = Column(String(50), default='No aplica') # 487
    total_impuesto_liquidar_mes = Column(Float, default=0.0) # 499
    
    # COMPRAS SECTION
    activos_fijos_diferente_0_bruto = Column(Float, default=0.0) # 501
    activos_fijos_diferente_0_neto = Column(Float, default=0.0) # 511
    impuesto_activos_fijos_diferente_0 = Column(Float, default=0.0) # 521
    adquisiciones_tarifa_5_bruto = Column(Float, default=0.0) # 540
    adquisiciones_tarifa_5_neto = Column(Float, default=0.0) # 550
    impuesto_adquisiciones_tarifa_5 = Column(Float, default=0.0) # 560
    adquisiciones_sin_derecho_bruto = Column(Float, default=0.0) # 502
    adquisiciones_sin_derecho_neto = Column(Float, default=0.0) # 512
    impuesto_adquisiciones_sin_derecho = Column(Float, default=0.0) # 522
    importaciones_servicios_bruto = Column(Float, default=0.0) # 503
    importaciones_servicios_neto = Column(Float, default=0.0) # 513
    impuesto_importaciones_servicios = Column(Float, default=0.0) # 523
    importaciones_bienes_bruto = Column(Float, default=0.0) # 504
    importaciones_bienes_neto = Column(Float, default=0.0) # 514
    impuesto_importaciones_bienes = Column(Float, default=0.0) # 524
    importaciones_activos_fijos_bruto = Column(Float, default=0.0) # 505
    importaciones_activos_fijos_neto = Column(Float, default=0.0) # 515
    impuesto_importaciones_activos_fijos = Column(Float, default=0.0) # 525
    importaciones_0_bruto = Column(Float, default=0.0) # 506
    importaciones_0_neto = Column(Float, default=0.0) # 516
    adquisiciones_0_bruto = Column(Float, default=0.0) # 507
    adquisiciones_0_neto = Column(Float, default=0.0) # 517
    adquisiciones_rise_bruto = Column(Float, default=0.0) # 508
    adquisiciones_rise_neto = Column(Float, default=0.0) # 518
    total_adquisiciones_neto = Column(Float, default=0.0) # 519
    total_impuesto_adquisiciones = Column(Float, default=0.0) # 529
    adquisiciones_no_objeto_bruto = Column(Float, default=0.0) # 531
    adquisiciones_no_objeto_neto = Column(Float, default=0.0) # 541
    adquisiciones_exentas_bruto = Column(Float, default=0.0) # 532
    adquisiciones_exentas_neto = Column(Float, default=0.0) # 542
    notas_credito_compras_0_compensar = Column(Float, default=0.0) # 543 (Compras)
    notas_credito_compras_diferente_0_bruto = Column(Float, default=0.0) # 544
    notas_credito_compras_diferente_0_impuesto = Column(Float, default=0.0) # 554
    pagos_reembolso_bruto = Column(Float, default=0.0) # 535
    pagos_reembolso_neto = Column(Float, default=0.0) # 545
    pagos_reembolso_impuesto = Column(Float, default=0.0) # 555
    factor_proporcionalidad = Column(Float, default=0.0) # 563
    iva_no_considerado_credito = Column(Float, default=0.0) # 565
    ajuste_positivo_credito = Column(Float, default=0.0) # 526
    ajuste_negativo_credito = Column(Float, default=0.0) # 527
    
    # EXPORTACIONES SECTION (ISD related)
    importaciones_materias_primas_valor = Column(Float, default=0.0) # 700
    importaciones_materias_primas_isd_pagado = Column(Float, default=0.0) # 701
    proporcion_ingreso_neto_divisas = Column(Float, default=0.0) # 702
    
    # TOTALS SECTION (Additional)
    compensacion_iva_medio_electronico = Column(Float, default=0.0) # 603
    saldo_credito_anterior_adquisiciones = Column(Float, default=0.0) # 605
    saldo_credito_anterior_retenciones = Column(Float, default=0.0) # 606
    saldo_credito_anterior_electronico = Column(Float, default=0.0) # 607 (Renamed for clarity/simplicity)
    saldo_credito_anterior_zonas_afectadas = Column(Float, default=0.0) # 608
    iva_devuelto_adultos_mayores = Column(Float, default=0.0) # 622
    ajuste_iva_devuelto_electronico = Column(Float, default=0.0) # 610
    ajuste_iva_devuelto_adquisiciones = Column(Float, default=0.0) # 612
    ajuste_iva_devuelto_retenciones = Column(Float, default=0.0) # 613
    ajuste_iva_otras_instituciones = Column(Float, default=0.0) # 614
    saldo_credito_proximo_adquisiciones = Column(Float, default=0.0) # 615
    saldo_credito_proximo_retenciones = Column(Float, default=0.0) # 617
    saldo_credito_proximo_electronico = Column(Float, default=0.0) # 618 (Renamed for clarity/simplicity)
    saldo_credito_proximo_zonas_afectadas = Column(Float, default=0.0) # 619
    iva_pagado_no_compensado = Column(Float, default=0.0) # 624
    ajuste_credito_superior_5_anos = Column(Float, default=0.0) # 625
    devolucion_provisional_iva = Column(Float, default=0.0) # (No direct code provided, but often needed)
    total_impuesto_a_pagar = Column(Float, default=0.0) # 902
    interes_mora = Column(Float, default=0.0) # 903
    multa = Column(Float, default=0.0) # 904
    
    # Relationship to document
    document = relationship("Document", back_populates="form_104_data")
    
    def __repr__(self):
        return f"<Form104Data: Total Pagado {self.total_pagado}>"


class Form103Totals(Base):
    """
    ✅ COMPLETE Form 103 Totals - ALL 10 fields
    Summary values extracted from Form 103 tax declarations
    """
    __tablename__ = "form_103_totals"
    
    id = Column(Integer, primary_key=True, index=True)
    document_id = Column(Integer, ForeignKey("documents.id", ondelete="CASCADE"), nullable=False, unique=True, index=True)
    
    # ✅ ALL 10 TOTALS FIELDS
    subtotal_operaciones_pais = Column(Float, nullable=True, default=0.0)
    subtotal_retencion = Column(Float, nullable=True, default=0.0)
    pagos_no_sujetos = Column(Float, nullable=True, default=0.0)
    otras_retenciones_base = Column(Float, nullable=True, default=0.0)
    otras_retenciones_retenido = Column(Float, nullable=True, default=0.0)
    total_retencion = Column(Float, nullable=True, default=0.0)
    total_impuesto_pagar = Column(Float, nullable=True, default=0.0)
    interes_mora = Column(Float, nullable=True, default=0.0)
    multa = Column(Float, nullable=True, default=0.0)
    total_pagado = Column(Float, nullable=True, default=0.0)
    
    # Relationship
    document = relationship("Document", back_populates="form_103_totals")
    
    def __repr__(self):
        return f"<Form103Totals: Doc {self.document_id} - Total {self.total_pagado}>"


# ===================================
# User Model
# ===================================

class User(Base):
    """User model for authentication"""
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(100), unique=True, nullable=False, index=True)
    email = Column(String(255), unique=True, nullable=False, index=True)
    hashed_password = Column(String(255), nullable=False)
    is_active = Column(Boolean, default=True)
    is_superuser = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    last_login = Column(DateTime(timezone=True), nullable=True)
    google_id = Column(String, unique=True, nullable=True, index=True)

    # Password reset fields
    reset_token = Column(String(500), nullable=True)
    reset_token_expires = Column(DateTime(timezone=True), nullable=True)
    
    # ✅ ONLY these relationships (documents and analytics)
    documents = relationship("Document", back_populates="user", cascade="all, delete-orphan")
    analytics = relationship("UsageAnalytics", back_populates="user")

    def __repr__(self):
        return f"<User {self.username}>"


# ===================================
# Guest Session Model
# ===================================

class GuestSession(Base):
    """Track guest user sessions and document upload limits"""
    __tablename__ = "guest_sessions"

    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(String(255), unique=True, nullable=False, index=True)
    document_count = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    last_activity = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    ip_address = Column(String(45), nullable=True)
    user_agent = Column(Text, nullable=True)

    # Relationship to temporary files
    temporary_files = relationship("TemporaryFile", back_populates="guest_session", cascade="all, delete-orphan")


# ===================================
# Temporary File Model
# ===================================

class TemporaryFile(Base):
    """Track temporary files for guest users"""
    __tablename__ = "temporary_files"

    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(String(255), ForeignKey("guest_sessions.session_id", ondelete="CASCADE"), nullable=False, index=True)
    file_path = Column(String(500), nullable=False)
    file_size = Column(BigInteger, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    expires_at = Column(DateTime(timezone=True), nullable=False)

    # Relationship
    guest_session = relationship("GuestSession", back_populates="temporary_files")


# ===================================
# Usage Analytics Model
# ===================================

class UsageAnalytics(Base):
    """Track usage events for analytics"""
    __tablename__ = "usage_analytics"

    id = Column(Integer, primary_key=True, index=True)
    event_type = Column(String(50), nullable=False, index=True)
    
    user_id = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True)
    session_id = Column(String(255), nullable=True)
    event_data = Column(JSONB, nullable=True)  # ✅ FIXED: was 'metadata'
    created_at = Column(DateTime(timezone=True), server_default=func.now(), index=True)

    # Relationship
    user = relationship("User", back_populates="analytics")