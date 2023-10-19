--
-- PostgreSQL database dump
--

-- Dumped from database version 10.22 (Ubuntu 10.22-0ubuntu0.18.04.1)
-- Dumped by pg_dump version 10.22 (Ubuntu 10.22-0ubuntu0.18.04.1)

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
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: airdrops; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.airdrops (
    id integer NOT NULL,
    index integer NOT NULL,
    address character varying(42) NOT NULL,
    amount numeric(78,0) NOT NULL,
    token_symbol character varying(10) NOT NULL,
    contract_address character varying(42) NOT NULL,
    proof json NOT NULL,
    claimed_at_block integer,
    claimed_at_timestamp timestamp without time zone
);


ALTER TABLE public.airdrops OWNER TO postgres;

--
-- Name: airdrops_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.airdrops_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.airdrops_id_seq OWNER TO postgres;

--
-- Name: airdrops_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.airdrops_id_seq OWNED BY public.airdrops.id;


--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO postgres;

--
-- Name: claim_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.claim_status (
    id integer NOT NULL,
    claim_id integer NOT NULL,
    status integer NOT NULL,
    tx_hash text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL
);


ALTER TABLE public.claim_status OWNER TO postgres;

--
-- Name: claim_status_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.claim_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.claim_status_id_seq OWNER TO postgres;

--
-- Name: claim_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.claim_status_id_seq OWNED BY public.claim_status.id;


--
-- Name: claims; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.claims (
    id integer NOT NULL,
    protocol_id integer NOT NULL,
    initiator text NOT NULL,
    receiver text NOT NULL,
    exploit_started_at timestamp without time zone,
    amount numeric(78,0) NOT NULL,
    resources_link text,
    "timestamp" timestamp without time zone NOT NULL
);


ALTER TABLE public.claims OWNER TO postgres;

--
-- Name: claims_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.claims_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.claims_id_seq OWNER TO postgres;

--
-- Name: claims_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.claims_id_seq OWNED BY public.claims.id;


--
-- Name: fundraise_positions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fundraise_positions (
    id character varying(42) NOT NULL,
    stake numeric(78,0) NOT NULL,
    contribution numeric(78,0) NOT NULL,
    reward numeric(78,0) NOT NULL,
    claimable_at timestamp without time zone NOT NULL,
    claimed_at timestamp without time zone
);


ALTER TABLE public.fundraise_positions OWNER TO postgres;

--
-- Name: indexer_state; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.indexer_state (
    id integer NOT NULL,
    last_block integer NOT NULL,
    last_time timestamp without time zone NOT NULL,
    balance_factor numeric(78,70) NOT NULL,
    apy double precision NOT NULL,
    apy_50ms_factor numeric(78,70) NOT NULL,
    premiums_apy double precision NOT NULL,
    additional_apy double precision DEFAULT '0'::double precision NOT NULL,
    incentives_apy double precision DEFAULT '0'::double precision NOT NULL
);


ALTER TABLE public.indexer_state OWNER TO postgres;

--
-- Name: indexer_state_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.indexer_state_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.indexer_state_id_seq OWNER TO postgres;

--
-- Name: indexer_state_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.indexer_state_id_seq OWNED BY public.indexer_state.id;


--
-- Name: interval_functions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.interval_functions (
    name text NOT NULL,
    block_last_run integer DEFAULT 0
);


ALTER TABLE public.interval_functions OWNER TO postgres;

--
-- Name: protocols; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.protocols (
    id integer NOT NULL,
    bytes_identifier text NOT NULL,
    agent text NOT NULL,
    coverage_ended_at timestamp without time zone,
    tvl numeric(78,0)
);


ALTER TABLE public.protocols OWNER TO postgres;

--
-- Name: protocols_coverages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.protocols_coverages (
    id integer NOT NULL,
    protocol_id integer NOT NULL,
    coverage_amount numeric(78,0) NOT NULL,
    coverage_amount_set_at timestamp without time zone NOT NULL,
    claimable_until timestamp without time zone
);


ALTER TABLE public.protocols_coverages OWNER TO postgres;

--
-- Name: protocols_coverages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.protocols_coverages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.protocols_coverages_id_seq OWNER TO postgres;

--
-- Name: protocols_coverages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.protocols_coverages_id_seq OWNED BY public.protocols_coverages.id;


--
-- Name: protocols_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.protocols_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.protocols_id_seq OWNER TO postgres;

--
-- Name: protocols_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.protocols_id_seq OWNED BY public.protocols.id;


--
-- Name: protocols_premiums; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.protocols_premiums (
    id integer NOT NULL,
    protocol_id integer NOT NULL,
    premium numeric(78,0) NOT NULL,
    premium_set_at timestamp without time zone NOT NULL
);


ALTER TABLE public.protocols_premiums OWNER TO postgres;

--
-- Name: protocols_premiums_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.protocols_premiums_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.protocols_premiums_id_seq OWNER TO postgres;

--
-- Name: protocols_premiums_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.protocols_premiums_id_seq OWNED BY public.protocols_premiums.id;


--
-- Name: staking_positions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.staking_positions (
    id bigint NOT NULL,
    owner character varying(42) NOT NULL,
    lockup_end timestamp without time zone NOT NULL,
    usdc numeric(78,0) NOT NULL,
    sher numeric(78,0) NOT NULL,
    restake_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.staking_positions OWNER TO postgres;

--
-- Name: staking_positions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.staking_positions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.staking_positions_id_seq OWNER TO postgres;

--
-- Name: staking_positions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.staking_positions_id_seq OWNED BY public.staking_positions.id;


--
-- Name: staking_positions_meta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.staking_positions_meta (
    id integer NOT NULL,
    usdc_last_updated timestamp without time zone NOT NULL,
    usdc_last_updated_block integer NOT NULL
);


ALTER TABLE public.staking_positions_meta OWNER TO postgres;

--
-- Name: staking_positions_meta_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.staking_positions_meta_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.staking_positions_meta_id_seq OWNER TO postgres;

--
-- Name: staking_positions_meta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.staking_positions_meta_id_seq OWNED BY public.staking_positions_meta.id;


--
-- Name: stats_apy; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stats_apy (
    id bigint NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    value double precision NOT NULL,
    block integer,
    premiums_apy double precision NOT NULL,
    incentives_apy double precision DEFAULT '0'::double precision NOT NULL
);


ALTER TABLE public.stats_apy OWNER TO postgres;

--
-- Name: stats_apy_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stats_apy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stats_apy_id_seq OWNER TO postgres;

--
-- Name: stats_apy_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stats_apy_id_seq OWNED BY public.stats_apy.id;


--
-- Name: stats_tvc; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stats_tvc (
    id bigint NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    block integer NOT NULL,
    value numeric(78,0) NOT NULL
);


ALTER TABLE public.stats_tvc OWNER TO postgres;

--
-- Name: stats_tvc_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stats_tvc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stats_tvc_id_seq OWNER TO postgres;

--
-- Name: stats_tvc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stats_tvc_id_seq OWNED BY public.stats_tvc.id;


--
-- Name: stats_tvl; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stats_tvl (
    id bigint NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    block integer NOT NULL,
    value numeric(78,0) NOT NULL
);


ALTER TABLE public.stats_tvl OWNER TO postgres;

--
-- Name: stats_tvl_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stats_tvl_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stats_tvl_id_seq OWNER TO postgres;

--
-- Name: stats_tvl_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stats_tvl_id_seq OWNED BY public.stats_tvl.id;


--
-- Name: strategy_balances; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.strategy_balances (
    id integer NOT NULL,
    address text NOT NULL,
    value numeric(78,0) NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    block integer NOT NULL
);


ALTER TABLE public.strategy_balances OWNER TO postgres;

--
-- Name: strategy_balances_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.strategy_balances_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.strategy_balances_id_seq OWNER TO postgres;

--
-- Name: strategy_balances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.strategy_balances_id_seq OWNED BY public.strategy_balances.id;


--
-- Name: airdrops id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.airdrops ALTER COLUMN id SET DEFAULT nextval('public.airdrops_id_seq'::regclass);


--
-- Name: claim_status id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.claim_status ALTER COLUMN id SET DEFAULT nextval('public.claim_status_id_seq'::regclass);


--
-- Name: claims id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.claims ALTER COLUMN id SET DEFAULT nextval('public.claims_id_seq'::regclass);


--
-- Name: indexer_state id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.indexer_state ALTER COLUMN id SET DEFAULT nextval('public.indexer_state_id_seq'::regclass);


--
-- Name: protocols id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.protocols ALTER COLUMN id SET DEFAULT nextval('public.protocols_id_seq'::regclass);


--
-- Name: protocols_coverages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.protocols_coverages ALTER COLUMN id SET DEFAULT nextval('public.protocols_coverages_id_seq'::regclass);


--
-- Name: protocols_premiums id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.protocols_premiums ALTER COLUMN id SET DEFAULT nextval('public.protocols_premiums_id_seq'::regclass);


--
-- Name: staking_positions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staking_positions ALTER COLUMN id SET DEFAULT nextval('public.staking_positions_id_seq'::regclass);


--
-- Name: staking_positions_meta id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staking_positions_meta ALTER COLUMN id SET DEFAULT nextval('public.staking_positions_meta_id_seq'::regclass);


--
-- Name: stats_apy id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stats_apy ALTER COLUMN id SET DEFAULT nextval('public.stats_apy_id_seq'::regclass);


--
-- Name: stats_tvc id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stats_tvc ALTER COLUMN id SET DEFAULT nextval('public.stats_tvc_id_seq'::regclass);


--
-- Name: stats_tvl id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stats_tvl ALTER COLUMN id SET DEFAULT nextval('public.stats_tvl_id_seq'::regclass);


--
-- Name: strategy_balances id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.strategy_balances ALTER COLUMN id SET DEFAULT nextval('public.strategy_balances_id_seq'::regclass);


--
-- Data for Name: airdrops; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.airdrops (id, index, address, amount, token_symbol, contract_address, proof, claimed_at_block, claimed_at_timestamp) FROM stdin;
1	0	0x01ebce016681D076667BDb823EBE1f76830DA6Fa	1178181818099999965184	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x1b41cc0a4ee2c40b44236dea2e5b3c89615cae87160fb31446f246b1c3c47738", "0xd5fa2002230416212cedc7ec997f33149ba6066ead27b3bb3342c2d4c348c3a0", "0xdc5e9a42776846027c0c3f09a89ff7480f2148f129c7806d06adffee3bf4e5bb", "0xd31c285ad6ee45c08c4e1e6f5bbcb746ce2ab52f77b254d01a650a2935523e57", "0x490b1fedef934dd64563585efd3d770c1bab290715fc9a278492a24b4b422ba2", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
2	1	0x03894d4ac41Dd6C4c2f524eD4417C90fA46972c6	471272727240000012288	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x63c3aae9a6e64cf6462b7964ad7e3139ff3c7dba90439470ed6fe5612a0f21ed", "0xc512ad2c2eccf14f002d9e094548cf1a4c7d5e17b78559bb53c8661d6835330f", "0xf409fdc8454ba1c159f34d3f739479f6f12feb4e3b404941b2415aa23a7cf5ce", "0x61ce104d4609443f391e8c0d51fee3bc23998b2b65998d5bcc08d6aa5aac6896", "0x5901ae8481b97bbe4d5d35652dd94bf3077153c9d61fefaeb6466961d62ce60f", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
3	2	0x040528e6eBdcBC6e37e3C78350dE0a59AedCe622	61029818177579999232	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0xf3e45a8cad394802de44bf44405a0c52c701e2aa282234c0a6cbece6870bbfd4", "0xe000fabba3388f63887fcb28155cb049633442adb671e966b71284085f750c14", "0x8dd95ee87883d64e1b2bbb11b1e43d326d825b97642e3bd3c933dcb548e3ad72", "0x4c46eb8bc36404efe92ffe5c9cb8009eb9ea5803aaaf1c21700aa71cb4af5be9", "0x6c33d461ce84630cfa59d1c023a43663a4cc424d18e146a326820bdecbbf1541", "0x760ec1bd66ff0cac3f4625d9c6d59fe5bf21be693b8480b69eadee0741e371a6"]	\N	\N
4	3	0x046f601CbcBfa162228897AC75C9B61dAF5cEe5F	121352727264300007424	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x4ba4386534486ddf4a97bf992106d1f63e4f8b9377642df041e22a150fda0ac2", "0xb42a8cfd8e53aa04ebf8a583d8381cde2f5214d8aac4f6b13802c449423ccbb5", "0x4018fbf869f9d6fe5604ff848f7bfd060bb0c4e99fa16e978cc0f96ef790de6c", "0xcb4bceac6c8f86ae9b8bdd6043564f96b4329c106f62d27bf88136944daeb5a4", "0x5901ae8481b97bbe4d5d35652dd94bf3077153c9d61fefaeb6466961d62ce60f", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
5	4	0x05ac3D28434804ec02eD9472490fC42D7e9E646d	236814545438099996672	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x1de7f2b8b48d8e1f902ccefae49a31371a42662ffec967e2298c237d40c63bf6", "0xd5fa2002230416212cedc7ec997f33149ba6066ead27b3bb3342c2d4c348c3a0", "0xdc5e9a42776846027c0c3f09a89ff7480f2148f129c7806d06adffee3bf4e5bb", "0xd31c285ad6ee45c08c4e1e6f5bbcb746ce2ab52f77b254d01a650a2935523e57", "0x490b1fedef934dd64563585efd3d770c1bab290715fc9a278492a24b4b422ba2", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
6	5	0x09D1E14bc93217B9F2d083509E94dEe161ffd9AC	24741818180099997696	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x9209a7366a243c219312a366797ef7d84cf602c5391bd846fe9939aa8d227ab9", "0x40321d1fcfd9c4528dab15089e51524ae0b92228fb3d2fcc98101480886b90e5", "0x9606926fc9e35ae9b108111a6bbd9ab8b8ddc7baf4219627c9abc4d0ddc48d70", "0x49bfc1ebde0a26040a747659843248eb44495ed23bd37063f8463e13af199eee", "0xf05367580303e7a3b3d1a36c4261ded32496f0ab7f13219354fb9b50bd990af2", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
7	6	0x0Aa3Dceb1e65b8f7d3a58Bed68054b1c81585002	241055999983260008448	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x4113bc5868f9ba4e3c4bd80c0f8ea635d06d0eb47a1296db395fc529572aa78b", "0x86b4965e919cbab34d7dd33ed632bb1232f9872072ea82888f3877958f4ee36d", "0x2d8bbbf1bfeb0913f3c979403e69b4e6e7a0ddb055f93a6d96cc4a1731592843", "0x2ded3fd83f7bb615a20af878fa1b23e72b7d0aa7028b4d82ab215baf4a74d36c", "0x490b1fedef934dd64563585efd3d770c1bab290715fc9a278492a24b4b422ba2", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
8	7	0x111CE8D46cd445F5aB1ce3545d97b45071DfECC0	3534545454299999633408	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x8933291ef544830b30f7eb732061f148a3782d16f2a2c6f39e889ede0abdad72", "0xbe4a85f859bda8d821f577daedcb161caa438cdf9bfd2755ea94aa93a7920a7a", "0x61e582ed77be6270088c0d1e28bfef05e2204331a756b9c31ac8b467b95fac0f", "0x4455359c34aec0ac25939e3cf63b1444ea0853d2248fa015055235e28b728f4d", "0x015d5f866c25a41e44b6f0b3af233acd3366dd33456735378eaeb945fd7c7cc5", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
9	8	0x153e2BD0CCdB0F78aa60d5EBc86EFB27Afd5eA3A	23900360725612980076544	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x8f5bd10032d5b91b8ccca39b950bdce850673b2a73dc21afa2c85d874beb00c1", "0xbe4a85f859bda8d821f577daedcb161caa438cdf9bfd2755ea94aa93a7920a7a", "0x61e582ed77be6270088c0d1e28bfef05e2204331a756b9c31ac8b467b95fac0f", "0x4455359c34aec0ac25939e3cf63b1444ea0853d2248fa015055235e28b728f4d", "0x015d5f866c25a41e44b6f0b3af233acd3366dd33456735378eaeb945fd7c7cc5", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
10	9	0x18Bd2e8B69E48C5E6DeAE13682b1F78d1c260bF9	266975999981459996672	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0xdfa4d668179891a09be0c7b374ba34f42727ff602be876560f1ca52edf2d2cec", "0xe1ed2a91af58ae10baa0f9554c688befe703112eeda57679a18df437a830bd8e", "0xa343e0b328e4c8303ac7b2bc8149a926cb80b4c55a9b3284490ae92d84e64151", "0x4c46eb8bc36404efe92ffe5c9cb8009eb9ea5803aaaf1c21700aa71cb4af5be9", "0x6c33d461ce84630cfa59d1c023a43663a4cc424d18e146a326820bdecbbf1541", "0x760ec1bd66ff0cac3f4625d9c6d59fe5bf21be693b8480b69eadee0741e371a6"]	\N	\N
11	10	0x19fde20744903805bA05e1522980Ffff3545C1EC	23799272725619998720	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0xaf2b4f06d6e8b7ce7511d33e2038b45e0ab18d690412fc0f53bab8164e372073", "0xda37578b5e7f4d0e0884660a70f70f57c5164b56c5c5bfc1862792dd63f0b432", "0x2cab8521a60969378036d595a3b7fbcfc9058bc7ca11609717bc8a13d757dc87", "0xdc5523bf2d165204ee0974224a5eb18decd7e388eb07236c1385e7ee39b57e46", "0xf05367580303e7a3b3d1a36c4261ded32496f0ab7f13219354fb9b50bd990af2", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
12	11	0x1A918A8386F75f382E2A1b2e10b807c39728caf2	11781818180999999488	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x38f4679edd1fb54d8159eb2bedb73073a85b3e5ce4a6a90efaa9120a8b4b9cb9", "0x6c4b75574380516b20a52bf96e9736c00d5b56f8f74433cfe39b5df7922104bf", "0x2d8bbbf1bfeb0913f3c979403e69b4e6e7a0ddb055f93a6d96cc4a1731592843", "0x2ded3fd83f7bb615a20af878fa1b23e72b7d0aa7028b4d82ab215baf4a74d36c", "0x490b1fedef934dd64563585efd3d770c1bab290715fc9a278492a24b4b422ba2", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
14	13	0x236884bb674067C96fcBCc5dff728141E05BE99d	260378181800100003840	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0xb4c2e22dc364e1a4da5dfb6b01f8d9beb641a269fc2222192126ed74fbb7f886", "0xa962fd7e3a7eac5d8872ffd5f02a22e6564f862044de01576b58fbfd191cec96", "0x961c5fd9b9c9d4645410c4a4a839440d497962ca898aa984b2e2631cb3cdc4da", "0xdc5523bf2d165204ee0974224a5eb18decd7e388eb07236c1385e7ee39b57e46", "0xf05367580303e7a3b3d1a36c4261ded32496f0ab7f13219354fb9b50bd990af2", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
15	14	0x276651CF20Ef719Dd3faE29e75f63E1603507517	172250181806219984896	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x9728ac118f4b86671a554add4aa45ff1e34ce29788fb9d376243e6473c2edd55", "0xa0971ca9709be3085c69da104035f34f657a9f3425e916fe63d93a193816dc6a", "0x9606926fc9e35ae9b108111a6bbd9ab8b8ddc7baf4219627c9abc4d0ddc48d70", "0x49bfc1ebde0a26040a747659843248eb44495ed23bd37063f8463e13af199eee", "0xf05367580303e7a3b3d1a36c4261ded32496f0ab7f13219354fb9b50bd990af2", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
16	15	0x2d220B4783A291AbB2db3618BC4d94C632E16206	235636363620000006144	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x872bb8f5db10cf7acb7e8f4dbc241fae893115936d3ae1df5da7366cd901c0d7", "0x43365c7c692ecc1b53b84a448d6889b145541f31b2e935d05e54d0715d952405", "0xccf7a2a6e00d39a52b7b2fd5e5b4e2a360c8ac004135561f3c5f66ae61814e56", "0x4455359c34aec0ac25939e3cf63b1444ea0853d2248fa015055235e28b728f4d", "0x015d5f866c25a41e44b6f0b3af233acd3366dd33456735378eaeb945fd7c7cc5", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
17	16	0x3524ff8D740a4f1be13F2cDd2F2345e54DC0c6B0	480933818148419993600	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x98b9c85bdf87cb21a02939110eaeb57696c34976b4a7633521a5c63065c18ec3", "0x82649a624bf0abf393b2d839b92dc7173b3223023955d2d6f7420bf26d549eaa", "0x661eae4b18968d5822ce4caac4a3e687c8ab5c2d0cfcad0834382aba5619308a", "0x49bfc1ebde0a26040a747659843248eb44495ed23bd37063f8463e13af199eee", "0xf05367580303e7a3b3d1a36c4261ded32496f0ab7f13219354fb9b50bd990af2", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
18	17	0x40dB5C12aA263660A6188A8e16fCdf9c5235E5bF	23554210907455200690176	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x3b14a8743eb2f36e192e89445b821dcdfacbc2ab30678eba87043b4440611605", "0x6c4b75574380516b20a52bf96e9736c00d5b56f8f74433cfe39b5df7922104bf", "0x2d8bbbf1bfeb0913f3c979403e69b4e6e7a0ddb055f93a6d96cc4a1731592843", "0x2ded3fd83f7bb615a20af878fa1b23e72b7d0aa7028b4d82ab215baf4a74d36c", "0x490b1fedef934dd64563585efd3d770c1bab290715fc9a278492a24b4b422ba2", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
19	18	0x4953b5F3980f0FE8584F84C9A1AD93013EBE29c6	227153454529679982592	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x6b24451494b84a66f26c792c3dbca23b0c8fac82a46a02500015db64a1f0fcc4", "0x018979e7326a778d8c6526f664a334abcd3a46c2731065c492e7659923955764", "0xf409fdc8454ba1c159f34d3f739479f6f12feb4e3b404941b2415aa23a7cf5ce", "0x61ce104d4609443f391e8c0d51fee3bc23998b2b65998d5bcc08d6aa5aac6896", "0x5901ae8481b97bbe4d5d35652dd94bf3077153c9d61fefaeb6466961d62ce60f", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
20	19	0x49eb81cc817cD5a1E8Df590F43D5A0A0F432251A	69983999995139997696	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0xb5f038bf2d119dbb9bc392ad90d16e9104a7ed1d29a3303391cec39717746afa", "0xa962fd7e3a7eac5d8872ffd5f02a22e6564f862044de01576b58fbfd191cec96", "0x961c5fd9b9c9d4645410c4a4a839440d497962ca898aa984b2e2631cb3cdc4da", "0xdc5523bf2d165204ee0974224a5eb18decd7e388eb07236c1385e7ee39b57e46", "0xf05367580303e7a3b3d1a36c4261ded32496f0ab7f13219354fb9b50bd990af2", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
21	20	0x520cc7572527711B8C50bceFe1d881F8ddb5Fe8C	471272727240000000	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x00baab5089ff96fc6f822ee160be52540c6203ba39e4717a32dca8791060bf44", "0x1fc8a9300f8272e74c83ed5f53aa9675d94fdff6b3feb2c6d5ae3d373bd19559", "0x37c54b2583e36a970b7f0766e4a3e0501640011d3b2ef27cebeac4537cf336c5", "0xd31c285ad6ee45c08c4e1e6f5bbcb746ce2ab52f77b254d01a650a2935523e57", "0x490b1fedef934dd64563585efd3d770c1bab290715fc9a278492a24b4b422ba2", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
22	21	0x543298794e7E195c8628f65D16fB7fcf7D096Cb0	2357070545290860167168	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0xe3e8c33485a7a0cd9b703bedf8d52f825ca2ad15f201ef7152d17629f1791a72", "0x61bf798828e80122cd2f1600d20ed7006555438ac6d9ffad402ebbb64b6529a5", "0xa343e0b328e4c8303ac7b2bc8149a926cb80b4c55a9b3284490ae92d84e64151", "0x4c46eb8bc36404efe92ffe5c9cb8009eb9ea5803aaaf1c21700aa71cb4af5be9", "0x6c33d461ce84630cfa59d1c023a43663a4cc424d18e146a326820bdecbbf1541", "0x760ec1bd66ff0cac3f4625d9c6d59fe5bf21be693b8480b69eadee0741e371a6"]	\N	\N
24	23	0x5a641C6fd5a473395355816EBC757b067CCaabE5	24741818180099997696	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x044d704f0d05768cf43d5931f24b23a90ef3616667ef31bd2755d63b7fecfd2b", "0x1fc8a9300f8272e74c83ed5f53aa9675d94fdff6b3feb2c6d5ae3d373bd19559", "0x37c54b2583e36a970b7f0766e4a3e0501640011d3b2ef27cebeac4537cf336c5", "0xd31c285ad6ee45c08c4e1e6f5bbcb746ce2ab52f77b254d01a650a2935523e57", "0x490b1fedef934dd64563585efd3d770c1bab290715fc9a278492a24b4b422ba2", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
13	12	0x1efb3038DE631CfcE0C0A231952c6B90d5D9cFE5	235636363620000006144	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x77f4f43f2cd26cbe373d196a89e6f6eff3b5e66b76a697d19dcd4a00504322b6", "0x35f4d533223cea4909ec8e1c39f15ff10fc665385f377674884d9920b1f3bd63", "0x3299bf318ec58326ab263fc668aba7856146c106c47d993bfc4cec61be75f926", "0xad372c3fad9326146ddee2133ce722db8bce5a6a263895ab96eba4c0b3c55172", "0x015d5f866c25a41e44b6f0b3af233acd3366dd33456735378eaeb945fd7c7cc5", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	15498755	2022-09-08 20:50:29
25	24	0x5a756d9C7cAA740E0342f755fa8Ad32e6F83726b	23799272725619998720	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x98bb260e6c162afccae5f11670617f82377c07322e37596f94ee26d34390ce78", "0x82649a624bf0abf393b2d839b92dc7173b3223023955d2d6f7420bf26d549eaa", "0x661eae4b18968d5822ce4caac4a3e687c8ab5c2d0cfcad0834382aba5619308a", "0x49bfc1ebde0a26040a747659843248eb44495ed23bd37063f8463e13af199eee", "0xf05367580303e7a3b3d1a36c4261ded32496f0ab7f13219354fb9b50bd990af2", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
26	25	0x605D50F68E737eBF7F6054D6f7860010FC80971F	1159095272646779994112	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x80955f1cda10af5c5a6d8ebe24c63f13100fd42fe55a56592c02d2537ba6d194", "0x1c4e6c1d316d4d762494b7d764ab148c6c314d4f4ebe30a99bc49a599270b7d7", "0xccf7a2a6e00d39a52b7b2fd5e5b4e2a360c8ac004135561f3c5f66ae61814e56", "0x4455359c34aec0ac25939e3cf63b1444ea0853d2248fa015055235e28b728f4d", "0x015d5f866c25a41e44b6f0b3af233acd3366dd33456735378eaeb945fd7c7cc5", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
27	26	0x60C42Ecb80C2069eb7aC1Ee18A84244c8617E8Ab	86478545448539996160	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x43bbc62034a781c3d9f1fca86041a6887cdbf99c04054f06986d1989a775925a", "0x9b0760019739fc0a5b3c7eab555ea819d26a1f3a5ff64a4d274eb60df715b9a2", "0x4ef4b3e1873f36435dbfaeecb6d4f326fab05d3dbca429bfd3d54c12a288290a", "0xcb4bceac6c8f86ae9b8bdd6043564f96b4329c106f62d27bf88136944daeb5a4", "0x5901ae8481b97bbe4d5d35652dd94bf3077153c9d61fefaeb6466961d62ce60f", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
28	27	0x60eE0C8Bb493b79286A54997322904f74fba3736	2356363636200000000	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x44d9f797a3d4078cb9cbeb1235486403a28eb32a551d902c2807e1ea5b0bd116", "0x9b0760019739fc0a5b3c7eab555ea819d26a1f3a5ff64a4d274eb60df715b9a2", "0x4ef4b3e1873f36435dbfaeecb6d4f326fab05d3dbca429bfd3d54c12a288290a", "0xcb4bceac6c8f86ae9b8bdd6043564f96b4329c106f62d27bf88136944daeb5a4", "0x5901ae8481b97bbe4d5d35652dd94bf3077153c9d61fefaeb6466961d62ce60f", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
29	28	0x61D9e931A72c9FB3eB9731dCc5A30f1F6C3ab63F	236578909074480005120	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x8786d1966334fd4426aa0605a4d228953225d0159b5d1763a46e5fed291896c9", "0xe7611ea12b2171f5144e234a3fc6a9b33444e92d854aeba053d22036fb3ab3c4", "0x61e582ed77be6270088c0d1e28bfef05e2204331a756b9c31ac8b467b95fac0f", "0x4455359c34aec0ac25939e3cf63b1444ea0853d2248fa015055235e28b728f4d", "0x015d5f866c25a41e44b6f0b3af233acd3366dd33456735378eaeb945fd7c7cc5", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
30	29	0x641f2f8cD5Fb6CB50a49c22247B065CD893a1FC7	90013090902840000512	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x0a669dca5172421d7efefbd23be794a4c2effded1a9eb10306caa5965dbe2883", "0xcc759575963322342177778ea031a5487f18768f2c927bdabc3fcbff24c8c266", "0xdc5e9a42776846027c0c3f09a89ff7480f2148f129c7806d06adffee3bf4e5bb", "0xd31c285ad6ee45c08c4e1e6f5bbcb746ce2ab52f77b254d01a650a2935523e57", "0x490b1fedef934dd64563585efd3d770c1bab290715fc9a278492a24b4b422ba2", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
31	30	0x644Be8a25BE30A21E2DFFeAE4FC43937fBCf3efd	118996363628099993600	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x75d608c5b08af9f84c3557fc1dae5e1657ec8fa2a20b8c1a432162da0c2675b9", "0x35f4d533223cea4909ec8e1c39f15ff10fc665385f377674884d9920b1f3bd63", "0x3299bf318ec58326ab263fc668aba7856146c106c47d993bfc4cec61be75f926", "0xad372c3fad9326146ddee2133ce722db8bce5a6a263895ab96eba4c0b3c55172", "0x015d5f866c25a41e44b6f0b3af233acd3366dd33456735378eaeb945fd7c7cc5", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
32	31	0x6A04941De896E4215Eeb8e6eb1b72AD2904D2402	294545454524999997063168	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x9e55bebee9a8dea3a43cc6e52a2d2163049016ec53f17d6ed80e779988fc5607", "0x1110c9bc05988f38c567eac2eab6781fd1f37379cd4696c901f880da2b90fd5b", "0x661eae4b18968d5822ce4caac4a3e687c8ab5c2d0cfcad0834382aba5619308a", "0x49bfc1ebde0a26040a747659843248eb44495ed23bd37063f8463e13af199eee", "0xf05367580303e7a3b3d1a36c4261ded32496f0ab7f13219354fb9b50bd990af2", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
33	32	0x6f9BB7e454f5B3eb2310343f0E99269dC2BB8A1d	5624404363245779943424	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0xc3515a8b162f254c3edb49ce79b9bdb71d6e17f42267c60faea84a60cee0f1ef", "0x0010bd0fa66856ae6682981c4a64bd1caefe2eaa72a848eb87362d554139699a", "0x3d33247cd6e9be538b9da120a046524eb2979e459bb0b87213cc4f24d85c6521", "0x4b02f63c85cfecbeb951e77076a033facf68ea61287f83afa33b0a7db04bf9b8", "0x6c33d461ce84630cfa59d1c023a43663a4cc424d18e146a326820bdecbbf1541", "0x760ec1bd66ff0cac3f4625d9c6d59fe5bf21be693b8480b69eadee0741e371a6"]	\N	\N
34	33	0x70F9E695823A748D0f492c86bE093c220a8d487a	3534545454299999744	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x28978cffde7951d0ec310f4f5f53105edd7311539c228de3c0e6679b4650ea38", "0x1d83ec68a3819f24d324fcd55afd4939e131c10df10a3e93f526bc33186eefb6", "0x5c29c482dcadea8915bcc92bdbcd9a3494d14e4e0d70879ccb251be14edd2e3d", "0x2ded3fd83f7bb615a20af878fa1b23e72b7d0aa7028b4d82ab215baf4a74d36c", "0x490b1fedef934dd64563585efd3d770c1bab290715fc9a278492a24b4b422ba2", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
35	34	0x72770a19522ACD2025b74dc130502F81a73F875C	611947636321139949568	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x9e64fee457688bfd6fa82d5558fb29e76c9ac84f4a7427aa6ad3b4edcc36d644", "0x1110c9bc05988f38c567eac2eab6781fd1f37379cd4696c901f880da2b90fd5b", "0x661eae4b18968d5822ce4caac4a3e687c8ab5c2d0cfcad0834382aba5619308a", "0x49bfc1ebde0a26040a747659843248eb44495ed23bd37063f8463e13af199eee", "0xf05367580303e7a3b3d1a36c4261ded32496f0ab7f13219354fb9b50bd990af2", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
36	35	0x78b8A76BEa31733777556033e2a116df66C4C41C	473629090876199993344	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x4e8f90e264434cd31107d9493906b34741e20829ae63078a1f60edc6a968b0d6", "0x5df1724991f9cabef70ddd8707038d6e80bea48b45e71aeca85490b65f6752ff", "0x4018fbf869f9d6fe5604ff848f7bfd060bb0c4e99fa16e978cc0f96ef790de6c", "0xcb4bceac6c8f86ae9b8bdd6043564f96b4329c106f62d27bf88136944daeb5a4", "0x5901ae8481b97bbe4d5d35652dd94bf3077153c9d61fefaeb6466961d62ce60f", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
37	36	0x7a86C44e1B41c6C37fF783E8f6B2f6c68AB251f4	141146181808380002304	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0xe3950c92c455f9a10f6542d9134630503fa98159b82a479c773b6f767ac29be2", "0x61bf798828e80122cd2f1600d20ed7006555438ac6d9ffad402ebbb64b6529a5", "0xa343e0b328e4c8303ac7b2bc8149a926cb80b4c55a9b3284490ae92d84e64151", "0x4c46eb8bc36404efe92ffe5c9cb8009eb9ea5803aaaf1c21700aa71cb4af5be9", "0x6c33d461ce84630cfa59d1c023a43663a4cc424d18e146a326820bdecbbf1541", "0x760ec1bd66ff0cac3f4625d9c6d59fe5bf21be693b8480b69eadee0741e371a6"]	\N	\N
38	37	0x7Ba080516dBAbe9fafc1f7F548F60d27e6932c48	23563636361999998976	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0xcae41381e7a06850421399847ba900695fb0e0d164e459a722288bf27cd8388c", "0x84c46c81cc110db6c7fda56c925b764738a40065305cd240d92a2d3a75fa3d4e", "0x8c5cb79fadf57d0f809a3a54af5c2fb5cfc033bfb5046faa57d73aa725ca2c61", "0x4b02f63c85cfecbeb951e77076a033facf68ea61287f83afa33b0a7db04bf9b8", "0x6c33d461ce84630cfa59d1c023a43663a4cc424d18e146a326820bdecbbf1541", "0x760ec1bd66ff0cac3f4625d9c6d59fe5bf21be693b8480b69eadee0741e371a6"]	\N	\N
39	38	0x7D51910845011B41Cc32806644dA478FEfF2f11F	23895883634704199450624	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x50f2e6eece0418a9e4e91453292c6925e3f2ed5647e8f8ed26a11e7c8fbc471e", "0x5df1724991f9cabef70ddd8707038d6e80bea48b45e71aeca85490b65f6752ff", "0x4018fbf869f9d6fe5604ff848f7bfd060bb0c4e99fa16e978cc0f96ef790de6c", "0xcb4bceac6c8f86ae9b8bdd6043564f96b4329c106f62d27bf88136944daeb5a4", "0x5901ae8481b97bbe4d5d35652dd94bf3077153c9d61fefaeb6466961d62ce60f", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
40	39	0x7df953D6BE5Fd9532a7E829cDFB72d2A9AB27000	235636363620000006144	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0xaa018e60ed39fcee47ddd40e47c9aeefa7d1c82275b309a7ad852c5491b6bede", "0x79595559cd5136bb1514564836982d23be219145836175ec91749e6001e2e4b5", "0x2cab8521a60969378036d595a3b7fbcfc9058bc7ca11609717bc8a13d757dc87", "0xdc5523bf2d165204ee0974224a5eb18decd7e388eb07236c1385e7ee39b57e46", "0xf05367580303e7a3b3d1a36c4261ded32496f0ab7f13219354fb9b50bd990af2", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
41	40	0x82bbF2B4Dc52d24Cbe0CbB6540bd4d4CeB2870B7	471272727240000012288	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0xd294f9e60696beb4fdae977fc8a19a1b2afc7e2b3675b81ae5addc785cfcd21f", "0x84c46c81cc110db6c7fda56c925b764738a40065305cd240d92a2d3a75fa3d4e", "0x8c5cb79fadf57d0f809a3a54af5c2fb5cfc033bfb5046faa57d73aa725ca2c61", "0x4b02f63c85cfecbeb951e77076a033facf68ea61287f83afa33b0a7db04bf9b8", "0x6c33d461ce84630cfa59d1c023a43663a4cc424d18e146a326820bdecbbf1541", "0x760ec1bd66ff0cac3f4625d9c6d59fe5bf21be693b8480b69eadee0741e371a6"]	\N	\N
42	41	0x88888882bb6125AF160999e91bCA82b56E0b819B	589090909049999982592	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x46b2a74e08101512f888048e5e57be9eb4c2da779fe3c95a0b0f88ba86cafd26", "0xed0036d9235cd6785282563008c22b14bca50bc7c118da2150362f6c2372bfd7", "0x4ef4b3e1873f36435dbfaeecb6d4f326fab05d3dbca429bfd3d54c12a288290a", "0xcb4bceac6c8f86ae9b8bdd6043564f96b4329c106f62d27bf88136944daeb5a4", "0x5901ae8481b97bbe4d5d35652dd94bf3077153c9d61fefaeb6466961d62ce60f", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
43	42	0x89768Ca7E116D7971519af950DbBdf6e80b9Ded1	350155636339320029184	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x945aaa2e0e56a0988945a838d4945d2660187417f413adf08f6f829fa08eeefb", "0xa0971ca9709be3085c69da104035f34f657a9f3425e916fe63d93a193816dc6a", "0x9606926fc9e35ae9b108111a6bbd9ab8b8ddc7baf4219627c9abc4d0ddc48d70", "0x49bfc1ebde0a26040a747659843248eb44495ed23bd37063f8463e13af199eee", "0xf05367580303e7a3b3d1a36c4261ded32496f0ab7f13219354fb9b50bd990af2", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
44	43	0x8B600c7Ef1D97225860a7996b63c5b8b116182d5	2356363636199999930368	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x86b9231f8e8bcd516617ee7cfa6eb6a4cf657f18619b6b2449dbe18a4c21aa8d", "0x43365c7c692ecc1b53b84a448d6889b145541f31b2e935d05e54d0715d952405", "0xccf7a2a6e00d39a52b7b2fd5e5b4e2a360c8ac004135561f3c5f66ae61814e56", "0x4455359c34aec0ac25939e3cf63b1444ea0853d2248fa015055235e28b728f4d", "0x015d5f866c25a41e44b6f0b3af233acd3366dd33456735378eaeb945fd7c7cc5", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
45	44	0x8DC4310F20d59BA458b76A62141697717f93FA41	843578181759599902720	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0xa9f44dcbb69150e96280a30739b200f518e11fc11d7bb117558346f544f82a93", "0x79595559cd5136bb1514564836982d23be219145836175ec91749e6001e2e4b5", "0x2cab8521a60969378036d595a3b7fbcfc9058bc7ca11609717bc8a13d757dc87", "0xdc5523bf2d165204ee0974224a5eb18decd7e388eb07236c1385e7ee39b57e46", "0xf05367580303e7a3b3d1a36c4261ded32496f0ab7f13219354fb9b50bd990af2", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
47	46	0x8fa1F8787bF4c3fC37b4DD48f472AeF08c279e42	674155636316820078592	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0xfe83829c1b36c6ca4e877de1525421afb327c5627f881b6c6091deff881f8eb1", "0xfffb814b839bf375e0120bec38a6512867a241e3160bc8e92829e0a459389658", "0x9794c424b35f9c13f51aa84cc7373d1bbfdbab1dc8c2d9607971f6384b9c2ac5", "0x760ec1bd66ff0cac3f4625d9c6d59fe5bf21be693b8480b69eadee0741e371a6"]	\N	\N
48	47	0x9497243478392B1F7f508874F606379F989C6eea	259906909072859987968	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0xde7e806a7ee81d947a573ba95809b08bebd1fc8dd90ead9550930892246ae118", "0xe1ed2a91af58ae10baa0f9554c688befe703112eeda57679a18df437a830bd8e", "0xa343e0b328e4c8303ac7b2bc8149a926cb80b4c55a9b3284490ae92d84e64151", "0x4c46eb8bc36404efe92ffe5c9cb8009eb9ea5803aaaf1c21700aa71cb4af5be9", "0x6c33d461ce84630cfa59d1c023a43663a4cc424d18e146a326820bdecbbf1541", "0x760ec1bd66ff0cac3f4625d9c6d59fe5bf21be693b8480b69eadee0741e371a6"]	\N	\N
49	48	0x987f05B5eEB8B30b02329D3888bebc3a7424e999	1885090908960000049152	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x73e5420d5ff8216dff54ad5149b85d9224c846744e4c4b478b222105345e82f2", "0xa63eb5c79bb6844fff1e99b208b244825db98cbfac8a1e641ec572055cba0479", "0x224324fd44c37d9ea9fc1b232de79a6762716dc45fdc76412da31baf27b553ad", "0xad372c3fad9326146ddee2133ce722db8bce5a6a263895ab96eba4c0b3c55172", "0x015d5f866c25a41e44b6f0b3af233acd3366dd33456735378eaeb945fd7c7cc5", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
51	50	0x9c27c3aa042a608F67d19bDA36b099a062185A65	235636363620000006144	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0xc803a20d8cacb7fdaab2a23c80ff4d75b48d5e131b88fd1566c74755436b5948", "0x0010bd0fa66856ae6682981c4a64bd1caefe2eaa72a848eb87362d554139699a", "0x3d33247cd6e9be538b9da120a046524eb2979e459bb0b87213cc4f24d85c6521", "0x4b02f63c85cfecbeb951e77076a033facf68ea61287f83afa33b0a7db04bf9b8", "0x6c33d461ce84630cfa59d1c023a43663a4cc424d18e146a326820bdecbbf1541", "0x760ec1bd66ff0cac3f4625d9c6d59fe5bf21be693b8480b69eadee0741e371a6"]	\N	\N
52	51	0x9cBddD3a8320583bFa7fA78c02a7F7226805f7ab	945373090843439923200	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0xc344c923c1744d6bfca0fbf104deb9b8e8876469028231c02cfb9d06158fc9f4", "0xcd9f00fa591ec092e41674658e3c8a6dea7bb79965bac0cff7743002a4bafb75", "0x3d33247cd6e9be538b9da120a046524eb2979e459bb0b87213cc4f24d85c6521", "0x4b02f63c85cfecbeb951e77076a033facf68ea61287f83afa33b0a7db04bf9b8", "0x6c33d461ce84630cfa59d1c023a43663a4cc424d18e146a326820bdecbbf1541", "0x760ec1bd66ff0cac3f4625d9c6d59fe5bf21be693b8480b69eadee0741e371a6"]	\N	\N
53	52	0xA4Bd35E96887170a2D484e894078A5cB1AB93A45	31103999997839998976	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x634874c22ac41592a5d9acefb05eb1ab9dad93cd5f245d21c5c412a23e24b001", "0xc6b76987b05d0125242aa3dbb67754959afe820ba16321ba06a4ae0a43636c86", "0xae9fd6609a79c62b827e3808dd44556c4b2deb5ed31bf67ca96ecb51b7709733", "0x61ce104d4609443f391e8c0d51fee3bc23998b2b65998d5bcc08d6aa5aac6896", "0x5901ae8481b97bbe4d5d35652dd94bf3077153c9d61fefaeb6466961d62ce60f", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
54	53	0xaB7b49bacd43BD4CfA41433D477F690Bb9E1fB26	353454545429999976448	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x2fb43babe239bc95c4acef23428ce57d651b27ec3aaeba9259961b2fae1580b9", "0x2b422081e2710db61c774c4d00442bf8cba21495b624eecd9cbf20ddb3378294", "0x5c29c482dcadea8915bcc92bdbcd9a3494d14e4e0d70879ccb251be14edd2e3d", "0x2ded3fd83f7bb615a20af878fa1b23e72b7d0aa7028b4d82ab215baf4a74d36c", "0x490b1fedef934dd64563585efd3d770c1bab290715fc9a278492a24b4b422ba2", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
55	54	0xabc42ca4eab3C98543C1C15ca89280888ba6109d	24506181816479997952	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x834c40141cd5ab9219cfcb7f8f6a0a2dd2c0b589bb14233547529b51bab648bb", "0x1c4e6c1d316d4d762494b7d764ab148c6c314d4f4ebe30a99bc49a599270b7d7", "0xccf7a2a6e00d39a52b7b2fd5e5b4e2a360c8ac004135561f3c5f66ae61814e56", "0x4455359c34aec0ac25939e3cf63b1444ea0853d2248fa015055235e28b728f4d", "0x015d5f866c25a41e44b6f0b3af233acd3366dd33456735378eaeb945fd7c7cc5", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
56	55	0xB26d1fE1328172b38708d7f334dd385b6d6fB4AA	1178181818099999965184	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x6e174733c0f267c1d6751f77119e3c630762bf722ec9a7639ab1b2ec00892564", "0x9bd24633689b533f35620dfc7cffd1dcde85404cfc4a1b72a87c9ede716db573", "0x224324fd44c37d9ea9fc1b232de79a6762716dc45fdc76412da31baf27b553ad", "0xad372c3fad9326146ddee2133ce722db8bce5a6a263895ab96eba4c0b3c55172", "0x015d5f866c25a41e44b6f0b3af233acd3366dd33456735378eaeb945fd7c7cc5", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
57	56	0xb98CC80fD75333dC20A9D122d98B5638AaF4FfC3	239022693801583011954688	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x8060a3fded64fff61c1fecf1e2d84430b666dd5287d8edf1921e09421e9ce8e4", "0x7428c5e38b526dee8f41cf879703da225467b52692a0ea3450a17d76e6f7e83d", "0x3299bf318ec58326ab263fc668aba7856146c106c47d993bfc4cec61be75f926", "0xad372c3fad9326146ddee2133ce722db8bce5a6a263895ab96eba4c0b3c55172", "0x015d5f866c25a41e44b6f0b3af233acd3366dd33456735378eaeb945fd7c7cc5", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
59	58	0xc0555149B5A5D96AC016d3425b7986504190c3a0	23799272725619998720	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x901a6504c09926fce5175d800d79332c6338aca643e2cceb707237b72e20a87d", "0x40321d1fcfd9c4528dab15089e51524ae0b92228fb3d2fcc98101480886b90e5", "0x9606926fc9e35ae9b108111a6bbd9ab8b8ddc7baf4219627c9abc4d0ddc48d70", "0x49bfc1ebde0a26040a747659843248eb44495ed23bd37063f8463e13af199eee", "0xf05367580303e7a3b3d1a36c4261ded32496f0ab7f13219354fb9b50bd990af2", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
60	59	0xC134041A85EdBb3BD9CAE36A32486454c1c6e134	28276363634399997952	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x7cac9f5975dc18798b766f20a068f6e3ff80fa91585def2852bf362046406aab", "0x7428c5e38b526dee8f41cf879703da225467b52692a0ea3450a17d76e6f7e83d", "0x3299bf318ec58326ab263fc668aba7856146c106c47d993bfc4cec61be75f926", "0xad372c3fad9326146ddee2133ce722db8bce5a6a263895ab96eba4c0b3c55172", "0x015d5f866c25a41e44b6f0b3af233acd3366dd33456735378eaeb945fd7c7cc5", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
61	60	0xc2a622b764878FaF9ab9078aD31303B24Fd4b707	149157818171459993600	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0xb72de8ba55d8a547e9b06b7b88e081fdc8f9e2ca3dd2ad4f633c68a0580805c7", "0x11363d9c5d5816f7b2a36481d1d541464f5a46d459bd27d749b69cbfda73aa6c", "0x961c5fd9b9c9d4645410c4a4a839440d497962ca898aa984b2e2631cb3cdc4da", "0xdc5523bf2d165204ee0974224a5eb18decd7e388eb07236c1385e7ee39b57e46", "0xf05367580303e7a3b3d1a36c4261ded32496f0ab7f13219354fb9b50bd990af2", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
58	57	0xbBf6507bCAB4128Ab99AA89b3eE750880fF5D56B	4712727272399999860736	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x71811390796f08f3e6337c7d0b4006acc99684ec133f8c05bdfd725e7ddd4555", "0x9bd24633689b533f35620dfc7cffd1dcde85404cfc4a1b72a87c9ede716db573", "0x224324fd44c37d9ea9fc1b232de79a6762716dc45fdc76412da31baf27b553ad", "0xad372c3fad9326146ddee2133ce722db8bce5a6a263895ab96eba4c0b3c55172", "0x015d5f866c25a41e44b6f0b3af233acd3366dd33456735378eaeb945fd7c7cc5", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	15503055	2022-09-09 13:42:53
62	61	0xC2Ac36c669fBf04DD2E1a2ED9Ce5ccC442977305	53018181814499999744	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0xea89c64c00abb4c12db38ae6eabbf1b087cd8b809da984b1217a29d1a039107c", "0xca04002efc95b7b14056c07923a983f9738db0aa4e84f56cca01070c0bcafa3d", "0x8dd95ee87883d64e1b2bbb11b1e43d326d825b97642e3bd3c933dcb548e3ad72", "0x4c46eb8bc36404efe92ffe5c9cb8009eb9ea5803aaaf1c21700aa71cb4af5be9", "0x6c33d461ce84630cfa59d1c023a43663a4cc424d18e146a326820bdecbbf1541", "0x760ec1bd66ff0cac3f4625d9c6d59fe5bf21be693b8480b69eadee0741e371a6"]	\N	\N
63	62	0xc4676e5E99b823E54B3e6c32c8143BB441633eEA	122530909082399997952	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0xd595ad0f7af3ba3f36ddb917fc0b92678fe0a99017f693fda861274457a130c0", "0xa1e120a720a92241d2c8b1a50d83a7dc6d92642e5aaf352f3a5c4e7959296dab", "0x8c5cb79fadf57d0f809a3a54af5c2fb5cfc033bfb5046faa57d73aa725ca2c61", "0x4b02f63c85cfecbeb951e77076a033facf68ea61287f83afa33b0a7db04bf9b8", "0x6c33d461ce84630cfa59d1c023a43663a4cc424d18e146a326820bdecbbf1541", "0x760ec1bd66ff0cac3f4625d9c6d59fe5bf21be693b8480b69eadee0741e371a6"]	\N	\N
64	63	0xC887b3406424838aE65456860278a5e6e40fCb08	23799272725619998720	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x87ede8d34868deafe6e8ca08633c6979d30f9cb567fbe9432003057ccad6265a", "0xe7611ea12b2171f5144e234a3fc6a9b33444e92d854aeba053d22036fb3ab3c4", "0x61e582ed77be6270088c0d1e28bfef05e2204331a756b9c31ac8b467b95fac0f", "0x4455359c34aec0ac25939e3cf63b1444ea0853d2248fa015055235e28b728f4d", "0x015d5f866c25a41e44b6f0b3af233acd3366dd33456735378eaeb945fd7c7cc5", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
65	64	0xc88d7DC8Dfa23d3769f7e8241f761D09A10D9831	235636363620000006144	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x294ed73410e15c4d54073d4c21b8e2bfc6f925f022ea5bf0d302b4a74c14a961", "0x1d83ec68a3819f24d324fcd55afd4939e131c10df10a3e93f526bc33186eefb6", "0x5c29c482dcadea8915bcc92bdbcd9a3494d14e4e0d70879ccb251be14edd2e3d", "0x2ded3fd83f7bb615a20af878fa1b23e72b7d0aa7028b4d82ab215baf4a74d36c", "0x490b1fedef934dd64563585efd3d770c1bab290715fc9a278492a24b4b422ba2", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
67	66	0xcb630c28658d8B4f0509D628D8d947e6F95eA20A	70690909085999996928	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0xbc1b1cc233e2b24903058fcc752d530acd3580da45dfd327827df86bc47b4d69", "0x11363d9c5d5816f7b2a36481d1d541464f5a46d459bd27d749b69cbfda73aa6c", "0x961c5fd9b9c9d4645410c4a4a839440d497962ca898aa984b2e2631cb3cdc4da", "0xdc5523bf2d165204ee0974224a5eb18decd7e388eb07236c1385e7ee39b57e46", "0xf05367580303e7a3b3d1a36c4261ded32496f0ab7f13219354fb9b50bd990af2", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
68	67	0xcd5561b1be55C1Fa4BbA4749919A03219497B6eF	100381090902119989248	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x4da560aff24625e057e93153db64660e8a44038aeb9340db972b48f7c161e1dc", "0xb42a8cfd8e53aa04ebf8a583d8381cde2f5214d8aac4f6b13802c449423ccbb5", "0x4018fbf869f9d6fe5604ff848f7bfd060bb0c4e99fa16e978cc0f96ef790de6c", "0xcb4bceac6c8f86ae9b8bdd6043564f96b4329c106f62d27bf88136944daeb5a4", "0x5901ae8481b97bbe4d5d35652dd94bf3077153c9d61fefaeb6466961d62ce60f", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
69	68	0xCfaF3E19Dca4b4cb0fB1399abB7Ec074AbE39114	2356363636200000000	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x3bb52fc469b5f3ef60deefaba4e10918a39119ad39e6877735fc9ed8c7728a80", "0x86b4965e919cbab34d7dd33ed632bb1232f9872072ea82888f3877958f4ee36d", "0x2d8bbbf1bfeb0913f3c979403e69b4e6e7a0ddb055f93a6d96cc4a1731592843", "0x2ded3fd83f7bb615a20af878fa1b23e72b7d0aa7028b4d82ab215baf4a74d36c", "0x490b1fedef934dd64563585efd3d770c1bab290715fc9a278492a24b4b422ba2", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
70	69	0xD43Ca531907f8C8dBb3272Cc2EF321cC572E56E3	420610909061699993600	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x730dca946a2194355c36ff51de472ab7c5ae2efd420b9249b2ad222480108342", "0xa63eb5c79bb6844fff1e99b208b244825db98cbfac8a1e641ec572055cba0479", "0x224324fd44c37d9ea9fc1b232de79a6762716dc45fdc76412da31baf27b553ad", "0xad372c3fad9326146ddee2133ce722db8bce5a6a263895ab96eba4c0b3c55172", "0x015d5f866c25a41e44b6f0b3af233acd3366dd33456735378eaeb945fd7c7cc5", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
71	70	0xd8742073F4F44d0046916a9B62A955A36e0c0e5f	236107636347239989248	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x6513200f87d6bb021afc25e63768effe4eee9e23ca6e18b57bdd59ce900a3951", "0xc512ad2c2eccf14f002d9e094548cf1a4c7d5e17b78559bb53c8661d6835330f", "0xf409fdc8454ba1c159f34d3f739479f6f12feb4e3b404941b2415aa23a7cf5ce", "0x61ce104d4609443f391e8c0d51fee3bc23998b2b65998d5bcc08d6aa5aac6896", "0x5901ae8481b97bbe4d5d35652dd94bf3077153c9d61fefaeb6466961d62ce60f", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
72	71	0xdD32231c664f6e3456e81ec6c27C6f429C7dc3b3	23092363634759999488	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0xfb54c7b9485c5a90d6e0d95d9b9dd860ee4754b5259ea758683c72a36d73adab", "0xe000fabba3388f63887fcb28155cb049633442adb671e966b71284085f750c14", "0x8dd95ee87883d64e1b2bbb11b1e43d326d825b97642e3bd3c933dcb548e3ad72", "0x4c46eb8bc36404efe92ffe5c9cb8009eb9ea5803aaaf1c21700aa71cb4af5be9", "0x6c33d461ce84630cfa59d1c023a43663a4cc424d18e146a326820bdecbbf1541", "0x760ec1bd66ff0cac3f4625d9c6d59fe5bf21be693b8480b69eadee0741e371a6"]	\N	\N
73	72	0xdd4A19DC351Ba42421dB282196AF38b433AA86BA	236814545438099996672	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0xd9366343f4b79c1b5f97b64a9290fe40e2e441891c270578edde7843056246a7", "0xa1e120a720a92241d2c8b1a50d83a7dc6d92642e5aaf352f3a5c4e7959296dab", "0x8c5cb79fadf57d0f809a3a54af5c2fb5cfc033bfb5046faa57d73aa725ca2c61", "0x4b02f63c85cfecbeb951e77076a033facf68ea61287f83afa33b0a7db04bf9b8", "0x6c33d461ce84630cfa59d1c023a43663a4cc424d18e146a326820bdecbbf1541", "0x760ec1bd66ff0cac3f4625d9c6d59fe5bf21be693b8480b69eadee0741e371a6"]	\N	\N
74	73	0xde0634a1F956Df8580f18C955B3e9EE957e552C6	1319799272635619868672	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x48dd62ba8262e291667726b072415126b31f9abf72a48b2613a645df46d2ea98", "0xed0036d9235cd6785282563008c22b14bca50bc7c118da2150362f6c2372bfd7", "0x4ef4b3e1873f36435dbfaeecb6d4f326fab05d3dbca429bfd3d54c12a288290a", "0xcb4bceac6c8f86ae9b8bdd6043564f96b4329c106f62d27bf88136944daeb5a4", "0x5901ae8481b97bbe4d5d35652dd94bf3077153c9d61fefaeb6466961d62ce60f", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
75	74	0xDe3258C1C45a557F4924d1E4e3d0A4E5341607Ee	58909090904999997734912	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x6bf06b3aa4692f8616881dadc421092d6a666844c1819d998f1ae06a9a2518fd", "0x018979e7326a778d8c6526f664a334abcd3a46c2731065c492e7659923955764", "0xf409fdc8454ba1c159f34d3f739479f6f12feb4e3b404941b2415aa23a7cf5ce", "0x61ce104d4609443f391e8c0d51fee3bc23998b2b65998d5bcc08d6aa5aac6896", "0x5901ae8481b97bbe4d5d35652dd94bf3077153c9d61fefaeb6466961d62ce60f", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
76	75	0xE1d1c5F48f708aa038AA6A9976308Cd1d19D951a	236814545438099996672	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0xf048ea917fbb99ab476fd3adbf68ae8ab15fb10bb7f74e987799acbf178e15b0", "0xca04002efc95b7b14056c07923a983f9738db0aa4e84f56cca01070c0bcafa3d", "0x8dd95ee87883d64e1b2bbb11b1e43d326d825b97642e3bd3c933dcb548e3ad72", "0x4c46eb8bc36404efe92ffe5c9cb8009eb9ea5803aaaf1c21700aa71cb4af5be9", "0x6c33d461ce84630cfa59d1c023a43663a4cc424d18e146a326820bdecbbf1541", "0x760ec1bd66ff0cac3f4625d9c6d59fe5bf21be693b8480b69eadee0741e371a6"]	\N	\N
78	77	0xe45c950EFB371C331fFEF421B5C8787c74830479	28276363634399997952	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x55bd28e806c1c19ec428c1e87c60ca4f20f134d790492f4d9acf52a46f292b28", "0x92ca506ac64cbda4f724ab90a82bcff59799abc09175cda83a4760dd5df20408", "0xae9fd6609a79c62b827e3808dd44556c4b2deb5ed31bf67ca96ecb51b7709733", "0x61ce104d4609443f391e8c0d51fee3bc23998b2b65998d5bcc08d6aa5aac6896", "0x5901ae8481b97bbe4d5d35652dd94bf3077153c9d61fefaeb6466961d62ce60f", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
79	78	0xEE15f56C09Dd300dc039dE1901BCcca32a23a253	388047613063961308561408	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x0839b1e24e4dbe04223e91ddf083a04a18d8785f8b9c2177fc0aebc5de7d7e90", "0x9794c424b35f9c13f51aa84cc7373d1bbfdbab1dc8c2d9607971f6384b9c2ac5", "0x760ec1bd66ff0cac3f4625d9c6d59fe5bf21be693b8480b69eadee0741e371a6"]	\N	\N
80	79	0xeEEC0e4927704ab3BBE5df7F4EfFa818b43665a3	980954181750059958272	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0xb248d8556b842f5d26785eb3e7c13f4544d6ec768643db67012971a77c653b2d", "0xda37578b5e7f4d0e0884660a70f70f57c5164b56c5c5bfc1862792dd63f0b432", "0x2cab8521a60969378036d595a3b7fbcfc9058bc7ca11609717bc8a13d757dc87", "0xdc5523bf2d165204ee0974224a5eb18decd7e388eb07236c1385e7ee39b57e46", "0xf05367580303e7a3b3d1a36c4261ded32496f0ab7f13219354fb9b50bd990af2", "0x82466e8f44ef25dd2b382d84c83bc1e6f348fafbd26c64d2dbab74e1ed506329", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
81	80	0xF977bF5f5CCB1BFd868BD95D563294494F0D5d89	236578909074480005120	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x361e16d17650c59c78c9581c6dd912b5dee301e0c1a8721281447214785fdf74", "0x2b422081e2710db61c774c4d00442bf8cba21495b624eecd9cbf20ddb3378294", "0x5c29c482dcadea8915bcc92bdbcd9a3494d14e4e0d70879ccb251be14edd2e3d", "0x2ded3fd83f7bb615a20af878fa1b23e72b7d0aa7028b4d82ab215baf4a74d36c", "0x490b1fedef934dd64563585efd3d770c1bab290715fc9a278492a24b4b422ba2", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	\N	\N
83	82	0xfC0591893B0BDb4322D25BDd43904Aa9aB137140	24270545452859998208	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0xbe98555b289402c019dc3e79e60d0d5155ab88a361b45dc1d1a8dbc491f2d9bd", "0xcd9f00fa591ec092e41674658e3c8a6dea7bb79965bac0cff7743002a4bafb75", "0x3d33247cd6e9be538b9da120a046524eb2979e459bb0b87213cc4f24d85c6521", "0x4b02f63c85cfecbeb951e77076a033facf68ea61287f83afa33b0a7db04bf9b8", "0x6c33d461ce84630cfa59d1c023a43663a4cc424d18e146a326820bdecbbf1541", "0x760ec1bd66ff0cac3f4625d9c6d59fe5bf21be693b8480b69eadee0741e371a6"]	\N	\N
84	0	0x014607F2d6477bADD9d74bF2c5D6356e29a9b957	6171541	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x1a109103a25fb4973ed5609e5c3653847056cecf1173b99f23880b55a5ba9a8d", "0x496809f32e10c0893a18cc05b0725e67752baa9a3d8166f69ff890f15830ff06", "0xa6ca3476ad4754c3920514f9001b155a6ded3326888e23f76f64dd9367047801", "0x3ab607ebbc4a10e6a4ec561864e1fc5bcaff643a31646eb179f9f584ac658bb1", "0xa3c59b0e5d79f4dc42f2d3ff4534c87218390db4b26870abb9db219ee3e4b80b", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
85	1	0x01ebce016681D076667BDb823EBE1f76830DA6Fa	265407935	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x04b8a1457b975c1a27d1768843d7a859b755cc8cc519a52e3b7fcfee463a43fc", "0x016543b27806e25a9c7da13ad23679fef8d1959a09914412b803457db97c4511", "0xbd1e3c6fe285c0c34cbfb67a1ea86225ddd0041e7be942f12dd33c36ff4a7b06", "0x349bbd8b6fa55a140bf1344ee94ae7fe0ded4fa2f4006ca83004621ed602c890", "0xa3c59b0e5d79f4dc42f2d3ff4534c87218390db4b26870abb9db219ee3e4b80b", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
86	2	0x03894d4ac41Dd6C4c2f524eD4417C90fA46972c6	106168037	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xb9d3a4680dc0ae9ca5f3aa2ce4688eda22693363a55c372563aad40e27d7f719", "0x6f9546d1a3e7ac92faf1319efd82452f28a757c8f4c472c5181d284d752311aa", "0x5f3f00592f0f70f3e3a142c42577056d421ec3dbb64a54809b33787a3b6d48c4", "0x6f79d0c40910c8366ab4d76b9d1bdb697fd8df4d24653c63825db6ebe036bc3b", "0xe4c0bdd842dcc90a8185ceced86982f2b595eb41e0ab11693765cd198ab7ce18", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
87	3	0x040528e6eBdcBC6e37e3C78350dE0a59AedCe622	13530381	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x7a79bef389900de7b2a3773973a19108d7359c424e8f3a0f6d95b711cf22f36b", "0x81a9f71d721ea90019848c2b2a20248cbb28e444305460667129afdc318943a5", "0xab27c389aac33a5280613bbe8d35cfb6163c1c19d0911f8920a76b90c41cfbf0", "0xd48c008462c00547c5c0c21f1092301a97e7dd2df64014bcf04ef46427517154", "0x28ff0d7e60f4eb100bad786efefb9004d4274e7ff8d48c3af92cc48fcab9a159", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
82	81	0xfB28bB6CFCf19cb8784472226CCd13F2e5224000	1178181818099999965184	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x078bd01dc479fa37d6c924cd375e9840bc7ca690d4a20377f2d2ccfb026cf432", "0xbccc176fd407bb6fe5c0c08f83ead495d593f5516993834fedb4bcd55f71e1ff", "0x37c54b2583e36a970b7f0766e4a3e0501640011d3b2ef27cebeac4537cf336c5", "0xd31c285ad6ee45c08c4e1e6f5bbcb746ce2ab52f77b254d01a650a2935523e57", "0x490b1fedef934dd64563585efd3d770c1bab290715fc9a278492a24b4b422ba2", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	15487301	2022-09-07 00:48:29
88	4	0x046f601CbcBfa162228897AC75C9B61dAF5cEe5F	27278790	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x5b1ce2947fc684329718838c5affbf10c5b9c46e973d5993732884da5cc9034b", "0x601a7c6d66cd673821161499125cac262cf24d3dfca9a9e9936a255c222a2dc4", "0x673959062dc2638bc6ff7a69622ac893558907c5a8d11114feed9b1b375e56c1", "0x9db93fb4966878cebb91145aeba7f152eb32b9cb74c97883a0dc3e33eff70d44", "0xcaf053c33846aaa8f6fbb1f7a75d4132cda69f172397cbd7b2ce09cd928b19d8", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
89	5	0x05ac3D28434804ec02eD9472490fC42D7e9E646d	53349812	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x183a1ef070e27f2efa8ab7ffa04a88855cac860e0c27c58aa5e5549386cc3983", "0xfe874403ed79fe713284e5911dd5bef1169b69405422502041f61d590ae8c1a2", "0xa6ca3476ad4754c3920514f9001b155a6ded3326888e23f76f64dd9367047801", "0x3ab607ebbc4a10e6a4ec561864e1fc5bcaff643a31646eb179f9f584ac658bb1", "0xa3c59b0e5d79f4dc42f2d3ff4534c87218390db4b26870abb9db219ee3e4b80b", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
90	6	0x09D1E14bc93217B9F2d083509E94dEe161ffd9AC	5463206	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x4ba525904b43d1ca93a02081aad5fae07d579e44b08c51ac7f06e8508911947d", "0xa1de1bdfd265dba43a92ff9614bf9775f9ab387b61d9249e8b7c66f15aed7d0d", "0xc8fe9950e04c57915e0fcddf5439437e28435ba6e1d6ddcee54c86e537adde11", "0xcc74105228f8df13b29dc9352dab6b01f6dd2ce9990ccda307e2cf72f6a0f9c2", "0xcaf053c33846aaa8f6fbb1f7a75d4132cda69f172397cbd7b2ce09cd928b19d8", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
92	8	0x1040a43093b700D9bfe90346990afAa4D1151508	29131553	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xd0bbdfb32e51c45ba9fa62cabc47e7360072f59e7ceb66449c03cdc122eb99b7", "0xd9382c3b709f8f467feefa81497786196ed402cbcdea0c83f0753f11d37ddb46", "0xf0fa5d762599bf649ccbd15e396d492d2df7d6e2cf1090ade7efe453a0cb59dc", "0x621b0226039f314e62d4ec3f88a43102368e04c9c3ee2266dd32f5d072203054", "0xe4c0bdd842dcc90a8185ceced86982f2b595eb41e0ab11693765cd198ab7ce18", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
93	9	0x111CE8D46cd445F5aB1ce3545d97b45071DfECC0	794585894	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x8889a19e667fcb074312194fac13774eae6cd6f04eadeab4600d6d6b0b08d72e", "0x8f4232a99b2a5f5b103c9cc19047dc35c0efc31418794c3a96fee9d2c0b7db02", "0xc1d504a8d5fabb1d02dcf934b16a0a56eeea11e20374b9578701ad3e7afee823", "0x05fabdedf2ebeec4ae3e8aa842d7b0d1032b25528d26df0119fb732210f3c5ab", "0x5edafa5f7feaa44c05fc81c84df464db15f12761a510fbf938f6066d7117b162", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
94	10	0x13711b99539d2860AA740c0180A50627d538c28e	5533870	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xe27985882f483668f7a9a35858a08cbf94bad958d367275a0b2400a6ebfaecbc", "0x7256e3af23038662a535912e331e84d4c42f7335b24712500d16b9e0752c2f16", "0x18c202265596dcaa0820dd9403f7a553a9fe5ce819a63d9b23860d2a908c919b", "0x621b0226039f314e62d4ec3f88a43102368e04c9c3ee2266dd32f5d072203054", "0xe4c0bdd842dcc90a8185ceced86982f2b595eb41e0ab11693765cd198ab7ce18", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
95	11	0x153e2BD0CCdB0F78aa60d5EBc86EFB27Afd5eA3A	5376799437	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xbc904c593fd4f2588d471c60061d1230330bd7f871c3320f26ed99bbf85158a4", "0xea49dfd34af8d558c1328e57dbe8cb56cd4be3324461f36d4d8e6985ac3989dc", "0x5f3f00592f0f70f3e3a142c42577056d421ec3dbb64a54809b33787a3b6d48c4", "0x6f79d0c40910c8366ab4d76b9d1bdb697fd8df4d24653c63825db6ebe036bc3b", "0xe4c0bdd842dcc90a8185ceced86982f2b595eb41e0ab11693765cd198ab7ce18", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
96	12	0x18Bd2e8B69E48C5E6DeAE13682b1F78d1c260bF9	59033882	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x9ce0e3acfc3f3b159006975bed7f5180e18d39eaf0fefe5daf1309db3f22c677", "0x8a15010b71e0462f04cc42fe3ea3d175a8755b843f76e12ea4196aa833ca212f", "0x35992df4c952bb93f59ac25f6ab9c869da5c75273c85a7c44b6386fc3748664e", "0x05fabdedf2ebeec4ae3e8aa842d7b0d1032b25528d26df0119fb732210f3c5ab", "0x5edafa5f7feaa44c05fc81c84df464db15f12761a510fbf938f6066d7117b162", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
97	13	0x19fde20744903805bA05e1522980Ffff3545C1EC	5346798	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x5ec80b62c75a8799fff94e8b58594e13f482fd564d1bb2dce26bce10d7f5eb4e", "0x601a7c6d66cd673821161499125cac262cf24d3dfca9a9e9936a255c222a2dc4", "0x673959062dc2638bc6ff7a69622ac893558907c5a8d11114feed9b1b375e56c1", "0x9db93fb4966878cebb91145aeba7f152eb32b9cb74c97883a0dc3e33eff70d44", "0xcaf053c33846aaa8f6fbb1f7a75d4132cda69f172397cbd7b2ce09cd928b19d8", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
98	14	0x1A918A8386F75f382E2A1b2e10b807c39728caf2	2619637	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x444783e979fa34b6acce94981f8f8c5d54c86614fe7b5eb0d76df555711c667d", "0xd9adb4ad261afe80d72f57838d611ccec4fc6cbd8449231c001b766a6597099e", "0x3269a889ef513df7d18dddb0ba5a8aad4f13cf9c6318b0d18a7e6975fbcfd082", "0xcc74105228f8df13b29dc9352dab6b01f6dd2ce9990ccda307e2cf72f6a0f9c2", "0xcaf053c33846aaa8f6fbb1f7a75d4132cda69f172397cbd7b2ce09cd928b19d8", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
99	15	0x1c721671916560c9Ab5B7c5406E152b750eB03a2	45482045	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x6c072efa6dfeefaae3fb1428d5296ee04ce1395863ae984caefdc6549e6521ff", "0x63aa2700a72631edd8d69ac592d6789a4bb802ef06baa315a375ce49a6b46ffc", "0xfea2015912db92559503a34c02870da8c90a9c24b36aa16c41f9d81be5b03bfb", "0xd48c008462c00547c5c0c21f1092301a97e7dd2df64014bcf04ef46427517154", "0x28ff0d7e60f4eb100bad786efefb9004d4274e7ff8d48c3af92cc48fcab9a159", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
101	17	0x236884bb674067C96fcBCc5dff728141E05BE99d	58659076	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x13f3a8430d108b9897cdb7959a7a1eaadea80a934537c98114ba1e272decc30b", "0xe21ef441150ede62f9da6b1d379f3bf875b1a06fefe662e520d85b52c945003f", "0x204e90522978efc4455386f206b0b441bbdea5ce5b24ca8b28158ce3262c5963", "0x349bbd8b6fa55a140bf1344ee94ae7fe0ded4fa2f4006ca83004621ed602c890", "0xa3c59b0e5d79f4dc42f2d3ff4534c87218390db4b26870abb9db219ee3e4b80b", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
102	18	0x25aD2667B19e866109c1a93102b816730a6Aec3f	879858	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xb475c0509479140d1e449b50559c2c50a7921e4e71a3fde68e75250a05cb3f16", "0x46348778e308c6af344b72b4659efe9e3ad38799a9520ef4b1f77a0f4063afe7", "0x8e406feb3a35d29751c3aa341ab3936ff84def31ee342b70d9283145ccb24d30", "0x08fbe1a228db71e67ee68159d3d604c4b891ecb0d107a6b611f3bed8ad04f6f3", "0x5edafa5f7feaa44c05fc81c84df464db15f12761a510fbf938f6066d7117b162", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
103	19	0x276651CF20Ef719Dd3faE29e75f63E1603507517	38619924	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x6bb0b8dd5b1752f8e050bec98b2fdca2c55b59e7ebef890e5eb633ab2eaac53b", "0x63aa2700a72631edd8d69ac592d6789a4bb802ef06baa315a375ce49a6b46ffc", "0xfea2015912db92559503a34c02870da8c90a9c24b36aa16c41f9d81be5b03bfb", "0xd48c008462c00547c5c0c21f1092301a97e7dd2df64014bcf04ef46427517154", "0x28ff0d7e60f4eb100bad786efefb9004d4274e7ff8d48c3af92cc48fcab9a159", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
104	20	0x2d220B4783A291AbB2db3618BC4d94C632E16206	52034953	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x46507d6bf36bb00c8ecfa1dbe57afe2082d526a9ca4c858d219b8e6d16d5c4d0", "0x2d22132a8755322838e5e87fa75d1a0d9e2e0ab56b76b9e7fdfe70854e90fb07", "0x3269a889ef513df7d18dddb0ba5a8aad4f13cf9c6318b0d18a7e6975fbcfd082", "0xcc74105228f8df13b29dc9352dab6b01f6dd2ce9990ccda307e2cf72f6a0f9c2", "0xcaf053c33846aaa8f6fbb1f7a75d4132cda69f172397cbd7b2ce09cd928b19d8", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
105	21	0x3255d4B48d108cFD7A6D71d0722Ff845F9213a13	5793289	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xeb71bbba8235eda252e5e10e1f489cb472be7da59531608cf10a16c4a2b27a74", "0xbb41b83b9993d9dc252a76268675b138ba5b79aae7dfe7ac33db72ae698b1bae", "0x5583ae526dcda17805318cf82273f4997bebaa79caa4eee7a4f65604f337883f", "0xc48602e28c66ccef2767e2b33dc9470d841b599ee2d6edf51d57a5f78e41769c", "0x68f9fe7b7e8b3dee2dfce6d031b8d57ce0a64ff057bb827b03ddb951605b09d7", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
106	22	0x3524ff8D740a4f1be13F2cDd2F2345e54DC0c6B0	106268048	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x812fd88e4fdd256f26fca8b54afa9e4e91ab5c3af1418cc3e040961edbaacce7", "0xca11a27c66723adf5c6a5a73402ea2eeae4b8322fcb093c5e7f4cba3f86aad68", "0xe992624fe43ac2884ac4b4ac88891324b25616da3d10589da04e1f431ebe584d", "0xe8abe811ab30f69889988f5b32137e32f1aec7ec1491dc68b17be8eddaa17e97", "0x28ff0d7e60f4eb100bad786efefb9004d4274e7ff8d48c3af92cc48fcab9a159", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
107	23	0x37d8fa18BD09eD448e93ecD47641019d91eb43a4	5744832	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xf57a0a32434e85a86e16057fb36cad0a8ccefc890dfae08d98a5ef2e888f4a73", "0x89a9e6bc027cb4eb0b56132a89e81e5d9b92de1f27751e2b5fc127b22955800c", "0x99629a16e2622d280c51683b346649728f0b28e4bea870fff17ce440e475ef10", "0x4388025aa18bad616b51fe465bbdf09bcf17db9207191fe8753e0f3e2ee4f35b", "0x68f9fe7b7e8b3dee2dfce6d031b8d57ce0a64ff057bb827b03ddb951605b09d7", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
108	24	0x40dB5C12aA263660A6188A8e16fCdf9c5235E5bF	5306101451	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xf3097ec7b36794998d07549f2f0dde1cbfeb0dda83868c24a3d25967b0ba477c", "0x63d9ebb935cad0469a7959f77e3c0ed83d7d3368855e932b15ed23055dbf814d", "0x99629a16e2622d280c51683b346649728f0b28e4bea870fff17ce440e475ef10", "0x4388025aa18bad616b51fe465bbdf09bcf17db9207191fe8753e0f3e2ee4f35b", "0x68f9fe7b7e8b3dee2dfce6d031b8d57ce0a64ff057bb827b03ddb951605b09d7", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
109	25	0x446Ccd4633512f321B400cF89c1877F8307F6C26	2125107	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x07b272cd4184450d49e7536709bab92b84bd2e0193199b1956d4cf599eea7ee0", "0x312156e6faa3c24c6768f8f5ddc68c9636dad3d9fcb685540156b09223b3ee47", "0x204e90522978efc4455386f206b0b441bbdea5ce5b24ca8b28158ce3262c5963", "0x349bbd8b6fa55a140bf1344ee94ae7fe0ded4fa2f4006ca83004621ed602c890", "0xa3c59b0e5d79f4dc42f2d3ff4534c87218390db4b26870abb9db219ee3e4b80b", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
110	26	0x4953b5F3980f0FE8584F84C9A1AD93013EBE29c6	51165939	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xa80d0a5369830f2dbadcd76ea9809b159b87990fcc3191e851f2e840f8588f2d", "0xa8b5d5634fc81cf8673b2e698c9454f02e26ee96d15ef462be06a5a024294cdd", "0xd915c49e421f2c6a47d6ab09ed0ae141cb58237bb339a873ff432917bb58f606", "0x08fbe1a228db71e67ee68159d3d604c4b891ecb0d107a6b611f3bed8ad04f6f3", "0x5edafa5f7feaa44c05fc81c84df464db15f12761a510fbf938f6066d7117b162", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
111	27	0x49eb81cc817cD5a1E8Df590F43D5A0A0F432251A	15741141	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x2d1ecd4cf728459f055c9301d1183982313486fcad7cd35f24055d056919e778", "0x5f9ebc3e25deabd732af145e459b55c172f3d92ce5356658d9c6ed5ce86d0522", "0xf3742381508535ddd26ebdbf8586aaf7138051cc036ef806317d2eac25ce9827", "0x5f5b7003db8be724c809d3268a3d80a7600f4c4f4dc42a90748b7b1a54b92515", "0x99cc2dafecf549c4babf0015b70339ca43cdd95c69bec9fe2a344ba8143183e9", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
112	28	0x4C1F58d3dED593b018ca2ec4228399Df39CFdd6f	11342122	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xfb87aaba7907c5a8819ecdd313d1bdc135627117cc39bce6d9e257e627872ce7", "0xfdb0820360ebe555c73eb6abf39625f326625b7bd130ba4728a8f1ff8a230ce5", "0xf8b3e3e43e13df428b419562561683ba5223ba97e9af428781f6261005b40600", "0x4388025aa18bad616b51fe465bbdf09bcf17db9207191fe8753e0f3e2ee4f35b", "0x68f9fe7b7e8b3dee2dfce6d031b8d57ce0a64ff057bb827b03ddb951605b09d7", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
113	29	0x4D5dAADc1Bf9Aa1c023FE1A9f75545B3863dfD14	5741971	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xde15d74a1fdb58d23c34631f5e0f47dff6ca0efc88fcb5807780dd6015c6aa95", "0xc98f961873d240df918592920e0cd77e2cda4eaffa78e6d08deb1715b52496fb", "0x18c202265596dcaa0820dd9403f7a553a9fe5ce819a63d9b23860d2a908c919b", "0x621b0226039f314e62d4ec3f88a43102368e04c9c3ee2266dd32f5d072203054", "0xe4c0bdd842dcc90a8185ceced86982f2b595eb41e0ab11693765cd198ab7ce18", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
114	30	0x520cc7572527711B8C50bceFe1d881F8ddb5Fe8C	105889	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x318098de773cba8d2b2b875e1c8ae5a96a4ce29daf1806588b23ef700e9a63ed", "0x9d16d7251b1bdd5ff13063c1f015d708d8e08a5eabb8057fe0cc27089c83b3b8", "0xf3742381508535ddd26ebdbf8586aaf7138051cc036ef806317d2eac25ce9827", "0x5f5b7003db8be724c809d3268a3d80a7600f4c4f4dc42a90748b7b1a54b92515", "0x99cc2dafecf549c4babf0015b70339ca43cdd95c69bec9fe2a344ba8143183e9", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
115	31	0x543298794e7E195c8628f65D16fB7fcf7D096Cb0	531009236	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x8f9ea8b08a793786fa4f465a84fbe6b0f89d5845552c6e83261a1e747a9df5d4", "0xa879e07f7d7424c4ef6b4d3c114525776e02f677cc730163549c3f32a4f67d0a", "0xc1d504a8d5fabb1d02dcf934b16a0a56eeea11e20374b9578701ad3e7afee823", "0x05fabdedf2ebeec4ae3e8aa842d7b0d1032b25528d26df0119fb732210f3c5ab", "0x5edafa5f7feaa44c05fc81c84df464db15f12761a510fbf938f6066d7117b162", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
117	33	0x5a641C6fd5a473395355816EBC757b067CCaabE5	5564170	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x25f450603722c0b115c3e00f247bc98866cad896edc47da87e0eee1d46eebfc5", "0x9603c0b0fc0e6c0b4ce7a5216f107190f9b1b49505b8b74624af3d426a0b3f68", "0x1230d26fc38dc5dfcc45f1aa43e7737f48a371bac1a64237544a735eb2a502a4", "0x3ab607ebbc4a10e6a4ec561864e1fc5bcaff643a31646eb179f9f584ac658bb1", "0xa3c59b0e5d79f4dc42f2d3ff4534c87218390db4b26870abb9db219ee3e4b80b", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
118	34	0x5a756d9C7cAA740E0342f755fa8Ad32e6F83726b	5361617	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x4f1e056fdfcd3141586df55280972e220a6c7cbc2652d881226f83ac296c9686", "0xd7328d53a5fddf74bcff73795942a09cc26903268e2a6bf38f8a34d4ead22547", "0xe14971af7dbbc265b309d5f5ed38e32891f25af502e14fdf29d33c432ea24e90", "0x9db93fb4966878cebb91145aeba7f152eb32b9cb74c97883a0dc3e33eff70d44", "0xcaf053c33846aaa8f6fbb1f7a75d4132cda69f172397cbd7b2ce09cd928b19d8", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
119	35	0x5D9a5eBAe5828cd8d15166666d45D53f0b871Bb4	57387	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x86ae1936f069c79313f4f58c100f2e992d173dd93860a258fdd06b4e53dcc65b", "0xab380d30b473f66d38fa953c38ae6c549a1a22cc71877e961a20ba190794f4db", "0x95c7bd05a271c38f758173a8bc258df64ff515e9352581b4b0bb4811edc0b087", "0xe8abe811ab30f69889988f5b32137e32f1aec7ec1491dc68b17be8eddaa17e97", "0x28ff0d7e60f4eb100bad786efefb9004d4274e7ff8d48c3af92cc48fcab9a159", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
120	36	0x6058f8E21D7D736b574e80c2B57e73fDf360bae0	5818673	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x0d74e96226741dc3eadafea3794465dfd5eac6c6219538263d084fa70600749f", "0xe21ef441150ede62f9da6b1d379f3bf875b1a06fefe662e520d85b52c945003f", "0x204e90522978efc4455386f206b0b441bbdea5ce5b24ca8b28158ce3262c5963", "0x349bbd8b6fa55a140bf1344ee94ae7fe0ded4fa2f4006ca83004621ed602c890", "0xa3c59b0e5d79f4dc42f2d3ff4534c87218390db4b26870abb9db219ee3e4b80b", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
122	38	0x60C42Ecb80C2069eb7aC1Ee18A84244c8617E8Ab	19205024	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x2dfa821979988e22286c7a5fe2583452cad4e995e678577359cdfda426b7caf1", "0x5f9ebc3e25deabd732af145e459b55c172f3d92ce5356658d9c6ed5ce86d0522", "0xf3742381508535ddd26ebdbf8586aaf7138051cc036ef806317d2eac25ce9827", "0x5f5b7003db8be724c809d3268a3d80a7600f4c4f4dc42a90748b7b1a54b92515", "0x99cc2dafecf549c4babf0015b70339ca43cdd95c69bec9fe2a344ba8143183e9", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
123	39	0x60eE0C8Bb493b79286A54997322904f74fba3736	520645	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x47c8491021098836d4df1ebef93c3e9610bff2b12de78208b4251b0192fea2f0", "0xa1de1bdfd265dba43a92ff9614bf9775f9ab387b61d9249e8b7c66f15aed7d0d", "0xc8fe9950e04c57915e0fcddf5439437e28435ba6e1d6ddcee54c86e537adde11", "0xcc74105228f8df13b29dc9352dab6b01f6dd2ce9990ccda307e2cf72f6a0f9c2", "0xcaf053c33846aaa8f6fbb1f7a75d4132cda69f172397cbd7b2ce09cd928b19d8", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
124	40	0x61D9e931A72c9FB3eB9731dCc5A30f1F6C3ab63F	53296688	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x2ca57c0ffd0de0bffd0c7c8039578c40c6f926893476fd96d3782060faa545e4", "0x3ca52e87b8809e7bfa44f61898f0ea874d01b109bc44f68376d6fcdfb5c08ddd", "0x9424ba7d753380a0b451c3a597b7ebadae9e3537e4615df79d7a13e816327c8f", "0x5f5b7003db8be724c809d3268a3d80a7600f4c4f4dc42a90748b7b1a54b92515", "0x99cc2dafecf549c4babf0015b70339ca43cdd95c69bec9fe2a344ba8143183e9", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
121	37	0x605D50F68E737eBF7F6054D6f7860010FC80971F	260942347	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xe4359ba1b2c466eddbe1b6e4a3d733c4e040699e8a46106b25213f8706dbdd5c", "0x7256e3af23038662a535912e331e84d4c42f7335b24712500d16b9e0752c2f16", "0x18c202265596dcaa0820dd9403f7a553a9fe5ce819a63d9b23860d2a908c919b", "0x621b0226039f314e62d4ec3f88a43102368e04c9c3ee2266dd32f5d072203054", "0xe4c0bdd842dcc90a8185ceced86982f2b595eb41e0ab11693765cd198ab7ce18", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	15489480	2022-09-07 09:16:06
125	41	0x641f2f8cD5Fb6CB50a49c22247B065CD893a1FC7	20243898	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xb611a4b4334d071e006de86b2ad735addfd995c81505e5ae6ddabaa5d327cff6", "0x4175d971d14c187137f365cb6e999c6992eb8957035d8ee694f400556773b117", "0x8e406feb3a35d29751c3aa341ab3936ff84def31ee342b70d9283145ccb24d30", "0x08fbe1a228db71e67ee68159d3d604c4b891ecb0d107a6b611f3bed8ad04f6f3", "0x5edafa5f7feaa44c05fc81c84df464db15f12761a510fbf938f6066d7117b162", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
126	42	0x644Be8a25BE30A21E2DFFeAE4FC43937fBCf3efd	26562255	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xc072988419cb40d2d979da82c86ae40376c98e2bbdbe3352f4e3a8764d774a76", "0xea49dfd34af8d558c1328e57dbe8cb56cd4be3324461f36d4d8e6985ac3989dc", "0x5f3f00592f0f70f3e3a142c42577056d421ec3dbb64a54809b33787a3b6d48c4", "0x6f79d0c40910c8366ab4d76b9d1bdb697fd8df4d24653c63825db6ebe036bc3b", "0xe4c0bdd842dcc90a8185ceced86982f2b595eb41e0ab11693765cd198ab7ce18", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
127	43	0x65aaeEc60C6149Bf18753F5D2c361ecbBA22651A	574060	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xdcc3e3617d71fcff019dbc328b69f07629b9ce127a7b78a06ede87e3248e250f", "0x70b76abfbb383adb21906aefb315f8f9ae33daf07d92febc90dfce75ab6c8070", "0xf0fa5d762599bf649ccbd15e396d492d2df7d6e2cf1090ade7efe453a0cb59dc", "0x621b0226039f314e62d4ec3f88a43102368e04c9c3ee2266dd32f5d072203054", "0xe4c0bdd842dcc90a8185ceced86982f2b595eb41e0ab11693765cd198ab7ce18", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
128	44	0x677f0fB523eCfe8343560ddCAAC47e1Eab34409a	5629018	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x22b9d7ad5e84446cccc8cf0176db1ff23faacdddfbf69c6ef5ee253ba2e253b5", "0xf3dcdb5cf4cbb4c5e90f7758ac63e34c648c8d92eaa9fdfcf4d74b930c4a5412", "0x1230d26fc38dc5dfcc45f1aa43e7737f48a371bac1a64237544a735eb2a502a4", "0x3ab607ebbc4a10e6a4ec561864e1fc5bcaff643a31646eb179f9f584ac658bb1", "0xa3c59b0e5d79f4dc42f2d3ff4534c87218390db4b26870abb9db219ee3e4b80b", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
129	45	0x6A04941De896E4215Eeb8e6eb1b72AD2904D2402	66356213697	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x227f5e653dde0eb63d832704b23b2d653e66b03d47448434ec4faffc00503f72", "0xf3dcdb5cf4cbb4c5e90f7758ac63e34c648c8d92eaa9fdfcf4d74b930c4a5412", "0x1230d26fc38dc5dfcc45f1aa43e7737f48a371bac1a64237544a735eb2a502a4", "0x3ab607ebbc4a10e6a4ec561864e1fc5bcaff643a31646eb179f9f584ac658bb1", "0xa3c59b0e5d79f4dc42f2d3ff4534c87218390db4b26870abb9db219ee3e4b80b", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
130	46	0x6f9BB7e454f5B3eb2310343f0E99269dC2BB8A1d	1245482436	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x78b89d18e9881d11b524fa661a3d39fec316f8509f302f589ce7c5658109fbf4", "0x6271e856bbe25f4d77c2331a24c725d1b234dc18b6095222ed14ddddc1974840", "0xab27c389aac33a5280613bbe8d35cfb6163c1c19d0911f8920a76b90c41cfbf0", "0xd48c008462c00547c5c0c21f1092301a97e7dd2df64014bcf04ef46427517154", "0x28ff0d7e60f4eb100bad786efefb9004d4274e7ff8d48c3af92cc48fcab9a159", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
131	47	0x70F9E695823A748D0f492c86bE093c220a8d487a	781233	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xc62363ad4e721af2e9c3145ae46ce264d28d51decb1906b085e68682fca80a9d", "0xccb28160582c379debb9fe4541efa4795cd40df07dd270dd75357cf781aa0905", "0xc3bca812677b6d2d433402f573624b0783362aba4ac398d951c36080e18923ba", "0x6f79d0c40910c8366ab4d76b9d1bdb697fd8df4d24653c63825db6ebe036bc3b", "0xe4c0bdd842dcc90a8185ceced86982f2b595eb41e0ab11693765cd198ab7ce18", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
132	48	0x72770a19522ACD2025b74dc130502F81a73F875C	135587095	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x3731b3db827f4c00615629fe2e55ed2c46fa0e102b5865b7d23eb197dbc4032c", "0x3e35d381f5f77d518a2a2c0ce5c6a37065670659626d69ad8bc6f7083bf5fee8", "0xb265802858875fb4df027d53974849ca462a868d8d0529787d6ed3b6e10f5cea", "0xc168a44965a74a1eaa02067ace53953b5141fe117e94ad76b07e5ed3a4b085d0", "0x99cc2dafecf549c4babf0015b70339ca43cdd95c69bec9fe2a344ba8143183e9", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
133	49	0x76FeB15406Fd0637b95C871BFA8C71FbB1854dD0	5647713	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x024d5ab59d7ca39a0f2afbdb405e97418166e7be5e1c6c3f88e9a84e5a06c5ab", "0x016543b27806e25a9c7da13ad23679fef8d1959a09914412b803457db97c4511", "0xbd1e3c6fe285c0c34cbfb67a1ea86225ddd0041e7be942f12dd33c36ff4a7b06", "0x349bbd8b6fa55a140bf1344ee94ae7fe0ded4fa2f4006ca83004621ed602c890", "0xa3c59b0e5d79f4dc42f2d3ff4534c87218390db4b26870abb9db219ee3e4b80b", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
134	50	0x78b8A76BEa31733777556033e2a116df66C4C41C	105178014	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x3dfb594639c7037e256e429c5eaff4252868a75c65d0aebc02df43dedc22015e", "0x2960b0a077a760e0bb8b3f33fb9993e8ccb890d7bed665bde57b158cf4ba35f2", "0xec90ca4ad8783feb4cf3906be499428175d383f4bf4e50d5e43b3a8739307724", "0xc168a44965a74a1eaa02067ace53953b5141fe117e94ad76b07e5ed3a4b085d0", "0x99cc2dafecf549c4babf0015b70339ca43cdd95c69bec9fe2a344ba8143183e9", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
135	51	0x7A247fF3d9BE7A89B5F71206Ec1cA3F8684bB5c3	89124	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x40cfa54b7ec61b81c0993ab875fc70ad5beada0e6e6470c65f2ea955bbbc728a", "0xfb9015ef5eb15910d03fdad299e61ba50e2049c0b77eb97cb925ad0a73beed35", "0xec90ca4ad8783feb4cf3906be499428175d383f4bf4e50d5e43b3a8739307724", "0xc168a44965a74a1eaa02067ace53953b5141fe117e94ad76b07e5ed3a4b085d0", "0x99cc2dafecf549c4babf0015b70339ca43cdd95c69bec9fe2a344ba8143183e9", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
136	52	0x7a86C44e1B41c6C37fF783E8f6B2f6c68AB251f4	31444864	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x1e76f50ca5ad9413ed0cbb1caf7c5774b21edee53b1164929527377a1d015b0c", "0x496809f32e10c0893a18cc05b0725e67752baa9a3d8166f69ff890f15830ff06", "0xa6ca3476ad4754c3920514f9001b155a6ded3326888e23f76f64dd9367047801", "0x3ab607ebbc4a10e6a4ec561864e1fc5bcaff643a31646eb179f9f584ac658bb1", "0xa3c59b0e5d79f4dc42f2d3ff4534c87218390db4b26870abb9db219ee3e4b80b", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
137	53	0x7Ba080516dBAbe9fafc1f7F548F60d27e6932c48	5225761	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xb6890094b3a8fba7df1d98d1f2e23969d75216eb7dcfb3d0c8f3a26e47cec51e", "0x6f9546d1a3e7ac92faf1319efd82452f28a757c8f4c472c5181d284d752311aa", "0x5f3f00592f0f70f3e3a142c42577056d421ec3dbb64a54809b33787a3b6d48c4", "0x6f79d0c40910c8366ab4d76b9d1bdb697fd8df4d24653c63825db6ebe036bc3b", "0xe4c0bdd842dcc90a8185ceced86982f2b595eb41e0ab11693765cd198ab7ce18", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
138	54	0x7D51910845011B41Cc32806644dA478FEfF2f11F	5383346906	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x06c9681acf79917f80e8f02d419967cc97f4abcd04a96bbad4346728e865519d", "0x312156e6faa3c24c6768f8f5ddc68c9636dad3d9fcb685540156b09223b3ee47", "0x204e90522978efc4455386f206b0b441bbdea5ce5b24ca8b28158ce3262c5963", "0x349bbd8b6fa55a140bf1344ee94ae7fe0ded4fa2f4006ca83004621ed602c890", "0xa3c59b0e5d79f4dc42f2d3ff4534c87218390db4b26870abb9db219ee3e4b80b", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
139	55	0x7df953D6BE5Fd9532a7E829cDFB72d2A9AB27000	52054798	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xed48801bc46c2f72def3c7ab8a7602a632993e109597cfe45be012f7bab0e60d", "0x5b5cf215688e44ba2fd8e6982fb14ed954f6e4253d92e81fa438df0057160c7b", "0x5583ae526dcda17805318cf82273f4997bebaa79caa4eee7a4f65604f337883f", "0xc48602e28c66ccef2767e2b33dc9470d841b599ee2d6edf51d57a5f78e41769c", "0x68f9fe7b7e8b3dee2dfce6d031b8d57ce0a64ff057bb827b03ddb951605b09d7", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
140	56	0x82bbF2B4Dc52d24Cbe0CbB6540bd4d4CeB2870B7	106170464	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xef0a3e5767a4610bd2848f5ec8e37eeec0916d2b900f5117c0ee3f88ae527079", "0xb15bf93655a3a30072a201d8b1d5d3587ab819ca5cb16d099303fe12bc31848b", "0x4e4619b22b12142d85fafe04723698a34e2509e02ffdba36cc13b30046341c31", "0xc48602e28c66ccef2767e2b33dc9470d841b599ee2d6edf51d57a5f78e41769c", "0x68f9fe7b7e8b3dee2dfce6d031b8d57ce0a64ff057bb827b03ddb951605b09d7", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
141	57	0x843aa999827ae6d187F8a5b6ab4afB1B1597551D	112906	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x7aea8d2716e434b47997e2c726fa42a27b378b7dd32592993b21fbb530a83fa3", "0x81a9f71d721ea90019848c2b2a20248cbb28e444305460667129afdc318943a5", "0xab27c389aac33a5280613bbe8d35cfb6163c1c19d0911f8920a76b90c41cfbf0", "0xd48c008462c00547c5c0c21f1092301a97e7dd2df64014bcf04ef46427517154", "0x28ff0d7e60f4eb100bad786efefb9004d4274e7ff8d48c3af92cc48fcab9a159", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
142	58	0x88888882bb6125AF160999e91bCA82b56E0b819B	131356481	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xf55be2e2935d84475d1cb5bc7a31bd02941f2b4dd438dc37051d5f0c0cb01372", "0xf8b3e3e43e13df428b419562561683ba5223ba97e9af428781f6261005b40600", "0x4388025aa18bad616b51fe465bbdf09bcf17db9207191fe8753e0f3e2ee4f35b", "0x68f9fe7b7e8b3dee2dfce6d031b8d57ce0a64ff057bb827b03ddb951605b09d7", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
143	59	0x89768Ca7E116D7971519af950DbBdf6e80b9Ded1	77343453	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x31c928546a80f38198aec2fd775563c1fc6616193c644071b6dc59275cf92e40", "0x687f0f9387c3b24415b63f9f6cf23b0b47de8dba0588671778dd2a782045ae12", "0xb265802858875fb4df027d53974849ca462a868d8d0529787d6ed3b6e10f5cea", "0xc168a44965a74a1eaa02067ace53953b5141fe117e94ad76b07e5ed3a4b085d0", "0x99cc2dafecf549c4babf0015b70339ca43cdd95c69bec9fe2a344ba8143183e9", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
144	60	0x8B600c7Ef1D97225860a7996b63c5b8b116182d5	530824734	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xf992c588f053bfdc50b296891070f4fd7f3254196be112653d78a88d85466619", "0x89a9e6bc027cb4eb0b56132a89e81e5d9b92de1f27751e2b5fc127b22955800c", "0x99629a16e2622d280c51683b346649728f0b28e4bea870fff17ce440e475ef10", "0x4388025aa18bad616b51fe465bbdf09bcf17db9207191fe8753e0f3e2ee4f35b", "0x68f9fe7b7e8b3dee2dfce6d031b8d57ce0a64ff057bb827b03ddb951605b09d7", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
145	61	0x8c302250f1F5f4A933b7a62B52E998b0a40C3917	27854940	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xed70b3a2f75c7fc124e6fff7c4876cc368a4055c6e3ab0ce84d8b0b13100c732", "0xb15bf93655a3a30072a201d8b1d5d3587ab819ca5cb16d099303fe12bc31848b", "0x4e4619b22b12142d85fafe04723698a34e2509e02ffdba36cc13b30046341c31", "0xc48602e28c66ccef2767e2b33dc9470d841b599ee2d6edf51d57a5f78e41769c", "0x68f9fe7b7e8b3dee2dfce6d031b8d57ce0a64ff057bb827b03ddb951605b09d7", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
146	62	0x8DC4310F20d59BA458b76A62141697717f93FA41	186340508	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xc2d7bd3704d233fd5d6eee0e823f9b4abfdd7379f7db599d62a09d104c9bfd90", "0xccb28160582c379debb9fe4541efa4795cd40df07dd270dd75357cf781aa0905", "0xc3bca812677b6d2d433402f573624b0783362aba4ac398d951c36080e18923ba", "0x6f79d0c40910c8366ab4d76b9d1bdb697fd8df4d24653c63825db6ebe036bc3b", "0xe4c0bdd842dcc90a8185ceced86982f2b595eb41e0ab11693765cd198ab7ce18", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
148	64	0x8fa1F8787bF4c3fC37b4DD48f472AeF08c279e42	149159123	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xb4f8d1f7939949d5c2ceff03abbe936be41dbaecfe559fb523b038cbcbd7d189", "0x4175d971d14c187137f365cb6e999c6992eb8957035d8ee694f400556773b117", "0x8e406feb3a35d29751c3aa341ab3936ff84def31ee342b70d9283145ccb24d30", "0x08fbe1a228db71e67ee68159d3d604c4b891ecb0d107a6b611f3bed8ad04f6f3", "0x5edafa5f7feaa44c05fc81c84df464db15f12761a510fbf938f6066d7117b162", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
149	65	0x9497243478392B1F7f508874F606379F989C6eea	58552082	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x2763c908b12070e0195b7aff42f0765794bcc68f47e044ea93280a78f9e8c417", "0x635ce99c6036853048f67609b9fccb3c44759da390cbdf89d8ae30a2d8908fa1", "0x9424ba7d753380a0b451c3a597b7ebadae9e3537e4615df79d7a13e816327c8f", "0x5f5b7003db8be724c809d3268a3d80a7600f4c4f4dc42a90748b7b1a54b92515", "0x99cc2dafecf549c4babf0015b70339ca43cdd95c69bec9fe2a344ba8143183e9", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
150	66	0x987f05B5eEB8B30b02329D3888bebc3a7424e999	420274862	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xef546c0bcd3fab8f61e97e9d294c8fdcadbd5c0b50a0718cbd0f0093006868a6", "0x9a2617e5c8b63681b61282adbdec47588a8dfbfdb1355610be27f9b98ef872bd", "0x4e4619b22b12142d85fafe04723698a34e2509e02ffdba36cc13b30046341c31", "0xc48602e28c66ccef2767e2b33dc9470d841b599ee2d6edf51d57a5f78e41769c", "0x68f9fe7b7e8b3dee2dfce6d031b8d57ce0a64ff057bb827b03ddb951605b09d7", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
151	67	0x9a4a43a48F6BD53fEF42B1565F14d24E1f9f41E8	9204339	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x2ec85209d2dc361de35979d034e7fc9b9ad014c35c9cb39c622fbdbea635a3c9", "0x9d16d7251b1bdd5ff13063c1f015d708d8e08a5eabb8057fe0cc27089c83b3b8", "0xf3742381508535ddd26ebdbf8586aaf7138051cc036ef806317d2eac25ce9827", "0x5f5b7003db8be724c809d3268a3d80a7600f4c4f4dc42a90748b7b1a54b92515", "0x99cc2dafecf549c4babf0015b70339ca43cdd95c69bec9fe2a344ba8143183e9", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
152	68	0x9B2b78003e469A342977e0a078F6Aef88077acD9	5685439	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x39fb446fde5208291c1f6c315e592e0b8dc8e90eea96b28195c0473549979f35", "0x2960b0a077a760e0bb8b3f33fb9993e8ccb890d7bed665bde57b158cf4ba35f2", "0xec90ca4ad8783feb4cf3906be499428175d383f4bf4e50d5e43b3a8739307724", "0xc168a44965a74a1eaa02067ace53953b5141fe117e94ad76b07e5ed3a4b085d0", "0x99cc2dafecf549c4babf0015b70339ca43cdd95c69bec9fe2a344ba8143183e9", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
154	70	0x9c27c3aa042a608F67d19bDA36b099a062185A65	52055855	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xd60dda879a328d5a3b0ed596d22325de7900daa009b7598aacc540e3b024a2ba", "0xd9382c3b709f8f467feefa81497786196ed402cbcdea0c83f0753f11d37ddb46", "0xf0fa5d762599bf649ccbd15e396d492d2df7d6e2cf1090ade7efe453a0cb59dc", "0x621b0226039f314e62d4ec3f88a43102368e04c9c3ee2266dd32f5d072203054", "0xe4c0bdd842dcc90a8185ceced86982f2b595eb41e0ab11693765cd198ab7ce18", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
155	71	0x9cBddD3a8320583bFa7fA78c02a7F7226805f7ab	212447327	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x80e65b9760e9b15bdbefd8ca4cab3d8c76d3183fd73e5a4872d53a3c489a253d", "0xca11a27c66723adf5c6a5a73402ea2eeae4b8322fcb093c5e7f4cba3f86aad68", "0xe992624fe43ac2884ac4b4ac88891324b25616da3d10589da04e1f431ebe584d", "0xe8abe811ab30f69889988f5b32137e32f1aec7ec1491dc68b17be8eddaa17e97", "0x28ff0d7e60f4eb100bad786efefb9004d4274e7ff8d48c3af92cc48fcab9a159", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
156	72	0xA4Bd35E96887170a2D484e894078A5cB1AB93A45	6983456	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xf345292724deb1ad190376b52ba9f36c7b354af84aa1566221f10d0bb8747e9f", "0x63d9ebb935cad0469a7959f77e3c0ed83d7d3368855e932b15ed23055dbf814d", "0x99629a16e2622d280c51683b346649728f0b28e4bea870fff17ce440e475ef10", "0x4388025aa18bad616b51fe465bbdf09bcf17db9207191fe8753e0f3e2ee4f35b", "0x68f9fe7b7e8b3dee2dfce6d031b8d57ce0a64ff057bb827b03ddb951605b09d7", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
157	73	0xAAa017530E01e7BF6D69F29756870F4dd09b74d6	112556	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x4d26d77a31107683b6b91fdb50b140120e1dd89a27eaaa59dfd10ed70eb27a5f", "0x642d6a974367f7bbb028355d3f0e3ce9d4fd71f69c373b39179c0c6ed41afe39", "0xc8fe9950e04c57915e0fcddf5439437e28435ba6e1d6ddcee54c86e537adde11", "0xcc74105228f8df13b29dc9352dab6b01f6dd2ce9990ccda307e2cf72f6a0f9c2", "0xcaf053c33846aaa8f6fbb1f7a75d4132cda69f172397cbd7b2ce09cd928b19d8", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
158	74	0xaB7b49bacd43BD4CfA41433D477F690Bb9E1fB26	79625899	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xb4c53690936c2458c6862d40992ffb77c230438d8b769cedbaaf082981f2ca53", "0x46348778e308c6af344b72b4659efe9e3ad38799a9520ef4b1f77a0f4063afe7", "0x8e406feb3a35d29751c3aa341ab3936ff84def31ee342b70d9283145ccb24d30", "0x08fbe1a228db71e67ee68159d3d604c4b891ecb0d107a6b611f3bed8ad04f6f3", "0x5edafa5f7feaa44c05fc81c84df464db15f12761a510fbf938f6066d7117b162", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
159	75	0xabc42ca4eab3C98543C1C15ca89280888ba6109d	5413779	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xe06a202b76e7e6ffea5f1f79c73ece1ed8849efc8533ef8341c67498fbf40444", "0xc98f961873d240df918592920e0cd77e2cda4eaffa78e6d08deb1715b52496fb", "0x18c202265596dcaa0820dd9403f7a553a9fe5ce819a63d9b23860d2a908c919b", "0x621b0226039f314e62d4ec3f88a43102368e04c9c3ee2266dd32f5d072203054", "0xe4c0bdd842dcc90a8185ceced86982f2b595eb41e0ab11693765cd198ab7ce18", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
161	77	0xaFbe2Fe7325418ac50337ACe4cD86ee0bfA245C7	30634225	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x58330dfbd374eaf449c6bd3f1f057d12dd68a6ecc9bdcad95180f1eae2c5fb80", "0xfd8abadb57cf2ce76368db09fba98ec7f91b7493c193487e9266d255120d7d4d", "0x673959062dc2638bc6ff7a69622ac893558907c5a8d11114feed9b1b375e56c1", "0x9db93fb4966878cebb91145aeba7f152eb32b9cb74c97883a0dc3e33eff70d44", "0xcaf053c33846aaa8f6fbb1f7a75d4132cda69f172397cbd7b2ce09cd928b19d8", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
174	90	0xc92c4df3DD076d3ef60f2c6C533eE16616F4d8A5	176783	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xe735787f0c9fffa6b95dae2cff2bb1ffda5ffecb98256097888cf7193f26411e", "0xbb41b83b9993d9dc252a76268675b138ba5b79aae7dfe7ac33db72ae698b1bae", "0x5583ae526dcda17805318cf82273f4997bebaa79caa4eee7a4f65604f337883f", "0xc48602e28c66ccef2767e2b33dc9470d841b599ee2d6edf51d57a5f78e41769c", "0x68f9fe7b7e8b3dee2dfce6d031b8d57ce0a64ff057bb827b03ddb951605b09d7", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
153	69	0x9b818ad72E4B3cd03bCBE4848a44b274618C4CBE	105519926	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x836a68c13b853001fe077b2e7a047046d09ec0b83aa74c110520c04b7884123b", "0xb6083204e9e7a5367b9af2d08083fdc5141b208d53412021d79c6c22816663cb", "0xe992624fe43ac2884ac4b4ac88891324b25616da3d10589da04e1f431ebe584d", "0xe8abe811ab30f69889988f5b32137e32f1aec7ec1491dc68b17be8eddaa17e97", "0x28ff0d7e60f4eb100bad786efefb9004d4274e7ff8d48c3af92cc48fcab9a159", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	15489528	2022-09-07 09:28:40
162	78	0xB26d1fE1328172b38708d7f334dd385b6d6fB4AA	265362454	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xad577735691f614c882d40209f7658443fc58030fa6518fcc0b7937d2169a599", "0x889bb05c77dd23ca217dd7cd4fe2763140a2ed4c5e5d959f97a1e51d057694e6", "0xd915c49e421f2c6a47d6ab09ed0ae141cb58237bb339a873ff432917bb58f606", "0x08fbe1a228db71e67ee68159d3d604c4b891ecb0d107a6b611f3bed8ad04f6f3", "0x5edafa5f7feaa44c05fc81c84df464db15f12761a510fbf938f6066d7117b162", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
163	79	0xb42f5A41B62b52616598cfD1A0D3A01846Bfa888	5770614	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xddbb94441384f469834ff673d94cf2b2c1b4e013ca6b77c4316cbabf45aeac00", "0x70b76abfbb383adb21906aefb315f8f9ae33daf07d92febc90dfce75ab6c8070", "0xf0fa5d762599bf649ccbd15e396d492d2df7d6e2cf1090ade7efe453a0cb59dc", "0x621b0226039f314e62d4ec3f88a43102368e04c9c3ee2266dd32f5d072203054", "0xe4c0bdd842dcc90a8185ceced86982f2b595eb41e0ab11693765cd198ab7ce18", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
164	80	0xb98CC80fD75333dC20A9D122d98B5638AaF4FfC3	53843889185	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xa3bf5bbc83e36be24edad53b55a6483836b335f25ae5327345ca852db57d5f1f", "0xaa587c7382c72bdf7a47dc0bbf13dd22fcf984e4ab01fea5a008a9d602664cee", "0x35992df4c952bb93f59ac25f6ab9c869da5c75273c85a7c44b6386fc3748664e", "0x05fabdedf2ebeec4ae3e8aa842d7b0d1032b25528d26df0119fb732210f3c5ab", "0x5edafa5f7feaa44c05fc81c84df464db15f12761a510fbf938f6066d7117b162", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
165	81	0xbAA3A36ade58A3593972B7728A97916ed82ee371	6302907	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xa53c8fe3c665db481ff95ff7f76b85a65336f0a0df2569fcfbce63a3d39735e7", "0xa8b5d5634fc81cf8673b2e698c9454f02e26ee96d15ef462be06a5a024294cdd", "0xd915c49e421f2c6a47d6ab09ed0ae141cb58237bb339a873ff432917bb58f606", "0x08fbe1a228db71e67ee68159d3d604c4b891ecb0d107a6b611f3bed8ad04f6f3", "0x5edafa5f7feaa44c05fc81c84df464db15f12761a510fbf938f6066d7117b162", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
167	83	0xc0555149B5A5D96AC016d3425b7986504190c3a0	5345550	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xaaf986b9e2dfd1d9cf48d90ef62039f4b1a4c58854a59070fc46e17695165965", "0x889bb05c77dd23ca217dd7cd4fe2763140a2ed4c5e5d959f97a1e51d057694e6", "0xd915c49e421f2c6a47d6ab09ed0ae141cb58237bb339a873ff432917bb58f606", "0x08fbe1a228db71e67ee68159d3d604c4b891ecb0d107a6b611f3bed8ad04f6f3", "0x5edafa5f7feaa44c05fc81c84df464db15f12761a510fbf938f6066d7117b162", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
168	84	0xC134041A85EdBb3BD9CAE36A32486454c1c6e134	6353421	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xa44e9428e0fd0fc32a5a51c96e3d8a75326c3e62f91b8e489f4338f5839cdde7", "0xaa587c7382c72bdf7a47dc0bbf13dd22fcf984e4ab01fea5a008a9d602664cee", "0x35992df4c952bb93f59ac25f6ab9c869da5c75273c85a7c44b6386fc3748664e", "0x05fabdedf2ebeec4ae3e8aa842d7b0d1032b25528d26df0119fb732210f3c5ab", "0x5edafa5f7feaa44c05fc81c84df464db15f12761a510fbf938f6066d7117b162", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
169	85	0xc2a622b764878FaF9ab9078aD31303B24Fd4b707	33338531	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x520aba28a81b04b56ca9f0df79efa7f41e51427847720f2c7b3cc836505bce4d", "0x20f1d8fb1b243834dadd2a959b15e968e0782fca93b6142f3e1d3d483a514579", "0xe14971af7dbbc265b309d5f5ed38e32891f25af502e14fdf29d33c432ea24e90", "0x9db93fb4966878cebb91145aeba7f152eb32b9cb74c97883a0dc3e33eff70d44", "0xcaf053c33846aaa8f6fbb1f7a75d4132cda69f172397cbd7b2ce09cd928b19d8", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
170	86	0xC2Ac36c669fBf04DD2E1a2ED9Ce5ccC442977305	11942332	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x875096903cd1d724dc444a39bc3043c89f7e3eddbac272a23406b36aa7d24f22", "0xab380d30b473f66d38fa953c38ae6c549a1a22cc71877e961a20ba190794f4db", "0x95c7bd05a271c38f758173a8bc258df64ff515e9352581b4b0bb4811edc0b087", "0xe8abe811ab30f69889988f5b32137e32f1aec7ec1491dc68b17be8eddaa17e97", "0x28ff0d7e60f4eb100bad786efefb9004d4274e7ff8d48c3af92cc48fcab9a159", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
171	87	0xc4676e5E99b823E54B3e6c32c8143BB441633eEA	27604271	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x178356a2bdaef57390c16497d9ca6ed7d86ab26322678fcdf9b4fd0cee1220c4", "0xfe874403ed79fe713284e5911dd5bef1169b69405422502041f61d590ae8c1a2", "0xa6ca3476ad4754c3920514f9001b155a6ded3326888e23f76f64dd9367047801", "0x3ab607ebbc4a10e6a4ec561864e1fc5bcaff643a31646eb179f9f584ac658bb1", "0xa3c59b0e5d79f4dc42f2d3ff4534c87218390db4b26870abb9db219ee3e4b80b", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
172	88	0xC887b3406424838aE65456860278a5e6e40fCb08	5265586	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xebb08554bad9b0e39eea89ac27a1353f54594dce331d9ea164e80ec56822a825", "0x5b5cf215688e44ba2fd8e6982fb14ed954f6e4253d92e81fa438df0057160c7b", "0x5583ae526dcda17805318cf82273f4997bebaa79caa4eee7a4f65604f337883f", "0xc48602e28c66ccef2767e2b33dc9470d841b599ee2d6edf51d57a5f78e41769c", "0x68f9fe7b7e8b3dee2dfce6d031b8d57ce0a64ff057bb827b03ddb951605b09d7", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
173	89	0xc88d7DC8Dfa23d3769f7e8241f761D09A10D9831	52055068	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x4368489a14c73e8f6b75222825eae8b8fd9e11f866e8c4204fdc3c4661088d79", "0xfb9015ef5eb15910d03fdad299e61ba50e2049c0b77eb97cb925ad0a73beed35", "0xec90ca4ad8783feb4cf3906be499428175d383f4bf4e50d5e43b3a8739307724", "0xc168a44965a74a1eaa02067ace53953b5141fe117e94ad76b07e5ed3a4b085d0", "0x99cc2dafecf549c4babf0015b70339ca43cdd95c69bec9fe2a344ba8143183e9", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
176	92	0xcb630c28658d8B4f0509D628D8d947e6F95eA20A	15808664	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x9cdc45e8adcf0b997306e50879a34687f8f035b393d3268725ce06b5aacff698", "0x8a15010b71e0462f04cc42fe3ea3d175a8755b843f76e12ea4196aa833ca212f", "0x35992df4c952bb93f59ac25f6ab9c869da5c75273c85a7c44b6386fc3748664e", "0x05fabdedf2ebeec4ae3e8aa842d7b0d1032b25528d26df0119fb732210f3c5ab", "0x5edafa5f7feaa44c05fc81c84df464db15f12761a510fbf938f6066d7117b162", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
177	93	0xcd5561b1be55C1Fa4BbA4749919A03219497B6eF	22573394	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x758e13e85ca2f61bf03df687cdbd3c74386380e1b97bdbff5372616c8378742f", "0x6271e856bbe25f4d77c2331a24c725d1b234dc18b6095222ed14ddddc1974840", "0xab27c389aac33a5280613bbe8d35cfb6163c1c19d0911f8920a76b90c41cfbf0", "0xd48c008462c00547c5c0c21f1092301a97e7dd2df64014bcf04ef46427517154", "0x28ff0d7e60f4eb100bad786efefb9004d4274e7ff8d48c3af92cc48fcab9a159", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
178	94	0xCfaF3E19Dca4b4cb0fB1399abB7Ec074AbE39114	529288	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x2cec2f585e7b7567838ddc63d5f53158502a443018bd1e0fdb3f9567e3592d88", "0x3ca52e87b8809e7bfa44f61898f0ea874d01b109bc44f68376d6fcdfb5c08ddd", "0x9424ba7d753380a0b451c3a597b7ebadae9e3537e4615df79d7a13e816327c8f", "0x5f5b7003db8be724c809d3268a3d80a7600f4c4f4dc42a90748b7b1a54b92515", "0x99cc2dafecf549c4babf0015b70339ca43cdd95c69bec9fe2a344ba8143183e9", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
179	95	0xD43Ca531907f8C8dBb3272Cc2EF321cC572E56E3	94754688	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x365a3b4afed34e9a7b0c6ec50901aec17bc36368f6f2d47260951300f8039723", "0x3e35d381f5f77d518a2a2c0ce5c6a37065670659626d69ad8bc6f7083bf5fee8", "0xb265802858875fb4df027d53974849ca462a868d8d0529787d6ed3b6e10f5cea", "0xc168a44965a74a1eaa02067ace53953b5141fe117e94ad76b07e5ed3a4b085d0", "0x99cc2dafecf549c4babf0015b70339ca43cdd95c69bec9fe2a344ba8143183e9", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
180	96	0xd8742073F4F44d0046916a9B62A955A36e0c0e5f	53093695	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x8c1c21670a4359e0e01b307ad94769cd70102fcb2f554a7579f61190b8987d51", "0x8f4232a99b2a5f5b103c9cc19047dc35c0efc31418794c3a96fee9d2c0b7db02", "0xc1d504a8d5fabb1d02dcf934b16a0a56eeea11e20374b9578701ad3e7afee823", "0x05fabdedf2ebeec4ae3e8aa842d7b0d1032b25528d26df0119fb732210f3c5ab", "0x5edafa5f7feaa44c05fc81c84df464db15f12761a510fbf938f6066d7117b162", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
181	97	0xdD32231c664f6e3456e81ec6c27C6f429C7dc3b3	5127994	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xefb361739b04d832a57b7f646f990a9b1aada09a406819826a9bf2fee2b7e7a5", "0x9a2617e5c8b63681b61282adbdec47588a8dfbfdb1355610be27f9b98ef872bd", "0x4e4619b22b12142d85fafe04723698a34e2509e02ffdba36cc13b30046341c31", "0xc48602e28c66ccef2767e2b33dc9470d841b599ee2d6edf51d57a5f78e41769c", "0x68f9fe7b7e8b3dee2dfce6d031b8d57ce0a64ff057bb827b03ddb951605b09d7", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
182	98	0xdd4A19DC351Ba42421dB282196AF38b433AA86BA	53350313	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x004ad51a17216c4ddce03c2d092d82a1843147d992ae7e9e40a2b488d40e6c09", "0x371c3b7bc3b728d521689cabdd61e29752eb33bbd467d29af09df1cd1de71dd2", "0xbd1e3c6fe285c0c34cbfb67a1ea86225ddd0041e7be942f12dd33c36ff4a7b06", "0x349bbd8b6fa55a140bf1344ee94ae7fe0ded4fa2f4006ca83004621ed602c890", "0xa3c59b0e5d79f4dc42f2d3ff4534c87218390db4b26870abb9db219ee3e4b80b", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
183	99	0xde0634a1F956Df8580f18C955B3e9EE957e552C6	291391841	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x537a9b62aeb7a585196e2505dd20ae2f739d20caedf750a3f7a9a7b5e271fe99", "0xfd8abadb57cf2ce76368db09fba98ec7f91b7493c193487e9266d255120d7d4d", "0x673959062dc2638bc6ff7a69622ac893558907c5a8d11114feed9b1b375e56c1", "0x9db93fb4966878cebb91145aeba7f152eb32b9cb74c97883a0dc3e33eff70d44", "0xcaf053c33846aaa8f6fbb1f7a75d4132cda69f172397cbd7b2ce09cd928b19d8", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
184	100	0xDe3258C1C45a557F4924d1E4e3d0A4E5341607Ee	13112063228	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x43fa4706cf893cafc1ed41f5048388da78bdc87d314c086c83a5f21a7c820a84", "0xd9adb4ad261afe80d72f57838d611ccec4fc6cbd8449231c001b766a6597099e", "0x3269a889ef513df7d18dddb0ba5a8aad4f13cf9c6318b0d18a7e6975fbcfd082", "0xcc74105228f8df13b29dc9352dab6b01f6dd2ce9990ccda307e2cf72f6a0f9c2", "0xcaf053c33846aaa8f6fbb1f7a75d4132cda69f172397cbd7b2ce09cd928b19d8", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
185	101	0xdF6C74e0387570344C4C36FF77C79fd805c5b5F7	5629088	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x26fd234fca10b37c0735f15610cd86df8142347e267dabb127ea601dd60d5b89", "0x9603c0b0fc0e6c0b4ce7a5216f107190f9b1b49505b8b74624af3d426a0b3f68", "0x1230d26fc38dc5dfcc45f1aa43e7737f48a371bac1a64237544a735eb2a502a4", "0x3ab607ebbc4a10e6a4ec561864e1fc5bcaff643a31646eb179f9f584ac658bb1", "0xa3c59b0e5d79f4dc42f2d3ff4534c87218390db4b26870abb9db219ee3e4b80b", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
186	102	0xDf839BbBE062AE73493a6961fC34849b53F1c154	27536574	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x4e0d7ed5af426a1d0aaab90d537f835aa99dd5688750b4f4ae74cd0375cae831", "0x642d6a974367f7bbb028355d3f0e3ce9d4fd71f69c373b39179c0c6ed41afe39", "0xc8fe9950e04c57915e0fcddf5439437e28435ba6e1d6ddcee54c86e537adde11", "0xcc74105228f8df13b29dc9352dab6b01f6dd2ce9990ccda307e2cf72f6a0f9c2", "0xcaf053c33846aaa8f6fbb1f7a75d4132cda69f172397cbd7b2ce09cd928b19d8", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
187	103	0xE1d1c5F48f708aa038AA6A9976308Cd1d19D951a	53350239	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xfac018060e1a374ebe75262ca2f6bab33b6c3e0d34b97b9cc7f4be5d8ef87ed0", "0xfdb0820360ebe555c73eb6abf39625f326625b7bd130ba4728a8f1ff8a230ce5", "0xf8b3e3e43e13df428b419562561683ba5223ba97e9af428781f6261005b40600", "0x4388025aa18bad616b51fe465bbdf09bcf17db9207191fe8753e0f3e2ee4f35b", "0x68f9fe7b7e8b3dee2dfce6d031b8d57ce0a64ff057bb827b03ddb951605b09d7", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
189	105	0xe45c950EFB371C331fFEF421B5C8787c74830479	6245428	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x327d3ade86ea347e384f608046951d7b34c0d268403f38b10b5a0a7c23490966", "0x687f0f9387c3b24415b63f9f6cf23b0b47de8dba0588671778dd2a782045ae12", "0xb265802858875fb4df027d53974849ca462a868d8d0529787d6ed3b6e10f5cea", "0xc168a44965a74a1eaa02067ace53953b5141fe117e94ad76b07e5ed3a4b085d0", "0x99cc2dafecf549c4babf0015b70339ca43cdd95c69bec9fe2a344ba8143183e9", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
190	106	0xEE15f56C09Dd300dc039dE1901BCcca32a23a253	87312871872	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x8859adf583ac16f3dc1f0e6c986faf3c2c665c454591aebaa6e21b586a95df0e", "0x20d17c53ed093c56cbdc6639c112611108743a5f54cc732e8781f3acd5862680", "0x95c7bd05a271c38f758173a8bc258df64ff515e9352581b4b0bb4811edc0b087", "0xe8abe811ab30f69889988f5b32137e32f1aec7ec1491dc68b17be8eddaa17e97", "0x28ff0d7e60f4eb100bad786efefb9004d4274e7ff8d48c3af92cc48fcab9a159", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
191	107	0xeEEC0e4927704ab3BBE5df7F4EfFa818b43665a3	220990690	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xcbe29075838b7f37d4ec82ee58608686756468e43e8bbf6a62af167377a6618f", "0xf28f4b3ce455f7371e0b527314dc32e3ee3765c3735bd8ef17f68fa72e0b877d", "0xc3bca812677b6d2d433402f573624b0783362aba4ac398d951c36080e18923ba", "0x6f79d0c40910c8366ab4d76b9d1bdb697fd8df4d24653c63825db6ebe036bc3b", "0xe4c0bdd842dcc90a8185ceced86982f2b595eb41e0ab11693765cd198ab7ce18", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
192	108	0xF977bF5f5CCB1BFd868BD95D563294494F0D5d89	53297154	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x9418ff1062a31d97cc14f3fc9bb3940b6e9e07941d2801d80782e7d1aa2657b1", "0xa879e07f7d7424c4ef6b4d3c114525776e02f677cc730163549c3f32a4f67d0a", "0xc1d504a8d5fabb1d02dcf934b16a0a56eeea11e20374b9578701ad3e7afee823", "0x05fabdedf2ebeec4ae3e8aa842d7b0d1032b25528d26df0119fb732210f3c5ab", "0x5edafa5f7feaa44c05fc81c84df464db15f12761a510fbf938f6066d7117b162", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	\N	\N
194	110	0xfC0591893B0BDb4322D25BDd43904Aa9aB137140	11157595	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x00e8171ce4f84c7f497678d21638d0cc17849b6ddad98d510c8d8192dbf2d0d4", "0x371c3b7bc3b728d521689cabdd61e29752eb33bbd467d29af09df1cd1de71dd2", "0xbd1e3c6fe285c0c34cbfb67a1ea86225ddd0041e7be942f12dd33c36ff4a7b06", "0x349bbd8b6fa55a140bf1344ee94ae7fe0ded4fa2f4006ca83004621ed602c890", "0xa3c59b0e5d79f4dc42f2d3ff4534c87218390db4b26870abb9db219ee3e4b80b", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	\N	\N
188	104	0xE400820f3D60d77a3EC8018d44366ed0d334f93C	5308501	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x61333535b82bc412d125845fbaf5c598cb2a8332816d9e2f8f005a78b03137b0", "0x4fe6b463f09abdf608bac310811d289e0b8d32ce45853eb2c24bb0aed46fc756", "0xfea2015912db92559503a34c02870da8c90a9c24b36aa16c41f9d81be5b03bfb", "0xd48c008462c00547c5c0c21f1092301a97e7dd2df64014bcf04ef46427517154", "0x28ff0d7e60f4eb100bad786efefb9004d4274e7ff8d48c3af92cc48fcab9a159", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	15478260	2022-09-05 14:01:20
77	76	0xE400820f3D60d77a3EC8018d44366ed0d334f93C	23563636361999998976	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0xfe05e32cd5fb969a2910f3e5ef4bb24356b7e9bb532e5ba2ceb3d86d01812bf1", "0xfffb814b839bf375e0120bec38a6512867a241e3160bc8e92829e0a459389658", "0x9794c424b35f9c13f51aa84cc7373d1bbfdbab1dc8c2d9607971f6384b9c2ac5", "0x760ec1bd66ff0cac3f4625d9c6d59fe5bf21be693b8480b69eadee0741e371a6"]	15478266	2022-09-05 14:02:27
160	76	0xAe4281d74056F3975941b66daf324bB893279cF0	573199	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x5275b6151849c17e72f974e1024f61194da90bd015478f1c69ae9d40c498171c", "0x20f1d8fb1b243834dadd2a959b15e968e0782fca93b6142f3e1d3d483a514579", "0xe14971af7dbbc265b309d5f5ed38e32891f25af502e14fdf29d33c432ea24e90", "0x9db93fb4966878cebb91145aeba7f152eb32b9cb74c97883a0dc3e33eff70d44", "0xcaf053c33846aaa8f6fbb1f7a75d4132cda69f172397cbd7b2ce09cd928b19d8", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	15478374	2022-09-05 14:26:56
116	32	0x5584cF54ADE7C81aB6d6Bc870C714F87FC0a7721	265426710	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x51e6f75b89763f0f7f2f187fc83852497611fe25246adabb4b5d3525459f36c8", "0xd7328d53a5fddf74bcff73795942a09cc26903268e2a6bf38f8a34d4ead22547", "0xe14971af7dbbc265b309d5f5ed38e32891f25af502e14fdf29d33c432ea24e90", "0x9db93fb4966878cebb91145aeba7f152eb32b9cb74c97883a0dc3e33eff70d44", "0xcaf053c33846aaa8f6fbb1f7a75d4132cda69f172397cbd7b2ce09cd928b19d8", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	15483557	2022-09-06 10:30:54
23	22	0x5584cF54ADE7C81aB6d6Bc870C714F87FC0a7721	1178181818099999965184	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x0536fbe77385f684a40fa8a131a861b0370ac4cd76211e79c52b62425cc02a4f", "0xbccc176fd407bb6fe5c0c08f83ead495d593f5516993834fedb4bcd55f71e1ff", "0x37c54b2583e36a970b7f0766e4a3e0501640011d3b2ef27cebeac4537cf336c5", "0xd31c285ad6ee45c08c4e1e6f5bbcb746ce2ab52f77b254d01a650a2935523e57", "0x490b1fedef934dd64563585efd3d770c1bab290715fc9a278492a24b4b422ba2", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	15483563	2022-09-06 10:31:50
175	91	0xCA1Af846C9194e82561dd9a93fFC9A9c851b3B1c	74319478494	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x8456127630520875aa73bdd9b48c20aa1dcff4cb336a53d300caaa7946fff762", "0xb6083204e9e7a5367b9af2d08083fdc5141b208d53412021d79c6c22816663cb", "0xe992624fe43ac2884ac4b4ac88891324b25616da3d10589da04e1f431ebe584d", "0xe8abe811ab30f69889988f5b32137e32f1aec7ec1491dc68b17be8eddaa17e97", "0x28ff0d7e60f4eb100bad786efefb9004d4274e7ff8d48c3af92cc48fcab9a159", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	15484710	2022-09-06 14:47:54
66	65	0xCA1Af846C9194e82561dd9a93fFC9A9c851b3B1c	329890909067999967182848	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x521d562dd730853bca11a88e48ad0fa6a1d9f28f0569afdf92c2262fdae0d938", "0x92ca506ac64cbda4f724ab90a82bcff59799abc09175cda83a4760dd5df20408", "0xae9fd6609a79c62b827e3808dd44556c4b2deb5ed31bf67ca96ecb51b7709733", "0x61ce104d4609443f391e8c0d51fee3bc23998b2b65998d5bcc08d6aa5aac6896", "0x5901ae8481b97bbe4d5d35652dd94bf3077153c9d61fefaeb6466961d62ce60f", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	15484727	2022-09-06 14:51:55
193	109	0xfB28bB6CFCf19cb8784472226CCd13F2e5224000	265423087	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0xc951ff6bd92ee98405b6a8ae36173e75e04cd69724b9ad4a1458a8145e7a1c0a", "0xf28f4b3ce455f7371e0b527314dc32e3ee3765c3735bd8ef17f68fa72e0b877d", "0xc3bca812677b6d2d433402f573624b0783362aba4ac398d951c36080e18923ba", "0x6f79d0c40910c8366ab4d76b9d1bdb697fd8df4d24653c63825db6ebe036bc3b", "0xe4c0bdd842dcc90a8185ceced86982f2b595eb41e0ab11693765cd198ab7ce18", "0xa617e9d0a5066bce254562953db0c59fb9abedffa3b4e401204ea674e4ffee68", "0xeadcf26b4910e18655c15cbd4981f9443bf8bec3faec1935185876f10d2ccebc"]	15487285	2022-09-07 00:45:41
147	63	0x8e1fD9D5Eac794555594B9B9F700Bc37Da6Aeab1	116111217	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x5f7925417975742f15e4443e524931151546348ff5cf7a2f47f223c9a7fbeaf1", "0x4fe6b463f09abdf608bac310811d289e0b8d32ce45853eb2c24bb0aed46fc756", "0xfea2015912db92559503a34c02870da8c90a9c24b36aa16c41f9d81be5b03bfb", "0xd48c008462c00547c5c0c21f1092301a97e7dd2df64014bcf04ef46427517154", "0x28ff0d7e60f4eb100bad786efefb9004d4274e7ff8d48c3af92cc48fcab9a159", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	15488440	2022-09-07 05:03:30
46	45	0x8e1fD9D5Eac794555594B9B9F700Bc37Da6Aeab1	518399999963999961088	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x5d29225e04ba781b5c6ac0a87669de20eb816bda982fc811f1ef1b0513225639", "0xc6b76987b05d0125242aa3dbb67754959afe820ba16321ba06a4ae0a43636c86", "0xae9fd6609a79c62b827e3808dd44556c4b2deb5ed31bf67ca96ecb51b7709733", "0x61ce104d4609443f391e8c0d51fee3bc23998b2b65998d5bcc08d6aa5aac6896", "0x5901ae8481b97bbe4d5d35652dd94bf3077153c9d61fefaeb6466961d62ce60f", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	15488457	2022-09-07 05:09:52
91	7	0x0Aa3Dceb1e65b8f7d3a58Bed68054b1c81585002	53746247	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x4755ba2b84218b50b3677a5603fdca75e219a0dbfe961710e33dffb77dab1719", "0x2d22132a8755322838e5e87fa75d1a0d9e2e0ab56b76b9e7fdfe70854e90fb07", "0x3269a889ef513df7d18dddb0ba5a8aad4f13cf9c6318b0d18a7e6975fbcfd082", "0xcc74105228f8df13b29dc9352dab6b01f6dd2ce9990ccda307e2cf72f6a0f9c2", "0xcaf053c33846aaa8f6fbb1f7a75d4132cda69f172397cbd7b2ce09cd928b19d8", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	15489371	2022-09-07 08:49:46
50	49	0x9b818ad72E4B3cd03bCBE4848a44b274618C4CBE	471272727240000012288	SHER	0x22b055CC2bbE30EBA40efC499c7f918bB1996E9c	["0x189d86fd4cfc94d450d8ceeecb11311a64830c2af598f9a98430fa82b0a74eef", "0xcc759575963322342177778ea031a5487f18768f2c927bdabc3fcbff24c8c266", "0xdc5e9a42776846027c0c3f09a89ff7480f2148f129c7806d06adffee3bf4e5bb", "0xd31c285ad6ee45c08c4e1e6f5bbcb746ce2ab52f77b254d01a650a2935523e57", "0x490b1fedef934dd64563585efd3d770c1bab290715fc9a278492a24b4b422ba2", "0x6432a58f5df13c463d13fb0f254b48a1da5a84383dedd8f709bc70d79ad0d54f", "0x14108f2e722d6cdfaff9e9dde0e298d7a896fe24a9fbde9cb44a3eb064031836"]	15489524	2022-09-07 09:26:59
100	16	0x1efb3038DE631CfcE0C0A231952c6B90d5D9cFE5	52843293	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x8857aa99426e7265aa544ac937b4249957f3bfda7d4adbe565e65bf6ce893b09", "0x20d17c53ed093c56cbdc6639c112611108743a5f54cc732e8781f3acd5862680", "0x95c7bd05a271c38f758173a8bc258df64ff515e9352581b4b0bb4811edc0b087", "0xe8abe811ab30f69889988f5b32137e32f1aec7ec1491dc68b17be8eddaa17e97", "0x28ff0d7e60f4eb100bad786efefb9004d4274e7ff8d48c3af92cc48fcab9a159", "0x3a54f776b71d76c479aea8c8c0ee308a3682a1fe1db69b1d22930c864581b7ca", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	15498740	2022-09-08 20:46:55
166	82	0xbBf6507bCAB4128Ab99AA89b3eE750880fF5D56B	1061699224	USDC	0x840F8E8c039d013A6c7BA4Ccb74b5dC953be8e24	["0x2c68868180b35d23cc1512192f7d20786085ef198d977e44a3a7d1351c4db943", "0x635ce99c6036853048f67609b9fccb3c44759da390cbdf89d8ae30a2d8908fa1", "0x9424ba7d753380a0b451c3a597b7ebadae9e3537e4615df79d7a13e816327c8f", "0x5f5b7003db8be724c809d3268a3d80a7600f4c4f4dc42a90748b7b1a54b92515", "0x99cc2dafecf549c4babf0015b70339ca43cdd95c69bec9fe2a344ba8143183e9", "0x80b01513f4beb4efcbb8b2352b61059152abf3f211cf7f800b985b86222c9daa", "0x81d14dd0bdebcc69b79a5fcf8e614751ebd3990e27cd866438337772ca0a7bdc"]	15503089	2022-09-09 13:53:14
\.


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alembic_version (version_num) FROM stdin;
b54caacad6b6
\.


--
-- Data for Name: claim_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.claim_status (id, claim_id, status, tx_hash, "timestamp") FROM stdin;
\.


--
-- Data for Name: claims; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.claims (id, protocol_id, initiator, receiver, exploit_started_at, amount, resources_link, "timestamp") FROM stdin;
\.


--
-- Data for Name: fundraise_positions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fundraise_positions (id, stake, contribution, reward, claimable_at, claimed_at) FROM stdin;
0xCA1Af846C9194e82561dd9a93fFC9A9c851b3B1c	1260000000000	140000000000	140000000000000000000000	2022-09-10 16:00:00	\N
0x5584cF54ADE7C81aB6d6Bc870C714F87FC0a7721	4500000000	500000000	500000000000000000000	2022-09-10 16:00:00	\N
0x5a756d9C7cAA740E0342f755fa8Ad32e6F83726b	90900000	10100000	10100000000000000000	2022-09-10 16:00:00	\N
0x82bbF2B4Dc52d24Cbe0CbB6540bd4d4CeB2870B7	1800000000	200000000	200000000000000000000	2022-09-10 16:00:00	\N
0xc4676e5E99b823E54B3e6c32c8143BB441633eEA	468000000	52000000	52000000000000000000	2022-09-10 16:00:00	\N
0x236884bb674067C96fcBCc5dff728141E05BE99d	994500000	110500000	110500000000000000000	2022-09-10 16:00:00	\N
0xE400820f3D60d77a3EC8018d44366ed0d334f93C	90000000	10000000	10000000000000000000	2022-09-10 16:00:00	\N
0x543298794e7E195c8628f65D16fB7fcf7D096Cb0	9002700000	1000300000	1000300000000000000000	2022-09-10 16:00:00	\N
0x7D51910845011B41Cc32806644dA478FEfF2f11F	91269000000	10141000000	10141000000000000000000	2022-09-10 16:00:00	\N
0x6A04941De896E4215Eeb8e6eb1b72AD2904D2402	1125000000000	125000000000	125000000000000000000000	2022-09-10 16:00:00	\N
0xbBf6507bCAB4128Ab99AA89b3eE750880fF5D56B	18000000000	2000000000	2000000000000000000000	2022-09-10 16:00:00	\N
0xdd4A19DC351Ba42421dB282196AF38b433AA86BA	904500000	100500000	100500000000000000000	2022-09-10 16:00:00	\N
0xF977bF5f5CCB1BFd868BD95D563294494F0D5d89	903600000	100400000	100400000000000000000	2022-09-10 16:00:00	\N
0xE1d1c5F48f708aa038AA6A9976308Cd1d19D951a	904500000	100500000	100500000000000000000	2022-09-10 16:00:00	\N
0xfB28bB6CFCf19cb8784472226CCd13F2e5224000	4500000000	500000000	500000000000000000000	2022-09-10 16:00:00	\N
0xeEEC0e4927704ab3BBE5df7F4EfFa818b43665a3	3746700000	416300000	416300000000000000000	2022-09-10 16:00:00	\N
0x9497243478392B1F7f508874F606379F989C6eea	992700000	110300000	110300000000000000000	2022-09-10 16:00:00	\N
0x05ac3D28434804ec02eD9472490fC42D7e9E646d	904500000	100500000	100500000000000000000	2022-09-10 16:00:00	\N
0x61D9e931A72c9FB3eB9731dCc5A30f1F6C3ab63F	903600000	100400000	100400000000000000000	2022-09-10 16:00:00	\N
0x03894d4ac41Dd6C4c2f524eD4417C90fA46972c6	1800000000	200000000	200000000000000000000	2022-09-10 16:00:00	\N
0xaB7b49bacd43BD4CfA41433D477F690Bb9E1fB26	1350000000	150000000	150000000000000000000	2022-09-10 16:00:00	\N
0xD43Ca531907f8C8dBb3272Cc2EF321cC572E56E3	1606500000	178500000	178500000000000000000	2022-09-10 16:00:00	\N
0x8B600c7Ef1D97225860a7996b63c5b8b116182d5	9000000000	1000000000	1000000000000000000000	2022-09-10 16:00:00	\N
0x40dB5C12aA263660A6188A8e16fCdf9c5235E5bF	89964000000	9996000000	9996000000000000000000	2022-09-10 16:00:00	\N
0x01ebce016681D076667BDb823EBE1f76830DA6Fa	4500000000	500000000	500000000000000000000	2022-09-10 16:00:00	\N
0xb98CC80fD75333dC20A9D122d98B5638AaF4FfC3	912933900000	101437100000	101437100000000000000000	2022-09-10 16:00:00	\N
0xC2Ac36c669fBf04DD2E1a2ED9Ce5ccC442977305	202500000	22500000	22500000000000000000	2022-09-10 16:00:00	\N
0x4953b5F3980f0FE8584F84C9A1AD93013EBE29c6	867600000	96400000	96400000000000000000	2022-09-10 16:00:00	\N
0xB26d1fE1328172b38708d7f334dd385b6d6fB4AA	4500000000	500000000	500000000000000000000	2022-09-10 16:00:00	\N
0x605D50F68E737eBF7F6054D6f7860010FC80971F	4427100000	491900000	491900000000000000000	2022-09-10 16:00:00	\N
0x153e2BD0CCdB0F78aa60d5EBc86EFB27Afd5eA3A	91286100000	10142900000	10142900000000000000000	2022-09-10 16:00:00	\N
0x49eb81cc817cD5a1E8Df590F43D5A0A0F432251A	267300000	29700000	29700000000000000000	2022-09-10 16:00:00	\N
0x641f2f8cD5Fb6CB50a49c22247B065CD893a1FC7	343800000	38200000	38200000000000000000	2022-09-10 16:00:00	\N
0x5a641C6fd5a473395355816EBC757b067CCaabE5	94500000	10500000	10500000000000000000	2022-09-10 16:00:00	\N
0xcd5561b1be55C1Fa4BbA4749919A03219497B6eF	383400000	42600000	42600000000000000000	2022-09-10 16:00:00	\N
0xd8742073F4F44d0046916a9B62A955A36e0c0e5f	901800000	100200000	100200000000000000000	2022-09-10 16:00:00	\N
0x111CE8D46cd445F5aB1ce3545d97b45071DfECC0	13500000000	1500000000	1500000000000000000000	2022-09-10 16:00:00	\N
0x046f601CbcBfa162228897AC75C9B61dAF5cEe5F	463500000	51500000	51500000000000000000	2022-09-10 16:00:00	\N
0x9cBddD3a8320583bFa7fA78c02a7F7226805f7ab	3610800000	401200000	401200000000000000000	2022-09-10 16:00:00	\N
0xC134041A85EdBb3BD9CAE36A32486454c1c6e134	108000000	12000000	12000000000000000000	2022-09-10 16:00:00	\N
0x520cc7572527711B8C50bceFe1d881F8ddb5Fe8C	1800000	200000	200000000000000000	2022-09-10 16:00:00	\N
0x19fde20744903805bA05e1522980Ffff3545C1EC	90900000	10100000	10100000000000000000	2022-09-10 16:00:00	\N
0xCfaF3E19Dca4b4cb0fB1399abB7Ec074AbE39114	9000000	1000000	1000000000000000000	2022-09-10 16:00:00	\N
0xc0555149B5A5D96AC016d3425b7986504190c3a0	90900000	10100000	10100000000000000000	2022-09-10 16:00:00	\N
0xA4Bd35E96887170a2D484e894078A5cB1AB93A45	118800000	13200000	13200000000000000000	2022-09-10 16:00:00	\N
0x1efb3038DE631CfcE0C0A231952c6B90d5D9cFE5	900000000	100000000	100000000000000000000	2022-09-10 16:00:00	\N
0x276651CF20Ef719Dd3faE29e75f63E1603507517	657900000	73100000	73100000000000000000	2022-09-10 16:00:00	\N
0x8e1fD9D5Eac794555594B9B9F700Bc37Da6Aeab1	1980000000	220000000	220000000000000000000	2022-09-10 16:00:00	\N
0x9b818ad72E4B3cd03bCBE4848a44b274618C4CBE	1800000000	200000000	200000000000000000000	2022-09-10 16:00:00	\N
0xcb630c28658d8B4f0509D628D8d947e6F95eA20A	270000000	30000000	30000000000000000000	2022-09-10 16:00:00	\N
0xc2a622b764878FaF9ab9078aD31303B24Fd4b707	569700000	63300000	63300000000000000000	2022-09-10 16:00:00	\N
0x644Be8a25BE30A21E2DFFeAE4FC43937fBCf3efd	454500000	50500000	50500000000000000000	2022-09-10 16:00:00	\N
0x9c27c3aa042a608F67d19bDA36b099a062185A65	900000000	100000000	100000000000000000000	2022-09-10 16:00:00	\N
0xEE15f56C09Dd300dc039dE1901BCcca32a23a253	1482126300000	164680700000	164680700000000000000000	2022-09-10 16:00:00	\N
0x88888882bb6125AF160999e91bCA82b56E0b819B	2250000000	250000000	250000000000000000000	2022-09-10 16:00:00	\N
0x0Aa3Dceb1e65b8f7d3a58Bed68054b1c81585002	920700000	102300000	102300000000000000000	2022-09-10 16:00:00	\N
0x987f05B5eEB8B30b02329D3888bebc3a7424e999	7200000000	800000000	800000000000000000000	2022-09-10 16:00:00	\N
0x7a86C44e1B41c6C37fF783E8f6B2f6c68AB251f4	539100000	59900000	59900000000000000000	2022-09-10 16:00:00	\N
0xDe3258C1C45a557F4924d1E4e3d0A4E5341607Ee	225000000000	25000000000	25000000000000000000000	2022-09-10 16:00:00	\N
0x1A918A8386F75f382E2A1b2e10b807c39728caf2	45000000	5000000	5000000000000000000	2022-09-10 16:00:00	\N
0x60C42Ecb80C2069eb7aC1Ee18A84244c8617E8Ab	330300000	36700000	36700000000000000000	2022-09-10 16:00:00	\N
0x78b8A76BEa31733777556033e2a116df66C4C41C	1809000000	201000000	201000000000000000000	2022-09-10 16:00:00	\N
0xdD32231c664f6e3456e81ec6c27C6f429C7dc3b3	88200000	9800000	9800000000000000000	2022-09-10 16:00:00	\N
0x7Ba080516dBAbe9fafc1f7F548F60d27e6932c48	90000000	10000000	10000000000000000000	2022-09-10 16:00:00	\N
0x040528e6eBdcBC6e37e3C78350dE0a59AedCe622	233100000	25900000	25900000000000000000	2022-09-10 16:00:00	\N
0x72770a19522ACD2025b74dc130502F81a73F875C	2337300000	259700000	259700000000000000000	2022-09-10 16:00:00	\N
0x6f9BB7e454f5B3eb2310343f0E99269dC2BB8A1d	21482100000	2386900000	2386900000000000000000	2022-09-10 16:00:00	\N
0x8fa1F8787bF4c3fC37b4DD48f472AeF08c279e42	2574900000	286100000	286100000000000000000	2022-09-10 16:00:00	\N
0xC887b3406424838aE65456860278a5e6e40fCb08	90900000	10100000	10100000000000000000	2022-09-10 16:00:00	\N
0x18Bd2e8B69E48C5E6DeAE13682b1F78d1c260bF9	1019700000	113300000	113300000000000000000	2022-09-10 16:00:00	\N
0x70F9E695823A748D0f492c86bE093c220a8d487a	13500000	1500000	1500000000000000000	2022-09-10 16:00:00	\N
0x3524ff8D740a4f1be13F2cDd2F2345e54DC0c6B0	1836900000	204100000	204100000000000000000	2022-09-10 16:00:00	\N
0x60eE0C8Bb493b79286A54997322904f74fba3736	9000000	1000000	1000000000000000000	2022-09-10 16:00:00	\N
0xabc42ca4eab3C98543C1C15ca89280888ba6109d	93600000	10400000	10400000000000000000	2022-09-10 16:00:00	\N
0xc88d7DC8Dfa23d3769f7e8241f761D09A10D9831	900000000	100000000	100000000000000000000	2022-09-10 16:00:00	\N
0x7df953D6BE5Fd9532a7E829cDFB72d2A9AB27000	900000000	100000000	100000000000000000000	2022-09-10 16:00:00	\N
0x8DC4310F20d59BA458b76A62141697717f93FA41	3222000000	358000000	358000000000000000000	2022-09-10 16:00:00	\N
0x89768Ca7E116D7971519af950DbBdf6e80b9Ded1	1337400000	148600000	148600000000000000000	2022-09-10 16:00:00	\N
0xe45c950EFB371C331fFEF421B5C8787c74830479	108000000	12000000	12000000000000000000	2022-09-10 16:00:00	\N
0xfC0591893B0BDb4322D25BDd43904Aa9aB137140	92700000	10300000	10300000000000000000	2022-09-10 16:00:00	\N
0x2d220B4783A291AbB2db3618BC4d94C632E16206	900000000	100000000	100000000000000000000	2022-09-10 16:00:00	\N
0x09D1E14bc93217B9F2d083509E94dEe161ffd9AC	94500000	10500000	10500000000000000000	2022-09-10 16:00:00	\N
0xde0634a1F956Df8580f18C955B3e9EE957e552C6	5040900000	560100000	560100000000000000000	2022-09-10 16:00:00	\N
\.


--
-- Data for Name: indexer_state; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.indexer_state (id, last_block, last_time, balance_factor, apy, apy_50ms_factor, premiums_apy, additional_apy, incentives_apy) FROM stdin;
1	15503317	2022-09-09 06:47:47	1.0000000000000000000000000000000000000000000000000000000000000000000000	0.0819151353051580239	0.0000000000000000000000000000000000000000000000000000000000000000000000	0.0304524912677735723	0.0125260755523752907	0.0482703573157260632
\.


--
-- Data for Name: interval_functions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.interval_functions (name, block_last_run) FROM stdin;
calc_tvl	15498526
calc_tvc	15498526
calc_apy	15498526
calc_additional_apy	15498526
index_apy	15498526
index_strategy_balances	15498526
reset_balance_factor	15499339
log_maple_apy	15503103
\.


--
-- Data for Name: protocols; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.protocols (id, bytes_identifier, agent, coverage_ended_at, tvl) FROM stdin;
4	0x69f4668c272ce31fadcd9c3baa18d332f7b51237a757c2a883b7c95c84d204e3	0x2d697A19192f0e4B9887f3679FA50B9BB89D886c	\N	2750000000000
6	0x7141e52f1187d2baa72e449b5470b3cd2b2cfe77ccade306ff9bcadf941a7a8d	0xd8a0852FE7732d51e81D9bB398fb84543BAD3240	\N	250000000000
3	0x3019e52a670390f24e4b9b58af62a7367658e457bbb07f86b19b213ec74b5be7	0xE130bA997B941f159ADc597F0d89a328554D4B3E	\N	242014222838880
2	0x99b8883ea932491b57118762f4b507ebcac598bee27b98f443c06d889237d9a4	0x609FFF64429e2A275a879e5C50e415cec842c629	\N	99651897322480
1	0x615307f589ff909e3b7cfbf4d4b4371eb99fa64353970d40b76c1c37381e5cf0	0xaB40A7e3cEF4AfB323cE23B6565012Ac7c76BFef	\N	1784473678380
7	0x47a46b3628edc31155b950156914c27d25890563476422202887ed4298fc3c98	0x666B8EbFbF4D5f0CE56962a25635CfF563F13161	\N	\N
5	0x9c832ff12f1059a111aeb390ae646e686435ffa13c2bdc61d499758b85c1a716	0x246d38588b16Dd877c558b245e6D5a711C649fCF	\N	17050745910000
\.


--
-- Data for Name: protocols_coverages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.protocols_coverages (id, protocol_id, coverage_amount, coverage_amount_set_at, claimable_until) FROM stdin;
1	1	10000000000000	2022-04-12 22:00:25	\N
2	2	10000000000000	2022-04-12 22:00:36	\N
3	3	10000000000000	2022-04-12 22:01:16	\N
4	4	10000000000000	2022-06-02 22:15:00	\N
5	5	10000000000000	2022-06-26 17:40:52	\N
6	6	1000000000000	2022-08-25 15:03:18	\N
7	7	1	2022-09-01 14:52:39	\N
\.


--
-- Data for Name: protocols_premiums; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.protocols_premiums (id, protocol_id, premium, premium_set_at) FROM stdin;
1	3	5391	2022-04-12 22:31:06
2	2	4756	2022-04-12 22:31:06
3	1	3907	2022-04-12 22:31:06
4	1	3551	2022-04-26 20:05:51
5	1	1826	2022-05-23 20:35:11
6	4	396	2022-06-02 22:23:15
7	1	996	2022-06-25 00:01:21
8	5	6342	2022-06-26 17:47:18
9	5	2061	2022-07-04 16:54:43
10	1	1177	2022-07-20 16:33:05
11	5	2638	2022-07-20 16:33:05
12	5	6342	2022-08-08 17:17:20
13	4	2180	2022-08-11 18:44:57
14	6	159	2022-08-25 15:40:27
\.


--
-- Data for Name: staking_positions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.staking_positions (id, owner, lockup_end, usdc, sher, restake_count) FROM stdin;
352	0xC10898edA672fDFc4Ac0228bB1Da9b2bF54C768f	2023-01-25 09:48:53	104530474	20290740174676751559	0
196	0x4f9484348aF66460Fc3D5F79f091b6fF4F0aAE5F	2022-10-06 20:21:56	431546106	84999999994902720000	0
173	0x9859F916C7B46AEae52BEe615F93f2f4641bbE6E	2022-10-06 16:23:24	1065164300	209799999987418713600	0
267	0x655839d9642FaC2EE207CEfF33D08a525aBFcD8B	2022-10-07 16:19:46	1060045301	208799999987478681600	0
48	0x276651CF20Ef719Dd3faE29e75f63E1603507517	2022-09-06 20:42:31	668991374	0	0
227	0xAA0445568a566FCD905B49Ed6D91A47eDd15519c	2022-10-06 23:46:57	1140290893	224599999986531187200	0
228	0xF7B10D603907658F690Da534E9b7dbC4dAB3E2D6	2022-10-07 00:58:47	20538397367	4045399999757405452800	0
358	0xAEc9bb8E36FDdCBc644b3A77216327834cEB9e15	2023-08-06 00:38:50	54229894	21044783979173666394	0
239	0xd84B9909a087872efb9b08bae8171625a3cCB653	2022-10-07 03:01:02	8190149044	1613199999903259622400	0
240	0x74a2E6A985B33454D39A0b333F51c3315CafC125	2022-10-07 03:09:27	1861212456	366599999978015731200	0
253	0xF4dcC8993D097093303e3E50D7a27E36fB1A6eb5	2022-10-07 09:35:20	50769010064	9999999999400320000000	0
354	0x716722C80757FFF31DA3F3C392A1736b7cfa3A3e	2023-01-26 06:26:31	100503355	19507399979192846904	0
356	0xa5A5de531F63b636443e484C06f60640c2F98D3a	2023-02-01 10:38:20	30136352	5848128830053699410	0
232	0x84dcCfB3F3e044229fa00e216E2829725579D97f	2022-10-07 01:40:49	1925186931	379199999977260134400	0
344	0xc062Eeca3891539F75054b1060997aa3459b7390	2023-01-13 09:29:41	122732393	23997828664560364877	0
212	0xF07CdaB23124D5cF2897EC460d691C610103A96A	2022-10-06 21:56:20	1127094049	221999999986687104000	0
342	0xDA6c2d0f44352D9f4B8Ebb00606657310eA4e26B	2023-01-13 09:21:37	10060028	1967061296686305934	0
118	0xc5614f397051E6Db3bFAbf9813C6C9b57f232783	2022-09-28 15:23:43	1015942756773	0	0
221	0xB7f9f538aA1b41aE2853eB63f1939187fFE70EB4	2022-10-06 23:01:49	30461948273	5999999999640192000000	0
241	0xABdb1F94bFf885Bd8933AC4f8AAaCDA4326491dE	2022-10-07 04:26:54	10249337975	2018799999878936601600	0
242	0xA4b6ED45DCC760aBD5679f7c36066Fd3FCEd0EC0	2022-10-07 04:32:53	152909455046	30118399998193859788800	0
229	0xe5Ec967f039833b8606B5588c27e85c33043716c	2022-10-07 01:23:32	10649457013	2097599999874211123200	0
247	0xa7A6A13D550180a397817A1BB5e896E5dcAE4606	2022-10-07 06:41:40	102147749461	20119999998793443840000	0
248	0xCD36B622085C508404DDAACA943Eb69aD8113Ff7	2022-10-07 07:01:06	1523076940	299999999982009600000	0
249	0x301481D22A64E7DEA6C44c68Ad3030a4132C81C3	2022-10-07 07:15:59	1015384194	199999999988006400000	0
250	0x4C4b46Abe88F996d1B3B4A8Fa41876535675ef1E	2022-10-07 07:23:58	3046151925	599999999964019200000	0
251	0x1b1D046A1001fd6fd4d11f204c7464989d621D92	2022-10-07 08:27:21	203076430345	39999999997601280000000	0
44	0xCfaF3E19Dca4b4cb0fB1399abB7Ec074AbE39114	2022-09-06 09:43:33	9151718	0	0
217	0xd6B01c20918a7Ba5D05E81DC59DEd322962b4D37	2022-10-06 22:47:21	2030797332	399999999976012800000	0
218	0xf93F775EEB76e69Aa76b6785c2DCF16303fE277d	2022-10-06 22:53:58	1066168395	209999999987406720000	0
346	0xF55F8884203632EB007F239758D1B25cd173458B	2023-01-13 09:38:56	61366176	11998673633540823539	0
364	0x34E040AE65E8CBfde0B8e2F8bBDa396f8f05e46C	2023-08-27 09:31:13	10021705	3883271920294594616	0
372	0xAe4281d74056F3975941b66daf324bB893279cF0	2023-03-07 18:23:21	1000579	45454545444672000	0
365	0x54Cfc009D17C9d6161604a9535ddb0E2EC8AE218	2023-02-26 13:02:05	1002156	194159501599436643	0
236	0xb0Ba26deDC9C1ddAe319de606C3B1279e26be57e	2022-10-07 02:25:12	5112502180	1006999999939612224000	0
237	0xC32b7438b3dF7844c9eE799930a2224Fe6E26426	2022-10-07 02:36:43	553388833	108999999993463488000	0
238	0xBD121117185485b4fa3368690240B826fBd76fBB	2022-10-07 02:57:12	1015391761	199999999988006400000	0
362	0xc84BE49850d6b36f33219eD88ee5042E21fcf7e9	2023-02-16 07:22:27	8482880381	1644640713890212158996	0
252	0xd48d664965286ddea41e97784d079de981d099B6	2022-10-07 08:46:42	10153816034	1999999999880064000000	0
348	0xd37f7B32a541D9E423f759dFf1dd63181651bd04	2023-07-15 05:14:21	100594384866	39203008085054407344347	0
123	0xAe4281d74056F3975941b66daf324bB893279cF0	2022-09-28 16:03:22	10159403	1999999999880064000	0
99	0x677f0fB523eCfe8343560ddCAAC47e1Eab34409a	2022-09-18 07:08:18	101657505	0	0
171	0xAC5348A948CE281e0507d4FC87e08c28612D8e8D	2022-10-06 16:18:38	3350851091	659999999960421120000	0
355	0x5701068cA0bA0338a5B64e8F59d5ae661e9eCfc0	2023-07-27 10:47:13	260300045	101045125397647859253	0
76	0xabc42ca4eab3C98543C1C15ca89280888ba6109d	2022-09-10 12:28:57	95177970	0	0
172	0xA337321a3b9909aEC6e7053Ef8e8FDb24e4614F2	2022-10-06 16:20:14	5077046740019	999999999940032000000000	0
54	0xEE15f56C09Dd300dc039dE1901BCcca32a23a253	2022-09-08 00:43:54	91517288490	0	0
353	0x3524ff8D740a4f1be13F2cDd2F2345e54DC0c6B0	2023-07-26 12:36:59	735727161	285619485788231650675	0
174	0xb38Bfe8F08a059e172a34A2E916379C673c36420	2022-10-06 16:24:31	4570356892	900199999946016806400	0
136	0x6A04941De896E4215Eeb8e6eb1b72AD2904D2402	2022-09-28 17:20:07	761953919832	149999999991004800000000	0
35	0x5a641C6fd5a473395355816EBC757b067CCaabE5	2022-09-06 02:33:47	96093158	0	0
156	0x66b1e927C3d35cbF4de05A29DcD76aE4D8947081	2022-10-06 16:00:40	1003225305	197599999988150323200	0
211	0x22a8ac0570DdC4b99D295B1D71fF0BdE265903f3	2022-10-06 21:49:32	1063124038	209399999987442700800	0
175	0x8D470921050899284b451d6a65f4204Eee4aaf8f	2022-10-06 16:25:51	1693702499	333599999979994675200	0
261	0xF78a149be085ff02bC5De35578D52055a47A619E	2022-10-07 13:16:41	50768701465	9999999999400320000000	0
357	0xaB93BF0635CCf8E6E1e136922f1C793C3f4f6014	2023-02-04 04:51:39	8034584	1559019075716215410	0
366	0xAe4281d74056F3975941b66daf324bB893279cF0	2023-03-02 14:51:04	1001755	45454545444672000	0
367	0x3f60008Dfd0EfC03F476D9B489D6C5B13B3eBF2C	2023-03-02 23:26:18	15025097780	681818181670080000000	0
368	0x3f60008Dfd0EfC03F476D9B489D6C5B13B3eBF2C	2023-03-03 05:04:52	15024286384	681818181670080000000	0
369	0x0999033A70B936bd10582437040550eaB875Ca95	2023-03-04 16:56:57	152194167	6909090907590144000	0
370	0xe1a360141718499010C4089fCC0915B94FD4B9DA	2023-09-02 19:00:51	48060369	4363636362688512000	0
371	0xC8A44E444e7dAc7744bf2FA35256F7300e9c04FB	2023-03-05 14:05:17	100107671	4545454544467200000	0
373	0xE400820f3D60d77a3EC8018d44366ed0d334f93C	2023-03-07 18:27:00	100057783	4545454544467200000	0
374	0x8e0a98aA62FC5FdA99043a5ac3aDAa2f0023C05C	2023-03-08 14:23:21	1500566582617	68181818167008000000000	0
375	0xf7c7cA163DDFe69218377Ab7086bdFc9a50F4E1E	2023-03-10 06:47:47	9999999999	454545454446720000000	0
213	0x9282fe119c18b600053399DD608f374AFD0D218E	2022-10-06 22:08:23	1106785689	217999999986926976000	0
338	0x71eEAEB679B69D0773adB1923566c8390B10917a	2023-01-01 10:34:37	101696614	19893111598706823216	0
328	0xd88f8e62C6a0A193d9f920c04b3a7c778eF32381	2022-12-19 09:23:52	100799071	19726170142438394362	0
231	0x4Cf8BE01027aD66c4939181a5b8c5B2b281771f0	2022-10-07 01:39:29	1005240058	197999999988126336000	0
233	0xFF92318eeC032755D443aE6c877ab09fD27FC2F5	2022-10-07 01:48:47	10153937275	1999999999880064000000	0
234	0xc7b6C16b6032aC35ed5a512622272215aE860156	2022-10-07 02:04:40	5173428723	1018999999938892608000	0
181	0xCc2939843EB9b1739187d79a3AA164f59d6F56dE	2022-10-06 16:45:03	304622579	59999999996401920000	0
182	0x9935eabEf41C6F9932579F2Eb86bdb77ffd63327	2022-10-06 16:50:22	1523112676	299999999982009600000	0
68	0x6f9BB7e454f5B3eb2310343f0E99269dC2BB8A1d	2022-09-09 22:25:02	21844261591	0	0
359	0x37b3805388479f7b47940B8c190c9E32efD82Fb5	2023-02-05 04:52:56	107454041	20849404327308089587	0
235	0xBD251F2d6E8132d44d076f12e0520F2Bc74b0013	2022-10-07 02:10:32	1015393100	199999999988006400000	0
258	0x8EDF3624a4Bee9CC5e4BC46b4daf872255Bf25Ac	2022-10-07 12:37:48	304612538	59999999996401920000	0
244	0xF930b0A0500D8F53b2E7EFa4F7bCB5cc0c71067E	2022-10-07 06:01:48	76153974800	14999999999100480000000	0
363	0x081fa64b6667f0ABBce89bBB08D64ddc6096E759	2023-08-21 06:58:51	1002780	388659771878026184	0
334	0x42492200015c883f24cF5e631208D1081d128666	2022-12-21 07:19:27	105823801	20708047913930979782	0
360	0x3f60008Dfd0EfC03F476D9B489D6C5B13B3eBF2C	2023-02-07 01:18:35	1004090420	194805454743597906489	0
192	0x644Be8a25BE30A21E2DFFeAE4FC43937fBCf3efd	2022-10-06 18:52:49	4569322580	899999999946028800000	0
361	0x341d2d099d0ad1986CE5E549a1a15631163877D6	2023-02-16 02:59:37	108345292	21012048336453069485	0
283	0x634ed8C2dF8fBe613eE25DEBE1a460B4DF2487d7	2022-10-17 23:20:31	24341094	4791319654278114142	0
206	0x3eDC48974ecC602F5648BffBDBB90E766b19556d	2022-10-06 21:06:03	20309043419	4000199999760116006400	0
207	0x1B87b6EF6dE51D272bd30493D0761d9a8De6B3D0	2022-10-06 21:20:35	1321036713	260199999984396326400	0
219	0x9b19dA8bbd711F15767bE282d2c2A5ff8CeE2d2C	2022-10-06 22:56:16	2046027827	402999999975832896000	0
220	0x13BE6e4686fF8af227befB921bbFdfc997E0573f	2022-10-06 22:56:44	4061593646	799999999952025600000	0
120	0x710dC8C61B177687F1e3c085F694896CdC438209	2022-09-28 16:00:53	12207550217	2403199999855884902400	0
144	0xF616959CfC26d7D734C28f4437d5b4D25aF13b2e	2022-09-28 22:47:46	3439935013	677199999959389670400	0
145	0xbDA0020B6e44dB02CA73e65819aD33EEa4A2111c	2022-09-28 22:49:48	1026088054	201999999987886464000	0
166	0x9D32F1e7C5fF707e92b4B30937A1e5E2C2De2462	2022-10-06 16:07:26	1116950907	219999999986807040000	0
167	0x16A3b440C18Cc022a735f298659c008f9622f799	2022-10-06 16:09:31	2741606531	539999999967617280000	0
321	0x4Ab3D7F4c46E511Ca09eeCDAC483e43ED96bd7Aa	2023-06-08 12:18:42	102905668	40297389923649206120	0
322	0x91831208EF824bbB986996312F2F0D92Cca7bb90	2023-06-15 08:40:37	50415481	19738321571329665665	0
266	0x67aD62E37e5e76f40105fc441F502ba79ca24265	2022-10-07 16:19:04	1559606911	307199999981577830400	0
315	0xBeDd3062A3BDE463B22D01Bb985401729D556A8D	2022-11-27 07:35:44	20195889	3956617835830729541	0
69	0x8fa1F8787bF4c3fC37b4DD48f472AeF08c279e42	2022-09-10 03:27:46	2618309615	0	0
299	0x82Eb60d17E1B39c97B175777EA1319Cd77CfAEDa	2022-11-03 01:47:14	506133250	99371072577840915519	0
121	0xD9F0834E7Ca9B9262Df3189b850eBf9514027e82	2022-09-28 16:01:32	30468077665	5997999999640311936000	0
95	0x446Ccd4633512f321B400cF89c1877F8307F6C26	2023-03-18 11:36:25	24398719	0	0
96	0x4D5dAADc1Bf9Aa1c023FE1A9f75545B3863dfD14	2022-09-18 06:40:23	103690751	0	0
61	0x1A918A8386F75f382E2A1b2e10b807c39728caf2	2022-09-08 22:20:51	45758644	0	0
62	0x60C42Ecb80C2069eb7aC1Ee18A84244c8617E8Ab	2022-09-09 05:28:04	335868449	0	0
63	0x78b8A76BEa31733777556033e2a116df66C4C41C	2022-09-09 05:44:19	1839497499	0	0
64	0xdD32231c664f6e3456e81ec6c27C6f429C7dc3b3	2022-09-09 05:50:28	89686941	0	0
320	0xf2f7ad044dfBAa417249C8568788d7Aa1E6F155b	2022-12-07 14:46:09	514566268	100755671945839083864	0
307	0xEFfdc0Cfcf0131c39208c14033142b6c2D1a863F	2023-05-08 10:02:02	1112974030	436533514093909958225	0
310	0x886cf30e5f7C6f69Ef1Be1173a53a6DD04E76966	2022-11-13 16:51:40	1011068	198185295068888557	0
311	0x9E03EB454D58688334fA14e0D46252Fa2513A92C	2022-11-14 11:04:52	1033221849	202513379488835544324	0
312	0xAC0ea85F1C2f0B07E2862BA1CC4DA36150A4Faab	2022-11-15 08:39:33	6065242	1188711205176875366	0
330	0xc385E224391C6776f4bCBa5C65Aca3ae9CB540db	2023-06-20 01:50:22	9071441	3550438087035327328	0
226	0x4ae1AC36EdA71d31b01Dae5c706d1d741509b124	2022-10-06 23:39:46	1030628214	202999999987826496000	0
255	0xd819c62dDE216Ef3b508d348542B59477efd606f	2022-10-07 09:55:05	2030761	399999999976012800	0
21	0xaB7b49bacd43BD4CfA41433D477F690Bb9E1fB26	2022-09-05 16:10:30	1372759329	0	0
256	0xc1129C95D9f16a17F80EFcBDe4F1B536c484C1D6	2022-10-07 12:05:21	20307520175	3999999999760128000000	0
257	0x821E3f3BB33cF667B98339beBE8a3E3c693b6eb4	2022-10-07 12:15:31	101537572871	19999999998800640000000	0
154	0x746c7757501193aF295797d4F338121Cf22A4aCd	2022-10-06 16:00:14	30457230182	5998999999640251968000	0
53	0x644Be8a25BE30A21E2DFFeAE4FC43937fBCf3efd	2022-09-07 23:04:05	462162290	0	0
127	0x643430283B19fA5BD70A1138B495c2B43523CDd5	2022-09-28 16:06:49	101594104541	19999999998800640000000	0
297	0x9cC30a6b421C4E6bE8547b8d694A46Adf45E8F87	2022-11-01 04:44:10	3948639218	775472425470116469586	0
93	0x76FeB15406Fd0637b95C871BFA8C71FbB1854dD0	2022-09-17 07:22:41	101662134	0	0
83	0x2d220B4783A291AbB2db3618BC4d94C632E16206	2022-09-10 14:48:29	915172887	0	0
116	0x6715fD4994379fF0b1bC3d0bD3d599f83e9Ec4Be	2022-09-27 08:29:44	121923705	0	0
183	0xD01A2311cA001241502394d25Bc08b0aD8Cd2229	2022-10-06 16:52:03	4550045062	896199999946256678400	0
25	0x01ebce016681D076667BDb823EBE1f76830DA6Fa	2022-09-05 16:26:25	4575864428	0	0
326	0x364F4B2eEe8920b6E476Dfd4e531B6fd6bfC14Cf	2023-06-18 10:13:05	504034019	197286514549275788961	0
289	0x1cD7dA537C779D127376851fc7680CAd5d2A32E7	2022-10-22 14:21:50	172313156	33877571713901096446	0
290	0x9E2E00AaB67c3A7B827eb3e431c4A6c2077510a6	2022-10-22 23:04:43	202711970	39852994585682095620	0
291	0x8C228d8c83Ba1c37DC7d328a943f3D41500D1ef3	2022-10-23 01:37:21	5169085413	1016052759473733348116	0
292	0xf67336E671f1588d71c8f1e50a79c2715717E07a	2023-04-23 09:58:33	3064828007	1204519914180354869782	0
22	0xD43Ca531907f8C8dBb3272Cc2EF321cC572E56E3	2022-09-05 16:11:00	1633583619	0	0
115	0xC134041A85EdBb3BD9CAE36A32486454c1c6e134	2022-09-27 04:51:43	1510854051	0	0
3	0x5a756d9C7cAA740E0342f755fa8Ad32e6F83726b	2022-09-05 16:01:29	92432459	0	0
112	0x13711b99539d2860AA740c0180A50627d538c28e	2022-09-23 13:10:46	101628980	0	0
4	0x82bbF2B4Dc52d24Cbe0CbB6540bd4d4CeB2870B7	2022-09-05 16:02:01	1830345769	0	0
74	0x60eE0C8Bb493b79286A54997322904f74fba3736	2022-09-10 11:29:10	9151718	0	0
11	0xbBf6507bCAB4128Ab99AA89b3eE750880fF5D56B	2022-09-05 16:03:51	18303457698	0	0
208	0x0e2e091221b1D79CCe17F240515443dc139C7d90	2022-10-06 21:23:50	10154009185	1999999999880064000000	0
209	0x0d9686D3c602a458110F43147bcF33bFc3feF135	2022-10-06 21:45:30	1116940368	219999999986807040000	0
343	0x40276bA5EfDFBBf749557f6B2A094ABd78197164	2023-01-13 09:28:38	122732399	23998028676874752882	0
65	0x7Ba080516dBAbe9fafc1f7F548F60d27e6932c48	2022-09-09 13:37:49	91517287	0	0
347	0xF06F09C65635ea3dB2F6255cABeFcc11d28f2ef2	2023-01-13 09:41:35	122732327	23997194493569042907	0
8	0xFdBcf42e241806c8a80e47af135Ff2FebCB8B558	2022-09-05 16:03:36	9154474374	0	0
337	0xAC0ea85F1C2f0B07E2862BA1CC4DA36150A4Faab	2022-12-25 08:02:11	5037820	985703206398289350	0
34	0x641f2f8cD5Fb6CB50a49c22247B065CD893a1FC7	2022-09-06 02:17:29	349596039	0	0
16	0xeEEC0e4927704ab3BBE5df7F4EfFa818b43665a3	2022-09-05 16:06:47	3809864722	0	0
59	0x7a86C44e1B41c6C37fF783E8f6B2f6c68AB251f4	2022-09-08 10:42:36	548188570	0	0
100	0xc92c4df3DD076d3ef60f2c6C533eE16616F4d8A5	2023-03-19 07:32:28	2033140	0	0
42	0x520cc7572527711B8C50bceFe1d881F8ddb5Fe8C	2022-09-06 07:57:35	1830331	0	0
43	0x19fde20744903805bA05e1522980Ffff3545C1EC	2022-09-06 08:36:53	92432459	0	0
339	0xB2b8DE16675ef164e51910BDf15e62F2f80f7f4c	2023-01-02 15:59:34	10067852	1969307842918037880	0
286	0x977C827A997E6cB67e70dAEaA7145B17D0CB8bDA	2022-10-18 04:30:59	10254415486	2017488300963283554893	0
287	0x481787bBa8C56f801Db8bdb336844b771c011246	2022-10-18 05:42:37	1022291035	201053830743399203877	0
277	0x43630db375F1A1943155E3bB9c3Ab8fE24091C58	2022-10-15 02:39:05	1014729200	199820310309670508963	0
278	0x7EE85eC0744FaB13ae27D21695338d08E55f0039	2022-10-15 18:47:26	59863834	11787617212248440170	0
24	0x40dB5C12aA263660A6188A8e16fCdf9c5235E5bF	2022-09-05 16:21:56	91480681566	0	0
70	0xC887b3406424838aE65456860278a5e6e40fCb08	2022-09-10 03:33:14	92432459	0	0
317	0x10fa00823D930bD4aB3592CdeD68D830da652D22	2022-11-27 09:57:01	10097873	1978273302606300239	0
162	0xFD9cE48c96617BF6Ccc7C37044b1a22638B71E02	2022-10-06 16:01:40	101541017608	19999999998800640000000	0
163	0x9F9EBCE72C0715CdbAD4d589986EB22F6782A1CE	2022-10-06 16:02:55	3046230359	599999999964019200000	0
168	0x4c6BB92f83e0E978270E8325181adeE3F1d0DF7f	2022-10-06 16:11:32	2999520362	590799999964570905600	0
169	0xEf47003F0E276eb0Fb60B626E80554DD7AdCdd11	2022-10-06 16:12:49	53578091633	10552999999367157696000	0
10	0x6A04941De896E4215Eeb8e6eb1b72AD2904D2402	2022-09-05 16:03:47	1143966106111	0	0
230	0x1750F9f65bE225fA3c3914Dc77C13d739da8FBEE	2022-10-07 01:35:10	203078816	39999999997601280000	0
122	0xCd52e48D1f34a6498aF641A5afa66376f85775c7	2022-09-28 16:03:01	1015941176829	199999999988006400000000	0
91	0x1040a43093b700D9bfe90346990afAa4D1151508	2022-09-14 10:22:42	519567966	0	0
12	0xdd4A19DC351Ba42421dB282196AF38b433AA86BA	2022-09-05 16:04:21	919748751	0	0
13	0xF977bF5f5CCB1BFd868BD95D563294494F0D5d89	2022-09-05 16:04:31	918833576	0	0
158	0xb38Bfe8F08a059e172a34A2E916379C673c36420	2022-10-06 16:00:50	507705106	99999999994003200000	0
159	0x4A2Ff57467dB1290cF32Cf106C96987d5f4ECA1a	2022-10-06 16:00:50	10154102136	1999999999880064000000	0
170	0x317379256FdDcB3EC5A5EB00b044fD9575038b7F	2022-10-06 16:17:37	4061637848	799999999952025600000	0
58	0x987f05B5eEB8B30b02329D3888bebc3a7424e999	2022-09-08 06:19:33	7321383075	0	0
323	0x15D67FC9dEec198977688C7A25a8dB2CA2b477ac	2022-12-16 04:44:29	10082426	1973649962631377492	0
298	0x30bF85E1d0bC7FDEDcbEeFf39225D8037cb0cb7c	2023-05-02 12:14:00	1012437453	397594768909437036896	0
57	0x0Aa3Dceb1e65b8f7d3a58Bed68054b1c81585002	2022-09-08 05:55:41	936221860	0	0
306	0x5d0e6a02FfdA33516b170015B400eAB91f130C9D	2023-05-07 05:15:58	102203975	40090075855391131664	0
300	0xEEdA7f71Df5A589a9B8c5794AA3D28D66a4ee672	2022-11-03 13:08:19	1555774082	305424754017602221683	0
301	0xE7765e5BB4562245C274194101C1aD1dA417A033	2023-05-05 17:51:48	417990155	164098864878720065937	0
204	0xf436f85a9C26FC71AfFF2E9DD36C0eee66b8e1DE	2022-10-06 21:02:50	10154014877	1999999999880064000000	0
303	0xceC771B3AB9204c4EB0B731111658e7C8bA539cF	2023-05-06 17:48:36	10119732125	3971101756317327636529	0
304	0x13AE5042d3ABe5371b6b24b73e57EC718222A4dA	2022-11-05 22:45:10	106254811	20840581432566432012	0
305	0xceC771B3AB9204c4EB0B731111658e7C8bA539cF	2022-11-06 02:42:37	505966147	99236421459215656944	0
200	0x8aa4243Ef5fE3D6ebe375fA6D47A710266Cb0CaF	2022-10-06 20:34:33	151294938	29799999998212953600	0
296	0x2aeE3234eAED102777688544dAa54441fB3B47F5	2023-04-30 06:06:44	54685140	21483641559535668982	0
314	0x5050DcEb1D3C031543548711208701D910A5334a	2022-11-26 21:38:50	60589637	11870407214072955420	0
295	0x9A608d9F416518b5F11acf3dC5594C90D6998e2c	2023-04-27 08:51:42	1013017	398022703151251374	0
259	0x95f35CA431cf7C5c7eB7cc66071c35f2d516491D	2022-10-07 12:44:50	5279949616	1039999999937633280000	0
340	0xeFD52a9E454FEB9Ad8edCA588c7a9703d67cdFF7	2023-01-12 04:51:29	1117764217	218574227927026540698	0
341	0x184F44a581a3FDf67e834Cf2A0F193CbDd08A3b9	2023-01-13 09:19:02	10060029	1967062944412972502	0
262	0x14730014EeA880F2D52aC0b67442c485242D9B9c	2022-10-07 13:58:08	101536272731	19999799998800651993600	0
263	0xCDb2De3C7E3523F943904bdaaB94E316853601Ee	2022-10-07 14:04:45	2538431750	499999999970016000000	0
264	0xDeb263240eaDf03BfFdC6036cE652fE4cec96d2C	2022-10-07 14:19:50	662022736	130399999992180172800	0
319	0x94DdEe5FF016BE756882Ab37714013E9B199CcC6	2023-06-04 13:49:27	3045781083	1193020036451596494449	0
327	0x6B820D74B6D0b9ed0A8eBbfFAECdC32a854e952e	2022-12-18 12:45:16	12096716	2367370475327153527	0
329	0xb6943C2E791Fba7abC45f208b8e78860069C228C	2022-12-19 11:50:04	20159658	3945176343048215665	0
282	0xBF8641831D15c2701BA122981C3D7A6A2533ea48	2022-10-17 10:49:50	521340079	102625147319467588498	0
260	0xDaC71EAAd0AEE5c4EB45F9284900D7A2B9561327	2022-10-07 13:16:03	101537404659	19999999998800640000000	0
178	0xCd52e48D1f34a6498aF641A5afa66376f85775c7	2022-10-06 16:32:53	71074565975	13999199999160495974400	0
179	0x09635F1A9e74772789978b012F132Ec97983963E	2022-10-06 16:40:17	2538521871	499999999970016000000	0
180	0x63eebA70536D2D0778C66aBFa854e2023E9aC24e	2022-10-06 16:44:21	1025562716	201999999987886464000	0
19	0x61D9e931A72c9FB3eB9731dCc5A30f1F6C3ab63F	2022-09-05 16:07:40	918833576	0	0
7	0xE400820f3D60d77a3EC8018d44366ed0d334f93C	2022-09-05 16:03:36	91517287	0	0
84	0x09D1E14bc93217B9F2d083509E94dEe161ffd9AC	2022-09-10 15:18:33	96093158	0	0
86	0xb42f5A41B62b52616598cfD1A0D3A01846Bfa888	2022-09-11 02:03:20	101685879	0	0
87	0x65aaeEc60C6149Bf18753F5D2c361ecbBA22651A	2022-09-12 08:36:52	10168578	0	0
40	0x9cBddD3a8320583bFa7fA78c02a7F7226805f7ab	2022-09-06 06:59:17	3671673605	0	0
41	0xC134041A85EdBb3BD9CAE36A32486454c1c6e134	2022-09-06 07:52:15	109820742	0	0
88	0x5D9a5eBAe5828cd8d15166666d45D53f0b871Bb4	2022-09-12 10:40:24	1016851	0	0
67	0x72770a19522ACD2025b74dc130502F81a73F875C	2022-09-09 19:06:49	2376703996	0	0
288	0x9fA10388D2BB8b7d8a2c8586772876D6302D4cB3	2023-04-22 06:37:21	1520472748	597905884142704779937	0
188	0x11d67Fa925877813B744aBC0917900c2b1D6Eb81	2022-10-06 17:36:43	304622132811	59999999996401920000000	0
189	0x864B81C40D8314D5c4289a14eb92f03b9f43B6bc	2022-10-06 17:44:18	203081379783	39999999997601280000000	0
190	0x11e2463446Ae4dF20128044aAE992f0D07d4a6aD	2022-10-06 17:50:01	499580108	98399999994099148800	0
119	0xB8c9D38Ba6924095062A92A581326a3eCecF62D9	2022-09-28 15:47:54	20319851608	0	0
214	0x391891Af67E29D97E61E30C3036a0874F5Da411e	2022-10-06 22:15:59	50769975538	9999999999400320000000	0
215	0xE49464e503b3A5E97765E5e54666DCe2A828652D	2022-10-06 22:35:24	1122015883	220999999986747072000	0
216	0x471eb1312a93c397089FCC569e32ac887fe1856E	2022-10-06 22:46:53	1115923141	219799999986819033600	0
316	0xD2Dc3aDde00FAf9f89b40A71071837410E321727	2022-11-27 08:36:52	101988936	19980750544665847684	0
225	0x6d3C4171d6807378CF6482732873E675d28A8c72	2022-10-06 23:18:54	10164132143	2001999999879944064000	0
161	0x5F13fBd61Bc5DC77758D72F4fBf17ba591F1962f	2022-10-06 16:01:40	20304141881	3999199999760175974400	0
92	0x1c721671916560c9Ab5B7c5406E152b750eB03a2	2023-03-15 23:31:36	519553398	0	0
135	0x5811b5D57cb3f803151768FeA0d22046B1eBd65C	2022-09-28 16:37:21	25033777731	4928199999704465702400	0
137	0x6E93Ebc8302890fF1D1BeFd779D1DB131eF30D4d	2022-09-28 17:20:39	253984635818	49999999997001600000000	0
332	0x61D656C068b93202eCF787A2872c58B39a277b9B	2022-12-20 11:46:12	105830144	20709904983679668417	0
101	0xfC0591893B0BDb4322D25BDd43904Aa9aB137140	2022-09-18 07:56:00	104707069	0	0
102	0xAAa017530E01e7BF6D69F29756870F4dd09b74d6	2022-09-18 08:38:51	2033134	0	0
9	0x7D51910845011B41Cc32806644dA478FEfF2f11F	2022-09-05 16:03:47	92807682269	0	0
98	0xdF6C74e0387570344C4C36FF77C79fd805c5b5F7	2022-09-18 07:02:55	101657522	0	0
149	0xE188e4f2Ce31B507D7faE2397aD66C5FE4504Ff7	2022-09-29 00:16:57	2034900164	400599999975976819200	0
150	0x046f601CbcBfa162228897AC75C9B61dAF5cEe5F	2022-09-29 00:22:35	609555609	119999999992803840000	0
151	0x18Bd2e8B69E48C5E6DeAE13682b1F78d1c260bF9	2022-09-29 01:41:07	6095542251	1199999999928038400000	0
152	0xda4807e777e2E4a6B2ab075BDC0aEf459E708cBE	2022-09-29 06:10:41	30477473241	5999999999640192000000	0
254	0x48aa9d67cb713804C005516BCa7769c159d7897C	2022-10-07 09:53:17	10153792	1999999999880064000	0
72	0x70F9E695823A748D0f492c86bE093c220a8d487a	2022-09-10 09:28:50	13727595	0	0
138	0x1b50Adc3c74b4f3a2A4307Fe714c853634139e45	2022-09-28 17:42:35	81275030801	15999999999040512000000	0
139	0xCF2e0814DDF1587e06a66B479de3D0B7b151E5B8	2022-09-28 17:44:40	1031176883	202999999987826496000	0
140	0x5C44368C0Ad4C446842738BDbf8f2Bbf9876546e	2022-09-28 18:27:38	30478096340	5999999999640192000000	0
141	0x825aE6fb177186e9551ab1CDd6D4aB10B22A0Dba	2022-09-28 18:49:24	18286846164	3599999999784115200000	0
142	0xA1ed36FE9e4a32737472Ea0dd632825E73cB2943	2022-09-28 18:58:22	507967816	99999999994003200000	0
143	0x308Bff328370FC4a9683aB9fCd79A21be6dC5eE4	2022-09-28 20:01:00	30763490606	6056199999636821798400	0
313	0x62d51Fa08B15411D9429133aE5F224abf3867729	2023-05-22 08:32:12	1010264	395914877717031109	0
55	0xEE15f56C09Dd300dc039dE1901BCcca32a23a253	2022-09-08 00:48:01	19957175093	0	0
335	0x694dA39965A6a817cE47B7D3EFA622B992b382f6	2022-12-21 11:20:51	105822500	20707553314911409442	0
23	0x8B600c7Ef1D97225860a7996b63c5b8b116182d5	2022-09-05 16:20:24	9151728844	0	0
336	0x98E073b579FD483EaC8f10d5bd0B32C8C3BBD7e0	2022-12-22 11:39:04	100775959	19719371751977468714	0
165	0xB9Df1Ac065Aba19Fb4a23328784665B9b19dEe31	2022-10-06 16:03:20	10154101011	1999999999880064000000	0
318	0xda90f94194F093dB4f27e10a4d0289cEE9602459	2022-12-04 08:32:55	100922326	19767637621982574307	0
325	0xC93505A56396456B49e20Ddb46A01B780aA87990	2022-12-18 06:14:26	100808062	19729387916296868065	0
113	0x3255d4B48d108cFD7A6D71d0722Ff845F9213a13	2022-09-24 12:30:22	106703670	0	0
33	0x49eb81cc817cD5a1E8Df590F43D5A0A0F432251A	2022-09-06 01:36:56	271806330	0	0
81	0xe45c950EFB371C331fFEF421B5C8787c74830479	2022-09-10 13:38:48	109820742	0	0
82	0xfC0591893B0BDb4322D25BDd43904Aa9aB137140	2022-09-10 13:59:11	94262801	0	0
106	0x6058f8E21D7D736b574e80c2B57e73fDf360bae0	2023-03-20 13:20:36	67089935	0	0
77	0xc88d7DC8Dfa23d3769f7e8241f761D09A10D9831	2022-09-10 12:31:58	915172887	0	0
78	0x7df953D6BE5Fd9532a7E829cDFB72d2A9AB27000	2022-09-10 12:33:48	915172887	0	0
128	0xDeb263240eaDf03BfFdC6036cE652fE4cec96d2C	2022-09-28 16:08:47	578070421	113799999993175641600	0
134	0x874d561AFa3E120BF9bd2AAd7A435cf0D4656989	2022-09-28 16:30:15	1015940245	199999999988006400000	0
331	0xFA08CD18766A40600f59725792ec42eFb5ce391A	2022-12-20 08:05:25	10079171	1972410479078651821	0
184	0x3A1b938670eb674A710e767F3ef2B2e0e976984a	2022-10-06 16:55:30	3999693311	787799999952757209600	0
185	0xdD98b9e40F29b6E8126Db8a0EC683303B7C6626A	2022-10-06 16:58:08	1136241799	223799999986579161600	0
153	0x31c039383d787457b75D185D820D4A37aB80DAD2	2022-09-29 06:22:53	1523873124960	299999999982009600000000	0
186	0xd3AEcF9e0856822bd320873E905Ae9F78a2977e7	2022-10-06 16:58:32	3224936487	635199999961908326400	0
164	0x10216D6b520a9E033769393C65c2EfD94303684b	2022-10-06 16:03:20	5505553570	1084399999934970700800	0
210	0x2f75fFe98046E4a55Fa79daf97B2730d7e707186	2022-10-06 21:46:59	2033846788	400599999975976819200	0
187	0xD4E26683635bf3dc9EAD5F31B935c33cC1Ce1838	2022-10-06 17:31:46	507703624593	99999999994003200000000	0
111	0x9a4a43a48F6BD53fEF42B1565F14d24E1f9f41E8	2023-03-23 08:39:06	106717953	0	0
125	0x6A356bE9b82E09bcFF191BaA639Cf6012C63aDDd	2022-09-28 16:03:56	4188725329	824599999950550387200	0
37	0xd8742073F4F44d0046916a9B62A955A36e0c0e5f	2022-09-06 03:03:28	917003228	0	0
20	0x03894d4ac41Dd6C4c2f524eD4417C90fA46972c6	2022-09-05 16:09:55	1830345769	0	0
124	0xfdA5BB18E3F47eA9B3d5689c3cD896D4DDD41Eca	2022-09-28 16:03:35	2364095077	465399999972090892800	0
160	0x2a03278590cd1962De28F9AbC855CF3774fe3eb6	2022-10-06 16:01:09	1023533488	201599999987910451200	0
268	0x96A8e25128f088005226BE0B7155E133DfA62f73	2022-10-07 16:21:10	1017399771	200399999987982412800	0
269	0x357dfdC34F93388059D2eb09996d80F233037cBa	2022-10-07 17:34:56	50768352149	9999999999400320000000	0
270	0xBEFE9091541d2FD2Bb2B931536Fbee0383C4c4E0	2022-10-07 17:40:10	50768345135	9999999999400320000000	0
271	0xa9d0af4df087C15F67862f1F03582b6755715978	2022-10-07 17:42:16	203073369313	39999999997601280000000	0
302	0x0c43D79BaEBA1Acb896B4E35F02615eb25c3e4AA	2023-05-05 20:15:14	1017132139	399295667986875837380	0
130	0x87A427C0A3508705F7f7D0C8b90E270f4f3d8268	2022-09-28 16:13:26	1092136370	214999999987106880000	0
131	0xF6c719DC30FD8a3b8f23D075DDc4e4B00fA2736D	2022-09-28 16:14:08	507970404	99999999994003200000	0
117	0x643430283B19fA5BD70A1138B495c2B43523CDd5	2022-09-28 15:03:56	101594369669	0	0
308	0xf3EAB2365c8689D7d429e9Cf03C78b29F07907b1	2022-11-13 02:55:47	2022283885	396461037418171691173	0
309	0x578dCF77ba084ecCDc34723FC32153Fbc36aBE23	2022-11-13 09:48:08	1019196649	199787008582943972668	0
191	0xC134041A85EdBb3BD9CAE36A32486454c1c6e134	2022-10-06 18:22:49	2713164420	534399999967953100800	0
324	0x32a59b87352e980dD6aB1bAF462696D28e63525D	2023-06-16 20:36:12	2043603206	800006441412166067051	0
114	0xDf839BbBE062AE73493a6961fC34849b53F1c154	2022-09-25 02:48:43	508093094	0	0
284	0xB400486a30ae70B7293D4587Ada484d88418D751	2023-04-18 01:58:46	202839580	79853218543766028856	0
285	0x59070F02Fa3693Bb7af1A41e80cC0aE3f1509E4b	2023-04-18 02:06:26	2028394444	798472786273077183949	0
6	0x236884bb674067C96fcBCc5dff728141E05BE99d	2022-09-05 16:02:40	1011266035	0	0
197	0x1A2A24E8aC0bd22c4F9B4FdF34BFcD30820246BC	2022-10-06 20:29:30	325944152	64199999996150054400	0
198	0xCC3529c09DbeEC382804ef0E8eCd18797665Eed1	2022-10-06 20:31:41	1108819347	218399999986902988800	0
199	0xf596f9420234Ad8Ad4486518113680fbF4054420	2022-10-06 20:34:23	1015402260	199999999988006400000	0
146	0xeabdfF58088179bCA0d8255EA2fBe036e3e5eF3b	2022-09-28 22:56:20	1027103791	202199999987874470400	0
147	0xE6cC5e3EBB07B5156ba3aF510B8c6cA19804d88E	2022-09-28 23:01:57	5079642036	999999999940032000000	0
293	0x5C466e3ba27381c722B78Ab836fF62Df14E0BCC9	2023-04-25 13:54:20	147932084	58127908870266238893	0
294	0xBF861d09615543c419c749Ea8cBEB720E3B3E3ad	2023-04-26 09:40:35	2026264	796165095538068904	0
36	0xcd5561b1be55C1Fa4BbA4749919A03219497B6eF	2022-09-06 02:53:31	389863643	0	0
132	0x06aA5e77Cf3BEC21129DDbF29b531ed742A4109C	2022-09-28 16:20:06	10315860783	2030799999878216985600	0
133	0x70aF29f754988473fcAbA6E01AbfbafF871046d1	2022-09-28 16:22:57	5079702496	999999999940032000000	0
66	0x040528e6eBdcBC6e37e3C78350dE0a59AedCe622	2022-09-09 15:31:30	237029775	0	0
224	0x5D2cA9c220F66A5f181E53bAC510Fe1e1a0bA268	2022-10-06 23:18:42	11159222071	2197999999868190336000	0
148	0x96Dc89dbE84970ee42A2F0B35fB50599e6745FF8	2022-09-28 23:32:30	20318550089	3999999999760128000000	0
85	0xde0634a1F956Df8580f18C955B3e9EE957e552C6	2022-09-10 15:56:15	5125883327	0	0
279	0x10216D6b520a9E033769393C65c2EfD94303684b	2022-10-16 05:31:32	924285097	181988946241012086871	0
280	0x8e5e01DCa1706F9Df683c53a6Fc9D4bb8D237153	2022-10-16 21:41:41	456458140	89864246546075020862	0
281	0xe5aedd6520c4D4e0cb4Ee78784a0187D34d55ADC	2023-04-17 04:05:04	1016345500	400157813233952296254	0
39	0x046f601CbcBfa162228897AC75C9B61dAF5cEe5F	2022-09-06 05:13:45	471314044	0	0
14	0xE1d1c5F48f708aa038AA6A9976308Cd1d19D951a	2022-09-05 16:04:31	919748751	0	0
5	0xc4676e5E99b823E54B3e6c32c8143BB441633eEA	2022-09-05 16:02:40	475889904	0	0
97	0x9B2b78003e469A342977e0a078F6Aef88077acD9	2022-09-18 06:58:24	102674124	0	0
333	0x0B7487924EaEfBB690a6355565B928713d37223a	2022-12-20 13:00:59	10079018	1972353963954121877	0
205	0xbDA0020B6e44dB02CA73e65819aD33EEa4A2111c	2022-10-06 21:04:33	2030802877	399999999976012800000	0
222	0x40c0771F1AD6A3bF551CBBe0436716a394847a44	2022-10-06 23:10:50	1158569161	228199999986315302400	0
223	0x8fA942761E522662bB233f6f520e3C0Ae39708A6	2022-10-06 23:12:13	3553892981	699999999958022400000	0
243	0xDf839BbBE062AE73493a6961fC34849b53F1c154	2022-10-07 05:45:16	507693396	99999999994003200000	0
193	0xB193Da6F9F2252BE679fd5b020C22DEd01f4eC8D	2022-10-06 19:13:53	203080888205	39999999997601280000000	0
194	0xBE3026ecA9dd524401Ceb3B703d7972497332325	2022-10-06 19:36:22	2030807664	399999999976012800000	0
195	0x33ce1310E0E95bDb74fe3bA755231B0fe1849105	2022-10-06 20:11:11	2030805776	399999999976012800000	0
157	0x193F0Ee42a199A0CECD479a9F09BA293eB1CA357	2022-10-06 16:00:40	53407531422	10519399999369172620800	0
126	0xc29d294B9C254D20BA7E20923f31A8fE91D4fAeB	2022-09-28 16:05:07	30478233125	5999999999640192000000	0
245	0x1ccb144B700EC726d37Db38c617E154De6d9c0d0	2022-10-07 06:37:28	406154119	79999999995202560000	0
38	0x111CE8D46cd445F5aB1ce3545d97b45071DfECC0	2022-09-06 04:47:29	13727593268	0	0
272	0xf7476Db5B717aC661C027e684456115ab1e728C3	2022-10-07 17:53:03	37717821634	7429399999554473740800	0
273	0x8114E78965B7F7e52E35b2CfbE33973a4eF320Cb	2022-10-07 18:14:10	6568402660	1293799999922413401600	0
274	0x942BFCc165f1A54f107A42897454246c670AcdE7	2022-10-07 20:23:10	456913140330	89999999994602880000000	0
275	0x942BFCc165f1A54f107A42897454246c670AcdE7	2022-10-07 21:57:14	284607455792	56060399996598285505703	0
276	0x57b18F9302306c4D655802F2Be3575147bf7BEe3	2022-10-12 09:30:01	548143411	107958363061297152883	0
345	0xdC09eb652D4568c3E22D176BCe8F5eFb12aF7716	2023-01-13 09:34:43	197176591	38553461150293679374	0
176	0x07E39E8e9d519e3AE3F7b030ab5E03493cD4b945	2022-10-06 16:30:20	50760297961	9997999999400439936000	0
177	0xeE160154b02A2e404c6c13ff0B28Ed76010cf07d	2022-10-06 16:30:43	508155356335	100088799993997874841600	0
109	0x8c302250f1F5f4A933b7a62B52E998b0a40C3917	2022-09-21 10:49:12	508206305	0	0
89	0xAe4281d74056F3975941b66daf324bB893279cF0	2022-09-12 17:42:03	10168545	0	0
90	0x7A247fF3d9BE7A89B5F71206Ec1cA3F8684bB5c3	2023-03-15 08:01:30	1016763	0	0
129	0x5eBC7a6f0EcBC069065Fce49B0ED28b5E6dBdaf8	2022-09-28 16:13:26	1015940813	199999999988006400000	0
45	0xc0555149B5A5D96AC016d3425b7986504190c3a0	2022-09-06 10:00:44	92432459	0	0
46	0xA4Bd35E96887170a2D484e894078A5cB1AB93A45	2022-09-06 12:25:05	120802823	0	0
110	0xaFbe2Fe7325418ac50337ACe4cD86ee0bfA245C7	2022-09-21 12:19:15	559025041	0	0
71	0x18Bd2e8B69E48C5E6DeAE13682b1F78d1c260bF9	2022-09-10 06:59:51	1036890881	0	0
201	0xDAcCce559a0571083556f39d05b177579613D83b	2022-10-06 20:34:33	112709648	22199999998668710400	0
202	0xba181DeB98AfC2202202C9AeBf26B18f46D70497	2022-10-06 20:42:13	10154020463	1999999999880064000000	0
203	0xB52E056572E091DFA12BeB038D898b27292Aa4EC	2022-10-06 20:50:21	153325689	30199999998188966400	0
60	0xDe3258C1C45a557F4924d1E4e3d0A4E5341607Ee	2022-09-08 16:03:55	228793221225	0	0
17	0x9497243478392B1F7f508874F606379F989C6eea	2022-09-05 16:07:24	1009435685	0	0
103	0x37d8fa18BD09eD448e93ecD47641019d91eb43a4	2023-03-19 08:46:10	66077175	0	0
104	0xbAA3A36ade58A3593972B7728A97916ed82ee371	2022-09-18 08:56:58	113855996	0	0
75	0x9c27c3aa042a608F67d19bDA36b099a062185A65	2022-09-10 12:26:54	915172887	0	0
265	0x17d2B1B51fb36eF6f8e397feEE9e0C98Ad8EAB60	2022-10-07 14:31:45	20307443	3999999999760128000	0
94	0x843aa999827ae6d187F8a5b6ab4afB1B1597551D	2022-09-17 10:20:50	2033221	0	0
107	0x25aD2667B19e866109c1a93102b816730a6Aec3f	2023-03-21 12:43:22	10164627	0	0
108	0x4C1F58d3dED593b018ca2ec4228399Df39CFdd6f	2022-09-20 13:15:21	206341702	0	0
30	0xEE15f56C09Dd300dc039dE1901BCcca32a23a253	2022-09-05 19:31:36	1395638649449	0	0
32	0x153e2BD0CCdB0F78aa60d5EBc86EFB27Afd5eA3A	2022-09-06 00:29:02	92825070546	0	0
18	0x05ac3D28434804ec02eD9472490fC42D7e9E646d	2022-09-05 16:07:24	919748751	0	0
349	0xe5214a481f2c2bbD501c14DFA66254a8a907cf39	2023-01-16 01:08:38	1206973056	234365406146697575323	0
350	0xae52ed1bAcBf48Cd32Db52C134eCD24c1d21bc22	2023-01-22 10:07:13	30159925	5855001172301287289	0
155	0xCDb2De3C7E3523F943904bdaaB94E316853601Ee	2022-10-06 16:00:40	8871639102	1747399999895211916800	0
105	0x014607F2d6477bADD9d74bF2c5D6356e29a9b957	2022-09-19 06:55:06	111817956	0	0
73	0x3524ff8D740a4f1be13F2cDd2F2345e54DC0c6B0	2022-09-10 11:13:35	1867867852	0	0
27	0xC2Ac36c669fBf04DD2E1a2ED9Ce5ccC442977305	2022-09-05 16:57:21	205913899	0	0
351	0xe1912dF4cff0DfbF051A65936C2BD23096a7Ca5C	2023-01-24 13:14:37	30155009	5853661556564567623	0
79	0x8DC4310F20d59BA458b76A62141697717f93FA41	2022-09-10 13:03:30	3276318938	0	0
80	0x89768Ca7E116D7971519af950DbBdf6e80b9Ded1	2022-09-10 13:19:22	1359946912	0	0
56	0x88888882bb6125AF160999e91bCA82b56E0b819B	2022-09-08 05:23:40	2287932225	0	0
26	0xb98CC80fD75333dC20A9D122d98B5638AaF4FfC3	2022-09-05 16:29:59	928324834416	0	0
51	0xcb630c28658d8B4f0509D628D8d947e6F95eA20A	2022-09-07 12:06:07	274551861	0	0
52	0xc2a622b764878FaF9ab9078aD31303B24Fd4b707	2022-09-07 15:16:24	579304441	0	0
28	0x4953b5F3980f0FE8584F84C9A1AD93013EBE29c6	2022-09-05 16:59:35	882226664	0	0
29	0xB26d1fE1328172b38708d7f334dd385b6d6fB4AA	2022-09-05 17:28:09	4575864428	0	0
31	0x605D50F68E737eBF7F6054D6f7860010FC80971F	2023-03-08 09:14:39	4501735420	204536531137389574660	1
246	0xbbACa87124B71a3A3cD29846c7A3CE0C493864e2	2022-10-07 06:40:35	507692599	99999999994003200000	0
\.


--
-- Data for Name: staking_positions_meta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.staking_positions_meta (id, usdc_last_updated, usdc_last_updated_block) FROM stdin;
1	2022-09-09 06:47:47	15501336
\.


--
-- Data for Name: stats_apy; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stats_apy (id, "timestamp", value, block, premiums_apy, incentives_apy) FROM stdin;
1	2022-03-03 05:29:07	0	14312126	0	0
2	2022-03-04 11:16:33	0	14320126	0	0
3	2022-03-05 17:07:12	0	14328126	0	0
4	2022-03-06 22:59:53	0	14336126	0	0
5	2022-03-08 04:42:30	0	14344126	0	0
6	2022-03-09 10:52:28	0	14352126	0	0
7	2022-03-10 16:22:04	0	14360126	0	0
8	2022-03-11 22:22:08	0	14368126	0	0
9	2022-03-13 04:03:10	0	14376126	0	0
10	2022-03-14 10:19:24	0	14384126	0	0
11	2022-03-15 16:00:06	0.0187038540245634301	14392126	0	0
12	2022-03-16 21:56:21	0.0187368805614213825	14400126	0	0
13	2022-03-18 04:02:37	0.018260369173467645	14408126	0	0
14	2022-03-19 09:42:20	0.0175396892942916056	14416126	0	0
15	2022-03-20 15:42:34	0.0174264859799631647	14424126	0	0
16	2022-03-21 21:29:34	0.0176055619137522289	14432126	0	0
17	2022-03-23 03:20:07	0.019351210625864125	14440126	0	0
18	2022-03-24 09:23:56	0.0201907683696825116	14448126	0	0
19	2022-03-25 15:00:00	0.0220139045457187314	14456126	0	0
20	2022-03-26 21:03:07	0.0237477284931526256	14464126	0	0
21	2022-03-28 02:54:50	0.0242921120655604679	14472126	0	0
22	2022-03-29 08:41:16	0.0255435353154276068	14480126	0	0
23	2022-03-30 14:39:43	0.0242534395661065973	14488126	0	0
24	2022-03-31 20:35:27	0.0142350462340060796	14496126	0	0
25	2022-04-02 02:30:00	0.0263744808918633077	14504126	0	0
26	2022-04-03 08:35:45	0.0263837749278478979	14512126	0	0
27	2022-04-04 14:46:30	0.0262889213908421779	14520126	0	0
28	2022-04-05 20:37:30	0.0245861407267011604	14528126	0	0
29	2022-04-07 02:43:35	0.0241228315939272207	14536126	0	0
30	2022-04-08 08:47:01	0.0174299575472645733	14544126	0	0
31	2022-04-09 14:46:50	0.0135646761546661249	14552126	0	0
32	2022-04-10 20:37:18	0.0138313511835287135	14560126	0	0
33	2022-04-12 02:40:37	0.0253250790268332339	14568126	0	0
34	2022-04-13 08:37:33	0.0342488839518250085	14576126	0.0221543423884444576	0
35	2022-04-14 14:39:05	0.0461225251984176618	14584126	0.0221502407865187129	0
36	2022-04-15 20:32:06	0.0468486518195342025	14592126	0.0221467052957281911	0
37	2022-04-17 02:22:59	0.0469976089619372137	14600126	0.0221419871551747846	0
38	2022-04-18 08:27:33	0.0986266972646794859	14608126	0.0221326783080748636	0
39	2022-04-19 14:47:21	0.0469816493924481299	14616126	0.0221137778211882262	0
40	2022-04-20 20:41:47	0.0472971981888263907	14624126	0.0221102114368836415	0
41	2022-04-22 02:53:57	0.0474128877234204216	14632126	0.0221065978195070165	0
42	2022-04-23 09:03:22	0.0468406570944863709	14640126	0.0221013782655794036	0
43	2022-04-24 15:04:46	0.0463941783525337187	14648126	0.0220885075361630136	0
44	2022-04-25 21:16:38	0.0445915191471301237	14656126	0.0220851026715572045	0
45	2022-04-27 03:30:57	0.043376697767626142	14664126	0.0215222767922890815	0
46	2022-04-28 09:38:41	0.0422101215132964086	14672126	0.0215191439453764448	0
47	2022-04-29 15:58:51	0.0420728551059835754	14680126	0.0215160106754421245	0
48	2022-04-30 21:58:04	0.0416085854346380929	14688126	0.0215129435174861022	0
49	2022-05-02 04:13:22	0.0406989470593639019	14696126	0.021509855764033789	0
50	2022-05-03 10:33:30	0.0395033813125352101	14704126	0.0215027336252336387	0
51	2022-05-04 16:57:25	0.0393449233696182635	14712126	0.0214987274457540609	0
52	2022-05-05 23:28:52	0.0395617681019781939	14720126	0.0214935854573522767	0
53	2022-05-07 06:11:48	0.0397507480234058214	14728126	0.0214890761967458481	0
54	2022-05-08 12:39:36	0.0396469796973532712	14736126	0.021474677926379436	0
55	2022-05-09 19:13:26	0.0368138699854235543	14744126	0.0214707099261110777	0
56	2022-05-11 02:08:46	0.0375411657845337657	14752126	0.0214678907002162252	0
57	2022-05-12 08:48:16	0.039171361755936919	14760126	0.0214649741550516082	0
58	2022-05-13 15:16:17	0.0462138220462056312	14768126	0.0214615385138726966	0
59	2022-05-14 21:55:07	0.0436203898723133629	14776126	0.0214582295958094978	0
60	2022-05-16 04:16:31	0.0435356396305828022	14784126	0.0214517871072831684	0
61	2022-05-17 10:56:49	0.0433169815671863787	14792126	0.0214474326822895849	0
62	2022-05-18 17:30:11	0.0386286240803836792	14800126	0.0214444973439799416	0
63	2022-05-20 00:52:34	0.0360238418317786885	14808126	0.0214417066108263665	0
64	2022-05-21 08:00:26	0.0361922983204924428	14816126	0.0214389212251858835	0
65	2022-05-22 15:22:52	0.0354372261635714156	14824126	0.0214361982843095968	0
66	2022-05-23 22:24:37	0.0312919090319467921	14832126	0.0187346118108774815	0
67	2022-05-25 05:41:08	0.0280484522290339253	14840126	0.0187327370426393046	0
68	2022-05-26 13:10:16	0.0280287439879746518	14848126	0.0187308489255055138	0
69	2022-05-27 20:11:40	0.0284752130415376649	14856126	0.0187289422040295139	0
70	2022-05-29 03:18:39	0.0288601896268535704	14864126	0.0187269763644305753	0
71	2022-05-30 10:48:44	0.0284655167332917916	14872126	0.0187249344950799652	0
72	2022-05-31 17:56:04	0.0289415554557834048	14880126	0.0187230133393090498	0
73	2022-06-02 01:21:45	0.0295878748396679672	14888126	0.0187210448032227861	0
74	2022-06-03 08:36:26	0.0301708787159775324	14896126	0.0193381619212018956	0
75	2022-06-04 16:17:53	0.0297312896017280053	14904126	0.0193360772567241455	0
76	2022-06-06 00:52:54	0.0297585661734643611	14912126	0.019330950061010245	0
77	2022-06-07 09:38:26	0.0298664077514174675	14920126	0.0193287898962676355	0
78	2022-06-08 18:08:16	0.0299447050634136999	14928126	0.019326145235519579	0
79	2022-06-10 02:59:25	0.0298148141393116822	14936126	0.0193238812342140173	0
80	2022-06-11 11:56:25	0.0300264147398128789	14944126	0.0193217023586846962	0
81	2022-06-12 20:33:08	0.0288767099074454664	14952126	0.0193196146071848707	0
82	2022-06-14 05:37:12	0.0319572824434066274	14960126	0.0193173494520326831	0
83	2022-06-15 15:06:28	0.0301768893707189574	14968126	0.0193150903862635073	0
84	2022-06-17 00:01:04	0.0290580431922274653	14976126	0.0193129144688530645	0
85	2022-06-18 09:00:25	0.0285882828459737282	14984126	0.0193088833216033956	0
86	2022-06-19 18:09:30	0.02897146874652037	14992126	0.0193061878503194041	0
87	2022-06-21 03:02:38	0.027957612979665078	15000126	0.0193040337069703763	0
88	2022-06-22 14:48:09	0.0268636122431893665	15008126	0.0193015845527425081	0
89	2022-06-24 02:43:12	0.0258558214068774841	15016126	0.0192994277923796212	0
90	2022-06-25 14:33:09	0.0248455557048057538	15024126	0.0180025325595119107	0
91	2022-06-27 02:43:39	0.0271637929824156861	15032126	0.0180025325595119003	0
92	2022-06-28 14:32:26	0.0340029912504431278	15040126	0.0278900474244407823	0
93	2022-06-30 02:23:18	0.0348327887795519542	15048126	0.0278860764010129651	0
94	2022-07-01 10:37:53	0.0354361452660822765	15056126	0.027882442522697122	0
95	2022-07-02 16:18:53	0.0347368061254385088	15064126	0.0278791434720040907	0
96	2022-07-03 21:54:04	0.0334799118763090195	15072126	0.0278758482989900636	0
97	2022-07-05 03:31:32	0.0298161940738110934	15080126	0.0211997306342000917	0
98	2022-07-06 09:32:16	0.025937480895978738	15088126	0.0211978378991523261	0
99	2022-07-07 15:05:12	0.0251650948236660128	15096126	0.021196037836875424	0
100	2022-07-08 20:30:35	0.026895219731139567	15104126	0.0211941488637277034	0
101	2022-07-10 02:14:22	0.0281674147840970078	15112126	0.0211921250186419378	0
102	2022-07-11 07:58:48	0.0281551286080772324	15120126	0.0211900994344516973	0
103	2022-07-12 13:39:41	0.0263317228140678254	15128126	0.0211881944753823971	0
104	2022-07-13 19:23:14	0.0251956382045462508	15136126	0.0211863840594990506	0
105	2022-07-15 00:43:55	0.0258991249791892669	15144126	0.0211833836268475219	0
106	2022-07-16 06:32:53	0.0261555290738591344	15152126	0.0210767420874656067	0
107	2022-07-17 12:21:40	0.0265426640302605307	15160126	0.0210748449006991981	0
108	2022-07-18 17:57:40	0.0266501012161417701	15168126	0.0210717102764218893	0
109	2022-07-19 23:47:40	0.0269188236949320162	15176126	0.0210697830213292699	0
110	2022-07-21 05:48:00	0.0270946480666035723	15184126	0.0222420531163282503	0
111	2022-07-22 11:35:22	0.0278380308238009751	15192126	0.0222399519337717552	0
112	2022-07-23 17:05:00	0.0277110352867284727	15200126	0.0222378749385312262	0
113	2022-07-24 22:54:42	0.0277447150459127732	15208126	0.0222357368135353735	0
114	2022-07-26 05:05:35	0.0280911558142168671	15216126	0.0222335968161126926	0
115	2022-07-27 10:54:31	0.0280689205173789216	15224126	0.0222313280675667316	0
116	2022-07-28 10:36:21	0.0283686688874478683	15230527	0.0222287141184264424	0
117	2022-07-29 10:49:51	0.0282962538024637486	15236928	0.0222266922438604485	0
118	2022-07-30 10:44:48	0.0285665307486706113	15243328	0.0222249589193332479	0
119	2022-07-31 10:36:06	0.0289120221866048834	15249728	0.0222232092315698508	0
120	2022-08-01 10:34:06	0.0288210106206665088	15256128	0.0222214570251444629	0
121	2022-08-02 10:24:34	0.028786016690103465	15262528	0.0222197162508408347	0
122	2022-08-03 10:23:16	0.0291005795693825842	15268928	0.0222179464661229412	0
123	2022-08-04 10:26:31	0.0291307312312082227	15275328	0.0222161366835679081	0
124	2022-08-05 10:25:33	0.0291576870275424387	15281728	0.0222143633009858864	0
125	2022-08-06 10:16:26	0.0292654203680300963	15288129	0.0222125848779822187	0
126	2022-08-07 10:09:27	0.0290733794454749138	15294529	0.0222106488840718048	0
127	2022-08-08 10:08:58	0.0291030655009878979	15300929	0.0222088786662452305	0
128	2022-08-09 09:55:10	0.0334245434153336712	15307329	0.0279343025997188139	0
129	2022-08-10 10:07:25	0.0343150035690276412	15313729	0.0279316543024322392	0
130	2022-08-11 10:16:04	0.0346212006151450924	15320129	0.0279289892518495945	0
131	2022-08-12 10:42:38	0.0355615291435198294	15326529	0.0306845159512558231	0
132	2022-08-13 10:44:37	0.036199609135727312	15332929	0.0306814688638439928	0
133	2022-08-14 10:53:19	0.0360049088645724644	15339329	0.030678424350590823	0
134	2022-08-15 11:24:06	0.0364002444679559917	15345729	0.0306752998079222773	0
135	2022-08-16 11:40:05	0.0365502296661396262	15352129	0.0306721942759611635	0
136	2022-08-17 11:44:12	0.0363816196136603487	15358529	0.0306691285707858877	0
137	2022-08-18 12:11:49	0.0364166596848655433	15364929	0.0306531474140065707	0
138	2022-08-19 12:37:30	0.0363706837331070343	15371329	0.0306500387965203923	0
139	2022-08-20 12:57:59	0.0362214118488994943	15377729	0.0306469542313966004	0
140	2022-08-21 13:04:27	0.0359719061207929708	15384129	0.0306439206136678959	0
141	2022-08-22 13:38:26	0.0363108045407967428	15390529	0.0306407989799054072	0
142	2022-08-23 13:49:31	0.0363326780155269272	15396930	0.0306377258068647185	0
143	2022-08-24 14:02:36	0.0362035198376095893	15403330	0.0306346596171512935	0
144	2022-08-25 14:57:13	0.0362468064843242191	15409730	0.0306315023414255663	0
145	2022-08-26 15:21:56	0.0368778035482498212	15416131	0.0308737396028400217	0
146	2022-08-27 16:03:06	0.0366385795494907837	15422531	0.030870552239307656	0
147	2022-08-28 16:43:23	0.0365924567663390363	15428931	0.0308673545011162904	0
148	2022-08-29 17:08:38	0.0361586992447441163	15435332	0.03086424342051668	0
149	2022-08-30 17:46:12	0.0361397179170055427	15441732	0.030861108056274511	0
150	2022-08-31 18:08:04	0.0364026380961804466	15448136	0.0308579838354727139	0
159	2022-09-01 15:42:04	0.0974119432587801787	15453708	0.0308553796959074936	0.0489089772635454487
160	2022-09-02 16:05:44	0.0985989872057575767	15460109	0.0308030172528315806	0.0488259773600244612
161	2022-09-03 16:46:41	0.0983127227022385919	15466509	0.0307957815154675969	0.0488145079657824263
162	2022-09-04 17:26:14	0.0982995327273676195	15472909	0.0307881277176150804	0.048802375902303137
163	2022-09-05 18:09:37	0.0958025205305184507	15479309	0.0307808993386320569	0.0487909181718581622
164	2022-09-06 18:38:21	0.0972450516139426457	15485709	0.032831777376450412	0.052041772587215325
165	2022-09-06 18:43:15	0.0972568506640724972	15485726	0.032831399074006451	0.0520411729386025743
166	2022-09-07 19:21:41	0.0991792519959907859	15492126	0.0304595001294492192	0.048281467088469622
167	2022-09-08 19:58:28	0.0944412108575333198	15498526	0.0304524912677735723	0.0482703573157260632
\.


--
-- Data for Name: stats_tvc; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stats_tvc (id, "timestamp", block, value) FROM stdin;
1	2022-03-03 05:29:07	14312126	0
2	2022-03-04 11:16:33	14320126	0
3	2022-03-05 17:07:12	14328126	0
4	2022-03-06 22:59:53	14336126	0
5	2022-03-08 04:42:30	14344126	0
6	2022-03-09 10:52:28	14352126	0
7	2022-03-10 16:22:04	14360126	0
8	2022-03-11 22:22:08	14368126	0
9	2022-03-13 04:03:10	14376126	0
10	2022-03-14 10:19:24	14384126	0
11	2022-03-15 16:00:06	14392126	0
12	2022-03-16 21:56:21	14400126	0
13	2022-03-18 04:02:37	14408126	0
14	2022-03-19 09:42:20	14416126	0
15	2022-03-20 15:42:34	14424126	0
16	2022-03-21 21:29:34	14432126	0
17	2022-03-23 03:20:07	14440126	0
18	2022-03-24 09:23:56	14448126	0
19	2022-03-25 15:00:00	14456126	0
20	2022-03-26 21:03:07	14464126	0
21	2022-03-28 02:54:50	14472126	0
22	2022-03-29 08:41:16	14480126	0
23	2022-03-30 14:39:43	14488126	0
24	2022-03-31 20:35:27	14496126	0
25	2022-04-02 02:30:00	14504126	0
26	2022-04-03 08:35:45	14512126	0
27	2022-04-04 14:46:30	14520126	0
28	2022-04-05 20:37:30	14528126	0
29	2022-04-07 02:43:35	14536126	0
30	2022-04-08 08:47:01	14544126	0
31	2022-04-09 14:46:50	14552126	0
32	2022-04-10 20:37:18	14560126	0
33	2022-04-12 02:40:37	14568126	0
34	2022-04-13 08:37:33	14576126	26242439707780
35	2022-04-14 14:39:05	14584126	26364586229650
36	2022-04-15 20:32:06	14592126	25853322601380
37	2022-04-17 02:22:59	14600126	25798273596900
38	2022-04-18 08:27:33	14608126	25703064579020
39	2022-04-19 14:47:21	14616126	25803613408000
40	2022-04-20 20:41:47	14624126	25841498028690
41	2022-04-22 02:53:57	14632126	25691422063200
42	2022-04-23 09:03:22	14640126	25678127896100
43	2022-04-24 15:04:46	14648126	25649824090060
44	2022-04-25 21:16:38	14656126	25633071999520
45	2022-04-27 03:30:57	14664126	25489695636910
46	2022-04-28 09:38:41	14672126	25587945366900
47	2022-04-29 15:58:51	14680126	25564892073720
48	2022-04-30 21:58:04	14688126	25437684352510
49	2022-05-02 04:13:22	14696126	24183699865350
50	2022-05-03 10:33:30	14704126	24223020286130
51	2022-05-04 16:57:25	14712126	24134924191800
52	2022-05-05 23:28:52	14720126	24308397162830
53	2022-05-07 06:11:48	14728126	24020139430270
54	2022-05-08 12:39:36	14736126	23959823321200
55	2022-05-09 19:13:26	14744126	23827697782280
56	2022-05-11 02:08:46	14752126	23619443847740
57	2022-05-12 08:48:16	14760126	22895004775440
58	2022-05-13 15:16:17	14768126	22795652301290
59	2022-05-14 21:55:07	14776126	22884593923850
60	2022-05-16 04:16:31	14784126	22962081172890
61	2022-05-17 10:56:49	14792126	22849205351000
62	2022-05-18 17:30:11	14800126	22915021709530
63	2022-05-20 00:52:34	14808126	22836065547830
64	2022-05-21 08:00:26	14816126	22791066304460
65	2022-05-22 15:22:52	14824126	22805119939810
66	2022-05-23 22:24:37	14832126	22864778292660
67	2022-05-25 05:41:08	14840126	22799754821470
68	2022-05-26 13:10:16	14848126	22652613118160
69	2022-05-27 20:11:40	14856126	22533506008700
70	2022-05-29 03:18:39	14864126	22524132045960
71	2022-05-30 10:48:44	14872126	22539741347170
72	2022-05-31 17:56:04	14880126	22694889355980
73	2022-06-02 01:21:45	14888126	22541750993760
74	2022-06-03 08:36:26	14896126	23052348929600
75	2022-06-04 16:17:53	14904126	23001635423550
76	2022-06-06 00:52:54	14912126	23032212981210
77	2022-06-07 09:38:26	14920126	23076805859660
78	2022-06-08 18:08:16	14928126	23038651986830
79	2022-06-10 02:59:25	14936126	23008015656330
80	2022-06-11 11:56:25	14944126	22919637040390
81	2022-06-12 20:33:08	14952126	22784221804570
82	2022-06-14 05:37:12	14960126	22140804461120
83	2022-06-15 15:06:28	14968126	22138304570190
84	2022-06-17 00:01:04	14976126	22056990968210
85	2022-06-18 09:00:25	14984126	22073383825540
86	2022-06-19 18:09:30	14992126	22014179234550
87	2022-06-21 03:02:38	15000126	22093300183660
88	2022-06-22 14:48:09	15008126	22089681829310
89	2022-06-24 02:43:12	15016126	22106320352200
90	2022-06-25 14:33:09	15024126	22154957051320
91	2022-06-27 02:43:39	15032126	24541881614320
92	2022-06-28 14:32:26	15040126	24532366509680
93	2022-06-30 02:23:18	15048126	24478147229350
94	2022-07-01 10:37:53	15056126	24585568247670
95	2022-07-02 16:18:53	15064126	24559463977400
96	2022-07-03 21:54:04	15072126	24558678903710
97	2022-07-05 03:31:32	15080126	25338379414200
98	2022-07-06 09:32:16	15088126	25335679515490
99	2022-07-07 15:05:12	15096126	25356902183060
100	2022-07-08 20:30:35	15104126	25389015582840
101	2022-07-10 02:14:22	15112126	25376731697830
102	2022-07-11 07:58:48	15120126	25350557640880
103	2022-07-12 13:39:41	15128126	25304198991830
104	2022-07-13 19:23:14	15136126	25270657006880
105	2022-07-15 00:43:55	15144126	25359627148630
106	2022-07-16 06:32:53	15152126	25379100601420
107	2022-07-17 12:21:40	15160126	25465251517260
108	2022-07-18 17:57:40	15168126	25455014191290
109	2022-07-19 23:47:40	15176126	25600991336780
110	2022-07-21 05:48:00	15184126	26505026738440
111	2022-07-22 11:35:22	15192126	26525169577040
112	2022-07-23 17:05:00	15200126	26554610603300
113	2022-07-24 22:54:42	15208126	26531782321960
114	2022-07-26 05:05:35	15216126	26465838068480
115	2022-07-27 10:54:31	15224126	26465838068480
116	2022-07-28 10:36:21	15230527	26566046839140
117	2022-07-29 10:49:51	15236928	26587441627410
118	2022-07-30 10:44:48	15243328	26578208575060
119	2022-07-31 10:36:06	15249728	26574040483070
120	2022-08-01 10:34:06	15256128	26565454199720
121	2022-08-02 10:24:34	15262528	26507963397090
122	2022-08-03 10:23:16	15268928	26563907105710
123	2022-08-04 10:26:31	15275328	26538030865080
124	2022-08-05 10:25:33	15281728	26563841386030
125	2022-08-06 10:16:26	15288129	26592697208030
126	2022-08-07 10:09:27	15294529	26576948706650
128	2022-08-08 18:41:29	15303213	32467245304730
129	2022-08-09 18:44:13	15309614	32419706110670
130	2022-08-10 18:45:07	15316014	32503790071510
131	2022-08-11 19:06:08	15322414	34780571360360
132	2022-08-12 19:22:48	15328816	34805214874160
133	2022-08-13 19:20:38	15335216	34840527740130
134	2022-08-14 19:31:04	15341616	34811544846380
135	2022-08-15 20:05:20	15348016	34789635533900
136	2022-08-16 20:15:54	15354416	34780647952470
137	2022-08-17 20:24:22	15360816	34757471518380
138	2022-08-18 20:55:42	15367216	34777972191430
139	2022-08-19 21:17:09	15373616	34669257882370
140	2022-08-20 21:36:18	15380016	34583464352360
141	2022-08-21 21:48:41	15386416	34634511694920
142	2022-08-22 22:07:28	15392816	34597710222560
143	2022-08-23 22:12:38	15399216	34645176793850
145	2022-08-24 22:43:38	15409964	34935604814240
146	2022-08-26 16:12:08	15416364	34868290441890
147	2022-08-27 16:54:37	15422764	34795794654580
148	2022-08-28 17:33:55	15429164	34798429811630
149	2022-08-29 18:01:49	15435564	34831326070530
150	2022-08-30 18:39:54	15441964	34796478502700
151	2022-08-31 19:10:16	15448366	34812032086810
152	2022-08-25 22:43:38	15410000	34935604814240
154	2022-09-01 15:12:34	15453573	34784810757400
155	2022-09-02 15:32:20	15459973	34791071543900
156	2022-09-03 16:15:03	15466373	34737946156830
157	2022-09-04 16:55:39	15472773	34745512479140
158	2022-09-05 17:39:45	15479173	34766310858990
160	2022-09-06 18:43:15	15485726	34762596855980
161	2022-09-07 19:21:41	15492126	34741608342910
162	2022-09-08 19:58:28	15498526	34784473678380
\.


--
-- Data for Name: stats_tvl; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stats_tvl (id, "timestamp", block, value) FROM stdin;
1	2022-03-03 05:29:07	14312126	0
2	2022-03-04 11:16:33	14320126	0
3	2022-03-05 17:07:12	14328126	0
4	2022-03-06 22:59:53	14336126	0
5	2022-03-08 04:42:30	14344126	5021903700000
6	2022-03-09 10:52:28	14352126	5045235300000
7	2022-03-10 16:22:04	14360126	5392065600000
8	2022-03-11 22:22:08	14368126	5396998500000
9	2022-03-13 04:03:10	14376126	5437714600000
10	2022-03-14 10:19:24	14384126	5437724600000
11	2022-03-15 16:00:06	14392126	5438012335742
12	2022-03-16 21:56:21	14400126	5438872344791
13	2022-03-18 04:02:37	14408126	5439725945594
14	2022-03-19 09:42:20	14416126	5440150949016
15	2022-03-20 15:42:34	14424126	5441181656591
16	2022-03-21 21:29:34	14432126	5441685131128
17	2022-03-23 03:20:07	14440126	5442256543976
18	2022-03-24 09:23:56	14448126	5443786634647
19	2022-03-25 15:00:00	14456126	5444288070031
20	2022-03-26 21:03:07	14464126	5444836381841
21	2022-03-28 02:54:50	14472126	5445784678316
22	2022-03-29 08:41:16	14480126	5447863275666
23	2022-03-30 14:39:43	14488126	5448321501522
24	2022-03-31 20:35:27	14496126	10520010059507
25	2022-04-02 02:30:00	14504126	10520957267238
26	2022-04-03 08:35:45	14512126	10521915563324
27	2022-04-04 14:46:30	14520126	10522868417822
28	2022-04-05 20:37:30	14528126	10523765852008
29	2022-04-07 02:43:35	14536126	10524636230235
30	2022-04-08 08:47:01	14544126	18493417509637
31	2022-04-09 14:46:50	14552126	20000518921035
32	2022-04-10 20:37:18	14560126	20001456377200
33	2022-04-12 02:40:37	14568126	20003192230476
34	2022-04-13 08:37:33	14576126	20005420889007
35	2022-04-14 14:39:05	14584126	20009125330581
36	2022-04-15 20:32:06	14592126	20012319578998
37	2022-04-17 02:22:59	14600126	20016583917872
38	2022-04-18 08:27:33	14608126	20025002750720
39	2022-04-19 14:47:21	14616126	20042117976574
40	2022-04-20 20:41:47	14624126	20045350776730
41	2022-04-22 02:53:57	14632126	20048627455868
42	2022-04-23 09:03:22	14640126	20053362223579
43	2022-04-24 15:04:46	14648126	20065047096296
44	2022-04-25 21:16:38	14656126	20068140528538
45	2022-04-27 03:30:57	14664126	20071302500615
46	2022-04-28 09:38:41	14672126	20074224564719
47	2022-04-29 15:58:51	14680126	20077147874492
48	2022-04-30 21:58:04	14688126	20080010327219
49	2022-05-02 04:13:22	14696126	20082892825451
50	2022-05-03 10:33:30	14704126	20089544684359
51	2022-05-04 16:57:25	14712126	20093288269735
52	2022-05-05 23:28:52	14720126	20098095259962
53	2022-05-07 06:11:48	14728126	20102312637591
54	2022-05-08 12:39:36	14736126	20115790769060
55	2022-05-09 19:13:26	14744126	20119508366822
56	2022-05-11 02:08:46	14752126	20122150519224
57	2022-05-12 08:48:16	14760126	20124884608740
58	2022-05-13 15:16:17	14768126	20128106273498
59	2022-05-14 21:55:07	14776126	20131210082884
60	2022-05-16 04:16:31	14784126	20137255970312
61	2022-05-17 10:56:49	14792126	20141344393015
62	2022-05-18 17:30:11	14800126	20144101354806
63	2022-05-20 00:52:34	14808126	20146723198884
64	2022-05-21 08:00:26	14816126	20149340699686
65	2022-05-22 15:22:52	14824126	20151900177010
66	2022-05-23 22:24:37	14832126	20154168755222
67	2022-05-25 05:41:08	14840126	20156185780036
68	2022-05-26 13:10:16	14848126	20158217574744
69	2022-05-27 20:11:40	14856126	20160269805241
70	2022-05-29 03:18:39	14864126	20162386102925
71	2022-05-30 10:48:44	14872126	20164584719867
72	2022-05-31 17:56:04	14880126	20166653794305
73	2022-06-02 01:21:45	14888126	20168774337584
74	2022-06-03 08:36:26	14896126	20170933803814
75	2022-06-04 16:17:53	14904126	20173108475989
76	2022-06-06 00:52:54	14912126	20178459039463
77	2022-06-07 09:38:26	14920126	20180714162314
78	2022-06-08 18:08:16	14928126	20183475765415
79	2022-06-10 02:59:25	14936126	20185840477500
80	2022-06-11 11:56:25	14944126	20188116800416
81	2022-06-12 20:33:08	14952126	20190298405587
82	2022-06-14 05:37:12	14960126	20192665922858
83	2022-06-15 15:06:28	14968126	20195027628626
84	2022-06-17 00:01:04	14976126	20197302930590
85	2022-06-18 09:00:25	14984126	20201519554659
86	2022-06-19 18:09:30	14992126	20204340029435
87	2022-06-21 03:02:38	15000126	20206594638257
88	2022-06-22 14:48:09	15008126	20209158628097
89	2022-06-24 02:43:12	15016126	20211417053205
90	2022-06-25 14:33:09	15024126	20213484008267
91	2022-06-27 02:43:39	15032126	20215703546700
92	2022-06-28 14:32:26	15040126	20218510475025
93	2022-06-30 02:23:18	15048126	20221389624376
94	2022-07-01 10:37:53	15056126	20224025048773
95	2022-07-02 16:18:53	15064126	20226418238647
96	2022-07-03 21:54:04	15072126	20228809181044
97	2022-07-05 03:31:32	15080126	20230898561895
98	2022-07-06 09:32:16	15088126	20232704959837
99	2022-07-07 15:05:12	15096126	20234423211580
100	2022-07-08 20:30:35	15104126	20236226647158
101	2022-07-10 02:14:22	15112126	20238159204078
102	2022-07-11 07:58:48	15120126	20240093791287
103	2022-07-12 13:39:41	15128126	20241913509823
104	2022-07-13 19:23:14	15136126	20243643218943
105	2022-07-15 00:43:55	15144126	20246510545956
106	2022-07-16 06:32:53	15152126	20348951380634
107	2022-07-17 12:21:40	15160126	20350783221459
108	2022-07-18 17:57:40	15168126	20353810600742
109	2022-07-19 23:47:40	15176126	20355672365768
110	2022-07-21 05:48:00	15184126	20357558073971
111	2022-07-22 11:35:22	15192126	20359481412027
112	2022-07-23 17:05:00	15200126	20361382967194
113	2022-07-24 22:54:42	15208126	20363340859673
114	2022-07-26 05:05:35	15216126	20365300843805
115	2022-07-27 10:54:31	15224126	20367379160788
116	2022-07-28 10:36:21	15230527	20369774229300
117	2022-07-29 10:49:51	15236928	20371627187355
118	2022-07-30 10:44:48	15243328	20373215970542
119	2022-07-31 10:36:06	15249728	20374820003799
120	2022-08-01 10:34:06	15256128	20376426599194
121	2022-08-02 10:24:34	15262528	20378022963406
122	2022-08-03 10:23:16	15268928	20379646187842
123	2022-08-04 10:26:31	15275328	20381306365247
124	2022-08-05 10:25:33	15281728	20382933414072
125	2022-08-06 10:16:26	15288129	20384565348305
126	2022-08-07 10:09:27	15294529	20386342171422
127	2022-08-08 10:08:58	15300929	20387967119123
128	2022-08-09 09:55:10	15307329	20390816272096
129	2022-08-10 10:07:25	15313729	20392749596303
130	2022-08-11 10:16:04	15320129	20394695520973
131	2022-08-12 10:42:38	15326529	20396719211547
132	2022-08-13 10:44:37	15332929	20398744883350
133	2022-08-14 10:53:19	15339329	20400769245763
134	2022-08-15 11:24:06	15345729	20402847239275
135	2022-08-16 11:40:05	15352129	20404913009126
136	2022-08-17 11:44:12	15358529	20406952696927
137	2022-08-18 12:11:49	15364929	20417591953837
138	2022-08-19 12:37:30	15371329	20419662766334
139	2022-08-20 12:57:59	15377729	20421717971531
140	2022-08-21 13:04:27	15384129	20423739634701
141	2022-08-22 13:38:26	15390529	20425820371409
142	2022-08-23 13:49:31	15396930	20427869220625
143	2022-08-24 14:02:36	15403330	20429913823805
144	2022-08-25 14:57:13	15409730	20432019592901
145	2022-08-26 15:21:56	15416131	20434119355660
146	2022-08-27 16:03:06	15422531	20436229164592
147	2022-08-28 16:43:23	15428931	20438346278661
148	2022-08-29 17:08:38	15435332	20440406440698
149	2022-08-30 17:46:12	15441732	20442483103640
8455	2022-08-31 18:08:04	15448136	20444552805643
8457	2022-09-01 15:12:34	15453573	20446278289801
8458	2022-09-02 15:32:20	15459973	20481035179825
8459	2022-09-03 16:15:03	15466373	20485847377607
8460	2022-09-04 16:55:39	15472773	20490940072301
8461	2022-09-05 17:39:45	15479173	20495752026589
8463	2022-09-06 18:43:15	15485726	19215680653082
8464	2022-09-07 19:21:41	15492126	20712016852504
8465	2022-09-08 19:58:28	15498526	20716783873365
\.


--
-- Data for Name: strategy_balances; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.strategy_balances (id, address, value, "timestamp", block) FROM stdin;
1	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	0	2022-07-05 03:31:32	15080126
2	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	0	2022-07-05 03:31:32	15080126
3	0xC124A8088c39625f125655152A168baA86b49026	0	2022-07-05 03:31:32	15080126
4	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	0	2022-07-06 09:32:16	15088126
5	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	0	2022-07-06 09:32:16	15088126
6	0xC124A8088c39625f125655152A168baA86b49026	0	2022-07-06 09:32:16	15088126
7	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	0	2022-07-07 15:05:12	15096126
8	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	0	2022-07-07 15:05:12	15096126
9	0xC124A8088c39625f125655152A168baA86b49026	0	2022-07-07 15:05:12	15096126
10	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	0	2022-07-08 20:30:35	15104126
11	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	0	2022-07-08 20:30:35	15104126
12	0xC124A8088c39625f125655152A168baA86b49026	0	2022-07-08 20:30:35	15104126
13	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	0	2022-07-10 02:14:22	15112126
14	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	0	2022-07-10 02:14:22	15112126
15	0xC124A8088c39625f125655152A168baA86b49026	0	2022-07-10 02:14:22	15112126
16	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	0	2022-07-11 07:58:48	15120126
17	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	0	2022-07-11 07:58:48	15120126
18	0xC124A8088c39625f125655152A168baA86b49026	0	2022-07-11 07:58:48	15120126
19	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	0	2022-07-12 13:39:41	15128126
20	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	0	2022-07-12 13:39:41	15128126
21	0xC124A8088c39625f125655152A168baA86b49026	0	2022-07-12 13:39:41	15128126
22	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	9126787489480	2022-07-13 19:23:14	15136126
23	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	9116787458198	2022-07-13 19:23:14	15136126
24	0xC124A8088c39625f125655152A168baA86b49026	2000001309587	2022-07-13 19:23:14	15136126
25	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	9126917468715	2022-07-15 00:43:55	15144126
26	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	9116938163618	2022-07-15 00:43:55	15144126
27	0xC124A8088c39625f125655152A168baA86b49026	2000040234345	2022-07-15 00:43:55	15144126
28	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	9127055086978	2022-07-16 06:32:53	15152126
29	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	9117098367955	2022-07-16 06:32:53	15152126
30	0xC124A8088c39625f125655152A168baA86b49026	2000080449623	2022-07-16 06:32:53	15152126
31	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	9127215396385	2022-07-17 12:21:40	15160126
32	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	9117268128000	2022-07-17 12:21:40	15160126
33	0xC124A8088c39625f125655152A168baA86b49026	2000122573796	2022-07-17 12:21:40	15160126
34	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	9127378474199	2022-07-18 17:57:40	15168126
35	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	9117441312692	2022-07-18 17:57:40	15168126
36	0xC124A8088c39625f125655152A168baA86b49026	2000164474573	2022-07-18 17:57:40	15168126
37	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	9127549649165	2022-07-19 23:47:40	15176126
38	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	9117623635213	2022-07-19 23:47:40	15176126
39	0xC124A8088c39625f125655152A168baA86b49026	2000212102112	2022-07-19 23:47:40	15176126
40	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	9127707095705	2022-07-21 05:48:00	15184126
41	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	9117799236735	2022-07-21 05:48:00	15184126
42	0xC124A8088c39625f125655152A168baA86b49026	2000259537443	2022-07-21 05:48:00	15184126
43	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	9127865716252	2022-07-22 11:35:22	15192126
44	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	9117979323234	2022-07-22 11:35:22	15192126
45	0xC124A8088c39625f125655152A168baA86b49026	2000304387817	2022-07-22 11:35:22	15192126
46	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	9128015842856	2022-07-23 17:05:00	15200126
47	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	9118161347378	2022-07-23 17:05:00	15200126
48	0xC124A8088c39625f125655152A168baA86b49026	2000349288512	2022-07-23 17:05:00	15200126
49	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	9128176112549	2022-07-24 22:54:42	15208126
50	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	9118344702741	2022-07-24 22:54:42	15208126
51	0xC124A8088c39625f125655152A168baA86b49026	2000391765179	2022-07-24 22:54:42	15208126
52	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	9128339673032	2022-07-26 05:05:35	15216126
53	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	9118532466035	2022-07-26 05:05:35	15216126
54	0xC124A8088c39625f125655152A168baA86b49026	2000440385760	2022-07-26 05:05:35	15216126
55	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10175365047125	2022-07-27 10:54:31	15224126
56	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10175380309721	2022-07-27 10:54:31	15224126
57	0xC124A8088c39625f125655152A168baA86b49026	0	2022-07-27 10:54:31	15224126
58	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10175529197226	2022-07-28 10:36:21	15230527
59	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10175554347152	2022-07-28 10:36:21	15230527
60	0xC124A8088c39625f125655152A168baA86b49026	0	2022-07-28 10:36:21	15230527
61	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10175697079120	2022-07-29 10:49:51	15236928
62	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10175728262133	2022-07-29 10:49:51	15236928
63	0xC124A8088c39625f125655152A168baA86b49026	0	2022-07-29 10:49:51	15236928
64	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10175869858799	2022-07-30 10:44:48	15243328
65	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10175908084915	2022-07-30 10:44:48	15243328
66	0xC124A8088c39625f125655152A168baA86b49026	0	2022-07-30 10:44:48	15243328
67	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10176061711875	2022-07-31 10:36:06	15249728
68	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10176087228772	2022-07-31 10:36:06	15249728
69	0xC124A8088c39625f125655152A168baA86b49026	0	2022-07-31 10:36:06	15249728
70	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10176247995352	2022-08-01 10:34:06	15256128
71	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10176268732450	2022-08-01 10:34:06	15256128
72	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-01 10:34:06	15256128
73	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10176428415782	2022-08-02 10:24:34	15262528
74	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10176452357808	2022-08-02 10:24:34	15262528
75	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-02 10:24:34	15262528
76	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10176617711239	2022-08-03 10:23:16	15268928
77	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10176646875511	2022-08-03 10:23:16	15268928
78	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-03 10:23:16	15268928
79	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10176816500743	2022-08-04 10:26:31	15275328
80	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10176834932402	2022-08-04 10:26:31	15275328
81	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-04 10:26:31	15275328
82	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10177008000640	2022-08-05 10:25:33	15281728
83	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10177030782894	2022-08-05 10:25:33	15281728
84	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-05 10:25:33	15281728
85	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10177203376713	2022-08-06 10:16:26	15288129
86	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10177226663680	2022-08-06 10:16:26	15288129
87	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-06 10:16:26	15288129
88	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10177387148066	2022-08-07 10:09:27	15294529
89	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10177424200246	2022-08-07 10:09:27	15294529
90	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-07 10:09:27	15294529
91	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10177574322622	2022-08-08 10:08:58	15300929
92	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10177621858573	2022-08-08 10:08:58	15300929
93	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-08 10:08:58	15300929
94	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10177778954340	2022-08-09 09:55:10	15307329
95	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10177815978572	2022-08-09 09:55:10	15307329
96	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-09 09:55:10	15307329
97	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10177949554839	2022-08-10 10:07:25	15313729
98	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10178004869910	2022-08-10 10:07:25	15313729
99	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-10 10:07:25	15313729
100	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10178138066217	2022-08-11 10:16:04	15320129
101	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10178192352224	2022-08-11 10:16:04	15320129
102	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-11 10:16:04	15320129
103	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10178292287411	2022-08-12 10:42:38	15326529
104	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10178369963552	2022-08-12 10:42:38	15326529
105	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-12 10:42:38	15326529
106	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10178430691834	2022-08-13 10:44:37	15332929
107	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10178540174858	2022-08-13 10:44:37	15332929
108	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-13 10:44:37	15332929
109	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10178564043830	2022-08-14 10:53:19	15339329
110	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10178706131263	2022-08-14 10:53:19	15339329
111	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-14 10:53:19	15339329
112	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10178707941439	2022-08-15 11:24:06	15345729
113	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10178888877204	2022-08-15 11:24:06	15345729
114	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-15 11:24:06	15345729
115	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10178860262758	2022-08-16 11:40:05	15352129
116	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10179068599022	2022-08-16 11:40:05	15352129
117	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-16 11:40:05	15352129
118	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10178998453782	2022-08-17 11:44:12	15358529
119	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10179250499437	2022-08-17 11:44:12	15358529
120	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-17 11:44:12	15358529
121	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10179141164725	2022-08-18 12:11:49	15364929
122	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10179435466182	2022-08-18 12:11:49	15364929
123	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-18 12:11:49	15364929
124	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10179275015399	2022-08-19 12:37:30	15371329
125	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10179627150919	2022-08-19 12:37:30	15371329
126	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-19 12:37:30	15371329
127	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10179397801931	2022-08-20 12:57:59	15377729
128	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10179820484450	2022-08-20 12:57:59	15377729
129	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-20 12:57:59	15377729
130	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10179504786506	2022-08-21 13:04:27	15384129
131	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10180012768397	2022-08-21 13:04:27	15384129
132	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-21 13:04:27	15384129
133	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10179626408316	2022-08-22 13:38:26	15390529
134	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10180215722901	2022-08-22 13:38:26	15390529
135	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-22 13:38:26	15390529
136	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10179748034902	2022-08-23 13:49:31	15396930
137	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10180415053541	2022-08-23 13:49:31	15396930
138	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-23 13:49:31	15396930
139	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10179862133042	2022-08-24 14:02:36	15403330
140	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10180615285071	2022-08-24 14:02:36	15403330
141	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-24 14:02:36	15403330
142	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10179992085890	2022-08-25 14:57:13	15409730
143	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10180811371577	2022-08-25 14:57:13	15409730
144	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-25 14:57:13	15409730
145	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10180128202138	2022-08-26 15:21:56	15416131
146	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10181017331119	2022-08-26 15:21:56	15416131
147	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-26 15:21:56	15416131
148	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10180262098563	2022-08-27 16:03:06	15422531
149	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10181215399276	2022-08-27 16:03:06	15422531
150	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-27 16:03:06	15422531
151	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10180402888910	2022-08-28 16:43:23	15428931
152	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10181403938913	2022-08-28 16:43:23	15428931
153	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-28 16:43:23	15428931
154	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10180510580767	2022-08-29 17:08:38	15435332
155	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10181597669518	2022-08-29 17:08:38	15435332
156	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-29 17:08:38	15435332
157	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	10180624455629	2022-08-30 17:46:12	15441732
158	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	10181786934328	2022-08-30 17:46:12	15441732
159	0xC124A8088c39625f125655152A168baA86b49026	0	2022-08-30 17:46:12	15441732
160	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	7662752000000	2022-08-31 18:08:04	15448136
161	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	7725470423648	2022-08-31 18:08:04	15448136
162	0xB2acd0214F87d217A2eF148aA4a5ABA71d3F7956	5000000000000	2022-08-31 18:08:04	15448136
163	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	7718796205693	2022-09-01 09:01:03	15451974
164	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	7725561018334	2022-09-01 09:01:03	15451974
165	0xB2acd0214F87d217A2eF148aA4a5ABA71d3F7956	5000000000000	2022-09-01 09:01:03	15451974
166	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	7718868143262	2022-09-02 09:25:39	15458355
167	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	7725708791888	2022-09-02 09:25:39	15458355
168	0xB2acd0214F87d217A2eF148aA4a5ABA71d3F7956	5000000000000	2022-09-02 09:25:39	15458355
169	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	7718945708348	2022-09-03 10:10:00	15464755
170	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	7725849656432	2022-09-03 10:10:00	15464755
171	0xB2acd0214F87d217A2eF148aA4a5ABA71d3F7956	5000000000000	2022-09-03 10:10:00	15464755
172	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	7719018912735	2022-09-04 10:39:21	15471155
173	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	7725980375645	2022-09-04 10:39:21	15471155
174	0xB2acd0214F87d217A2eF148aA4a5ABA71d3F7956	5000000000000	2022-09-04 10:39:21	15471155
175	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	7719090936320	2022-09-05 11:18:23	15477555
176	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	7726111620064	2022-09-05 11:18:23	15477555
177	0xB2acd0214F87d217A2eF148aA4a5ABA71d3F7956	5000000000000	2022-09-05 11:18:23	15477555
181	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	7719171345362	2022-09-06 18:43:15	15485726
182	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	6495662525705	2022-09-06 18:43:15	15485726
183	0xB2acd0214F87d217A2eF148aA4a5ABA71d3F7956	5000000000000	2022-09-06 18:43:15	15485726
184	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	7855090209422	2022-09-07 19:21:41	15492126
185	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	7855101362157	2022-09-07 19:21:41	15492126
186	0xB2acd0214F87d217A2eF148aA4a5ABA71d3F7956	5000000000000	2022-09-07 19:21:41	15492126
187	0x75C5d2d8D54254476239a5c1e1F23ec48Df8779E	7855149677811	2022-09-08 19:58:28	15498526
188	0x5b7a52b6d75Fb3105c3c37fcc6007Eb7ac78F1B8	7855226603624	2022-09-08 19:58:28	15498526
189	0xB2acd0214F87d217A2eF148aA4a5ABA71d3F7956	5000000000000	2022-09-08 19:58:28	15498526
\.


--
-- Name: airdrops_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.airdrops_id_seq', 194, true);


--
-- Name: claim_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.claim_status_id_seq', 1, false);


--
-- Name: claims_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.claims_id_seq', 1, false);


--
-- Name: indexer_state_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.indexer_state_id_seq', 1, false);


--
-- Name: protocols_coverages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.protocols_coverages_id_seq', 7, true);


--
-- Name: protocols_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.protocols_id_seq', 7, true);


--
-- Name: protocols_premiums_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.protocols_premiums_id_seq', 15, true);


--
-- Name: staking_positions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.staking_positions_id_seq', 1, false);


--
-- Name: staking_positions_meta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.staking_positions_meta_id_seq', 1, false);


--
-- Name: stats_apy_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stats_apy_id_seq', 167, true);


--
-- Name: stats_tvc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stats_tvc_id_seq', 162, true);


--
-- Name: stats_tvl_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stats_tvl_id_seq', 8465, true);


--
-- Name: strategy_balances_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.strategy_balances_id_seq', 189, true);


--
-- Name: airdrops airdrops_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.airdrops
    ADD CONSTRAINT airdrops_pkey PRIMARY KEY (id);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: claim_status claim_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.claim_status
    ADD CONSTRAINT claim_status_pkey PRIMARY KEY (id);


--
-- Name: claims claims_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.claims
    ADD CONSTRAINT claims_pkey PRIMARY KEY (id);


--
-- Name: fundraise_positions fundraise_positions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fundraise_positions
    ADD CONSTRAINT fundraise_positions_pkey PRIMARY KEY (id);


--
-- Name: indexer_state indexer_state_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.indexer_state
    ADD CONSTRAINT indexer_state_pkey PRIMARY KEY (id);


--
-- Name: interval_functions interval_functions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interval_functions
    ADD CONSTRAINT interval_functions_pkey PRIMARY KEY (name);


--
-- Name: protocols protocols_bytes_identifier_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.protocols
    ADD CONSTRAINT protocols_bytes_identifier_key UNIQUE (bytes_identifier);


--
-- Name: protocols_coverages protocols_coverages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.protocols_coverages
    ADD CONSTRAINT protocols_coverages_pkey PRIMARY KEY (id);


--
-- Name: protocols_coverages protocols_coverages_protocol_id_coverage_amount_coverage_am_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.protocols_coverages
    ADD CONSTRAINT protocols_coverages_protocol_id_coverage_amount_coverage_am_key UNIQUE (protocol_id, coverage_amount, coverage_amount_set_at);


--
-- Name: protocols protocols_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.protocols
    ADD CONSTRAINT protocols_pkey PRIMARY KEY (id);


--
-- Name: protocols_premiums protocols_premiums_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.protocols_premiums
    ADD CONSTRAINT protocols_premiums_pkey PRIMARY KEY (id);


--
-- Name: staking_positions_meta staking_positions_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staking_positions_meta
    ADD CONSTRAINT staking_positions_meta_pkey PRIMARY KEY (id);


--
-- Name: staking_positions staking_positions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staking_positions
    ADD CONSTRAINT staking_positions_pkey PRIMARY KEY (id);


--
-- Name: stats_apy stats_apy_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stats_apy
    ADD CONSTRAINT stats_apy_pkey PRIMARY KEY (id);


--
-- Name: stats_tvc stats_tvc_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stats_tvc
    ADD CONSTRAINT stats_tvc_pkey PRIMARY KEY (id);


--
-- Name: stats_tvl stats_tvl_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stats_tvl
    ADD CONSTRAINT stats_tvl_pkey PRIMARY KEY (id);


--
-- Name: strategy_balances strategy_balances_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.strategy_balances
    ADD CONSTRAINT strategy_balances_pkey PRIMARY KEY (id);


--
-- Name: claim_status claim_status_claim_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.claim_status
    ADD CONSTRAINT claim_status_claim_id_fkey FOREIGN KEY (claim_id) REFERENCES public.claims(id);


--
-- Name: claims claims_protocol_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.claims
    ADD CONSTRAINT claims_protocol_id_fkey FOREIGN KEY (protocol_id) REFERENCES public.protocols(id);


--
-- Name: protocols_coverages protocols_coverages_protocol_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.protocols_coverages
    ADD CONSTRAINT protocols_coverages_protocol_id_fkey FOREIGN KEY (protocol_id) REFERENCES public.protocols(id);


--
-- Name: protocols_premiums protocols_premiums_protocol_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.protocols_premiums
    ADD CONSTRAINT protocols_premiums_protocol_id_fkey FOREIGN KEY (protocol_id) REFERENCES public.protocols(id);


--
-- PostgreSQL database dump complete
--

