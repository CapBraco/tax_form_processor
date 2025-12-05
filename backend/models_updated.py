"""
Updated Database Models - Phase 1
Includes user_id relationships and new tables for guest sessions
"""

from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, Text, BigInteger
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from datetime import datetime

from app.core.database import Base

# =====================================================
# User Model (Updated with relationships)
# =====================================================

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    is_superuser = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    last_login = Column(DateTime(timezone=True), nullable=True)
    reset_token = Column(String, nullable=True)
    reset_token_expires = Column(DateTime(timezone=True), nullable=True)

    # ✅ NEW: Relationships
    documents = relationship("Document", back_populates="user", cascade="all, delete-orphan")
    form_103_items = relationship("Form103LineItem", back_populates="user", cascade="all, delete-orphan")
    form_104_items = relationship("Form104LineItem", back_populates="user", cascade="all, delete-orphan")
    analytics = relationship("UsageAnalytics", back_populates="user")

# =====================================================
# Document Model (Updated with user_id)
# =====================================================

class Document(Base):
    __tablename__ = "documents"

    id = Column(Integer, primary_key=True, index=True)
    filename = Column(String, nullable=False)
    file_path = Column(String, nullable=False)
    file_size = Column(Integer)
    upload_date = Column(DateTime(timezone=True), server_default=func.now())
    razon_social = Column(String, index=True)
    periodo_mes = Column(Integer)
    periodo_year = Column(Integer, index=True)
    periodo_fiscal = Column(String)
    tipo_formulario = Column(String, index=True)
    status = Column(String, default="pending")
    processing_time = Column(Integer)
    error_message = Column(Text, nullable=True)
    parsed_data = Column(JSONB, nullable=True)
    
    # ✅ NEW: User relationship
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=True, index=True)
    user = relationship("User", back_populates="documents")

# =====================================================
# Form 103 Line Item Model (Updated with user_id)
# =====================================================

class Form103LineItem(Base):
    __tablename__ = "form_103_line_items"

    id = Column(Integer, primary_key=True, index=True)
    document_id = Column(Integer, ForeignKey("documents.id", ondelete="CASCADE"), nullable=False)
    concepto = Column(String, nullable=False)
    codigo_base = Column(String)
    base_imponible = Column(Integer, default=0)
    codigo_retencion = Column(String)
    valor_retenido = Column(Integer, default=0)
    
    # ✅ NEW: User relationship
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=True, index=True)
    user = relationship("User", back_populates="form_103_items")

# =====================================================
# Form 104 Line Item Model (Updated with user_id)
# =====================================================

class Form104LineItem(Base):
    __tablename__ = "form_104_line_items"

    id = Column(Integer, primary_key=True, index=True)
    document_id = Column(Integer, ForeignKey("documents.id", ondelete="CASCADE"), nullable=False)
    codigo = Column(String, nullable=False)
    tipo_transaccion = Column(String)
    base_imponible = Column(Integer, default=0)
    porcentaje_iva = Column(Integer, default=0)
    impuesto_generado = Column(Integer, default=0)
    
    # ✅ NEW: User relationship
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=True, index=True)
    user = relationship("User", back_populates="form_104_items")

# =====================================================
# ✅ NEW: Guest Session Model
# =====================================================

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

# =====================================================
# ✅ NEW: Temporary File Model
# =====================================================

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

# =====================================================
# ✅ NEW: Usage Analytics Model
# =====================================================

class UsageAnalytics(Base):
    """Track usage events for analytics"""
    __tablename__ = "usage_analytics"

    id = Column(Integer, primary_key=True, index=True)
    event_type = Column(String(50), nullable=False, index=True)
    # Examples: 'guest_upload', 'user_upload', 'registration', 'login', 'export', etc.
    
    user_id = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True)
    session_id = Column(String(255), nullable=True)
    metadata = Column(JSONB, nullable=True)  # Store additional event data
    created_at = Column(DateTime(timezone=True), server_default=func.now(), index=True)

    # Relationship
    user = relationship("User", back_populates="analytics")

# =====================================================
# Form 103 Totals Model (Existing - no changes needed)
# =====================================================

class Form103Totals(Base):
    """Aggregated totals for Form 103"""
    __tablename__ = "form_103_totals"

    id = Column(Integer, primary_key=True, index=True)
    document_id = Column(Integer, ForeignKey("documents.id", ondelete="CASCADE"), unique=True, nullable=False)
    subtotal_operaciones = Column(Integer, default=0)
    total_retencion = Column(Integer, default=0)
    total_impuesto_pagar = Column(Integer, default=0)
    total_pagado = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

# =====================================================
# Form 104 Totals Model (Existing - no changes needed)
# =====================================================

class Form104Totals(Base):
    """Aggregated totals for Form 104"""
    __tablename__ = "form_104_totals"

    id = Column(Integer, primary_key=True, index=True)
    document_id = Column(Integer, ForeignKey("documents.id", ondelete="CASCADE"), unique=True, nullable=False)
    
    # Ventas (Sales)
    ventas_neto = Column(Integer, default=0)
    impuesto_generado = Column(Integer, default=0)
    
    # Compras (Purchases)
    adquisiciones_gravadas = Column(Integer, default=0)
    credito_tributario = Column(Integer, default=0)
    
    # Cálculos fiscales
    impuesto_causado = Column(Integer, default=0)
    retenciones_efectuadas = Column(Integer, default=0)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
