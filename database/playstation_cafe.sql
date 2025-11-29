--
-- PostgreSQL database dump
--

\restrict 6lj7ZE9ecOxlyoEotdzUBzW7pbbko4iC8oBwAX0HPdc6YGX60pi8Rxp6CVKvLc4

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

-- Started on 2025-11-29 22:12:35

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
-- TOC entry 236 (class 1255 OID 24655)
-- Name: check_device_status(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_device_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    active_count INT;
BEGIN
    SELECT COUNT(*) INTO active_count
    FROM sessions
    WHERE device_id = NEW.device_id
      AND status = 'active';

    IF active_count > 0 THEN
        RAISE EXCEPTION 'Device % is already in an active session', NEW.device_id;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_device_status() OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 24580)
-- Name: validate_subtype(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validate_subtype() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if new.subtype_id is not null then
		if new.type_id != (select device_type_id from device_subtype where id = new.subtype_id) then
		   raise exception 'subtype does not match type';
		end if;
	end if;
	return new;
end;
$$;


ALTER FUNCTION public.validate_subtype() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 226 (class 1259 OID 16457)
-- Name: device; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.device (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    type_id integer,
    subtype_id integer,
    price_per_hour integer NOT NULL
);


ALTER TABLE public.device OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16456)
-- Name: device_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.device_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.device_id_seq OWNER TO postgres;

--
-- TOC entry 5002 (class 0 OID 0)
-- Dependencies: 225
-- Name: device_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.device_id_seq OWNED BY public.device.id;


--
-- TOC entry 224 (class 1259 OID 16429)
-- Name: device_subtype; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.device_subtype (
    id integer CONSTRAINT subdevice_type_id_not_null NOT NULL,
    device_type_id integer,
    name character varying(50) CONSTRAINT subdevice_type_name_not_null NOT NULL
);


ALTER TABLE public.device_subtype OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16420)
-- Name: device_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.device_type (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.device_type OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16419)
-- Name: device_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.device_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.device_type_id_seq OWNER TO postgres;

--
-- TOC entry 5003 (class 0 OID 0)
-- Dependencies: 221
-- Name: device_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.device_type_id_seq OWNED BY public.device_type.id;


--
-- TOC entry 232 (class 1259 OID 24616)
-- Name: product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product (
    id integer NOT NULL,
    category_id integer CONSTRAINT product_category_id_not_null1 NOT NULL,
    name character varying(25) NOT NULL,
    price integer NOT NULL
);


ALTER TABLE public.product OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 24606)
-- Name: product_category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_category (
    id integer NOT NULL,
    name character varying(25) NOT NULL
);


ALTER TABLE public.product_category OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 24605)
-- Name: product_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.product_category ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.product_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 231 (class 1259 OID 24615)
-- Name: product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.product ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 234 (class 1259 OID 24633)
-- Name: session_order_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session_order_details (
    id integer NOT NULL,
    session_id integer NOT NULL,
    product_id integer NOT NULL,
    price numeric(10,2) NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    subtotal numeric(10,2) NOT NULL
);


ALTER TABLE public.session_order_details OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 24632)
-- Name: session_order_details_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.session_order_details ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.session_order_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 228 (class 1259 OID 24583)
-- Name: sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sessions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    device_id integer NOT NULL,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone,
    total_time interval,
    device_price numeric(10,2),
    order_price numeric(10,2),
    sub_total numeric(10,2),
    status character varying(20) DEFAULT 'active'::character varying,
    created_at timestamp without time zone DEFAULT now(),
    ended_at timestamp without time zone
);


ALTER TABLE public.sessions OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 24582)
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.sessions ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 223 (class 1259 OID 16428)
-- Name: subdevice_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.subdevice_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.subdevice_type_id_seq OWNER TO postgres;

--
-- TOC entry 5004 (class 0 OID 0)
-- Dependencies: 223
-- Name: subdevice_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.subdevice_type_id_seq OWNED BY public.device_subtype.id;


--
-- TOC entry 220 (class 1259 OID 16395)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    role character varying(50) DEFAULT 'employee'::character varying NOT NULL,
    email character varying(50) NOT NULL,
    password character varying(250) NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16394)
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
-- TOC entry 5005 (class 0 OID 0)
-- Dependencies: 219
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 4796 (class 2604 OID 16460)
-- Name: device id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device ALTER COLUMN id SET DEFAULT nextval('public.device_id_seq'::regclass);


--
-- TOC entry 4795 (class 2604 OID 16432)
-- Name: device_subtype id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_subtype ALTER COLUMN id SET DEFAULT nextval('public.subdevice_type_id_seq'::regclass);


--
-- TOC entry 4794 (class 2604 OID 16423)
-- Name: device_type id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_type ALTER COLUMN id SET DEFAULT nextval('public.device_type_id_seq'::regclass);


--
-- TOC entry 4792 (class 2604 OID 16398)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 4988 (class 0 OID 16457)
-- Dependencies: 226
-- Data for Name: device; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.device (id, name, type_id, subtype_id, price_per_hour) FROM stdin;
4	device1	2	1	20
5	device2	2	2	30
6	device3	2	3	40
7	device4	2	4	50
12	device5	2	2	30
15	device6	3	5	10
16	device7	3	6	10
20	device9	3	5	20
\.


--
-- TOC entry 4986 (class 0 OID 16429)
-- Dependencies: 224
-- Data for Name: device_subtype; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.device_subtype (id, device_type_id, name) FROM stdin;
1	2	ps2
2	2	ps3
3	2	ps4
4	2	ps5
5	3	pc
6	3	laptop
\.


--
-- TOC entry 4984 (class 0 OID 16420)
-- Dependencies: 222
-- Data for Name: device_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.device_type (id, name) FROM stdin;
2	ps
3	computer
\.


--
-- TOC entry 4994 (class 0 OID 24616)
-- Dependencies: 232
-- Data for Name: product; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product (id, category_id, name, price) FROM stdin;
1	1	nescafe	20
2	1	cofee	20
3	1	tea	10
4	2	pepsi	10
5	2	7up	10
6	2	merinda	10
7	2	ice cofee	50
8	2	red bull	50
9	4	chepsi	10
10	4	flaminko	10
11	4	chetos	10
\.


--
-- TOC entry 4992 (class 0 OID 24606)
-- Dependencies: 230
-- Data for Name: product_category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_category (id, name) FROM stdin;
1	hot drinks
2	cold drinks
4	snaks
\.


--
-- TOC entry 4996 (class 0 OID 24633)
-- Dependencies: 234
-- Data for Name: session_order_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session_order_details (id, session_id, product_id, price, quantity, subtotal) FROM stdin;
2	2	7	50.00	3	150.00
\.


--
-- TOC entry 4990 (class 0 OID 24583)
-- Dependencies: 228
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sessions (id, user_id, device_id, start_time, end_time, total_time, device_price, order_price, sub_total, status, created_at, ended_at) FROM stdin;
2	1	4	2025-11-29 20:21:56.533392	\N	\N	50.00	0.00	0.00	active	2025-11-29 20:21:56.533392	\N
\.


--
-- TOC entry 4982 (class 0 OID 16395)
-- Dependencies: 220
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, role, email, password) FROM stdin;
1	mostafa	admin	mostafa@gmail.com	123456
\.


--
-- TOC entry 5006 (class 0 OID 0)
-- Dependencies: 225
-- Name: device_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.device_id_seq', 20, true);


--
-- TOC entry 5007 (class 0 OID 0)
-- Dependencies: 221
-- Name: device_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.device_type_id_seq', 3, true);


--
-- TOC entry 5008 (class 0 OID 0)
-- Dependencies: 229
-- Name: product_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_category_id_seq', 4, true);


--
-- TOC entry 5009 (class 0 OID 0)
-- Dependencies: 231
-- Name: product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_id_seq', 11, true);


--
-- TOC entry 5010 (class 0 OID 0)
-- Dependencies: 233
-- Name: session_order_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.session_order_details_id_seq', 2, true);


--
-- TOC entry 5011 (class 0 OID 0)
-- Dependencies: 227
-- Name: sessions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sessions_id_seq', 8, true);


--
-- TOC entry 5012 (class 0 OID 0)
-- Dependencies: 223
-- Name: subdevice_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.subdevice_type_id_seq', 6, true);


--
-- TOC entry 5013 (class 0 OID 0)
-- Dependencies: 219
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 1, true);


--
-- TOC entry 4809 (class 2606 OID 24579)
-- Name: device device_name_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device
    ADD CONSTRAINT device_name_unique UNIQUE (name);


--
-- TOC entry 4811 (class 2606 OID 16464)
-- Name: device device_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device
    ADD CONSTRAINT device_pkey PRIMARY KEY (id);


--
-- TOC entry 4805 (class 2606 OID 16427)
-- Name: device_type device_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_type
    ADD CONSTRAINT device_type_pkey PRIMARY KEY (id);


--
-- TOC entry 4815 (class 2606 OID 24614)
-- Name: product_category product_category_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_category
    ADD CONSTRAINT product_category_name_key UNIQUE (name);


--
-- TOC entry 4817 (class 2606 OID 24612)
-- Name: product_category product_category_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_category
    ADD CONSTRAINT product_category_pkey PRIMARY KEY (id);


--
-- TOC entry 4819 (class 2606 OID 24626)
-- Name: product product_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_name_key UNIQUE (name);


--
-- TOC entry 4821 (class 2606 OID 24624)
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);


--
-- TOC entry 4823 (class 2606 OID 24644)
-- Name: session_order_details session_order_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_order_details
    ADD CONSTRAINT session_order_details_pkey PRIMARY KEY (id);


--
-- TOC entry 4813 (class 2606 OID 24594)
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 4807 (class 2606 OID 16436)
-- Name: device_subtype subdevice_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_subtype
    ADD CONSTRAINT subdevice_type_pkey PRIMARY KEY (id);


--
-- TOC entry 4801 (class 2606 OID 16408)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 4803 (class 2606 OID 16406)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4833 (class 2620 OID 24657)
-- Name: sessions trg_check_device_status; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_check_device_status BEFORE INSERT ON public.sessions FOR EACH ROW EXECUTE FUNCTION public.check_device_status();


--
-- TOC entry 4832 (class 2620 OID 24581)
-- Name: device trg_validate_device_subtype; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_validate_device_subtype BEFORE INSERT OR UPDATE ON public.device FOR EACH ROW EXECUTE FUNCTION public.validate_subtype();


--
-- TOC entry 4825 (class 2606 OID 16470)
-- Name: device device_subtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device
    ADD CONSTRAINT device_subtype_id_fkey FOREIGN KEY (subtype_id) REFERENCES public.device_subtype(id);


--
-- TOC entry 4826 (class 2606 OID 16465)
-- Name: device device_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device
    ADD CONSTRAINT device_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.device_type(id);


--
-- TOC entry 4829 (class 2606 OID 24627)
-- Name: product product_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.product_category(id);


--
-- TOC entry 4830 (class 2606 OID 24650)
-- Name: session_order_details session_order_details_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_order_details
    ADD CONSTRAINT session_order_details_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(id);


--
-- TOC entry 4831 (class 2606 OID 24645)
-- Name: session_order_details session_order_details_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session_order_details
    ADD CONSTRAINT session_order_details_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.sessions(id);


--
-- TOC entry 4827 (class 2606 OID 24600)
-- Name: sessions sessions_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.device(id);


--
-- TOC entry 4828 (class 2606 OID 24595)
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 4824 (class 2606 OID 16437)
-- Name: device_subtype subdevice_type_device_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_subtype
    ADD CONSTRAINT subdevice_type_device_type_id_fkey FOREIGN KEY (device_type_id) REFERENCES public.device_type(id);


-- Completed on 2025-11-29 22:12:35

--
-- PostgreSQL database dump complete
--

\unrestrict 6lj7ZE9ecOxlyoEotdzUBzW7pbbko4iC8oBwAX0HPdc6YGX60pi8Rxp6CVKvLc4

