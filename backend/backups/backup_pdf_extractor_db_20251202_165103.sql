--
-- PostgreSQL database dump
--

\restrict OHWrVRsU7LCteyJm91i4gWtLYcX1nmDucV5ZJbGEKR2QtsUFnk1IobcPaPOBigt

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
    periodo_mes_numero integer
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
    order_index integer NOT NULL
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
    multa double precision DEFAULT 0.0
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
    reset_token_expires timestamp with time zone
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
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: documents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.documents (id, filename, original_filename, file_path, file_size, form_type, extracted_text, total_pages, total_characters, parsed_data, codigo_verificador, numero_serial, fecha_recaudacion, identificacion_ruc, razon_social, periodo_mes, periodo_anio, processing_status, processing_error, uploaded_at, processed_at, periodo_fiscal_completo, periodo_mes_numero) FROM stdin;
204	510eb1a18c134c9cbce5a0af7d9262fe.pdf	103 DECLARACION MARZO.pdf	./uploads\\510eb1a18c134c9cbce5a0af7d9262fe.pdf	149464	FORM_103	Obligación Tributaria: 1031 - DECLARACIÓN DE RETENCIONES EN LA FUENTE\nIdentificación: 1792234026001 Razón Social: GAMA EDITORES REYES MEDINA CIA. LTDA.\nPeríodo Fiscal: MARZO 2025 Tipo Declaración: ORIGINAL\nFormulario Sustituye:\n.\nDETALLE DE PAGOS Y RETENCIÓN POR IMPUESTO A LA RENTA\nPOR PAGOS EFECTUADOS A RESIDENTES Y ESTABLECIMIENTOS PERMANENTES\nDERIVADAS DEL TRABAJO Y SERVICIOS PRESTADOS\nBASE VALOR\nIMPONIBLE RETENIDO\nEn relación de dependencia que supera o no la base desgravada 302 7740.21 352 0.00\nServicios\n.Honorarios profesionales 303 300.00 353 30.00\n.Servicios profesionales prestados por sociedades residentes 3030 0.00 3530 0.00\n.Predomina el intelecto 304 0.00 354 0.00\n.Predomina la mano de obra 307 0.00 357 0.00\n.Utilización o aprovechamiento de la imagen o renombre (personas naturales, sociedades, influencers) 308 0.00 358 0.00\n.Publicidad y comunicación 309 0.00 359 0.00\n.Transporte privado de pasajeros o servicio público o privado de carga 310 42.50 360 0.43\nA través de liquidaciones de compra (nivel cultural o rusticidad) 311 0.00 361 0.00\nPOR BIENES Y SERVICIOS\nTransferencia de bienes muebles de naturaleza corporal 312 26938.06 362 471.42\nSeguros y reaseguros (primas y cesiones) 322 0.00 372 0.00\nCOMPRAS AL PRODUCTOR: de bienes de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuático, forestal y carnes en estado natural y 3120 0.00 3620 0.00\nlos descritos en el art.27.1 de LRTI.\nLa información reposa en la base de datos del SRI, conforme la declaraciónrealizada por el contribuyente\nCÓDIGO VERIFICADOR NÚMERO SERIAL FECHA RECAUDACIÓN PÁGINA\nSRIDEC2025127625296 872820582771 08-04-2025 1\nCOMPRAS AL COMERCIALIZADOR: de bienes de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuático, forestal y carnes en estado 3121 0.00 3621 0.00\nnatural y los descritos en el art.27.1 de LRTI.\nActividades de construcción de obra material inmueble, urbanización, lotización o actividades similares 3430 0.00 3450 0.00\nPagos aplicables el 1% (Energía Eléctrica y régimen RIMPE - Emprendedores, para este caso aplica con cualquier forma de pago inclusive los 343 6.74 393 0.07\npagos que deban realizar las tarjetas de crédito/débito)\nPagos aplicables el 2% (incluye Pago local tarjeta de crédito /débito reportada por la Emisora de tarjeta de crédito / entidades del sistema 344 0.00 394 0.00\nfinanciero; adquisición de sustancias minerales dentro del territorio nacional; Recepción de botellas plásticas no retornables de PET)\nPagos de bienes y servicios no sujetos a retención o con 0% (distintos de rendimientos financieros) 332 6539.43\nPOR REGALIAS, COMISIONES, ARRENDAMIENTOS Y OTROS\nPor regalías, derechos de autor, marcas, patentes y similares 314 0.00 364 0.00\nComisiones pagadas a sociedades, nacionales o extranjeras residentes en el Ecuador y establecimientos permanentes domiciliados en el país 3140 0.00 3640 0.00\nArrendamiento\n.Mercantil 319 0.00 369 0.00\n.Bienes inmuebles 320 0.00 370 0.00\nRELACIONADAS CON EL CAPITAL ( RENDIMIENTOS, GANANCIAS, DIVIDENDOS Y OTROS)\nRendimientos financieros 323 0.00 373 0.00\nRendimientos financieros entre instituciones del sistema financiero y entidades economía popular y solidaria 324 0.00 374 0.00\nOtros Rendimientos financieros 0% 3230 0.00\nGanancia en la enajenación de derechos representativos de capital u otros derechos que permitan la exploración, explotación, concesión o 333 0.00 383 0.00\nsimilares de sociedades, que se coticen en las bolsas de valores del Ecuador\nContraprestación en la enajenación de derechos representativos de capital u otros derechos que permitan la exploración, explotación, concesión o 334 0.00 384 0.00\nsimilares de sociedades, no cotizados en las bolsas de valores del Ecuador\nPOR LOTERIAS Y PREMIOS\nLoterías, rifas, apuestas, pronósticos deportivos y similares 335 0.00 385 0.00\nAUTORRETENCIONES Y OTRAS RETENCIONES\nVenta de combustibles\n.A comercializadoras 336 0.00 386 0.00\n.A distribuidores 337 0.00 387 0.00\nRetención a cargo del propio sujeto pasivo por la comercialización de productos forestales 3370 0.00 3870 0.00\nOtras autorretenciones (inciso 1 y 2 Art.92.1 RLRTI) 350 0.00 400 0.00\nOtras retenciones\nLa información reposa en la base de datos del SRI, conforme la declaraciónrealizada por el contribuyente\nCÓDIGO VERIFICADOR NÚMERO SERIAL FECHA RECAUDACIÓN PÁGINA\nSRIDEC2025127625296 872820582771 08-04-2025 2\n. Aplicables el 2,75% 3440 165.91 3940 4.56\n. Aplicables a otros porcentajes ( Por Donaciones en dinero -Impuesto a las donaciones ) 346 0.00 396 0.00\nSUBTOTAL OPERACIONES EFECTUADAS EN EL PAÍS 349 41732.85 399 506.48\nBASE VALOR\nIMPONIBLE RETENIDO\nTOTAL DE RETENCIÓN DE IMPUESTO A LA RENTA 399 + 498 499 506.48\n.\nVALORES A PAGAR (luego de imputación al pago)\nTOTAL IMPUESTO A PAGAR 499 - 898 902 506.48\nInterés por mora 903 0.00\nMulta 904 0.00\nTOTAL PAGADO 999 506.48\nLa información reposa en la base de datos del SRI, conforme la declaraciónrealizada por el contribuyente\nCÓDIGO VERIFICADOR NÚMERO SERIAL FECHA RECAUDACIÓN PÁGINA\nSRIDEC2025127625296 872820582771 08-04-2025 3	3	5033	{"form_type": "form_103", "header": {"codigo_verificador": "N", "obligacion_tributaria": "1031 - DECLARACI\\u00d3N DE RETENCIONES EN LA FUENTE\\nIdentificaci\\u00f3n", "identificacion": "1792234026001", "razon_social": "GAMA EDITORES REYES MEDINA CIA. LTDA.", "periodo_mes": "MARZO", "periodo_anio": "2025", "tipo_declaracion": "ORIGINAL"}, "line_items": [{"concepto": ".\\nDETALLE DE PAGOS Y RETENCI\\u00d3N POR IMPUESTO A LA RENTA\\nPOR PAGOS EFECTUADOS A RESIDENTES Y ESTABLECIMIENTOS PERMANENTES\\nDERIVADAS DEL TRABAJO Y SERVICIOS PRESTADOS\\nBASE VALOR\\nIMPONIBLE RETENIDO\\nEn relaci\\u00f3n de dependencia que supera o no la base desgravada", "codigo_base": "302", "base_imponible": 7740.21, "codigo_retencion": "352", "valor_retenido": 0.0}, {"concepto": "Servicios\\n.Honorarios profesionales", "codigo_base": "303", "base_imponible": 300.0, "codigo_retencion": "353", "valor_retenido": 30.0}, {"concepto": ".Servicios profesionales prestados por sociedades residentes", "codigo_base": "3030", "base_imponible": 0.0, "codigo_retencion": "3530", "valor_retenido": 0.0}, {"concepto": ".Predomina el intelecto", "codigo_base": "304", "base_imponible": 0.0, "codigo_retencion": "354", "valor_retenido": 0.0}, {"concepto": ".Predomina la mano de obra", "codigo_base": "307", "base_imponible": 0.0, "codigo_retencion": "357", "valor_retenido": 0.0}, {"concepto": ".Utilizaci\\u00f3n o aprovechamiento de la imagen o renombre (personas naturales, sociedades, influencers)", "codigo_base": "308", "base_imponible": 0.0, "codigo_retencion": "358", "valor_retenido": 0.0}, {"concepto": ".Publicidad y comunicaci\\u00f3n", "codigo_base": "309", "base_imponible": 0.0, "codigo_retencion": "359", "valor_retenido": 0.0}, {"concepto": ".Transporte privado de pasajeros o servicio p\\u00fablico o privado de carga", "codigo_base": "310", "base_imponible": 42.5, "codigo_retencion": "360", "valor_retenido": 0.43}, {"concepto": "A trav\\u00e9s de liquidaciones de compra (nivel cultural o rusticidad)", "codigo_base": "311", "base_imponible": 0.0, "codigo_retencion": "361", "valor_retenido": 0.0}, {"concepto": "POR BIENES Y SERVICIOS\\nTransferencia de bienes muebles de naturaleza corporal", "codigo_base": "312", "base_imponible": 26938.06, "codigo_retencion": "362", "valor_retenido": 471.42}, {"concepto": "Seguros y reaseguros (primas y cesiones)", "codigo_base": "322", "base_imponible": 0.0, "codigo_retencion": "372", "valor_retenido": 0.0}, {"concepto": "de bienes de origen agr\\u00edcola, av\\u00edcola, pecuario, ap\\u00edcola, cun\\u00edcola, bioacu\\u00e1tico, forestal y carnes en estado natural y", "codigo_base": "3120", "base_imponible": 0.0, "codigo_retencion": "3620", "valor_retenido": 0.0}, {"concepto": "de bienes de origen agr\\u00edcola, av\\u00edcola, pecuario, ap\\u00edcola, cun\\u00edcola, bioacu\\u00e1tico, forestal y carnes en estado", "codigo_base": "3121", "base_imponible": 0.0, "codigo_retencion": "3621", "valor_retenido": 0.0}, {"concepto": "de LRTI.\\nActividades de construcci\\u00f3n de obra material inmueble, urbanizaci\\u00f3n, lotizaci\\u00f3n o actividades similares", "codigo_base": "3430", "base_imponible": 0.0, "codigo_retencion": "3450", "valor_retenido": 0.0}, {"concepto": "(Energ\\u00eda El\\u00e9ctrica y r\\u00e9gimen RIMPE - Emprendedores, para este caso aplica con cualquier forma de pago inclusive los", "codigo_base": "343", "base_imponible": 6.74, "codigo_retencion": "393", "valor_retenido": 0.07}, {"concepto": "(incluye Pago local tarjeta de cr\\u00e9dito /d\\u00e9bito reportada por la Emisora de tarjeta de cr\\u00e9dito / entidades del sistema", "codigo_base": "344", "base_imponible": 0.0, "codigo_retencion": "394", "valor_retenido": 0.0}, {"concepto": "POR REGALIAS, COMISIONES, ARRENDAMIENTOS Y OTROS\\nPor regal\\u00edas, derechos de autor, marcas, patentes y similares", "codigo_base": "314", "base_imponible": 0.0, "codigo_retencion": "364", "valor_retenido": 0.0}, {"concepto": "Comisiones pagadas a sociedades, nacionales o extranjeras residentes en el Ecuador y establecimientos permanentes domiciliados en el pa\\u00eds", "codigo_base": "3140", "base_imponible": 0.0, "codigo_retencion": "3640", "valor_retenido": 0.0}, {"concepto": "Arrendamiento\\n.Mercantil", "codigo_base": "319", "base_imponible": 0.0, "codigo_retencion": "369", "valor_retenido": 0.0}, {"concepto": ".Bienes inmuebles", "codigo_base": "320", "base_imponible": 0.0, "codigo_retencion": "370", "valor_retenido": 0.0}, {"concepto": "RELACIONADAS CON EL CAPITAL ( RENDIMIENTOS, GANANCIAS, DIVIDENDOS Y OTROS)\\nRendimientos financieros", "codigo_base": "323", "base_imponible": 0.0, "codigo_retencion": "373", "valor_retenido": 0.0}, {"concepto": "Rendimientos financieros entre instituciones del sistema financiero y entidades econom\\u00eda popular y solidaria", "codigo_base": "324", "base_imponible": 0.0, "codigo_retencion": "374", "valor_retenido": 0.0}, {"concepto": "Ganancia en la enajenaci\\u00f3n de derechos representativos de capital u otros derechos que permitan la exploraci\\u00f3n, explotaci\\u00f3n, concesi\\u00f3n o", "codigo_base": "333", "base_imponible": 0.0, "codigo_retencion": "383", "valor_retenido": 0.0}, {"concepto": "similares de sociedades, que se coticen en las bolsas de valores del Ecuador\\nContraprestaci\\u00f3n en la enajenaci\\u00f3n de derechos representativos de capital u otros derechos que permitan la exploraci\\u00f3n, explotaci\\u00f3n, concesi\\u00f3n o", "codigo_base": "334", "base_imponible": 0.0, "codigo_retencion": "384", "valor_retenido": 0.0}, {"concepto": "similares de sociedades, no cotizados en las bolsas de valores del Ecuador\\nPOR LOTERIAS Y PREMIOS\\nLoter\\u00edas, rifas, apuestas, pron\\u00f3sticos deportivos y similares", "codigo_base": "335", "base_imponible": 0.0, "codigo_retencion": "385", "valor_retenido": 0.0}, {"concepto": "AUTORRETENCIONES Y OTRAS RETENCIONES\\nVenta de combustibles\\n.A comercializadoras", "codigo_base": "336", "base_imponible": 0.0, "codigo_retencion": "386", "valor_retenido": 0.0}, {"concepto": ".A distribuidores", "codigo_base": "337", "base_imponible": 0.0, "codigo_retencion": "387", "valor_retenido": 0.0}, {"concepto": "Retenci\\u00f3n a cargo del propio sujeto pasivo por la comercializaci\\u00f3n de productos forestales", "codigo_base": "3370", "base_imponible": 0.0, "codigo_retencion": "3870", "valor_retenido": 0.0}, {"concepto": "RLRTI)", "codigo_base": "350", "base_imponible": 0.0, "codigo_retencion": "400", "valor_retenido": 0.0}, {"concepto": ". Aplicables a otros porcentajes ( Por Donaciones en dinero -Impuesto a las donaciones )", "codigo_base": "346", "base_imponible": 0.0, "codigo_retencion": "396", "valor_retenido": 0.0}, {"concepto": "Pagos de bienes y servicios no sujetos a retenci\\u00f3n (C\\u00f3digo 332)", "codigo_base": "332", "base_imponible": 6539.43, "codigo_retencion": "N/A", "valor_retenido": 0.0}], "totals": {"subtotal_operaciones_pais": 41732.85, "subtotal_retencion": 506.48, "pagos_no_sujetos": 6539.43, "otras_retenciones_base": 165.91, "otras_retenciones_retenido": 4.56, "total_retencion": 506.48, "total_impuesto_pagar": 506.48, "interes_mora": 0.0, "multa": 0.0, "total_pagado": 506.48}}	\N	\N	\N	1792234026001	GAMA EDITORES REYES MEDINA CIA. LTDA.	MARZO	2025	COMPLETED	\N	2025-12-01 17:19:21.769686+00	2025-12-01 22:19:21.754168+00	MARZO 2025	3
205	59b8a3ba305942f097526c5c7775ce47.pdf	104 DECLARACION MARZO.pdf	./uploads\\59b8a3ba305942f097526c5c7775ce47.pdf	154328	FORM_104	Obligación Tributaria: 2011 DECLARACION DE IVA\nIdentificación: 1792234026001 Razón Social: GAMA EDITORES REYES MEDINA CIA. LTDA.\nPeríodo Fiscal: MARZO 2025 Tipo Declaración: ORIGINAL\nFormulario Sustituye:\nTARIFA VARIABLE DE IVA\nPARA ACTIVIDADES\nTURÍSTICAS\nVENTAS\nRESUMEN DE VENTAS Y OTRAS OPERACIONES DEL PERÍODO QUE DECLARA VALOR BRUTO VALOR NETO IMPUESTO\nGENERADO\n. (VALOR BRUTO - N/C) .\nVentas locales (excluye activos fijos) gravadas tarifa diferente de cero 401 20362.68 411 20362.68 421 3054.40\nIVA generado en la diferencia entre ventas y notas de crédito con distinta tarifa (ajuste a pagar) . 423 0.00\nIVA generado en la diferencia entre ventas y notas de crédito con distinta tarifa (ajuste a favor) . 424 0.00\nVentas locales (excluye activos fijos) gravadas tarifa 0% que no dan derecho a crédito tributario 403 0.00 413 0.00 .\nVentas locales (excluye activos fijos) gravadas tarifa 0% que dan derecho a crédito tributario 405 0.00 415 0.00 .\nTOTAL VENTAS Y OTRAS OPERACIONES 409 20362.68 419 20362.68 429 3054.40\nTransferencias de bienes y prestación de servicios no objeto o exentos de IVA 431 0.00 441 0.00 .\nIngresos por reembolso como intermediario / valores facturados por operadoras de transporte / ingresos 434 0.00 444 0.00 454 0.00\nobtenidos por parte de las sociedades de gestión colectiva como intermediarios (informativo)\n.\nLIQUIDACIÓN DEL IVA EN EL MES\nTotal impuesto generado (trasládese campo 429) 482 3054.40\nImpuesto a liquidar del mes anterior (verificar que el valor corresponda al campo 485 por 483 0.00\nventas a crédito de periodos anteriores)\nLa información reposa en la base de datos del SRI, conforme la declaraciónrealizada por el contribuyente\nCÓDIGO VERIFICADOR NÚMERO SERIAL FECHA RECAUDACIÓN PÁGINA\nSRIDEC2025127625752 872820587210 08-04-2025 1\nImpuesto a liquidar en este mes 484 3054.40\nMes a pagar el monto de IVA diferente de cero por ventas a crédito de este mes 486 0\nTamaño COPCI 487 No aplica\nTOTAL IMPUESTO A LIQUIDAR EN ESTE MES 483+484 499 3054.40\nRESUMEN DE ADQUISICIONES Y PAGOS DEL PERÍODO QUE DECLARA VALOR BRUTO VALOR NETO IMPUESTO\nGENERADO\n. (VALOR BRUTO - N/C) .\nAdquisiciones y pagos (excluye activos fijos) gravados tarifa diferente de cero (con derecho a crédito tributario) 500 10473.22 510 10282.50 520 1542.38\nOtras adquisiciones y pagos gravados tarifa diferente de cero (sin derecho a crédito tributario) 502 0.00 512 0.00 522 0.00\nIVA generado en la diferencia entre adquisiciones y notas de crédito con distinta tarifa (ajuste en positivo al . 526 0.00\ncrédito tributario)\nIVA generado en la diferencia entre adquisiciones y notas de crédito con distinta tarifa (ajuste en negativo al . 527 0.00\ncrédito tributario)\nAdquisiciones y pagos (incluye activos fijos) gravados tarifa 0% 507 18176.62 517 18176.62 .\nAdquisiciones realizadas a contribuyentes RISE (hasta diciembre 2021), NEGOCIOS POPULARES (desde 508 5342.80 518 5342.80 .\nenero 2022)\nTOTAL ADQUISICIONES Y PAGOS 509 33992.64 519 33801.92 529 1542.38\nAdquisiciones no objeto de IVA 531 0.00 541 0.00 .\nAdquisiciones exentas del pago de IVA 532 0.00 542 0.00 .\nPagos netos por reembolso como intermediario / valores facturados por socios a operadoras de transporte / 535 0.00 545 0.00 555 0.00\npagos realizados por parte de las sociedades de gestión colectiva como intermediarios (informativo)\n.\nFactor de proporcionalidad para crédito tributario (411+412+420+435+415+416+417+418) / 419 563 1.0000\nCrédito tributario aplicable en este período (de acuerdo al factor de proporcionalidad o a su contabilidad) (520+521+534+560+523+524+525+526-527) x 563 564 1542.38\nValor de IVA no considerado como crédito tributario por factor de proporcionalidad 565 0.00\n.\nRESUMEN IMPOSITIVO: AGENTE DE PERCEPCIÓN DEL IMPUESTO AL VALOR AGREGADO\nImpuesto causado (si la diferencia de los campos 499-564 es mayor que cero) 601 1512.02\nCrédito tributario aplicable en este período (si la diferencia de los campos 499-564 es menor que cero) 602 0.00\n(-) Compensación de IVA por ventas efectuadas con medio electrónico y/o IVA devuelto o descontado por transacciones realizadas con personas adultas mayores o 603 0.00\npersonas con discapacidad\n(-) Saldo crédito tributario del mes anterior\nLa información reposa en la base de datos del SRI, conforme la declaraciónrealizada por el contribuyente\nCÓDIGO VERIFICADOR NÚMERO SERIAL FECHA RECAUDACIÓN PÁGINA\nSRIDEC2025127625752 872820587210 08-04-2025 2\n. Por adquisiciones e importaciones (trasládese el campo 615 de la declaración del período 605 0.00\nanterior)\n. Por retenciones en la fuente de IVA que le han sido efectuadas (trasládese el campo 617 de la declaración del período 606 0.00\nanterior)\n. Por compensación de IVA por ventas efectuadas con medio (trasládese el campo 618 de la declaración del período 607 0.00\nelectrónico anterior)\n. Por compensación de IVA por ventas efectuadas en zonas afectadas (trasládese el campo 619 de la declaración del período 608 0.00\n- Ley de solidaridad, restitución de crédito tributario en resoluciones anterior)\nadministrativas o sentencias judiciales de última instancia\n(-) Retenciones en la fuente de IVA que le han sido efectuadas en este período 609 829.10\n(-) IVA devuelto o descontado por transacciones realizadas con personas adultas mayores o personas con discapacidad 622 0.00\n(+) Ajuste por IVA devuelto o descontado por adquisiciones efectuadas con medio electrónico 610 0.00\n(+) Ajuste por IVA devuelto e IVA rechazado (por concepto de devoluciones de IVA), ajuste de IVA por procesos de control y otros (adquisiciones en importaciones), 612 0.00\nimputables al crédito tributario\n(+) Ajuste por IVA devuelto e IVA rechazado, ajuste de IVA por procesos de control y otros (por concepto retenciones en la fuente de IVA), imputables al crédito 613 0.00\ntributario\n(+) Ajuste por IVA devuelto por otras instituciones del sector público imputable al crédito tributario en el mes 614 0.00\nSaldo crédito tributario para el próximo mes\n. Por adquisiciones e importaciones 615 0.00\n. Por retenciones en la fuente de IVA que le han sido efectuadas 617 0.00\n. Por compensación de IVA por ventas efectuadas con medio electrónico 618 0.00\n. Por compensación de IVA por ventas efectuadas en zonas afectadas - Ley de solidaridad, restitución de crédito tributario en 619 0.00\nresoluciones administrativas o sentencias judiciales de última instancia\nIVA pagado y no compensado, en la adquisición local o importación de bienes o servicios que se carga al gasto de Impuesto a la Renta. 624 0.00\nAjuste del crédito tributario de Impuesto al Valor Agregado pagado en adquisiciones locales e importaciones de bienes y servicios superior a cinco (5) años 625 0.00\nSUBTOTAL A PAGAR Si (601-602-603-604-605-606-607-608-609+610+611+612+613+614) > 0 620 682.92\nTOTAL IMPUESTO A PAGAR POR PERCEPCIÓN Y RETENCIONES EFECTUADAS EN VENTAS (varios 620+621 699 682.92\nporcentajes)\nDEVOLUCIÓN ISD POR\nEXPORTACIONES\nAGENTE DE RETENCIÓN DEL IMPUESTO AL VALOR AGREGADO\nRetención del 10% 721 0.00\nLa información reposa en la base de datos del SRI, conforme la declaraciónrealizada por el contribuyente\nCÓDIGO VERIFICADOR NÚMERO SERIAL FECHA RECAUDACIÓN PÁGINA\nSRIDEC2025127625752 872820587210 08-04-2025 3\nRetención del 20% 723 0.00\nRetención del 30% 725 388.09\nRetención del 50% 727 0.00\nRetención del 70% 729 9.35\nRetención del 100% 731 76.48\nTOTAL IMPUESTO RETENIDO 721+723+725+727+729+731 799 473.92\nTOTAL IMPUESTO A PAGAR POR RETENCIÓN (799-800-802) 801 473.92\nTOTAL CONSOLIDADO DE IMPUESTO AL VALOR AGREGADO (699+801) 859 1156.84\n.\n.\n887\nVALORES A PAGAR (luego de imputación al pago en declaraciones sustitutivas)\nTOTAL IMPUESTO A PAGAR (859-898) 902 1156.84\nInterés por mora 903 0\nMulta 904 0\nTOTAL PAGADO 999 1156.84\nLa información reposa en la base de datos del SRI, conforme la declaraciónrealizada por el contribuyente\nCÓDIGO VERIFICADOR NÚMERO SERIAL FECHA RECAUDACIÓN PÁGINA\nSRIDEC2025127625752 872820587210 08-04-2025 4	4	7906	{"form_type": "form_104", "header": {"codigo_verificador": "N", "obligacion_tributaria": "2011 DECLARACION DE IVA\\nIdentificaci\\u00f3n", "identificacion": "1792234026001", "razon_social": "GAMA EDITORES REYES MEDINA CIA. LTDA.", "periodo_mes": "MARZO", "periodo_anio": "2025", "tipo_declaracion": "ORIGINAL"}, "ventas": {"ventas_tarifa_diferente_cero_bruto": 20362.68, "ventas_tarifa_diferente_cero_neto": 20362.68, "impuesto_generado": 3054.4, "iva_ajuste_pagar": 0.0, "iva_ajuste_favor": 0.0, "ventas_tarifa_cero_sin_derecho": 0.0, "ventas_tarifa_cero_sin_derecho_neto": 0.0, "ventas_tarifa_cero_con_derecho": 0.0, "ventas_tarifa_cero_con_derecho_neto": 0.0, "total_ventas_bruto": 20362.68, "total_ventas_neto": 20362.68, "total_impuesto_generado": 3054.4, "transferencias_no_objeto_exentas": 0.0, "ingresos_reembolso": 0.0, "total_impuesto_generado_482": 3054.4, "impuesto_liquidar_mes_anterior": 0.0, "impuesto_liquidar_este_mes": 3054.4, "total_impuesto_liquidar": 3054.4}, "compras": {"adquisiciones_tarifa_diferente_cero_bruto": 10473.22, "adquisiciones_tarifa_diferente_cero_neto": 10282.5, "impuesto_compras": 1542.38, "otras_adquisiciones_sin_derecho": 0.0, "otras_adquisiciones_sin_derecho_neto": 0.0, "impuesto_otras_adquisiciones": 0.0, "ajuste_positivo_credito": 0.0, "ajuste_negativo_credito": 0.0, "adquisiciones_tarifa_cero": 18176.62, "adquisiciones_tarifa_cero_neto": 18176.62, "adquisiciones_rise": 5342.8, "adquisiciones_rise_neto": 5342.8, "total_adquisiciones": 33992.64, "total_adquisiciones_neto": 33801.92, "total_impuesto_compras": 1542.38, "adquisiciones_no_objeto": 0.0, "adquisiciones_exentas": 0.0, "pagos_reembolso": 0.0, "factor_proporcionalidad": 1.0, "credito_tributario_aplicable": 1542.38, "iva_no_credito": 0.0}, "retenciones_iva": [{"porcentaje": 10, "valor": 0.0}, {"porcentaje": 20, "valor": 0.0}, {"porcentaje": 30, "valor": 388.09}, {"porcentaje": 50, "valor": 0.0}, {"porcentaje": 70, "valor": 9.35}, {"porcentaje": 100, "valor": 76.48}], "totals": {"impuesto_causado": 1512.02, "credito_tributario_602": 0.0, "compensacion_iva_electronico": 0.0, "saldo_credito_anterior_adquisiciones": 0.0, "saldo_credito_anterior_retenciones": 0.0, "saldo_credito_anterior_electronico": 0.0, "saldo_credito_anterior_zonas": 0.0, "retenciones_efectuadas": 829.1, "ajuste_iva_devuelto_electronico": 0.0, "ajuste_iva_devuelto_adquisiciones": 0.0, "ajuste_iva_devuelto_retenciones": 0.0, "ajuste_iva_otras_instituciones": 0.0, "saldo_credito_proximo_adquisiciones": 0.0, "saldo_credito_proximo_retenciones": 0.0, "saldo_credito_proximo_electronico": 0.0, "saldo_credito_proximo_zonas": 0.0, "subtotal_a_pagar": 682.92, "iva_devuelto_adultos_mayores": 0.0, "iva_pagado_no_compensado": 0.0, "ajuste_credito_superior_5_anos": 0.0, "total_impuesto_pagar_percepcion": 682.92, "total_impuesto_retenido": 473.92, "total_impuesto_pagar_retencion": 473.92, "total_consolidado_iva": 1156.84, "total_impuesto_a_pagar": 1156.84, "interes_mora": 0.0, "multa": 0.0, "total_pagado": 1156.84}}	\N	\N	\N	1792234026001	GAMA EDITORES REYES MEDINA CIA. LTDA.	MARZO	2025	COMPLETED	\N	2025-12-01 17:19:21.873258+00	2025-12-01 22:19:22.043331+00	MARZO 2025	3
202	9feb84f13c144f608ea35c8047dae9b6.pdf	103 DECLARACION RETENCIONES SEPTIEMBRE.pdf	./uploads\\9feb84f13c144f608ea35c8047dae9b6.pdf	150038	FORM_103	Obligación Tributaria: 1031 - DECLARACIÓN DE RETENCIONES EN LA FUENTE\nIdentificación: 1792234026001 Razón Social: GAMA EDITORES REYES MEDINA CIA. LTDA.\nPeríodo Fiscal: SEPTIEMBRE 2025 Tipo Declaración: ORIGINAL\nFormulario Sustituye:\n.\nDETALLE DE PAGOS Y RETENCIÓN POR IMPUESTO A LA RENTA\nPOR PAGOS EFECTUADOS A RESIDENTES Y ESTABLECIMIENTOS PERMANENTES\nDERIVADAS DEL TRABAJO Y SERVICIOS PRESTADOS\nBASE VALOR\nIMPONIBLE RETENIDO\nEn relación de dependencia que supera o no la base desgravada 302 7225.47 352 0.00\nServicios\n.Honorarios profesionales 303 300.00 353 30.00\n.Servicios profesionales prestados por sociedades residentes 3030 0.00 3530 0.00\n.Predomina el intelecto 304 0.00 354 0.00\n.Predomina la mano de obra 307 0.00 357 0.00\n.Utilización o aprovechamiento de la imagen o renombre (personas naturales, sociedades, influencers) 308 0.00 358 0.00\n.Publicidad y comunicación 309 0.00 359 0.00\n.Transporte privado de pasajeros o servicio público o privado de carga 310 125.89 360 1.28\nA través de liquidaciones de compra (nivel cultural o rusticidad) 311 0.00 361 0.00\nPOR BIENES Y SERVICIOS\nTransferencia de bienes muebles de naturaleza corporal 312 6783.94 362 118.73\nSeguros y reaseguros (primas y cesiones) 322 0.00 372 0.00\nCOMPRAS AL PRODUCTOR: de bienes de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuático, forestal y carnes en estado natural y 3120 0.00 3620 0.00\nlos descritos en el art.27.1 de LRTI.\nLa información reposa en la base de datos del SRI, conforme la declaraciónrealizada por el contribuyente\nCÓDIGO VERIFICADOR NÚMERO SERIAL FECHA RECAUDACIÓN PÁGINA\nSRIDEC2025136448896 872912199734 07-10-2025 1\nCOMPRAS AL COMERCIALIZADOR: de bienes de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuático, forestal y carnes en estado 3121 0.00 3621 0.00\nnatural y los descritos en el art.27.1 de LRTI.\nActividades de construcción de obra material inmueble, urbanización, lotización o actividades similares 3430 0.00 3450 0.00\nPagos aplicables el 1% (Energía Eléctrica y régimen RIMPE - Emprendedores, para este caso aplica con cualquier forma de pago inclusive los 343 16.80 393 0.17\npagos que deban realizar las tarjetas de crédito/débito)\nPagos aplicables el 2% (incluye Pago local tarjeta de crédito /débito reportada por la Emisora de tarjeta de crédito / entidades del sistema 344 0.00 394 0.00\nfinanciero; adquisición de sustancias minerales dentro del territorio nacional; Recepción de botellas plásticas no retornables de PET)\nPagos de bienes y servicios no sujetos a retención o con 0% (distintos de rendimientos financieros) 332 1503.17\nPOR REGALIAS, COMISIONES, ARRENDAMIENTOS Y OTROS\nPor regalías, derechos de autor, marcas, patentes y similares 314 0.00 364 0.00\nComisiones pagadas a sociedades, nacionales o extranjeras residentes en el Ecuador y establecimientos permanentes domiciliados en el país 3140 0.00 3640 0.00\nArrendamiento\n.Mercantil 319 0.00 369 0.00\n.Bienes inmuebles 320 350.00 370 35.00\nRELACIONADAS CON EL CAPITAL ( RENDIMIENTOS, GANANCIAS, DIVIDENDOS Y OTROS)\nRendimientos financieros 323 0.00 373 0.00\nRendimientos financieros entre instituciones del sistema financiero y entidades economía popular y solidaria 324 0.00 374 0.00\nOtros Rendimientos financieros 0% 3230 0.00\nDividendos\n.Dividendos exentos (por no superar la franja exenta o beneficio de otras leyes) 3250 0.00\nGanancia en la enajenación de derechos representativos de capital u otros derechos que permitan la exploración, explotación, concesión o 333 0.00 383 0.00\nsimilares de sociedades, que se coticen en las bolsas de valores del Ecuador\nContraprestación en la enajenación de derechos representativos de capital u otros derechos que permitan la exploración, explotación, concesión o 334 0.00 384 0.00\nsimilares de sociedades, no cotizados en las bolsas de valores del Ecuador\nPOR LOTERIAS Y PREMIOS\nLoterías, rifas, apuestas, pronósticos deportivos y similares 335 0.00 385 0.00\nAUTORRETENCIONES Y OTRAS RETENCIONES\nVenta de combustibles\n.A comercializadoras 336 0.00 386 0.00\n.A distribuidores 337 0.00 387 0.00\nRetención a cargo del propio sujeto pasivo por la comercialización de productos forestales 3370 0.00 3870 0.00\nLa información reposa en la base de datos del SRI, conforme la declaraciónrealizada por el contribuyente\nCÓDIGO VERIFICADOR NÚMERO SERIAL FECHA RECAUDACIÓN PÁGINA\nSRIDEC2025136448896 872912199734 07-10-2025 2\nOtras autorretenciones (inciso 1 y 2 Art.92.1 RLRTI) 350 0.00 400 0.00\nOtras retenciones\n. Aplicables el 2,75% 3440 82.91 3940 2.28\n. Aplicables a otros porcentajes ( Por Donaciones en dinero -Impuesto a las donaciones ) 346 0.00 396 0.00\nIRU Pronósticos deportivos\n.(+) Ingresos generados por la actividad económica de pronósticos deportivos 3483 0.00\n.(+) Comisiones derivadas de la actividad de pronósticos deportivos 3484 0.00\n.(-) Premios pagados por pronósticos deportivos 3485 0.00\n.Impuesto a la renta único sobre los ingresos percibidos por los operadores de pronósticos deportivos 3480 0.00 3980 0.00\nSUBTOTAL OPERACIONES EFECTUADAS EN EL PAÍS 349 16388.18 399 187.46\nTOTAL DE RETENCIÓN DE IMPUESTO A LA RENTA 399 + 498 499 187.46\n.\nVALORES A PAGAR (luego de imputación al pago)\nTOTAL IMPUESTO A PAGAR 902 187.46\nInterés por mora 903 0.00\nMulta 904 0.00\nTOTAL PAGADO 999 187.46\nLa información reposa en la base de datos del SRI, conforme la declaraciónrealizada por el contribuyente\nCÓDIGO VERIFICADOR NÚMERO SERIAL FECHA RECAUDACIÓN PÁGINA\nSRIDEC2025136448896 872912199734 07-10-2025 3	3	5475	{"form_type": "form_103", "header": {"codigo_verificador": "N", "obligacion_tributaria": "1031 - DECLARACI\\u00d3N DE RETENCIONES EN LA FUENTE\\nIdentificaci\\u00f3n", "identificacion": "1792234026001", "razon_social": "GAMA EDITORES REYES MEDINA CIA. LTDA.", "periodo_mes": "SEPTIEMBRE", "periodo_anio": "2025", "tipo_declaracion": "ORIGINAL"}, "line_items": [{"concepto": ".\\nDETALLE DE PAGOS Y RETENCI\\u00d3N POR IMPUESTO A LA RENTA\\nPOR PAGOS EFECTUADOS A RESIDENTES Y ESTABLECIMIENTOS PERMANENTES\\nDERIVADAS DEL TRABAJO Y SERVICIOS PRESTADOS\\nBASE VALOR\\nIMPONIBLE RETENIDO\\nEn relaci\\u00f3n de dependencia que supera o no la base desgravada", "codigo_base": "302", "base_imponible": 7225.47, "codigo_retencion": "352", "valor_retenido": 0.0}, {"concepto": "Servicios\\n.Honorarios profesionales", "codigo_base": "303", "base_imponible": 300.0, "codigo_retencion": "353", "valor_retenido": 30.0}, {"concepto": ".Servicios profesionales prestados por sociedades residentes", "codigo_base": "3030", "base_imponible": 0.0, "codigo_retencion": "3530", "valor_retenido": 0.0}, {"concepto": ".Predomina el intelecto", "codigo_base": "304", "base_imponible": 0.0, "codigo_retencion": "354", "valor_retenido": 0.0}, {"concepto": ".Predomina la mano de obra", "codigo_base": "307", "base_imponible": 0.0, "codigo_retencion": "357", "valor_retenido": 0.0}, {"concepto": ".Utilizaci\\u00f3n o aprovechamiento de la imagen o renombre (personas naturales, sociedades, influencers)", "codigo_base": "308", "base_imponible": 0.0, "codigo_retencion": "358", "valor_retenido": 0.0}, {"concepto": ".Publicidad y comunicaci\\u00f3n", "codigo_base": "309", "base_imponible": 0.0, "codigo_retencion": "359", "valor_retenido": 0.0}, {"concepto": ".Transporte privado de pasajeros o servicio p\\u00fablico o privado de carga", "codigo_base": "310", "base_imponible": 125.89, "codigo_retencion": "360", "valor_retenido": 1.28}, {"concepto": "A trav\\u00e9s de liquidaciones de compra (nivel cultural o rusticidad)", "codigo_base": "311", "base_imponible": 0.0, "codigo_retencion": "361", "valor_retenido": 0.0}, {"concepto": "POR BIENES Y SERVICIOS\\nTransferencia de bienes muebles de naturaleza corporal", "codigo_base": "312", "base_imponible": 6783.94, "codigo_retencion": "362", "valor_retenido": 118.73}, {"concepto": "Seguros y reaseguros (primas y cesiones)", "codigo_base": "322", "base_imponible": 0.0, "codigo_retencion": "372", "valor_retenido": 0.0}, {"concepto": "de bienes de origen agr\\u00edcola, av\\u00edcola, pecuario, ap\\u00edcola, cun\\u00edcola, bioacu\\u00e1tico, forestal y carnes en estado natural y", "codigo_base": "3120", "base_imponible": 0.0, "codigo_retencion": "3620", "valor_retenido": 0.0}, {"concepto": "de bienes de origen agr\\u00edcola, av\\u00edcola, pecuario, ap\\u00edcola, cun\\u00edcola, bioacu\\u00e1tico, forestal y carnes en estado", "codigo_base": "3121", "base_imponible": 0.0, "codigo_retencion": "3621", "valor_retenido": 0.0}, {"concepto": "de LRTI.\\nActividades de construcci\\u00f3n de obra material inmueble, urbanizaci\\u00f3n, lotizaci\\u00f3n o actividades similares", "codigo_base": "3430", "base_imponible": 0.0, "codigo_retencion": "3450", "valor_retenido": 0.0}, {"concepto": "(Energ\\u00eda El\\u00e9ctrica y r\\u00e9gimen RIMPE - Emprendedores, para este caso aplica con cualquier forma de pago inclusive los", "codigo_base": "343", "base_imponible": 16.8, "codigo_retencion": "393", "valor_retenido": 0.17}, {"concepto": "(incluye Pago local tarjeta de cr\\u00e9dito /d\\u00e9bito reportada por la Emisora de tarjeta de cr\\u00e9dito / entidades del sistema", "codigo_base": "344", "base_imponible": 0.0, "codigo_retencion": "394", "valor_retenido": 0.0}, {"concepto": "POR REGALIAS, COMISIONES, ARRENDAMIENTOS Y OTROS\\nPor regal\\u00edas, derechos de autor, marcas, patentes y similares", "codigo_base": "314", "base_imponible": 0.0, "codigo_retencion": "364", "valor_retenido": 0.0}, {"concepto": "Comisiones pagadas a sociedades, nacionales o extranjeras residentes en el Ecuador y establecimientos permanentes domiciliados en el pa\\u00eds", "codigo_base": "3140", "base_imponible": 0.0, "codigo_retencion": "3640", "valor_retenido": 0.0}, {"concepto": "Arrendamiento\\n.Mercantil", "codigo_base": "319", "base_imponible": 0.0, "codigo_retencion": "369", "valor_retenido": 0.0}, {"concepto": ".Bienes inmuebles", "codigo_base": "320", "base_imponible": 350.0, "codigo_retencion": "370", "valor_retenido": 35.0}, {"concepto": "RELACIONADAS CON EL CAPITAL ( RENDIMIENTOS, GANANCIAS, DIVIDENDOS Y OTROS)\\nRendimientos financieros", "codigo_base": "323", "base_imponible": 0.0, "codigo_retencion": "373", "valor_retenido": 0.0}, {"concepto": "Rendimientos financieros entre instituciones del sistema financiero y entidades econom\\u00eda popular y solidaria", "codigo_base": "324", "base_imponible": 0.0, "codigo_retencion": "374", "valor_retenido": 0.0}, {"concepto": "Ganancia en la enajenaci\\u00f3n de derechos representativos de capital u otros derechos que permitan la exploraci\\u00f3n, explotaci\\u00f3n, concesi\\u00f3n o", "codigo_base": "333", "base_imponible": 0.0, "codigo_retencion": "383", "valor_retenido": 0.0}, {"concepto": "similares de sociedades, que se coticen en las bolsas de valores del Ecuador\\nContraprestaci\\u00f3n en la enajenaci\\u00f3n de derechos representativos de capital u otros derechos que permitan la exploraci\\u00f3n, explotaci\\u00f3n, concesi\\u00f3n o", "codigo_base": "334", "base_imponible": 0.0, "codigo_retencion": "384", "valor_retenido": 0.0}, {"concepto": "similares de sociedades, no cotizados en las bolsas de valores del Ecuador\\nPOR LOTERIAS Y PREMIOS\\nLoter\\u00edas, rifas, apuestas, pron\\u00f3sticos deportivos y similares", "codigo_base": "335", "base_imponible": 0.0, "codigo_retencion": "385", "valor_retenido": 0.0}, {"concepto": "AUTORRETENCIONES Y OTRAS RETENCIONES\\nVenta de combustibles\\n.A comercializadoras", "codigo_base": "336", "base_imponible": 0.0, "codigo_retencion": "386", "valor_retenido": 0.0}, {"concepto": ".A distribuidores", "codigo_base": "337", "base_imponible": 0.0, "codigo_retencion": "387", "valor_retenido": 0.0}, {"concepto": "Retenci\\u00f3n a cargo del propio sujeto pasivo por la comercializaci\\u00f3n de productos forestales", "codigo_base": "3370", "base_imponible": 0.0, "codigo_retencion": "3870", "valor_retenido": 0.0}, {"concepto": "RLRTI)", "codigo_base": "350", "base_imponible": 0.0, "codigo_retencion": "400", "valor_retenido": 0.0}, {"concepto": ". Aplicables a otros porcentajes ( Por Donaciones en dinero -Impuesto a las donaciones )", "codigo_base": "346", "base_imponible": 0.0, "codigo_retencion": "396", "valor_retenido": 0.0}, {"concepto": ".Impuesto a la renta \\u00fanico sobre los ingresos percibidos por los operadores de pron\\u00f3sticos deportivos", "codigo_base": "3480", "base_imponible": 0.0, "codigo_retencion": "3980", "valor_retenido": 0.0}, {"concepto": "Pagos de bienes y servicios no sujetos a retenci\\u00f3n (C\\u00f3digo 332)", "codigo_base": "332", "base_imponible": 1503.17, "codigo_retencion": "N/A", "valor_retenido": 0.0}], "totals": {"subtotal_operaciones_pais": 16388.18, "subtotal_retencion": 187.46, "pagos_no_sujetos": 1503.17, "otras_retenciones_base": 82.91, "otras_retenciones_retenido": 2.28, "total_retencion": 187.46, "total_impuesto_pagar": 187.46, "interes_mora": 0.0, "multa": 0.0, "total_pagado": 187.46}}	\N	\N	\N	1792234026001	GAMA EDITORES REYES MEDINA CIA. LTDA.	SEPTIEMBRE	2025	COMPLETED	\N	2025-11-29 03:37:15.731764+00	2025-11-29 08:37:15.789214+00	SEPTIEMBRE 2025	9
203	f24a03db5df240499ce4b111953556c2.pdf	104 DECLARACION ABRIL.pdf	./uploads\\f24a03db5df240499ce4b111953556c2.pdf	154335	FORM_104	Obligación Tributaria: 2011 DECLARACION DE IVA\nIdentificación: 1792234026001 Razón Social: GAMA EDITORES REYES MEDINA CIA. LTDA.\nPeríodo Fiscal: ABRIL 2025 Tipo Declaración: ORIGINAL\nFormulario Sustituye:\nTARIFA VARIABLE DE IVA\nPARA ACTIVIDADES\nTURÍSTICAS\nVENTAS\nRESUMEN DE VENTAS Y OTRAS OPERACIONES DEL PERÍODO QUE DECLARA VALOR BRUTO VALOR NETO IMPUESTO\nGENERADO\n. (VALOR BRUTO - N/C) .\nVentas locales (excluye activos fijos) gravadas tarifa diferente de cero 401 36088.15 411 36080.04 421 5412.01\nIVA generado en la diferencia entre ventas y notas de crédito con distinta tarifa (ajuste a pagar) . 423 0.00\nIVA generado en la diferencia entre ventas y notas de crédito con distinta tarifa (ajuste a favor) . 424 0.00\nVentas locales (excluye activos fijos) gravadas tarifa 0% que no dan derecho a crédito tributario 403 0.00 413 0.00 .\nVentas locales (excluye activos fijos) gravadas tarifa 0% que dan derecho a crédito tributario 405 0.00 415 0.00 .\nTOTAL VENTAS Y OTRAS OPERACIONES 409 36088.15 419 36080.04 429 5412.01\nTransferencias de bienes y prestación de servicios no objeto o exentos de IVA 431 0.00 441 0.00 .\nIngresos por reembolso como intermediario / valores facturados por operadoras de transporte / ingresos 434 0.00 444 0.00 454 0.00\nobtenidos por parte de las sociedades de gestión colectiva como intermediarios (informativo)\n.\nLIQUIDACIÓN DEL IVA EN EL MES\nTotal impuesto generado (trasládese campo 429) 482 5412.01\nImpuesto a liquidar del mes anterior (verificar que el valor corresponda al campo 485 por 483 0.00\nventas a crédito de periodos anteriores)\nLa información reposa en la base de datos del SRI, conforme la declaraciónrealizada por el contribuyente\nCÓDIGO VERIFICADOR NÚMERO SERIAL FECHA RECAUDACIÓN PÁGINA\nSRIDEC2025129355166 872836049499 07-05-2025 1\nImpuesto a liquidar en este mes 484 5412.01\nMes a pagar el monto de IVA diferente de cero por ventas a crédito de este mes 486 0\nTamaño COPCI 487 No aplica\nTOTAL IMPUESTO A LIQUIDAR EN ESTE MES 483+484 499 5412.01\nRESUMEN DE ADQUISICIONES Y PAGOS DEL PERÍODO QUE DECLARA VALOR BRUTO VALOR NETO IMPUESTO\nGENERADO\n. (VALOR BRUTO - N/C) .\nAdquisiciones y pagos (excluye activos fijos) gravados tarifa diferente de cero (con derecho a crédito tributario) 500 9622.70 510 9515.22 520 1427.28\nOtras adquisiciones y pagos gravados tarifa diferente de cero (sin derecho a crédito tributario) 502 0.00 512 0.00 522 0.00\nIVA generado en la diferencia entre adquisiciones y notas de crédito con distinta tarifa (ajuste en positivo al . 526 0.00\ncrédito tributario)\nIVA generado en la diferencia entre adquisiciones y notas de crédito con distinta tarifa (ajuste en negativo al . 527 0.00\ncrédito tributario)\nAdquisiciones y pagos (incluye activos fijos) gravados tarifa 0% 507 3238.99 517 3238.99 .\nAdquisiciones realizadas a contribuyentes RISE (hasta diciembre 2021), NEGOCIOS POPULARES (desde 508 497.30 518 497.30 .\nenero 2022)\nTOTAL ADQUISICIONES Y PAGOS 509 13358.99 519 13251.51 529 1427.28\nAdquisiciones no objeto de IVA 531 0.00 541 0.00 .\nAdquisiciones exentas del pago de IVA 532 0.00 542 0.00 .\nPagos netos por reembolso como intermediario / valores facturados por socios a operadoras de transporte / 535 0.00 545 0.00 555 0.00\npagos realizados por parte de las sociedades de gestión colectiva como intermediarios (informativo)\n.\nFactor de proporcionalidad para crédito tributario (411+412+420+435+415+416+417+418) / 419 563 1.0000\nCrédito tributario aplicable en este período (de acuerdo al factor de proporcionalidad o a su contabilidad) (520+521+534+560+523+524+525+526-527) x 563 564 1427.28\nValor de IVA no considerado como crédito tributario por factor de proporcionalidad 565 0.00\n.\nRESUMEN IMPOSITIVO: AGENTE DE PERCEPCIÓN DEL IMPUESTO AL VALOR AGREGADO\nImpuesto causado (si la diferencia de los campos 499-564 es mayor que cero) 601 3984.73\nCrédito tributario aplicable en este período (si la diferencia de los campos 499-564 es menor que cero) 602 0.00\n(-) Compensación de IVA por ventas efectuadas con medio electrónico y/o IVA devuelto o descontado por transacciones realizadas con personas adultas mayores o 603 0.00\npersonas con discapacidad\n(-) Saldo crédito tributario del mes anterior\nLa información reposa en la base de datos del SRI, conforme la declaraciónrealizada por el contribuyente\nCÓDIGO VERIFICADOR NÚMERO SERIAL FECHA RECAUDACIÓN PÁGINA\nSRIDEC2025129355166 872836049499 07-05-2025 2\n. Por adquisiciones e importaciones (trasládese el campo 615 de la declaración del período 605 0.00\nanterior)\n. Por retenciones en la fuente de IVA que le han sido efectuadas (trasládese el campo 617 de la declaración del período 606 0.00\nanterior)\n. Por compensación de IVA por ventas efectuadas con medio (trasládese el campo 618 de la declaración del período 607 0.00\nelectrónico anterior)\n. Por compensación de IVA por ventas efectuadas en zonas afectadas (trasládese el campo 619 de la declaración del período 608 0.00\n- Ley de solidaridad, restitución de crédito tributario en resoluciones anterior)\nadministrativas o sentencias judiciales de última instancia\n(-) Retenciones en la fuente de IVA que le han sido efectuadas en este período 609 1491.71\n(-) IVA devuelto o descontado por transacciones realizadas con personas adultas mayores o personas con discapacidad 622 0.00\n(+) Ajuste por IVA devuelto o descontado por adquisiciones efectuadas con medio electrónico 610 0.00\n(+) Ajuste por IVA devuelto e IVA rechazado (por concepto de devoluciones de IVA), ajuste de IVA por procesos de control y otros (adquisiciones en importaciones), 612 0.00\nimputables al crédito tributario\n(+) Ajuste por IVA devuelto e IVA rechazado, ajuste de IVA por procesos de control y otros (por concepto retenciones en la fuente de IVA), imputables al crédito 613 0.00\ntributario\n(+) Ajuste por IVA devuelto por otras instituciones del sector público imputable al crédito tributario en el mes 614 0.00\nSaldo crédito tributario para el próximo mes\n. Por adquisiciones e importaciones 615 0.00\n. Por retenciones en la fuente de IVA que le han sido efectuadas 617 0.00\n. Por compensación de IVA por ventas efectuadas con medio electrónico 618 0.00\n. Por compensación de IVA por ventas efectuadas en zonas afectadas - Ley de solidaridad, restitución de crédito tributario en 619 0.00\nresoluciones administrativas o sentencias judiciales de última instancia\nIVA pagado y no compensado, en la adquisición local o importación de bienes o servicios que se carga al gasto de Impuesto a la Renta. 624 0.00\nAjuste del crédito tributario de Impuesto al Valor Agregado pagado en adquisiciones locales e importaciones de bienes y servicios superior a cinco (5) años 625 0.00\nSUBTOTAL A PAGAR Si (601-602-603-604-605-606-607-608-609+610+611+612+613+614) > 0 620 2493.02\nTOTAL IMPUESTO A PAGAR POR PERCEPCIÓN Y RETENCIONES EFECTUADAS EN VENTAS (varios 620+621 699 2493.02\nporcentajes)\nDEVOLUCIÓN ISD POR\nEXPORTACIONES\nAGENTE DE RETENCIÓN DEL IMPUESTO AL VALOR AGREGADO\nRetención del 10% 721 0.00\nLa información reposa en la base de datos del SRI, conforme la declaraciónrealizada por el contribuyente\nCÓDIGO VERIFICADOR NÚMERO SERIAL FECHA RECAUDACIÓN PÁGINA\nSRIDEC2025129355166 872836049499 07-05-2025 3\nRetención del 20% 723 0.00\nRetención del 30% 725 111.66\nRetención del 50% 727 0.00\nRetención del 70% 729 11.18\nRetención del 100% 731 342.31\nTOTAL IMPUESTO RETENIDO 721+723+725+727+729+731 799 465.15\nTOTAL IMPUESTO A PAGAR POR RETENCIÓN (799-800-802) 801 465.15\nTOTAL CONSOLIDADO DE IMPUESTO AL VALOR AGREGADO (699+801) 859 2958.17\n.\n.\n887\nVALORES A PAGAR (luego de imputación al pago en declaraciones sustitutivas)\nTOTAL IMPUESTO A PAGAR (859-898) 902 2958.17\nInterés por mora 903 0\nMulta 904 0\nTOTAL PAGADO 999 2958.17\nLa información reposa en la base de datos del SRI, conforme la declaraciónrealizada por el contribuyente\nCÓDIGO VERIFICADOR NÚMERO SERIAL FECHA RECAUDACIÓN PÁGINA\nSRIDEC2025129355166 872836049499 07-05-2025 4	4	7905	{"form_type": "form_104", "header": {"codigo_verificador": "N", "obligacion_tributaria": "2011 DECLARACION DE IVA\\nIdentificaci\\u00f3n", "identificacion": "1792234026001", "razon_social": "GAMA EDITORES REYES MEDINA CIA. LTDA.", "periodo_mes": "ABRIL", "periodo_anio": "2025", "tipo_declaracion": "ORIGINAL"}, "ventas": {"ventas_tarifa_diferente_cero_bruto": 36088.15, "ventas_tarifa_diferente_cero_neto": 36080.04, "impuesto_generado": 5412.01, "iva_ajuste_pagar": 0.0, "iva_ajuste_favor": 0.0, "ventas_tarifa_cero_sin_derecho": 0.0, "ventas_tarifa_cero_sin_derecho_neto": 0.0, "ventas_tarifa_cero_con_derecho": 0.0, "ventas_tarifa_cero_con_derecho_neto": 0.0, "total_ventas_bruto": 36088.15, "total_ventas_neto": 36080.04, "total_impuesto_generado": 5412.01, "transferencias_no_objeto_exentas": 0.0, "ingresos_reembolso": 0.0, "total_impuesto_generado_482": 5412.01, "impuesto_liquidar_mes_anterior": 0.0, "impuesto_liquidar_este_mes": 5412.01, "total_impuesto_liquidar": 5412.01}, "compras": {"adquisiciones_tarifa_diferente_cero_bruto": 9622.7, "adquisiciones_tarifa_diferente_cero_neto": 9515.22, "impuesto_compras": 1427.28, "otras_adquisiciones_sin_derecho": 0.0, "otras_adquisiciones_sin_derecho_neto": 0.0, "impuesto_otras_adquisiciones": 0.0, "ajuste_positivo_credito": 0.0, "ajuste_negativo_credito": 0.0, "adquisiciones_tarifa_cero": 3238.99, "adquisiciones_tarifa_cero_neto": 3238.99, "adquisiciones_rise": 497.3, "adquisiciones_rise_neto": 497.3, "total_adquisiciones": 13358.99, "total_adquisiciones_neto": 13251.51, "total_impuesto_compras": 1427.28, "adquisiciones_no_objeto": 0.0, "adquisiciones_exentas": 0.0, "pagos_reembolso": 0.0, "factor_proporcionalidad": 1.0, "credito_tributario_aplicable": 1427.28, "iva_no_credito": 0.0}, "retenciones_iva": [{"porcentaje": 10, "valor": 0.0}, {"porcentaje": 20, "valor": 0.0}, {"porcentaje": 30, "valor": 111.66}, {"porcentaje": 50, "valor": 0.0}, {"porcentaje": 70, "valor": 11.18}, {"porcentaje": 100, "valor": 342.31}], "totals": {"impuesto_causado": 3984.73, "credito_tributario_602": 0.0, "compensacion_iva_electronico": 0.0, "saldo_credito_anterior_adquisiciones": 0.0, "saldo_credito_anterior_retenciones": 0.0, "saldo_credito_anterior_electronico": 0.0, "saldo_credito_anterior_zonas": 0.0, "retenciones_efectuadas": 1491.71, "ajuste_iva_devuelto_electronico": 0.0, "ajuste_iva_devuelto_adquisiciones": 0.0, "ajuste_iva_devuelto_retenciones": 0.0, "ajuste_iva_otras_instituciones": 0.0, "saldo_credito_proximo_adquisiciones": 0.0, "saldo_credito_proximo_retenciones": 0.0, "saldo_credito_proximo_electronico": 0.0, "saldo_credito_proximo_zonas": 0.0, "subtotal_a_pagar": 2493.02, "iva_devuelto_adultos_mayores": 0.0, "iva_pagado_no_compensado": 0.0, "ajuste_credito_superior_5_anos": 0.0, "total_impuesto_pagar_percepcion": 2493.02, "total_impuesto_retenido": 465.15, "total_impuesto_pagar_retencion": 465.15, "total_consolidado_iva": 2958.17, "total_impuesto_a_pagar": 2958.17, "interes_mora": 0.0, "multa": 0.0, "total_pagado": 2958.17}}	\N	\N	\N	1792234026001	GAMA EDITORES REYES MEDINA CIA. LTDA.	ABRIL	2025	COMPLETED	\N	2025-11-29 03:37:15.835239+00	2025-11-29 08:37:16.061944+00	ABRIL 2025	4
\.


--
-- Data for Name: form_103_line_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.form_103_line_items (id, document_id, concepto, codigo_base, base_imponible, codigo_retencion, valor_retenido, order_index) FROM stdin;
2066	202	.\nDETALLE DE PAGOS Y RETENCIÓN POR IMPUESTO A LA RENTA\nPOR PAGOS EFECTUADOS A RESIDENTES Y ESTABLECIMIENTOS PERMANENTES\nDERIVADAS DEL TRABAJO Y SERVICIOS PRESTADOS\nBASE VALOR\nIMPONIBLE RETENIDO\nEn relación de dependencia que supera o no la base desgravada	302	7225.47	352	0	0
2067	202	Servicios\n.Honorarios profesionales	303	300	353	30	1
2068	202	.Servicios profesionales prestados por sociedades residentes	3030	0	3530	0	2
2069	202	.Predomina el intelecto	304	0	354	0	3
2070	202	.Predomina la mano de obra	307	0	357	0	4
2071	202	.Utilización o aprovechamiento de la imagen o renombre (personas naturales, sociedades, influencers)	308	0	358	0	5
2072	202	.Publicidad y comunicación	309	0	359	0	6
2073	202	.Transporte privado de pasajeros o servicio público o privado de carga	310	125.89	360	1.28	7
2074	202	A través de liquidaciones de compra (nivel cultural o rusticidad)	311	0	361	0	8
2075	202	POR BIENES Y SERVICIOS\nTransferencia de bienes muebles de naturaleza corporal	312	6783.94	362	118.73	9
2076	202	Seguros y reaseguros (primas y cesiones)	322	0	372	0	10
2077	202	de bienes de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuático, forestal y carnes en estado natural y	3120	0	3620	0	11
2078	202	de bienes de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuático, forestal y carnes en estado	3121	0	3621	0	12
2079	202	de LRTI.\nActividades de construcción de obra material inmueble, urbanización, lotización o actividades similares	3430	0	3450	0	13
2080	202	(Energía Eléctrica y régimen RIMPE - Emprendedores, para este caso aplica con cualquier forma de pago inclusive los	343	16.8	393	0.17	14
2081	202	(incluye Pago local tarjeta de crédito /débito reportada por la Emisora de tarjeta de crédito / entidades del sistema	344	0	394	0	15
2082	202	POR REGALIAS, COMISIONES, ARRENDAMIENTOS Y OTROS\nPor regalías, derechos de autor, marcas, patentes y similares	314	0	364	0	16
2083	202	Comisiones pagadas a sociedades, nacionales o extranjeras residentes en el Ecuador y establecimientos permanentes domiciliados en el país	3140	0	3640	0	17
2084	202	Arrendamiento\n.Mercantil	319	0	369	0	18
2085	202	.Bienes inmuebles	320	350	370	35	19
2086	202	RELACIONADAS CON EL CAPITAL ( RENDIMIENTOS, GANANCIAS, DIVIDENDOS Y OTROS)\nRendimientos financieros	323	0	373	0	20
2087	202	Rendimientos financieros entre instituciones del sistema financiero y entidades economía popular y solidaria	324	0	374	0	21
2088	202	Ganancia en la enajenación de derechos representativos de capital u otros derechos que permitan la exploración, explotación, concesión o	333	0	383	0	22
2089	202	similares de sociedades, que se coticen en las bolsas de valores del Ecuador\nContraprestación en la enajenación de derechos representativos de capital u otros derechos que permitan la exploración, explotación, concesión o	334	0	384	0	23
2090	202	similares de sociedades, no cotizados en las bolsas de valores del Ecuador\nPOR LOTERIAS Y PREMIOS\nLoterías, rifas, apuestas, pronósticos deportivos y similares	335	0	385	0	24
2091	202	AUTORRETENCIONES Y OTRAS RETENCIONES\nVenta de combustibles\n.A comercializadoras	336	0	386	0	25
2092	202	.A distribuidores	337	0	387	0	26
2093	202	Retención a cargo del propio sujeto pasivo por la comercialización de productos forestales	3370	0	3870	0	27
2094	202	RLRTI)	350	0	400	0	28
2095	202	. Aplicables a otros porcentajes ( Por Donaciones en dinero -Impuesto a las donaciones )	346	0	396	0	29
2096	202	.Impuesto a la renta único sobre los ingresos percibidos por los operadores de pronósticos deportivos	3480	0	3980	0	30
2097	202	Pagos de bienes y servicios no sujetos a retención (Código 332)	332	1503.17	N/A	0	31
2098	204	.\nDETALLE DE PAGOS Y RETENCIÓN POR IMPUESTO A LA RENTA\nPOR PAGOS EFECTUADOS A RESIDENTES Y ESTABLECIMIENTOS PERMANENTES\nDERIVADAS DEL TRABAJO Y SERVICIOS PRESTADOS\nBASE VALOR\nIMPONIBLE RETENIDO\nEn relación de dependencia que supera o no la base desgravada	302	7740.21	352	0	0
2099	204	Servicios\n.Honorarios profesionales	303	300	353	30	1
2100	204	.Servicios profesionales prestados por sociedades residentes	3030	0	3530	0	2
2101	204	.Predomina el intelecto	304	0	354	0	3
2102	204	.Predomina la mano de obra	307	0	357	0	4
2103	204	.Utilización o aprovechamiento de la imagen o renombre (personas naturales, sociedades, influencers)	308	0	358	0	5
2104	204	.Publicidad y comunicación	309	0	359	0	6
2105	204	.Transporte privado de pasajeros o servicio público o privado de carga	310	42.5	360	0.43	7
2106	204	A través de liquidaciones de compra (nivel cultural o rusticidad)	311	0	361	0	8
2107	204	POR BIENES Y SERVICIOS\nTransferencia de bienes muebles de naturaleza corporal	312	26938.06	362	471.42	9
2108	204	Seguros y reaseguros (primas y cesiones)	322	0	372	0	10
2109	204	de bienes de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuático, forestal y carnes en estado natural y	3120	0	3620	0	11
2110	204	de bienes de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuático, forestal y carnes en estado	3121	0	3621	0	12
2111	204	de LRTI.\nActividades de construcción de obra material inmueble, urbanización, lotización o actividades similares	3430	0	3450	0	13
2112	204	(Energía Eléctrica y régimen RIMPE - Emprendedores, para este caso aplica con cualquier forma de pago inclusive los	343	6.74	393	0.07	14
2113	204	(incluye Pago local tarjeta de crédito /débito reportada por la Emisora de tarjeta de crédito / entidades del sistema	344	0	394	0	15
2114	204	POR REGALIAS, COMISIONES, ARRENDAMIENTOS Y OTROS\nPor regalías, derechos de autor, marcas, patentes y similares	314	0	364	0	16
2115	204	Comisiones pagadas a sociedades, nacionales o extranjeras residentes en el Ecuador y establecimientos permanentes domiciliados en el país	3140	0	3640	0	17
2116	204	Arrendamiento\n.Mercantil	319	0	369	0	18
2117	204	.Bienes inmuebles	320	0	370	0	19
2118	204	RELACIONADAS CON EL CAPITAL ( RENDIMIENTOS, GANANCIAS, DIVIDENDOS Y OTROS)\nRendimientos financieros	323	0	373	0	20
2119	204	Rendimientos financieros entre instituciones del sistema financiero y entidades economía popular y solidaria	324	0	374	0	21
2120	204	Ganancia en la enajenación de derechos representativos de capital u otros derechos que permitan la exploración, explotación, concesión o	333	0	383	0	22
2121	204	similares de sociedades, que se coticen en las bolsas de valores del Ecuador\nContraprestación en la enajenación de derechos representativos de capital u otros derechos que permitan la exploración, explotación, concesión o	334	0	384	0	23
2122	204	similares de sociedades, no cotizados en las bolsas de valores del Ecuador\nPOR LOTERIAS Y PREMIOS\nLoterías, rifas, apuestas, pronósticos deportivos y similares	335	0	385	0	24
2123	204	AUTORRETENCIONES Y OTRAS RETENCIONES\nVenta de combustibles\n.A comercializadoras	336	0	386	0	25
2124	204	.A distribuidores	337	0	387	0	26
2125	204	Retención a cargo del propio sujeto pasivo por la comercialización de productos forestales	3370	0	3870	0	27
2126	204	RLRTI)	350	0	400	0	28
2127	204	. Aplicables a otros porcentajes ( Por Donaciones en dinero -Impuesto a las donaciones )	346	0	396	0	29
2128	204	Pagos de bienes y servicios no sujetos a retención (Código 332)	332	6539.43	N/A	0	30
\.


--
-- Data for Name: form_103_totals; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.form_103_totals (id, document_id, subtotal_operaciones_pais, total_retencion, total_impuesto_pagar, total_pagado, subtotal_retencion, interes_mora, multa, pagos_no_sujetos, otras_retenciones_base, otras_retenciones_retenido) FROM stdin;
74	202	16388.18	187.46	187.46	187.46	187.46	0	0	1503.17	82.91	2.28
75	204	41732.85	506.48	506.48	506.48	506.48	0	0	6539.43	165.91	4.56
\.


--
-- Data for Name: form_104_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.form_104_data (id, document_id, ventas_tarifa_diferente_cero_bruto, ventas_tarifa_diferente_cero_neto, impuesto_generado, total_ventas_bruto, total_ventas_neto, total_impuesto_generado, adquisiciones_tarifa_diferente_cero_bruto, adquisiciones_tarifa_diferente_cero_neto, impuesto_compras, adquisiciones_tarifa_cero, total_adquisiciones, credito_tributario_aplicable, retenciones_iva, impuesto_causado, retenciones_efectuadas, subtotal_a_pagar, total_impuesto_retenido, total_impuesto_pagar_retencion, total_consolidado_iva, total_pagado, total_impuesto_pagar_percepcion, total_impuesto_a_pagar, interes_mora, multa) FROM stdin;
72	203	36088.15	36080.04	5412.01	36088.15	36080.04	5412.01	9622.7	9515.22	1427.28	3238.99	13358.99	1427.28	[{"porcentaje": 10, "valor": 0.0}, {"porcentaje": 20, "valor": 0.0}, {"porcentaje": 30, "valor": 111.66}, {"porcentaje": 50, "valor": 0.0}, {"porcentaje": 70, "valor": 11.18}, {"porcentaje": 100, "valor": 342.31}]	3984.73	1491.71	2493.02	465.15	465.15	2958.17	2958.17	0	0	0	0
73	205	20362.68	20362.68	3054.4	20362.68	20362.68	3054.4	10473.22	10282.5	1542.38	18176.62	33992.64	1542.38	[{"porcentaje": 10, "valor": 0.0}, {"porcentaje": 20, "valor": 0.0}, {"porcentaje": 30, "valor": 388.09}, {"porcentaje": 50, "valor": 0.0}, {"porcentaje": 70, "valor": 9.35}, {"porcentaje": 100, "valor": 76.48}]	1512.02	829.1	682.92	473.92	473.92	1156.84	1156.84	0	0	0	0
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, email, hashed_password, is_active, is_superuser, created_at, last_login, reset_token, reset_token_expires) FROM stdin;
2	braco	bryandpaw@gmail.com	$2b$12$8P.NInWIq1dmLICLWX0kZumDPUOXve0dVfVKWh.rVYORPl1QoS75u	t	f	2025-12-02 02:00:58.009199+00	\N	\N	\N
3	bracosmo	bracosmo@gmail.com	$2b$12$yhdNWy78akgvYLACDTqiyu0lEZVTOq0w13uKhAfKLhnc9s7ZpZOVO	t	f	2025-12-02 02:11:31.791184+00	\N	\N	\N
4	Bryan	dev@capbraco.com	$2b$12$3xHtDYqbD0MiMLdjrMggqeVZI99f7RtIh90sdwFDfWbkLw.KPQMwq	t	f	2025-12-02 02:13:28.304723+00	\N	\N	\N
5	andres	bracosmo@hotmail.com	$2b$12$usjUgf8pvIsGgAU2oLk2rex/UQHGRfxqw7myVBpUC/M4LaNYRTIxO	t	f	2025-12-02 07:21:01.74437+00	\N	\N	\N
6	braco123	braco@gmail.com	$2b$12$AhSBmvi1PdC8Dr62XYG.WuWjM0cTsNdVNPGGc40MgpZjiIxysy4ra	t	f	2025-12-02 07:24:16.328772+00	\N	\N	\N
7	andres123	andres@gmail.com	$2b$12$ae6TpMWdwH1S2tadKziT6uCgAOGkq0R/kvpAcf1bTX1tNTDggK67y	t	f	2025-12-02 07:25:33.028326+00	2025-12-02 07:48:14.497715+00	\N	\N
1	admin	admin@example.com	$2b$12$G2i17/i5I9PfOS/jtLJBbObdGFfw9pWkQpoFLtAGM..ul2IQQf6ZW	t	t	2025-11-29 03:24:28.127504+00	2025-12-02 08:05:19.645012+00	\N	\N
\.


--
-- Name: documents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.documents_id_seq', 205, true);


--
-- Name: form_103_line_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.form_103_line_items_id_seq', 2128, true);


--
-- Name: form_103_totals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.form_103_totals_id_seq', 75, true);


--
-- Name: form_104_data_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.form_104_data_id_seq', 73, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 7, true);


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
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


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
-- PostgreSQL database dump complete
--

\unrestrict OHWrVRsU7LCteyJm91i4gWtLYcX1nmDucV5ZJbGEKR2QtsUFnk1IobcPaPOBigt

