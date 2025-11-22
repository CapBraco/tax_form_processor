--
-- PostgreSQL database dump
--

\restrict bWy4o3fqVYYNwaH3Hh0AofRFd5MoyXJjgAA75wJJlzQHXzI1q5yP87HMtx0TA8O

-- Dumped from database version 15.14
-- Dumped by pg_dump version 15.14

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
    processed_at timestamp with time zone
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


ALTER TABLE public.documents_id_seq OWNER TO postgres;

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


ALTER TABLE public.form_103_line_items_id_seq OWNER TO postgres;

--
-- Name: form_103_line_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.form_103_line_items_id_seq OWNED BY public.form_103_line_items.id;


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
    total_pagado double precision
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


ALTER TABLE public.form_104_data_id_seq OWNER TO postgres;

--
-- Name: form_104_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.form_104_data_id_seq OWNED BY public.form_104_data.id;


--
-- Name: documents id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents ALTER COLUMN id SET DEFAULT nextval('public.documents_id_seq'::regclass);


--
-- Name: form_103_line_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.form_103_line_items ALTER COLUMN id SET DEFAULT nextval('public.form_103_line_items_id_seq'::regclass);


--
-- Name: form_104_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.form_104_data ALTER COLUMN id SET DEFAULT nextval('public.form_104_data_id_seq'::regclass);


--
-- Data for Name: documents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.documents (id, filename, original_filename, file_path, file_size, form_type, extracted_text, total_pages, total_characters, parsed_data, codigo_verificador, numero_serial, fecha_recaudacion, identificacion_ruc, razon_social, periodo_mes, periodo_anio, processing_status, processing_error, uploaded_at, processed_at) FROM stdin;
1	94684008dc0a4d1ea1e1575c37ca1a15.pdf	103 DECLARACION JUNIO.pdf	./uploads\\94684008dc0a4d1ea1e1575c37ca1a15.pdf	149938	FORM_103	=== Page 1 ===\nObligación Tributaria: 1031 - DECLARACIÓN DE RETENCIONES EN LA FUENTE\nIdentificación: 1792234026001 Razón Social: GAMA EDITORES REYES MEDINA CIA. LTDA.\nPeríodo Fiscal: JUNIO 2025 Tipo Declaración: ORIGINAL\nFormulario Sustituye:\n.\nDETALLE DE PAGOS Y RETENCIÓN POR IMPUESTO A LA RENTA\nPOR PAGOS EFECTUADOS A RESIDENTES Y ESTABLECIMIENTOS PERMANENTES\nDERIVADAS DEL TRABAJO Y SERVICIOS PRESTADOS\nBASE VALOR\nIMPONIBLE RETENIDO\nEn relación de dependencia que supera o no la base desgravada 302 7905.59 352 0.00\nServicios\n.Honorarios profesionales 303 340.00 353 34.00\n.Servicios profesionales prestados por sociedades residentes 3030 0.00 3530 0.00\n.Predomina el intelecto 304 0.00 354 0.00\n.Predomina la mano de obra 307 0.00 357 0.00\n.Utilización o aprovechamiento de la imagen o renombre (personas naturales, sociedades, influencers) 308 0.00 358 0.00\n.Publicidad y comunicación 309 0.00 359 0.00\n.Transporte privado de pasajeros o servicio público o privado de carga 310 101.50 360 1.03\nA través de liquidaciones de compra (nivel cultural o rusticidad) 311 0.00 361 0.00\nPOR BIENES Y SERVICIOS\nTransferencia de bienes muebles de naturaleza corporal 312 1788.00 362 31.29\nSeguros y reaseguros (primas y cesiones) 322 0.00 372 0.00\nCOMPRAS AL PRODUCTOR: de bienes de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuático, forestal y carnes en estado natural y 3120 0.00 3620 0.00\nlos descritos en el art.27.1 de LRTI.\nLa información reposa en la base de datos del SRI, conforme la declaraciónrealizada por el contribuyente\nCÓDIGO VERIFICADOR NÚMERO SERIAL FECHA RECAUDACIÓN PÁGINA\nSRIDEC2025132437674 872869024132 09-07-2025 1\n\n=== Page 2 ===\nCOMPRAS AL COMERCIALIZADOR: de bienes de origen agrícola, avícola, pecuario, apícola, cunícola, bioacuático, forestal y carnes en estado 3121 0.00 3621 0.00\nnatural y los descritos en el art.27.1 de LRTI.\nActividades de construcción de obra material inmueble, urbanización, lotización o actividades similares 3430 0.00 3450 0.00\nPagos aplicables el 1% (Energía Eléctrica y régimen RIMPE - Emprendedores, para este caso aplica con cualquier forma de pago inclusive los 343 0.00 393 0.00\npagos que deban realizar las tarjetas de crédito/débito)\nPagos aplicables el 2% (incluye Pago local tarjeta de crédito /débito reportada por la Emisora de tarjeta de crédito / entidades del sistema 344 0.00 394 0.00\nfinanciero; adquisición de sustancias minerales dentro del territorio nacional; Recepción de botellas plásticas no retornables de PET)\nPagos de bienes y servicios no sujetos a retención o con 0% (distintos de rendimientos financieros) 332 13543.01\nPOR REGALIAS, COMISIONES, ARRENDAMIENTOS Y OTROS\nPor regalías, derechos de autor, marcas, patentes y similares 314 0.00 364 0.00\nComisiones pagadas a sociedades, nacionales o extranjeras residentes en el Ecuador y establecimientos permanentes domiciliados en el país 3140 0.00 3640 0.00\nArrendamiento\n.Mercantil 319 0.00 369 0.00\n.Bienes inmuebles 320 0.00 370 0.00\nRELACIONADAS CON EL CAPITAL ( RENDIMIENTOS, GANANCIAS, DIVIDENDOS Y OTROS)\nRendimientos financieros 323 0.00 373 0.00\nRendimientos financieros entre instituciones del sistema financiero y entidades economía popular y solidaria 324 0.00 374 0.00\nOtros Rendimientos financieros 0% 3230 0.00\nGanancia en la enajenación de derechos representativos de capital u otros derechos que permitan la exploración, explotación, concesión o similares 333 0.00 383 0.00\nde sociedades, que se coticen en las bolsas de valores del Ecuador\nContraprestación en la enajenación de derechos representativos de capital u otros derechos que permitan la exploración, explotación, concesión o 334 0.00 384 0.00\nsimilares de sociedades, no cotizados en las bolsas de valores del Ecuador\nPOR LOTERIAS Y PREMIOS\nLoterías, rifas, apuestas, pronósticos deportivos y similares 335 0.00 385 0.00\nAUTORRETENCIONES Y OTRAS RETENCIONES\nVenta de combustibles\n.A comercializadoras 336 0.00 386 0.00\n.A distribuidores 337 0.00 387 0.00\nRetención a cargo del propio sujeto pasivo por la comercialización de productos forestales 3370 0.00 3870 0.00\nOtras autorretenciones (inciso 1 y 2 Art.92.1 RLRTI) 350 0.00 400 0.00\nOtras retenciones\nLa información reposa en la base de datos del SRI, conforme la declaraciónrealizada por el contribuyente\nCÓDIGO VERIFICADOR NÚMERO SERIAL FECHA RECAUDACIÓN PÁGINA\nSRIDEC2025132437674 872869024132 09-07-2025 2\n\n=== Page 3 ===\n. Aplicables el 2,75% 3440 52.72 3940 1.45\n. Aplicables a otros porcentajes ( Por Donaciones en dinero -Impuesto a las donaciones ) 346 0.00 396 0.00\nLIQUIDACIÓN DE IMPUESTO A LA RENTA ÚNICO\nIRU Pronósticos deportivos\n. (+) Ingresos generados por la actividad económica de pronósticos deportivos 3483 0.00\n. (+) Comisiones derivadas de la actividad de pronósticos deportivos 3484 0.00\n. (-) Premios pagados por pronósticos deportivos 3485 0.00\nImpuesto a la renta único sobre los ingresos percibidos por los operadores de pronósticos deportivos 3480 0.00 3980 0.00\nSUBTOTAL OPERACIONES EFECTUADAS EN EL PAÍS 349 23730.82 399 67.77\nBASE VALOR\nIMPONIBLE RETENIDO\nTOTAL DE RETENCIÓN DE IMPUESTO A LA RENTA 399 + 498 499 67.77\n.\nVALORES A PAGAR (luego de imputación al pago)\nTOTAL IMPUESTO A PAGAR 499 - 898 902 67.77\nInterés por mora 903 0.00\nMulta 904 0.00\nTOTAL PAGADO 999 67.77\nLa información reposa en la base de datos del SRI, conforme la declaraciónrealizada por el contribuyente\nCÓDIGO VERIFICADOR NÚMERO SERIAL FECHA RECAUDACIÓN PÁGINA\nSRIDEC2025132437674 872869024132 09-07-2025 3\n	3	5491	{"form_type": "form_103", "header": {"codigo_verificador": "N", "obligacion_tributaria": "1031 - DECLARACI\\u00d3N DE RETENCIONES EN LA FUENTE\\nIdentificaci\\u00f3n", "identificacion": "1792234026001", "razon_social": "GAMA EDITORES REYES MEDINA CIA. LTDA.", "periodo_mes": "JUNIO", "periodo_anio": "2025", "tipo_declaracion": "ORIGINAL"}, "line_items": [{"concepto": ".\\nDETALLE DE PAGOS Y RETENCI\\u00d3N POR IMPUESTO A LA RENTA\\nPOR PAGOS EFECTUADOS A RESIDENTES Y ESTABLECIMIENTOS PERMANENTES\\nDERIVADAS DEL TRABAJO Y SERVICIOS PRESTADOS\\nBASE VALOR\\nIMPONIBLE RETENIDO\\nEn relaci\\u00f3n de dependencia que supera o no la base desgravada", "codigo_base": "302", "base_imponible": 7905.59, "codigo_retencion": "352", "valor_retenido": 0.0}, {"concepto": "Servicios\\n.Honorarios profesionales", "codigo_base": "303", "base_imponible": 340.0, "codigo_retencion": "353", "valor_retenido": 34.0}, {"concepto": ".Transporte privado de pasajeros o servicio p\\u00fablico o privado de carga", "codigo_base": "310", "base_imponible": 101.5, "codigo_retencion": "360", "valor_retenido": 1.03}, {"concepto": "POR BIENES Y SERVICIOS\\nTransferencia de bienes muebles de naturaleza corporal", "codigo_base": "312", "base_imponible": 1788.0, "codigo_retencion": "362", "valor_retenido": 31.29}], "totals": {"subtotal_operaciones": 67.77, "total_retencion": 67.77, "total_impuesto_pagar": 67.77, "intereses": 0.0, "multa": 0.0, "total_pagado": 67.77}}	N	\N	\N	1792234026001	GAMA EDITORES REYES MEDINA CIA. LTDA.	JUNIO	2025	COMPLETED	\N	2025-11-22 01:20:41.815415+00	2025-11-22 06:20:41.101224+00
\.


--
-- Data for Name: form_103_line_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.form_103_line_items (id, document_id, concepto, codigo_base, base_imponible, codigo_retencion, valor_retenido, order_index) FROM stdin;
1	1	.\nDETALLE DE PAGOS Y RETENCIÓN POR IMPUESTO A LA RENTA\nPOR PAGOS EFECTUADOS A RESIDENTES Y ESTABLECIMIENTOS PERMANENTES\nDERIVADAS DEL TRABAJO Y SERVICIOS PRESTADOS\nBASE VALOR\nIMPONIBLE RETENIDO\nEn relación de dependencia que supera o no la base desgravada	302	7905.59	352	0	0
2	1	Servicios\n.Honorarios profesionales	303	340	353	34	1
3	1	.Transporte privado de pasajeros o servicio público o privado de carga	310	101.5	360	1.03	2
4	1	POR BIENES Y SERVICIOS\nTransferencia de bienes muebles de naturaleza corporal	312	1788	362	31.29	3
\.


--
-- Data for Name: form_104_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.form_104_data (id, document_id, ventas_tarifa_diferente_cero_bruto, ventas_tarifa_diferente_cero_neto, impuesto_generado, total_ventas_bruto, total_ventas_neto, total_impuesto_generado, adquisiciones_tarifa_diferente_cero_bruto, adquisiciones_tarifa_diferente_cero_neto, impuesto_compras, adquisiciones_tarifa_cero, total_adquisiciones, credito_tributario_aplicable, retenciones_iva, impuesto_causado, retenciones_efectuadas, subtotal_a_pagar, total_impuesto_retenido, total_impuesto_pagar_retencion, total_consolidado_iva, total_pagado) FROM stdin;
\.


--
-- Name: documents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.documents_id_seq', 1, true);


--
-- Name: form_103_line_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.form_103_line_items_id_seq', 4, true);


--
-- Name: form_104_data_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.form_104_data_id_seq', 1, false);


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
-- Name: form_104_data form_104_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.form_104_data
    ADD CONSTRAINT form_104_data_pkey PRIMARY KEY (id);


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
-- Name: ix_form_104_data_document_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_form_104_data_document_id ON public.form_104_data USING btree (document_id);


--
-- Name: ix_form_104_data_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_form_104_data_id ON public.form_104_data USING btree (id);


--
-- Name: form_103_line_items form_103_line_items_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.form_103_line_items
    ADD CONSTRAINT form_103_line_items_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.documents(id) ON DELETE CASCADE;


--
-- Name: form_104_data form_104_data_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.form_104_data
    ADD CONSTRAINT form_104_data_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.documents(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict bWy4o3fqVYYNwaH3Hh0AofRFd5MoyXJjgAA75wJJlzQHXzI1q5yP87HMtx0TA8O

