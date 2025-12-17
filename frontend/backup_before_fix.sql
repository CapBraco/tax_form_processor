--
-- PostgreSQL database dump
--

\restrict brTTQU2LA57bb91ZrA7tQ0DQJEkuJcbev7ZcdcXLZSlbb49eTvUOqw7IaYBT8cc

-- Dumped from database version 15.15
-- Dumped by pg_dump version 15.15

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: formtypeenum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.formtypeenum AS ENUM (
    'FORM_103',
    'FORM_104'
);


ALTER TYPE public.formtypeenum OWNER TO postgres;

--
-- Name: processingstatusenum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.processingstatusenum AS ENUM (
    'PENDING',
    'PROCESSING',
    'COMPLETED',
    'ERROR'
);


ALTER TYPE public.processingstatusenum OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: analytics_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.analytics_events (
    id integer NOT NULL,
    event_type character varying(100) NOT NULL,
    event_data jsonb,
    user_id integer,
    session_id character varying(255),
    ip_address character varying(45),
    user_agent text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.analytics_events OWNER TO postgres;

--
-- Name: TABLE analytics_events; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.analytics_events IS 'Tracks all analytics events including page views, uploads, exports, etc.';


--
-- Name: COLUMN analytics_events.event_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.analytics_events.event_type IS 'Type of event: page_view, upload, export, etc.';


--
-- Name: COLUMN analytics_events.event_data; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.analytics_events.event_data IS 'JSON data with additional event details (page path, metadata, etc.)';


--
-- Name: COLUMN analytics_events.user_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.analytics_events.user_id IS 'User ID for registered users (NULL for guests)';


--
-- Name: COLUMN analytics_events.session_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.analytics_events.session_id IS 'Session ID for tracking guest users';


--
-- Name: COLUMN analytics_events.ip_address; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.analytics_events.ip_address IS 'IP address of the visitor (optional)';


--
-- Name: COLUMN analytics_events.user_agent; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.analytics_events.user_agent IS 'Browser user agent string (optional)';


--
-- Name: analytics_events_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.analytics_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.analytics_events_id_seq OWNER TO postgres;

--
-- Name: analytics_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.analytics_events_id_seq OWNED BY public.analytics_events.id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.documents (
    id integer NOT NULL,
    filename character varying(500) NOT NULL,
    file_path character varying(1000),
    file_size integer,
    form_type public.formtypeenum,
    razon_social character varying(500),
    ruc character varying(50),
    period character varying(20),
    status character varying(50) DEFAULT 'pending'::character varying,
    error_message text,
    user_id integer,
    session_id character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    original_filename character varying(500),
    extracted_text text,
    total_pages integer,
    total_characters integer,
    parsed_data jsonb,
    codigo_verificador character varying(100),
    numero_serial character varying(100),
    fecha_recaudacion character varying(100),
    identificacion_ruc character varying(50),
    periodo_mes character varying(50),
    periodo_anio character varying(10),
    periodo_fiscal_completo character varying(100),
    periodo_mes_numero integer,
    processing_status public.processingstatusenum DEFAULT 'PENDING'::public.processingstatusenum,
    processing_error text,
    uploaded_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    processed_at timestamp with time zone
);


ALTER TABLE public.documents OWNER TO postgres;

--
-- Name: TABLE documents; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.documents IS 'Uploaded PDF documents metadata';


--
-- Name: COLUMN documents.user_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.documents.user_id IS 'User ID for registered users, NULL for guests';


--
-- Name: COLUMN documents.session_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.documents.session_id IS 'Session ID for guest users, NULL for registered';


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


ALTER TABLE public.documents_id_seq OWNER TO postgres;

--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.documents_id_seq OWNED BY public.documents.id;


--
-- Name: form_103_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.form_103_data (
    id integer NOT NULL,
    document_id integer,
    razon_social character varying(500),
    ruc character varying(50),
    period character varying(20),
    base_imponible_total numeric(15,2),
    valor_retenido_total numeric(15,2),
    raw_data jsonb,
    user_id integer,
    session_id character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.form_103_data OWNER TO postgres;

--
-- Name: TABLE form_103_data; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.form_103_data IS 'Extracted data from Form 103 (Retenciones)';


--
-- Name: COLUMN form_103_data.user_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.form_103_data.user_id IS 'User ID for complete data isolation';


--
-- Name: COLUMN form_103_data.session_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.form_103_data.session_id IS 'Guest session ID for temporary data';


--
-- Name: form_103_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.form_103_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.form_103_data_id_seq OWNER TO postgres;

--
-- Name: form_103_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.form_103_data_id_seq OWNED BY public.form_103_data.id;


--
-- Name: form_103_line_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.form_103_line_items (
    id integer NOT NULL,
    document_id integer,
    concepto character varying(500),
    codigo_base character varying(10),
    base_imponible numeric(15,2),
    codigo_retencion character varying(10),
    valor_retenido numeric(15,2),
    order_index integer,
    user_id integer,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
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


ALTER TABLE public.form_103_line_items_id_seq OWNER TO postgres;

--
-- Name: form_103_line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.form_103_line_items_id_seq OWNED BY public.form_103_line_items.id;


--
-- Name: form_103_totals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.form_103_totals (
    id integer NOT NULL,
    document_id integer,
    subtotal_operaciones_pais numeric(15,2),
    subtotal_retencion numeric(15,2),
    pagos_no_sujetos numeric(15,2),
    otras_retenciones_base numeric(15,2),
    otras_retenciones_retenido numeric(15,2),
    total_retencion numeric(15,2),
    total_impuesto_pagar numeric(15,2),
    interes_mora numeric(15,2),
    multa numeric(15,2),
    total_pagado numeric(15,2),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
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


ALTER TABLE public.form_103_totals_id_seq OWNER TO postgres;

--
-- Name: form_103_totals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.form_103_totals_id_seq OWNED BY public.form_103_totals.id;


--
-- Name: form_104_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.form_104_data (
    id integer NOT NULL,
    document_id integer,
    razon_social character varying(500),
    ruc character varying(50),
    period character varying(20),
    periodo_fiscal character varying(50),
    formulario_num character varying(50),
    num_formulario_que_sustituye character varying(50),
    ventas_tarifa_0 numeric(15,2),
    ventas_tarifa_12 numeric(15,2),
    ventas_tarifa_15 numeric(15,2),
    ventas_no_objeto_iva numeric(15,2),
    ventas_exentas numeric(15,2),
    compras_tarifa_0 numeric(15,2),
    compras_tarifa_12 numeric(15,2),
    compras_tarifa_15 numeric(15,2),
    compras_no_objeto_iva numeric(15,2),
    impuesto_causado numeric(15,2),
    credito_tributario numeric(15,2),
    iva_a_pagar numeric(15,2),
    saldo_favor_contribuyente numeric(15,2),
    total_ventas numeric(15,2),
    total_compras numeric(15,2),
    diferencia numeric(15,2),
    exportaciones_bienes numeric(15,2),
    exportaciones_servicios numeric(15,2),
    total_impuesto_generado numeric(15,2),
    total_impuesto_pagado numeric(15,2),
    saldo_total numeric(15,2),
    raw_data jsonb,
    user_id integer,
    session_id character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.form_104_data OWNER TO postgres;

--
-- Name: TABLE form_104_data; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.form_104_data IS 'Extracted data from Form 104 (IVA) - 127 fields';


--
-- Name: COLUMN form_104_data.ventas_tarifa_0; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.form_104_data.ventas_tarifa_0 IS 'Sales at 0% VAT rate';


--
-- Name: COLUMN form_104_data.ventas_tarifa_12; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.form_104_data.ventas_tarifa_12 IS 'Sales at 12% VAT rate';


--
-- Name: COLUMN form_104_data.ventas_tarifa_15; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.form_104_data.ventas_tarifa_15 IS 'Sales at 15% VAT rate';


--
-- Name: COLUMN form_104_data.impuesto_causado; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.form_104_data.impuesto_causado IS 'VAT tax caused/generated';


--
-- Name: COLUMN form_104_data.credito_tributario; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.form_104_data.credito_tributario IS 'Tax credit available';


--
-- Name: COLUMN form_104_data.raw_data; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.form_104_data.raw_data IS 'Complete JSON storage of all 127 fields from Form 104';


--
-- Name: COLUMN form_104_data.user_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.form_104_data.user_id IS 'User ID for complete data isolation';


--
-- Name: COLUMN form_104_data.session_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.form_104_data.session_id IS 'Guest session ID for temporary data';


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


ALTER TABLE public.form_104_data_id_seq OWNER TO postgres;

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
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    last_activity timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    expires_at timestamp with time zone,
    ip_address character varying(45),
    user_agent text
);


ALTER TABLE public.guest_sessions OWNER TO postgres;

--
-- Name: TABLE guest_sessions; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.guest_sessions IS 'Guest session tracking with document limits';


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


ALTER TABLE public.guest_sessions_id_seq OWNER TO postgres;

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
    file_path character varying(1000) NOT NULL,
    document_id integer,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    expires_at timestamp with time zone,
    file_size bigint
);


ALTER TABLE public.temporary_files OWNER TO postgres;

--
-- Name: TABLE temporary_files; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.temporary_files IS 'Temporary file storage for guest sessions';


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


ALTER TABLE public.temporary_files_id_seq OWNER TO postgres;

--
-- Name: temporary_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.temporary_files_id_seq OWNED BY public.temporary_files.id;


--
-- Name: usage_analytics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usage_analytics (
    id integer NOT NULL,
    user_id integer,
    session_id character varying(255),
    metadata jsonb,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    event_type character varying(50) DEFAULT 'unknown'::character varying NOT NULL,
    event_data jsonb
);


ALTER TABLE public.usage_analytics OWNER TO postgres;

--
-- Name: TABLE usage_analytics; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.usage_analytics IS 'User action tracking and usage statistics';


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


ALTER TABLE public.usage_analytics_id_seq OWNER TO postgres;

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
    is_superuser boolean DEFAULT false,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: TABLE users; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.users IS 'Registered user accounts with authentication';


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


ALTER TABLE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: analytics_events id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.analytics_events ALTER COLUMN id SET DEFAULT nextval('public.analytics_events_id_seq'::regclass);


--
-- Name: documents id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents ALTER COLUMN id SET DEFAULT nextval('public.documents_id_seq'::regclass);


--
-- Name: form_103_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.form_103_data ALTER COLUMN id SET DEFAULT nextval('public.form_103_data_id_seq'::regclass);


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
-- Data for Name: analytics_events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.analytics_events (id, event_type, event_data, user_id, session_id, ip_address, user_agent, created_at) FROM stdin;
\.


--
-- Data for Name: documents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.documents (id, filename, file_path, file_size, form_type, razon_social, ruc, period, status, error_message, user_id, session_id, created_at, updated_at, original_filename, extracted_text, total_pages, total_characters, parsed_data, codigo_verificador, numero_serial, fecha_recaudacion, identificacion_ruc, periodo_mes, periodo_anio, periodo_fiscal_completo, periodo_mes_numero, processing_status, processing_error, uploaded_at, processed_at) FROM stdin;
4	a1eb5c19cf21497aa7159b8ef8900654.pdf	./uploads/a1eb5c19cf21497aa7159b8ef8900654.pdf	149930	FORM_103	GAMA EDITORES REYES MEDINA CIA. LTDA.	\N	\N	pending	\N	\N	2dd5953c-7858-423a-92d7-676e616f5a5d	2025-12-16 22:44:37.793413+00	2025-12-16 22:44:37.793413+00	103 DECLARACION RETENCIONES JULIO.pdf	Obligación Tributaria: 1031 - DECLARACIÓN DE RETENCIONES EN LA FUENTE\nIdentificación: 1792234026001 Razón Social: GAMA EDITORES REYES MEDINA CIA. LTDA.\nPeríodo Fiscal: JULIO 2025 Tipo Declaración: ORIGINAL\nFormulario Sustituye:\n.\nDETALLE DE PAGOS Y RETENCIÓN POR IMPUESTO A LA RENTA\nPOR PAGOS EFECTUADOS A RESIDENTES Y ESTABLECIMIENTOS PERMANENTES\nDERIVADAS DEL TRABAJO Y SERVICIOS PRESTADOS\nBASE VALOR\nIMPONIBLE RETENIDO\nEn relación de dependencia que supera o no la base desgravada 302 7225.47 352 0.00\nServicios\n.Honorarios profesionales 303 445.00 353 44.50\n.Servicios profesionales prestados por sociedades residentes 3030 0.00 3530 0.00\n.Predomina el intelecto 304 0.00 354 0.00\n.Predomina la mano de obra 307 0.00 357 0.00\n.Utilización o aprovechamiento de la imagen o renombre (personas naturales, sociedades, influencers) 308 0.00 358 0.00\n.Publicidad y comunicación 309 0.00 359 0.00\n.Transporte privado de pasajeros o servicio público o privado de carga 310 13.50 360 0.14\nA través de liquidaciones de compra (nivel cultural o rusticidad) 311 0.00 361 0.00\nPOR BIENES Y SERVICIOS\nTransferencia de bienes muebles de naturaleza corporal 312 10920.24 362 191.10\nSeguros y reaseguros (primas y cesiones) 322 0.00 372 0.00\nCOMPRAS AL PRODUCTOR: de bienes de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuático, forestal y carnes en estado natural y 3120 0.00 3620 0.00\nlos descritos en el art.27.1 de LRTI.\nLa información reposa en la base de datos del SRI, conforme la declaraciónrealizada por el contribuyente\nCÓDIGO VERIFICADOR NÚMERO SERIAL FECHA RECAUDACIÓN PÁGINA\nSRIDEC2025134116289 872887903811 14-08-2025 1\nCOMPRAS AL COMERCIALIZADOR: de bienes de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuático, forestal y carnes en estado 3121 0.00 3621 0.00\nnatural y los descritos en el art.27.1 de LRTI.\nActividades de construcción de obra material inmueble, urbanización, lotización o actividades similares 3430 0.00 3450 0.00\nPagos aplicables el 1% (Energía Eléctrica y régimen RIMPE - Emprendedores, para este caso aplica con cualquier forma de pago inclusive los 343 6.52 393 0.07\npagos que deban realizar las tarjetas de crédito/débito)\nPagos aplicables el 2% (incluye Pago local tarjeta de crédito /débito reportada por la Emisora de tarjeta de crédito / entidades del sistema 344 0.00 394 0.00\nfinanciero; adquisición de sustancias minerales dentro del territorio nacional; Recepción de botellas plásticas no retornables de PET)\nPagos de bienes y servicios no sujetos a retención o con 0% (distintos de rendimientos financieros) 332 3684.78\nPOR REGALIAS, COMISIONES, ARRENDAMIENTOS Y OTROS\nPor regalías, derechos de autor, marcas, patentes y similares 314 0.00 364 0.00\nComisiones pagadas a sociedades, nacionales o extranjeras residentes en el Ecuador y establecimientos permanentes domiciliados en el país 3140 0.00 3640 0.00\nArrendamiento\n.Mercantil 319 0.00 369 0.00\n.Bienes inmuebles 320 0.00 370 0.00\nRELACIONADAS CON EL CAPITAL ( RENDIMIENTOS, GANANCIAS, DIVIDENDOS Y OTROS)\nRendimientos financieros 323 0.00 373 0.00\nRendimientos financieros entre instituciones del sistema financiero y entidades economía popular y solidaria 324 0.00 374 0.00\nOtros Rendimientos financieros 0% 3230 0.00\nGanancia en la enajenación de derechos representativos de capital u otros derechos que permitan la exploración, explotación, concesión o 333 0.00 383 0.00\nsimilares de sociedades, que se coticen en las bolsas de valores del Ecuador\nContraprestación en la enajenación de derechos representativos de capital u otros derechos que permitan la exploración, explotación, concesión o 334 0.00 384 0.00\nsimilares de sociedades, no cotizados en las bolsas de valores del Ecuador\nPOR LOTERIAS Y PREMIOS\nLoterías, rifas, apuestas, pronósticos deportivos y similares 335 0.00 385 0.00\nAUTORRETENCIONES Y OTRAS RETENCIONES\nVenta de combustibles\n.A comercializadoras 336 0.00 386 0.00\n.A distribuidores 337 0.00 387 0.00\nRetención a cargo del propio sujeto pasivo por la comercialización de productos forestales 3370 0.00 3870 0.00\nOtras autorretenciones (inciso 1 y 2 Art.92.1 RLRTI) 350 0.00 400 0.00\nOtras retenciones\nLa información reposa en la base de datos del SRI, conforme la declaraciónrealizada por el contribuyente\nCÓDIGO VERIFICADOR NÚMERO SERIAL FECHA RECAUDACIÓN PÁGINA\nSRIDEC2025134116289 872887903811 14-08-2025 2\n. Aplicables el 2,75% 3440 233.91 3940 6.44\n. Aplicables a otros porcentajes ( Por Donaciones en dinero -Impuesto a las donaciones ) 346 0.00 396 0.00\nLIQUIDACIÓN DE IMPUESTO A LA RENTA ÚNICO\nIRU Pronósticos deportivos\n. (+) Ingresos generados por la actividad económica de pronósticos deportivos 3483 0.00\n. (+) Comisiones derivadas de la actividad de pronósticos deportivos 3484 0.00\n. (-) Premios pagados por pronósticos deportivos 3485 0.00\nImpuesto a la renta único sobre los ingresos percibidos por los operadores de pronósticos deportivos 3480 0.00 3980 0.00\nSUBTOTAL OPERACIONES EFECTUADAS EN EL PAÍS 349 22529.42 399 242.25\nBASE VALOR\nIMPONIBLE RETENIDO\nTOTAL DE RETENCIÓN DE IMPUESTO A LA RENTA 399 + 498 499 242.25\n.\nVALORES A PAGAR (luego de imputación al pago)\nTOTAL IMPUESTO A PAGAR 499 - 898 902 242.25\nInterés por mora 903 0.00\nMulta 904 0.00\nTOTAL PAGADO 999 242.25\nLa información reposa en la base de datos del SRI, conforme la declaraciónrealizada por el contribuyente\nCÓDIGO VERIFICADOR NÚMERO SERIAL FECHA RECAUDACIÓN PÁGINA\nSRIDEC2025134116289 872887903811 14-08-2025 3	3	5448	{"header": {"periodo_mes": "JULIO", "periodo_anio": "2025", "razon_social": "GAMA EDITORES REYES MEDINA CIA. LTDA.", "identificacion": "1792234026001", "tipo_declaracion": "ORIGINAL", "codigo_verificador": "N", "obligacion_tributaria": "1031 - DECLARACIÓN DE RETENCIONES EN LA FUENTE\\nIdentificación"}, "totals": {"multa": 0.0, "interes_mora": 0.0, "total_pagado": 242.25, "total_retencion": 242.25, "pagos_no_sujetos": 3684.78, "subtotal_retencion": 242.25, "total_impuesto_pagar": 242.25, "otras_retenciones_base": 233.91, "subtotal_operaciones_pais": 22529.42, "otras_retenciones_retenido": 6.44}, "form_type": "form_103", "line_items": [{"concepto": ".\\nDETALLE DE PAGOS Y RETENCIÓN POR IMPUESTO A LA RENTA\\nPOR PAGOS EFECTUADOS A RESIDENTES Y ESTABLECIMIENTOS PERMANENTES\\nDERIVADAS DEL TRABAJO Y SERVICIOS PRESTADOS\\nBASE VALOR\\nIMPONIBLE RETENIDO\\nEn relación de dependencia que supera o no la base desgravada", "codigo_base": "302", "base_imponible": 7225.47, "valor_retenido": 0.0, "codigo_retencion": "352"}, {"concepto": "Servicios\\n.Honorarios profesionales", "codigo_base": "303", "base_imponible": 445.0, "valor_retenido": 44.5, "codigo_retencion": "353"}, {"concepto": ".Servicios profesionales prestados por sociedades residentes", "codigo_base": "3030", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "3530"}, {"concepto": ".Predomina el intelecto", "codigo_base": "304", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "354"}, {"concepto": ".Predomina la mano de obra", "codigo_base": "307", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "357"}, {"concepto": ".Utilización o aprovechamiento de la imagen o renombre (personas naturales, sociedades, influencers)", "codigo_base": "308", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "358"}, {"concepto": ".Publicidad y comunicación", "codigo_base": "309", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "359"}, {"concepto": ".Transporte privado de pasajeros o servicio público o privado de carga", "codigo_base": "310", "base_imponible": 13.5, "valor_retenido": 0.14, "codigo_retencion": "360"}, {"concepto": "A través de liquidaciones de compra (nivel cultural o rusticidad)", "codigo_base": "311", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "361"}, {"concepto": "POR BIENES Y SERVICIOS\\nTransferencia de bienes muebles de naturaleza corporal", "codigo_base": "312", "base_imponible": 10920.24, "valor_retenido": 191.1, "codigo_retencion": "362"}, {"concepto": "Seguros y reaseguros (primas y cesiones)", "codigo_base": "322", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "372"}, {"concepto": "de bienes de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuático, forestal y carnes en estado natural y", "codigo_base": "3120", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "3620"}, {"concepto": "de bienes de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuático, forestal y carnes en estado", "codigo_base": "3121", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "3621"}, {"concepto": "de LRTI.\\nActividades de construcción de obra material inmueble, urbanización, lotización o actividades similares", "codigo_base": "3430", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "3450"}, {"concepto": "(Energía Eléctrica y régimen RIMPE - Emprendedores, para este caso aplica con cualquier forma de pago inclusive los", "codigo_base": "343", "base_imponible": 6.52, "valor_retenido": 0.07, "codigo_retencion": "393"}, {"concepto": "(incluye Pago local tarjeta de crédito /débito reportada por la Emisora de tarjeta de crédito / entidades del sistema", "codigo_base": "344", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "394"}, {"concepto": "POR REGALIAS, COMISIONES, ARRENDAMIENTOS Y OTROS\\nPor regalías, derechos de autor, marcas, patentes y similares", "codigo_base": "314", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "364"}, {"concepto": "Comisiones pagadas a sociedades, nacionales o extranjeras residentes en el Ecuador y establecimientos permanentes domiciliados en el país", "codigo_base": "3140", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "3640"}, {"concepto": "Arrendamiento\\n.Mercantil", "codigo_base": "319", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "369"}, {"concepto": ".Bienes inmuebles", "codigo_base": "320", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "370"}, {"concepto": "RELACIONADAS CON EL CAPITAL ( RENDIMIENTOS, GANANCIAS, DIVIDENDOS Y OTROS)\\nRendimientos financieros", "codigo_base": "323", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "373"}, {"concepto": "Rendimientos financieros entre instituciones del sistema financiero y entidades economía popular y solidaria", "codigo_base": "324", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "374"}, {"concepto": "Ganancia en la enajenación de derechos representativos de capital u otros derechos que permitan la exploración, explotación, concesión o", "codigo_base": "333", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "383"}, {"concepto": "similares de sociedades, que se coticen en las bolsas de valores del Ecuador\\nContraprestación en la enajenación de derechos representativos de capital u otros derechos que permitan la exploración, explotación, concesión o", "codigo_base": "334", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "384"}, {"concepto": "similares de sociedades, no cotizados en las bolsas de valores del Ecuador\\nPOR LOTERIAS Y PREMIOS\\nLoterías, rifas, apuestas, pronósticos deportivos y similares", "codigo_base": "335", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "385"}, {"concepto": "AUTORRETENCIONES Y OTRAS RETENCIONES\\nVenta de combustibles\\n.A comercializadoras", "codigo_base": "336", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "386"}, {"concepto": ".A distribuidores", "codigo_base": "337", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "387"}, {"concepto": "Retención a cargo del propio sujeto pasivo por la comercialización de productos forestales", "codigo_base": "3370", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "3870"}, {"concepto": "RLRTI)", "codigo_base": "350", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "400"}, {"concepto": ". Aplicables a otros porcentajes ( Por Donaciones en dinero -Impuesto a las donaciones )", "codigo_base": "346", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "396"}, {"concepto": "Impuesto a la renta único sobre los ingresos percibidos por los operadores de pronósticos deportivos", "codigo_base": "3480", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "3980"}, {"concepto": "Pagos de bienes y servicios no sujetos a retención (Código 332)", "codigo_base": "332", "base_imponible": 3684.78, "valor_retenido": 0.0, "codigo_retencion": "N/A"}]}	\N	\N	\N	1792234026001	JULIO	2025	JULIO 2025	7	COMPLETED	\N	2025-12-16 22:44:37.793413+00	2025-12-17 03:44:37.95699+00
5	17c5a671a1b24c2398876a7c029ba500.pdf	./uploads/17c5a671a1b24c2398876a7c029ba500.pdf	149912	FORM_103	GAMA EDITORES REYES MEDINA CIA. LTDA.	\N	\N	pending	\N	\N	2dd5953c-7858-423a-92d7-676e616f5a5d	2025-12-16 23:54:44.418076+00	2025-12-16 23:54:44.418076+00	103 DECLARACION RETENCIONES AGOSTO.pdf	Obligación Tributaria: 1031 - DECLARACIÓN DE RETENCIONES EN LA FUENTE\nIdentificación: 1792234026001 Razón Social: GAMA EDITORES REYES MEDINA CIA. LTDA.\nPeríodo Fiscal: AGOSTO 2025 Tipo Declaración: ORIGINAL\nFormulario Sustituye:\n.\nDETALLE DE PAGOS Y RETENCIÓN POR IMPUESTO A LA RENTA\nPOR PAGOS EFECTUADOS A RESIDENTES Y ESTABLECIMIENTOS PERMANENTES\nDERIVADAS DEL TRABAJO Y SERVICIOS PRESTADOS\nBASE VALOR\nIMPONIBLE RETENIDO\nEn relación de dependencia que supera o no la base desgravada 302 7225.47 352 0.00\nServicios\n.Honorarios profesionales 303 328.00 353 32.80\n.Servicios profesionales prestados por sociedades residentes 3030 0.00 3530 0.00\n.Predomina el intelecto 304 0.00 354 0.00\n.Predomina la mano de obra 307 0.00 357 0.00\n.Utilización o aprovechamiento de la imagen o renombre (personas naturales, sociedades, influencers) 308 0.00 358 0.00\n.Publicidad y comunicación 309 0.00 359 0.00\n.Transporte privado de pasajeros o servicio público o privado de carga 310 115.50 360 1.17\nA través de liquidaciones de compra (nivel cultural o rusticidad) 311 0.00 361 0.00\nPOR BIENES Y SERVICIOS\nTransferencia de bienes muebles de naturaleza corporal 312 4995.59 362 87.41\nSeguros y reaseguros (primas y cesiones) 322 0.00 372 0.00\nCOMPRAS AL PRODUCTOR: de bienes de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuático, forestal y carnes en estado natural y 3120 0.00 3620 0.00\nlos descritos en el art.27.1 de LRTI.\nLa información reposa en la base de datos del SRI, conforme la declaraciónrealizada por el contribuyente\nCÓDIGO VERIFICADOR NÚMERO SERIAL FECHA RECAUDACIÓN PÁGINA\nSRIDEC2025135437940 872901824967 12-09-2025 1\nCOMPRAS AL COMERCIALIZADOR: de bienes de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuático, forestal y carnes en estado 3121 0.00 3621 0.00\nnatural y los descritos en el art.27.1 de LRTI.\nActividades de construcción de obra material inmueble, urbanización, lotización o actividades similares 3430 0.00 3450 0.00\nPagos aplicables el 1% (Energía Eléctrica y régimen RIMPE - Emprendedores, para este caso aplica con cualquier forma de pago inclusive los 343 0.00 393 0.00\npagos que deban realizar las tarjetas de crédito/débito)\nPagos aplicables el 2% (incluye Pago local tarjeta de crédito /débito reportada por la Emisora de tarjeta de crédito / entidades del sistema 344 0.00 394 0.00\nfinanciero; adquisición de sustancias minerales dentro del territorio nacional; Recepción de botellas plásticas no retornables de PET)\nPagos de bienes y servicios no sujetos a retención o con 0% (distintos de rendimientos financieros) 332 2660.48\nPOR REGALIAS, COMISIONES, ARRENDAMIENTOS Y OTROS\nPor regalías, derechos de autor, marcas, patentes y similares 314 0.00 364 0.00\nComisiones pagadas a sociedades, nacionales o extranjeras residentes en el Ecuador y establecimientos permanentes domiciliados en el país 3140 0.00 3640 0.00\nArrendamiento\n.Mercantil 319 0.00 369 0.00\n.Bienes inmuebles 320 0.00 370 0.00\nRELACIONADAS CON EL CAPITAL ( RENDIMIENTOS, GANANCIAS, DIVIDENDOS Y OTROS)\nRendimientos financieros 323 0.00 373 0.00\nRendimientos financieros entre instituciones del sistema financiero y entidades economía popular y solidaria 324 0.00 374 0.00\nOtros Rendimientos financieros 0% 3230 0.00\nGanancia en la enajenación de derechos representativos de capital u otros derechos que permitan la exploración, explotación, concesión o 333 0.00 383 0.00\nsimilares de sociedades, que se coticen en las bolsas de valores del Ecuador\nContraprestación en la enajenación de derechos representativos de capital u otros derechos que permitan la exploración, explotación, concesión o 334 0.00 384 0.00\nsimilares de sociedades, no cotizados en las bolsas de valores del Ecuador\nPOR LOTERIAS Y PREMIOS\nLoterías, rifas, apuestas, pronósticos deportivos y similares 335 0.00 385 0.00\nAUTORRETENCIONES Y OTRAS RETENCIONES\nVenta de combustibles\n.A comercializadoras 336 0.00 386 0.00\n.A distribuidores 337 0.00 387 0.00\nRetención a cargo del propio sujeto pasivo por la comercialización de productos forestales 3370 0.00 3870 0.00\nOtras autorretenciones (inciso 1 y 2 Art.92.1 RLRTI) 350 0.00 400 0.00\nOtras retenciones\nLa información reposa en la base de datos del SRI, conforme la declaraciónrealizada por el contribuyente\nCÓDIGO VERIFICADOR NÚMERO SERIAL FECHA RECAUDACIÓN PÁGINA\nSRIDEC2025135437940 872901824967 12-09-2025 2\n. Aplicables el 2,75% 3440 176.91 3940 4.87\n. Aplicables a otros porcentajes ( Por Donaciones en dinero -Impuesto a las donaciones ) 346 0.00 396 0.00\nLIQUIDACIÓN DE IMPUESTO A LA RENTA ÚNICO\nIRU Pronósticos deportivos\n. (+) Ingresos generados por la actividad económica de pronósticos deportivos 3483 0.00\n. (+) Comisiones derivadas de la actividad de pronósticos deportivos 3484 0.00\n. (-) Premios pagados por pronósticos deportivos 3485 0.00\nImpuesto a la renta único sobre los ingresos percibidos por los operadores de pronósticos deportivos 3480 0.00 3980 0.00\nSUBTOTAL OPERACIONES EFECTUADAS EN EL PAÍS 349 15501.95 399 126.25\nBASE VALOR\nIMPONIBLE RETENIDO\nTOTAL DE RETENCIÓN DE IMPUESTO A LA RENTA 399 + 498 499 126.25\n.\nVALORES A PAGAR (luego de imputación al pago)\nTOTAL IMPUESTO A PAGAR 499 - 898 902 126.25\nInterés por mora 903 0.00\nMulta 904 0.00\nTOTAL PAGADO 999 126.25\nLa información reposa en la base de datos del SRI, conforme la declaraciónrealizada por el contribuyente\nCÓDIGO VERIFICADOR NÚMERO SERIAL FECHA RECAUDACIÓN PÁGINA\nSRIDEC2025135437940 872901824967 12-09-2025 3	3	5448	{"header": {"periodo_mes": "AGOSTO", "periodo_anio": "2025", "razon_social": "GAMA EDITORES REYES MEDINA CIA. LTDA.", "identificacion": "1792234026001", "tipo_declaracion": "ORIGINAL", "codigo_verificador": "N", "obligacion_tributaria": "1031 - DECLARACIÓN DE RETENCIONES EN LA FUENTE\\nIdentificación"}, "totals": {"multa": 0.0, "interes_mora": 0.0, "total_pagado": 126.25, "total_retencion": 126.25, "pagos_no_sujetos": 2660.48, "subtotal_retencion": 126.25, "total_impuesto_pagar": 126.25, "otras_retenciones_base": 176.91, "subtotal_operaciones_pais": 15501.95, "otras_retenciones_retenido": 4.87}, "form_type": "form_103", "line_items": [{"concepto": ".\\nDETALLE DE PAGOS Y RETENCIÓN POR IMPUESTO A LA RENTA\\nPOR PAGOS EFECTUADOS A RESIDENTES Y ESTABLECIMIENTOS PERMANENTES\\nDERIVADAS DEL TRABAJO Y SERVICIOS PRESTADOS\\nBASE VALOR\\nIMPONIBLE RETENIDO\\nEn relación de dependencia que supera o no la base desgravada", "codigo_base": "302", "base_imponible": 7225.47, "valor_retenido": 0.0, "codigo_retencion": "352"}, {"concepto": "Servicios\\n.Honorarios profesionales", "codigo_base": "303", "base_imponible": 328.0, "valor_retenido": 32.8, "codigo_retencion": "353"}, {"concepto": ".Servicios profesionales prestados por sociedades residentes", "codigo_base": "3030", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "3530"}, {"concepto": ".Predomina el intelecto", "codigo_base": "304", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "354"}, {"concepto": ".Predomina la mano de obra", "codigo_base": "307", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "357"}, {"concepto": ".Utilización o aprovechamiento de la imagen o renombre (personas naturales, sociedades, influencers)", "codigo_base": "308", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "358"}, {"concepto": ".Publicidad y comunicación", "codigo_base": "309", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "359"}, {"concepto": ".Transporte privado de pasajeros o servicio público o privado de carga", "codigo_base": "310", "base_imponible": 115.5, "valor_retenido": 1.17, "codigo_retencion": "360"}, {"concepto": "A través de liquidaciones de compra (nivel cultural o rusticidad)", "codigo_base": "311", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "361"}, {"concepto": "POR BIENES Y SERVICIOS\\nTransferencia de bienes muebles de naturaleza corporal", "codigo_base": "312", "base_imponible": 4995.59, "valor_retenido": 87.41, "codigo_retencion": "362"}, {"concepto": "Seguros y reaseguros (primas y cesiones)", "codigo_base": "322", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "372"}, {"concepto": "de bienes de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuático, forestal y carnes en estado natural y", "codigo_base": "3120", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "3620"}, {"concepto": "de bienes de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuático, forestal y carnes en estado", "codigo_base": "3121", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "3621"}, {"concepto": "de LRTI.\\nActividades de construcción de obra material inmueble, urbanización, lotización o actividades similares", "codigo_base": "3430", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "3450"}, {"concepto": "(Energía Eléctrica y régimen RIMPE - Emprendedores, para este caso aplica con cualquier forma de pago inclusive los", "codigo_base": "343", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "393"}, {"concepto": "(incluye Pago local tarjeta de crédito /débito reportada por la Emisora de tarjeta de crédito / entidades del sistema", "codigo_base": "344", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "394"}, {"concepto": "POR REGALIAS, COMISIONES, ARRENDAMIENTOS Y OTROS\\nPor regalías, derechos de autor, marcas, patentes y similares", "codigo_base": "314", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "364"}, {"concepto": "Comisiones pagadas a sociedades, nacionales o extranjeras residentes en el Ecuador y establecimientos permanentes domiciliados en el país", "codigo_base": "3140", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "3640"}, {"concepto": "Arrendamiento\\n.Mercantil", "codigo_base": "319", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "369"}, {"concepto": ".Bienes inmuebles", "codigo_base": "320", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "370"}, {"concepto": "RELACIONADAS CON EL CAPITAL ( RENDIMIENTOS, GANANCIAS, DIVIDENDOS Y OTROS)\\nRendimientos financieros", "codigo_base": "323", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "373"}, {"concepto": "Rendimientos financieros entre instituciones del sistema financiero y entidades economía popular y solidaria", "codigo_base": "324", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "374"}, {"concepto": "Ganancia en la enajenación de derechos representativos de capital u otros derechos que permitan la exploración, explotación, concesión o", "codigo_base": "333", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "383"}, {"concepto": "similares de sociedades, que se coticen en las bolsas de valores del Ecuador\\nContraprestación en la enajenación de derechos representativos de capital u otros derechos que permitan la exploración, explotación, concesión o", "codigo_base": "334", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "384"}, {"concepto": "similares de sociedades, no cotizados en las bolsas de valores del Ecuador\\nPOR LOTERIAS Y PREMIOS\\nLoterías, rifas, apuestas, pronósticos deportivos y similares", "codigo_base": "335", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "385"}, {"concepto": "AUTORRETENCIONES Y OTRAS RETENCIONES\\nVenta de combustibles\\n.A comercializadoras", "codigo_base": "336", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "386"}, {"concepto": ".A distribuidores", "codigo_base": "337", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "387"}, {"concepto": "Retención a cargo del propio sujeto pasivo por la comercialización de productos forestales", "codigo_base": "3370", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "3870"}, {"concepto": "RLRTI)", "codigo_base": "350", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "400"}, {"concepto": ". Aplicables a otros porcentajes ( Por Donaciones en dinero -Impuesto a las donaciones )", "codigo_base": "346", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "396"}, {"concepto": "Impuesto a la renta único sobre los ingresos percibidos por los operadores de pronósticos deportivos", "codigo_base": "3480", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "3980"}, {"concepto": "Pagos de bienes y servicios no sujetos a retención (Código 332)", "codigo_base": "332", "base_imponible": 2660.48, "valor_retenido": 0.0, "codigo_retencion": "N/A"}]}	\N	\N	\N	1792234026001	AGOSTO	2025	AGOSTO 2025	8	COMPLETED	\N	2025-12-16 23:54:44.418076+00	2025-12-17 04:54:44.573656+00
6	fa9e822f373741eea7205163faa39f83.pdf	./uploads/fa9e822f373741eea7205163faa39f83.pdf	148451	FORM_103	GAMA EDITORES REYES MEDINA CIA. LTDA.	\N	\N	pending	\N	\N	2dd5953c-7858-423a-92d7-676e616f5a5d	2025-12-17 01:27:44.718372+00	2025-12-17 01:27:44.718372+00	103 DECLARACION RETENCION FUENTE OCTUBRE.pdf	_ Obligación Tributaria: 1031 - DECLARACIÓN DE RETENCIONES EN LA FUENTE _\n_ Identificación: 1792234026001 Razón Social: GAMA EDITORES REYES MEDINA CIA. LTDA. _\n_ Período Fiscal: OCTUBRE 2025 Tipo Declaración: ORIGINAL _\n_ Formulario Sustituye: Estado de la Declaración: PENDIENTE _\n_\nDETALLE DE PAGOS Y RETENCIÓN POR IMPUESTO A LA RENTA\nPOR PAGOS EFECTUADOS A RESIDENTES Y ESTABLECIMIENTOS PERMANENTES\nDERIVADAS DEL TRABAJO Y SERVICIOS PRESTADOS\n_ BASE IMPONIBLE VALOR\nRETENIDO\nEn relación de dependencia que supera o no la base desgravada 302 7225.47 352 0.00\nServicios\n_ Honorarios profesionales 303 300.00 353 30.00\n_ Servicios profesionales prestados por sociedades residentes 3030 0.00 3530 0.00\n_ Predomina el intelecto 304 0.00 354 0.00\n_ Predomina la mano de obra 307 0.00 357 0.00\n_ Utilización o aprovechamiento de la imagen o renombre (personas naturales, sociedades, influencers) 308 0.00 358 0.00\n_ Publicidad y comunicación 309 0.00 359 0.00\n_ Transporte privado de pasajeros o servicio público o privado de carga 310 118.00 360 1.18\nA través de liquidaciones de compra (nivel cultural o rusticidad) 311 0.00 361 0.00\nPOR BIENES Y SERVICIOS\nTransferencia de bienes muebles de naturaleza corporal 312 11141.32 362 194.98\nSeguros y reaseguros (primas y cesiones) 322 0.00 372 0.00\nLa información reposa en la base de datos del SRI, conforme la declaraciónrealizada por el contribuyente\nNÚMERO SERIAL FECHA RECAUDACIÓN PÁGINA\n872927677763 11-11-2025 1\nCOMPRAS AL PRODUCTOR: de bienes de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuático, forestal y carnes 3120 0.00 3620 0.00\nen estado natural y los descritos en el art.27.1 de LRTI.\nCOMPRAS AL COMERCIALIZADOR: de bienes de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuático, forestal y 3121 0.00 3621 0.00\ncarnes en estado natural y los descritos en el art.27.1 de LRTI.\nActividades de construcción de obra material inmueble, urbanización, lotización o actividades similares 3430 0.00 3450 0.00\nPagos aplicables el 1% (Energía Eléctrica y régimen RIMPE - Emprendedores, para este caso aplica con cualquier forma de 343 0.00 393 0.00\npago inclusive los pagos que deban realizar las tarjetas de crédito/débito)\nPagos aplicables el 2% (incluye Pago local tarjeta de crédito /débito reportada por la Emisora de tarjeta de crédito / entidades 344 0.00 394 0.00\ndel sistema financiero; adquisición de sustancias minerales dentro del territorio nacional; Recepción de botellas plásticas no\nretornables de PET)\nPagos de bienes y servicios no sujetos a retención o con 0% (distintos de rendimientos financieros) 332 942.92 _\nPOR REGALIAS, COMISIONES, ARRENDAMIENTOS Y OTROS\nPor regalías, derechos de autor, marcas, patentes y similares 314 0.00 364 0.00\nComisiones pagadas a sociedades, nacionales o extranjeras residentes en el Ecuador y establecimientos permanentes 3140 0.00 3640 0.00\ndomiciliados en el país\nArrendamiento\n_ Mercantil 319 0.00 369 0.00\n_ Bienes inmuebles 320 0.00 370 0.00\nRELACIONADAS CON EL CAPITAL (RENDIMIENTOS, GANANCIAS, DIVIDENDOS Y OTROS)\nRendimientos financieros 323 0.00 373 0.00\nRendimientos financieros entre instituciones del sistema financiero y entidades economía popular y solidaria 324 0.00 374 0.00\nOtros Rendimientos financieros 0% 3230 0.00 _\n_ Dividendos exentos (por no superar la franja exenta o beneficio de otras leyes) 3250 0.00 _\nGanancia en la enajenación de derechos representativos de capital u otros derechos que permitan la exploración, explotación, 333 0.00 383 0.00\nconcesión o similares de sociedades, que se coticen en las bolsas de valores del Ecuador\nContraprestación en la enajenación de derechos representativos de capital u otros derechos que permitan la exploración, 334 0.00 384 0.00\nexplotación, concesión o similares de sociedades, no cotizados en las bolsas de valores del Ecuador\nPOR LOTERIAS Y PREMIOS\nLoterías, rifas, apuestas, pronósticos deportivos y similares 335 0.00 385 0.00\nLa información reposa en la base de datos del SRI, conforme la declaraciónrealizada por el contribuyente\nNÚMERO SERIAL FECHA RECAUDACIÓN PÁGINA\n872927677763 11-11-2025 2\nAUTORRETENCIONES Y OTRAS RETENCIONES\nVenta de combustibles\n_ A comercializadoras 336 0.00 386 0.00\n_ A distribuidores 337 0.00 387 0.00\nRetención a cargo del propio sujeto pasivo por la comercialización de productos forestales 3370 0.00 3870 0.00\nOtras autorretenciones (inciso 1 y 2 Art.92.1 RLRTI) 350 0.00 400 0.00\nOtras retenciones\n_ Aplicables el 2,75% 3440 537.91 3940 14.79\n_ Aplicables a otros porcentajes ( Por Donaciones en dinero -Impuesto a las donaciones ) 346 0.00 396 0.00\nLIQUIDACIÓN DE IMPUESTO A LA RENTA ÚNICO\nIRU Pronósticos deportivos\n_ (+) Ingresos generados por la actividad económica de pronósticos deportivos 3483 0.00 _\n_ (+) Comisiones derivadas de la actividad de pronósticos deportivos 3484 0.00 _\n_ (-) Premios pagados por pronósticos deportivos 3485 0.00 _\n_ Impuesto a la renta único sobre los ingresos percibidos por los operadores de pronósticos deportivos 3480 0.00 3980 0.00\nSUBTOTAL OPERACIONES EFECTUADAS EN EL PAÍS 349 20265.62 399 240.95\n_\n_\nTOTAL DE RETENCIÓN DE IMPUESTO A LA RENTA 399 + 498 499 240.95\n_\nVALORES A PAGAR (luego de imputación al pago)\nTOTAL IMPUESTO A PAGAR 902 240.95\nInterés por mora 903 0.00\nMulta 904 0.00\nTOTAL PAGADO 999 240.95\nLa información reposa en la base de datos del SRI, conforme la declaraciónrealizada por el contribuyente\nNÚMERO SERIAL FECHA RECAUDACIÓN PÁGINA\n872927677763 11-11-2025 3	3	5468	{"header": {"periodo_mes": "OCTUBRE", "periodo_anio": "2025", "identificacion": "1792234026001", "tipo_declaracion": "ORIGINAL", "obligacion_tributaria": "1031 - DECLARACIÓN DE RETENCIONES EN LA FUENTE"}, "totals": {"multa": 0.0, "interes_mora": 0.0, "total_pagado": 240.95, "total_retencion": 240.95, "pagos_no_sujetos": 942.92, "subtotal_retencion": 240.95, "total_impuesto_pagar": 240.95, "otras_retenciones_base": 537.91, "subtotal_operaciones_pais": 20265.62, "otras_retenciones_retenido": 14.79}, "form_type": "form_103", "line_items": [{"concepto": "Honorarios profesionales", "codigo_base": "303", "base_imponible": 300.0, "valor_retenido": 30.0, "codigo_retencion": "353"}, {"concepto": "Servicios profesionales prestados por sociedades residentes", "codigo_base": "3030", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "3530"}, {"concepto": "Predomina el intelecto", "codigo_base": "304", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "354"}, {"concepto": "Predomina la mano de obra", "codigo_base": "307", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "357"}, {"concepto": "Utilización o aprovechamiento de la imagen o renombre (personas naturales, sociedades, influencers)", "codigo_base": "308", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "358"}, {"concepto": "Publicidad y comunicación", "codigo_base": "309", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "359"}, {"concepto": "Transporte privado de pasajeros o servicio público o privado de carga", "codigo_base": "310", "base_imponible": 118.0, "valor_retenido": 1.18, "codigo_retencion": "360"}, {"concepto": "A través de liquidaciones de compra (nivel cultural o rusticidad)", "codigo_base": "311", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "361"}, {"concepto": "POR BIENES Y SERVICIOS\\nTransferencia de bienes muebles de naturaleza corporal", "codigo_base": "312", "base_imponible": 11141.32, "valor_retenido": 194.98, "codigo_retencion": "362"}, {"concepto": "Seguros y reaseguros (primas y cesiones)", "codigo_base": "322", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "372"}, {"concepto": "de bienes de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuático, forestal y carnes", "codigo_base": "3120", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "3620"}, {"concepto": "de bienes de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuático, forestal y", "codigo_base": "3121", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "3621"}, {"concepto": "de LRTI.\\nActividades de construcción de obra material inmueble, urbanización, lotización o actividades similares", "codigo_base": "3430", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "3450"}, {"concepto": "(Energía Eléctrica y régimen RIMPE - Emprendedores, para este caso aplica con cualquier forma de", "codigo_base": "343", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "393"}, {"concepto": "(incluye Pago local tarjeta de crédito /débito reportada por la Emisora de tarjeta de crédito / entidades", "codigo_base": "344", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "394"}, {"concepto": "POR REGALIAS, COMISIONES, ARRENDAMIENTOS Y OTROS\\nPor regalías, derechos de autor, marcas, patentes y similares", "codigo_base": "314", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "364"}, {"concepto": "Comisiones pagadas a sociedades, nacionales o extranjeras residentes en el Ecuador y establecimientos permanentes", "codigo_base": "3140", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "3640"}, {"concepto": "Mercantil", "codigo_base": "319", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "369"}, {"concepto": "Bienes inmuebles", "codigo_base": "320", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "370"}, {"concepto": "RELACIONADAS CON EL CAPITAL (RENDIMIENTOS, GANANCIAS, DIVIDENDOS Y OTROS)\\nRendimientos financieros", "codigo_base": "323", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "373"}, {"concepto": "Rendimientos financieros entre instituciones del sistema financiero y entidades economía popular y solidaria", "codigo_base": "324", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "374"}, {"concepto": "Ganancia en la enajenación de derechos representativos de capital u otros derechos que permitan la exploración, explotación,", "codigo_base": "333", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "383"}, {"concepto": "concesión o similares de sociedades, que se coticen en las bolsas de valores del Ecuador\\nContraprestación en la enajenación de derechos representativos de capital u otros derechos que permitan la exploración,", "codigo_base": "334", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "384"}, {"concepto": "explotación, concesión o similares de sociedades, no cotizados en las bolsas de valores del Ecuador\\nPOR LOTERIAS Y PREMIOS\\nLoterías, rifas, apuestas, pronósticos deportivos y similares", "codigo_base": "335", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "385"}, {"concepto": "A comercializadoras", "codigo_base": "336", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "386"}, {"concepto": "A distribuidores", "codigo_base": "337", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "387"}, {"concepto": "Retención a cargo del propio sujeto pasivo por la comercialización de productos forestales", "codigo_base": "3370", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "3870"}, {"concepto": "RLRTI)", "codigo_base": "350", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "400"}, {"concepto": "Aplicables a otros porcentajes ( Por Donaciones en dinero -Impuesto a las donaciones )", "codigo_base": "346", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "396"}, {"concepto": "Impuesto a la renta único sobre los ingresos percibidos por los operadores de pronósticos deportivos", "codigo_base": "3480", "base_imponible": 0.0, "valor_retenido": 0.0, "codigo_retencion": "3980"}, {"concepto": "Pagos de bienes y servicios no sujetos a retención (Código 332)", "codigo_base": "332", "base_imponible": 942.92, "valor_retenido": 0.0, "codigo_retencion": "N/A"}]}	\N	\N	\N	1792234026001	OCTUBRE	2025	OCTUBRE 2025	10	COMPLETED	\N	2025-12-17 01:27:44.718372+00	2025-12-17 06:27:44.884602+00
\.


--
-- Data for Name: form_103_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.form_103_data (id, document_id, razon_social, ruc, period, base_imponible_total, valor_retenido_total, raw_data, user_id, session_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: form_103_line_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.form_103_line_items (id, document_id, concepto, codigo_base, base_imponible, codigo_retencion, valor_retenido, order_index, user_id, created_at) FROM stdin;
1	4	.\nDETALLE DE PAGOS Y RETENCIÓN POR IMPUESTO A LA RENTA\nPOR PAGOS EFECTUADOS A RESIDENTES Y ESTABLECIMIENTOS PERMANENTES\nDERIVADAS DEL TRABAJO Y SERVICIOS PRESTADOS\nBASE VALOR\nIMPONIBLE RETENIDO\nEn relación de dependencia que supera o no la base desgravada	302	7225.47	352	0.00	0	\N	2025-12-16 22:44:37.793413+00
2	4	Servicios\n.Honorarios profesionales	303	445.00	353	44.50	1	\N	2025-12-16 22:44:37.793413+00
3	4	.Servicios profesionales prestados por sociedades residentes	3030	0.00	3530	0.00	2	\N	2025-12-16 22:44:37.793413+00
4	4	.Predomina el intelecto	304	0.00	354	0.00	3	\N	2025-12-16 22:44:37.793413+00
5	4	.Predomina la mano de obra	307	0.00	357	0.00	4	\N	2025-12-16 22:44:37.793413+00
6	4	.Utilización o aprovechamiento de la imagen o renombre (personas naturales, sociedades, influencers)	308	0.00	358	0.00	5	\N	2025-12-16 22:44:37.793413+00
7	4	.Publicidad y comunicación	309	0.00	359	0.00	6	\N	2025-12-16 22:44:37.793413+00
8	4	.Transporte privado de pasajeros o servicio público o privado de carga	310	13.50	360	0.14	7	\N	2025-12-16 22:44:37.793413+00
9	4	A través de liquidaciones de compra (nivel cultural o rusticidad)	311	0.00	361	0.00	8	\N	2025-12-16 22:44:37.793413+00
10	4	POR BIENES Y SERVICIOS\nTransferencia de bienes muebles de naturaleza corporal	312	10920.24	362	191.10	9	\N	2025-12-16 22:44:37.793413+00
11	4	Seguros y reaseguros (primas y cesiones)	322	0.00	372	0.00	10	\N	2025-12-16 22:44:37.793413+00
12	4	de bienes de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuático, forestal y carnes en estado natural y	3120	0.00	3620	0.00	11	\N	2025-12-16 22:44:37.793413+00
13	4	de bienes de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuático, forestal y carnes en estado	3121	0.00	3621	0.00	12	\N	2025-12-16 22:44:37.793413+00
14	4	de LRTI.\nActividades de construcción de obra material inmueble, urbanización, lotización o actividades similares	3430	0.00	3450	0.00	13	\N	2025-12-16 22:44:37.793413+00
15	4	(Energía Eléctrica y régimen RIMPE - Emprendedores, para este caso aplica con cualquier forma de pago inclusive los	343	6.52	393	0.07	14	\N	2025-12-16 22:44:37.793413+00
16	4	(incluye Pago local tarjeta de crédito /débito reportada por la Emisora de tarjeta de crédito / entidades del sistema	344	0.00	394	0.00	15	\N	2025-12-16 22:44:37.793413+00
17	4	POR REGALIAS, COMISIONES, ARRENDAMIENTOS Y OTROS\nPor regalías, derechos de autor, marcas, patentes y similares	314	0.00	364	0.00	16	\N	2025-12-16 22:44:37.793413+00
18	4	Comisiones pagadas a sociedades, nacionales o extranjeras residentes en el Ecuador y establecimientos permanentes domiciliados en el país	3140	0.00	3640	0.00	17	\N	2025-12-16 22:44:37.793413+00
19	4	Arrendamiento\n.Mercantil	319	0.00	369	0.00	18	\N	2025-12-16 22:44:37.793413+00
20	4	.Bienes inmuebles	320	0.00	370	0.00	19	\N	2025-12-16 22:44:37.793413+00
21	4	RELACIONADAS CON EL CAPITAL ( RENDIMIENTOS, GANANCIAS, DIVIDENDOS Y OTROS)\nRendimientos financieros	323	0.00	373	0.00	20	\N	2025-12-16 22:44:37.793413+00
22	4	Rendimientos financieros entre instituciones del sistema financiero y entidades economía popular y solidaria	324	0.00	374	0.00	21	\N	2025-12-16 22:44:37.793413+00
23	4	Ganancia en la enajenación de derechos representativos de capital u otros derechos que permitan la exploración, explotación, concesión o	333	0.00	383	0.00	22	\N	2025-12-16 22:44:37.793413+00
24	4	similares de sociedades, que se coticen en las bolsas de valores del Ecuador\nContraprestación en la enajenación de derechos representativos de capital u otros derechos que permitan la exploración, explotación, concesión o	334	0.00	384	0.00	23	\N	2025-12-16 22:44:37.793413+00
25	4	similares de sociedades, no cotizados en las bolsas de valores del Ecuador\nPOR LOTERIAS Y PREMIOS\nLoterías, rifas, apuestas, pronósticos deportivos y similares	335	0.00	385	0.00	24	\N	2025-12-16 22:44:37.793413+00
26	4	AUTORRETENCIONES Y OTRAS RETENCIONES\nVenta de combustibles\n.A comercializadoras	336	0.00	386	0.00	25	\N	2025-12-16 22:44:37.793413+00
27	4	.A distribuidores	337	0.00	387	0.00	26	\N	2025-12-16 22:44:37.793413+00
28	4	Retención a cargo del propio sujeto pasivo por la comercialización de productos forestales	3370	0.00	3870	0.00	27	\N	2025-12-16 22:44:37.793413+00
29	4	RLRTI)	350	0.00	400	0.00	28	\N	2025-12-16 22:44:37.793413+00
30	4	. Aplicables a otros porcentajes ( Por Donaciones en dinero -Impuesto a las donaciones )	346	0.00	396	0.00	29	\N	2025-12-16 22:44:37.793413+00
31	4	Impuesto a la renta único sobre los ingresos percibidos por los operadores de pronósticos deportivos	3480	0.00	3980	0.00	30	\N	2025-12-16 22:44:37.793413+00
32	4	Pagos de bienes y servicios no sujetos a retención (Código 332)	332	3684.78	N/A	0.00	31	\N	2025-12-16 22:44:37.793413+00
33	5	.\nDETALLE DE PAGOS Y RETENCIÓN POR IMPUESTO A LA RENTA\nPOR PAGOS EFECTUADOS A RESIDENTES Y ESTABLECIMIENTOS PERMANENTES\nDERIVADAS DEL TRABAJO Y SERVICIOS PRESTADOS\nBASE VALOR\nIMPONIBLE RETENIDO\nEn relación de dependencia que supera o no la base desgravada	302	7225.47	352	0.00	0	\N	2025-12-16 23:54:44.418076+00
34	5	Servicios\n.Honorarios profesionales	303	328.00	353	32.80	1	\N	2025-12-16 23:54:44.418076+00
35	5	.Servicios profesionales prestados por sociedades residentes	3030	0.00	3530	0.00	2	\N	2025-12-16 23:54:44.418076+00
36	5	.Predomina el intelecto	304	0.00	354	0.00	3	\N	2025-12-16 23:54:44.418076+00
37	5	.Predomina la mano de obra	307	0.00	357	0.00	4	\N	2025-12-16 23:54:44.418076+00
38	5	.Utilización o aprovechamiento de la imagen o renombre (personas naturales, sociedades, influencers)	308	0.00	358	0.00	5	\N	2025-12-16 23:54:44.418076+00
39	5	.Publicidad y comunicación	309	0.00	359	0.00	6	\N	2025-12-16 23:54:44.418076+00
40	5	.Transporte privado de pasajeros o servicio público o privado de carga	310	115.50	360	1.17	7	\N	2025-12-16 23:54:44.418076+00
41	5	A través de liquidaciones de compra (nivel cultural o rusticidad)	311	0.00	361	0.00	8	\N	2025-12-16 23:54:44.418076+00
42	5	POR BIENES Y SERVICIOS\nTransferencia de bienes muebles de naturaleza corporal	312	4995.59	362	87.41	9	\N	2025-12-16 23:54:44.418076+00
43	5	Seguros y reaseguros (primas y cesiones)	322	0.00	372	0.00	10	\N	2025-12-16 23:54:44.418076+00
44	5	de bienes de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuático, forestal y carnes en estado natural y	3120	0.00	3620	0.00	11	\N	2025-12-16 23:54:44.418076+00
45	5	de bienes de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuático, forestal y carnes en estado	3121	0.00	3621	0.00	12	\N	2025-12-16 23:54:44.418076+00
46	5	de LRTI.\nActividades de construcción de obra material inmueble, urbanización, lotización o actividades similares	3430	0.00	3450	0.00	13	\N	2025-12-16 23:54:44.418076+00
47	5	(Energía Eléctrica y régimen RIMPE - Emprendedores, para este caso aplica con cualquier forma de pago inclusive los	343	0.00	393	0.00	14	\N	2025-12-16 23:54:44.418076+00
48	5	(incluye Pago local tarjeta de crédito /débito reportada por la Emisora de tarjeta de crédito / entidades del sistema	344	0.00	394	0.00	15	\N	2025-12-16 23:54:44.418076+00
49	5	POR REGALIAS, COMISIONES, ARRENDAMIENTOS Y OTROS\nPor regalías, derechos de autor, marcas, patentes y similares	314	0.00	364	0.00	16	\N	2025-12-16 23:54:44.418076+00
50	5	Comisiones pagadas a sociedades, nacionales o extranjeras residentes en el Ecuador y establecimientos permanentes domiciliados en el país	3140	0.00	3640	0.00	17	\N	2025-12-16 23:54:44.418076+00
51	5	Arrendamiento\n.Mercantil	319	0.00	369	0.00	18	\N	2025-12-16 23:54:44.418076+00
52	5	.Bienes inmuebles	320	0.00	370	0.00	19	\N	2025-12-16 23:54:44.418076+00
53	5	RELACIONADAS CON EL CAPITAL ( RENDIMIENTOS, GANANCIAS, DIVIDENDOS Y OTROS)\nRendimientos financieros	323	0.00	373	0.00	20	\N	2025-12-16 23:54:44.418076+00
54	5	Rendimientos financieros entre instituciones del sistema financiero y entidades economía popular y solidaria	324	0.00	374	0.00	21	\N	2025-12-16 23:54:44.418076+00
55	5	Ganancia en la enajenación de derechos representativos de capital u otros derechos que permitan la exploración, explotación, concesión o	333	0.00	383	0.00	22	\N	2025-12-16 23:54:44.418076+00
56	5	similares de sociedades, que se coticen en las bolsas de valores del Ecuador\nContraprestación en la enajenación de derechos representativos de capital u otros derechos que permitan la exploración, explotación, concesión o	334	0.00	384	0.00	23	\N	2025-12-16 23:54:44.418076+00
57	5	similares de sociedades, no cotizados en las bolsas de valores del Ecuador\nPOR LOTERIAS Y PREMIOS\nLoterías, rifas, apuestas, pronósticos deportivos y similares	335	0.00	385	0.00	24	\N	2025-12-16 23:54:44.418076+00
58	5	AUTORRETENCIONES Y OTRAS RETENCIONES\nVenta de combustibles\n.A comercializadoras	336	0.00	386	0.00	25	\N	2025-12-16 23:54:44.418076+00
59	5	.A distribuidores	337	0.00	387	0.00	26	\N	2025-12-16 23:54:44.418076+00
60	5	Retención a cargo del propio sujeto pasivo por la comercialización de productos forestales	3370	0.00	3870	0.00	27	\N	2025-12-16 23:54:44.418076+00
61	5	RLRTI)	350	0.00	400	0.00	28	\N	2025-12-16 23:54:44.418076+00
62	5	. Aplicables a otros porcentajes ( Por Donaciones en dinero -Impuesto a las donaciones )	346	0.00	396	0.00	29	\N	2025-12-16 23:54:44.418076+00
63	5	Impuesto a la renta único sobre los ingresos percibidos por los operadores de pronósticos deportivos	3480	0.00	3980	0.00	30	\N	2025-12-16 23:54:44.418076+00
64	5	Pagos de bienes y servicios no sujetos a retención (Código 332)	332	2660.48	N/A	0.00	31	\N	2025-12-16 23:54:44.418076+00
65	6	Honorarios profesionales	303	300.00	353	30.00	0	\N	2025-12-17 01:27:44.718372+00
66	6	Servicios profesionales prestados por sociedades residentes	3030	0.00	3530	0.00	1	\N	2025-12-17 01:27:44.718372+00
67	6	Predomina el intelecto	304	0.00	354	0.00	2	\N	2025-12-17 01:27:44.718372+00
68	6	Predomina la mano de obra	307	0.00	357	0.00	3	\N	2025-12-17 01:27:44.718372+00
69	6	Utilización o aprovechamiento de la imagen o renombre (personas naturales, sociedades, influencers)	308	0.00	358	0.00	4	\N	2025-12-17 01:27:44.718372+00
70	6	Publicidad y comunicación	309	0.00	359	0.00	5	\N	2025-12-17 01:27:44.718372+00
71	6	Transporte privado de pasajeros o servicio público o privado de carga	310	118.00	360	1.18	6	\N	2025-12-17 01:27:44.718372+00
72	6	A través de liquidaciones de compra (nivel cultural o rusticidad)	311	0.00	361	0.00	7	\N	2025-12-17 01:27:44.718372+00
73	6	POR BIENES Y SERVICIOS\nTransferencia de bienes muebles de naturaleza corporal	312	11141.32	362	194.98	8	\N	2025-12-17 01:27:44.718372+00
74	6	Seguros y reaseguros (primas y cesiones)	322	0.00	372	0.00	9	\N	2025-12-17 01:27:44.718372+00
75	6	de bienes de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuático, forestal y carnes	3120	0.00	3620	0.00	10	\N	2025-12-17 01:27:44.718372+00
76	6	de bienes de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuático, forestal y	3121	0.00	3621	0.00	11	\N	2025-12-17 01:27:44.718372+00
77	6	de LRTI.\nActividades de construcción de obra material inmueble, urbanización, lotización o actividades similares	3430	0.00	3450	0.00	12	\N	2025-12-17 01:27:44.718372+00
78	6	(Energía Eléctrica y régimen RIMPE - Emprendedores, para este caso aplica con cualquier forma de	343	0.00	393	0.00	13	\N	2025-12-17 01:27:44.718372+00
79	6	(incluye Pago local tarjeta de crédito /débito reportada por la Emisora de tarjeta de crédito / entidades	344	0.00	394	0.00	14	\N	2025-12-17 01:27:44.718372+00
80	6	POR REGALIAS, COMISIONES, ARRENDAMIENTOS Y OTROS\nPor regalías, derechos de autor, marcas, patentes y similares	314	0.00	364	0.00	15	\N	2025-12-17 01:27:44.718372+00
81	6	Comisiones pagadas a sociedades, nacionales o extranjeras residentes en el Ecuador y establecimientos permanentes	3140	0.00	3640	0.00	16	\N	2025-12-17 01:27:44.718372+00
82	6	Mercantil	319	0.00	369	0.00	17	\N	2025-12-17 01:27:44.718372+00
83	6	Bienes inmuebles	320	0.00	370	0.00	18	\N	2025-12-17 01:27:44.718372+00
84	6	RELACIONADAS CON EL CAPITAL (RENDIMIENTOS, GANANCIAS, DIVIDENDOS Y OTROS)\nRendimientos financieros	323	0.00	373	0.00	19	\N	2025-12-17 01:27:44.718372+00
85	6	Rendimientos financieros entre instituciones del sistema financiero y entidades economía popular y solidaria	324	0.00	374	0.00	20	\N	2025-12-17 01:27:44.718372+00
86	6	Ganancia en la enajenación de derechos representativos de capital u otros derechos que permitan la exploración, explotación,	333	0.00	383	0.00	21	\N	2025-12-17 01:27:44.718372+00
87	6	concesión o similares de sociedades, que se coticen en las bolsas de valores del Ecuador\nContraprestación en la enajenación de derechos representativos de capital u otros derechos que permitan la exploración,	334	0.00	384	0.00	22	\N	2025-12-17 01:27:44.718372+00
88	6	explotación, concesión o similares de sociedades, no cotizados en las bolsas de valores del Ecuador\nPOR LOTERIAS Y PREMIOS\nLoterías, rifas, apuestas, pronósticos deportivos y similares	335	0.00	385	0.00	23	\N	2025-12-17 01:27:44.718372+00
89	6	A comercializadoras	336	0.00	386	0.00	24	\N	2025-12-17 01:27:44.718372+00
90	6	A distribuidores	337	0.00	387	0.00	25	\N	2025-12-17 01:27:44.718372+00
91	6	Retención a cargo del propio sujeto pasivo por la comercialización de productos forestales	3370	0.00	3870	0.00	26	\N	2025-12-17 01:27:44.718372+00
92	6	RLRTI)	350	0.00	400	0.00	27	\N	2025-12-17 01:27:44.718372+00
93	6	Aplicables a otros porcentajes ( Por Donaciones en dinero -Impuesto a las donaciones )	346	0.00	396	0.00	28	\N	2025-12-17 01:27:44.718372+00
94	6	Impuesto a la renta único sobre los ingresos percibidos por los operadores de pronósticos deportivos	3480	0.00	3980	0.00	29	\N	2025-12-17 01:27:44.718372+00
95	6	Pagos de bienes y servicios no sujetos a retención (Código 332)	332	942.92	N/A	0.00	30	\N	2025-12-17 01:27:44.718372+00
\.


--
-- Data for Name: form_103_totals; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.form_103_totals (id, document_id, subtotal_operaciones_pais, subtotal_retencion, pagos_no_sujetos, otras_retenciones_base, otras_retenciones_retenido, total_retencion, total_impuesto_pagar, interes_mora, multa, total_pagado, created_at, updated_at) FROM stdin;
1	4	22529.42	242.25	3684.78	233.91	6.44	242.25	242.25	0.00	0.00	242.25	2025-12-16 22:44:37.793413+00	2025-12-16 22:44:37.793413+00
2	5	15501.95	126.25	2660.48	176.91	4.87	126.25	126.25	0.00	0.00	126.25	2025-12-16 23:54:44.418076+00	2025-12-16 23:54:44.418076+00
3	6	20265.62	240.95	942.92	537.91	14.79	240.95	240.95	0.00	0.00	240.95	2025-12-17 01:27:44.718372+00	2025-12-17 01:27:44.718372+00
\.


--
-- Data for Name: form_104_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.form_104_data (id, document_id, razon_social, ruc, period, periodo_fiscal, formulario_num, num_formulario_que_sustituye, ventas_tarifa_0, ventas_tarifa_12, ventas_tarifa_15, ventas_no_objeto_iva, ventas_exentas, compras_tarifa_0, compras_tarifa_12, compras_tarifa_15, compras_no_objeto_iva, impuesto_causado, credito_tributario, iva_a_pagar, saldo_favor_contribuyente, total_ventas, total_compras, diferencia, exportaciones_bienes, exportaciones_servicios, total_impuesto_generado, total_impuesto_pagado, saldo_total, raw_data, user_id, session_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: guest_sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.guest_sessions (id, session_id, document_count, created_at, last_activity, expires_at, ip_address, user_agent) FROM stdin;
1	eec959b3-c70d-45fe-9e95-c213bedb3928	0	2025-12-16 22:13:38.429339+00	2025-12-16 22:13:38.429339+00	\N	127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15
\.


--
-- Data for Name: temporary_files; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.temporary_files (id, session_id, file_path, document_id, created_at, expires_at, file_size) FROM stdin;
1	2dd5953c-7858-423a-92d7-676e616f5a5d	./uploads/555c9ffe51ab425d8b9589573bd2491c.pdf	\N	2025-12-17 01:19:54.231892+00	2025-12-18 06:19:54.394179+00	149930
2	2dd5953c-7858-423a-92d7-676e616f5a5d	./uploads/0edf67147aca46ca84b4d2e718c7785a.pdf	\N	2025-12-17 01:24:00.253161+00	2025-12-18 06:24:00.408719+00	149930
3	2dd5953c-7858-423a-92d7-676e616f5a5d	./uploads/fa9e822f373741eea7205163faa39f83.pdf	\N	2025-12-17 01:27:44.892156+00	2025-12-18 06:27:44.904071+00	148451
4	2dd5953c-7858-423a-92d7-676e616f5a5d	./uploads/02a4b894818347dd9bf8c1856caabd76.pdf	\N	2025-12-17 01:27:44.983629+00	2025-12-18 06:27:44.987457+00	149912
5	2dd5953c-7858-423a-92d7-676e616f5a5d	./uploads/bddb4e10550a40ae9b1dfb7e1f6a4524.pdf	\N	2025-12-17 01:27:45.093664+00	2025-12-18 06:27:45.095841+00	149930
\.


--
-- Data for Name: usage_analytics; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usage_analytics (id, user_id, session_id, metadata, created_at, event_type, event_data) FROM stdin;
2	\N	2dd5953c-7858-423a-92d7-676e616f5a5d	\N	2025-12-17 01:27:44.905932+00	guest_upload	{"filename": "103 DECLARACION RETENCION FUENTE OCTUBRE.pdf", "document_id": 6, "is_duplicate": false}
3	\N	2dd5953c-7858-423a-92d7-676e616f5a5d	\N	2025-12-17 01:27:44.988679+00	guest_upload	{"filename": "103 DECLARACION RETENCIONES AGOSTO.pdf", "document_id": 5, "is_duplicate": true}
4	\N	2dd5953c-7858-423a-92d7-676e616f5a5d	\N	2025-12-17 01:27:45.096696+00	guest_upload	{"filename": "103 DECLARACION RETENCIONES JULIO.pdf", "document_id": 4, "is_duplicate": true}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, email, hashed_password, is_superuser, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Name: analytics_events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.analytics_events_id_seq', 1, false);


--
-- Name: documents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.documents_id_seq', 8, true);


--
-- Name: form_103_data_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.form_103_data_id_seq', 1, false);


--
-- Name: form_103_line_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.form_103_line_items_id_seq', 95, true);


--
-- Name: form_103_totals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.form_103_totals_id_seq', 3, true);


--
-- Name: form_104_data_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.form_104_data_id_seq', 1, false);


--
-- Name: guest_sessions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.guest_sessions_id_seq', 1, true);


--
-- Name: temporary_files_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.temporary_files_id_seq', 5, true);


--
-- Name: usage_analytics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usage_analytics_id_seq', 4, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 1, false);


--
-- Name: analytics_events analytics_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.analytics_events
    ADD CONSTRAINT analytics_events_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: form_103_data form_103_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.form_103_data
    ADD CONSTRAINT form_103_data_pkey PRIMARY KEY (id);


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
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: idx_analytics_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_analytics_created_at ON public.analytics_events USING btree (created_at);


--
-- Name: idx_analytics_event_data; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_analytics_event_data ON public.analytics_events USING gin (event_data);


--
-- Name: idx_analytics_event_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_analytics_event_type ON public.analytics_events USING btree (event_type);


--
-- Name: idx_analytics_session_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_analytics_session_id ON public.analytics_events USING btree (session_id);


--
-- Name: idx_analytics_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_analytics_user_id ON public.analytics_events USING btree (user_id);


--
-- Name: idx_documents_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_documents_created_at ON public.documents USING btree (created_at);


--
-- Name: idx_documents_form_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_documents_form_type ON public.documents USING btree (form_type);


--
-- Name: idx_documents_period; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_documents_period ON public.documents USING btree (period);


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
-- Name: idx_documents_ruc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_documents_ruc ON public.documents USING btree (ruc);


--
-- Name: idx_documents_session_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_documents_session_id ON public.documents USING btree (session_id);


--
-- Name: idx_documents_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_documents_status ON public.documents USING btree (status);


--
-- Name: idx_documents_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_documents_user_id ON public.documents USING btree (user_id);


--
-- Name: idx_form_103_document_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_form_103_document_id ON public.form_103_data USING btree (document_id);


--
-- Name: idx_form_103_line_items_document_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_form_103_line_items_document_id ON public.form_103_line_items USING btree (document_id);


--
-- Name: idx_form_103_line_items_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_form_103_line_items_user_id ON public.form_103_line_items USING btree (user_id);


--
-- Name: idx_form_103_period; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_form_103_period ON public.form_103_data USING btree (period);


--
-- Name: idx_form_103_raw_data; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_form_103_raw_data ON public.form_103_data USING gin (raw_data);


--
-- Name: idx_form_103_razon_social; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_form_103_razon_social ON public.form_103_data USING btree (razon_social);


--
-- Name: idx_form_103_ruc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_form_103_ruc ON public.form_103_data USING btree (ruc);


--
-- Name: idx_form_103_session_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_form_103_session_id ON public.form_103_data USING btree (session_id);


--
-- Name: idx_form_103_totals_document_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_form_103_totals_document_id ON public.form_103_totals USING btree (document_id);


--
-- Name: idx_form_103_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_form_103_user_id ON public.form_103_data USING btree (user_id);


--
-- Name: idx_form_104_data_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_form_104_data_user_id ON public.form_104_data USING btree (user_id);


--
-- Name: idx_form_104_document_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_form_104_document_id ON public.form_104_data USING btree (document_id);


--
-- Name: idx_form_104_period; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_form_104_period ON public.form_104_data USING btree (period);


--
-- Name: idx_form_104_raw_data; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_form_104_raw_data ON public.form_104_data USING gin (raw_data);


--
-- Name: idx_form_104_razon_social; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_form_104_razon_social ON public.form_104_data USING btree (razon_social);


--
-- Name: idx_form_104_ruc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_form_104_ruc ON public.form_104_data USING btree (ruc);


--
-- Name: idx_form_104_session_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_form_104_session_id ON public.form_104_data USING btree (session_id);


--
-- Name: idx_form_104_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_form_104_user_id ON public.form_104_data USING btree (user_id);


--
-- Name: idx_guest_sessions_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_guest_sessions_created_at ON public.guest_sessions USING btree (created_at);


--
-- Name: idx_guest_sessions_expires_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_guest_sessions_expires_at ON public.guest_sessions USING btree (expires_at);


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
-- Name: idx_temporary_files_document_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_temporary_files_document_id ON public.temporary_files USING btree (document_id);


--
-- Name: idx_temporary_files_expires_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_temporary_files_expires_at ON public.temporary_files USING btree (expires_at);


--
-- Name: idx_temporary_files_session_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_temporary_files_session_id ON public.temporary_files USING btree (session_id);


--
-- Name: idx_usage_analytics_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_usage_analytics_created_at ON public.usage_analytics USING btree (created_at);


--
-- Name: idx_usage_analytics_session_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_usage_analytics_session_id ON public.usage_analytics USING btree (session_id);


--
-- Name: idx_usage_analytics_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_usage_analytics_user_id ON public.usage_analytics USING btree (user_id);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- Name: idx_users_is_superuser; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_is_superuser ON public.users USING btree (is_superuser);


--
-- Name: idx_users_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_username ON public.users USING btree (username);


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
-- Name: ix_users_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_users_id ON public.users USING btree (id);


--
-- Name: ix_users_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_users_username ON public.users USING btree (username);


--
-- Name: analytics_events analytics_events_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.analytics_events
    ADD CONSTRAINT analytics_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: documents documents_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


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
-- Name: form_103_data form_103_data_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.form_103_data
    ADD CONSTRAINT form_103_data_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.documents(id) ON DELETE CASCADE;


--
-- Name: form_103_data form_103_data_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.form_103_data
    ADD CONSTRAINT form_103_data_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: form_103_line_items form_103_line_items_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.form_103_line_items
    ADD CONSTRAINT form_103_line_items_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.documents(id) ON DELETE CASCADE;


--
-- Name: form_103_line_items form_103_line_items_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.form_103_line_items
    ADD CONSTRAINT form_103_line_items_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


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
-- Name: form_104_data form_104_data_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.form_104_data
    ADD CONSTRAINT form_104_data_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: temporary_files temporary_files_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.temporary_files
    ADD CONSTRAINT temporary_files_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.documents(id) ON DELETE CASCADE;


--
-- Name: usage_analytics usage_analytics_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usage_analytics
    ADD CONSTRAINT usage_analytics_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict brTTQU2LA57bb91ZrA7tQ0DQJEkuJcbev7ZcdcXLZSlbb49eTvUOqw7IaYBT8cc

