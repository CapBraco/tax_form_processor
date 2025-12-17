--
-- PostgreSQL database dump
--

\restrict PzxXwp9szPc2CQQEpw4gDqHjdJQSTSs5QfE5g4Vfm7tSKG3DPDFab944GfcAjxq

-- Dumped from database version 15.14
-- Dumped by pg_dump version 18.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: formtypeenum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.formtypeenum AS ENUM (
    'FORM_103',
    'FORM_104',
    'UNKNOWN'
);


ALTER TYPE public.formtypeenum OWNER TO postgres;

--
-- Name: processingstatusenum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.processingstatusenum AS ENUM (
    'PENDING',
    'PROCESSING',
    'COMPLETED',
    'FAILED'
);


ALTER TYPE public.processingstatusenum OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: documents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.documents (
    id integer NOT NULL,
    filename character varying(255) NOT NULL,
    original_filename character varying(255) NOT NULL,
    file_path character varying(500) NOT NULL,
    file_size integer NOT NULL,
    form_type public.formtypeenum,
    extracted_text text,
    total_pages integer,
    total_characters integer,
    parsed_data json,
    codigo_verificador character varying(100),
    numero_serial character varying(100),
    fecha_recaudacion timestamp with time zone,
    identificacion_ruc character varying(50),
    razon_social character varying(500),
    periodo_mes character varying(20),
    periodo_anio character varying(10),
    processing_status public.processingstatusenum,
    processing_error text,
    uploaded_at timestamp with time zone DEFAULT now(),
    processed_at timestamp with time zone,
    periodo_fiscal_completo character varying(50),
    periodo_mes_numero integer,
    user_id integer,
    session_id character varying
);


ALTER TABLE public.documents OWNER TO postgres;

--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.documents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.documents_id_seq OWNER TO postgres;

--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.documents_id_seq OWNED BY public.documents.id;


--
-- Name: form_103_line_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.form_103_line_items (
    id integer NOT NULL,
    document_id integer NOT NULL,
    concepto character varying(500) NOT NULL,
    codigo_base character varying(10) NOT NULL,
    base_imponible double precision NOT NULL,
    codigo_retencion character varying(10) NOT NULL,
    valor_retenido double precision NOT NULL,
    order_index integer NOT NULL,
    user_id integer
);


ALTER TABLE public.form_103_line_items OWNER TO postgres;

--
-- Name: form_103_line_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.form_103_line_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.form_103_line_items_id_seq OWNER TO postgres;

--
-- Name: form_103_line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.form_103_line_items_id_seq OWNED BY public.form_103_line_items.id;


--
-- Name: form_103_totals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.form_103_totals (
    id integer NOT NULL,
    document_id integer NOT NULL,
    subtotal_operaciones_pais double precision,
    total_retencion double precision,
    total_impuesto_pagar double precision,
    total_pagado double precision,
    subtotal_retencion double precision DEFAULT 0.0,
    interes_mora double precision DEFAULT 0.0,
    multa double precision DEFAULT 0.0,
    pagos_no_sujetos double precision DEFAULT 0.0,
    otras_retenciones_base double precision DEFAULT 0.0,
    otras_retenciones_retenido double precision DEFAULT 0.0
);


ALTER TABLE public.form_103_totals OWNER TO postgres;

--
-- Name: form_103_totals_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.form_103_totals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.form_103_totals_id_seq OWNER TO postgres;

--
-- Name: form_103_totals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.form_103_totals_id_seq OWNED BY public.form_103_totals.id;


--
-- Name: form_104_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.form_104_data (
    id integer NOT NULL,
    document_id integer NOT NULL,
    ventas_tarifa_diferente_cero_bruto double precision,
    ventas_tarifa_diferente_cero_neto double precision,
    impuesto_generado double precision,
    total_ventas_bruto double precision,
    total_ventas_neto double precision,
    total_impuesto_generado double precision,
    adquisiciones_tarifa_diferente_cero_bruto double precision,
    adquisiciones_tarifa_diferente_cero_neto double precision,
    impuesto_compras double precision,
    adquisiciones_tarifa_cero double precision,
    total_adquisiciones double precision,
    credito_tributario_aplicable double precision,
    retenciones_iva json,
    impuesto_causado double precision,
    retenciones_efectuadas double precision,
    subtotal_a_pagar double precision,
    total_impuesto_retenido double precision,
    total_impuesto_pagar_retencion double precision,
    total_consolidado_iva double precision,
    total_pagado double precision,
    total_impuesto_pagar_percepcion double precision DEFAULT 0.0,
    total_impuesto_a_pagar double precision DEFAULT 0.0,
    interes_mora double precision DEFAULT 0.0,
    multa double precision DEFAULT 0.0,
    user_id integer,
    ventas_activos_fijos_bruto double precision DEFAULT 0.0,
    ventas_activos_fijos_neto double precision DEFAULT 0.0,
    impuesto_generado_activos_fijos double precision DEFAULT 0.0,
    ventas_tarifa_5_bruto double precision DEFAULT 0.0,
    ventas_tarifa_5_neto double precision DEFAULT 0.0,
    impuesto_generado_tarifa_5 double precision DEFAULT 0.0,
    iva_ajuste_pagar double precision DEFAULT 0.0,
    iva_ajuste_favor double precision DEFAULT 0.0,
    ventas_0_sin_derecho_bruto double precision DEFAULT 0.0,
    ventas_0_sin_derecho_neto double precision DEFAULT 0.0,
    activos_fijos_0_sin_derecho_bruto double precision DEFAULT 0.0,
    activos_fijos_0_sin_derecho_neto double precision DEFAULT 0.0,
    ventas_0_con_derecho_bruto double precision DEFAULT 0.0,
    ventas_0_con_derecho_neto double precision DEFAULT 0.0,
    activos_fijos_0_con_derecho_bruto double precision DEFAULT 0.0,
    activos_fijos_0_con_derecho_neto double precision DEFAULT 0.0,
    exportaciones_bienes_bruto double precision DEFAULT 0.0,
    exportaciones_bienes_neto double precision DEFAULT 0.0,
    exportaciones_servicios_bruto double precision DEFAULT 0.0,
    exportaciones_servicios_neto double precision DEFAULT 0.0,
    transferencias_no_objeto_bruto double precision DEFAULT 0.0,
    transferencias_no_objeto_neto double precision DEFAULT 0.0,
    notas_credito_0_compensar double precision DEFAULT 0.0,
    notas_credito_diferente_0_bruto double precision DEFAULT 0.0,
    notas_credito_diferente_0_impuesto double precision DEFAULT 0.0,
    ingresos_reembolso_bruto double precision DEFAULT 0.0,
    ingresos_reembolso_neto double precision DEFAULT 0.0,
    ingresos_reembolso_impuesto double precision DEFAULT 0.0,
    transferencias_contado_mes double precision DEFAULT 0.0,
    transferencias_credito_mes double precision DEFAULT 0.0,
    impuesto_liquidar_mes_anterior double precision DEFAULT 0.0,
    impuesto_liquidar_este_mes double precision DEFAULT 0.0,
    impuesto_liquidar_proximo_mes double precision DEFAULT 0.0,
    mes_pagar_iva_credito integer DEFAULT 0,
    tamano_copci character varying(50) DEFAULT 'No aplica'::character varying,
    total_impuesto_liquidar_mes double precision DEFAULT 0.0,
    activos_fijos_diferente_0_bruto double precision DEFAULT 0.0,
    activos_fijos_diferente_0_neto double precision DEFAULT 0.0,
    impuesto_activos_fijos_diferente_0 double precision DEFAULT 0.0,
    adquisiciones_tarifa_5_bruto double precision DEFAULT 0.0,
    adquisiciones_tarifa_5_neto double precision DEFAULT 0.0,
    impuesto_adquisiciones_tarifa_5 double precision DEFAULT 0.0,
    adquisiciones_sin_derecho_bruto double precision DEFAULT 0.0,
    adquisiciones_sin_derecho_neto double precision DEFAULT 0.0,
    impuesto_adquisiciones_sin_derecho double precision DEFAULT 0.0,
    importaciones_servicios_bruto double precision DEFAULT 0.0,
    importaciones_servicios_neto double precision DEFAULT 0.0,
    impuesto_importaciones_servicios double precision DEFAULT 0.0,
    importaciones_bienes_bruto double precision DEFAULT 0.0,
    importaciones_bienes_neto double precision DEFAULT 0.0,
    impuesto_importaciones_bienes double precision DEFAULT 0.0,
    importaciones_activos_fijos_bruto double precision DEFAULT 0.0,
    importaciones_activos_fijos_neto double precision DEFAULT 0.0,
    impuesto_importaciones_activos_fijos double precision DEFAULT 0.0,
    importaciones_0_bruto double precision DEFAULT 0.0,
    importaciones_0_neto double precision DEFAULT 0.0,
    adquisiciones_0_bruto double precision DEFAULT 0.0,
    adquisiciones_0_neto double precision DEFAULT 0.0,
    adquisiciones_rise_bruto double precision DEFAULT 0.0,
    adquisiciones_rise_neto double precision DEFAULT 0.0,
    total_adquisiciones_neto double precision DEFAULT 0.0,
    total_impuesto_adquisiciones double precision DEFAULT 0.0,
    adquisiciones_no_objeto_bruto double precision DEFAULT 0.0,
    adquisiciones_no_objeto_neto double precision DEFAULT 0.0,
    adquisiciones_exentas_bruto double precision DEFAULT 0.0,
    adquisiciones_exentas_neto double precision DEFAULT 0.0,
    notas_credito_compras_0_compensar double precision DEFAULT 0.0,
    notas_credito_compras_diferente_0_bruto double precision DEFAULT 0.0,
    notas_credito_compras_diferente_0_impuesto double precision DEFAULT 0.0,
    pagos_reembolso_bruto double precision DEFAULT 0.0,
    pagos_reembolso_neto double precision DEFAULT 0.0,
    pagos_reembolso_impuesto double precision DEFAULT 0.0,
    factor_proporcionalidad double precision DEFAULT 0.0,
    iva_no_considerado_credito double precision DEFAULT 0.0,
    ajuste_positivo_credito double precision DEFAULT 0.0,
    ajuste_negativo_credito double precision DEFAULT 0.0,
    importaciones_materias_primas_valor double precision DEFAULT 0.0,
    importaciones_materias_primas_isd_pagado double precision DEFAULT 0.0,
    proporcion_ingreso_neto_divisas double precision DEFAULT 0.0,
    compensacion_iva_medio_electronico double precision DEFAULT 0.0,
    saldo_credito_anterior_adquisiciones double precision DEFAULT 0.0,
    saldo_credito_anterior_retenciones double precision DEFAULT 0.0,
    saldo_credito_anterior_electronico double precision DEFAULT 0.0,
    saldo_credito_anterior_zonas_afectadas double precision DEFAULT 0.0,
    iva_devuelto_adultos_mayores double precision DEFAULT 0.0,
    ajuste_iva_devuelto_electronico double precision DEFAULT 0.0,
    ajuste_iva_devuelto_adquisiciones double precision DEFAULT 0.0,
    ajuste_iva_devuelto_retenciones double precision DEFAULT 0.0,
    ajuste_iva_otras_instituciones double precision DEFAULT 0.0,
    saldo_credito_proximo_adquisiciones double precision DEFAULT 0.0,
    saldo_credito_proximo_retenciones double precision DEFAULT 0.0,
    saldo_credito_proximo_electronico double precision DEFAULT 0.0,
    saldo_credito_proximo_zonas_afectadas double precision DEFAULT 0.0,
    iva_pagado_no_compensado double precision DEFAULT 0.0,
    ajuste_credito_superior_5_anos double precision DEFAULT 0.0,
    devolucion_provisional_iva double precision DEFAULT 0.0,
    field_887 double precision DEFAULT 0.0,
    saldo_credito_anterior_compensacion_electronico double precision DEFAULT 0.0,
    saldo_credito_proximo_compensacion_electronico double precision DEFAULT 0.0,
    ajuste_reduccion_impuesto_tarifa_5 double precision DEFAULT 0.0,
    ajuste_reduccion_impuesto_iva_diferencial double precision DEFAULT 0.0,
    ajuste_credito_compensacion_zonas_afectadas double precision DEFAULT 0.0,
    saldo_credito_anterior_iva_medio_electronico double precision DEFAULT 0.0,
    saldo_credito_proximo_iva_electronico double precision DEFAULT 0.0
);


ALTER TABLE public.form_104_data OWNER TO postgres;

--
-- Name: form_104_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.form_104_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.form_104_data_id_seq OWNER TO postgres;

--
-- Name: form_104_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.form_104_data_id_seq OWNED BY public.form_104_data.id;


--
-- Name: guest_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.guest_sessions (
    id integer NOT NULL,
    session_id character varying(255) NOT NULL,
    document_count integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT now(),
    last_activity timestamp without time zone DEFAULT now(),
    ip_address character varying(45),
    user_agent text
);


ALTER TABLE public.guest_sessions OWNER TO postgres;

--
-- Name: guest_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.guest_sessions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.guest_sessions_id_seq OWNER TO postgres;

--
-- Name: guest_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.guest_sessions_id_seq OWNED BY public.guest_sessions.id;


--
-- Name: temporary_files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.temporary_files (
    id integer NOT NULL,
    session_id character varying(255) NOT NULL,
    file_path character varying(500) NOT NULL,
    file_size bigint,
    created_at timestamp without time zone DEFAULT now(),
    expires_at timestamp without time zone NOT NULL
);


ALTER TABLE public.temporary_files OWNER TO postgres;

--
-- Name: temporary_files_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.temporary_files_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.temporary_files_id_seq OWNER TO postgres;

--
-- Name: temporary_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.temporary_files_id_seq OWNED BY public.temporary_files.id;


--
-- Name: usage_analytics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usage_analytics (
    id integer NOT NULL,
    event_type character varying(50) NOT NULL,
    user_id integer,
    session_id character varying(255),
    event_data jsonb,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.usage_analytics OWNER TO postgres;

--
-- Name: usage_analytics_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usage_analytics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usage_analytics_id_seq OWNER TO postgres;

--
-- Name: usage_analytics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usage_analytics_id_seq OWNED BY public.usage_analytics.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(100) NOT NULL,
    email character varying(255) NOT NULL,
    hashed_password character varying(255) NOT NULL,
    is_active boolean,
    is_superuser boolean,
    created_at timestamp with time zone DEFAULT now(),
    last_login timestamp with time zone,
    reset_token character varying(500),
    reset_token_expires timestamp with time zone,
    google_id character varying(255)
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: documents id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents ALTER COLUMN id SET DEFAULT nextval('public.documents_id_seq'::regclass);


--
-- Name: form_103_line_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.form_103_line_items ALTER COLUMN id SET DEFAULT nextval('public.form_103_line_items_id_seq'::regclass);


--
-- Name: form_103_totals id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.form_103_totals ALTER COLUMN id SET DEFAULT nextval('public.form_103_totals_id_seq'::regclass);


--
-- Name: form_104_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.form_104_data ALTER COLUMN id SET DEFAULT nextval('public.form_104_data_id_seq'::regclass);


--
-- Name: guest_sessions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.guest_sessions ALTER COLUMN id SET DEFAULT nextval('public.guest_sessions_id_seq'::regclass);


--
-- Name: temporary_files id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.temporary_files ALTER COLUMN id SET DEFAULT nextval('public.temporary_files_id_seq'::regclass);


--
-- Name: usage_analytics id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usage_analytics ALTER COLUMN id SET DEFAULT nextval('public.usage_analytics_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: form_103_line_items form_103_line_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.form_103_line_items
    ADD CONSTRAINT form_103_line_items_pkey PRIMARY KEY (id);


--
-- Name: form_103_totals form_103_totals_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.form_103_totals
    ADD CONSTRAINT form_103_totals_pkey PRIMARY KEY (id);


--
-- Name: form_104_data form_104_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.form_104_data
    ADD CONSTRAINT form_104_data_pkey PRIMARY KEY (id);


--
-- Name: guest_sessions guest_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.guest_sessions
    ADD CONSTRAINT guest_sessions_pkey PRIMARY KEY (id);


--
-- Name: guest_sessions guest_sessions_session_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.guest_sessions
    ADD CONSTRAINT guest_sessions_session_id_key UNIQUE (session_id);


--
-- Name: temporary_files temporary_files_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.temporary_files
    ADD CONSTRAINT temporary_files_pkey PRIMARY KEY (id);


--
-- Name: usage_analytics usage_analytics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usage_analytics
    ADD CONSTRAINT usage_analytics_pkey PRIMARY KEY (id);


--
-- Name: users users_google_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_google_id_unique UNIQUE (google_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_analytics_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_analytics_created_at ON public.usage_analytics USING btree (created_at);


--
-- Name: idx_analytics_event_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_analytics_event_type ON public.usage_analytics USING btree (event_type);


--
-- Name: idx_analytics_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_analytics_user_id ON public.usage_analytics USING btree (user_id);


--
-- Name: idx_documents_periodo_mes; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_documents_periodo_mes ON public.documents USING btree (periodo_mes);


--
-- Name: idx_documents_periodo_mes_numero; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_documents_periodo_mes_numero ON public.documents USING btree (periodo_mes_numero);


--
-- Name: idx_documents_razon_social; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_documents_razon_social ON public.documents USING btree (razon_social);


--
-- Name: idx_documents_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_documents_user_id ON public.documents USING btree (user_id);


--
-- Name: idx_form_103_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_form_103_user_id ON public.form_103_line_items USING btree (user_id);


--
-- Name: idx_form_104_data_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_form_104_data_user_id ON public.form_104_data USING btree (user_id);


--
-- Name: idx_guest_sessions_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_guest_sessions_created_at ON public.guest_sessions USING btree (created_at);


--
-- Name: idx_guest_sessions_session_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_guest_sessions_session_id ON public.guest_sessions USING btree (session_id);


--
-- Name: idx_temp_files_expires_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_temp_files_expires_at ON public.temporary_files USING btree (expires_at);


--
-- Name: idx_temp_files_session_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_temp_files_session_id ON public.temporary_files USING btree (session_id);


--
-- Name: ix_documents_codigo_verificador; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_documents_codigo_verificador ON public.documents USING btree (codigo_verificador);


--
-- Name: ix_documents_form_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_documents_form_type ON public.documents USING btree (form_type);


--
-- Name: ix_documents_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_documents_id ON public.documents USING btree (id);


--
-- Name: ix_documents_identificacion_ruc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_documents_identificacion_ruc ON public.documents USING btree (identificacion_ruc);


--
-- Name: ix_documents_periodo_anio; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_documents_periodo_anio ON public.documents USING btree (periodo_anio);


--
-- Name: ix_documents_processing_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_documents_processing_status ON public.documents USING btree (processing_status);


--
-- Name: ix_documents_session_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_documents_session_id ON public.documents USING btree (session_id);


--
-- Name: ix_form_103_line_items_document_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_form_103_line_items_document_id ON public.form_103_line_items USING btree (document_id);


--
-- Name: ix_form_103_line_items_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_form_103_line_items_id ON public.form_103_line_items USING btree (id);


--
-- Name: ix_form_103_totals_document_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_form_103_totals_document_id ON public.form_103_totals USING btree (document_id);


--
-- Name: ix_form_103_totals_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_form_103_totals_id ON public.form_103_totals USING btree (id);


--
-- Name: ix_form_104_data_document_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_form_104_data_document_id ON public.form_104_data USING btree (document_id);


--
-- Name: ix_form_104_data_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_form_104_data_id ON public.form_104_data USING btree (id);


--
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: ix_users_google_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_users_google_id ON public.users USING btree (google_id);


--
-- Name: ix_users_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_users_id ON public.users USING btree (id);


--
-- Name: ix_users_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_users_username ON public.users USING btree (username);


--
-- Name: documents fk_documents_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT fk_documents_user_id FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: form_103_line_items fk_form103_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.form_103_line_items
    ADD CONSTRAINT fk_form103_user_id FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: form_104_data fk_form104_data_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.form_104_data
    ADD CONSTRAINT fk_form104_data_user_id FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: form_103_line_items form_103_line_items_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.form_103_line_items
    ADD CONSTRAINT form_103_line_items_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.documents(id) ON DELETE CASCADE;


--
-- Name: form_103_totals form_103_totals_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.form_103_totals
    ADD CONSTRAINT form_103_totals_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.documents(id) ON DELETE CASCADE;


--
-- Name: form_104_data form_104_data_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.form_104_data
    ADD CONSTRAINT form_104_data_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.documents(id) ON DELETE CASCADE;


--
-- Name: usage_analytics usage_analytics_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usage_analytics
    ADD CONSTRAINT usage_analytics_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict PzxXwp9szPc2CQQEpw4gDqHjdJQSTSs5QfE5g4Vfm7tSKG3DPDFab944GfcAjxq

