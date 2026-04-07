--
-- PostgreSQL database dump
--

\restrict wmwExmqZ5Pm8WOAzgjl3DDu5YdRl8MhGFZtxYdCj5d6j3ypllC7U86icxSbtk3W

-- Dumped from database version 15.17 (Debian 15.17-1.pgdg13+1)
-- Dumped by pg_dump version 15.17 (Debian 15.17-1.pgdg13+1)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admin_event_entity; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.admin_event_entity (
    id character varying(36) NOT NULL,
    admin_event_time bigint,
    realm_id character varying(255),
    operation_type character varying(255),
    auth_realm_id character varying(255),
    auth_client_id character varying(255),
    auth_user_id character varying(255),
    ip_address character varying(255),
    resource_path character varying(2550),
    representation text,
    error character varying(255),
    resource_type character varying(64)
);


ALTER TABLE public.admin_event_entity OWNER TO vermeg;

--
-- Name: applications; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.applications (
    id bigint NOT NULL,
    applied_at timestamp(6) without time zone,
    cin_file text,
    city character varying(255),
    country character varying(255),
    cover_letter text,
    cv_file text,
    diploma_file text,
    email character varying(255),
    full_name character varying(255),
    job_id bigint,
    job_title character varying(255),
    phone character varying(255),
    status character varying(255),
    user_id bigint
);


ALTER TABLE public.applications OWNER TO vermeg;

--
-- Name: applications_id_seq; Type: SEQUENCE; Schema: public; Owner: vermeg
--

CREATE SEQUENCE public.applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.applications_id_seq OWNER TO vermeg;

--
-- Name: applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vermeg
--

ALTER SEQUENCE public.applications_id_seq OWNED BY public.applications.id;


--
-- Name: approval_decisions; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.approval_decisions (
    id bigint NOT NULL,
    comment character varying(255),
    decided_at timestamp(6) without time zone,
    decided_by character varying(255) NOT NULL,
    status character varying(255) NOT NULL,
    target_id bigint NOT NULL,
    target_type character varying(255) NOT NULL
);


ALTER TABLE public.approval_decisions OWNER TO vermeg;

--
-- Name: approval_decisions_id_seq; Type: SEQUENCE; Schema: public; Owner: vermeg
--

CREATE SEQUENCE public.approval_decisions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.approval_decisions_id_seq OWNER TO vermeg;

--
-- Name: approval_decisions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vermeg
--

ALTER SEQUENCE public.approval_decisions_id_seq OWNED BY public.approval_decisions.id;


--
-- Name: associated_policy; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.associated_policy (
    policy_id character varying(36) NOT NULL,
    associated_policy_id character varying(36) NOT NULL
);


ALTER TABLE public.associated_policy OWNER TO vermeg;

--
-- Name: authentication_execution; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.authentication_execution (
    id character varying(36) NOT NULL,
    alias character varying(255),
    authenticator character varying(36),
    realm_id character varying(36),
    flow_id character varying(36),
    requirement integer,
    priority integer,
    authenticator_flow boolean DEFAULT false NOT NULL,
    auth_flow_id character varying(36),
    auth_config character varying(36)
);


ALTER TABLE public.authentication_execution OWNER TO vermeg;

--
-- Name: authentication_flow; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.authentication_flow (
    id character varying(36) NOT NULL,
    alias character varying(255),
    description character varying(255),
    realm_id character varying(36),
    provider_id character varying(36) DEFAULT 'basic-flow'::character varying NOT NULL,
    top_level boolean DEFAULT false NOT NULL,
    built_in boolean DEFAULT false NOT NULL
);


ALTER TABLE public.authentication_flow OWNER TO vermeg;

--
-- Name: authenticator_config; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.authenticator_config (
    id character varying(36) NOT NULL,
    alias character varying(255),
    realm_id character varying(36)
);


ALTER TABLE public.authenticator_config OWNER TO vermeg;

--
-- Name: authenticator_config_entry; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.authenticator_config_entry (
    authenticator_id character varying(36) NOT NULL,
    value text,
    name character varying(255) NOT NULL
);


ALTER TABLE public.authenticator_config_entry OWNER TO vermeg;

--
-- Name: broker_link; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.broker_link (
    identity_provider character varying(255) NOT NULL,
    storage_provider_id character varying(255),
    realm_id character varying(36) NOT NULL,
    broker_user_id character varying(255),
    broker_username character varying(255),
    token text,
    user_id character varying(255) NOT NULL
);


ALTER TABLE public.broker_link OWNER TO vermeg;

--
-- Name: client; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.client (
    id character varying(36) NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    full_scope_allowed boolean DEFAULT false NOT NULL,
    client_id character varying(255),
    not_before integer,
    public_client boolean DEFAULT false NOT NULL,
    secret character varying(255),
    base_url character varying(255),
    bearer_only boolean DEFAULT false NOT NULL,
    management_url character varying(255),
    surrogate_auth_required boolean DEFAULT false NOT NULL,
    realm_id character varying(36),
    protocol character varying(255),
    node_rereg_timeout integer DEFAULT 0,
    frontchannel_logout boolean DEFAULT false NOT NULL,
    consent_required boolean DEFAULT false NOT NULL,
    name character varying(255),
    service_accounts_enabled boolean DEFAULT false NOT NULL,
    client_authenticator_type character varying(255),
    root_url character varying(255),
    description character varying(255),
    registration_token character varying(255),
    standard_flow_enabled boolean DEFAULT true NOT NULL,
    implicit_flow_enabled boolean DEFAULT false NOT NULL,
    direct_access_grants_enabled boolean DEFAULT false NOT NULL,
    always_display_in_console boolean DEFAULT false NOT NULL
);


ALTER TABLE public.client OWNER TO vermeg;

--
-- Name: client_attributes; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.client_attributes (
    client_id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    value text
);


ALTER TABLE public.client_attributes OWNER TO vermeg;

--
-- Name: client_auth_flow_bindings; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.client_auth_flow_bindings (
    client_id character varying(36) NOT NULL,
    flow_id character varying(36),
    binding_name character varying(255) NOT NULL
);


ALTER TABLE public.client_auth_flow_bindings OWNER TO vermeg;

--
-- Name: client_initial_access; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.client_initial_access (
    id character varying(36) NOT NULL,
    realm_id character varying(36) NOT NULL,
    "timestamp" integer,
    expiration integer,
    count integer,
    remaining_count integer
);


ALTER TABLE public.client_initial_access OWNER TO vermeg;

--
-- Name: client_node_registrations; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.client_node_registrations (
    client_id character varying(36) NOT NULL,
    value integer,
    name character varying(255) NOT NULL
);


ALTER TABLE public.client_node_registrations OWNER TO vermeg;

--
-- Name: client_scope; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.client_scope (
    id character varying(36) NOT NULL,
    name character varying(255),
    realm_id character varying(36),
    description character varying(255),
    protocol character varying(255)
);


ALTER TABLE public.client_scope OWNER TO vermeg;

--
-- Name: client_scope_attributes; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.client_scope_attributes (
    scope_id character varying(36) NOT NULL,
    value character varying(2048),
    name character varying(255) NOT NULL
);


ALTER TABLE public.client_scope_attributes OWNER TO vermeg;

--
-- Name: client_scope_client; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.client_scope_client (
    client_id character varying(255) NOT NULL,
    scope_id character varying(255) NOT NULL,
    default_scope boolean DEFAULT false NOT NULL
);


ALTER TABLE public.client_scope_client OWNER TO vermeg;

--
-- Name: client_scope_role_mapping; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.client_scope_role_mapping (
    scope_id character varying(36) NOT NULL,
    role_id character varying(36) NOT NULL
);


ALTER TABLE public.client_scope_role_mapping OWNER TO vermeg;

--
-- Name: client_session; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.client_session (
    id character varying(36) NOT NULL,
    client_id character varying(36),
    redirect_uri character varying(255),
    state character varying(255),
    "timestamp" integer,
    session_id character varying(36),
    auth_method character varying(255),
    realm_id character varying(255),
    auth_user_id character varying(36),
    current_action character varying(36)
);


ALTER TABLE public.client_session OWNER TO vermeg;

--
-- Name: client_session_auth_status; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.client_session_auth_status (
    authenticator character varying(36) NOT NULL,
    status integer,
    client_session character varying(36) NOT NULL
);


ALTER TABLE public.client_session_auth_status OWNER TO vermeg;

--
-- Name: client_session_note; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.client_session_note (
    name character varying(255) NOT NULL,
    value character varying(255),
    client_session character varying(36) NOT NULL
);


ALTER TABLE public.client_session_note OWNER TO vermeg;

--
-- Name: client_session_prot_mapper; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.client_session_prot_mapper (
    protocol_mapper_id character varying(36) NOT NULL,
    client_session character varying(36) NOT NULL
);


ALTER TABLE public.client_session_prot_mapper OWNER TO vermeg;

--
-- Name: client_session_role; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.client_session_role (
    role_id character varying(255) NOT NULL,
    client_session character varying(36) NOT NULL
);


ALTER TABLE public.client_session_role OWNER TO vermeg;

--
-- Name: client_user_session_note; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.client_user_session_note (
    name character varying(255) NOT NULL,
    value character varying(2048),
    client_session character varying(36) NOT NULL
);


ALTER TABLE public.client_user_session_note OWNER TO vermeg;

--
-- Name: component; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.component (
    id character varying(36) NOT NULL,
    name character varying(255),
    parent_id character varying(36),
    provider_id character varying(36),
    provider_type character varying(255),
    realm_id character varying(36),
    sub_type character varying(255)
);


ALTER TABLE public.component OWNER TO vermeg;

--
-- Name: component_config; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.component_config (
    id character varying(36) NOT NULL,
    component_id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    value text
);


ALTER TABLE public.component_config OWNER TO vermeg;

--
-- Name: composite_role; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.composite_role (
    composite character varying(36) NOT NULL,
    child_role character varying(36) NOT NULL
);


ALTER TABLE public.composite_role OWNER TO vermeg;

--
-- Name: contract_types; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.contract_types (
    id bigint NOT NULL,
    description character varying(255),
    name character varying(255) NOT NULL
);


ALTER TABLE public.contract_types OWNER TO vermeg;

--
-- Name: contract_types_id_seq; Type: SEQUENCE; Schema: public; Owner: vermeg
--

CREATE SEQUENCE public.contract_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.contract_types_id_seq OWNER TO vermeg;

--
-- Name: contract_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vermeg
--

ALTER SEQUENCE public.contract_types_id_seq OWNED BY public.contract_types.id;


--
-- Name: credential; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.credential (
    id character varying(36) NOT NULL,
    salt bytea,
    type character varying(255),
    user_id character varying(36),
    created_date bigint,
    user_label character varying(255),
    secret_data text,
    credential_data text,
    priority integer
);


ALTER TABLE public.credential OWNER TO vermeg;

--
-- Name: databasechangelog; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.databasechangelog (
    id character varying(255) NOT NULL,
    author character varying(255) NOT NULL,
    filename character varying(255) NOT NULL,
    dateexecuted timestamp without time zone NOT NULL,
    orderexecuted integer NOT NULL,
    exectype character varying(10) NOT NULL,
    md5sum character varying(35),
    description character varying(255),
    comments character varying(255),
    tag character varying(255),
    liquibase character varying(20),
    contexts character varying(255),
    labels character varying(255),
    deployment_id character varying(10)
);


ALTER TABLE public.databasechangelog OWNER TO vermeg;

--
-- Name: databasechangeloglock; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.databasechangeloglock (
    id integer NOT NULL,
    locked boolean NOT NULL,
    lockgranted timestamp without time zone,
    lockedby character varying(255)
);


ALTER TABLE public.databasechangeloglock OWNER TO vermeg;

--
-- Name: default_client_scope; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.default_client_scope (
    realm_id character varying(36) NOT NULL,
    scope_id character varying(36) NOT NULL,
    default_scope boolean DEFAULT false NOT NULL
);


ALTER TABLE public.default_client_scope OWNER TO vermeg;

--
-- Name: departments; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.departments (
    id bigint NOT NULL,
    description character varying(255),
    name character varying(255) NOT NULL
);


ALTER TABLE public.departments OWNER TO vermeg;

--
-- Name: departments_id_seq; Type: SEQUENCE; Schema: public; Owner: vermeg
--

CREATE SEQUENCE public.departments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.departments_id_seq OWNER TO vermeg;

--
-- Name: departments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vermeg
--

ALTER SEQUENCE public.departments_id_seq OWNED BY public.departments.id;


--
-- Name: document_requests; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.document_requests (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone,
    details character varying(255),
    employee_email character varying(255),
    file_data text,
    file_name character varying(255),
    status character varying(255),
    type character varying(255),
    user_id bigint
);


ALTER TABLE public.document_requests OWNER TO vermeg;

--
-- Name: document_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: vermeg
--

CREATE SEQUENCE public.document_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.document_requests_id_seq OWNER TO vermeg;

--
-- Name: document_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vermeg
--

ALTER SEQUENCE public.document_requests_id_seq OWNED BY public.document_requests.id;


--
-- Name: event_entity; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.event_entity (
    id character varying(36) NOT NULL,
    client_id character varying(255),
    details_json character varying(2550),
    error character varying(255),
    ip_address character varying(255),
    realm_id character varying(255),
    session_id character varying(255),
    event_time bigint,
    type character varying(255),
    user_id character varying(255),
    details_json_long_value text
);


ALTER TABLE public.event_entity OWNER TO vermeg;

--
-- Name: fed_user_attribute; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.fed_user_attribute (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    storage_provider_id character varying(36),
    value character varying(2024),
    long_value_hash bytea,
    long_value_hash_lower_case bytea,
    long_value text
);


ALTER TABLE public.fed_user_attribute OWNER TO vermeg;

--
-- Name: fed_user_consent; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.fed_user_consent (
    id character varying(36) NOT NULL,
    client_id character varying(255),
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    storage_provider_id character varying(36),
    created_date bigint,
    last_updated_date bigint,
    client_storage_provider character varying(36),
    external_client_id character varying(255)
);


ALTER TABLE public.fed_user_consent OWNER TO vermeg;

--
-- Name: fed_user_consent_cl_scope; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.fed_user_consent_cl_scope (
    user_consent_id character varying(36) NOT NULL,
    scope_id character varying(36) NOT NULL
);


ALTER TABLE public.fed_user_consent_cl_scope OWNER TO vermeg;

--
-- Name: fed_user_credential; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.fed_user_credential (
    id character varying(36) NOT NULL,
    salt bytea,
    type character varying(255),
    created_date bigint,
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    storage_provider_id character varying(36),
    user_label character varying(255),
    secret_data text,
    credential_data text,
    priority integer
);


ALTER TABLE public.fed_user_credential OWNER TO vermeg;

--
-- Name: fed_user_group_membership; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.fed_user_group_membership (
    group_id character varying(36) NOT NULL,
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    storage_provider_id character varying(36)
);


ALTER TABLE public.fed_user_group_membership OWNER TO vermeg;

--
-- Name: fed_user_required_action; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.fed_user_required_action (
    required_action character varying(255) DEFAULT ' '::character varying NOT NULL,
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    storage_provider_id character varying(36)
);


ALTER TABLE public.fed_user_required_action OWNER TO vermeg;

--
-- Name: fed_user_role_mapping; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.fed_user_role_mapping (
    role_id character varying(36) NOT NULL,
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    storage_provider_id character varying(36)
);


ALTER TABLE public.fed_user_role_mapping OWNER TO vermeg;

--
-- Name: federated_identity; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.federated_identity (
    identity_provider character varying(255) NOT NULL,
    realm_id character varying(36),
    federated_user_id character varying(255),
    federated_username character varying(255),
    token text,
    user_id character varying(36) NOT NULL
);


ALTER TABLE public.federated_identity OWNER TO vermeg;

--
-- Name: federated_user; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.federated_user (
    id character varying(255) NOT NULL,
    storage_provider_id character varying(255),
    realm_id character varying(36) NOT NULL
);


ALTER TABLE public.federated_user OWNER TO vermeg;

--
-- Name: group_attribute; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.group_attribute (
    id character varying(36) DEFAULT 'sybase-needs-something-here'::character varying NOT NULL,
    name character varying(255) NOT NULL,
    value character varying(255),
    group_id character varying(36) NOT NULL
);


ALTER TABLE public.group_attribute OWNER TO vermeg;

--
-- Name: group_role_mapping; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.group_role_mapping (
    role_id character varying(36) NOT NULL,
    group_id character varying(36) NOT NULL
);


ALTER TABLE public.group_role_mapping OWNER TO vermeg;

--
-- Name: identity_provider; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.identity_provider (
    internal_id character varying(36) NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    provider_alias character varying(255),
    provider_id character varying(255),
    store_token boolean DEFAULT false NOT NULL,
    authenticate_by_default boolean DEFAULT false NOT NULL,
    realm_id character varying(36),
    add_token_role boolean DEFAULT true NOT NULL,
    trust_email boolean DEFAULT false NOT NULL,
    first_broker_login_flow_id character varying(36),
    post_broker_login_flow_id character varying(36),
    provider_display_name character varying(255),
    link_only boolean DEFAULT false NOT NULL
);


ALTER TABLE public.identity_provider OWNER TO vermeg;

--
-- Name: identity_provider_config; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.identity_provider_config (
    identity_provider_id character varying(36) NOT NULL,
    value text,
    name character varying(255) NOT NULL
);


ALTER TABLE public.identity_provider_config OWNER TO vermeg;

--
-- Name: identity_provider_mapper; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.identity_provider_mapper (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    idp_alias character varying(255) NOT NULL,
    idp_mapper_name character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL
);


ALTER TABLE public.identity_provider_mapper OWNER TO vermeg;

--
-- Name: idp_mapper_config; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.idp_mapper_config (
    idp_mapper_id character varying(36) NOT NULL,
    value text,
    name character varying(255) NOT NULL
);


ALTER TABLE public.idp_mapper_config OWNER TO vermeg;

--
-- Name: interviews; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.interviews (
    id bigint NOT NULL,
    application_id bigint,
    candidate_email character varying(255),
    candidate_name character varying(255),
    comments text,
    date character varying(255),
    evaluator_id bigint,
    job_title character varying(255),
    score integer,
    status character varying(255)
);


ALTER TABLE public.interviews OWNER TO vermeg;

--
-- Name: interviews_id_seq; Type: SEQUENCE; Schema: public; Owner: vermeg
--

CREATE SEQUENCE public.interviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.interviews_id_seq OWNER TO vermeg;

--
-- Name: interviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vermeg
--

ALTER SEQUENCE public.interviews_id_seq OWNED BY public.interviews.id;


--
-- Name: job_offers; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.job_offers (
    id bigint NOT NULL,
    closing_date date,
    created_at timestamp(6) without time zone,
    department character varying(255),
    description text,
    eligibility_criteria text,
    opening_date date,
    recruiter_id bigint,
    requirements text,
    salary_range character varying(255),
    status character varying(255),
    title character varying(255) NOT NULL,
    type character varying(255)
);


ALTER TABLE public.job_offers OWNER TO vermeg;

--
-- Name: job_offers_id_seq; Type: SEQUENCE; Schema: public; Owner: vermeg
--

CREATE SEQUENCE public.job_offers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_offers_id_seq OWNER TO vermeg;

--
-- Name: job_offers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vermeg
--

ALTER SEQUENCE public.job_offers_id_seq OWNED BY public.job_offers.id;


--
-- Name: keycloak_group; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.keycloak_group (
    id character varying(36) NOT NULL,
    name character varying(255),
    parent_group character varying(36) NOT NULL,
    realm_id character varying(36)
);


ALTER TABLE public.keycloak_group OWNER TO vermeg;

--
-- Name: keycloak_role; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.keycloak_role (
    id character varying(36) NOT NULL,
    client_realm_constraint character varying(255),
    client_role boolean DEFAULT false NOT NULL,
    description character varying(255),
    name character varying(255),
    realm_id character varying(255),
    client character varying(36),
    realm character varying(36)
);


ALTER TABLE public.keycloak_role OWNER TO vermeg;

--
-- Name: leave_requests; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.leave_requests (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone,
    employee_email character varying(255) NOT NULL,
    end_date date,
    reason character varying(255),
    start_date date,
    status character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    user_id bigint
);


ALTER TABLE public.leave_requests OWNER TO vermeg;

--
-- Name: leave_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: vermeg
--

CREATE SEQUENCE public.leave_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.leave_requests_id_seq OWNER TO vermeg;

--
-- Name: leave_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vermeg
--

ALTER SEQUENCE public.leave_requests_id_seq OWNED BY public.leave_requests.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.messages (
    id bigint NOT NULL,
    content text,
    created_at timestamp(6) without time zone,
    is_read boolean,
    receiver_id bigint,
    sender_id bigint
);


ALTER TABLE public.messages OWNER TO vermeg;

--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: vermeg
--

CREATE SEQUENCE public.messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.messages_id_seq OWNER TO vermeg;

--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vermeg
--

ALTER SEQUENCE public.messages_id_seq OWNED BY public.messages.id;


--
-- Name: migration_model; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.migration_model (
    id character varying(36) NOT NULL,
    version character varying(36),
    update_time bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.migration_model OWNER TO vermeg;

--
-- Name: news; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.news (
    id bigint NOT NULL,
    author_id bigint,
    content text,
    created_at timestamp(6) without time zone,
    title character varying(255)
);


ALTER TABLE public.news OWNER TO vermeg;

--
-- Name: news_id_seq; Type: SEQUENCE; Schema: public; Owner: vermeg
--

CREATE SEQUENCE public.news_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.news_id_seq OWNER TO vermeg;

--
-- Name: news_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vermeg
--

ALTER SEQUENCE public.news_id_seq OWNED BY public.news.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.notifications (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone,
    is_read boolean,
    message text,
    type character varying(255),
    user_id bigint
);


ALTER TABLE public.notifications OWNER TO vermeg;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: vermeg
--

CREATE SEQUENCE public.notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notifications_id_seq OWNER TO vermeg;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vermeg
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: offline_client_session; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.offline_client_session (
    user_session_id character varying(36) NOT NULL,
    client_id character varying(255) NOT NULL,
    offline_flag character varying(4) NOT NULL,
    "timestamp" integer,
    data text,
    client_storage_provider character varying(36) DEFAULT 'local'::character varying NOT NULL,
    external_client_id character varying(255) DEFAULT 'local'::character varying NOT NULL
);


ALTER TABLE public.offline_client_session OWNER TO vermeg;

--
-- Name: offline_user_session; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.offline_user_session (
    user_session_id character varying(36) NOT NULL,
    user_id character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    created_on integer NOT NULL,
    offline_flag character varying(4) NOT NULL,
    data text,
    last_session_refresh integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.offline_user_session OWNER TO vermeg;

--
-- Name: policy_config; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.policy_config (
    policy_id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    value text
);


ALTER TABLE public.policy_config OWNER TO vermeg;

--
-- Name: positions; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.positions (
    id bigint NOT NULL,
    department character varying(255),
    title character varying(255) NOT NULL
);


ALTER TABLE public.positions OWNER TO vermeg;

--
-- Name: positions_id_seq; Type: SEQUENCE; Schema: public; Owner: vermeg
--

CREATE SEQUENCE public.positions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.positions_id_seq OWNER TO vermeg;

--
-- Name: positions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vermeg
--

ALTER SEQUENCE public.positions_id_seq OWNED BY public.positions.id;


--
-- Name: protocol_mapper; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.protocol_mapper (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    protocol character varying(255) NOT NULL,
    protocol_mapper_name character varying(255) NOT NULL,
    client_id character varying(36),
    client_scope_id character varying(36)
);


ALTER TABLE public.protocol_mapper OWNER TO vermeg;

--
-- Name: protocol_mapper_config; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.protocol_mapper_config (
    protocol_mapper_id character varying(36) NOT NULL,
    value text,
    name character varying(255) NOT NULL
);


ALTER TABLE public.protocol_mapper_config OWNER TO vermeg;

--
-- Name: realm; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.realm (
    id character varying(36) NOT NULL,
    access_code_lifespan integer,
    user_action_lifespan integer,
    access_token_lifespan integer,
    account_theme character varying(255),
    admin_theme character varying(255),
    email_theme character varying(255),
    enabled boolean DEFAULT false NOT NULL,
    events_enabled boolean DEFAULT false NOT NULL,
    events_expiration bigint,
    login_theme character varying(255),
    name character varying(255),
    not_before integer,
    password_policy character varying(2550),
    registration_allowed boolean DEFAULT false NOT NULL,
    remember_me boolean DEFAULT false NOT NULL,
    reset_password_allowed boolean DEFAULT false NOT NULL,
    social boolean DEFAULT false NOT NULL,
    ssl_required character varying(255),
    sso_idle_timeout integer,
    sso_max_lifespan integer,
    update_profile_on_soc_login boolean DEFAULT false NOT NULL,
    verify_email boolean DEFAULT false NOT NULL,
    master_admin_client character varying(36),
    login_lifespan integer,
    internationalization_enabled boolean DEFAULT false NOT NULL,
    default_locale character varying(255),
    reg_email_as_username boolean DEFAULT false NOT NULL,
    admin_events_enabled boolean DEFAULT false NOT NULL,
    admin_events_details_enabled boolean DEFAULT false NOT NULL,
    edit_username_allowed boolean DEFAULT false NOT NULL,
    otp_policy_counter integer DEFAULT 0,
    otp_policy_window integer DEFAULT 1,
    otp_policy_period integer DEFAULT 30,
    otp_policy_digits integer DEFAULT 6,
    otp_policy_alg character varying(36) DEFAULT 'HmacSHA1'::character varying,
    otp_policy_type character varying(36) DEFAULT 'totp'::character varying,
    browser_flow character varying(36),
    registration_flow character varying(36),
    direct_grant_flow character varying(36),
    reset_credentials_flow character varying(36),
    client_auth_flow character varying(36),
    offline_session_idle_timeout integer DEFAULT 0,
    revoke_refresh_token boolean DEFAULT false NOT NULL,
    access_token_life_implicit integer DEFAULT 0,
    login_with_email_allowed boolean DEFAULT true NOT NULL,
    duplicate_emails_allowed boolean DEFAULT false NOT NULL,
    docker_auth_flow character varying(36),
    refresh_token_max_reuse integer DEFAULT 0,
    allow_user_managed_access boolean DEFAULT false NOT NULL,
    sso_max_lifespan_remember_me integer DEFAULT 0 NOT NULL,
    sso_idle_timeout_remember_me integer DEFAULT 0 NOT NULL,
    default_role character varying(255)
);


ALTER TABLE public.realm OWNER TO vermeg;

--
-- Name: realm_attribute; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.realm_attribute (
    name character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL,
    value text
);


ALTER TABLE public.realm_attribute OWNER TO vermeg;

--
-- Name: realm_default_groups; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.realm_default_groups (
    realm_id character varying(36) NOT NULL,
    group_id character varying(36) NOT NULL
);


ALTER TABLE public.realm_default_groups OWNER TO vermeg;

--
-- Name: realm_enabled_event_types; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.realm_enabled_event_types (
    realm_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


ALTER TABLE public.realm_enabled_event_types OWNER TO vermeg;

--
-- Name: realm_events_listeners; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.realm_events_listeners (
    realm_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


ALTER TABLE public.realm_events_listeners OWNER TO vermeg;

--
-- Name: realm_localizations; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.realm_localizations (
    realm_id character varying(255) NOT NULL,
    locale character varying(255) NOT NULL,
    texts text NOT NULL
);


ALTER TABLE public.realm_localizations OWNER TO vermeg;

--
-- Name: realm_required_credential; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.realm_required_credential (
    type character varying(255) NOT NULL,
    form_label character varying(255),
    input boolean DEFAULT false NOT NULL,
    secret boolean DEFAULT false NOT NULL,
    realm_id character varying(36) NOT NULL
);


ALTER TABLE public.realm_required_credential OWNER TO vermeg;

--
-- Name: realm_smtp_config; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.realm_smtp_config (
    realm_id character varying(36) NOT NULL,
    value character varying(255),
    name character varying(255) NOT NULL
);


ALTER TABLE public.realm_smtp_config OWNER TO vermeg;

--
-- Name: realm_supported_locales; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.realm_supported_locales (
    realm_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


ALTER TABLE public.realm_supported_locales OWNER TO vermeg;

--
-- Name: redirect_uris; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.redirect_uris (
    client_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


ALTER TABLE public.redirect_uris OWNER TO vermeg;

--
-- Name: required_action_config; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.required_action_config (
    required_action_id character varying(36) NOT NULL,
    value text,
    name character varying(255) NOT NULL
);


ALTER TABLE public.required_action_config OWNER TO vermeg;

--
-- Name: required_action_provider; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.required_action_provider (
    id character varying(36) NOT NULL,
    alias character varying(255),
    name character varying(255),
    realm_id character varying(36),
    enabled boolean DEFAULT false NOT NULL,
    default_action boolean DEFAULT false NOT NULL,
    provider_id character varying(255),
    priority integer
);


ALTER TABLE public.required_action_provider OWNER TO vermeg;

--
-- Name: resource_attribute; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.resource_attribute (
    id character varying(36) DEFAULT 'sybase-needs-something-here'::character varying NOT NULL,
    name character varying(255) NOT NULL,
    value character varying(255),
    resource_id character varying(36) NOT NULL
);


ALTER TABLE public.resource_attribute OWNER TO vermeg;

--
-- Name: resource_policy; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.resource_policy (
    resource_id character varying(36) NOT NULL,
    policy_id character varying(36) NOT NULL
);


ALTER TABLE public.resource_policy OWNER TO vermeg;

--
-- Name: resource_scope; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.resource_scope (
    resource_id character varying(36) NOT NULL,
    scope_id character varying(36) NOT NULL
);


ALTER TABLE public.resource_scope OWNER TO vermeg;

--
-- Name: resource_server; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.resource_server (
    id character varying(36) NOT NULL,
    allow_rs_remote_mgmt boolean DEFAULT false NOT NULL,
    policy_enforce_mode smallint NOT NULL,
    decision_strategy smallint DEFAULT 1 NOT NULL
);


ALTER TABLE public.resource_server OWNER TO vermeg;

--
-- Name: resource_server_perm_ticket; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.resource_server_perm_ticket (
    id character varying(36) NOT NULL,
    owner character varying(255) NOT NULL,
    requester character varying(255) NOT NULL,
    created_timestamp bigint NOT NULL,
    granted_timestamp bigint,
    resource_id character varying(36) NOT NULL,
    scope_id character varying(36),
    resource_server_id character varying(36) NOT NULL,
    policy_id character varying(36)
);


ALTER TABLE public.resource_server_perm_ticket OWNER TO vermeg;

--
-- Name: resource_server_policy; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.resource_server_policy (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    type character varying(255) NOT NULL,
    decision_strategy smallint,
    logic smallint,
    resource_server_id character varying(36) NOT NULL,
    owner character varying(255)
);


ALTER TABLE public.resource_server_policy OWNER TO vermeg;

--
-- Name: resource_server_resource; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.resource_server_resource (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    type character varying(255),
    icon_uri character varying(255),
    owner character varying(255) NOT NULL,
    resource_server_id character varying(36) NOT NULL,
    owner_managed_access boolean DEFAULT false NOT NULL,
    display_name character varying(255)
);


ALTER TABLE public.resource_server_resource OWNER TO vermeg;

--
-- Name: resource_server_scope; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.resource_server_scope (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    icon_uri character varying(255),
    resource_server_id character varying(36) NOT NULL,
    display_name character varying(255)
);


ALTER TABLE public.resource_server_scope OWNER TO vermeg;

--
-- Name: resource_uris; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.resource_uris (
    resource_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


ALTER TABLE public.resource_uris OWNER TO vermeg;

--
-- Name: role_attribute; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.role_attribute (
    id character varying(36) NOT NULL,
    role_id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    value character varying(255)
);


ALTER TABLE public.role_attribute OWNER TO vermeg;

--
-- Name: salary_requests; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.salary_requests (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone,
    details character varying(255),
    employee_email character varying(255),
    file_data text,
    file_name character varying(255),
    month integer,
    status character varying(255),
    user_id bigint,
    year integer
);


ALTER TABLE public.salary_requests OWNER TO vermeg;

--
-- Name: salary_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: vermeg
--

CREATE SEQUENCE public.salary_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.salary_requests_id_seq OWNER TO vermeg;

--
-- Name: salary_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vermeg
--

ALTER SEQUENCE public.salary_requests_id_seq OWNED BY public.salary_requests.id;


--
-- Name: scope_mapping; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.scope_mapping (
    client_id character varying(36) NOT NULL,
    role_id character varying(36) NOT NULL
);


ALTER TABLE public.scope_mapping OWNER TO vermeg;

--
-- Name: scope_policy; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.scope_policy (
    scope_id character varying(36) NOT NULL,
    policy_id character varying(36) NOT NULL
);


ALTER TABLE public.scope_policy OWNER TO vermeg;

--
-- Name: user_attribute; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.user_attribute (
    name character varying(255) NOT NULL,
    value character varying(255),
    user_id character varying(36) NOT NULL,
    id character varying(36) DEFAULT 'sybase-needs-something-here'::character varying NOT NULL,
    long_value_hash bytea,
    long_value_hash_lower_case bytea,
    long_value text
);


ALTER TABLE public.user_attribute OWNER TO vermeg;

--
-- Name: user_consent; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.user_consent (
    id character varying(36) NOT NULL,
    client_id character varying(255),
    user_id character varying(36) NOT NULL,
    created_date bigint,
    last_updated_date bigint,
    client_storage_provider character varying(36),
    external_client_id character varying(255)
);


ALTER TABLE public.user_consent OWNER TO vermeg;

--
-- Name: user_consent_client_scope; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.user_consent_client_scope (
    user_consent_id character varying(36) NOT NULL,
    scope_id character varying(36) NOT NULL
);


ALTER TABLE public.user_consent_client_scope OWNER TO vermeg;

--
-- Name: user_entity; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.user_entity (
    id character varying(36) NOT NULL,
    email character varying(255),
    email_constraint character varying(255),
    email_verified boolean DEFAULT false NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    federation_link character varying(255),
    first_name character varying(255),
    last_name character varying(255),
    realm_id character varying(255),
    username character varying(255),
    created_timestamp bigint,
    service_account_client_link character varying(255),
    not_before integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.user_entity OWNER TO vermeg;

--
-- Name: user_federation_config; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.user_federation_config (
    user_federation_provider_id character varying(36) NOT NULL,
    value character varying(255),
    name character varying(255) NOT NULL
);


ALTER TABLE public.user_federation_config OWNER TO vermeg;

--
-- Name: user_federation_mapper; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.user_federation_mapper (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    federation_provider_id character varying(36) NOT NULL,
    federation_mapper_type character varying(255) NOT NULL,
    realm_id character varying(36) NOT NULL
);


ALTER TABLE public.user_federation_mapper OWNER TO vermeg;

--
-- Name: user_federation_mapper_config; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.user_federation_mapper_config (
    user_federation_mapper_id character varying(36) NOT NULL,
    value character varying(255),
    name character varying(255) NOT NULL
);


ALTER TABLE public.user_federation_mapper_config OWNER TO vermeg;

--
-- Name: user_federation_provider; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.user_federation_provider (
    id character varying(36) NOT NULL,
    changed_sync_period integer,
    display_name character varying(255),
    full_sync_period integer,
    last_sync integer,
    priority integer,
    provider_name character varying(255),
    realm_id character varying(36)
);


ALTER TABLE public.user_federation_provider OWNER TO vermeg;

--
-- Name: user_group_membership; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.user_group_membership (
    group_id character varying(36) NOT NULL,
    user_id character varying(36) NOT NULL
);


ALTER TABLE public.user_group_membership OWNER TO vermeg;

--
-- Name: user_required_action; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.user_required_action (
    user_id character varying(36) NOT NULL,
    required_action character varying(255) DEFAULT ' '::character varying NOT NULL
);


ALTER TABLE public.user_required_action OWNER TO vermeg;

--
-- Name: user_role_mapping; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.user_role_mapping (
    role_id character varying(255) NOT NULL,
    user_id character varying(36) NOT NULL
);


ALTER TABLE public.user_role_mapping OWNER TO vermeg;

--
-- Name: user_session; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.user_session (
    id character varying(36) NOT NULL,
    auth_method character varying(255),
    ip_address character varying(255),
    last_session_refresh integer,
    login_username character varying(255),
    realm_id character varying(255),
    remember_me boolean DEFAULT false NOT NULL,
    started integer,
    user_id character varying(255),
    user_session_state integer,
    broker_session_id character varying(255),
    broker_user_id character varying(255)
);


ALTER TABLE public.user_session OWNER TO vermeg;

--
-- Name: user_session_note; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.user_session_note (
    user_session character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    value character varying(2048)
);


ALTER TABLE public.user_session_note OWNER TO vermeg;

--
-- Name: username_login_failure; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.username_login_failure (
    realm_id character varying(36) NOT NULL,
    username character varying(255) NOT NULL,
    failed_login_not_before integer,
    last_failure bigint,
    last_ip_failure character varying(255),
    num_failures integer
);


ALTER TABLE public.username_login_failure OWNER TO vermeg;

--
-- Name: users; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    avatar_url text,
    city character varying(255),
    contract_type character varying(255),
    country character varying(255),
    department character varying(255),
    diploma character varying(255),
    email character varying(255) NOT NULL,
    experience character varying(255),
    full_name character varying(255) NOT NULL,
    leave_balance integer,
    manager_id bigint,
    phone character varying(255),
    "position" character varying(255),
    role character varying(255) NOT NULL,
    salary double precision,
    total_hours integer
);


ALTER TABLE public.users OWNER TO vermeg;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: vermeg
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO vermeg;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: vermeg
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: web_origins; Type: TABLE; Schema: public; Owner: vermeg
--

CREATE TABLE public.web_origins (
    client_id character varying(36) NOT NULL,
    value character varying(255) NOT NULL
);


ALTER TABLE public.web_origins OWNER TO vermeg;

--
-- Name: applications id; Type: DEFAULT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.applications ALTER COLUMN id SET DEFAULT nextval('public.applications_id_seq'::regclass);


--
-- Name: approval_decisions id; Type: DEFAULT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.approval_decisions ALTER COLUMN id SET DEFAULT nextval('public.approval_decisions_id_seq'::regclass);


--
-- Name: contract_types id; Type: DEFAULT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.contract_types ALTER COLUMN id SET DEFAULT nextval('public.contract_types_id_seq'::regclass);


--
-- Name: departments id; Type: DEFAULT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.departments ALTER COLUMN id SET DEFAULT nextval('public.departments_id_seq'::regclass);


--
-- Name: document_requests id; Type: DEFAULT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.document_requests ALTER COLUMN id SET DEFAULT nextval('public.document_requests_id_seq'::regclass);


--
-- Name: interviews id; Type: DEFAULT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.interviews ALTER COLUMN id SET DEFAULT nextval('public.interviews_id_seq'::regclass);


--
-- Name: job_offers id; Type: DEFAULT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.job_offers ALTER COLUMN id SET DEFAULT nextval('public.job_offers_id_seq'::regclass);


--
-- Name: leave_requests id; Type: DEFAULT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.leave_requests ALTER COLUMN id SET DEFAULT nextval('public.leave_requests_id_seq'::regclass);


--
-- Name: messages id; Type: DEFAULT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.messages ALTER COLUMN id SET DEFAULT nextval('public.messages_id_seq'::regclass);


--
-- Name: news id; Type: DEFAULT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.news ALTER COLUMN id SET DEFAULT nextval('public.news_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: positions id; Type: DEFAULT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.positions ALTER COLUMN id SET DEFAULT nextval('public.positions_id_seq'::regclass);


--
-- Name: salary_requests id; Type: DEFAULT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.salary_requests ALTER COLUMN id SET DEFAULT nextval('public.salary_requests_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: admin_event_entity; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.admin_event_entity (id, admin_event_time, realm_id, operation_type, auth_realm_id, auth_client_id, auth_user_id, ip_address, resource_path, representation, error, resource_type) FROM stdin;
\.


--
-- Data for Name: applications; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.applications (id, applied_at, cin_file, city, country, cover_letter, cv_file, diploma_file, email, full_name, job_id, job_title, phone, status, user_id) FROM stdin;
1	2026-04-02 12:04:23.382619	\N	Tunis	Tunisie	Je suis motive(e) et disponible rapidement.	\N	\N	candidate@vermeg.com	Camille Candidate	1	Senior Developer React	+21622333444	PENDING	9
\.


--
-- Data for Name: approval_decisions; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.approval_decisions (id, comment, decided_at, decided_by, status, target_id, target_type) FROM stdin;
\.


--
-- Data for Name: associated_policy; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.associated_policy (policy_id, associated_policy_id) FROM stdin;
\.


--
-- Data for Name: authentication_execution; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.authentication_execution (id, alias, authenticator, realm_id, flow_id, requirement, priority, authenticator_flow, auth_flow_id, auth_config) FROM stdin;
2cce7809-22eb-425c-9420-e62f6f8e19ed	\N	auth-cookie	b748fd0d-b840-453b-b49c-26b926a71139	cf004547-830f-4a07-b5fa-386cd9c7d842	2	10	f	\N	\N
9eb42f76-8168-4c16-bb81-d1507e1d3eae	\N	auth-spnego	b748fd0d-b840-453b-b49c-26b926a71139	cf004547-830f-4a07-b5fa-386cd9c7d842	3	20	f	\N	\N
60c5ec24-dec5-40a7-86ba-1283df9412e7	\N	identity-provider-redirector	b748fd0d-b840-453b-b49c-26b926a71139	cf004547-830f-4a07-b5fa-386cd9c7d842	2	25	f	\N	\N
274c4ce6-11b5-4027-9177-bc4efac739f5	\N	\N	b748fd0d-b840-453b-b49c-26b926a71139	cf004547-830f-4a07-b5fa-386cd9c7d842	2	30	t	b72806f3-2124-41b6-b3da-4e5201e2e7f6	\N
478b7c39-1dd1-45bc-80e2-c68e96f4dda5	\N	auth-username-password-form	b748fd0d-b840-453b-b49c-26b926a71139	b72806f3-2124-41b6-b3da-4e5201e2e7f6	0	10	f	\N	\N
db8e639d-647c-4a3e-9228-79948c18803b	\N	\N	b748fd0d-b840-453b-b49c-26b926a71139	b72806f3-2124-41b6-b3da-4e5201e2e7f6	1	20	t	d13bb5a7-e02d-4d4a-8ae6-9204262c76dc	\N
3b7de485-5119-44d7-8ec0-1a1cc7625ade	\N	conditional-user-configured	b748fd0d-b840-453b-b49c-26b926a71139	d13bb5a7-e02d-4d4a-8ae6-9204262c76dc	0	10	f	\N	\N
74c81ee6-f83f-4bb0-9f85-b13bc4af9bd5	\N	auth-otp-form	b748fd0d-b840-453b-b49c-26b926a71139	d13bb5a7-e02d-4d4a-8ae6-9204262c76dc	0	20	f	\N	\N
fd39f220-94b8-486b-b174-7e21686b4362	\N	direct-grant-validate-username	b748fd0d-b840-453b-b49c-26b926a71139	776caa78-f5f5-4435-8668-a0d485f5b456	0	10	f	\N	\N
91ec2db6-ab67-42df-b399-9329975f3695	\N	direct-grant-validate-password	b748fd0d-b840-453b-b49c-26b926a71139	776caa78-f5f5-4435-8668-a0d485f5b456	0	20	f	\N	\N
7863e625-5c2c-4f8f-a13a-eb940385f7bb	\N	\N	b748fd0d-b840-453b-b49c-26b926a71139	776caa78-f5f5-4435-8668-a0d485f5b456	1	30	t	c42f7490-74cb-4c8f-a01d-2a278d7a6b2d	\N
05384813-6d0d-477e-982b-e9a1ac6921f8	\N	conditional-user-configured	b748fd0d-b840-453b-b49c-26b926a71139	c42f7490-74cb-4c8f-a01d-2a278d7a6b2d	0	10	f	\N	\N
51c0c3ad-1a73-4226-b887-18605068a220	\N	direct-grant-validate-otp	b748fd0d-b840-453b-b49c-26b926a71139	c42f7490-74cb-4c8f-a01d-2a278d7a6b2d	0	20	f	\N	\N
b1a60a72-1898-48b5-aa3f-974c84cf15c7	\N	registration-page-form	b748fd0d-b840-453b-b49c-26b926a71139	fda073a3-8ba9-4d8e-892a-c133e9f5966b	0	10	t	2ad1720d-f1ff-49b9-bbc1-8065d0596407	\N
c046b7d7-309d-4089-8668-4ca93101ca57	\N	registration-user-creation	b748fd0d-b840-453b-b49c-26b926a71139	2ad1720d-f1ff-49b9-bbc1-8065d0596407	0	20	f	\N	\N
e0f2496e-f1ca-40fc-90ad-c321413af54f	\N	registration-password-action	b748fd0d-b840-453b-b49c-26b926a71139	2ad1720d-f1ff-49b9-bbc1-8065d0596407	0	50	f	\N	\N
f4b4e1ac-8aa4-4df1-9e55-d9cf47bae34e	\N	registration-recaptcha-action	b748fd0d-b840-453b-b49c-26b926a71139	2ad1720d-f1ff-49b9-bbc1-8065d0596407	3	60	f	\N	\N
efa01b2b-b8d3-4841-8fed-f0dbb685900f	\N	registration-terms-and-conditions	b748fd0d-b840-453b-b49c-26b926a71139	2ad1720d-f1ff-49b9-bbc1-8065d0596407	3	70	f	\N	\N
f30dc9bd-7ab7-433b-8ac8-3fb32bf0881d	\N	reset-credentials-choose-user	b748fd0d-b840-453b-b49c-26b926a71139	a7a23995-0f05-4882-98e3-951595cb264f	0	10	f	\N	\N
1336c4e4-1c2e-49d6-91b5-7221bc648a06	\N	reset-credential-email	b748fd0d-b840-453b-b49c-26b926a71139	a7a23995-0f05-4882-98e3-951595cb264f	0	20	f	\N	\N
de6995d9-de82-4377-a7ef-49b9005c8489	\N	reset-password	b748fd0d-b840-453b-b49c-26b926a71139	a7a23995-0f05-4882-98e3-951595cb264f	0	30	f	\N	\N
18a07b48-20e3-4d77-bfb3-cbd4b63c460f	\N	\N	b748fd0d-b840-453b-b49c-26b926a71139	a7a23995-0f05-4882-98e3-951595cb264f	1	40	t	4d0b96e2-1b01-4d2c-8987-2f763bc84512	\N
653e27cb-1c67-455c-9229-01c40b79575c	\N	conditional-user-configured	b748fd0d-b840-453b-b49c-26b926a71139	4d0b96e2-1b01-4d2c-8987-2f763bc84512	0	10	f	\N	\N
5a7f8c45-e669-4764-afc9-5e518b103da6	\N	reset-otp	b748fd0d-b840-453b-b49c-26b926a71139	4d0b96e2-1b01-4d2c-8987-2f763bc84512	0	20	f	\N	\N
69544aad-60ca-4e22-9f04-62016e5db767	\N	client-secret	b748fd0d-b840-453b-b49c-26b926a71139	72229a16-9d72-4c05-a5be-ece0ba7e1b56	2	10	f	\N	\N
5ad86ddf-f5e4-4ea8-b12e-eae32696394e	\N	client-jwt	b748fd0d-b840-453b-b49c-26b926a71139	72229a16-9d72-4c05-a5be-ece0ba7e1b56	2	20	f	\N	\N
ce3b7394-b077-4b30-a14e-073451350929	\N	client-secret-jwt	b748fd0d-b840-453b-b49c-26b926a71139	72229a16-9d72-4c05-a5be-ece0ba7e1b56	2	30	f	\N	\N
6104d78f-88b3-4b35-b6bd-84d2ce912b8d	\N	client-x509	b748fd0d-b840-453b-b49c-26b926a71139	72229a16-9d72-4c05-a5be-ece0ba7e1b56	2	40	f	\N	\N
d34eee47-5ca7-4083-9939-484934ec640a	\N	idp-review-profile	b748fd0d-b840-453b-b49c-26b926a71139	d253edf1-2667-4235-bf75-c042ac7923d8	0	10	f	\N	dd39ccab-5428-44f5-a942-3de1b1a94d22
4cade93b-caa3-4125-b806-8f3c5e02a22b	\N	\N	b748fd0d-b840-453b-b49c-26b926a71139	d253edf1-2667-4235-bf75-c042ac7923d8	0	20	t	76d08a9d-74bd-4866-babe-c8889bf2430b	\N
99545972-587f-44d6-9e52-550637cb7b0d	\N	idp-create-user-if-unique	b748fd0d-b840-453b-b49c-26b926a71139	76d08a9d-74bd-4866-babe-c8889bf2430b	2	10	f	\N	c6894a7d-7988-4b0f-bfdc-76d6179161d8
fd251585-b6bc-4db8-a6d1-ec56faf48e3b	\N	\N	b748fd0d-b840-453b-b49c-26b926a71139	76d08a9d-74bd-4866-babe-c8889bf2430b	2	20	t	f397bb2a-aaf9-4445-881a-c417a8aa5de1	\N
f16cf059-72c4-4c16-8666-0a60464792d4	\N	idp-confirm-link	b748fd0d-b840-453b-b49c-26b926a71139	f397bb2a-aaf9-4445-881a-c417a8aa5de1	0	10	f	\N	\N
366481be-85c0-4dfc-ab9b-35140c6de894	\N	\N	b748fd0d-b840-453b-b49c-26b926a71139	f397bb2a-aaf9-4445-881a-c417a8aa5de1	0	20	t	6c2ab40f-2834-47a9-b277-2621c65fd67f	\N
8c1e7b83-0745-41d7-9d41-c7aedf94aa40	\N	idp-email-verification	b748fd0d-b840-453b-b49c-26b926a71139	6c2ab40f-2834-47a9-b277-2621c65fd67f	2	10	f	\N	\N
57e4564f-669c-460f-a5f9-01e138d34048	\N	\N	b748fd0d-b840-453b-b49c-26b926a71139	6c2ab40f-2834-47a9-b277-2621c65fd67f	2	20	t	f03b8b25-4326-47ee-909e-fe086611961a	\N
41a4fbb3-3db8-4d9f-9e8f-e59fcf4ea0e1	\N	idp-username-password-form	b748fd0d-b840-453b-b49c-26b926a71139	f03b8b25-4326-47ee-909e-fe086611961a	0	10	f	\N	\N
f70aff18-2f75-420c-8088-4073703f1339	\N	\N	b748fd0d-b840-453b-b49c-26b926a71139	f03b8b25-4326-47ee-909e-fe086611961a	1	20	t	0742e2b3-363c-43f1-9854-bd1ec03d48a1	\N
7726b603-f0db-459f-aed9-c417639bb611	\N	conditional-user-configured	b748fd0d-b840-453b-b49c-26b926a71139	0742e2b3-363c-43f1-9854-bd1ec03d48a1	0	10	f	\N	\N
3b5c78f6-a8ff-4905-a8b6-4c8ee378141d	\N	auth-otp-form	b748fd0d-b840-453b-b49c-26b926a71139	0742e2b3-363c-43f1-9854-bd1ec03d48a1	0	20	f	\N	\N
b294e78b-08b2-4a52-b525-0c2b8481c054	\N	http-basic-authenticator	b748fd0d-b840-453b-b49c-26b926a71139	fa33888b-4c60-4c94-9beb-3d813d81d430	0	10	f	\N	\N
a71ccbc9-e5d8-4d54-bf46-1693ee49cf42	\N	docker-http-basic-authenticator	b748fd0d-b840-453b-b49c-26b926a71139	c0c1525f-0937-494b-aab6-fa8e02539bf3	0	10	f	\N	\N
1c09777d-739a-4143-9159-8f89b0ac1945	\N	auth-cookie	354b9070-b2b9-4f85-9ab1-d7b290304732	66a70324-e6d8-4619-928c-7868e7322f0e	2	10	f	\N	\N
a15d5a06-6812-4bcb-a634-3196b6f8f7dd	\N	auth-spnego	354b9070-b2b9-4f85-9ab1-d7b290304732	66a70324-e6d8-4619-928c-7868e7322f0e	3	20	f	\N	\N
b73390f2-ce44-4082-b8be-b82d854ead97	\N	identity-provider-redirector	354b9070-b2b9-4f85-9ab1-d7b290304732	66a70324-e6d8-4619-928c-7868e7322f0e	2	25	f	\N	\N
fb8a3a3b-16e4-4552-b693-c768863092b7	\N	\N	354b9070-b2b9-4f85-9ab1-d7b290304732	66a70324-e6d8-4619-928c-7868e7322f0e	2	30	t	e51a3e8c-9b50-426c-a4b7-9f19b48eb4b9	\N
c1c61f06-9334-45d0-ad2a-8734d4a306c5	\N	auth-username-password-form	354b9070-b2b9-4f85-9ab1-d7b290304732	e51a3e8c-9b50-426c-a4b7-9f19b48eb4b9	0	10	f	\N	\N
26860ff5-3710-4953-99e6-c7710a826412	\N	\N	354b9070-b2b9-4f85-9ab1-d7b290304732	e51a3e8c-9b50-426c-a4b7-9f19b48eb4b9	1	20	t	d4a910fd-288b-475a-901e-2dae7216819a	\N
ab8ba290-9d39-4371-84e6-5f714f1ee860	\N	conditional-user-configured	354b9070-b2b9-4f85-9ab1-d7b290304732	d4a910fd-288b-475a-901e-2dae7216819a	0	10	f	\N	\N
bf2c7f82-ebd6-4237-baa2-c66c032bfc44	\N	auth-otp-form	354b9070-b2b9-4f85-9ab1-d7b290304732	d4a910fd-288b-475a-901e-2dae7216819a	0	20	f	\N	\N
0ff352a7-ee97-48ee-b069-5e226dd51d8a	\N	direct-grant-validate-username	354b9070-b2b9-4f85-9ab1-d7b290304732	a6038308-cc02-49b9-9c2b-c664c0f31a7c	0	10	f	\N	\N
a42fd864-6d27-46f3-9931-24d2db56e1b1	\N	direct-grant-validate-password	354b9070-b2b9-4f85-9ab1-d7b290304732	a6038308-cc02-49b9-9c2b-c664c0f31a7c	0	20	f	\N	\N
af04e9ee-82b2-4e89-8fbe-d2e7a0f37f40	\N	\N	354b9070-b2b9-4f85-9ab1-d7b290304732	a6038308-cc02-49b9-9c2b-c664c0f31a7c	1	30	t	e0acf3e8-469a-471d-b6a5-f22325881e02	\N
da1e6775-0066-4247-a601-fa8ba1b9a3f6	\N	conditional-user-configured	354b9070-b2b9-4f85-9ab1-d7b290304732	e0acf3e8-469a-471d-b6a5-f22325881e02	0	10	f	\N	\N
4def6293-7a6a-4ab9-b3d1-86e9da87c50c	\N	direct-grant-validate-otp	354b9070-b2b9-4f85-9ab1-d7b290304732	e0acf3e8-469a-471d-b6a5-f22325881e02	0	20	f	\N	\N
63fa65b6-bb7d-4a39-a90e-01cdf7fbbfe1	\N	registration-page-form	354b9070-b2b9-4f85-9ab1-d7b290304732	1a5b2e92-b2e0-4f78-98fb-539431b029fe	0	10	t	ecd00ac4-815d-407c-9003-a5be8e3c30d2	\N
fd90b544-7751-4efd-9fa0-dbd2f657f379	\N	registration-user-creation	354b9070-b2b9-4f85-9ab1-d7b290304732	ecd00ac4-815d-407c-9003-a5be8e3c30d2	0	20	f	\N	\N
034dafca-010b-4971-a92b-40b296ab776f	\N	registration-password-action	354b9070-b2b9-4f85-9ab1-d7b290304732	ecd00ac4-815d-407c-9003-a5be8e3c30d2	0	50	f	\N	\N
a0fb1cef-469c-4f62-a88c-5bdb98dc4d4e	\N	registration-recaptcha-action	354b9070-b2b9-4f85-9ab1-d7b290304732	ecd00ac4-815d-407c-9003-a5be8e3c30d2	3	60	f	\N	\N
4ecc2ff1-9bd3-42d2-9a7c-fb06d6265a78	\N	registration-terms-and-conditions	354b9070-b2b9-4f85-9ab1-d7b290304732	ecd00ac4-815d-407c-9003-a5be8e3c30d2	3	70	f	\N	\N
faecf6a1-15b1-4238-9f7a-b0638b182708	\N	reset-credentials-choose-user	354b9070-b2b9-4f85-9ab1-d7b290304732	0ad663f0-8f1b-47ad-8731-5fa954b247bb	0	10	f	\N	\N
c04e7412-ae69-4fca-bdc0-7df9a4776e32	\N	reset-credential-email	354b9070-b2b9-4f85-9ab1-d7b290304732	0ad663f0-8f1b-47ad-8731-5fa954b247bb	0	20	f	\N	\N
73b1e045-02d4-4275-a3fe-31c130eb3ba5	\N	reset-password	354b9070-b2b9-4f85-9ab1-d7b290304732	0ad663f0-8f1b-47ad-8731-5fa954b247bb	0	30	f	\N	\N
9de2b08a-8c27-4f0a-8292-155900bc48ef	\N	\N	354b9070-b2b9-4f85-9ab1-d7b290304732	0ad663f0-8f1b-47ad-8731-5fa954b247bb	1	40	t	27dd2d19-b797-4aa8-bc84-85611e8007f8	\N
c0c932d7-6f5a-4061-bb17-ee222f9659be	\N	conditional-user-configured	354b9070-b2b9-4f85-9ab1-d7b290304732	27dd2d19-b797-4aa8-bc84-85611e8007f8	0	10	f	\N	\N
dc74b087-90c5-4cca-9e40-7ec2076ce687	\N	reset-otp	354b9070-b2b9-4f85-9ab1-d7b290304732	27dd2d19-b797-4aa8-bc84-85611e8007f8	0	20	f	\N	\N
5d71bf6e-f7ed-4ec7-a855-dab298432681	\N	client-secret	354b9070-b2b9-4f85-9ab1-d7b290304732	213f336e-969e-4ae9-9030-9463713396df	2	10	f	\N	\N
767e1f16-5ae6-4bdf-b97e-ec6b5f4b02c6	\N	client-jwt	354b9070-b2b9-4f85-9ab1-d7b290304732	213f336e-969e-4ae9-9030-9463713396df	2	20	f	\N	\N
ef419b78-754f-4c34-86b9-8591aa32c4b2	\N	client-secret-jwt	354b9070-b2b9-4f85-9ab1-d7b290304732	213f336e-969e-4ae9-9030-9463713396df	2	30	f	\N	\N
bfd007c1-49e7-4d88-83b7-8cf5fd2128c3	\N	client-x509	354b9070-b2b9-4f85-9ab1-d7b290304732	213f336e-969e-4ae9-9030-9463713396df	2	40	f	\N	\N
d91c7dc2-4926-4b30-bf01-265419f94b27	\N	idp-review-profile	354b9070-b2b9-4f85-9ab1-d7b290304732	04a11733-be63-45d0-aba3-d9e29cea5b3d	0	10	f	\N	95309187-3990-43a7-9446-6ee8f551d5d1
fc5658c9-1d7d-46fb-b7ef-8e356594f255	\N	\N	354b9070-b2b9-4f85-9ab1-d7b290304732	04a11733-be63-45d0-aba3-d9e29cea5b3d	0	20	t	308d7d56-eb19-45a7-aebb-9c524539f6de	\N
656f925f-e399-4738-a203-b3d20052ea3b	\N	idp-create-user-if-unique	354b9070-b2b9-4f85-9ab1-d7b290304732	308d7d56-eb19-45a7-aebb-9c524539f6de	2	10	f	\N	2186d350-1e10-4d87-9464-5ced2dd815e5
ab3a2823-9663-4a14-9157-9f97610e6599	\N	\N	354b9070-b2b9-4f85-9ab1-d7b290304732	308d7d56-eb19-45a7-aebb-9c524539f6de	2	20	t	f231b601-1fb8-4e24-b3a7-843f2e81e408	\N
cff1c783-cee9-4414-9de9-23b96e8d9dea	\N	idp-confirm-link	354b9070-b2b9-4f85-9ab1-d7b290304732	f231b601-1fb8-4e24-b3a7-843f2e81e408	0	10	f	\N	\N
60e830ba-4b7f-483e-9999-9cf9467cfa44	\N	\N	354b9070-b2b9-4f85-9ab1-d7b290304732	f231b601-1fb8-4e24-b3a7-843f2e81e408	0	20	t	98ed531c-4f83-4a9d-8d95-2b8e065b608d	\N
4cf79896-7230-43ca-9df7-992d4edf6885	\N	idp-email-verification	354b9070-b2b9-4f85-9ab1-d7b290304732	98ed531c-4f83-4a9d-8d95-2b8e065b608d	2	10	f	\N	\N
d575bde5-ec47-4f06-8a2f-58e07ff13ece	\N	\N	354b9070-b2b9-4f85-9ab1-d7b290304732	98ed531c-4f83-4a9d-8d95-2b8e065b608d	2	20	t	a507c495-1060-4e0e-af93-da4e8bf8082c	\N
5b646788-6144-4516-b91a-3ac70ef5a326	\N	idp-username-password-form	354b9070-b2b9-4f85-9ab1-d7b290304732	a507c495-1060-4e0e-af93-da4e8bf8082c	0	10	f	\N	\N
3f482264-0daf-4b85-b3af-d432873816a1	\N	\N	354b9070-b2b9-4f85-9ab1-d7b290304732	a507c495-1060-4e0e-af93-da4e8bf8082c	1	20	t	f40817d7-7b1a-423e-844b-473b97790567	\N
f1e79ecb-68ee-45e5-aeab-da4aeca036e1	\N	conditional-user-configured	354b9070-b2b9-4f85-9ab1-d7b290304732	f40817d7-7b1a-423e-844b-473b97790567	0	10	f	\N	\N
9763b7cc-392c-4aef-8b23-bf030dbb69f5	\N	auth-otp-form	354b9070-b2b9-4f85-9ab1-d7b290304732	f40817d7-7b1a-423e-844b-473b97790567	0	20	f	\N	\N
be754b21-288a-4818-94ad-3601b0417f6f	\N	http-basic-authenticator	354b9070-b2b9-4f85-9ab1-d7b290304732	e7ab29f2-79fc-418f-a620-6c692c90aa98	0	10	f	\N	\N
1f1d676e-892a-4c9f-b658-dfe7a1c47f54	\N	docker-http-basic-authenticator	354b9070-b2b9-4f85-9ab1-d7b290304732	281effda-308a-4658-9c7f-7919121c4df7	0	10	f	\N	\N
\.


--
-- Data for Name: authentication_flow; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.authentication_flow (id, alias, description, realm_id, provider_id, top_level, built_in) FROM stdin;
cf004547-830f-4a07-b5fa-386cd9c7d842	browser	browser based authentication	b748fd0d-b840-453b-b49c-26b926a71139	basic-flow	t	t
b72806f3-2124-41b6-b3da-4e5201e2e7f6	forms	Username, password, otp and other auth forms.	b748fd0d-b840-453b-b49c-26b926a71139	basic-flow	f	t
d13bb5a7-e02d-4d4a-8ae6-9204262c76dc	Browser - Conditional OTP	Flow to determine if the OTP is required for the authentication	b748fd0d-b840-453b-b49c-26b926a71139	basic-flow	f	t
776caa78-f5f5-4435-8668-a0d485f5b456	direct grant	OpenID Connect Resource Owner Grant	b748fd0d-b840-453b-b49c-26b926a71139	basic-flow	t	t
c42f7490-74cb-4c8f-a01d-2a278d7a6b2d	Direct Grant - Conditional OTP	Flow to determine if the OTP is required for the authentication	b748fd0d-b840-453b-b49c-26b926a71139	basic-flow	f	t
fda073a3-8ba9-4d8e-892a-c133e9f5966b	registration	registration flow	b748fd0d-b840-453b-b49c-26b926a71139	basic-flow	t	t
2ad1720d-f1ff-49b9-bbc1-8065d0596407	registration form	registration form	b748fd0d-b840-453b-b49c-26b926a71139	form-flow	f	t
a7a23995-0f05-4882-98e3-951595cb264f	reset credentials	Reset credentials for a user if they forgot their password or something	b748fd0d-b840-453b-b49c-26b926a71139	basic-flow	t	t
4d0b96e2-1b01-4d2c-8987-2f763bc84512	Reset - Conditional OTP	Flow to determine if the OTP should be reset or not. Set to REQUIRED to force.	b748fd0d-b840-453b-b49c-26b926a71139	basic-flow	f	t
72229a16-9d72-4c05-a5be-ece0ba7e1b56	clients	Base authentication for clients	b748fd0d-b840-453b-b49c-26b926a71139	client-flow	t	t
d253edf1-2667-4235-bf75-c042ac7923d8	first broker login	Actions taken after first broker login with identity provider account, which is not yet linked to any Keycloak account	b748fd0d-b840-453b-b49c-26b926a71139	basic-flow	t	t
76d08a9d-74bd-4866-babe-c8889bf2430b	User creation or linking	Flow for the existing/non-existing user alternatives	b748fd0d-b840-453b-b49c-26b926a71139	basic-flow	f	t
f397bb2a-aaf9-4445-881a-c417a8aa5de1	Handle Existing Account	Handle what to do if there is existing account with same email/username like authenticated identity provider	b748fd0d-b840-453b-b49c-26b926a71139	basic-flow	f	t
6c2ab40f-2834-47a9-b277-2621c65fd67f	Account verification options	Method with which to verity the existing account	b748fd0d-b840-453b-b49c-26b926a71139	basic-flow	f	t
f03b8b25-4326-47ee-909e-fe086611961a	Verify Existing Account by Re-authentication	Reauthentication of existing account	b748fd0d-b840-453b-b49c-26b926a71139	basic-flow	f	t
0742e2b3-363c-43f1-9854-bd1ec03d48a1	First broker login - Conditional OTP	Flow to determine if the OTP is required for the authentication	b748fd0d-b840-453b-b49c-26b926a71139	basic-flow	f	t
fa33888b-4c60-4c94-9beb-3d813d81d430	saml ecp	SAML ECP Profile Authentication Flow	b748fd0d-b840-453b-b49c-26b926a71139	basic-flow	t	t
c0c1525f-0937-494b-aab6-fa8e02539bf3	docker auth	Used by Docker clients to authenticate against the IDP	b748fd0d-b840-453b-b49c-26b926a71139	basic-flow	t	t
66a70324-e6d8-4619-928c-7868e7322f0e	browser	browser based authentication	354b9070-b2b9-4f85-9ab1-d7b290304732	basic-flow	t	t
e51a3e8c-9b50-426c-a4b7-9f19b48eb4b9	forms	Username, password, otp and other auth forms.	354b9070-b2b9-4f85-9ab1-d7b290304732	basic-flow	f	t
d4a910fd-288b-475a-901e-2dae7216819a	Browser - Conditional OTP	Flow to determine if the OTP is required for the authentication	354b9070-b2b9-4f85-9ab1-d7b290304732	basic-flow	f	t
a6038308-cc02-49b9-9c2b-c664c0f31a7c	direct grant	OpenID Connect Resource Owner Grant	354b9070-b2b9-4f85-9ab1-d7b290304732	basic-flow	t	t
e0acf3e8-469a-471d-b6a5-f22325881e02	Direct Grant - Conditional OTP	Flow to determine if the OTP is required for the authentication	354b9070-b2b9-4f85-9ab1-d7b290304732	basic-flow	f	t
1a5b2e92-b2e0-4f78-98fb-539431b029fe	registration	registration flow	354b9070-b2b9-4f85-9ab1-d7b290304732	basic-flow	t	t
ecd00ac4-815d-407c-9003-a5be8e3c30d2	registration form	registration form	354b9070-b2b9-4f85-9ab1-d7b290304732	form-flow	f	t
0ad663f0-8f1b-47ad-8731-5fa954b247bb	reset credentials	Reset credentials for a user if they forgot their password or something	354b9070-b2b9-4f85-9ab1-d7b290304732	basic-flow	t	t
27dd2d19-b797-4aa8-bc84-85611e8007f8	Reset - Conditional OTP	Flow to determine if the OTP should be reset or not. Set to REQUIRED to force.	354b9070-b2b9-4f85-9ab1-d7b290304732	basic-flow	f	t
213f336e-969e-4ae9-9030-9463713396df	clients	Base authentication for clients	354b9070-b2b9-4f85-9ab1-d7b290304732	client-flow	t	t
04a11733-be63-45d0-aba3-d9e29cea5b3d	first broker login	Actions taken after first broker login with identity provider account, which is not yet linked to any Keycloak account	354b9070-b2b9-4f85-9ab1-d7b290304732	basic-flow	t	t
308d7d56-eb19-45a7-aebb-9c524539f6de	User creation or linking	Flow for the existing/non-existing user alternatives	354b9070-b2b9-4f85-9ab1-d7b290304732	basic-flow	f	t
f231b601-1fb8-4e24-b3a7-843f2e81e408	Handle Existing Account	Handle what to do if there is existing account with same email/username like authenticated identity provider	354b9070-b2b9-4f85-9ab1-d7b290304732	basic-flow	f	t
98ed531c-4f83-4a9d-8d95-2b8e065b608d	Account verification options	Method with which to verity the existing account	354b9070-b2b9-4f85-9ab1-d7b290304732	basic-flow	f	t
a507c495-1060-4e0e-af93-da4e8bf8082c	Verify Existing Account by Re-authentication	Reauthentication of existing account	354b9070-b2b9-4f85-9ab1-d7b290304732	basic-flow	f	t
f40817d7-7b1a-423e-844b-473b97790567	First broker login - Conditional OTP	Flow to determine if the OTP is required for the authentication	354b9070-b2b9-4f85-9ab1-d7b290304732	basic-flow	f	t
e7ab29f2-79fc-418f-a620-6c692c90aa98	saml ecp	SAML ECP Profile Authentication Flow	354b9070-b2b9-4f85-9ab1-d7b290304732	basic-flow	t	t
281effda-308a-4658-9c7f-7919121c4df7	docker auth	Used by Docker clients to authenticate against the IDP	354b9070-b2b9-4f85-9ab1-d7b290304732	basic-flow	t	t
\.


--
-- Data for Name: authenticator_config; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.authenticator_config (id, alias, realm_id) FROM stdin;
dd39ccab-5428-44f5-a942-3de1b1a94d22	review profile config	b748fd0d-b840-453b-b49c-26b926a71139
c6894a7d-7988-4b0f-bfdc-76d6179161d8	create unique user config	b748fd0d-b840-453b-b49c-26b926a71139
95309187-3990-43a7-9446-6ee8f551d5d1	review profile config	354b9070-b2b9-4f85-9ab1-d7b290304732
2186d350-1e10-4d87-9464-5ced2dd815e5	create unique user config	354b9070-b2b9-4f85-9ab1-d7b290304732
\.


--
-- Data for Name: authenticator_config_entry; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.authenticator_config_entry (authenticator_id, value, name) FROM stdin;
c6894a7d-7988-4b0f-bfdc-76d6179161d8	false	require.password.update.after.registration
dd39ccab-5428-44f5-a942-3de1b1a94d22	missing	update.profile.on.first.login
2186d350-1e10-4d87-9464-5ced2dd815e5	false	require.password.update.after.registration
95309187-3990-43a7-9446-6ee8f551d5d1	missing	update.profile.on.first.login
\.


--
-- Data for Name: broker_link; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.broker_link (identity_provider, storage_provider_id, realm_id, broker_user_id, broker_username, token, user_id) FROM stdin;
\.


--
-- Data for Name: client; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.client (id, enabled, full_scope_allowed, client_id, not_before, public_client, secret, base_url, bearer_only, management_url, surrogate_auth_required, realm_id, protocol, node_rereg_timeout, frontchannel_logout, consent_required, name, service_accounts_enabled, client_authenticator_type, root_url, description, registration_token, standard_flow_enabled, implicit_flow_enabled, direct_access_grants_enabled, always_display_in_console) FROM stdin;
8555aea4-b785-4d79-996c-47e79ebae943	t	f	master-realm	0	f	\N	\N	t	\N	f	b748fd0d-b840-453b-b49c-26b926a71139	\N	0	f	f	master Realm	f	client-secret	\N	\N	\N	t	f	f	f
4d54aa61-2812-4233-b6c8-1c148de24706	t	f	account	0	t	\N	/realms/master/account/	f	\N	f	b748fd0d-b840-453b-b49c-26b926a71139	openid-connect	0	f	f	${client_account}	f	client-secret	${authBaseUrl}	\N	\N	t	f	f	f
fcf80481-f9c8-44c6-8f42-0523de9bbcc6	t	f	account-console	0	t	\N	/realms/master/account/	f	\N	f	b748fd0d-b840-453b-b49c-26b926a71139	openid-connect	0	f	f	${client_account-console}	f	client-secret	${authBaseUrl}	\N	\N	t	f	f	f
fa9e8401-1be7-4a56-a0b0-52dad2195303	t	f	broker	0	f	\N	\N	t	\N	f	b748fd0d-b840-453b-b49c-26b926a71139	openid-connect	0	f	f	${client_broker}	f	client-secret	\N	\N	\N	t	f	f	f
2c39f546-574c-436f-bd84-c217e5de074c	t	f	security-admin-console	0	t	\N	/admin/master/console/	f	\N	f	b748fd0d-b840-453b-b49c-26b926a71139	openid-connect	0	f	f	${client_security-admin-console}	f	client-secret	${authAdminUrl}	\N	\N	t	f	f	f
41267829-dba6-4ceb-9fa5-41fc3e4c9b32	t	f	admin-cli	0	t	\N	\N	f	\N	f	b748fd0d-b840-453b-b49c-26b926a71139	openid-connect	0	f	f	${client_admin-cli}	f	client-secret	\N	\N	\N	f	f	t	f
96861af9-57ec-4594-9587-dd4defa93b53	t	f	vermeg-sirh-realm	0	f	\N	\N	t	\N	f	b748fd0d-b840-453b-b49c-26b926a71139	\N	0	f	f	vermeg-sirh Realm	f	client-secret	\N	\N	\N	t	f	f	f
13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	t	f	realm-management	0	f	\N	\N	t	\N	f	354b9070-b2b9-4f85-9ab1-d7b290304732	openid-connect	0	f	f	${client_realm-management}	f	client-secret	\N	\N	\N	t	f	f	f
321503d7-7ad4-4062-a43b-6ed10dde5585	t	f	account	0	t	\N	/realms/vermeg-sirh/account/	f	\N	f	354b9070-b2b9-4f85-9ab1-d7b290304732	openid-connect	0	f	f	${client_account}	f	client-secret	${authBaseUrl}	\N	\N	t	f	f	f
a128520c-0fb1-4780-b35f-0a42e859e46d	t	f	account-console	0	t	\N	/realms/vermeg-sirh/account/	f	\N	f	354b9070-b2b9-4f85-9ab1-d7b290304732	openid-connect	0	f	f	${client_account-console}	f	client-secret	${authBaseUrl}	\N	\N	t	f	f	f
09cea9d8-680c-458a-8b61-4560b5831997	t	f	broker	0	f	\N	\N	t	\N	f	354b9070-b2b9-4f85-9ab1-d7b290304732	openid-connect	0	f	f	${client_broker}	f	client-secret	\N	\N	\N	t	f	f	f
fa8f3487-99ca-4e48-aca6-c706a7949899	t	f	security-admin-console	0	t	\N	/admin/vermeg-sirh/console/	f	\N	f	354b9070-b2b9-4f85-9ab1-d7b290304732	openid-connect	0	f	f	${client_security-admin-console}	f	client-secret	${authAdminUrl}	\N	\N	t	f	f	f
a79305b9-7053-459c-803c-fc4e046cded8	t	f	admin-cli	0	t	\N	\N	f	\N	f	354b9070-b2b9-4f85-9ab1-d7b290304732	openid-connect	0	f	f	${client_admin-cli}	f	client-secret	\N	\N	\N	f	f	t	f
65312025-7a16-4921-843b-47c7a1f5fc29	t	t	sirh-frontend	0	t	\N	\N	f	\N	f	354b9070-b2b9-4f85-9ab1-d7b290304732	openid-connect	-1	f	f	SIRH Frontend SPA	f	client-secret	\N	\N	\N	t	f	t	f
\.


--
-- Data for Name: client_attributes; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.client_attributes (client_id, name, value) FROM stdin;
4d54aa61-2812-4233-b6c8-1c148de24706	post.logout.redirect.uris	+
fcf80481-f9c8-44c6-8f42-0523de9bbcc6	post.logout.redirect.uris	+
fcf80481-f9c8-44c6-8f42-0523de9bbcc6	pkce.code.challenge.method	S256
2c39f546-574c-436f-bd84-c217e5de074c	post.logout.redirect.uris	+
2c39f546-574c-436f-bd84-c217e5de074c	pkce.code.challenge.method	S256
321503d7-7ad4-4062-a43b-6ed10dde5585	post.logout.redirect.uris	+
a128520c-0fb1-4780-b35f-0a42e859e46d	post.logout.redirect.uris	+
a128520c-0fb1-4780-b35f-0a42e859e46d	pkce.code.challenge.method	S256
fa8f3487-99ca-4e48-aca6-c706a7949899	post.logout.redirect.uris	+
fa8f3487-99ca-4e48-aca6-c706a7949899	pkce.code.challenge.method	S256
65312025-7a16-4921-843b-47c7a1f5fc29	pkce.code.challenge.method	S256
65312025-7a16-4921-843b-47c7a1f5fc29	post.logout.redirect.uris	+
\.


--
-- Data for Name: client_auth_flow_bindings; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.client_auth_flow_bindings (client_id, flow_id, binding_name) FROM stdin;
\.


--
-- Data for Name: client_initial_access; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.client_initial_access (id, realm_id, "timestamp", expiration, count, remaining_count) FROM stdin;
\.


--
-- Data for Name: client_node_registrations; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.client_node_registrations (client_id, value, name) FROM stdin;
\.


--
-- Data for Name: client_scope; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.client_scope (id, name, realm_id, description, protocol) FROM stdin;
5d094eff-5a40-456a-894b-8ce13fc7e43c	offline_access	b748fd0d-b840-453b-b49c-26b926a71139	OpenID Connect built-in scope: offline_access	openid-connect
e2130823-4219-425a-a272-a14ed23d6806	role_list	b748fd0d-b840-453b-b49c-26b926a71139	SAML role list	saml
2a81b3f6-1bcd-4fd8-b1ff-a55257bd8f3b	profile	b748fd0d-b840-453b-b49c-26b926a71139	OpenID Connect built-in scope: profile	openid-connect
aefd8acf-d41a-4d8a-9d3b-ceb0e6257a8b	email	b748fd0d-b840-453b-b49c-26b926a71139	OpenID Connect built-in scope: email	openid-connect
76c38eef-9683-4ad4-abb1-62c411d8c0dd	address	b748fd0d-b840-453b-b49c-26b926a71139	OpenID Connect built-in scope: address	openid-connect
0f22a8f2-72ab-46a7-b4fc-d321263fba76	phone	b748fd0d-b840-453b-b49c-26b926a71139	OpenID Connect built-in scope: phone	openid-connect
bc820279-57ae-419f-b290-6e886c2c2502	roles	b748fd0d-b840-453b-b49c-26b926a71139	OpenID Connect scope for add user roles to the access token	openid-connect
ac5426d1-f8da-4529-a9aa-713219ebdd8e	web-origins	b748fd0d-b840-453b-b49c-26b926a71139	OpenID Connect scope for add allowed web origins to the access token	openid-connect
fea7a210-49f2-4e8d-a2ad-fd08c415ed7c	microprofile-jwt	b748fd0d-b840-453b-b49c-26b926a71139	Microprofile - JWT built-in scope	openid-connect
b6ff3e04-8e0f-450a-aa13-5b158e1669af	acr	b748fd0d-b840-453b-b49c-26b926a71139	OpenID Connect scope for add acr (authentication context class reference) to the token	openid-connect
cf92c41a-2e84-4f45-9655-f77f1a0ea142	offline_access	354b9070-b2b9-4f85-9ab1-d7b290304732	OpenID Connect built-in scope: offline_access	openid-connect
49244ffb-76db-4607-ae9a-5f737125fa46	role_list	354b9070-b2b9-4f85-9ab1-d7b290304732	SAML role list	saml
576b8764-4e94-43c7-a71a-ac0022afd84c	profile	354b9070-b2b9-4f85-9ab1-d7b290304732	OpenID Connect built-in scope: profile	openid-connect
51eac524-dce3-40a2-9bd8-6d7162329b1d	email	354b9070-b2b9-4f85-9ab1-d7b290304732	OpenID Connect built-in scope: email	openid-connect
89f6de5e-7858-4e9c-ab55-44a2e3f109ca	address	354b9070-b2b9-4f85-9ab1-d7b290304732	OpenID Connect built-in scope: address	openid-connect
c8723907-0f2d-424b-ba90-b8e1112972c3	phone	354b9070-b2b9-4f85-9ab1-d7b290304732	OpenID Connect built-in scope: phone	openid-connect
995c67d6-07ed-4025-8c59-77adc190a6fa	roles	354b9070-b2b9-4f85-9ab1-d7b290304732	OpenID Connect scope for add user roles to the access token	openid-connect
a568d36b-4bf3-4fee-95c8-77589d1936b7	web-origins	354b9070-b2b9-4f85-9ab1-d7b290304732	OpenID Connect scope for add allowed web origins to the access token	openid-connect
dd280499-0b11-41ee-99a8-ed93e95a46d1	microprofile-jwt	354b9070-b2b9-4f85-9ab1-d7b290304732	Microprofile - JWT built-in scope	openid-connect
1a5bb211-b22b-4f03-a4d2-c06cbf603379	acr	354b9070-b2b9-4f85-9ab1-d7b290304732	OpenID Connect scope for add acr (authentication context class reference) to the token	openid-connect
\.


--
-- Data for Name: client_scope_attributes; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.client_scope_attributes (scope_id, value, name) FROM stdin;
5d094eff-5a40-456a-894b-8ce13fc7e43c	true	display.on.consent.screen
5d094eff-5a40-456a-894b-8ce13fc7e43c	${offlineAccessScopeConsentText}	consent.screen.text
e2130823-4219-425a-a272-a14ed23d6806	true	display.on.consent.screen
e2130823-4219-425a-a272-a14ed23d6806	${samlRoleListScopeConsentText}	consent.screen.text
2a81b3f6-1bcd-4fd8-b1ff-a55257bd8f3b	true	display.on.consent.screen
2a81b3f6-1bcd-4fd8-b1ff-a55257bd8f3b	${profileScopeConsentText}	consent.screen.text
2a81b3f6-1bcd-4fd8-b1ff-a55257bd8f3b	true	include.in.token.scope
aefd8acf-d41a-4d8a-9d3b-ceb0e6257a8b	true	display.on.consent.screen
aefd8acf-d41a-4d8a-9d3b-ceb0e6257a8b	${emailScopeConsentText}	consent.screen.text
aefd8acf-d41a-4d8a-9d3b-ceb0e6257a8b	true	include.in.token.scope
76c38eef-9683-4ad4-abb1-62c411d8c0dd	true	display.on.consent.screen
76c38eef-9683-4ad4-abb1-62c411d8c0dd	${addressScopeConsentText}	consent.screen.text
76c38eef-9683-4ad4-abb1-62c411d8c0dd	true	include.in.token.scope
0f22a8f2-72ab-46a7-b4fc-d321263fba76	true	display.on.consent.screen
0f22a8f2-72ab-46a7-b4fc-d321263fba76	${phoneScopeConsentText}	consent.screen.text
0f22a8f2-72ab-46a7-b4fc-d321263fba76	true	include.in.token.scope
bc820279-57ae-419f-b290-6e886c2c2502	true	display.on.consent.screen
bc820279-57ae-419f-b290-6e886c2c2502	${rolesScopeConsentText}	consent.screen.text
bc820279-57ae-419f-b290-6e886c2c2502	false	include.in.token.scope
ac5426d1-f8da-4529-a9aa-713219ebdd8e	false	display.on.consent.screen
ac5426d1-f8da-4529-a9aa-713219ebdd8e		consent.screen.text
ac5426d1-f8da-4529-a9aa-713219ebdd8e	false	include.in.token.scope
fea7a210-49f2-4e8d-a2ad-fd08c415ed7c	false	display.on.consent.screen
fea7a210-49f2-4e8d-a2ad-fd08c415ed7c	true	include.in.token.scope
b6ff3e04-8e0f-450a-aa13-5b158e1669af	false	display.on.consent.screen
b6ff3e04-8e0f-450a-aa13-5b158e1669af	false	include.in.token.scope
cf92c41a-2e84-4f45-9655-f77f1a0ea142	true	display.on.consent.screen
cf92c41a-2e84-4f45-9655-f77f1a0ea142	${offlineAccessScopeConsentText}	consent.screen.text
49244ffb-76db-4607-ae9a-5f737125fa46	true	display.on.consent.screen
49244ffb-76db-4607-ae9a-5f737125fa46	${samlRoleListScopeConsentText}	consent.screen.text
576b8764-4e94-43c7-a71a-ac0022afd84c	true	display.on.consent.screen
576b8764-4e94-43c7-a71a-ac0022afd84c	${profileScopeConsentText}	consent.screen.text
576b8764-4e94-43c7-a71a-ac0022afd84c	true	include.in.token.scope
51eac524-dce3-40a2-9bd8-6d7162329b1d	true	display.on.consent.screen
51eac524-dce3-40a2-9bd8-6d7162329b1d	${emailScopeConsentText}	consent.screen.text
51eac524-dce3-40a2-9bd8-6d7162329b1d	true	include.in.token.scope
89f6de5e-7858-4e9c-ab55-44a2e3f109ca	true	display.on.consent.screen
89f6de5e-7858-4e9c-ab55-44a2e3f109ca	${addressScopeConsentText}	consent.screen.text
89f6de5e-7858-4e9c-ab55-44a2e3f109ca	true	include.in.token.scope
c8723907-0f2d-424b-ba90-b8e1112972c3	true	display.on.consent.screen
c8723907-0f2d-424b-ba90-b8e1112972c3	${phoneScopeConsentText}	consent.screen.text
c8723907-0f2d-424b-ba90-b8e1112972c3	true	include.in.token.scope
995c67d6-07ed-4025-8c59-77adc190a6fa	true	display.on.consent.screen
995c67d6-07ed-4025-8c59-77adc190a6fa	${rolesScopeConsentText}	consent.screen.text
995c67d6-07ed-4025-8c59-77adc190a6fa	false	include.in.token.scope
a568d36b-4bf3-4fee-95c8-77589d1936b7	false	display.on.consent.screen
a568d36b-4bf3-4fee-95c8-77589d1936b7		consent.screen.text
a568d36b-4bf3-4fee-95c8-77589d1936b7	false	include.in.token.scope
dd280499-0b11-41ee-99a8-ed93e95a46d1	false	display.on.consent.screen
dd280499-0b11-41ee-99a8-ed93e95a46d1	true	include.in.token.scope
1a5bb211-b22b-4f03-a4d2-c06cbf603379	false	display.on.consent.screen
1a5bb211-b22b-4f03-a4d2-c06cbf603379	false	include.in.token.scope
\.


--
-- Data for Name: client_scope_client; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.client_scope_client (client_id, scope_id, default_scope) FROM stdin;
4d54aa61-2812-4233-b6c8-1c148de24706	ac5426d1-f8da-4529-a9aa-713219ebdd8e	t
4d54aa61-2812-4233-b6c8-1c148de24706	b6ff3e04-8e0f-450a-aa13-5b158e1669af	t
4d54aa61-2812-4233-b6c8-1c148de24706	bc820279-57ae-419f-b290-6e886c2c2502	t
4d54aa61-2812-4233-b6c8-1c148de24706	2a81b3f6-1bcd-4fd8-b1ff-a55257bd8f3b	t
4d54aa61-2812-4233-b6c8-1c148de24706	aefd8acf-d41a-4d8a-9d3b-ceb0e6257a8b	t
4d54aa61-2812-4233-b6c8-1c148de24706	5d094eff-5a40-456a-894b-8ce13fc7e43c	f
4d54aa61-2812-4233-b6c8-1c148de24706	76c38eef-9683-4ad4-abb1-62c411d8c0dd	f
4d54aa61-2812-4233-b6c8-1c148de24706	0f22a8f2-72ab-46a7-b4fc-d321263fba76	f
4d54aa61-2812-4233-b6c8-1c148de24706	fea7a210-49f2-4e8d-a2ad-fd08c415ed7c	f
fcf80481-f9c8-44c6-8f42-0523de9bbcc6	ac5426d1-f8da-4529-a9aa-713219ebdd8e	t
fcf80481-f9c8-44c6-8f42-0523de9bbcc6	b6ff3e04-8e0f-450a-aa13-5b158e1669af	t
fcf80481-f9c8-44c6-8f42-0523de9bbcc6	bc820279-57ae-419f-b290-6e886c2c2502	t
fcf80481-f9c8-44c6-8f42-0523de9bbcc6	2a81b3f6-1bcd-4fd8-b1ff-a55257bd8f3b	t
fcf80481-f9c8-44c6-8f42-0523de9bbcc6	aefd8acf-d41a-4d8a-9d3b-ceb0e6257a8b	t
fcf80481-f9c8-44c6-8f42-0523de9bbcc6	5d094eff-5a40-456a-894b-8ce13fc7e43c	f
fcf80481-f9c8-44c6-8f42-0523de9bbcc6	76c38eef-9683-4ad4-abb1-62c411d8c0dd	f
fcf80481-f9c8-44c6-8f42-0523de9bbcc6	0f22a8f2-72ab-46a7-b4fc-d321263fba76	f
fcf80481-f9c8-44c6-8f42-0523de9bbcc6	fea7a210-49f2-4e8d-a2ad-fd08c415ed7c	f
41267829-dba6-4ceb-9fa5-41fc3e4c9b32	ac5426d1-f8da-4529-a9aa-713219ebdd8e	t
41267829-dba6-4ceb-9fa5-41fc3e4c9b32	b6ff3e04-8e0f-450a-aa13-5b158e1669af	t
41267829-dba6-4ceb-9fa5-41fc3e4c9b32	bc820279-57ae-419f-b290-6e886c2c2502	t
41267829-dba6-4ceb-9fa5-41fc3e4c9b32	2a81b3f6-1bcd-4fd8-b1ff-a55257bd8f3b	t
41267829-dba6-4ceb-9fa5-41fc3e4c9b32	aefd8acf-d41a-4d8a-9d3b-ceb0e6257a8b	t
41267829-dba6-4ceb-9fa5-41fc3e4c9b32	5d094eff-5a40-456a-894b-8ce13fc7e43c	f
41267829-dba6-4ceb-9fa5-41fc3e4c9b32	76c38eef-9683-4ad4-abb1-62c411d8c0dd	f
41267829-dba6-4ceb-9fa5-41fc3e4c9b32	0f22a8f2-72ab-46a7-b4fc-d321263fba76	f
41267829-dba6-4ceb-9fa5-41fc3e4c9b32	fea7a210-49f2-4e8d-a2ad-fd08c415ed7c	f
fa9e8401-1be7-4a56-a0b0-52dad2195303	ac5426d1-f8da-4529-a9aa-713219ebdd8e	t
fa9e8401-1be7-4a56-a0b0-52dad2195303	b6ff3e04-8e0f-450a-aa13-5b158e1669af	t
fa9e8401-1be7-4a56-a0b0-52dad2195303	bc820279-57ae-419f-b290-6e886c2c2502	t
fa9e8401-1be7-4a56-a0b0-52dad2195303	2a81b3f6-1bcd-4fd8-b1ff-a55257bd8f3b	t
fa9e8401-1be7-4a56-a0b0-52dad2195303	aefd8acf-d41a-4d8a-9d3b-ceb0e6257a8b	t
fa9e8401-1be7-4a56-a0b0-52dad2195303	5d094eff-5a40-456a-894b-8ce13fc7e43c	f
fa9e8401-1be7-4a56-a0b0-52dad2195303	76c38eef-9683-4ad4-abb1-62c411d8c0dd	f
fa9e8401-1be7-4a56-a0b0-52dad2195303	0f22a8f2-72ab-46a7-b4fc-d321263fba76	f
fa9e8401-1be7-4a56-a0b0-52dad2195303	fea7a210-49f2-4e8d-a2ad-fd08c415ed7c	f
8555aea4-b785-4d79-996c-47e79ebae943	ac5426d1-f8da-4529-a9aa-713219ebdd8e	t
8555aea4-b785-4d79-996c-47e79ebae943	b6ff3e04-8e0f-450a-aa13-5b158e1669af	t
8555aea4-b785-4d79-996c-47e79ebae943	bc820279-57ae-419f-b290-6e886c2c2502	t
8555aea4-b785-4d79-996c-47e79ebae943	2a81b3f6-1bcd-4fd8-b1ff-a55257bd8f3b	t
8555aea4-b785-4d79-996c-47e79ebae943	aefd8acf-d41a-4d8a-9d3b-ceb0e6257a8b	t
8555aea4-b785-4d79-996c-47e79ebae943	5d094eff-5a40-456a-894b-8ce13fc7e43c	f
8555aea4-b785-4d79-996c-47e79ebae943	76c38eef-9683-4ad4-abb1-62c411d8c0dd	f
8555aea4-b785-4d79-996c-47e79ebae943	0f22a8f2-72ab-46a7-b4fc-d321263fba76	f
8555aea4-b785-4d79-996c-47e79ebae943	fea7a210-49f2-4e8d-a2ad-fd08c415ed7c	f
2c39f546-574c-436f-bd84-c217e5de074c	ac5426d1-f8da-4529-a9aa-713219ebdd8e	t
2c39f546-574c-436f-bd84-c217e5de074c	b6ff3e04-8e0f-450a-aa13-5b158e1669af	t
2c39f546-574c-436f-bd84-c217e5de074c	bc820279-57ae-419f-b290-6e886c2c2502	t
2c39f546-574c-436f-bd84-c217e5de074c	2a81b3f6-1bcd-4fd8-b1ff-a55257bd8f3b	t
2c39f546-574c-436f-bd84-c217e5de074c	aefd8acf-d41a-4d8a-9d3b-ceb0e6257a8b	t
2c39f546-574c-436f-bd84-c217e5de074c	5d094eff-5a40-456a-894b-8ce13fc7e43c	f
2c39f546-574c-436f-bd84-c217e5de074c	76c38eef-9683-4ad4-abb1-62c411d8c0dd	f
2c39f546-574c-436f-bd84-c217e5de074c	0f22a8f2-72ab-46a7-b4fc-d321263fba76	f
2c39f546-574c-436f-bd84-c217e5de074c	fea7a210-49f2-4e8d-a2ad-fd08c415ed7c	f
321503d7-7ad4-4062-a43b-6ed10dde5585	51eac524-dce3-40a2-9bd8-6d7162329b1d	t
321503d7-7ad4-4062-a43b-6ed10dde5585	576b8764-4e94-43c7-a71a-ac0022afd84c	t
321503d7-7ad4-4062-a43b-6ed10dde5585	a568d36b-4bf3-4fee-95c8-77589d1936b7	t
321503d7-7ad4-4062-a43b-6ed10dde5585	995c67d6-07ed-4025-8c59-77adc190a6fa	t
321503d7-7ad4-4062-a43b-6ed10dde5585	1a5bb211-b22b-4f03-a4d2-c06cbf603379	t
321503d7-7ad4-4062-a43b-6ed10dde5585	c8723907-0f2d-424b-ba90-b8e1112972c3	f
321503d7-7ad4-4062-a43b-6ed10dde5585	cf92c41a-2e84-4f45-9655-f77f1a0ea142	f
321503d7-7ad4-4062-a43b-6ed10dde5585	dd280499-0b11-41ee-99a8-ed93e95a46d1	f
321503d7-7ad4-4062-a43b-6ed10dde5585	89f6de5e-7858-4e9c-ab55-44a2e3f109ca	f
a128520c-0fb1-4780-b35f-0a42e859e46d	51eac524-dce3-40a2-9bd8-6d7162329b1d	t
a128520c-0fb1-4780-b35f-0a42e859e46d	576b8764-4e94-43c7-a71a-ac0022afd84c	t
a128520c-0fb1-4780-b35f-0a42e859e46d	a568d36b-4bf3-4fee-95c8-77589d1936b7	t
a128520c-0fb1-4780-b35f-0a42e859e46d	995c67d6-07ed-4025-8c59-77adc190a6fa	t
a128520c-0fb1-4780-b35f-0a42e859e46d	1a5bb211-b22b-4f03-a4d2-c06cbf603379	t
a128520c-0fb1-4780-b35f-0a42e859e46d	c8723907-0f2d-424b-ba90-b8e1112972c3	f
a128520c-0fb1-4780-b35f-0a42e859e46d	cf92c41a-2e84-4f45-9655-f77f1a0ea142	f
a128520c-0fb1-4780-b35f-0a42e859e46d	dd280499-0b11-41ee-99a8-ed93e95a46d1	f
a128520c-0fb1-4780-b35f-0a42e859e46d	89f6de5e-7858-4e9c-ab55-44a2e3f109ca	f
a79305b9-7053-459c-803c-fc4e046cded8	51eac524-dce3-40a2-9bd8-6d7162329b1d	t
a79305b9-7053-459c-803c-fc4e046cded8	576b8764-4e94-43c7-a71a-ac0022afd84c	t
a79305b9-7053-459c-803c-fc4e046cded8	a568d36b-4bf3-4fee-95c8-77589d1936b7	t
a79305b9-7053-459c-803c-fc4e046cded8	995c67d6-07ed-4025-8c59-77adc190a6fa	t
a79305b9-7053-459c-803c-fc4e046cded8	1a5bb211-b22b-4f03-a4d2-c06cbf603379	t
a79305b9-7053-459c-803c-fc4e046cded8	c8723907-0f2d-424b-ba90-b8e1112972c3	f
a79305b9-7053-459c-803c-fc4e046cded8	cf92c41a-2e84-4f45-9655-f77f1a0ea142	f
a79305b9-7053-459c-803c-fc4e046cded8	dd280499-0b11-41ee-99a8-ed93e95a46d1	f
a79305b9-7053-459c-803c-fc4e046cded8	89f6de5e-7858-4e9c-ab55-44a2e3f109ca	f
09cea9d8-680c-458a-8b61-4560b5831997	51eac524-dce3-40a2-9bd8-6d7162329b1d	t
09cea9d8-680c-458a-8b61-4560b5831997	576b8764-4e94-43c7-a71a-ac0022afd84c	t
09cea9d8-680c-458a-8b61-4560b5831997	a568d36b-4bf3-4fee-95c8-77589d1936b7	t
09cea9d8-680c-458a-8b61-4560b5831997	995c67d6-07ed-4025-8c59-77adc190a6fa	t
09cea9d8-680c-458a-8b61-4560b5831997	1a5bb211-b22b-4f03-a4d2-c06cbf603379	t
09cea9d8-680c-458a-8b61-4560b5831997	c8723907-0f2d-424b-ba90-b8e1112972c3	f
09cea9d8-680c-458a-8b61-4560b5831997	cf92c41a-2e84-4f45-9655-f77f1a0ea142	f
09cea9d8-680c-458a-8b61-4560b5831997	dd280499-0b11-41ee-99a8-ed93e95a46d1	f
09cea9d8-680c-458a-8b61-4560b5831997	89f6de5e-7858-4e9c-ab55-44a2e3f109ca	f
13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	51eac524-dce3-40a2-9bd8-6d7162329b1d	t
13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	576b8764-4e94-43c7-a71a-ac0022afd84c	t
13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	a568d36b-4bf3-4fee-95c8-77589d1936b7	t
13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	995c67d6-07ed-4025-8c59-77adc190a6fa	t
13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	1a5bb211-b22b-4f03-a4d2-c06cbf603379	t
13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	c8723907-0f2d-424b-ba90-b8e1112972c3	f
13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	cf92c41a-2e84-4f45-9655-f77f1a0ea142	f
13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	dd280499-0b11-41ee-99a8-ed93e95a46d1	f
13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	89f6de5e-7858-4e9c-ab55-44a2e3f109ca	f
fa8f3487-99ca-4e48-aca6-c706a7949899	51eac524-dce3-40a2-9bd8-6d7162329b1d	t
fa8f3487-99ca-4e48-aca6-c706a7949899	576b8764-4e94-43c7-a71a-ac0022afd84c	t
fa8f3487-99ca-4e48-aca6-c706a7949899	a568d36b-4bf3-4fee-95c8-77589d1936b7	t
fa8f3487-99ca-4e48-aca6-c706a7949899	995c67d6-07ed-4025-8c59-77adc190a6fa	t
fa8f3487-99ca-4e48-aca6-c706a7949899	1a5bb211-b22b-4f03-a4d2-c06cbf603379	t
fa8f3487-99ca-4e48-aca6-c706a7949899	c8723907-0f2d-424b-ba90-b8e1112972c3	f
fa8f3487-99ca-4e48-aca6-c706a7949899	cf92c41a-2e84-4f45-9655-f77f1a0ea142	f
fa8f3487-99ca-4e48-aca6-c706a7949899	dd280499-0b11-41ee-99a8-ed93e95a46d1	f
fa8f3487-99ca-4e48-aca6-c706a7949899	89f6de5e-7858-4e9c-ab55-44a2e3f109ca	f
65312025-7a16-4921-843b-47c7a1f5fc29	51eac524-dce3-40a2-9bd8-6d7162329b1d	t
65312025-7a16-4921-843b-47c7a1f5fc29	576b8764-4e94-43c7-a71a-ac0022afd84c	t
65312025-7a16-4921-843b-47c7a1f5fc29	a568d36b-4bf3-4fee-95c8-77589d1936b7	t
65312025-7a16-4921-843b-47c7a1f5fc29	995c67d6-07ed-4025-8c59-77adc190a6fa	t
65312025-7a16-4921-843b-47c7a1f5fc29	1a5bb211-b22b-4f03-a4d2-c06cbf603379	t
65312025-7a16-4921-843b-47c7a1f5fc29	c8723907-0f2d-424b-ba90-b8e1112972c3	f
65312025-7a16-4921-843b-47c7a1f5fc29	cf92c41a-2e84-4f45-9655-f77f1a0ea142	f
65312025-7a16-4921-843b-47c7a1f5fc29	dd280499-0b11-41ee-99a8-ed93e95a46d1	f
65312025-7a16-4921-843b-47c7a1f5fc29	89f6de5e-7858-4e9c-ab55-44a2e3f109ca	f
\.


--
-- Data for Name: client_scope_role_mapping; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.client_scope_role_mapping (scope_id, role_id) FROM stdin;
5d094eff-5a40-456a-894b-8ce13fc7e43c	e6535714-4142-4244-9960-43374ffe3341
cf92c41a-2e84-4f45-9655-f77f1a0ea142	51615ae0-b8a9-4a99-8de7-97d4959f9e3b
\.


--
-- Data for Name: client_session; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.client_session (id, client_id, redirect_uri, state, "timestamp", session_id, auth_method, realm_id, auth_user_id, current_action) FROM stdin;
\.


--
-- Data for Name: client_session_auth_status; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.client_session_auth_status (authenticator, status, client_session) FROM stdin;
\.


--
-- Data for Name: client_session_note; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.client_session_note (name, value, client_session) FROM stdin;
\.


--
-- Data for Name: client_session_prot_mapper; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.client_session_prot_mapper (protocol_mapper_id, client_session) FROM stdin;
\.


--
-- Data for Name: client_session_role; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.client_session_role (role_id, client_session) FROM stdin;
\.


--
-- Data for Name: client_user_session_note; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.client_user_session_note (name, value, client_session) FROM stdin;
\.


--
-- Data for Name: component; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.component (id, name, parent_id, provider_id, provider_type, realm_id, sub_type) FROM stdin;
47836467-ad8c-442b-bd1f-f600615bc97c	Trusted Hosts	b748fd0d-b840-453b-b49c-26b926a71139	trusted-hosts	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	b748fd0d-b840-453b-b49c-26b926a71139	anonymous
0a7f144b-326c-475e-8628-84844a50510c	Consent Required	b748fd0d-b840-453b-b49c-26b926a71139	consent-required	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	b748fd0d-b840-453b-b49c-26b926a71139	anonymous
2add6a20-1cb7-4211-b7f6-0497a7bbcfff	Full Scope Disabled	b748fd0d-b840-453b-b49c-26b926a71139	scope	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	b748fd0d-b840-453b-b49c-26b926a71139	anonymous
a428eb10-4814-4afa-b5dd-6bd6961806ef	Max Clients Limit	b748fd0d-b840-453b-b49c-26b926a71139	max-clients	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	b748fd0d-b840-453b-b49c-26b926a71139	anonymous
31a06b12-508c-432f-9b44-7c989f6c618f	Allowed Protocol Mapper Types	b748fd0d-b840-453b-b49c-26b926a71139	allowed-protocol-mappers	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	b748fd0d-b840-453b-b49c-26b926a71139	anonymous
78277d80-67ce-4ec1-b493-880e53ad539d	Allowed Client Scopes	b748fd0d-b840-453b-b49c-26b926a71139	allowed-client-templates	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	b748fd0d-b840-453b-b49c-26b926a71139	anonymous
f9211456-91de-4859-a3b6-a7d7c6745e89	Allowed Protocol Mapper Types	b748fd0d-b840-453b-b49c-26b926a71139	allowed-protocol-mappers	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	b748fd0d-b840-453b-b49c-26b926a71139	authenticated
6f2bf570-3a3d-40d0-bf1b-141a5a87b319	Allowed Client Scopes	b748fd0d-b840-453b-b49c-26b926a71139	allowed-client-templates	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	b748fd0d-b840-453b-b49c-26b926a71139	authenticated
7017d9e2-e2c4-4b52-8e72-4cda9cd4086c	rsa-generated	b748fd0d-b840-453b-b49c-26b926a71139	rsa-generated	org.keycloak.keys.KeyProvider	b748fd0d-b840-453b-b49c-26b926a71139	\N
1fe55eaf-4437-42ed-8790-11042e520fe2	rsa-enc-generated	b748fd0d-b840-453b-b49c-26b926a71139	rsa-enc-generated	org.keycloak.keys.KeyProvider	b748fd0d-b840-453b-b49c-26b926a71139	\N
5114831d-c6f5-44aa-b508-734c3d7f37ea	hmac-generated-hs512	b748fd0d-b840-453b-b49c-26b926a71139	hmac-generated	org.keycloak.keys.KeyProvider	b748fd0d-b840-453b-b49c-26b926a71139	\N
3b62e1ee-3611-4efc-926f-36b32e959248	aes-generated	b748fd0d-b840-453b-b49c-26b926a71139	aes-generated	org.keycloak.keys.KeyProvider	b748fd0d-b840-453b-b49c-26b926a71139	\N
7bb3084c-89aa-4b06-937c-21276cbaa145	\N	b748fd0d-b840-453b-b49c-26b926a71139	declarative-user-profile	org.keycloak.userprofile.UserProfileProvider	b748fd0d-b840-453b-b49c-26b926a71139	\N
1d7204ef-bb41-4943-badf-c16d2918a5d6	rsa-generated	354b9070-b2b9-4f85-9ab1-d7b290304732	rsa-generated	org.keycloak.keys.KeyProvider	354b9070-b2b9-4f85-9ab1-d7b290304732	\N
2e7c17f1-1d4d-4bd9-89f9-dea4e539f12c	rsa-enc-generated	354b9070-b2b9-4f85-9ab1-d7b290304732	rsa-enc-generated	org.keycloak.keys.KeyProvider	354b9070-b2b9-4f85-9ab1-d7b290304732	\N
028de41b-605b-4dc3-b97c-7d4b5445a6cd	hmac-generated-hs512	354b9070-b2b9-4f85-9ab1-d7b290304732	hmac-generated	org.keycloak.keys.KeyProvider	354b9070-b2b9-4f85-9ab1-d7b290304732	\N
36f7aa25-685a-43f2-96c3-eb76d117f601	aes-generated	354b9070-b2b9-4f85-9ab1-d7b290304732	aes-generated	org.keycloak.keys.KeyProvider	354b9070-b2b9-4f85-9ab1-d7b290304732	\N
26d9ef65-3047-4d52-976a-cda2adc94203	Trusted Hosts	354b9070-b2b9-4f85-9ab1-d7b290304732	trusted-hosts	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	354b9070-b2b9-4f85-9ab1-d7b290304732	anonymous
dc24c9c6-7a62-424a-9b60-d6974a8adb94	Consent Required	354b9070-b2b9-4f85-9ab1-d7b290304732	consent-required	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	354b9070-b2b9-4f85-9ab1-d7b290304732	anonymous
cc92789b-b74e-416f-aac5-23f6cfe8e8e0	Full Scope Disabled	354b9070-b2b9-4f85-9ab1-d7b290304732	scope	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	354b9070-b2b9-4f85-9ab1-d7b290304732	anonymous
9be032d4-5e20-43a9-a12c-e5e6cd980f66	Max Clients Limit	354b9070-b2b9-4f85-9ab1-d7b290304732	max-clients	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	354b9070-b2b9-4f85-9ab1-d7b290304732	anonymous
3c6a8ac1-73f7-4340-81f6-77eac09652a7	Allowed Protocol Mapper Types	354b9070-b2b9-4f85-9ab1-d7b290304732	allowed-protocol-mappers	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	354b9070-b2b9-4f85-9ab1-d7b290304732	anonymous
248c5ba4-56fa-4329-a6d1-6980bf16a0d2	Allowed Client Scopes	354b9070-b2b9-4f85-9ab1-d7b290304732	allowed-client-templates	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	354b9070-b2b9-4f85-9ab1-d7b290304732	anonymous
1a1cfd54-e196-4d5f-b5a0-df44d3d386d3	Allowed Protocol Mapper Types	354b9070-b2b9-4f85-9ab1-d7b290304732	allowed-protocol-mappers	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	354b9070-b2b9-4f85-9ab1-d7b290304732	authenticated
c067beb3-4889-4f25-bcef-a3365eb8af57	Allowed Client Scopes	354b9070-b2b9-4f85-9ab1-d7b290304732	allowed-client-templates	org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy	354b9070-b2b9-4f85-9ab1-d7b290304732	authenticated
\.


--
-- Data for Name: component_config; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.component_config (id, component_id, name, value) FROM stdin;
e1d04f28-f3d2-4de3-86a8-fc02c4ee34a5	47836467-ad8c-442b-bd1f-f600615bc97c	host-sending-registration-request-must-match	true
37611dc8-4878-4ab8-8c71-fc90e583ccdc	47836467-ad8c-442b-bd1f-f600615bc97c	client-uris-must-match	true
44456f0a-0803-437a-84cf-a6d54e095fba	6f2bf570-3a3d-40d0-bf1b-141a5a87b319	allow-default-scopes	true
c6d10ada-96ff-447c-9b9e-eff677503ace	78277d80-67ce-4ec1-b493-880e53ad539d	allow-default-scopes	true
bb98117e-c724-42d5-b7e9-ff4f3d7b2ef7	a428eb10-4814-4afa-b5dd-6bd6961806ef	max-clients	200
17ac7d0b-3eff-4be0-9acb-6f297abbc9a1	f9211456-91de-4859-a3b6-a7d7c6745e89	allowed-protocol-mapper-types	saml-user-attribute-mapper
8d6a3c6d-7b83-4aed-8751-483e07fe1be2	f9211456-91de-4859-a3b6-a7d7c6745e89	allowed-protocol-mapper-types	oidc-address-mapper
04872d73-0fc7-4cef-85a2-159e27bca780	f9211456-91de-4859-a3b6-a7d7c6745e89	allowed-protocol-mapper-types	oidc-sha256-pairwise-sub-mapper
8b19501c-9389-4284-9bf1-f776973403c1	f9211456-91de-4859-a3b6-a7d7c6745e89	allowed-protocol-mapper-types	oidc-usermodel-property-mapper
2b0f7eaf-9bd7-4dca-b801-fdf74f52601a	f9211456-91de-4859-a3b6-a7d7c6745e89	allowed-protocol-mapper-types	saml-role-list-mapper
34f4d3c7-59ee-49e2-82d9-b06addd6237a	f9211456-91de-4859-a3b6-a7d7c6745e89	allowed-protocol-mapper-types	oidc-usermodel-attribute-mapper
c6ea6d55-30b2-429c-96ad-e43aaff0eb36	f9211456-91de-4859-a3b6-a7d7c6745e89	allowed-protocol-mapper-types	saml-user-property-mapper
360496dd-09f6-4c68-b3db-e9afddcb9a1c	f9211456-91de-4859-a3b6-a7d7c6745e89	allowed-protocol-mapper-types	oidc-full-name-mapper
c51d977e-224a-4595-8ad5-62e2222be898	31a06b12-508c-432f-9b44-7c989f6c618f	allowed-protocol-mapper-types	oidc-sha256-pairwise-sub-mapper
97ff2649-dcfe-477b-b347-a0c22ab0693c	31a06b12-508c-432f-9b44-7c989f6c618f	allowed-protocol-mapper-types	saml-user-property-mapper
3b29cf56-10ad-46db-b79b-ffa7d7e0b53c	31a06b12-508c-432f-9b44-7c989f6c618f	allowed-protocol-mapper-types	oidc-usermodel-attribute-mapper
8b06796e-1631-4048-8ca3-38501c057c8d	31a06b12-508c-432f-9b44-7c989f6c618f	allowed-protocol-mapper-types	saml-user-attribute-mapper
afa59899-9195-4b06-ba79-a4800958c407	31a06b12-508c-432f-9b44-7c989f6c618f	allowed-protocol-mapper-types	oidc-full-name-mapper
654471d6-ba54-4573-b1a5-4bf9b9b4577f	31a06b12-508c-432f-9b44-7c989f6c618f	allowed-protocol-mapper-types	oidc-usermodel-property-mapper
2e754cda-81c9-4026-9ed0-77d6b4bc8608	31a06b12-508c-432f-9b44-7c989f6c618f	allowed-protocol-mapper-types	saml-role-list-mapper
504b2eec-365b-4656-ad0d-dce28ba967f7	31a06b12-508c-432f-9b44-7c989f6c618f	allowed-protocol-mapper-types	oidc-address-mapper
b06fbca4-ebe5-4214-9a44-2d7ad070816a	7017d9e2-e2c4-4b52-8e72-4cda9cd4086c	certificate	MIICmzCCAYMCBgGdThJlMjANBgkqhkiG9w0BAQsFADARMQ8wDQYDVQQDDAZtYXN0ZXIwHhcNMjYwNDAyMTIwMDIxWhcNMzYwNDAyMTIwMjAxWjARMQ8wDQYDVQQDDAZtYXN0ZXIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQD08nmsZ7iB1I9RV0BFFBErNfPfFmVi61l/U3Kb2xP90mzt9WK3Wb3PrlyOw6j3XRI5ZmQMxbZ86BCAo6ZIo06otQIp8vZJ83V1x+nNpZehLl3jaYJEiJpFEJJLwYTCPeKYF/CZhvCqn7jIrSak7jH/g3p67AkBSihYGkN1aSxhXi+y7Uip4h8TgfObUTywEqos0Rca6Wz+1CvRjNd8yvd7qcZuX2DHbjO2lXMM6xcpUDypURMyj2NohdMR8AJwewg6nIqLXGEMLt/m2yCNVqRf0ZrTy1fkm3NUrDLLw2ul3Mqcu2JbvND7TTxkdE71hWd/0Dg+6x/L3s0ilvZnRu1BAgMBAAEwDQYJKoZIhvcNAQELBQADggEBAIk6L8Yy4b9Jz6kZ/NG8obSotcckw7luFZjFhgLGywhvojuxRU+ChMfmoKUy59ma5yEhw40p+UAeW2T5IwsEnqIJ2cLqEsBzyKhnf1wMf5AN3upiLgGPFZVZRjiKsIXZM5ckLqLMiekLHeDQpn9A6Jx9CaiG4Hpl7ISq88I54mIykrnBYqzxcdRMQIOhwDR3GYSjvCv70heuf7O5WMxozm8g7BvAaE8O1I2YcqzOA9kWjXuT7ow8JwknG41UkXq8pewHuxsFrNK+8PxCwWMxzbaavdIip1pngjF7h4bwTaJi5gJuXE/wrN0vi1niGfjp9X06xt0xSq933d1cF1BqxmQ=
50505d62-be5b-4fbc-a00c-ab06ed61f411	7017d9e2-e2c4-4b52-8e72-4cda9cd4086c	keyUse	SIG
d99ee480-9283-4a17-9d81-e24fb1a81c0e	7017d9e2-e2c4-4b52-8e72-4cda9cd4086c	privateKey	MIIEpQIBAAKCAQEA9PJ5rGe4gdSPUVdARRQRKzXz3xZlYutZf1Nym9sT/dJs7fVit1m9z65cjsOo910SOWZkDMW2fOgQgKOmSKNOqLUCKfL2SfN1dcfpzaWXoS5d42mCRIiaRRCSS8GEwj3imBfwmYbwqp+4yK0mpO4x/4N6euwJAUooWBpDdWksYV4vsu1IqeIfE4Hzm1E8sBKqLNEXGuls/tQr0YzXfMr3e6nGbl9gx24ztpVzDOsXKVA8qVETMo9jaIXTEfACcHsIOpyKi1xhDC7f5tsgjVakX9Ga08tX5JtzVKwyy8NrpdzKnLtiW7zQ+008ZHRO9YVnf9A4Pusfy97NIpb2Z0btQQIDAQABAoIBAAJQSsnBy5pwx+gbFligsNAMCQ2xQBoTkKDRne+14R7g1cCe3zaGpI8kGh4ZNWlWScyyKiSY2kQAKCYxIfhCgfaOmD8cIk7M5nw15sdQaHZFl4p+KincRzulmqyYV8O0tG/pZGvQJxDaZ6Tx1DEzAuLxjGXscqk3Q1pZBO/vKmktWN6iFfKm+rTPJ+OgaYRNXLhrmMIo9qeL1YNZwqQ61mgLXoEfRQRe91FkabkQ/Sglt4zlkcI4XaRHKbZo5A8hSR6lNdhQ99hLaDTgP9cPZ7ffg8GN4pNg4m1AlpeITgUublW+DtOUyXEk++VGIXAoampgwy448R2gkasfy7jdZ50CgYEA/KRH79R9N3CF8ae9R4JWKYwm5Di31vlUYQFSdUE/wB7Pj1UH53Brc2m2cTo8MKhfVabzamYN3lg1tMBS9af18fFjyfZIJd/3LzsY/+0w2Rhzo/fopIUp3BF9G4Za3USvEm8c9Ge/7/rWFkEwO+UaaDG/UoO+TwX9Q7SV7kHQGRUCgYEA+DQCpltEBFzRa/H1v9Vvhsth20+rjp6WRZW5SjdZGOCsRJDk6JWoyHIzueKQNI0Z4IpoyLHlL3fN/c1Nl4tSLKKG+Zh0By+yjIpZB8mwRrNnK3pVFfzisojlSlc+z8W/z7OwOsyG8xySVb0nXBvolVBzY/CKoeANu8e2rdVvdn0CgYEA9VI4oEO/i1PyXKO7AnMnY5S6NyZ0LYVSUBfOkBlZ5B6HAfFZiXz6ecmO5QfdZoo4eJ1zBEAw+1TAYdHXPL9p7ROvCG/jwxNlnTFPp0QVCNnbgL674vWDnjRFPbMLDI0jS00l2pXcJRV3SYjnY2GmcMLNuzw+UdHJCjOS2xaBEbkCgYEAoTnPutYwAZF1a+QZWUpAjtPQNhCzhQoY3Qyb9syrMJDI9iUUvMxyffpJBWdZevlpJMVjuXJtSH9PLJ1O2LDkaSAOA1X3kK94EPjRSlDGE7b3vnNRj93cOFLadobjwz1WEopLYHZ49rTJja44QgnS9CL1Qab/tpT+9sqNLLAnHlUCgYEA2rlwBjUH6oDimR0LMAvXIhib/Ldwf6FjRLi4llDrAPtz/5y+CJ1I8BSMh+4aYMZPE0+gWajE7Y6LrxxyZM/pYF2cTztBonVuV4fsRS69p0/nKdbG8Y5FhTlBGRf2oUULhYy3N0S0l/Nn/jMeh2TGctgOYo5Oc/INt32TArMrFts=
c758c109-9f4f-4333-b2b5-4b1b3711c174	7017d9e2-e2c4-4b52-8e72-4cda9cd4086c	priority	100
7ac4134a-114c-492f-93f1-d88812496bac	1fe55eaf-4437-42ed-8790-11042e520fe2	algorithm	RSA-OAEP
ffcdac04-e056-4072-9630-db7fa998859f	1fe55eaf-4437-42ed-8790-11042e520fe2	privateKey	MIIEowIBAAKCAQEAuPYprSzXAkHsynlnE8ZDD5hYxON8VDn9DEgPu9Q55YyQr9MMMANCwBEBFa3MMltJY6/mbPVza+9ybGI5voP3rtqfVE4NGc3nxTIbPgxZuSDnKDesnhyPRK05KjG5HZR8KBahX0ROmFgb5+ZPsEOdX8CpIPOcsCPEw9QyC2sdB4jyk+ipDLbylVeYw5yz7iY7CeaGOiVwfX0YDUY9oMutsgsWNiM/06jYrVJUuD3xl5Rbco8tuT9vLU1aLWgjQ/FaXgWQPb6n7GZrL46SBtpw8hfK18nqqeUjJKY0EfEZLnoXhqN5N4NisFrHObVHRO+8K6zwrqtuKjXx/rIz5DJd5wIDAQABAoIBAFrxUlGfRAKMpqBxa+C5sZx35GG+lpGVR5ojznSkp2j6IeQJqarr14S3d6iQoV+7Kc0Vnn9BemR+Qe0PqOPHYF+9h+y8Sc2/w69ecS2jhfQ0POQ1566ATWNPptVbyHDGYvuVEPhWDizy2Zm+0LzSqgz8Hkyg65Bhrew5p/ecTZQ3hu4gaFzQcKDWcTOQ3iYIbBA8Pw1+jUql5q248VPRd+wuLeuKhOgTFDG0L5fN/j3BApIMi63TVWN2slcaTjq1T2KI899UpZZnctjYH+smvnKfVr8ZKyYyoI1pzCArrMnEG8W4mQTrzvKhWWmpH3Ol0qVhs3tJN6c2YW4+4TJefgkCgYEA87adz9MMXoVHbSzmP+JhxUcroXZ9RxsLx1L8CQjQb7oTHOU5hIeLBcNeiqb1N+TjmpeJFOXWSgTSgO0HnuSYCGsPXgQDHD4paXAoZ56A/8uKhsiHFawG5nO0d1bdWosMmjgNbYGNR9sMIT1irhdDbc7YxFRADK8M0Mee245P6y8CgYEAwklKlyYj6VEr/uB/L4NvX544+YZ9wnAeGhehBMoa3wjUfzL/mWzXDlYqW5pl0mEwjdv45jpuW+jKwZAB94AQaJqk00Q4HcGG/PRsyg7vw2e47Afrxy1ewOM24cnHsC8Oqt27O2rc/UGcxj2C1SMxK/khXwT5gjN9LXXqCLezKskCgYAJ3aGj0RpWFTUgAUpM2cA1eT0V6zMFFt4yMnTLdNTjQPgXGlxqtgX1tMP1/u48VgK0tl+xPeCf3HQdDftZ/kz9QkA8AROTKB0LDKRGFY+JS1cPP7zgLreUyqhKkHSjfq+C6rP4c98hQofKLK769ywenNn/kJ2LJebx6LLQloE7twKBgBh118E92QmX4Z0eMIUP3CbCqdOofg7LxM5uKSSMOWPZHb/B8PIlBNJWQND1mForSEyj5CtAMgK6RUSnV8gMRISW66d5kEMWyWLxdvzdcow8c8irmqCh8qsAMDmvCMgCtKsIbXkmlBoCd7VxqxYgbyFlJTFsU+lziBAAJ23fitwZAoGBALYteSJtRN5x/PnK1NaQ7r5PJ2NdjhxDgwcf4LLf2XutzgI9QeojSpJ+dSf312+fq3G87431luksC4L85qxvjxFRJYlB28Eo42SzeUGlL/9wIJrkgGJDlCk1X50md3m4SacpD4iail9sXYtDUd4CvuOdl2niZEIX8MFqRM9oslLb
e7a3a360-661a-4ba3-95dd-95fcd9a05357	1fe55eaf-4437-42ed-8790-11042e520fe2	keyUse	ENC
3db7da63-56b9-46c7-86d0-a77382098b6c	1fe55eaf-4437-42ed-8790-11042e520fe2	certificate	MIICmzCCAYMCBgGdThJnVTANBgkqhkiG9w0BAQsFADARMQ8wDQYDVQQDDAZtYXN0ZXIwHhcNMjYwNDAyMTIwMDIyWhcNMzYwNDAyMTIwMjAyWjARMQ8wDQYDVQQDDAZtYXN0ZXIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC49imtLNcCQezKeWcTxkMPmFjE43xUOf0MSA+71DnljJCv0wwwA0LAEQEVrcwyW0ljr+Zs9XNr73JsYjm+g/eu2p9UTg0ZzefFMhs+DFm5IOcoN6yeHI9ErTkqMbkdlHwoFqFfRE6YWBvn5k+wQ51fwKkg85ywI8TD1DILax0HiPKT6KkMtvKVV5jDnLPuJjsJ5oY6JXB9fRgNRj2gy62yCxY2Iz/TqNitUlS4PfGXlFtyjy25P28tTVotaCND8VpeBZA9vqfsZmsvjpIG2nDyF8rXyeqp5SMkpjQR8RkueheGo3k3g2KwWsc5tUdE77wrrPCuq24qNfH+sjPkMl3nAgMBAAEwDQYJKoZIhvcNAQELBQADggEBAD+WpclVtUev+moomvdIzmTIAFA4jPPmAFqZ/X83pXbK12fMvY6N44cmlvTG8DAmzCT7EP9n6jLhoW9Tf0Tkhtw6bI9j5OOASA4AYRjZCVJPEZzlqkgY4pigYFMSrD9ZpPAcvzh4Q5Wd3mJvMnYhTwNMMASSS47OO/gFz5qcoerRQwkLxs2mvPQVG8dunMdtfIPgqKYaJqFJ0WHvGk+56g9DIlcp0ocpVDVpHjpj2vMQ7jqi6xeKkrxZOMC7DrkYVCFxmE7Ci8KWziP/hlfa0jZnB585k6uqRy+yaefq55LMn45rkHAV4+ROcIiZwl16g89OJ0P5+7B8YpoQyHOeObc=
4a8f20d3-45e6-4715-bf67-578d1b21adcf	1fe55eaf-4437-42ed-8790-11042e520fe2	priority	100
22b3f199-e424-4224-a785-8e27b1de12ac	3b62e1ee-3611-4efc-926f-36b32e959248	priority	100
5f662839-7305-4a37-814e-5f7fd8fd270d	3b62e1ee-3611-4efc-926f-36b32e959248	kid	8da76a6a-d8dd-4640-9c76-e4028cb892a5
c02f849a-bbb8-4f55-b7bc-6625cf20a1e5	3b62e1ee-3611-4efc-926f-36b32e959248	secret	WpsfI7cGYD3z2J4l9xZByA
67178d8d-7d13-4739-bb76-83c71cc0e652	5114831d-c6f5-44aa-b508-734c3d7f37ea	priority	100
a456794d-74d7-4710-bab1-d848abd15d89	5114831d-c6f5-44aa-b508-734c3d7f37ea	kid	dc5045b0-c6d5-4ff3-80e8-4b05a7c7c1bf
8180ee32-0f0c-43c1-8c61-64e3cd2c1005	5114831d-c6f5-44aa-b508-734c3d7f37ea	secret	urcBPY1f2hGa22Ms_TBwgSjvnyItbPGdcP-tlzYBODOzcE3T3o_KAKWzDR9cX8yjKbo6EFxovi-R1pmt9t5OVbr6X6QlvgZib-XpcVaUlQhwwuY_1Oe-QvjMjGTIvWSXV7tAaSdS8ydEc0qnWp-qt_0l61RvhqOD2czy998b_oM
31832ce4-26dd-4a38-99b9-b2dc36d6bdaf	5114831d-c6f5-44aa-b508-734c3d7f37ea	algorithm	HS512
f8e2eede-6b2d-48bc-bc6f-7095282e9d3c	7bb3084c-89aa-4b06-937c-21276cbaa145	kc.user.profile.config	{"attributes":[{"name":"username","displayName":"${username}","validations":{"length":{"min":3,"max":255},"username-prohibited-characters":{},"up-username-not-idn-homograph":{}},"permissions":{"view":["admin","user"],"edit":["admin","user"]},"multivalued":false},{"name":"email","displayName":"${email}","validations":{"email":{},"length":{"max":255}},"permissions":{"view":["admin","user"],"edit":["admin","user"]},"multivalued":false},{"name":"firstName","displayName":"${firstName}","validations":{"length":{"max":255},"person-name-prohibited-characters":{}},"permissions":{"view":["admin","user"],"edit":["admin","user"]},"multivalued":false},{"name":"lastName","displayName":"${lastName}","validations":{"length":{"max":255},"person-name-prohibited-characters":{}},"permissions":{"view":["admin","user"],"edit":["admin","user"]},"multivalued":false}],"groups":[{"name":"user-metadata","displayHeader":"User metadata","displayDescription":"Attributes, which refer to user metadata"}]}
b48ad6f2-716c-48d6-b5fb-9f18f8dcded0	028de41b-605b-4dc3-b97c-7d4b5445a6cd	algorithm	HS512
ed711644-7274-434e-8e5f-4dc0ad73dce3	028de41b-605b-4dc3-b97c-7d4b5445a6cd	priority	100
1d52c13e-71f3-4c95-93c5-0c05b52fe556	028de41b-605b-4dc3-b97c-7d4b5445a6cd	kid	f027afc1-75fc-4cc4-839a-76b690f901ef
16bf481d-b318-4503-b96b-0f5e6c0e3594	028de41b-605b-4dc3-b97c-7d4b5445a6cd	secret	C6lVkiwVtLpxKB3nZ0-A3p9daojHz3YiOEQMyKTMPD_BFcOERDx__BGXfNwOUpC18KWu-raM8kzqDuD0wevUpFSxSpLSRRv1ZKgxGa3zDFoTPU230B6Wm4bE50NeEZtgtB3jszmkb5tJjJIhRNH0iOLKyPW7rMPU1Lk6PsOJ1y4
c6c6aafe-5534-4ddd-a3b8-1778cff1d130	2e7c17f1-1d4d-4bd9-89f9-dea4e539f12c	certificate	MIICpTCCAY0CBgGdThJ8+jANBgkqhkiG9w0BAQsFADAWMRQwEgYDVQQDDAt2ZXJtZWctc2lyaDAeFw0yNjA0MDIxMjAwMjdaFw0zNjA0MDIxMjAyMDdaMBYxFDASBgNVBAMMC3Zlcm1lZy1zaXJoMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmD9/VIxaaJynLnAUKwNUIwoub78/A3GGAUHS/CEfe/87MR3mID0lp6OuZy6qbNrRGBp1c3AJ1W23RxB+SoSRcWsztVdTbAJv87I6SfCFjliAkDypnhvcfs7mA2HnBtQjBykWknmvM7IBCcd5+TA7Fzn2FKVn8vUWE2rvM6hV4+qN028hkXv62EJhkW7l40nnuknKYBu8Ex2qlxwo17Egq9gHOJaHCp2x+gEE3r4J9SyZNrX0NlIUb9iv6v/U5U0ruQyUU/dixS19iYeqdhUyWAjYUthdM+Qp9Q+3Pvf9U/Ix/mW/1XwJN3afoU5rPjsFr5LC7KeT0iZ+vSw7GcOBaQIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQCEY8Eku95VNvnXmPGw2o615Av/xo/y36O17l9sqANfmM/y3RTBOymAZaAu/EwoB0MYVVkqTx27RcsrMrMILRQeII5hIanExBAUp3Bk8U4hG6ILDHsqvWbsldMGoTntUza8wQan7sIWg6BF4ci8ZpWyDl3gzVr3cJPNBCZ0DS90a4sNy20BZTBhCftJU0vaHxwgQItS8m73u7thf83N1MJ9aVr/+jQ+2P68UToAtrX2RIyvKc0yY7rxIw4hN27YAU0iG6LtAtEDASBwOkobsxFdAHa4FaEjRKfy9XeS+APiI6AqiBX1l0XyYmMjVghGlPx4j8yf6NLLEBw1aSLJ3Rwb
82187784-dcc1-4682-a902-55b0a5c16ebb	2e7c17f1-1d4d-4bd9-89f9-dea4e539f12c	privateKey	MIIEogIBAAKCAQEAmD9/VIxaaJynLnAUKwNUIwoub78/A3GGAUHS/CEfe/87MR3mID0lp6OuZy6qbNrRGBp1c3AJ1W23RxB+SoSRcWsztVdTbAJv87I6SfCFjliAkDypnhvcfs7mA2HnBtQjBykWknmvM7IBCcd5+TA7Fzn2FKVn8vUWE2rvM6hV4+qN028hkXv62EJhkW7l40nnuknKYBu8Ex2qlxwo17Egq9gHOJaHCp2x+gEE3r4J9SyZNrX0NlIUb9iv6v/U5U0ruQyUU/dixS19iYeqdhUyWAjYUthdM+Qp9Q+3Pvf9U/Ix/mW/1XwJN3afoU5rPjsFr5LC7KeT0iZ+vSw7GcOBaQIDAQABAoIBAANtpJyfB3clFeeoCvA4BDhAxbBq/kyBzSpwlMNsLIUSh37w5SpzLgqjFy2IIbrPR5eTGvN1Qadub8rYHnvnlc3Xw+OQupZrTKGQcRsSoTNGH2kAELK4fmPVnVzUosrm0n4aCQHV3yHbH4ZcmUzI7v+0JKws2FUiezOHPCkt4HdAGzduc4ceKEGPR+HBicZ0JvhZIZF2xKBLJT0X8rxJ5vOEd5q/1NxdDpQORkWIY77YcePp8UD0mgzuQ8/NuHOvu5DadRMFRc5EKIacKFY2W2BxyTVVXdt7mHt0PqSd6QchiR31YHEr6p/hvlS8LBWbxnB4x0lXDZlZcn3AnMvo8MECgYEA0IMzoFPzL71cGhPRhN14hIQbOL36RP/r0SvcmhjGAbQO2WhPO/3s942xHrYfv3b2FxcDILTrY7BqM8dg12zS4OqrJZN2qdSzonJH0fKB1kM53k3EXZsaH1NmVFQor2bU3vuFH0LqV8atfGpvw9D/n+y9Z8FQsuls7qJc+JDxvqECgYEAuuvv4OXQBnAcXnge9N1pZ6KVc6ZSirW7wNTQ/9nppfFAYDZ2zh3VuyQLJdAIiYJMwii/gP6K0JL34BcJ7yHL/yhoeIN3sE1rXRqv37xPeUJF6G9nJQyh+cvRs5r14GpZhOKc521XObGZnOh10nEz7hEH9wM1aMD98CxP7HINtckCgYAWMRCKjMTCHPYzdE6FRIjyGZlIFbgQJei0L2XgJKjWP5KhAuAD84eH5VWnfhys5P1WAcX8ciTnTDxRXHPrGZLsCy3B5wrnElM4A8+vAY9d/XOoPECc8cf684ZdjUNzP4+CV+SYKigExYlrR2yzu4epPqn94+4xzHQihbc9YTfJYQKBgCROGRxMZpgphEkQ+apDqupXGMIKpvOMEriEXUekUo5JimBlk7O69b1QZd3lRxM2PKRld7SdO+cA9KYQs3w/yzh257uohUG398dwnIJPN/xsU9mucZEvn/I9lTBWQ7Vf0p1Nyn3krdFl3lksiV3jYNu3cR2YAPKksW3JnYhmKqWJAoGAYipoD/ko2g7zM2/ZtN+BrofW9QDDq65PM9CrmKETiMdOGCIp+6iifR+ZGPg98nxIRklSx1kt5Kb5RuEqVKKMtpz4WpGj+vXGTncKf+3iu+kkhTdXMc6mNYJh5BOOxkc0GXhaSOJgRlJIsTOhNXJ1uF9kaZeBCYZx3tSqShkRHSM=
1a43bde7-2ed9-475a-a40f-a2fde3c7dec6	2e7c17f1-1d4d-4bd9-89f9-dea4e539f12c	algorithm	RSA-OAEP
771dd2e8-aa55-4568-9194-0ff1bd8b7765	2e7c17f1-1d4d-4bd9-89f9-dea4e539f12c	priority	100
6e02e821-f190-4fda-9094-a36aaa4d7d33	2e7c17f1-1d4d-4bd9-89f9-dea4e539f12c	keyUse	ENC
fb5551c5-784b-4a24-b2e9-3ace36bc9591	36f7aa25-685a-43f2-96c3-eb76d117f601	priority	100
7c7e6123-047a-4e18-87b5-22438111f94d	36f7aa25-685a-43f2-96c3-eb76d117f601	secret	w8QOC1ib5Nt3LXWLTfJibA
ba61c2fa-f471-4402-af1d-64eafe064286	36f7aa25-685a-43f2-96c3-eb76d117f601	kid	1dd80103-10be-4f56-a0ad-a55c5e2ad29b
cb106382-b0b2-4771-847a-fdbc728c17f6	1d7204ef-bb41-4943-badf-c16d2918a5d6	keyUse	SIG
dcd7a19b-8698-471c-a19f-818e37162b7a	1d7204ef-bb41-4943-badf-c16d2918a5d6	priority	100
57e636f1-5997-430d-82a3-426574f8b002	1d7204ef-bb41-4943-badf-c16d2918a5d6	certificate	MIICpTCCAY0CBgGdThJ6MTANBgkqhkiG9w0BAQsFADAWMRQwEgYDVQQDDAt2ZXJtZWctc2lyaDAeFw0yNjA0MDIxMjAwMjdaFw0zNjA0MDIxMjAyMDdaMBYxFDASBgNVBAMMC3Zlcm1lZy1zaXJoMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1PwlhK9ZF1eUKqIqYvrJge9iQtWtoTksjKfSe/6aaZd0IwtYwpi/GGgPrOE6i2zZx6kBJibBHTj1CWXNNW/HrQO6ZIBA33P6b9qoWXpm1Gi1H5Ml/N5cAMoEWfZC6pkyhjC0veV5PmtQcMR6pUovUNMwUhNKyvpoYaWKCd+l8P23okg27rY2SYGdK9sZYHZWBBiOwde91+sIX2mGki5sYsApY4YDJbL3qlMkN/VgVp+E75dD3Otl9/cUe8/hv3DyFzKten9Z7BO8BNQekSjmVI5tGwi+AjsUvqIKsBQFmKocs6mwfALDFQuXGNwQ/Sj1pPK19rWLW8JmrVETN8sLoQIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQB3z179cHMzBWAffb/YufQlf9Of/CIVM4MrxDIdiU9JsH27uwpQ9sTr+0Ba0gw4qKTRj+5xPFUdHvIN7IJ9cCVB1tijSDf5ui3J/GMc/8SMD7MGK5Xamyl/ihpCtCtIGvOD+p9ZD57crN0lcIKOavXVWHrsjOA8NTdEmlKYpwj7Kap5IMvO8xAC9MbGxcWU/9C+gaZ924sZEzYZbkfRzDc96x6OA66E15qLp0/SKaBC2lM2onl4jD8AsmChUw4k25wzrH74pPsD4aDdy3OoYaU66rMLAwPseMDhEZl3uLXk72g8KKodqAO3mQzWQ6+pUCuL2kprpQGeSqXqozYElKHr
f20f7a31-5795-4fc0-9b40-76da2997d3a9	1d7204ef-bb41-4943-badf-c16d2918a5d6	privateKey	MIIEowIBAAKCAQEA1PwlhK9ZF1eUKqIqYvrJge9iQtWtoTksjKfSe/6aaZd0IwtYwpi/GGgPrOE6i2zZx6kBJibBHTj1CWXNNW/HrQO6ZIBA33P6b9qoWXpm1Gi1H5Ml/N5cAMoEWfZC6pkyhjC0veV5PmtQcMR6pUovUNMwUhNKyvpoYaWKCd+l8P23okg27rY2SYGdK9sZYHZWBBiOwde91+sIX2mGki5sYsApY4YDJbL3qlMkN/VgVp+E75dD3Otl9/cUe8/hv3DyFzKten9Z7BO8BNQekSjmVI5tGwi+AjsUvqIKsBQFmKocs6mwfALDFQuXGNwQ/Sj1pPK19rWLW8JmrVETN8sLoQIDAQABAoIBABMWGYKfeBtoZMXBTI0cLkyvmB2nKm0lQ4HDVFB6S3ok8WpmjOi7aXyVbrouYOG3unhzA8BYfrvQq9zQu6gLQViW2fBBsg6URSAa9zU1i9uDGqAevqu/fX0wnV02fV6qpeVyne/ajZfzY/0HDnqbgEv88PqZ8fzoncwKWqlx2lwTJpxE5R2DumIaWEFTSVpognbTyY20RfQHxd86tw5g22jlBhbpgAQfmKXc4hGTi9rCJT4pegGeautduOTRhGLqmRZw6pk3fghYi1QVoLrRvQRs3AMqM9M4azZXIMP6DOUw35+VOmCOiBJtBRuzzsvycFYrQpK09g59+Mw3O8JXd9UCgYEA+d1zJQn5khl4ZuFZpUYDUCIhpRhvUg255p5OBL5q+G7yG3sN6hiQHHsn8X6kXLcg6mKuo806P6LCjuEsgYUnjlyT9IoF9vBnPEaw1/LP0CXzCKJWMsPzKNdjLTv8X5BTR5BKjv0XhS2AvJd1mOTVmsrcC4WC12iRfu4dd7FnQosCgYEA2jbiLGvqBbRMPKA45C9KfZBxCIuOiHVV4cPfH53Nv87/IvbqQunYgLdn4KANK5/uMTmqVCsMLzDeB4UsoTNQJU6xVVT8tdp6KuP5p/pB532jyT+3g3dI/gwFJfAcqrrNy78fZ68WzcBDsUg2+oZg2u80DmTWyIxGg08WqlH8TAMCgYBXDnM56nnMD5fFsKp9TSGGX/38+cB/hEzLL0jbmkTG/lDYhk1YzOoZIkfOemNl8mBDidJzO+QZm+nRwl6xWeVoUpUyVIyzdxthAvhGpVEGotJEpdsGoQMtra3eatIJsc1yV7HClCgHvMzn6JWOidxqrFdypDfsOYDICsq1k1f49QKBgCQwmAAQAabiiQZA+E53vV3nt6dYJdJhy1V++6EttbLK7Ktq0d05FSv7vuGVCbojcwh87M+6t/GXpCsRHh65+N/HFkf1qVernTlBx+Tg708qGiDFTXUjMlrXuX7aPJbgFkNlNhsnAZwr984OEPgpkyScKUD93lUyVntugW7L3BDrAoGBALLZ5P+1s/AP9+goowr3TWttWrM/QfnRNVJOvgEiZa9Gj9GWkvviZgi4AV+JxM+hmDGnYQ5mg1buaBpvq77WArtI/O9m2rL1D5kTiZ/+PHxMfirvlraLgTN7AeYcVg9wfUWPKutEukdRTMzI0DW9qmnD0od+ohDdKYjn/rC5GMhj
ce3a5e04-924c-4b55-8ffd-179ece787949	1a1cfd54-e196-4d5f-b5a0-df44d3d386d3	allowed-protocol-mapper-types	oidc-full-name-mapper
bbc5891b-0ea9-408d-aca5-d95fab6b40f6	1a1cfd54-e196-4d5f-b5a0-df44d3d386d3	allowed-protocol-mapper-types	oidc-usermodel-attribute-mapper
4945ffc9-98ee-45b3-9cd5-7acc5c322166	1a1cfd54-e196-4d5f-b5a0-df44d3d386d3	allowed-protocol-mapper-types	saml-user-property-mapper
084b119e-8fa5-4c2e-8cca-e661dcc15352	1a1cfd54-e196-4d5f-b5a0-df44d3d386d3	allowed-protocol-mapper-types	oidc-address-mapper
735aefbf-92c3-49d4-b8a5-403649f525fe	1a1cfd54-e196-4d5f-b5a0-df44d3d386d3	allowed-protocol-mapper-types	oidc-usermodel-property-mapper
b001e626-b1b5-4158-9a03-4f3501ab2915	1a1cfd54-e196-4d5f-b5a0-df44d3d386d3	allowed-protocol-mapper-types	oidc-sha256-pairwise-sub-mapper
0f7a769d-e571-4396-bcb7-77ac546dc239	1a1cfd54-e196-4d5f-b5a0-df44d3d386d3	allowed-protocol-mapper-types	saml-user-attribute-mapper
0c75d3d2-7796-40db-8162-3d02da5946ea	1a1cfd54-e196-4d5f-b5a0-df44d3d386d3	allowed-protocol-mapper-types	saml-role-list-mapper
f6b37e29-6148-4dc8-a315-e553b634eacf	9be032d4-5e20-43a9-a12c-e5e6cd980f66	max-clients	200
950ea9b6-0a2b-4827-9713-649c033ec25e	3c6a8ac1-73f7-4340-81f6-77eac09652a7	allowed-protocol-mapper-types	saml-role-list-mapper
1322c228-48de-4e30-8917-7ef3b240d721	3c6a8ac1-73f7-4340-81f6-77eac09652a7	allowed-protocol-mapper-types	oidc-usermodel-attribute-mapper
a5f8190a-24d3-482c-a13c-4738106a3e35	3c6a8ac1-73f7-4340-81f6-77eac09652a7	allowed-protocol-mapper-types	saml-user-property-mapper
209d2f72-8f8c-4b69-99a3-0c8cd78e5578	3c6a8ac1-73f7-4340-81f6-77eac09652a7	allowed-protocol-mapper-types	oidc-usermodel-property-mapper
16281634-36a1-47eb-9ea1-ba0f71152c50	3c6a8ac1-73f7-4340-81f6-77eac09652a7	allowed-protocol-mapper-types	oidc-full-name-mapper
cc1baea8-2131-4983-9ba3-1996d1b6a877	3c6a8ac1-73f7-4340-81f6-77eac09652a7	allowed-protocol-mapper-types	oidc-address-mapper
c4fa04f8-3070-418e-be74-57816d8e17e4	3c6a8ac1-73f7-4340-81f6-77eac09652a7	allowed-protocol-mapper-types	saml-user-attribute-mapper
3a4eb32d-71d8-43dd-bc45-640ac0562374	3c6a8ac1-73f7-4340-81f6-77eac09652a7	allowed-protocol-mapper-types	oidc-sha256-pairwise-sub-mapper
a7c9678c-3ff2-459c-9683-8cf089d45ebb	248c5ba4-56fa-4329-a6d1-6980bf16a0d2	allow-default-scopes	true
b0cfe9e2-12f4-4477-bcc9-4e0e6b457dbf	c067beb3-4889-4f25-bcef-a3365eb8af57	allow-default-scopes	true
4951894c-ae67-4f78-812f-95bcbc4b42df	26d9ef65-3047-4d52-976a-cda2adc94203	client-uris-must-match	true
8c8a7269-efb8-4471-9d14-447be8e9a396	26d9ef65-3047-4d52-976a-cda2adc94203	host-sending-registration-request-must-match	true
\.


--
-- Data for Name: composite_role; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.composite_role (composite, child_role) FROM stdin;
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	68526cfe-f879-4c7f-8954-9b554e86e2e1
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	e48be305-0bbe-4901-b291-1570bfd68155
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	16e0e737-d2fb-426f-9acf-e1a40c920f8e
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	5358b091-72b0-4dbd-97d4-b66e8cb62b92
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	dc7b2d59-7e41-445a-b5b7-7338af4125b4
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	d57599e3-984a-47ad-a1ba-2ac82577909b
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	f27c98b4-007c-4702-bb56-ff755d75a753
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	567dd811-2bf4-4762-8263-867b5a7093a5
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	075a0781-c16a-41fa-b4a8-e28ee56a9ae0
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	7e90c424-dadc-4e66-a014-cf04e24bd46d
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	cb65c285-7f30-414f-b3b5-073da28dc519
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	299e6300-3f6b-48ac-93c4-2e41fe9d7a34
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	e05a84ec-a99d-4d64-897d-abbc80c3179d
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	0a78b014-b1d9-44c8-905f-1570ec6ae5f8
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	722e55ab-a84a-48c5-869e-21fcd5918007
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	21245df4-2d74-460f-a43c-b17da0d05e4d
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	1d544440-dd09-41d4-a9f4-045050928a8e
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	c866a867-4e32-4ae7-94a7-b944f59a5af7
5358b091-72b0-4dbd-97d4-b66e8cb62b92	c866a867-4e32-4ae7-94a7-b944f59a5af7
5358b091-72b0-4dbd-97d4-b66e8cb62b92	722e55ab-a84a-48c5-869e-21fcd5918007
782cb36d-398b-422e-8a8d-1c0d950eeaed	feb0b02c-eca2-4af7-96bb-f3a88b728e4f
dc7b2d59-7e41-445a-b5b7-7338af4125b4	21245df4-2d74-460f-a43c-b17da0d05e4d
782cb36d-398b-422e-8a8d-1c0d950eeaed	f0ae8753-c8b8-4b37-9c6c-408b0181cad2
f0ae8753-c8b8-4b37-9c6c-408b0181cad2	29e3150b-4503-4913-ae66-665cce96db99
9c4baf6c-27a0-4956-9868-e4173f7ee4e0	340930a2-4bd0-4a70-8df6-d30caabf761e
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	ef6173fa-0da3-4775-bd7b-c69a1b7505bf
782cb36d-398b-422e-8a8d-1c0d950eeaed	e6535714-4142-4244-9960-43374ffe3341
782cb36d-398b-422e-8a8d-1c0d950eeaed	7d3bd85f-bc01-40a0-89ff-574604983668
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	63213da9-3497-4b71-89b5-4d58e9065956
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	ec7ccbfa-e533-4174-98b3-6586901af646
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	c4a3b88c-a3d2-47af-97a9-4afbed942e73
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	606ed14a-1880-4188-b8f0-66dd27d9d0ed
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	d694e99b-422d-44d5-a1fb-a3b0e9393014
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	13ec011e-12b4-4b03-8558-7859639efb50
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	fbe5efd5-3eba-4129-a6df-c8d2bffc9a7c
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	38a63893-0ffd-4ea1-90e7-94ce4dfcb76a
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	8133dd44-350f-4602-8f5e-4b8c11dcecbf
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	29c28f4d-aaba-4b54-ba7b-52e56744e15e
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	bd0055cd-991b-4ddf-9a60-21dec459a050
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	a3b2ccf6-8171-4223-80cc-7780e3c49bc9
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	7cebb432-8fc5-4bac-aba9-d706b0382198
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	af66da69-ca6b-4d6c-8ea7-546d609d20f1
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	f5049d9a-2d0e-4e4c-a5ce-d2ea910105b8
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	6e8470e7-94a3-4442-a0ef-0c1fc1542c82
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	e8da2bae-ff18-49dd-8eee-d82201c339ae
606ed14a-1880-4188-b8f0-66dd27d9d0ed	f5049d9a-2d0e-4e4c-a5ce-d2ea910105b8
c4a3b88c-a3d2-47af-97a9-4afbed942e73	af66da69-ca6b-4d6c-8ea7-546d609d20f1
c4a3b88c-a3d2-47af-97a9-4afbed942e73	e8da2bae-ff18-49dd-8eee-d82201c339ae
6a4cee8b-2975-479b-a0c0-337607d3cc79	23ccd3a2-4d76-47b7-91df-d76405dc3208
6a4cee8b-2975-479b-a0c0-337607d3cc79	39448f9a-88ce-4569-8836-77a8a973e99c
6a4cee8b-2975-479b-a0c0-337607d3cc79	db75210c-d922-4818-950f-c65c23acf8a7
6a4cee8b-2975-479b-a0c0-337607d3cc79	a5a3bb87-98c1-4ce2-b831-c234e633873e
6a4cee8b-2975-479b-a0c0-337607d3cc79	f1f1e25b-65e6-490a-a904-18165e8019c9
6a4cee8b-2975-479b-a0c0-337607d3cc79	6a46625d-3e93-498b-8ad1-242345e9f155
6a4cee8b-2975-479b-a0c0-337607d3cc79	f6bf7d05-7a13-444d-9c74-1e1628ae0465
6a4cee8b-2975-479b-a0c0-337607d3cc79	fbb72d15-a12b-4f22-b1fa-37c676bd8999
6a4cee8b-2975-479b-a0c0-337607d3cc79	b6fe5755-5ba6-4e45-8b32-81152b8036d9
6a4cee8b-2975-479b-a0c0-337607d3cc79	d9313716-42fa-4320-8f59-0b179067ebb5
6a4cee8b-2975-479b-a0c0-337607d3cc79	cdbc736f-d74c-4739-a27a-03fdf1a5b8a7
6a4cee8b-2975-479b-a0c0-337607d3cc79	66d55d56-81bb-4e67-9119-e22259fc6a69
6a4cee8b-2975-479b-a0c0-337607d3cc79	6b64b653-7e22-4947-a741-12141e678708
6a4cee8b-2975-479b-a0c0-337607d3cc79	dd9f9396-894c-4e41-8914-d99c8ff81dc1
6a4cee8b-2975-479b-a0c0-337607d3cc79	c179d2da-9871-4716-991c-60a3edffd2b1
6a4cee8b-2975-479b-a0c0-337607d3cc79	aaff2419-1106-407b-a71e-851fc9d9a31f
6a4cee8b-2975-479b-a0c0-337607d3cc79	fc1116cf-a463-4c14-8b77-deb407fdb63a
1a0603b9-d25d-4576-9d1b-3f6258a4f87e	1eddff7c-7e5b-42e6-9b14-7b1c56f26ca8
a5a3bb87-98c1-4ce2-b831-c234e633873e	c179d2da-9871-4716-991c-60a3edffd2b1
db75210c-d922-4818-950f-c65c23acf8a7	fc1116cf-a463-4c14-8b77-deb407fdb63a
db75210c-d922-4818-950f-c65c23acf8a7	dd9f9396-894c-4e41-8914-d99c8ff81dc1
1a0603b9-d25d-4576-9d1b-3f6258a4f87e	1ce1b465-8cf1-4fac-aba9-9c315ab34626
1ce1b465-8cf1-4fac-aba9-9c315ab34626	c7b13470-c31e-4e09-8481-585a5cb07417
5ea8547c-7eff-48cb-9c9b-a31b391fc7e1	4756c2be-6e3c-483f-8bc8-bbf9d889c650
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	d019aed4-5464-45f0-a641-9225a6189a45
6a4cee8b-2975-479b-a0c0-337607d3cc79	8d2b7e00-7d00-4984-ba2a-896c5cc0855b
1a0603b9-d25d-4576-9d1b-3f6258a4f87e	51615ae0-b8a9-4a99-8de7-97d4959f9e3b
1a0603b9-d25d-4576-9d1b-3f6258a4f87e	255c2aa1-ad79-4266-a56c-c5a7d4c8e260
\.


--
-- Data for Name: contract_types; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.contract_types (id, description, name) FROM stdin;
1	Contrat a Duree Indeterminee	CDI
2	Contrat a Duree Determinee	CDD
3	Stage d'Initiation a la Vie Professionnelle	SIVP
\.


--
-- Data for Name: credential; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.credential (id, salt, type, user_id, created_date, user_label, secret_data, credential_data, priority) FROM stdin;
5cfef384-a690-439d-a83b-611ae15683be	\N	password	b622d56d-af41-42cb-a289-b722f06cfc46	1775131325732	\N	{"value":"HgPK9DPvUdeHMDmo59xSaYN8SjDP5yCZD1dWJQdI5PgdZoE9ItOqid5z4QyD/LmBXIioSgQdbWQIMdW87t66yg==","salt":"yzQ8CpRo+feEwmCbUT92xw==","additionalParameters":{}}	{"hashIterations":210000,"algorithm":"pbkdf2-sha512","additionalParameters":{}}	10
dcf7c7ea-a31f-4849-86c2-530ad4547ca5	\N	password	337bad47-9d8d-45bd-acac-b20997ee568b	1775131326074	\N	{"value":"0FCcgbA8a4IbkPO3Xy0l8VeCl0b4WLMXSm1XlKG4BmDnliAZBvE4umrsQEjF/kCsu/FEpYEoJ5GT5db6kbw2pg==","salt":"L86+W7dy8mC/zUTJhV8uLg==","additionalParameters":{}}	{"hashIterations":210000,"algorithm":"pbkdf2-sha512","additionalParameters":{}}	10
8ff9c7a4-3f95-465a-a4ab-d9fc5cdcfb08	\N	password	662f0129-70d9-480f-bd5f-8c13163e5d99	1775131326421	\N	{"value":"4Se9KGQ7F34Qa5tOrR0LcLgcbahIYeQdzSUbqgJOcdWTrFugxf+PuJwxlHwydCHsm5qKAUyypFd33cLHRVAU6A==","salt":"3nbsyozQUjSZ0TFkzx6gOg==","additionalParameters":{}}	{"hashIterations":210000,"algorithm":"pbkdf2-sha512","additionalParameters":{}}	10
561c42b1-af22-4aeb-89c9-875cbb3bff5b	\N	password	f5121e97-fd33-4fc0-b11d-3e47ea5f485a	1775131326765	\N	{"value":"1ychakGAu54W9WTWNp2DeQ4Lrp9N95bjUGdBP64Lhft5m+6463wp8MBAOmmSsvRLXoXKVnPya2RJOSXl3BErPg==","salt":"H+8YChMHuQdIxzGljRfhGw==","additionalParameters":{}}	{"hashIterations":210000,"algorithm":"pbkdf2-sha512","additionalParameters":{}}	10
44f4e7ac-1b8b-4481-b3cc-1cd7bfe551bb	\N	password	23339660-b61a-4379-99be-262522d6d506	1775131328950	\N	{"value":"3rVicsousYnV4KcHdT6UYu2sSYnl87aCn/WdDmfvQNtDAgbpS/d3oR87ttWVhJyGbbDiyBFeGif4qMil+vUagQ==","salt":"ERKJJf5e0NiAGVIss56IRA==","additionalParameters":{}}	{"hashIterations":210000,"algorithm":"pbkdf2-sha512","additionalParameters":{}}	10
45575950-5e69-4b72-bfa2-1e29bfb9461e	\N	password	ed68e8ce-6e3f-447e-b6b9-a492ee46b5d8	1775131423581	\N	{"value":"252j3ulAaRQpNXcBwBWbQIEHJNyectHUT3+xdCjfxyhva73YXICem/ETiRwhfOoLzPTuoxc2lgHsMpElWBPPPw==","salt":"iQgHdaRDNZpFOen5XY3apw==","additionalParameters":{}}	{"hashIterations":210000,"algorithm":"pbkdf2-sha512","additionalParameters":{}}	10
\.


--
-- Data for Name: databasechangelog; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.databasechangelog (id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, comments, tag, liquibase, contexts, labels, deployment_id) FROM stdin;
1.0.0.Final-KEYCLOAK-5461	sthorger@redhat.com	META-INF/jpa-changelog-1.0.0.Final.xml	2026-04-02 12:01:54.008335	1	EXECUTED	9:6f1016664e21e16d26517a4418f5e3df	createTable tableName=APPLICATION_DEFAULT_ROLES; createTable tableName=CLIENT; createTable tableName=CLIENT_SESSION; createTable tableName=CLIENT_SESSION_ROLE; createTable tableName=COMPOSITE_ROLE; createTable tableName=CREDENTIAL; createTable tab...		\N	4.25.1	\N	\N	5131312613
1.0.0.Final-KEYCLOAK-5461	sthorger@redhat.com	META-INF/db2-jpa-changelog-1.0.0.Final.xml	2026-04-02 12:01:54.064424	2	MARK_RAN	9:828775b1596a07d1200ba1d49e5e3941	createTable tableName=APPLICATION_DEFAULT_ROLES; createTable tableName=CLIENT; createTable tableName=CLIENT_SESSION; createTable tableName=CLIENT_SESSION_ROLE; createTable tableName=COMPOSITE_ROLE; createTable tableName=CREDENTIAL; createTable tab...		\N	4.25.1	\N	\N	5131312613
1.1.0.Beta1	sthorger@redhat.com	META-INF/jpa-changelog-1.1.0.Beta1.xml	2026-04-02 12:01:54.21018	3	EXECUTED	9:5f090e44a7d595883c1fb61f4b41fd38	delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION; createTable tableName=CLIENT_ATTRIBUTES; createTable tableName=CLIENT_SESSION_NOTE; createTable tableName=APP_NODE_REGISTRATIONS; addColumn table...		\N	4.25.1	\N	\N	5131312613
1.1.0.Final	sthorger@redhat.com	META-INF/jpa-changelog-1.1.0.Final.xml	2026-04-02 12:01:54.223896	4	EXECUTED	9:c07e577387a3d2c04d1adc9aaad8730e	renameColumn newColumnName=EVENT_TIME, oldColumnName=TIME, tableName=EVENT_ENTITY		\N	4.25.1	\N	\N	5131312613
1.2.0.Beta1	psilva@redhat.com	META-INF/jpa-changelog-1.2.0.Beta1.xml	2026-04-02 12:01:54.491049	5	EXECUTED	9:b68ce996c655922dbcd2fe6b6ae72686	delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION; createTable tableName=PROTOCOL_MAPPER; createTable tableName=PROTOCOL_MAPPER_CONFIG; createTable tableName=...		\N	4.25.1	\N	\N	5131312613
1.2.0.Beta1	psilva@redhat.com	META-INF/db2-jpa-changelog-1.2.0.Beta1.xml	2026-04-02 12:01:54.506508	6	MARK_RAN	9:543b5c9989f024fe35c6f6c5a97de88e	delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION; createTable tableName=PROTOCOL_MAPPER; createTable tableName=PROTOCOL_MAPPER_CONFIG; createTable tableName=...		\N	4.25.1	\N	\N	5131312613
1.2.0.RC1	bburke@redhat.com	META-INF/jpa-changelog-1.2.0.CR1.xml	2026-04-02 12:01:54.741857	7	EXECUTED	9:765afebbe21cf5bbca048e632df38336	delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete tableName=USER_SESSION; createTable tableName=MIGRATION_MODEL; createTable tableName=IDENTITY_P...		\N	4.25.1	\N	\N	5131312613
1.2.0.RC1	bburke@redhat.com	META-INF/db2-jpa-changelog-1.2.0.CR1.xml	2026-04-02 12:01:54.751764	8	MARK_RAN	9:db4a145ba11a6fdaefb397f6dbf829a1	delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete tableName=USER_SESSION; createTable tableName=MIGRATION_MODEL; createTable tableName=IDENTITY_P...		\N	4.25.1	\N	\N	5131312613
1.2.0.Final	keycloak	META-INF/jpa-changelog-1.2.0.Final.xml	2026-04-02 12:01:54.775032	9	EXECUTED	9:9d05c7be10cdb873f8bcb41bc3a8ab23	update tableName=CLIENT; update tableName=CLIENT; update tableName=CLIENT		\N	4.25.1	\N	\N	5131312613
1.3.0	bburke@redhat.com	META-INF/jpa-changelog-1.3.0.xml	2026-04-02 12:01:55.039815	10	EXECUTED	9:18593702353128d53111f9b1ff0b82b8	delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_PROT_MAPPER; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete tableName=USER_SESSION; createTable tableName=ADMI...		\N	4.25.1	\N	\N	5131312613
1.4.0	bburke@redhat.com	META-INF/jpa-changelog-1.4.0.xml	2026-04-02 12:01:55.222274	11	EXECUTED	9:6122efe5f090e41a85c0f1c9e52cbb62	delete tableName=CLIENT_SESSION_AUTH_STATUS; delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_PROT_MAPPER; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete table...		\N	4.25.1	\N	\N	5131312613
1.4.0	bburke@redhat.com	META-INF/db2-jpa-changelog-1.4.0.xml	2026-04-02 12:01:55.241233	12	MARK_RAN	9:e1ff28bf7568451453f844c5d54bb0b5	delete tableName=CLIENT_SESSION_AUTH_STATUS; delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_PROT_MAPPER; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete table...		\N	4.25.1	\N	\N	5131312613
1.5.0	bburke@redhat.com	META-INF/jpa-changelog-1.5.0.xml	2026-04-02 12:01:55.334231	13	EXECUTED	9:7af32cd8957fbc069f796b61217483fd	delete tableName=CLIENT_SESSION_AUTH_STATUS; delete tableName=CLIENT_SESSION_ROLE; delete tableName=CLIENT_SESSION_PROT_MAPPER; delete tableName=CLIENT_SESSION_NOTE; delete tableName=CLIENT_SESSION; delete tableName=USER_SESSION_NOTE; delete table...		\N	4.25.1	\N	\N	5131312613
1.6.1_from15	mposolda@redhat.com	META-INF/jpa-changelog-1.6.1.xml	2026-04-02 12:01:55.406904	14	EXECUTED	9:6005e15e84714cd83226bf7879f54190	addColumn tableName=REALM; addColumn tableName=KEYCLOAK_ROLE; addColumn tableName=CLIENT; createTable tableName=OFFLINE_USER_SESSION; createTable tableName=OFFLINE_CLIENT_SESSION; addPrimaryKey constraintName=CONSTRAINT_OFFL_US_SES_PK2, tableName=...		\N	4.25.1	\N	\N	5131312613
1.6.1_from16-pre	mposolda@redhat.com	META-INF/jpa-changelog-1.6.1.xml	2026-04-02 12:01:55.413339	15	MARK_RAN	9:bf656f5a2b055d07f314431cae76f06c	delete tableName=OFFLINE_CLIENT_SESSION; delete tableName=OFFLINE_USER_SESSION		\N	4.25.1	\N	\N	5131312613
1.6.1_from16	mposolda@redhat.com	META-INF/jpa-changelog-1.6.1.xml	2026-04-02 12:01:55.421311	16	MARK_RAN	9:f8dadc9284440469dcf71e25ca6ab99b	dropPrimaryKey constraintName=CONSTRAINT_OFFLINE_US_SES_PK, tableName=OFFLINE_USER_SESSION; dropPrimaryKey constraintName=CONSTRAINT_OFFLINE_CL_SES_PK, tableName=OFFLINE_CLIENT_SESSION; addColumn tableName=OFFLINE_USER_SESSION; update tableName=OF...		\N	4.25.1	\N	\N	5131312613
1.6.1	mposolda@redhat.com	META-INF/jpa-changelog-1.6.1.xml	2026-04-02 12:01:55.430267	17	EXECUTED	9:d41d8cd98f00b204e9800998ecf8427e	empty		\N	4.25.1	\N	\N	5131312613
1.7.0	bburke@redhat.com	META-INF/jpa-changelog-1.7.0.xml	2026-04-02 12:01:55.638586	18	EXECUTED	9:3368ff0be4c2855ee2dd9ca813b38d8e	createTable tableName=KEYCLOAK_GROUP; createTable tableName=GROUP_ROLE_MAPPING; createTable tableName=GROUP_ATTRIBUTE; createTable tableName=USER_GROUP_MEMBERSHIP; createTable tableName=REALM_DEFAULT_GROUPS; addColumn tableName=IDENTITY_PROVIDER; ...		\N	4.25.1	\N	\N	5131312613
1.8.0	mposolda@redhat.com	META-INF/jpa-changelog-1.8.0.xml	2026-04-02 12:01:55.768167	19	EXECUTED	9:8ac2fb5dd030b24c0570a763ed75ed20	addColumn tableName=IDENTITY_PROVIDER; createTable tableName=CLIENT_TEMPLATE; createTable tableName=CLIENT_TEMPLATE_ATTRIBUTES; createTable tableName=TEMPLATE_SCOPE_MAPPING; dropNotNullConstraint columnName=CLIENT_ID, tableName=PROTOCOL_MAPPER; ad...		\N	4.25.1	\N	\N	5131312613
1.8.0-2	keycloak	META-INF/jpa-changelog-1.8.0.xml	2026-04-02 12:01:55.782671	20	EXECUTED	9:f91ddca9b19743db60e3057679810e6c	dropDefaultValue columnName=ALGORITHM, tableName=CREDENTIAL; update tableName=CREDENTIAL		\N	4.25.1	\N	\N	5131312613
24.0.0-9758-2	keycloak	META-INF/jpa-changelog-24.0.0.xml	2026-04-02 12:01:58.771115	119	EXECUTED	9:bf0fdee10afdf597a987adbf291db7b2	customChange		\N	4.25.1	\N	\N	5131312613
1.8.0	mposolda@redhat.com	META-INF/db2-jpa-changelog-1.8.0.xml	2026-04-02 12:01:55.790141	21	MARK_RAN	9:831e82914316dc8a57dc09d755f23c51	addColumn tableName=IDENTITY_PROVIDER; createTable tableName=CLIENT_TEMPLATE; createTable tableName=CLIENT_TEMPLATE_ATTRIBUTES; createTable tableName=TEMPLATE_SCOPE_MAPPING; dropNotNullConstraint columnName=CLIENT_ID, tableName=PROTOCOL_MAPPER; ad...		\N	4.25.1	\N	\N	5131312613
1.8.0-2	keycloak	META-INF/db2-jpa-changelog-1.8.0.xml	2026-04-02 12:01:55.797198	22	MARK_RAN	9:f91ddca9b19743db60e3057679810e6c	dropDefaultValue columnName=ALGORITHM, tableName=CREDENTIAL; update tableName=CREDENTIAL		\N	4.25.1	\N	\N	5131312613
1.9.0	mposolda@redhat.com	META-INF/jpa-changelog-1.9.0.xml	2026-04-02 12:01:55.86141	23	EXECUTED	9:bc3d0f9e823a69dc21e23e94c7a94bb1	update tableName=REALM; update tableName=REALM; update tableName=REALM; update tableName=REALM; update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=REALM; update tableName=REALM; customChange; dr...		\N	4.25.1	\N	\N	5131312613
1.9.1	keycloak	META-INF/jpa-changelog-1.9.1.xml	2026-04-02 12:01:55.886043	24	EXECUTED	9:c9999da42f543575ab790e76439a2679	modifyDataType columnName=PRIVATE_KEY, tableName=REALM; modifyDataType columnName=PUBLIC_KEY, tableName=REALM; modifyDataType columnName=CERTIFICATE, tableName=REALM		\N	4.25.1	\N	\N	5131312613
1.9.1	keycloak	META-INF/db2-jpa-changelog-1.9.1.xml	2026-04-02 12:01:55.890509	25	MARK_RAN	9:0d6c65c6f58732d81569e77b10ba301d	modifyDataType columnName=PRIVATE_KEY, tableName=REALM; modifyDataType columnName=CERTIFICATE, tableName=REALM		\N	4.25.1	\N	\N	5131312613
1.9.2	keycloak	META-INF/jpa-changelog-1.9.2.xml	2026-04-02 12:01:55.996144	26	EXECUTED	9:fc576660fc016ae53d2d4778d84d86d0	createIndex indexName=IDX_USER_EMAIL, tableName=USER_ENTITY; createIndex indexName=IDX_USER_ROLE_MAPPING, tableName=USER_ROLE_MAPPING; createIndex indexName=IDX_USER_GROUP_MAPPING, tableName=USER_GROUP_MEMBERSHIP; createIndex indexName=IDX_USER_CO...		\N	4.25.1	\N	\N	5131312613
authz-2.0.0	psilva@redhat.com	META-INF/jpa-changelog-authz-2.0.0.xml	2026-04-02 12:01:56.206192	27	EXECUTED	9:43ed6b0da89ff77206289e87eaa9c024	createTable tableName=RESOURCE_SERVER; addPrimaryKey constraintName=CONSTRAINT_FARS, tableName=RESOURCE_SERVER; addUniqueConstraint constraintName=UK_AU8TT6T700S9V50BU18WS5HA6, tableName=RESOURCE_SERVER; createTable tableName=RESOURCE_SERVER_RESOU...		\N	4.25.1	\N	\N	5131312613
authz-2.5.1	psilva@redhat.com	META-INF/jpa-changelog-authz-2.5.1.xml	2026-04-02 12:01:56.214645	28	EXECUTED	9:44bae577f551b3738740281eceb4ea70	update tableName=RESOURCE_SERVER_POLICY		\N	4.25.1	\N	\N	5131312613
2.1.0-KEYCLOAK-5461	bburke@redhat.com	META-INF/jpa-changelog-2.1.0.xml	2026-04-02 12:01:56.388052	29	EXECUTED	9:bd88e1f833df0420b01e114533aee5e8	createTable tableName=BROKER_LINK; createTable tableName=FED_USER_ATTRIBUTE; createTable tableName=FED_USER_CONSENT; createTable tableName=FED_USER_CONSENT_ROLE; createTable tableName=FED_USER_CONSENT_PROT_MAPPER; createTable tableName=FED_USER_CR...		\N	4.25.1	\N	\N	5131312613
2.2.0	bburke@redhat.com	META-INF/jpa-changelog-2.2.0.xml	2026-04-02 12:01:56.4232	30	EXECUTED	9:a7022af5267f019d020edfe316ef4371	addColumn tableName=ADMIN_EVENT_ENTITY; createTable tableName=CREDENTIAL_ATTRIBUTE; createTable tableName=FED_CREDENTIAL_ATTRIBUTE; modifyDataType columnName=VALUE, tableName=CREDENTIAL; addForeignKeyConstraint baseTableName=FED_CREDENTIAL_ATTRIBU...		\N	4.25.1	\N	\N	5131312613
2.3.0	bburke@redhat.com	META-INF/jpa-changelog-2.3.0.xml	2026-04-02 12:01:56.491605	31	EXECUTED	9:fc155c394040654d6a79227e56f5e25a	createTable tableName=FEDERATED_USER; addPrimaryKey constraintName=CONSTR_FEDERATED_USER, tableName=FEDERATED_USER; dropDefaultValue columnName=TOTP, tableName=USER_ENTITY; dropColumn columnName=TOTP, tableName=USER_ENTITY; addColumn tableName=IDE...		\N	4.25.1	\N	\N	5131312613
2.4.0	bburke@redhat.com	META-INF/jpa-changelog-2.4.0.xml	2026-04-02 12:01:56.516413	32	EXECUTED	9:eac4ffb2a14795e5dc7b426063e54d88	customChange		\N	4.25.1	\N	\N	5131312613
2.5.0	bburke@redhat.com	META-INF/jpa-changelog-2.5.0.xml	2026-04-02 12:01:56.54253	33	EXECUTED	9:54937c05672568c4c64fc9524c1e9462	customChange; modifyDataType columnName=USER_ID, tableName=OFFLINE_USER_SESSION		\N	4.25.1	\N	\N	5131312613
2.5.0-unicode-oracle	hmlnarik@redhat.com	META-INF/jpa-changelog-2.5.0.xml	2026-04-02 12:01:56.553453	34	MARK_RAN	9:3a32bace77c84d7678d035a7f5a8084e	modifyDataType columnName=DESCRIPTION, tableName=AUTHENTICATION_FLOW; modifyDataType columnName=DESCRIPTION, tableName=CLIENT_TEMPLATE; modifyDataType columnName=DESCRIPTION, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=DESCRIPTION,...		\N	4.25.1	\N	\N	5131312613
2.5.0-unicode-other-dbs	hmlnarik@redhat.com	META-INF/jpa-changelog-2.5.0.xml	2026-04-02 12:01:56.669042	35	EXECUTED	9:33d72168746f81f98ae3a1e8e0ca3554	modifyDataType columnName=DESCRIPTION, tableName=AUTHENTICATION_FLOW; modifyDataType columnName=DESCRIPTION, tableName=CLIENT_TEMPLATE; modifyDataType columnName=DESCRIPTION, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=DESCRIPTION,...		\N	4.25.1	\N	\N	5131312613
2.5.0-duplicate-email-support	slawomir@dabek.name	META-INF/jpa-changelog-2.5.0.xml	2026-04-02 12:01:56.681584	36	EXECUTED	9:61b6d3d7a4c0e0024b0c839da283da0c	addColumn tableName=REALM		\N	4.25.1	\N	\N	5131312613
2.5.0-unique-group-names	hmlnarik@redhat.com	META-INF/jpa-changelog-2.5.0.xml	2026-04-02 12:01:56.700443	37	EXECUTED	9:8dcac7bdf7378e7d823cdfddebf72fda	addUniqueConstraint constraintName=SIBLING_NAMES, tableName=KEYCLOAK_GROUP		\N	4.25.1	\N	\N	5131312613
2.5.1	bburke@redhat.com	META-INF/jpa-changelog-2.5.1.xml	2026-04-02 12:01:56.713102	38	EXECUTED	9:a2b870802540cb3faa72098db5388af3	addColumn tableName=FED_USER_CONSENT		\N	4.25.1	\N	\N	5131312613
3.0.0	bburke@redhat.com	META-INF/jpa-changelog-3.0.0.xml	2026-04-02 12:01:56.723469	39	EXECUTED	9:132a67499ba24bcc54fb5cbdcfe7e4c0	addColumn tableName=IDENTITY_PROVIDER		\N	4.25.1	\N	\N	5131312613
3.2.0-fix	keycloak	META-INF/jpa-changelog-3.2.0.xml	2026-04-02 12:01:56.728153	40	MARK_RAN	9:938f894c032f5430f2b0fafb1a243462	addNotNullConstraint columnName=REALM_ID, tableName=CLIENT_INITIAL_ACCESS		\N	4.25.1	\N	\N	5131312613
3.2.0-fix-with-keycloak-5416	keycloak	META-INF/jpa-changelog-3.2.0.xml	2026-04-02 12:01:56.735695	41	MARK_RAN	9:845c332ff1874dc5d35974b0babf3006	dropIndex indexName=IDX_CLIENT_INIT_ACC_REALM, tableName=CLIENT_INITIAL_ACCESS; addNotNullConstraint columnName=REALM_ID, tableName=CLIENT_INITIAL_ACCESS; createIndex indexName=IDX_CLIENT_INIT_ACC_REALM, tableName=CLIENT_INITIAL_ACCESS		\N	4.25.1	\N	\N	5131312613
3.2.0-fix-offline-sessions	hmlnarik	META-INF/jpa-changelog-3.2.0.xml	2026-04-02 12:01:56.754482	42	EXECUTED	9:fc86359c079781adc577c5a217e4d04c	customChange		\N	4.25.1	\N	\N	5131312613
3.2.0-fixed	keycloak	META-INF/jpa-changelog-3.2.0.xml	2026-04-02 12:01:57.121102	43	EXECUTED	9:59a64800e3c0d09b825f8a3b444fa8f4	addColumn tableName=REALM; dropPrimaryKey constraintName=CONSTRAINT_OFFL_CL_SES_PK2, tableName=OFFLINE_CLIENT_SESSION; dropColumn columnName=CLIENT_SESSION_ID, tableName=OFFLINE_CLIENT_SESSION; addPrimaryKey constraintName=CONSTRAINT_OFFL_CL_SES_P...		\N	4.25.1	\N	\N	5131312613
3.3.0	keycloak	META-INF/jpa-changelog-3.3.0.xml	2026-04-02 12:01:57.133714	44	EXECUTED	9:d48d6da5c6ccf667807f633fe489ce88	addColumn tableName=USER_ENTITY		\N	4.25.1	\N	\N	5131312613
authz-3.4.0.CR1-resource-server-pk-change-part1	glavoie@gmail.com	META-INF/jpa-changelog-authz-3.4.0.CR1.xml	2026-04-02 12:01:57.149983	45	EXECUTED	9:dde36f7973e80d71fceee683bc5d2951	addColumn tableName=RESOURCE_SERVER_POLICY; addColumn tableName=RESOURCE_SERVER_RESOURCE; addColumn tableName=RESOURCE_SERVER_SCOPE		\N	4.25.1	\N	\N	5131312613
authz-3.4.0.CR1-resource-server-pk-change-part2-KEYCLOAK-6095	hmlnarik@redhat.com	META-INF/jpa-changelog-authz-3.4.0.CR1.xml	2026-04-02 12:01:57.16507	46	EXECUTED	9:b855e9b0a406b34fa323235a0cf4f640	customChange		\N	4.25.1	\N	\N	5131312613
authz-3.4.0.CR1-resource-server-pk-change-part3-fixed	glavoie@gmail.com	META-INF/jpa-changelog-authz-3.4.0.CR1.xml	2026-04-02 12:01:57.169553	47	MARK_RAN	9:51abbacd7b416c50c4421a8cabf7927e	dropIndex indexName=IDX_RES_SERV_POL_RES_SERV, tableName=RESOURCE_SERVER_POLICY; dropIndex indexName=IDX_RES_SRV_RES_RES_SRV, tableName=RESOURCE_SERVER_RESOURCE; dropIndex indexName=IDX_RES_SRV_SCOPE_RES_SRV, tableName=RESOURCE_SERVER_SCOPE		\N	4.25.1	\N	\N	5131312613
authz-3.4.0.CR1-resource-server-pk-change-part3-fixed-nodropindex	glavoie@gmail.com	META-INF/jpa-changelog-authz-3.4.0.CR1.xml	2026-04-02 12:01:57.246854	48	EXECUTED	9:bdc99e567b3398bac83263d375aad143	addNotNullConstraint columnName=RESOURCE_SERVER_CLIENT_ID, tableName=RESOURCE_SERVER_POLICY; addNotNullConstraint columnName=RESOURCE_SERVER_CLIENT_ID, tableName=RESOURCE_SERVER_RESOURCE; addNotNullConstraint columnName=RESOURCE_SERVER_CLIENT_ID, ...		\N	4.25.1	\N	\N	5131312613
authn-3.4.0.CR1-refresh-token-max-reuse	glavoie@gmail.com	META-INF/jpa-changelog-authz-3.4.0.CR1.xml	2026-04-02 12:01:57.256303	49	EXECUTED	9:d198654156881c46bfba39abd7769e69	addColumn tableName=REALM		\N	4.25.1	\N	\N	5131312613
3.4.0	keycloak	META-INF/jpa-changelog-3.4.0.xml	2026-04-02 12:01:57.354486	50	EXECUTED	9:cfdd8736332ccdd72c5256ccb42335db	addPrimaryKey constraintName=CONSTRAINT_REALM_DEFAULT_ROLES, tableName=REALM_DEFAULT_ROLES; addPrimaryKey constraintName=CONSTRAINT_COMPOSITE_ROLE, tableName=COMPOSITE_ROLE; addPrimaryKey constraintName=CONSTR_REALM_DEFAULT_GROUPS, tableName=REALM...		\N	4.25.1	\N	\N	5131312613
3.4.0-KEYCLOAK-5230	hmlnarik@redhat.com	META-INF/jpa-changelog-3.4.0.xml	2026-04-02 12:01:57.425931	51	EXECUTED	9:7c84de3d9bd84d7f077607c1a4dcb714	createIndex indexName=IDX_FU_ATTRIBUTE, tableName=FED_USER_ATTRIBUTE; createIndex indexName=IDX_FU_CONSENT, tableName=FED_USER_CONSENT; createIndex indexName=IDX_FU_CONSENT_RU, tableName=FED_USER_CONSENT; createIndex indexName=IDX_FU_CREDENTIAL, t...		\N	4.25.1	\N	\N	5131312613
3.4.1	psilva@redhat.com	META-INF/jpa-changelog-3.4.1.xml	2026-04-02 12:01:57.43403	52	EXECUTED	9:5a6bb36cbefb6a9d6928452c0852af2d	modifyDataType columnName=VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.25.1	\N	\N	5131312613
3.4.2	keycloak	META-INF/jpa-changelog-3.4.2.xml	2026-04-02 12:01:57.442332	53	EXECUTED	9:8f23e334dbc59f82e0a328373ca6ced0	update tableName=REALM		\N	4.25.1	\N	\N	5131312613
3.4.2-KEYCLOAK-5172	mkanis@redhat.com	META-INF/jpa-changelog-3.4.2.xml	2026-04-02 12:01:57.449182	54	EXECUTED	9:9156214268f09d970cdf0e1564d866af	update tableName=CLIENT		\N	4.25.1	\N	\N	5131312613
4.0.0-KEYCLOAK-6335	bburke@redhat.com	META-INF/jpa-changelog-4.0.0.xml	2026-04-02 12:01:57.466487	55	EXECUTED	9:db806613b1ed154826c02610b7dbdf74	createTable tableName=CLIENT_AUTH_FLOW_BINDINGS; addPrimaryKey constraintName=C_CLI_FLOW_BIND, tableName=CLIENT_AUTH_FLOW_BINDINGS		\N	4.25.1	\N	\N	5131312613
4.0.0-CLEANUP-UNUSED-TABLE	bburke@redhat.com	META-INF/jpa-changelog-4.0.0.xml	2026-04-02 12:01:57.478842	56	EXECUTED	9:229a041fb72d5beac76bb94a5fa709de	dropTable tableName=CLIENT_IDENTITY_PROV_MAPPING		\N	4.25.1	\N	\N	5131312613
4.0.0-KEYCLOAK-6228	bburke@redhat.com	META-INF/jpa-changelog-4.0.0.xml	2026-04-02 12:01:57.533479	57	EXECUTED	9:079899dade9c1e683f26b2aa9ca6ff04	dropUniqueConstraint constraintName=UK_JKUWUVD56ONTGSUHOGM8UEWRT, tableName=USER_CONSENT; dropNotNullConstraint columnName=CLIENT_ID, tableName=USER_CONSENT; addColumn tableName=USER_CONSENT; addUniqueConstraint constraintName=UK_JKUWUVD56ONTGSUHO...		\N	4.25.1	\N	\N	5131312613
4.0.0-KEYCLOAK-5579-fixed	mposolda@redhat.com	META-INF/jpa-changelog-4.0.0.xml	2026-04-02 12:01:57.917762	58	EXECUTED	9:139b79bcbbfe903bb1c2d2a4dbf001d9	dropForeignKeyConstraint baseTableName=CLIENT_TEMPLATE_ATTRIBUTES, constraintName=FK_CL_TEMPL_ATTR_TEMPL; renameTable newTableName=CLIENT_SCOPE_ATTRIBUTES, oldTableName=CLIENT_TEMPLATE_ATTRIBUTES; renameColumn newColumnName=SCOPE_ID, oldColumnName...		\N	4.25.1	\N	\N	5131312613
authz-4.0.0.CR1	psilva@redhat.com	META-INF/jpa-changelog-authz-4.0.0.CR1.xml	2026-04-02 12:01:57.975463	59	EXECUTED	9:b55738ad889860c625ba2bf483495a04	createTable tableName=RESOURCE_SERVER_PERM_TICKET; addPrimaryKey constraintName=CONSTRAINT_FAPMT, tableName=RESOURCE_SERVER_PERM_TICKET; addForeignKeyConstraint baseTableName=RESOURCE_SERVER_PERM_TICKET, constraintName=FK_FRSRHO213XCX4WNKOG82SSPMT...		\N	4.25.1	\N	\N	5131312613
authz-4.0.0.Beta3	psilva@redhat.com	META-INF/jpa-changelog-authz-4.0.0.Beta3.xml	2026-04-02 12:01:57.988813	60	EXECUTED	9:e0057eac39aa8fc8e09ac6cfa4ae15fe	addColumn tableName=RESOURCE_SERVER_POLICY; addColumn tableName=RESOURCE_SERVER_PERM_TICKET; addForeignKeyConstraint baseTableName=RESOURCE_SERVER_PERM_TICKET, constraintName=FK_FRSRPO2128CX4WNKOG82SSRFY, referencedTableName=RESOURCE_SERVER_POLICY		\N	4.25.1	\N	\N	5131312613
authz-4.2.0.Final	mhajas@redhat.com	META-INF/jpa-changelog-authz-4.2.0.Final.xml	2026-04-02 12:01:58.010325	61	EXECUTED	9:42a33806f3a0443fe0e7feeec821326c	createTable tableName=RESOURCE_URIS; addForeignKeyConstraint baseTableName=RESOURCE_URIS, constraintName=FK_RESOURCE_SERVER_URIS, referencedTableName=RESOURCE_SERVER_RESOURCE; customChange; dropColumn columnName=URI, tableName=RESOURCE_SERVER_RESO...		\N	4.25.1	\N	\N	5131312613
authz-4.2.0.Final-KEYCLOAK-9944	hmlnarik@redhat.com	META-INF/jpa-changelog-authz-4.2.0.Final.xml	2026-04-02 12:01:58.0232	62	EXECUTED	9:9968206fca46eecc1f51db9c024bfe56	addPrimaryKey constraintName=CONSTRAINT_RESOUR_URIS_PK, tableName=RESOURCE_URIS		\N	4.25.1	\N	\N	5131312613
4.2.0-KEYCLOAK-6313	wadahiro@gmail.com	META-INF/jpa-changelog-4.2.0.xml	2026-04-02 12:01:58.031526	63	EXECUTED	9:92143a6daea0a3f3b8f598c97ce55c3d	addColumn tableName=REQUIRED_ACTION_PROVIDER		\N	4.25.1	\N	\N	5131312613
4.3.0-KEYCLOAK-7984	wadahiro@gmail.com	META-INF/jpa-changelog-4.3.0.xml	2026-04-02 12:01:58.03942	64	EXECUTED	9:82bab26a27195d889fb0429003b18f40	update tableName=REQUIRED_ACTION_PROVIDER		\N	4.25.1	\N	\N	5131312613
4.6.0-KEYCLOAK-7950	psilva@redhat.com	META-INF/jpa-changelog-4.6.0.xml	2026-04-02 12:01:58.047742	65	EXECUTED	9:e590c88ddc0b38b0ae4249bbfcb5abc3	update tableName=RESOURCE_SERVER_RESOURCE		\N	4.25.1	\N	\N	5131312613
4.6.0-KEYCLOAK-8377	keycloak	META-INF/jpa-changelog-4.6.0.xml	2026-04-02 12:01:58.07503	66	EXECUTED	9:5c1f475536118dbdc38d5d7977950cc0	createTable tableName=ROLE_ATTRIBUTE; addPrimaryKey constraintName=CONSTRAINT_ROLE_ATTRIBUTE_PK, tableName=ROLE_ATTRIBUTE; addForeignKeyConstraint baseTableName=ROLE_ATTRIBUTE, constraintName=FK_ROLE_ATTRIBUTE_ID, referencedTableName=KEYCLOAK_ROLE...		\N	4.25.1	\N	\N	5131312613
4.6.0-KEYCLOAK-8555	gideonray@gmail.com	META-INF/jpa-changelog-4.6.0.xml	2026-04-02 12:01:58.087057	67	EXECUTED	9:e7c9f5f9c4d67ccbbcc215440c718a17	createIndex indexName=IDX_COMPONENT_PROVIDER_TYPE, tableName=COMPONENT		\N	4.25.1	\N	\N	5131312613
4.7.0-KEYCLOAK-1267	sguilhen@redhat.com	META-INF/jpa-changelog-4.7.0.xml	2026-04-02 12:01:58.096798	68	EXECUTED	9:88e0bfdda924690d6f4e430c53447dd5	addColumn tableName=REALM		\N	4.25.1	\N	\N	5131312613
4.7.0-KEYCLOAK-7275	keycloak	META-INF/jpa-changelog-4.7.0.xml	2026-04-02 12:01:58.121027	69	EXECUTED	9:f53177f137e1c46b6a88c59ec1cb5218	renameColumn newColumnName=CREATED_ON, oldColumnName=LAST_SESSION_REFRESH, tableName=OFFLINE_USER_SESSION; addNotNullConstraint columnName=CREATED_ON, tableName=OFFLINE_USER_SESSION; addColumn tableName=OFFLINE_USER_SESSION; customChange; createIn...		\N	4.25.1	\N	\N	5131312613
4.8.0-KEYCLOAK-8835	sguilhen@redhat.com	META-INF/jpa-changelog-4.8.0.xml	2026-04-02 12:01:58.131443	70	EXECUTED	9:a74d33da4dc42a37ec27121580d1459f	addNotNullConstraint columnName=SSO_MAX_LIFESPAN_REMEMBER_ME, tableName=REALM; addNotNullConstraint columnName=SSO_IDLE_TIMEOUT_REMEMBER_ME, tableName=REALM		\N	4.25.1	\N	\N	5131312613
authz-7.0.0-KEYCLOAK-10443	psilva@redhat.com	META-INF/jpa-changelog-authz-7.0.0.xml	2026-04-02 12:01:58.140315	71	EXECUTED	9:fd4ade7b90c3b67fae0bfcfcb42dfb5f	addColumn tableName=RESOURCE_SERVER		\N	4.25.1	\N	\N	5131312613
8.0.0-adding-credential-columns	keycloak	META-INF/jpa-changelog-8.0.0.xml	2026-04-02 12:01:58.155774	72	EXECUTED	9:aa072ad090bbba210d8f18781b8cebf4	addColumn tableName=CREDENTIAL; addColumn tableName=FED_USER_CREDENTIAL		\N	4.25.1	\N	\N	5131312613
8.0.0-updating-credential-data-not-oracle-fixed	keycloak	META-INF/jpa-changelog-8.0.0.xml	2026-04-02 12:01:58.168484	73	EXECUTED	9:1ae6be29bab7c2aa376f6983b932be37	update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=FED_USER_CREDENTIAL; update tableName=FED_USER_CREDENTIAL; update tableName=FED_USER_CREDENTIAL		\N	4.25.1	\N	\N	5131312613
8.0.0-updating-credential-data-oracle-fixed	keycloak	META-INF/jpa-changelog-8.0.0.xml	2026-04-02 12:01:58.172389	74	MARK_RAN	9:14706f286953fc9a25286dbd8fb30d97	update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=CREDENTIAL; update tableName=FED_USER_CREDENTIAL; update tableName=FED_USER_CREDENTIAL; update tableName=FED_USER_CREDENTIAL		\N	4.25.1	\N	\N	5131312613
8.0.0-credential-cleanup-fixed	keycloak	META-INF/jpa-changelog-8.0.0.xml	2026-04-02 12:01:58.20439	75	EXECUTED	9:2b9cc12779be32c5b40e2e67711a218b	dropDefaultValue columnName=COUNTER, tableName=CREDENTIAL; dropDefaultValue columnName=DIGITS, tableName=CREDENTIAL; dropDefaultValue columnName=PERIOD, tableName=CREDENTIAL; dropDefaultValue columnName=ALGORITHM, tableName=CREDENTIAL; dropColumn ...		\N	4.25.1	\N	\N	5131312613
8.0.0-resource-tag-support	keycloak	META-INF/jpa-changelog-8.0.0.xml	2026-04-02 12:01:58.217415	76	EXECUTED	9:91fa186ce7a5af127a2d7a91ee083cc5	addColumn tableName=MIGRATION_MODEL; createIndex indexName=IDX_UPDATE_TIME, tableName=MIGRATION_MODEL		\N	4.25.1	\N	\N	5131312613
9.0.0-always-display-client	keycloak	META-INF/jpa-changelog-9.0.0.xml	2026-04-02 12:01:58.225413	77	EXECUTED	9:6335e5c94e83a2639ccd68dd24e2e5ad	addColumn tableName=CLIENT		\N	4.25.1	\N	\N	5131312613
9.0.0-drop-constraints-for-column-increase	keycloak	META-INF/jpa-changelog-9.0.0.xml	2026-04-02 12:01:58.229111	78	MARK_RAN	9:6bdb5658951e028bfe16fa0a8228b530	dropUniqueConstraint constraintName=UK_FRSR6T700S9V50BU18WS5PMT, tableName=RESOURCE_SERVER_PERM_TICKET; dropUniqueConstraint constraintName=UK_FRSR6T700S9V50BU18WS5HA6, tableName=RESOURCE_SERVER_RESOURCE; dropPrimaryKey constraintName=CONSTRAINT_O...		\N	4.25.1	\N	\N	5131312613
9.0.0-increase-column-size-federated-fk	keycloak	META-INF/jpa-changelog-9.0.0.xml	2026-04-02 12:01:58.259106	79	EXECUTED	9:d5bc15a64117ccad481ce8792d4c608f	modifyDataType columnName=CLIENT_ID, tableName=FED_USER_CONSENT; modifyDataType columnName=CLIENT_REALM_CONSTRAINT, tableName=KEYCLOAK_ROLE; modifyDataType columnName=OWNER, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=CLIENT_ID, ta...		\N	4.25.1	\N	\N	5131312613
9.0.0-recreate-constraints-after-column-increase	keycloak	META-INF/jpa-changelog-9.0.0.xml	2026-04-02 12:01:58.262978	80	MARK_RAN	9:077cba51999515f4d3e7ad5619ab592c	addNotNullConstraint columnName=CLIENT_ID, tableName=OFFLINE_CLIENT_SESSION; addNotNullConstraint columnName=OWNER, tableName=RESOURCE_SERVER_PERM_TICKET; addNotNullConstraint columnName=REQUESTER, tableName=RESOURCE_SERVER_PERM_TICKET; addNotNull...		\N	4.25.1	\N	\N	5131312613
9.0.1-add-index-to-client.client_id	keycloak	META-INF/jpa-changelog-9.0.1.xml	2026-04-02 12:01:58.281612	81	EXECUTED	9:be969f08a163bf47c6b9e9ead8ac2afb	createIndex indexName=IDX_CLIENT_ID, tableName=CLIENT		\N	4.25.1	\N	\N	5131312613
9.0.1-KEYCLOAK-12579-drop-constraints	keycloak	META-INF/jpa-changelog-9.0.1.xml	2026-04-02 12:01:58.285141	82	MARK_RAN	9:6d3bb4408ba5a72f39bd8a0b301ec6e3	dropUniqueConstraint constraintName=SIBLING_NAMES, tableName=KEYCLOAK_GROUP		\N	4.25.1	\N	\N	5131312613
9.0.1-KEYCLOAK-12579-add-not-null-constraint	keycloak	META-INF/jpa-changelog-9.0.1.xml	2026-04-02 12:01:58.293411	83	EXECUTED	9:966bda61e46bebf3cc39518fbed52fa7	addNotNullConstraint columnName=PARENT_GROUP, tableName=KEYCLOAK_GROUP		\N	4.25.1	\N	\N	5131312613
9.0.1-KEYCLOAK-12579-recreate-constraints	keycloak	META-INF/jpa-changelog-9.0.1.xml	2026-04-02 12:01:58.29765	84	MARK_RAN	9:8dcac7bdf7378e7d823cdfddebf72fda	addUniqueConstraint constraintName=SIBLING_NAMES, tableName=KEYCLOAK_GROUP		\N	4.25.1	\N	\N	5131312613
9.0.1-add-index-to-events	keycloak	META-INF/jpa-changelog-9.0.1.xml	2026-04-02 12:01:58.309449	85	EXECUTED	9:7d93d602352a30c0c317e6a609b56599	createIndex indexName=IDX_EVENT_TIME, tableName=EVENT_ENTITY		\N	4.25.1	\N	\N	5131312613
map-remove-ri	keycloak	META-INF/jpa-changelog-11.0.0.xml	2026-04-02 12:01:58.31827	86	EXECUTED	9:71c5969e6cdd8d7b6f47cebc86d37627	dropForeignKeyConstraint baseTableName=REALM, constraintName=FK_TRAF444KK6QRKMS7N56AIWQ5Y; dropForeignKeyConstraint baseTableName=KEYCLOAK_ROLE, constraintName=FK_KJHO5LE2C0RAL09FL8CM9WFW9		\N	4.25.1	\N	\N	5131312613
map-remove-ri	keycloak	META-INF/jpa-changelog-12.0.0.xml	2026-04-02 12:01:58.33624	87	EXECUTED	9:a9ba7d47f065f041b7da856a81762021	dropForeignKeyConstraint baseTableName=REALM_DEFAULT_GROUPS, constraintName=FK_DEF_GROUPS_GROUP; dropForeignKeyConstraint baseTableName=REALM_DEFAULT_ROLES, constraintName=FK_H4WPD7W4HSOOLNI3H0SW7BTJE; dropForeignKeyConstraint baseTableName=CLIENT...		\N	4.25.1	\N	\N	5131312613
12.1.0-add-realm-localization-table	keycloak	META-INF/jpa-changelog-12.0.0.xml	2026-04-02 12:01:58.355537	88	EXECUTED	9:fffabce2bc01e1a8f5110d5278500065	createTable tableName=REALM_LOCALIZATIONS; addPrimaryKey tableName=REALM_LOCALIZATIONS		\N	4.25.1	\N	\N	5131312613
default-roles	keycloak	META-INF/jpa-changelog-13.0.0.xml	2026-04-02 12:01:58.369475	89	EXECUTED	9:fa8a5b5445e3857f4b010bafb5009957	addColumn tableName=REALM; customChange		\N	4.25.1	\N	\N	5131312613
default-roles-cleanup	keycloak	META-INF/jpa-changelog-13.0.0.xml	2026-04-02 12:01:58.380308	90	EXECUTED	9:67ac3241df9a8582d591c5ed87125f39	dropTable tableName=REALM_DEFAULT_ROLES; dropTable tableName=CLIENT_DEFAULT_ROLES		\N	4.25.1	\N	\N	5131312613
13.0.0-KEYCLOAK-16844	keycloak	META-INF/jpa-changelog-13.0.0.xml	2026-04-02 12:01:58.392373	91	EXECUTED	9:ad1194d66c937e3ffc82386c050ba089	createIndex indexName=IDX_OFFLINE_USS_PRELOAD, tableName=OFFLINE_USER_SESSION		\N	4.25.1	\N	\N	5131312613
map-remove-ri-13.0.0	keycloak	META-INF/jpa-changelog-13.0.0.xml	2026-04-02 12:01:58.408147	92	EXECUTED	9:d9be619d94af5a2f5d07b9f003543b91	dropForeignKeyConstraint baseTableName=DEFAULT_CLIENT_SCOPE, constraintName=FK_R_DEF_CLI_SCOPE_SCOPE; dropForeignKeyConstraint baseTableName=CLIENT_SCOPE_CLIENT, constraintName=FK_C_CLI_SCOPE_SCOPE; dropForeignKeyConstraint baseTableName=CLIENT_SC...		\N	4.25.1	\N	\N	5131312613
13.0.0-KEYCLOAK-17992-drop-constraints	keycloak	META-INF/jpa-changelog-13.0.0.xml	2026-04-02 12:01:58.411711	93	MARK_RAN	9:544d201116a0fcc5a5da0925fbbc3bde	dropPrimaryKey constraintName=C_CLI_SCOPE_BIND, tableName=CLIENT_SCOPE_CLIENT; dropIndex indexName=IDX_CLSCOPE_CL, tableName=CLIENT_SCOPE_CLIENT; dropIndex indexName=IDX_CL_CLSCOPE, tableName=CLIENT_SCOPE_CLIENT		\N	4.25.1	\N	\N	5131312613
13.0.0-increase-column-size-federated	keycloak	META-INF/jpa-changelog-13.0.0.xml	2026-04-02 12:01:58.427404	94	EXECUTED	9:43c0c1055b6761b4b3e89de76d612ccf	modifyDataType columnName=CLIENT_ID, tableName=CLIENT_SCOPE_CLIENT; modifyDataType columnName=SCOPE_ID, tableName=CLIENT_SCOPE_CLIENT		\N	4.25.1	\N	\N	5131312613
13.0.0-KEYCLOAK-17992-recreate-constraints	keycloak	META-INF/jpa-changelog-13.0.0.xml	2026-04-02 12:01:58.430954	95	MARK_RAN	9:8bd711fd0330f4fe980494ca43ab1139	addNotNullConstraint columnName=CLIENT_ID, tableName=CLIENT_SCOPE_CLIENT; addNotNullConstraint columnName=SCOPE_ID, tableName=CLIENT_SCOPE_CLIENT; addPrimaryKey constraintName=C_CLI_SCOPE_BIND, tableName=CLIENT_SCOPE_CLIENT; createIndex indexName=...		\N	4.25.1	\N	\N	5131312613
json-string-accomodation-fixed	keycloak	META-INF/jpa-changelog-13.0.0.xml	2026-04-02 12:01:58.442157	96	EXECUTED	9:e07d2bc0970c348bb06fb63b1f82ddbf	addColumn tableName=REALM_ATTRIBUTE; update tableName=REALM_ATTRIBUTE; dropColumn columnName=VALUE, tableName=REALM_ATTRIBUTE; renameColumn newColumnName=VALUE, oldColumnName=VALUE_NEW, tableName=REALM_ATTRIBUTE		\N	4.25.1	\N	\N	5131312613
14.0.0-KEYCLOAK-11019	keycloak	META-INF/jpa-changelog-14.0.0.xml	2026-04-02 12:01:58.467821	97	EXECUTED	9:24fb8611e97f29989bea412aa38d12b7	createIndex indexName=IDX_OFFLINE_CSS_PRELOAD, tableName=OFFLINE_CLIENT_SESSION; createIndex indexName=IDX_OFFLINE_USS_BY_USER, tableName=OFFLINE_USER_SESSION; createIndex indexName=IDX_OFFLINE_USS_BY_USERSESS, tableName=OFFLINE_USER_SESSION		\N	4.25.1	\N	\N	5131312613
14.0.0-KEYCLOAK-18286	keycloak	META-INF/jpa-changelog-14.0.0.xml	2026-04-02 12:01:58.471331	98	MARK_RAN	9:259f89014ce2506ee84740cbf7163aa7	createIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.25.1	\N	\N	5131312613
14.0.0-KEYCLOAK-18286-revert	keycloak	META-INF/jpa-changelog-14.0.0.xml	2026-04-02 12:01:58.488919	99	MARK_RAN	9:04baaf56c116ed19951cbc2cca584022	dropIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.25.1	\N	\N	5131312613
14.0.0-KEYCLOAK-18286-supported-dbs	keycloak	META-INF/jpa-changelog-14.0.0.xml	2026-04-02 12:01:58.509424	100	EXECUTED	9:60ca84a0f8c94ec8c3504a5a3bc88ee8	createIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.25.1	\N	\N	5131312613
14.0.0-KEYCLOAK-18286-unsupported-dbs	keycloak	META-INF/jpa-changelog-14.0.0.xml	2026-04-02 12:01:58.5134	101	MARK_RAN	9:d3d977031d431db16e2c181ce49d73e9	createIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.25.1	\N	\N	5131312613
KEYCLOAK-17267-add-index-to-user-attributes	keycloak	META-INF/jpa-changelog-14.0.0.xml	2026-04-02 12:01:58.526977	102	EXECUTED	9:0b305d8d1277f3a89a0a53a659ad274c	createIndex indexName=IDX_USER_ATTRIBUTE_NAME, tableName=USER_ATTRIBUTE		\N	4.25.1	\N	\N	5131312613
KEYCLOAK-18146-add-saml-art-binding-identifier	keycloak	META-INF/jpa-changelog-14.0.0.xml	2026-04-02 12:01:58.535987	103	EXECUTED	9:2c374ad2cdfe20e2905a84c8fac48460	customChange		\N	4.25.1	\N	\N	5131312613
15.0.0-KEYCLOAK-18467	keycloak	META-INF/jpa-changelog-15.0.0.xml	2026-04-02 12:01:58.547591	104	EXECUTED	9:47a760639ac597360a8219f5b768b4de	addColumn tableName=REALM_LOCALIZATIONS; update tableName=REALM_LOCALIZATIONS; dropColumn columnName=TEXTS, tableName=REALM_LOCALIZATIONS; renameColumn newColumnName=TEXTS, oldColumnName=TEXTS_NEW, tableName=REALM_LOCALIZATIONS; addNotNullConstrai...		\N	4.25.1	\N	\N	5131312613
17.0.0-9562	keycloak	META-INF/jpa-changelog-17.0.0.xml	2026-04-02 12:01:58.560204	105	EXECUTED	9:a6272f0576727dd8cad2522335f5d99e	createIndex indexName=IDX_USER_SERVICE_ACCOUNT, tableName=USER_ENTITY		\N	4.25.1	\N	\N	5131312613
18.0.0-10625-IDX_ADMIN_EVENT_TIME	keycloak	META-INF/jpa-changelog-18.0.0.xml	2026-04-02 12:01:58.574042	106	EXECUTED	9:015479dbd691d9cc8669282f4828c41d	createIndex indexName=IDX_ADMIN_EVENT_TIME, tableName=ADMIN_EVENT_ENTITY		\N	4.25.1	\N	\N	5131312613
19.0.0-10135	keycloak	META-INF/jpa-changelog-19.0.0.xml	2026-04-02 12:01:58.58312	107	EXECUTED	9:9518e495fdd22f78ad6425cc30630221	customChange		\N	4.25.1	\N	\N	5131312613
20.0.0-12964-supported-dbs	keycloak	META-INF/jpa-changelog-20.0.0.xml	2026-04-02 12:01:58.597371	108	EXECUTED	9:e5f243877199fd96bcc842f27a1656ac	createIndex indexName=IDX_GROUP_ATT_BY_NAME_VALUE, tableName=GROUP_ATTRIBUTE		\N	4.25.1	\N	\N	5131312613
20.0.0-12964-unsupported-dbs	keycloak	META-INF/jpa-changelog-20.0.0.xml	2026-04-02 12:01:58.600341	109	MARK_RAN	9:1a6fcaa85e20bdeae0a9ce49b41946a5	createIndex indexName=IDX_GROUP_ATT_BY_NAME_VALUE, tableName=GROUP_ATTRIBUTE		\N	4.25.1	\N	\N	5131312613
client-attributes-string-accomodation-fixed	keycloak	META-INF/jpa-changelog-20.0.0.xml	2026-04-02 12:01:58.613731	110	EXECUTED	9:3f332e13e90739ed0c35b0b25b7822ca	addColumn tableName=CLIENT_ATTRIBUTES; update tableName=CLIENT_ATTRIBUTES; dropColumn columnName=VALUE, tableName=CLIENT_ATTRIBUTES; renameColumn newColumnName=VALUE, oldColumnName=VALUE_NEW, tableName=CLIENT_ATTRIBUTES		\N	4.25.1	\N	\N	5131312613
21.0.2-17277	keycloak	META-INF/jpa-changelog-21.0.2.xml	2026-04-02 12:01:58.626975	111	EXECUTED	9:7ee1f7a3fb8f5588f171fb9a6ab623c0	customChange		\N	4.25.1	\N	\N	5131312613
21.1.0-19404	keycloak	META-INF/jpa-changelog-21.1.0.xml	2026-04-02 12:01:58.68444	112	EXECUTED	9:3d7e830b52f33676b9d64f7f2b2ea634	modifyDataType columnName=DECISION_STRATEGY, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=LOGIC, tableName=RESOURCE_SERVER_POLICY; modifyDataType columnName=POLICY_ENFORCE_MODE, tableName=RESOURCE_SERVER		\N	4.25.1	\N	\N	5131312613
21.1.0-19404-2	keycloak	META-INF/jpa-changelog-21.1.0.xml	2026-04-02 12:01:58.689636	113	MARK_RAN	9:627d032e3ef2c06c0e1f73d2ae25c26c	addColumn tableName=RESOURCE_SERVER_POLICY; update tableName=RESOURCE_SERVER_POLICY; dropColumn columnName=DECISION_STRATEGY, tableName=RESOURCE_SERVER_POLICY; renameColumn newColumnName=DECISION_STRATEGY, oldColumnName=DECISION_STRATEGY_NEW, tabl...		\N	4.25.1	\N	\N	5131312613
22.0.0-17484-updated	keycloak	META-INF/jpa-changelog-22.0.0.xml	2026-04-02 12:01:58.699242	114	EXECUTED	9:90af0bfd30cafc17b9f4d6eccd92b8b3	customChange		\N	4.25.1	\N	\N	5131312613
22.0.5-24031	keycloak	META-INF/jpa-changelog-22.0.0.xml	2026-04-02 12:01:58.702614	115	MARK_RAN	9:a60d2d7b315ec2d3eba9e2f145f9df28	customChange		\N	4.25.1	\N	\N	5131312613
23.0.0-12062	keycloak	META-INF/jpa-changelog-23.0.0.xml	2026-04-02 12:01:58.711597	116	EXECUTED	9:2168fbe728fec46ae9baf15bf80927b8	addColumn tableName=COMPONENT_CONFIG; update tableName=COMPONENT_CONFIG; dropColumn columnName=VALUE, tableName=COMPONENT_CONFIG; renameColumn newColumnName=VALUE, oldColumnName=VALUE_NEW, tableName=COMPONENT_CONFIG		\N	4.25.1	\N	\N	5131312613
23.0.0-17258	keycloak	META-INF/jpa-changelog-23.0.0.xml	2026-04-02 12:01:58.718992	117	EXECUTED	9:36506d679a83bbfda85a27ea1864dca8	addColumn tableName=EVENT_ENTITY		\N	4.25.1	\N	\N	5131312613
24.0.0-9758	keycloak	META-INF/jpa-changelog-24.0.0.xml	2026-04-02 12:01:58.761062	118	EXECUTED	9:502c557a5189f600f0f445a9b49ebbce	addColumn tableName=USER_ATTRIBUTE; addColumn tableName=FED_USER_ATTRIBUTE; createIndex indexName=USER_ATTR_LONG_VALUES, tableName=USER_ATTRIBUTE; createIndex indexName=FED_USER_ATTR_LONG_VALUES, tableName=FED_USER_ATTRIBUTE; createIndex indexName...		\N	4.25.1	\N	\N	5131312613
24.0.0-26618-drop-index-if-present	keycloak	META-INF/jpa-changelog-24.0.0.xml	2026-04-02 12:01:58.779163	120	MARK_RAN	9:04baaf56c116ed19951cbc2cca584022	dropIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.25.1	\N	\N	5131312613
24.0.0-26618-reindex	keycloak	META-INF/jpa-changelog-24.0.0.xml	2026-04-02 12:01:58.794589	121	EXECUTED	9:08707c0f0db1cef6b352db03a60edc7f	createIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.25.1	\N	\N	5131312613
24.0.2-27228	keycloak	META-INF/jpa-changelog-24.0.2.xml	2026-04-02 12:01:58.804567	122	EXECUTED	9:eaee11f6b8aa25d2cc6a84fb86fc6238	customChange		\N	4.25.1	\N	\N	5131312613
24.0.2-27967-drop-index-if-present	keycloak	META-INF/jpa-changelog-24.0.2.xml	2026-04-02 12:01:58.807743	123	MARK_RAN	9:04baaf56c116ed19951cbc2cca584022	dropIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.25.1	\N	\N	5131312613
24.0.2-27967-reindex	keycloak	META-INF/jpa-changelog-24.0.2.xml	2026-04-02 12:01:58.812056	124	MARK_RAN	9:d3d977031d431db16e2c181ce49d73e9	createIndex indexName=IDX_CLIENT_ATT_BY_NAME_VALUE, tableName=CLIENT_ATTRIBUTES		\N	4.25.1	\N	\N	5131312613
\.


--
-- Data for Name: databasechangeloglock; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.databasechangeloglock (id, locked, lockgranted, lockedby) FROM stdin;
1	f	\N	\N
1000	f	\N	\N
1001	f	\N	\N
\.


--
-- Data for Name: default_client_scope; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.default_client_scope (realm_id, scope_id, default_scope) FROM stdin;
b748fd0d-b840-453b-b49c-26b926a71139	5d094eff-5a40-456a-894b-8ce13fc7e43c	f
b748fd0d-b840-453b-b49c-26b926a71139	e2130823-4219-425a-a272-a14ed23d6806	t
b748fd0d-b840-453b-b49c-26b926a71139	2a81b3f6-1bcd-4fd8-b1ff-a55257bd8f3b	t
b748fd0d-b840-453b-b49c-26b926a71139	aefd8acf-d41a-4d8a-9d3b-ceb0e6257a8b	t
b748fd0d-b840-453b-b49c-26b926a71139	76c38eef-9683-4ad4-abb1-62c411d8c0dd	f
b748fd0d-b840-453b-b49c-26b926a71139	0f22a8f2-72ab-46a7-b4fc-d321263fba76	f
b748fd0d-b840-453b-b49c-26b926a71139	bc820279-57ae-419f-b290-6e886c2c2502	t
b748fd0d-b840-453b-b49c-26b926a71139	ac5426d1-f8da-4529-a9aa-713219ebdd8e	t
b748fd0d-b840-453b-b49c-26b926a71139	fea7a210-49f2-4e8d-a2ad-fd08c415ed7c	f
b748fd0d-b840-453b-b49c-26b926a71139	b6ff3e04-8e0f-450a-aa13-5b158e1669af	t
354b9070-b2b9-4f85-9ab1-d7b290304732	cf92c41a-2e84-4f45-9655-f77f1a0ea142	f
354b9070-b2b9-4f85-9ab1-d7b290304732	49244ffb-76db-4607-ae9a-5f737125fa46	t
354b9070-b2b9-4f85-9ab1-d7b290304732	576b8764-4e94-43c7-a71a-ac0022afd84c	t
354b9070-b2b9-4f85-9ab1-d7b290304732	51eac524-dce3-40a2-9bd8-6d7162329b1d	t
354b9070-b2b9-4f85-9ab1-d7b290304732	89f6de5e-7858-4e9c-ab55-44a2e3f109ca	f
354b9070-b2b9-4f85-9ab1-d7b290304732	c8723907-0f2d-424b-ba90-b8e1112972c3	f
354b9070-b2b9-4f85-9ab1-d7b290304732	995c67d6-07ed-4025-8c59-77adc190a6fa	t
354b9070-b2b9-4f85-9ab1-d7b290304732	a568d36b-4bf3-4fee-95c8-77589d1936b7	t
354b9070-b2b9-4f85-9ab1-d7b290304732	dd280499-0b11-41ee-99a8-ed93e95a46d1	f
354b9070-b2b9-4f85-9ab1-d7b290304732	1a5bb211-b22b-4f03-a4d2-c06cbf603379	t
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.departments (id, description, name) FROM stdin;
1	Ressources Humaines	RH
2	Technologies de l'information	IT
3	Gestion de produit	Product
\.


--
-- Data for Name: document_requests; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.document_requests (id, created_at, details, employee_email, file_data, file_name, status, type, user_id) FROM stdin;
\.


--
-- Data for Name: event_entity; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.event_entity (id, client_id, details_json, error, ip_address, realm_id, session_id, event_time, type, user_id, details_json_long_value) FROM stdin;
\.


--
-- Data for Name: fed_user_attribute; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.fed_user_attribute (id, name, user_id, realm_id, storage_provider_id, value, long_value_hash, long_value_hash_lower_case, long_value) FROM stdin;
\.


--
-- Data for Name: fed_user_consent; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.fed_user_consent (id, client_id, user_id, realm_id, storage_provider_id, created_date, last_updated_date, client_storage_provider, external_client_id) FROM stdin;
\.


--
-- Data for Name: fed_user_consent_cl_scope; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.fed_user_consent_cl_scope (user_consent_id, scope_id) FROM stdin;
\.


--
-- Data for Name: fed_user_credential; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.fed_user_credential (id, salt, type, created_date, user_id, realm_id, storage_provider_id, user_label, secret_data, credential_data, priority) FROM stdin;
\.


--
-- Data for Name: fed_user_group_membership; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.fed_user_group_membership (group_id, user_id, realm_id, storage_provider_id) FROM stdin;
\.


--
-- Data for Name: fed_user_required_action; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.fed_user_required_action (required_action, user_id, realm_id, storage_provider_id) FROM stdin;
\.


--
-- Data for Name: fed_user_role_mapping; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.fed_user_role_mapping (role_id, user_id, realm_id, storage_provider_id) FROM stdin;
\.


--
-- Data for Name: federated_identity; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.federated_identity (identity_provider, realm_id, federated_user_id, federated_username, token, user_id) FROM stdin;
\.


--
-- Data for Name: federated_user; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.federated_user (id, storage_provider_id, realm_id) FROM stdin;
\.


--
-- Data for Name: group_attribute; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.group_attribute (id, name, value, group_id) FROM stdin;
\.


--
-- Data for Name: group_role_mapping; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.group_role_mapping (role_id, group_id) FROM stdin;
\.


--
-- Data for Name: identity_provider; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.identity_provider (internal_id, enabled, provider_alias, provider_id, store_token, authenticate_by_default, realm_id, add_token_role, trust_email, first_broker_login_flow_id, post_broker_login_flow_id, provider_display_name, link_only) FROM stdin;
\.


--
-- Data for Name: identity_provider_config; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.identity_provider_config (identity_provider_id, value, name) FROM stdin;
\.


--
-- Data for Name: identity_provider_mapper; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.identity_provider_mapper (id, name, idp_alias, idp_mapper_name, realm_id) FROM stdin;
\.


--
-- Data for Name: idp_mapper_config; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.idp_mapper_config (idp_mapper_id, value, name) FROM stdin;
\.


--
-- Data for Name: interviews; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.interviews (id, application_id, candidate_email, candidate_name, comments, date, evaluator_id, job_title, score, status) FROM stdin;
\.


--
-- Data for Name: job_offers; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.job_offers (id, closing_date, created_at, department, description, eligibility_criteria, opening_date, recruiter_id, requirements, salary_range, status, title, type) FROM stdin;
1	2026-05-17	2026-04-02 12:04:23.378655	IT	Nous recherchons un expert React pour nos projets internes.	Minimum 2 ans dans un poste developpement frontend	\N	\N	5+ ans, TypeScript, React, communication	45k - 60k	PUBLISHED	Senior Developer React	INTERNAL
2	2026-06-01	2026-04-02 12:04:23.378655	Product	Pilotage roadmap et coordination equipe produit.	Connaissance secteur FinTech appreciee	\N	\N	Experience SaaS, Agile, communication	50k - 70k	PUBLISHED	Product Manager	EXTERNAL
\.


--
-- Data for Name: keycloak_group; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.keycloak_group (id, name, parent_group, realm_id) FROM stdin;
\.


--
-- Data for Name: keycloak_role; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.keycloak_role (id, client_realm_constraint, client_role, description, name, realm_id, client, realm) FROM stdin;
782cb36d-398b-422e-8a8d-1c0d950eeaed	b748fd0d-b840-453b-b49c-26b926a71139	f	${role_default-roles}	default-roles-master	b748fd0d-b840-453b-b49c-26b926a71139	\N	\N
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	b748fd0d-b840-453b-b49c-26b926a71139	f	${role_admin}	admin	b748fd0d-b840-453b-b49c-26b926a71139	\N	\N
68526cfe-f879-4c7f-8954-9b554e86e2e1	b748fd0d-b840-453b-b49c-26b926a71139	f	${role_create-realm}	create-realm	b748fd0d-b840-453b-b49c-26b926a71139	\N	\N
e48be305-0bbe-4901-b291-1570bfd68155	8555aea4-b785-4d79-996c-47e79ebae943	t	${role_create-client}	create-client	b748fd0d-b840-453b-b49c-26b926a71139	8555aea4-b785-4d79-996c-47e79ebae943	\N
16e0e737-d2fb-426f-9acf-e1a40c920f8e	8555aea4-b785-4d79-996c-47e79ebae943	t	${role_view-realm}	view-realm	b748fd0d-b840-453b-b49c-26b926a71139	8555aea4-b785-4d79-996c-47e79ebae943	\N
5358b091-72b0-4dbd-97d4-b66e8cb62b92	8555aea4-b785-4d79-996c-47e79ebae943	t	${role_view-users}	view-users	b748fd0d-b840-453b-b49c-26b926a71139	8555aea4-b785-4d79-996c-47e79ebae943	\N
dc7b2d59-7e41-445a-b5b7-7338af4125b4	8555aea4-b785-4d79-996c-47e79ebae943	t	${role_view-clients}	view-clients	b748fd0d-b840-453b-b49c-26b926a71139	8555aea4-b785-4d79-996c-47e79ebae943	\N
d57599e3-984a-47ad-a1ba-2ac82577909b	8555aea4-b785-4d79-996c-47e79ebae943	t	${role_view-events}	view-events	b748fd0d-b840-453b-b49c-26b926a71139	8555aea4-b785-4d79-996c-47e79ebae943	\N
f27c98b4-007c-4702-bb56-ff755d75a753	8555aea4-b785-4d79-996c-47e79ebae943	t	${role_view-identity-providers}	view-identity-providers	b748fd0d-b840-453b-b49c-26b926a71139	8555aea4-b785-4d79-996c-47e79ebae943	\N
567dd811-2bf4-4762-8263-867b5a7093a5	8555aea4-b785-4d79-996c-47e79ebae943	t	${role_view-authorization}	view-authorization	b748fd0d-b840-453b-b49c-26b926a71139	8555aea4-b785-4d79-996c-47e79ebae943	\N
075a0781-c16a-41fa-b4a8-e28ee56a9ae0	8555aea4-b785-4d79-996c-47e79ebae943	t	${role_manage-realm}	manage-realm	b748fd0d-b840-453b-b49c-26b926a71139	8555aea4-b785-4d79-996c-47e79ebae943	\N
7e90c424-dadc-4e66-a014-cf04e24bd46d	8555aea4-b785-4d79-996c-47e79ebae943	t	${role_manage-users}	manage-users	b748fd0d-b840-453b-b49c-26b926a71139	8555aea4-b785-4d79-996c-47e79ebae943	\N
cb65c285-7f30-414f-b3b5-073da28dc519	8555aea4-b785-4d79-996c-47e79ebae943	t	${role_manage-clients}	manage-clients	b748fd0d-b840-453b-b49c-26b926a71139	8555aea4-b785-4d79-996c-47e79ebae943	\N
299e6300-3f6b-48ac-93c4-2e41fe9d7a34	8555aea4-b785-4d79-996c-47e79ebae943	t	${role_manage-events}	manage-events	b748fd0d-b840-453b-b49c-26b926a71139	8555aea4-b785-4d79-996c-47e79ebae943	\N
e05a84ec-a99d-4d64-897d-abbc80c3179d	8555aea4-b785-4d79-996c-47e79ebae943	t	${role_manage-identity-providers}	manage-identity-providers	b748fd0d-b840-453b-b49c-26b926a71139	8555aea4-b785-4d79-996c-47e79ebae943	\N
0a78b014-b1d9-44c8-905f-1570ec6ae5f8	8555aea4-b785-4d79-996c-47e79ebae943	t	${role_manage-authorization}	manage-authorization	b748fd0d-b840-453b-b49c-26b926a71139	8555aea4-b785-4d79-996c-47e79ebae943	\N
722e55ab-a84a-48c5-869e-21fcd5918007	8555aea4-b785-4d79-996c-47e79ebae943	t	${role_query-users}	query-users	b748fd0d-b840-453b-b49c-26b926a71139	8555aea4-b785-4d79-996c-47e79ebae943	\N
21245df4-2d74-460f-a43c-b17da0d05e4d	8555aea4-b785-4d79-996c-47e79ebae943	t	${role_query-clients}	query-clients	b748fd0d-b840-453b-b49c-26b926a71139	8555aea4-b785-4d79-996c-47e79ebae943	\N
1d544440-dd09-41d4-a9f4-045050928a8e	8555aea4-b785-4d79-996c-47e79ebae943	t	${role_query-realms}	query-realms	b748fd0d-b840-453b-b49c-26b926a71139	8555aea4-b785-4d79-996c-47e79ebae943	\N
c866a867-4e32-4ae7-94a7-b944f59a5af7	8555aea4-b785-4d79-996c-47e79ebae943	t	${role_query-groups}	query-groups	b748fd0d-b840-453b-b49c-26b926a71139	8555aea4-b785-4d79-996c-47e79ebae943	\N
feb0b02c-eca2-4af7-96bb-f3a88b728e4f	4d54aa61-2812-4233-b6c8-1c148de24706	t	${role_view-profile}	view-profile	b748fd0d-b840-453b-b49c-26b926a71139	4d54aa61-2812-4233-b6c8-1c148de24706	\N
f0ae8753-c8b8-4b37-9c6c-408b0181cad2	4d54aa61-2812-4233-b6c8-1c148de24706	t	${role_manage-account}	manage-account	b748fd0d-b840-453b-b49c-26b926a71139	4d54aa61-2812-4233-b6c8-1c148de24706	\N
29e3150b-4503-4913-ae66-665cce96db99	4d54aa61-2812-4233-b6c8-1c148de24706	t	${role_manage-account-links}	manage-account-links	b748fd0d-b840-453b-b49c-26b926a71139	4d54aa61-2812-4233-b6c8-1c148de24706	\N
cb0f2bf0-b178-444c-91c1-ceb82fb6c1d4	4d54aa61-2812-4233-b6c8-1c148de24706	t	${role_view-applications}	view-applications	b748fd0d-b840-453b-b49c-26b926a71139	4d54aa61-2812-4233-b6c8-1c148de24706	\N
340930a2-4bd0-4a70-8df6-d30caabf761e	4d54aa61-2812-4233-b6c8-1c148de24706	t	${role_view-consent}	view-consent	b748fd0d-b840-453b-b49c-26b926a71139	4d54aa61-2812-4233-b6c8-1c148de24706	\N
9c4baf6c-27a0-4956-9868-e4173f7ee4e0	4d54aa61-2812-4233-b6c8-1c148de24706	t	${role_manage-consent}	manage-consent	b748fd0d-b840-453b-b49c-26b926a71139	4d54aa61-2812-4233-b6c8-1c148de24706	\N
287301ad-8076-43a9-9ff2-544149507722	4d54aa61-2812-4233-b6c8-1c148de24706	t	${role_view-groups}	view-groups	b748fd0d-b840-453b-b49c-26b926a71139	4d54aa61-2812-4233-b6c8-1c148de24706	\N
267488a7-d8f8-42ac-b308-e55436ea4667	4d54aa61-2812-4233-b6c8-1c148de24706	t	${role_delete-account}	delete-account	b748fd0d-b840-453b-b49c-26b926a71139	4d54aa61-2812-4233-b6c8-1c148de24706	\N
36dd4954-8fde-4bf5-990d-7aad0b9b4f2d	fa9e8401-1be7-4a56-a0b0-52dad2195303	t	${role_read-token}	read-token	b748fd0d-b840-453b-b49c-26b926a71139	fa9e8401-1be7-4a56-a0b0-52dad2195303	\N
ef6173fa-0da3-4775-bd7b-c69a1b7505bf	8555aea4-b785-4d79-996c-47e79ebae943	t	${role_impersonation}	impersonation	b748fd0d-b840-453b-b49c-26b926a71139	8555aea4-b785-4d79-996c-47e79ebae943	\N
e6535714-4142-4244-9960-43374ffe3341	b748fd0d-b840-453b-b49c-26b926a71139	f	${role_offline-access}	offline_access	b748fd0d-b840-453b-b49c-26b926a71139	\N	\N
7d3bd85f-bc01-40a0-89ff-574604983668	b748fd0d-b840-453b-b49c-26b926a71139	f	${role_uma_authorization}	uma_authorization	b748fd0d-b840-453b-b49c-26b926a71139	\N	\N
1a0603b9-d25d-4576-9d1b-3f6258a4f87e	354b9070-b2b9-4f85-9ab1-d7b290304732	f	${role_default-roles}	default-roles-vermeg-sirh	354b9070-b2b9-4f85-9ab1-d7b290304732	\N	\N
63213da9-3497-4b71-89b5-4d58e9065956	96861af9-57ec-4594-9587-dd4defa93b53	t	${role_create-client}	create-client	b748fd0d-b840-453b-b49c-26b926a71139	96861af9-57ec-4594-9587-dd4defa93b53	\N
ec7ccbfa-e533-4174-98b3-6586901af646	96861af9-57ec-4594-9587-dd4defa93b53	t	${role_view-realm}	view-realm	b748fd0d-b840-453b-b49c-26b926a71139	96861af9-57ec-4594-9587-dd4defa93b53	\N
c4a3b88c-a3d2-47af-97a9-4afbed942e73	96861af9-57ec-4594-9587-dd4defa93b53	t	${role_view-users}	view-users	b748fd0d-b840-453b-b49c-26b926a71139	96861af9-57ec-4594-9587-dd4defa93b53	\N
606ed14a-1880-4188-b8f0-66dd27d9d0ed	96861af9-57ec-4594-9587-dd4defa93b53	t	${role_view-clients}	view-clients	b748fd0d-b840-453b-b49c-26b926a71139	96861af9-57ec-4594-9587-dd4defa93b53	\N
d694e99b-422d-44d5-a1fb-a3b0e9393014	96861af9-57ec-4594-9587-dd4defa93b53	t	${role_view-events}	view-events	b748fd0d-b840-453b-b49c-26b926a71139	96861af9-57ec-4594-9587-dd4defa93b53	\N
13ec011e-12b4-4b03-8558-7859639efb50	96861af9-57ec-4594-9587-dd4defa93b53	t	${role_view-identity-providers}	view-identity-providers	b748fd0d-b840-453b-b49c-26b926a71139	96861af9-57ec-4594-9587-dd4defa93b53	\N
fbe5efd5-3eba-4129-a6df-c8d2bffc9a7c	96861af9-57ec-4594-9587-dd4defa93b53	t	${role_view-authorization}	view-authorization	b748fd0d-b840-453b-b49c-26b926a71139	96861af9-57ec-4594-9587-dd4defa93b53	\N
38a63893-0ffd-4ea1-90e7-94ce4dfcb76a	96861af9-57ec-4594-9587-dd4defa93b53	t	${role_manage-realm}	manage-realm	b748fd0d-b840-453b-b49c-26b926a71139	96861af9-57ec-4594-9587-dd4defa93b53	\N
8133dd44-350f-4602-8f5e-4b8c11dcecbf	96861af9-57ec-4594-9587-dd4defa93b53	t	${role_manage-users}	manage-users	b748fd0d-b840-453b-b49c-26b926a71139	96861af9-57ec-4594-9587-dd4defa93b53	\N
29c28f4d-aaba-4b54-ba7b-52e56744e15e	96861af9-57ec-4594-9587-dd4defa93b53	t	${role_manage-clients}	manage-clients	b748fd0d-b840-453b-b49c-26b926a71139	96861af9-57ec-4594-9587-dd4defa93b53	\N
bd0055cd-991b-4ddf-9a60-21dec459a050	96861af9-57ec-4594-9587-dd4defa93b53	t	${role_manage-events}	manage-events	b748fd0d-b840-453b-b49c-26b926a71139	96861af9-57ec-4594-9587-dd4defa93b53	\N
a3b2ccf6-8171-4223-80cc-7780e3c49bc9	96861af9-57ec-4594-9587-dd4defa93b53	t	${role_manage-identity-providers}	manage-identity-providers	b748fd0d-b840-453b-b49c-26b926a71139	96861af9-57ec-4594-9587-dd4defa93b53	\N
7cebb432-8fc5-4bac-aba9-d706b0382198	96861af9-57ec-4594-9587-dd4defa93b53	t	${role_manage-authorization}	manage-authorization	b748fd0d-b840-453b-b49c-26b926a71139	96861af9-57ec-4594-9587-dd4defa93b53	\N
af66da69-ca6b-4d6c-8ea7-546d609d20f1	96861af9-57ec-4594-9587-dd4defa93b53	t	${role_query-users}	query-users	b748fd0d-b840-453b-b49c-26b926a71139	96861af9-57ec-4594-9587-dd4defa93b53	\N
f5049d9a-2d0e-4e4c-a5ce-d2ea910105b8	96861af9-57ec-4594-9587-dd4defa93b53	t	${role_query-clients}	query-clients	b748fd0d-b840-453b-b49c-26b926a71139	96861af9-57ec-4594-9587-dd4defa93b53	\N
6e8470e7-94a3-4442-a0ef-0c1fc1542c82	96861af9-57ec-4594-9587-dd4defa93b53	t	${role_query-realms}	query-realms	b748fd0d-b840-453b-b49c-26b926a71139	96861af9-57ec-4594-9587-dd4defa93b53	\N
e8da2bae-ff18-49dd-8eee-d82201c339ae	96861af9-57ec-4594-9587-dd4defa93b53	t	${role_query-groups}	query-groups	b748fd0d-b840-453b-b49c-26b926a71139	96861af9-57ec-4594-9587-dd4defa93b53	\N
6a4cee8b-2975-479b-a0c0-337607d3cc79	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	t	${role_realm-admin}	realm-admin	354b9070-b2b9-4f85-9ab1-d7b290304732	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	\N
23ccd3a2-4d76-47b7-91df-d76405dc3208	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	t	${role_create-client}	create-client	354b9070-b2b9-4f85-9ab1-d7b290304732	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	\N
39448f9a-88ce-4569-8836-77a8a973e99c	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	t	${role_view-realm}	view-realm	354b9070-b2b9-4f85-9ab1-d7b290304732	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	\N
db75210c-d922-4818-950f-c65c23acf8a7	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	t	${role_view-users}	view-users	354b9070-b2b9-4f85-9ab1-d7b290304732	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	\N
a5a3bb87-98c1-4ce2-b831-c234e633873e	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	t	${role_view-clients}	view-clients	354b9070-b2b9-4f85-9ab1-d7b290304732	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	\N
f1f1e25b-65e6-490a-a904-18165e8019c9	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	t	${role_view-events}	view-events	354b9070-b2b9-4f85-9ab1-d7b290304732	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	\N
6a46625d-3e93-498b-8ad1-242345e9f155	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	t	${role_view-identity-providers}	view-identity-providers	354b9070-b2b9-4f85-9ab1-d7b290304732	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	\N
f6bf7d05-7a13-444d-9c74-1e1628ae0465	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	t	${role_view-authorization}	view-authorization	354b9070-b2b9-4f85-9ab1-d7b290304732	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	\N
fbb72d15-a12b-4f22-b1fa-37c676bd8999	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	t	${role_manage-realm}	manage-realm	354b9070-b2b9-4f85-9ab1-d7b290304732	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	\N
b6fe5755-5ba6-4e45-8b32-81152b8036d9	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	t	${role_manage-users}	manage-users	354b9070-b2b9-4f85-9ab1-d7b290304732	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	\N
d9313716-42fa-4320-8f59-0b179067ebb5	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	t	${role_manage-clients}	manage-clients	354b9070-b2b9-4f85-9ab1-d7b290304732	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	\N
cdbc736f-d74c-4739-a27a-03fdf1a5b8a7	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	t	${role_manage-events}	manage-events	354b9070-b2b9-4f85-9ab1-d7b290304732	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	\N
66d55d56-81bb-4e67-9119-e22259fc6a69	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	t	${role_manage-identity-providers}	manage-identity-providers	354b9070-b2b9-4f85-9ab1-d7b290304732	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	\N
6b64b653-7e22-4947-a741-12141e678708	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	t	${role_manage-authorization}	manage-authorization	354b9070-b2b9-4f85-9ab1-d7b290304732	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	\N
dd9f9396-894c-4e41-8914-d99c8ff81dc1	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	t	${role_query-users}	query-users	354b9070-b2b9-4f85-9ab1-d7b290304732	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	\N
c179d2da-9871-4716-991c-60a3edffd2b1	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	t	${role_query-clients}	query-clients	354b9070-b2b9-4f85-9ab1-d7b290304732	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	\N
aaff2419-1106-407b-a71e-851fc9d9a31f	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	t	${role_query-realms}	query-realms	354b9070-b2b9-4f85-9ab1-d7b290304732	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	\N
fc1116cf-a463-4c14-8b77-deb407fdb63a	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	t	${role_query-groups}	query-groups	354b9070-b2b9-4f85-9ab1-d7b290304732	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	\N
1eddff7c-7e5b-42e6-9b14-7b1c56f26ca8	321503d7-7ad4-4062-a43b-6ed10dde5585	t	${role_view-profile}	view-profile	354b9070-b2b9-4f85-9ab1-d7b290304732	321503d7-7ad4-4062-a43b-6ed10dde5585	\N
1ce1b465-8cf1-4fac-aba9-9c315ab34626	321503d7-7ad4-4062-a43b-6ed10dde5585	t	${role_manage-account}	manage-account	354b9070-b2b9-4f85-9ab1-d7b290304732	321503d7-7ad4-4062-a43b-6ed10dde5585	\N
c7b13470-c31e-4e09-8481-585a5cb07417	321503d7-7ad4-4062-a43b-6ed10dde5585	t	${role_manage-account-links}	manage-account-links	354b9070-b2b9-4f85-9ab1-d7b290304732	321503d7-7ad4-4062-a43b-6ed10dde5585	\N
0e2bec5d-61b5-402d-8aca-acff254e3fac	321503d7-7ad4-4062-a43b-6ed10dde5585	t	${role_view-applications}	view-applications	354b9070-b2b9-4f85-9ab1-d7b290304732	321503d7-7ad4-4062-a43b-6ed10dde5585	\N
4756c2be-6e3c-483f-8bc8-bbf9d889c650	321503d7-7ad4-4062-a43b-6ed10dde5585	t	${role_view-consent}	view-consent	354b9070-b2b9-4f85-9ab1-d7b290304732	321503d7-7ad4-4062-a43b-6ed10dde5585	\N
5ea8547c-7eff-48cb-9c9b-a31b391fc7e1	321503d7-7ad4-4062-a43b-6ed10dde5585	t	${role_manage-consent}	manage-consent	354b9070-b2b9-4f85-9ab1-d7b290304732	321503d7-7ad4-4062-a43b-6ed10dde5585	\N
0d9e077c-1f18-49a7-8bb7-7c7fae36764f	321503d7-7ad4-4062-a43b-6ed10dde5585	t	${role_view-groups}	view-groups	354b9070-b2b9-4f85-9ab1-d7b290304732	321503d7-7ad4-4062-a43b-6ed10dde5585	\N
6c7bfeae-7c11-45cd-a3e9-a55970cffdf5	321503d7-7ad4-4062-a43b-6ed10dde5585	t	${role_delete-account}	delete-account	354b9070-b2b9-4f85-9ab1-d7b290304732	321503d7-7ad4-4062-a43b-6ed10dde5585	\N
d019aed4-5464-45f0-a641-9225a6189a45	96861af9-57ec-4594-9587-dd4defa93b53	t	${role_impersonation}	impersonation	b748fd0d-b840-453b-b49c-26b926a71139	96861af9-57ec-4594-9587-dd4defa93b53	\N
8d2b7e00-7d00-4984-ba2a-896c5cc0855b	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	t	${role_impersonation}	impersonation	354b9070-b2b9-4f85-9ab1-d7b290304732	13232e6b-b5e6-4eb2-8bb7-107ed1f0aba8	\N
81b2448a-2e4b-4d30-9470-ec2399ddbdb2	09cea9d8-680c-458a-8b61-4560b5831997	t	${role_read-token}	read-token	354b9070-b2b9-4f85-9ab1-d7b290304732	09cea9d8-680c-458a-8b61-4560b5831997	\N
51615ae0-b8a9-4a99-8de7-97d4959f9e3b	354b9070-b2b9-4f85-9ab1-d7b290304732	f	${role_offline-access}	offline_access	354b9070-b2b9-4f85-9ab1-d7b290304732	\N	\N
8a39cd47-6c32-447a-845f-f641728b413e	354b9070-b2b9-4f85-9ab1-d7b290304732	f	\N	EMPLOYEE	354b9070-b2b9-4f85-9ab1-d7b290304732	\N	\N
26325d0e-fb28-4f0c-ac88-b9f638808ec2	354b9070-b2b9-4f85-9ab1-d7b290304732	f	\N	MANAGER	354b9070-b2b9-4f85-9ab1-d7b290304732	\N	\N
68d859f3-377e-4275-9624-5ea338b091b4	354b9070-b2b9-4f85-9ab1-d7b290304732	f	\N	HR_ADMIN	354b9070-b2b9-4f85-9ab1-d7b290304732	\N	\N
2282bfc8-df36-4a2c-9140-7aa480515b60	354b9070-b2b9-4f85-9ab1-d7b290304732	f	\N	RECRUITER	354b9070-b2b9-4f85-9ab1-d7b290304732	\N	\N
e95cabc6-0d98-4fd3-9cfe-3c503a9d7416	354b9070-b2b9-4f85-9ab1-d7b290304732	f	\N	CANDIDATE	354b9070-b2b9-4f85-9ab1-d7b290304732	\N	\N
255c2aa1-ad79-4266-a56c-c5a7d4c8e260	354b9070-b2b9-4f85-9ab1-d7b290304732	f	${role_uma_authorization}	uma_authorization	354b9070-b2b9-4f85-9ab1-d7b290304732	\N	\N
\.


--
-- Data for Name: leave_requests; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.leave_requests (id, created_at, employee_email, end_date, reason, start_date, status, type, user_id) FROM stdin;
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.messages (id, content, created_at, is_read, receiver_id, sender_id) FROM stdin;
\.


--
-- Data for Name: migration_model; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.migration_model (id, version, update_time) FROM stdin;
6buxr	24.0.5	1775131319
\.


--
-- Data for Name: news; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.news (id, author_id, content, created_at, title) FROM stdin;
1	1	La plateforme RH microservices est operationnelle.	2026-04-02 12:04:23.375998	Bienvenue sur VERMEG SIRH
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.notifications (id, created_at, is_read, message, type, user_id) FROM stdin;
1	2026-04-02 12:04:23.385941	f	Votre espace RH est pret. Vous pouvez soumettre vos demandes.	INFO	2
\.


--
-- Data for Name: offline_client_session; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.offline_client_session (user_session_id, client_id, offline_flag, "timestamp", data, client_storage_provider, external_client_id) FROM stdin;
\.


--
-- Data for Name: offline_user_session; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.offline_user_session (user_session_id, user_id, realm_id, created_on, offline_flag, data, last_session_refresh) FROM stdin;
\.


--
-- Data for Name: policy_config; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.policy_config (policy_id, name, value) FROM stdin;
\.


--
-- Data for Name: positions; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.positions (id, department, title) FROM stdin;
\.


--
-- Data for Name: protocol_mapper; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.protocol_mapper (id, name, protocol, protocol_mapper_name, client_id, client_scope_id) FROM stdin;
a44aad13-07ca-485c-9abb-feb1c3297068	audience resolve	openid-connect	oidc-audience-resolve-mapper	fcf80481-f9c8-44c6-8f42-0523de9bbcc6	\N
71e2646c-bd77-42c4-b9c2-040da50d7c78	locale	openid-connect	oidc-usermodel-attribute-mapper	2c39f546-574c-436f-bd84-c217e5de074c	\N
a5743f4c-1724-41d2-90ff-de6956cd02f1	role list	saml	saml-role-list-mapper	\N	e2130823-4219-425a-a272-a14ed23d6806
bc538d21-cebe-4e09-9aae-8a684b4f8f93	full name	openid-connect	oidc-full-name-mapper	\N	2a81b3f6-1bcd-4fd8-b1ff-a55257bd8f3b
1cda455f-8b5c-4de7-a6a8-79e02cb2a4d2	family name	openid-connect	oidc-usermodel-attribute-mapper	\N	2a81b3f6-1bcd-4fd8-b1ff-a55257bd8f3b
6a9609d0-73f3-4a92-8e36-6c9685acee79	given name	openid-connect	oidc-usermodel-attribute-mapper	\N	2a81b3f6-1bcd-4fd8-b1ff-a55257bd8f3b
1f3b9c12-83e1-422f-98e9-f13393cccb7e	middle name	openid-connect	oidc-usermodel-attribute-mapper	\N	2a81b3f6-1bcd-4fd8-b1ff-a55257bd8f3b
4bebfb3b-56df-4e53-9a2e-30587c44e8a1	nickname	openid-connect	oidc-usermodel-attribute-mapper	\N	2a81b3f6-1bcd-4fd8-b1ff-a55257bd8f3b
8455a098-18f8-46bf-ac16-0a83f9c570b2	username	openid-connect	oidc-usermodel-attribute-mapper	\N	2a81b3f6-1bcd-4fd8-b1ff-a55257bd8f3b
866c3a86-d642-4021-bbc3-db605364f6ed	profile	openid-connect	oidc-usermodel-attribute-mapper	\N	2a81b3f6-1bcd-4fd8-b1ff-a55257bd8f3b
3e246aef-c046-44e9-aa58-3df038b2346d	picture	openid-connect	oidc-usermodel-attribute-mapper	\N	2a81b3f6-1bcd-4fd8-b1ff-a55257bd8f3b
111daa5e-2229-485b-ba5e-1b8eee542384	website	openid-connect	oidc-usermodel-attribute-mapper	\N	2a81b3f6-1bcd-4fd8-b1ff-a55257bd8f3b
525611ae-d4f9-4dae-b012-4bb0fde6b464	gender	openid-connect	oidc-usermodel-attribute-mapper	\N	2a81b3f6-1bcd-4fd8-b1ff-a55257bd8f3b
b0bf9c63-8793-4cd9-a8ed-a82865fb6c5c	birthdate	openid-connect	oidc-usermodel-attribute-mapper	\N	2a81b3f6-1bcd-4fd8-b1ff-a55257bd8f3b
dea279f9-d847-4cd3-834c-dc5d55a327fa	zoneinfo	openid-connect	oidc-usermodel-attribute-mapper	\N	2a81b3f6-1bcd-4fd8-b1ff-a55257bd8f3b
f00e68f5-328e-4dcc-9320-153af54af297	locale	openid-connect	oidc-usermodel-attribute-mapper	\N	2a81b3f6-1bcd-4fd8-b1ff-a55257bd8f3b
16eea955-31a9-4f46-8d67-0394eb4c37b8	updated at	openid-connect	oidc-usermodel-attribute-mapper	\N	2a81b3f6-1bcd-4fd8-b1ff-a55257bd8f3b
45c8c1fe-ab66-4586-8508-e86a6d53550f	email	openid-connect	oidc-usermodel-attribute-mapper	\N	aefd8acf-d41a-4d8a-9d3b-ceb0e6257a8b
cfef669f-9109-4144-8e6b-7ed5f1a06ee3	email verified	openid-connect	oidc-usermodel-property-mapper	\N	aefd8acf-d41a-4d8a-9d3b-ceb0e6257a8b
f065c78d-0727-4d0e-ba87-62533bad6ceb	address	openid-connect	oidc-address-mapper	\N	76c38eef-9683-4ad4-abb1-62c411d8c0dd
d3d8b8e5-5e0b-4424-8fa0-29e76e2c25ac	phone number	openid-connect	oidc-usermodel-attribute-mapper	\N	0f22a8f2-72ab-46a7-b4fc-d321263fba76
97d2ab03-fa57-46e2-865d-2683f3713d8a	phone number verified	openid-connect	oidc-usermodel-attribute-mapper	\N	0f22a8f2-72ab-46a7-b4fc-d321263fba76
b2e9ea91-dd58-4902-83a3-75b1fa0c47ea	realm roles	openid-connect	oidc-usermodel-realm-role-mapper	\N	bc820279-57ae-419f-b290-6e886c2c2502
14f9ec0b-4dd2-406b-9afe-534fbe1669af	client roles	openid-connect	oidc-usermodel-client-role-mapper	\N	bc820279-57ae-419f-b290-6e886c2c2502
57081ce0-80c6-4ec7-9113-bc084898a745	audience resolve	openid-connect	oidc-audience-resolve-mapper	\N	bc820279-57ae-419f-b290-6e886c2c2502
4250460d-b66b-4798-b919-7cac3c0b9e41	allowed web origins	openid-connect	oidc-allowed-origins-mapper	\N	ac5426d1-f8da-4529-a9aa-713219ebdd8e
50d8c4b1-e680-408d-b3a0-74a59626bda5	upn	openid-connect	oidc-usermodel-attribute-mapper	\N	fea7a210-49f2-4e8d-a2ad-fd08c415ed7c
1a0fe64d-41c8-48c5-9f56-042a371cc602	groups	openid-connect	oidc-usermodel-realm-role-mapper	\N	fea7a210-49f2-4e8d-a2ad-fd08c415ed7c
cb13fa0d-6386-45a3-9946-1a8e3750b5a1	acr loa level	openid-connect	oidc-acr-mapper	\N	b6ff3e04-8e0f-450a-aa13-5b158e1669af
4c5a46fd-6e1f-4bb2-813a-1eb2d714781b	audience resolve	openid-connect	oidc-audience-resolve-mapper	a128520c-0fb1-4780-b35f-0a42e859e46d	\N
e989d1ca-f573-473d-96d5-cfc67dc64047	role list	saml	saml-role-list-mapper	\N	49244ffb-76db-4607-ae9a-5f737125fa46
fd09b250-7ea4-46d6-854d-56b941094088	full name	openid-connect	oidc-full-name-mapper	\N	576b8764-4e94-43c7-a71a-ac0022afd84c
b6b99690-ac74-48db-abf9-7bf91cf7cea9	family name	openid-connect	oidc-usermodel-attribute-mapper	\N	576b8764-4e94-43c7-a71a-ac0022afd84c
42a8a63e-ead8-46dd-9bc4-bde01e53edfc	given name	openid-connect	oidc-usermodel-attribute-mapper	\N	576b8764-4e94-43c7-a71a-ac0022afd84c
6517778a-a76b-4621-915b-d61684aadae2	middle name	openid-connect	oidc-usermodel-attribute-mapper	\N	576b8764-4e94-43c7-a71a-ac0022afd84c
8d7f71a3-0173-4840-9b49-e68c91f39840	nickname	openid-connect	oidc-usermodel-attribute-mapper	\N	576b8764-4e94-43c7-a71a-ac0022afd84c
c28388f8-7ed2-4202-ba92-086f883fdbf1	username	openid-connect	oidc-usermodel-attribute-mapper	\N	576b8764-4e94-43c7-a71a-ac0022afd84c
6eed7426-8af5-4f8a-8718-b4c5888e84e9	profile	openid-connect	oidc-usermodel-attribute-mapper	\N	576b8764-4e94-43c7-a71a-ac0022afd84c
b91d266e-439d-45f2-ae2e-6bff2fb6fe17	picture	openid-connect	oidc-usermodel-attribute-mapper	\N	576b8764-4e94-43c7-a71a-ac0022afd84c
65ec5b88-262a-4e20-b1a3-14064430e78c	website	openid-connect	oidc-usermodel-attribute-mapper	\N	576b8764-4e94-43c7-a71a-ac0022afd84c
ad51f1b1-6ff7-4239-ae45-1e233fc9f76d	gender	openid-connect	oidc-usermodel-attribute-mapper	\N	576b8764-4e94-43c7-a71a-ac0022afd84c
ae464485-3ce9-4962-aaec-67a7501b0283	birthdate	openid-connect	oidc-usermodel-attribute-mapper	\N	576b8764-4e94-43c7-a71a-ac0022afd84c
684067fd-f5ac-4ab3-97d6-1f97f54428bc	zoneinfo	openid-connect	oidc-usermodel-attribute-mapper	\N	576b8764-4e94-43c7-a71a-ac0022afd84c
29f2c8f1-ba43-4631-acc5-a63fa1a3d999	locale	openid-connect	oidc-usermodel-attribute-mapper	\N	576b8764-4e94-43c7-a71a-ac0022afd84c
47f02abb-d82c-4a78-b1f5-4509e9327197	updated at	openid-connect	oidc-usermodel-attribute-mapper	\N	576b8764-4e94-43c7-a71a-ac0022afd84c
3d5df755-bd50-4fa7-9286-167b5e0d8634	email	openid-connect	oidc-usermodel-attribute-mapper	\N	51eac524-dce3-40a2-9bd8-6d7162329b1d
c778e967-1f9b-47d3-9c31-7f3e28f141c2	email verified	openid-connect	oidc-usermodel-property-mapper	\N	51eac524-dce3-40a2-9bd8-6d7162329b1d
c8c8602c-b3a2-446a-a6ba-5b210315e5c3	address	openid-connect	oidc-address-mapper	\N	89f6de5e-7858-4e9c-ab55-44a2e3f109ca
e8fe1ba9-81b6-4864-8c78-9aae9925ec55	phone number	openid-connect	oidc-usermodel-attribute-mapper	\N	c8723907-0f2d-424b-ba90-b8e1112972c3
0a4e191c-6dfc-4ea3-86bb-a191c969e1c3	phone number verified	openid-connect	oidc-usermodel-attribute-mapper	\N	c8723907-0f2d-424b-ba90-b8e1112972c3
64ef99ef-d853-4b9d-9f58-98a92884893e	realm roles	openid-connect	oidc-usermodel-realm-role-mapper	\N	995c67d6-07ed-4025-8c59-77adc190a6fa
4a3934f9-1031-4af0-aa4f-6759fd5eb2ac	client roles	openid-connect	oidc-usermodel-client-role-mapper	\N	995c67d6-07ed-4025-8c59-77adc190a6fa
18c01751-893f-4b5a-b8c4-ab490aa96499	audience resolve	openid-connect	oidc-audience-resolve-mapper	\N	995c67d6-07ed-4025-8c59-77adc190a6fa
dda8c124-bd9a-43ef-b0c2-5f34620c0716	allowed web origins	openid-connect	oidc-allowed-origins-mapper	\N	a568d36b-4bf3-4fee-95c8-77589d1936b7
c6071302-bf41-4fc2-9ce5-355c02cda6b5	upn	openid-connect	oidc-usermodel-attribute-mapper	\N	dd280499-0b11-41ee-99a8-ed93e95a46d1
2b3d70be-3be6-49f4-84b3-4d874995064c	groups	openid-connect	oidc-usermodel-realm-role-mapper	\N	dd280499-0b11-41ee-99a8-ed93e95a46d1
9998f452-0d69-49b2-bb79-7e769b62c499	acr loa level	openid-connect	oidc-acr-mapper	\N	1a5bb211-b22b-4f03-a4d2-c06cbf603379
1a6d663f-38bd-403f-8400-1a7c5a8b006c	locale	openid-connect	oidc-usermodel-attribute-mapper	fa8f3487-99ca-4e48-aca6-c706a7949899	\N
\.


--
-- Data for Name: protocol_mapper_config; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.protocol_mapper_config (protocol_mapper_id, value, name) FROM stdin;
71e2646c-bd77-42c4-b9c2-040da50d7c78	true	introspection.token.claim
71e2646c-bd77-42c4-b9c2-040da50d7c78	true	userinfo.token.claim
71e2646c-bd77-42c4-b9c2-040da50d7c78	locale	user.attribute
71e2646c-bd77-42c4-b9c2-040da50d7c78	true	id.token.claim
71e2646c-bd77-42c4-b9c2-040da50d7c78	true	access.token.claim
71e2646c-bd77-42c4-b9c2-040da50d7c78	locale	claim.name
71e2646c-bd77-42c4-b9c2-040da50d7c78	String	jsonType.label
a5743f4c-1724-41d2-90ff-de6956cd02f1	false	single
a5743f4c-1724-41d2-90ff-de6956cd02f1	Basic	attribute.nameformat
a5743f4c-1724-41d2-90ff-de6956cd02f1	Role	attribute.name
111daa5e-2229-485b-ba5e-1b8eee542384	true	introspection.token.claim
111daa5e-2229-485b-ba5e-1b8eee542384	true	userinfo.token.claim
111daa5e-2229-485b-ba5e-1b8eee542384	website	user.attribute
111daa5e-2229-485b-ba5e-1b8eee542384	true	id.token.claim
111daa5e-2229-485b-ba5e-1b8eee542384	true	access.token.claim
111daa5e-2229-485b-ba5e-1b8eee542384	website	claim.name
111daa5e-2229-485b-ba5e-1b8eee542384	String	jsonType.label
16eea955-31a9-4f46-8d67-0394eb4c37b8	true	introspection.token.claim
16eea955-31a9-4f46-8d67-0394eb4c37b8	true	userinfo.token.claim
16eea955-31a9-4f46-8d67-0394eb4c37b8	updatedAt	user.attribute
16eea955-31a9-4f46-8d67-0394eb4c37b8	true	id.token.claim
16eea955-31a9-4f46-8d67-0394eb4c37b8	true	access.token.claim
16eea955-31a9-4f46-8d67-0394eb4c37b8	updated_at	claim.name
16eea955-31a9-4f46-8d67-0394eb4c37b8	long	jsonType.label
1cda455f-8b5c-4de7-a6a8-79e02cb2a4d2	true	introspection.token.claim
1cda455f-8b5c-4de7-a6a8-79e02cb2a4d2	true	userinfo.token.claim
1cda455f-8b5c-4de7-a6a8-79e02cb2a4d2	lastName	user.attribute
1cda455f-8b5c-4de7-a6a8-79e02cb2a4d2	true	id.token.claim
1cda455f-8b5c-4de7-a6a8-79e02cb2a4d2	true	access.token.claim
1cda455f-8b5c-4de7-a6a8-79e02cb2a4d2	family_name	claim.name
1cda455f-8b5c-4de7-a6a8-79e02cb2a4d2	String	jsonType.label
1f3b9c12-83e1-422f-98e9-f13393cccb7e	true	introspection.token.claim
1f3b9c12-83e1-422f-98e9-f13393cccb7e	true	userinfo.token.claim
1f3b9c12-83e1-422f-98e9-f13393cccb7e	middleName	user.attribute
1f3b9c12-83e1-422f-98e9-f13393cccb7e	true	id.token.claim
1f3b9c12-83e1-422f-98e9-f13393cccb7e	true	access.token.claim
1f3b9c12-83e1-422f-98e9-f13393cccb7e	middle_name	claim.name
1f3b9c12-83e1-422f-98e9-f13393cccb7e	String	jsonType.label
3e246aef-c046-44e9-aa58-3df038b2346d	true	introspection.token.claim
3e246aef-c046-44e9-aa58-3df038b2346d	true	userinfo.token.claim
3e246aef-c046-44e9-aa58-3df038b2346d	picture	user.attribute
3e246aef-c046-44e9-aa58-3df038b2346d	true	id.token.claim
3e246aef-c046-44e9-aa58-3df038b2346d	true	access.token.claim
3e246aef-c046-44e9-aa58-3df038b2346d	picture	claim.name
3e246aef-c046-44e9-aa58-3df038b2346d	String	jsonType.label
4bebfb3b-56df-4e53-9a2e-30587c44e8a1	true	introspection.token.claim
4bebfb3b-56df-4e53-9a2e-30587c44e8a1	true	userinfo.token.claim
4bebfb3b-56df-4e53-9a2e-30587c44e8a1	nickname	user.attribute
4bebfb3b-56df-4e53-9a2e-30587c44e8a1	true	id.token.claim
4bebfb3b-56df-4e53-9a2e-30587c44e8a1	true	access.token.claim
4bebfb3b-56df-4e53-9a2e-30587c44e8a1	nickname	claim.name
4bebfb3b-56df-4e53-9a2e-30587c44e8a1	String	jsonType.label
525611ae-d4f9-4dae-b012-4bb0fde6b464	true	introspection.token.claim
525611ae-d4f9-4dae-b012-4bb0fde6b464	true	userinfo.token.claim
525611ae-d4f9-4dae-b012-4bb0fde6b464	gender	user.attribute
525611ae-d4f9-4dae-b012-4bb0fde6b464	true	id.token.claim
525611ae-d4f9-4dae-b012-4bb0fde6b464	true	access.token.claim
525611ae-d4f9-4dae-b012-4bb0fde6b464	gender	claim.name
525611ae-d4f9-4dae-b012-4bb0fde6b464	String	jsonType.label
6a9609d0-73f3-4a92-8e36-6c9685acee79	true	introspection.token.claim
6a9609d0-73f3-4a92-8e36-6c9685acee79	true	userinfo.token.claim
6a9609d0-73f3-4a92-8e36-6c9685acee79	firstName	user.attribute
6a9609d0-73f3-4a92-8e36-6c9685acee79	true	id.token.claim
6a9609d0-73f3-4a92-8e36-6c9685acee79	true	access.token.claim
6a9609d0-73f3-4a92-8e36-6c9685acee79	given_name	claim.name
6a9609d0-73f3-4a92-8e36-6c9685acee79	String	jsonType.label
8455a098-18f8-46bf-ac16-0a83f9c570b2	true	introspection.token.claim
8455a098-18f8-46bf-ac16-0a83f9c570b2	true	userinfo.token.claim
8455a098-18f8-46bf-ac16-0a83f9c570b2	username	user.attribute
8455a098-18f8-46bf-ac16-0a83f9c570b2	true	id.token.claim
8455a098-18f8-46bf-ac16-0a83f9c570b2	true	access.token.claim
8455a098-18f8-46bf-ac16-0a83f9c570b2	preferred_username	claim.name
8455a098-18f8-46bf-ac16-0a83f9c570b2	String	jsonType.label
866c3a86-d642-4021-bbc3-db605364f6ed	true	introspection.token.claim
866c3a86-d642-4021-bbc3-db605364f6ed	true	userinfo.token.claim
866c3a86-d642-4021-bbc3-db605364f6ed	profile	user.attribute
866c3a86-d642-4021-bbc3-db605364f6ed	true	id.token.claim
866c3a86-d642-4021-bbc3-db605364f6ed	true	access.token.claim
866c3a86-d642-4021-bbc3-db605364f6ed	profile	claim.name
866c3a86-d642-4021-bbc3-db605364f6ed	String	jsonType.label
b0bf9c63-8793-4cd9-a8ed-a82865fb6c5c	true	introspection.token.claim
b0bf9c63-8793-4cd9-a8ed-a82865fb6c5c	true	userinfo.token.claim
b0bf9c63-8793-4cd9-a8ed-a82865fb6c5c	birthdate	user.attribute
b0bf9c63-8793-4cd9-a8ed-a82865fb6c5c	true	id.token.claim
b0bf9c63-8793-4cd9-a8ed-a82865fb6c5c	true	access.token.claim
b0bf9c63-8793-4cd9-a8ed-a82865fb6c5c	birthdate	claim.name
b0bf9c63-8793-4cd9-a8ed-a82865fb6c5c	String	jsonType.label
bc538d21-cebe-4e09-9aae-8a684b4f8f93	true	introspection.token.claim
bc538d21-cebe-4e09-9aae-8a684b4f8f93	true	userinfo.token.claim
bc538d21-cebe-4e09-9aae-8a684b4f8f93	true	id.token.claim
bc538d21-cebe-4e09-9aae-8a684b4f8f93	true	access.token.claim
dea279f9-d847-4cd3-834c-dc5d55a327fa	true	introspection.token.claim
dea279f9-d847-4cd3-834c-dc5d55a327fa	true	userinfo.token.claim
dea279f9-d847-4cd3-834c-dc5d55a327fa	zoneinfo	user.attribute
dea279f9-d847-4cd3-834c-dc5d55a327fa	true	id.token.claim
dea279f9-d847-4cd3-834c-dc5d55a327fa	true	access.token.claim
dea279f9-d847-4cd3-834c-dc5d55a327fa	zoneinfo	claim.name
dea279f9-d847-4cd3-834c-dc5d55a327fa	String	jsonType.label
f00e68f5-328e-4dcc-9320-153af54af297	true	introspection.token.claim
f00e68f5-328e-4dcc-9320-153af54af297	true	userinfo.token.claim
f00e68f5-328e-4dcc-9320-153af54af297	locale	user.attribute
f00e68f5-328e-4dcc-9320-153af54af297	true	id.token.claim
f00e68f5-328e-4dcc-9320-153af54af297	true	access.token.claim
f00e68f5-328e-4dcc-9320-153af54af297	locale	claim.name
f00e68f5-328e-4dcc-9320-153af54af297	String	jsonType.label
45c8c1fe-ab66-4586-8508-e86a6d53550f	true	introspection.token.claim
45c8c1fe-ab66-4586-8508-e86a6d53550f	true	userinfo.token.claim
45c8c1fe-ab66-4586-8508-e86a6d53550f	email	user.attribute
45c8c1fe-ab66-4586-8508-e86a6d53550f	true	id.token.claim
45c8c1fe-ab66-4586-8508-e86a6d53550f	true	access.token.claim
45c8c1fe-ab66-4586-8508-e86a6d53550f	email	claim.name
45c8c1fe-ab66-4586-8508-e86a6d53550f	String	jsonType.label
cfef669f-9109-4144-8e6b-7ed5f1a06ee3	true	introspection.token.claim
cfef669f-9109-4144-8e6b-7ed5f1a06ee3	true	userinfo.token.claim
cfef669f-9109-4144-8e6b-7ed5f1a06ee3	emailVerified	user.attribute
cfef669f-9109-4144-8e6b-7ed5f1a06ee3	true	id.token.claim
cfef669f-9109-4144-8e6b-7ed5f1a06ee3	true	access.token.claim
cfef669f-9109-4144-8e6b-7ed5f1a06ee3	email_verified	claim.name
cfef669f-9109-4144-8e6b-7ed5f1a06ee3	boolean	jsonType.label
f065c78d-0727-4d0e-ba87-62533bad6ceb	formatted	user.attribute.formatted
f065c78d-0727-4d0e-ba87-62533bad6ceb	country	user.attribute.country
f065c78d-0727-4d0e-ba87-62533bad6ceb	true	introspection.token.claim
f065c78d-0727-4d0e-ba87-62533bad6ceb	postal_code	user.attribute.postal_code
f065c78d-0727-4d0e-ba87-62533bad6ceb	true	userinfo.token.claim
f065c78d-0727-4d0e-ba87-62533bad6ceb	street	user.attribute.street
f065c78d-0727-4d0e-ba87-62533bad6ceb	true	id.token.claim
f065c78d-0727-4d0e-ba87-62533bad6ceb	region	user.attribute.region
f065c78d-0727-4d0e-ba87-62533bad6ceb	true	access.token.claim
f065c78d-0727-4d0e-ba87-62533bad6ceb	locality	user.attribute.locality
97d2ab03-fa57-46e2-865d-2683f3713d8a	true	introspection.token.claim
97d2ab03-fa57-46e2-865d-2683f3713d8a	true	userinfo.token.claim
97d2ab03-fa57-46e2-865d-2683f3713d8a	phoneNumberVerified	user.attribute
97d2ab03-fa57-46e2-865d-2683f3713d8a	true	id.token.claim
97d2ab03-fa57-46e2-865d-2683f3713d8a	true	access.token.claim
97d2ab03-fa57-46e2-865d-2683f3713d8a	phone_number_verified	claim.name
97d2ab03-fa57-46e2-865d-2683f3713d8a	boolean	jsonType.label
d3d8b8e5-5e0b-4424-8fa0-29e76e2c25ac	true	introspection.token.claim
d3d8b8e5-5e0b-4424-8fa0-29e76e2c25ac	true	userinfo.token.claim
d3d8b8e5-5e0b-4424-8fa0-29e76e2c25ac	phoneNumber	user.attribute
d3d8b8e5-5e0b-4424-8fa0-29e76e2c25ac	true	id.token.claim
d3d8b8e5-5e0b-4424-8fa0-29e76e2c25ac	true	access.token.claim
d3d8b8e5-5e0b-4424-8fa0-29e76e2c25ac	phone_number	claim.name
d3d8b8e5-5e0b-4424-8fa0-29e76e2c25ac	String	jsonType.label
14f9ec0b-4dd2-406b-9afe-534fbe1669af	true	introspection.token.claim
14f9ec0b-4dd2-406b-9afe-534fbe1669af	true	multivalued
14f9ec0b-4dd2-406b-9afe-534fbe1669af	foo	user.attribute
14f9ec0b-4dd2-406b-9afe-534fbe1669af	true	access.token.claim
14f9ec0b-4dd2-406b-9afe-534fbe1669af	resource_access.${client_id}.roles	claim.name
14f9ec0b-4dd2-406b-9afe-534fbe1669af	String	jsonType.label
57081ce0-80c6-4ec7-9113-bc084898a745	true	introspection.token.claim
57081ce0-80c6-4ec7-9113-bc084898a745	true	access.token.claim
b2e9ea91-dd58-4902-83a3-75b1fa0c47ea	true	introspection.token.claim
b2e9ea91-dd58-4902-83a3-75b1fa0c47ea	true	multivalued
b2e9ea91-dd58-4902-83a3-75b1fa0c47ea	foo	user.attribute
b2e9ea91-dd58-4902-83a3-75b1fa0c47ea	true	access.token.claim
b2e9ea91-dd58-4902-83a3-75b1fa0c47ea	realm_access.roles	claim.name
b2e9ea91-dd58-4902-83a3-75b1fa0c47ea	String	jsonType.label
4250460d-b66b-4798-b919-7cac3c0b9e41	true	introspection.token.claim
4250460d-b66b-4798-b919-7cac3c0b9e41	true	access.token.claim
1a0fe64d-41c8-48c5-9f56-042a371cc602	true	introspection.token.claim
1a0fe64d-41c8-48c5-9f56-042a371cc602	true	multivalued
1a0fe64d-41c8-48c5-9f56-042a371cc602	foo	user.attribute
1a0fe64d-41c8-48c5-9f56-042a371cc602	true	id.token.claim
1a0fe64d-41c8-48c5-9f56-042a371cc602	true	access.token.claim
1a0fe64d-41c8-48c5-9f56-042a371cc602	groups	claim.name
1a0fe64d-41c8-48c5-9f56-042a371cc602	String	jsonType.label
50d8c4b1-e680-408d-b3a0-74a59626bda5	true	introspection.token.claim
50d8c4b1-e680-408d-b3a0-74a59626bda5	true	userinfo.token.claim
50d8c4b1-e680-408d-b3a0-74a59626bda5	username	user.attribute
50d8c4b1-e680-408d-b3a0-74a59626bda5	true	id.token.claim
50d8c4b1-e680-408d-b3a0-74a59626bda5	true	access.token.claim
50d8c4b1-e680-408d-b3a0-74a59626bda5	upn	claim.name
50d8c4b1-e680-408d-b3a0-74a59626bda5	String	jsonType.label
cb13fa0d-6386-45a3-9946-1a8e3750b5a1	true	introspection.token.claim
cb13fa0d-6386-45a3-9946-1a8e3750b5a1	true	id.token.claim
cb13fa0d-6386-45a3-9946-1a8e3750b5a1	true	access.token.claim
e989d1ca-f573-473d-96d5-cfc67dc64047	false	single
e989d1ca-f573-473d-96d5-cfc67dc64047	Basic	attribute.nameformat
e989d1ca-f573-473d-96d5-cfc67dc64047	Role	attribute.name
29f2c8f1-ba43-4631-acc5-a63fa1a3d999	true	introspection.token.claim
29f2c8f1-ba43-4631-acc5-a63fa1a3d999	true	userinfo.token.claim
29f2c8f1-ba43-4631-acc5-a63fa1a3d999	locale	user.attribute
29f2c8f1-ba43-4631-acc5-a63fa1a3d999	true	id.token.claim
29f2c8f1-ba43-4631-acc5-a63fa1a3d999	true	access.token.claim
29f2c8f1-ba43-4631-acc5-a63fa1a3d999	locale	claim.name
29f2c8f1-ba43-4631-acc5-a63fa1a3d999	String	jsonType.label
42a8a63e-ead8-46dd-9bc4-bde01e53edfc	true	introspection.token.claim
42a8a63e-ead8-46dd-9bc4-bde01e53edfc	true	userinfo.token.claim
42a8a63e-ead8-46dd-9bc4-bde01e53edfc	firstName	user.attribute
42a8a63e-ead8-46dd-9bc4-bde01e53edfc	true	id.token.claim
42a8a63e-ead8-46dd-9bc4-bde01e53edfc	true	access.token.claim
42a8a63e-ead8-46dd-9bc4-bde01e53edfc	given_name	claim.name
42a8a63e-ead8-46dd-9bc4-bde01e53edfc	String	jsonType.label
47f02abb-d82c-4a78-b1f5-4509e9327197	true	introspection.token.claim
47f02abb-d82c-4a78-b1f5-4509e9327197	true	userinfo.token.claim
47f02abb-d82c-4a78-b1f5-4509e9327197	updatedAt	user.attribute
47f02abb-d82c-4a78-b1f5-4509e9327197	true	id.token.claim
47f02abb-d82c-4a78-b1f5-4509e9327197	true	access.token.claim
47f02abb-d82c-4a78-b1f5-4509e9327197	updated_at	claim.name
47f02abb-d82c-4a78-b1f5-4509e9327197	long	jsonType.label
6517778a-a76b-4621-915b-d61684aadae2	true	introspection.token.claim
6517778a-a76b-4621-915b-d61684aadae2	true	userinfo.token.claim
6517778a-a76b-4621-915b-d61684aadae2	middleName	user.attribute
6517778a-a76b-4621-915b-d61684aadae2	true	id.token.claim
6517778a-a76b-4621-915b-d61684aadae2	true	access.token.claim
6517778a-a76b-4621-915b-d61684aadae2	middle_name	claim.name
6517778a-a76b-4621-915b-d61684aadae2	String	jsonType.label
65ec5b88-262a-4e20-b1a3-14064430e78c	true	introspection.token.claim
65ec5b88-262a-4e20-b1a3-14064430e78c	true	userinfo.token.claim
65ec5b88-262a-4e20-b1a3-14064430e78c	website	user.attribute
65ec5b88-262a-4e20-b1a3-14064430e78c	true	id.token.claim
65ec5b88-262a-4e20-b1a3-14064430e78c	true	access.token.claim
65ec5b88-262a-4e20-b1a3-14064430e78c	website	claim.name
65ec5b88-262a-4e20-b1a3-14064430e78c	String	jsonType.label
684067fd-f5ac-4ab3-97d6-1f97f54428bc	true	introspection.token.claim
684067fd-f5ac-4ab3-97d6-1f97f54428bc	true	userinfo.token.claim
684067fd-f5ac-4ab3-97d6-1f97f54428bc	zoneinfo	user.attribute
684067fd-f5ac-4ab3-97d6-1f97f54428bc	true	id.token.claim
684067fd-f5ac-4ab3-97d6-1f97f54428bc	true	access.token.claim
684067fd-f5ac-4ab3-97d6-1f97f54428bc	zoneinfo	claim.name
684067fd-f5ac-4ab3-97d6-1f97f54428bc	String	jsonType.label
6eed7426-8af5-4f8a-8718-b4c5888e84e9	true	introspection.token.claim
6eed7426-8af5-4f8a-8718-b4c5888e84e9	true	userinfo.token.claim
6eed7426-8af5-4f8a-8718-b4c5888e84e9	profile	user.attribute
6eed7426-8af5-4f8a-8718-b4c5888e84e9	true	id.token.claim
6eed7426-8af5-4f8a-8718-b4c5888e84e9	true	access.token.claim
6eed7426-8af5-4f8a-8718-b4c5888e84e9	profile	claim.name
6eed7426-8af5-4f8a-8718-b4c5888e84e9	String	jsonType.label
8d7f71a3-0173-4840-9b49-e68c91f39840	true	introspection.token.claim
8d7f71a3-0173-4840-9b49-e68c91f39840	true	userinfo.token.claim
8d7f71a3-0173-4840-9b49-e68c91f39840	nickname	user.attribute
8d7f71a3-0173-4840-9b49-e68c91f39840	true	id.token.claim
8d7f71a3-0173-4840-9b49-e68c91f39840	true	access.token.claim
8d7f71a3-0173-4840-9b49-e68c91f39840	nickname	claim.name
8d7f71a3-0173-4840-9b49-e68c91f39840	String	jsonType.label
ad51f1b1-6ff7-4239-ae45-1e233fc9f76d	true	introspection.token.claim
ad51f1b1-6ff7-4239-ae45-1e233fc9f76d	true	userinfo.token.claim
ad51f1b1-6ff7-4239-ae45-1e233fc9f76d	gender	user.attribute
ad51f1b1-6ff7-4239-ae45-1e233fc9f76d	true	id.token.claim
ad51f1b1-6ff7-4239-ae45-1e233fc9f76d	true	access.token.claim
ad51f1b1-6ff7-4239-ae45-1e233fc9f76d	gender	claim.name
ad51f1b1-6ff7-4239-ae45-1e233fc9f76d	String	jsonType.label
ae464485-3ce9-4962-aaec-67a7501b0283	true	introspection.token.claim
ae464485-3ce9-4962-aaec-67a7501b0283	true	userinfo.token.claim
ae464485-3ce9-4962-aaec-67a7501b0283	birthdate	user.attribute
ae464485-3ce9-4962-aaec-67a7501b0283	true	id.token.claim
ae464485-3ce9-4962-aaec-67a7501b0283	true	access.token.claim
ae464485-3ce9-4962-aaec-67a7501b0283	birthdate	claim.name
ae464485-3ce9-4962-aaec-67a7501b0283	String	jsonType.label
b6b99690-ac74-48db-abf9-7bf91cf7cea9	true	introspection.token.claim
b6b99690-ac74-48db-abf9-7bf91cf7cea9	true	userinfo.token.claim
b6b99690-ac74-48db-abf9-7bf91cf7cea9	lastName	user.attribute
b6b99690-ac74-48db-abf9-7bf91cf7cea9	true	id.token.claim
b6b99690-ac74-48db-abf9-7bf91cf7cea9	true	access.token.claim
b6b99690-ac74-48db-abf9-7bf91cf7cea9	family_name	claim.name
b6b99690-ac74-48db-abf9-7bf91cf7cea9	String	jsonType.label
b91d266e-439d-45f2-ae2e-6bff2fb6fe17	true	introspection.token.claim
b91d266e-439d-45f2-ae2e-6bff2fb6fe17	true	userinfo.token.claim
b91d266e-439d-45f2-ae2e-6bff2fb6fe17	picture	user.attribute
b91d266e-439d-45f2-ae2e-6bff2fb6fe17	true	id.token.claim
b91d266e-439d-45f2-ae2e-6bff2fb6fe17	true	access.token.claim
b91d266e-439d-45f2-ae2e-6bff2fb6fe17	picture	claim.name
b91d266e-439d-45f2-ae2e-6bff2fb6fe17	String	jsonType.label
c28388f8-7ed2-4202-ba92-086f883fdbf1	true	introspection.token.claim
c28388f8-7ed2-4202-ba92-086f883fdbf1	true	userinfo.token.claim
c28388f8-7ed2-4202-ba92-086f883fdbf1	username	user.attribute
c28388f8-7ed2-4202-ba92-086f883fdbf1	true	id.token.claim
c28388f8-7ed2-4202-ba92-086f883fdbf1	true	access.token.claim
c28388f8-7ed2-4202-ba92-086f883fdbf1	preferred_username	claim.name
c28388f8-7ed2-4202-ba92-086f883fdbf1	String	jsonType.label
fd09b250-7ea4-46d6-854d-56b941094088	true	introspection.token.claim
fd09b250-7ea4-46d6-854d-56b941094088	true	userinfo.token.claim
fd09b250-7ea4-46d6-854d-56b941094088	true	id.token.claim
fd09b250-7ea4-46d6-854d-56b941094088	true	access.token.claim
3d5df755-bd50-4fa7-9286-167b5e0d8634	true	introspection.token.claim
3d5df755-bd50-4fa7-9286-167b5e0d8634	true	userinfo.token.claim
3d5df755-bd50-4fa7-9286-167b5e0d8634	email	user.attribute
3d5df755-bd50-4fa7-9286-167b5e0d8634	true	id.token.claim
3d5df755-bd50-4fa7-9286-167b5e0d8634	true	access.token.claim
3d5df755-bd50-4fa7-9286-167b5e0d8634	email	claim.name
3d5df755-bd50-4fa7-9286-167b5e0d8634	String	jsonType.label
c778e967-1f9b-47d3-9c31-7f3e28f141c2	true	introspection.token.claim
c778e967-1f9b-47d3-9c31-7f3e28f141c2	true	userinfo.token.claim
c778e967-1f9b-47d3-9c31-7f3e28f141c2	emailVerified	user.attribute
c778e967-1f9b-47d3-9c31-7f3e28f141c2	true	id.token.claim
c778e967-1f9b-47d3-9c31-7f3e28f141c2	true	access.token.claim
c778e967-1f9b-47d3-9c31-7f3e28f141c2	email_verified	claim.name
c778e967-1f9b-47d3-9c31-7f3e28f141c2	boolean	jsonType.label
c8c8602c-b3a2-446a-a6ba-5b210315e5c3	formatted	user.attribute.formatted
c8c8602c-b3a2-446a-a6ba-5b210315e5c3	country	user.attribute.country
c8c8602c-b3a2-446a-a6ba-5b210315e5c3	true	introspection.token.claim
c8c8602c-b3a2-446a-a6ba-5b210315e5c3	postal_code	user.attribute.postal_code
c8c8602c-b3a2-446a-a6ba-5b210315e5c3	true	userinfo.token.claim
c8c8602c-b3a2-446a-a6ba-5b210315e5c3	street	user.attribute.street
c8c8602c-b3a2-446a-a6ba-5b210315e5c3	true	id.token.claim
c8c8602c-b3a2-446a-a6ba-5b210315e5c3	region	user.attribute.region
c8c8602c-b3a2-446a-a6ba-5b210315e5c3	true	access.token.claim
c8c8602c-b3a2-446a-a6ba-5b210315e5c3	locality	user.attribute.locality
0a4e191c-6dfc-4ea3-86bb-a191c969e1c3	true	introspection.token.claim
0a4e191c-6dfc-4ea3-86bb-a191c969e1c3	true	userinfo.token.claim
0a4e191c-6dfc-4ea3-86bb-a191c969e1c3	phoneNumberVerified	user.attribute
0a4e191c-6dfc-4ea3-86bb-a191c969e1c3	true	id.token.claim
0a4e191c-6dfc-4ea3-86bb-a191c969e1c3	true	access.token.claim
0a4e191c-6dfc-4ea3-86bb-a191c969e1c3	phone_number_verified	claim.name
0a4e191c-6dfc-4ea3-86bb-a191c969e1c3	boolean	jsonType.label
e8fe1ba9-81b6-4864-8c78-9aae9925ec55	true	introspection.token.claim
e8fe1ba9-81b6-4864-8c78-9aae9925ec55	true	userinfo.token.claim
e8fe1ba9-81b6-4864-8c78-9aae9925ec55	phoneNumber	user.attribute
e8fe1ba9-81b6-4864-8c78-9aae9925ec55	true	id.token.claim
e8fe1ba9-81b6-4864-8c78-9aae9925ec55	true	access.token.claim
e8fe1ba9-81b6-4864-8c78-9aae9925ec55	phone_number	claim.name
e8fe1ba9-81b6-4864-8c78-9aae9925ec55	String	jsonType.label
18c01751-893f-4b5a-b8c4-ab490aa96499	true	introspection.token.claim
18c01751-893f-4b5a-b8c4-ab490aa96499	true	access.token.claim
4a3934f9-1031-4af0-aa4f-6759fd5eb2ac	true	introspection.token.claim
4a3934f9-1031-4af0-aa4f-6759fd5eb2ac	true	multivalued
4a3934f9-1031-4af0-aa4f-6759fd5eb2ac	foo	user.attribute
4a3934f9-1031-4af0-aa4f-6759fd5eb2ac	true	access.token.claim
4a3934f9-1031-4af0-aa4f-6759fd5eb2ac	resource_access.${client_id}.roles	claim.name
4a3934f9-1031-4af0-aa4f-6759fd5eb2ac	String	jsonType.label
64ef99ef-d853-4b9d-9f58-98a92884893e	true	introspection.token.claim
64ef99ef-d853-4b9d-9f58-98a92884893e	true	multivalued
64ef99ef-d853-4b9d-9f58-98a92884893e	foo	user.attribute
64ef99ef-d853-4b9d-9f58-98a92884893e	true	access.token.claim
64ef99ef-d853-4b9d-9f58-98a92884893e	realm_access.roles	claim.name
64ef99ef-d853-4b9d-9f58-98a92884893e	String	jsonType.label
dda8c124-bd9a-43ef-b0c2-5f34620c0716	true	introspection.token.claim
dda8c124-bd9a-43ef-b0c2-5f34620c0716	true	access.token.claim
2b3d70be-3be6-49f4-84b3-4d874995064c	true	introspection.token.claim
2b3d70be-3be6-49f4-84b3-4d874995064c	true	multivalued
2b3d70be-3be6-49f4-84b3-4d874995064c	foo	user.attribute
2b3d70be-3be6-49f4-84b3-4d874995064c	true	id.token.claim
2b3d70be-3be6-49f4-84b3-4d874995064c	true	access.token.claim
2b3d70be-3be6-49f4-84b3-4d874995064c	groups	claim.name
2b3d70be-3be6-49f4-84b3-4d874995064c	String	jsonType.label
c6071302-bf41-4fc2-9ce5-355c02cda6b5	true	introspection.token.claim
c6071302-bf41-4fc2-9ce5-355c02cda6b5	true	userinfo.token.claim
c6071302-bf41-4fc2-9ce5-355c02cda6b5	username	user.attribute
c6071302-bf41-4fc2-9ce5-355c02cda6b5	true	id.token.claim
c6071302-bf41-4fc2-9ce5-355c02cda6b5	true	access.token.claim
c6071302-bf41-4fc2-9ce5-355c02cda6b5	upn	claim.name
c6071302-bf41-4fc2-9ce5-355c02cda6b5	String	jsonType.label
9998f452-0d69-49b2-bb79-7e769b62c499	true	introspection.token.claim
9998f452-0d69-49b2-bb79-7e769b62c499	true	id.token.claim
9998f452-0d69-49b2-bb79-7e769b62c499	true	access.token.claim
1a6d663f-38bd-403f-8400-1a7c5a8b006c	true	introspection.token.claim
1a6d663f-38bd-403f-8400-1a7c5a8b006c	true	userinfo.token.claim
1a6d663f-38bd-403f-8400-1a7c5a8b006c	locale	user.attribute
1a6d663f-38bd-403f-8400-1a7c5a8b006c	true	id.token.claim
1a6d663f-38bd-403f-8400-1a7c5a8b006c	true	access.token.claim
1a6d663f-38bd-403f-8400-1a7c5a8b006c	locale	claim.name
1a6d663f-38bd-403f-8400-1a7c5a8b006c	String	jsonType.label
\.


--
-- Data for Name: realm; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.realm (id, access_code_lifespan, user_action_lifespan, access_token_lifespan, account_theme, admin_theme, email_theme, enabled, events_enabled, events_expiration, login_theme, name, not_before, password_policy, registration_allowed, remember_me, reset_password_allowed, social, ssl_required, sso_idle_timeout, sso_max_lifespan, update_profile_on_soc_login, verify_email, master_admin_client, login_lifespan, internationalization_enabled, default_locale, reg_email_as_username, admin_events_enabled, admin_events_details_enabled, edit_username_allowed, otp_policy_counter, otp_policy_window, otp_policy_period, otp_policy_digits, otp_policy_alg, otp_policy_type, browser_flow, registration_flow, direct_grant_flow, reset_credentials_flow, client_auth_flow, offline_session_idle_timeout, revoke_refresh_token, access_token_life_implicit, login_with_email_allowed, duplicate_emails_allowed, docker_auth_flow, refresh_token_max_reuse, allow_user_managed_access, sso_max_lifespan_remember_me, sso_idle_timeout_remember_me, default_role) FROM stdin;
b748fd0d-b840-453b-b49c-26b926a71139	60	300	60	\N	\N	\N	t	f	0	\N	master	0	\N	f	f	f	f	EXTERNAL	1800	36000	f	f	8555aea4-b785-4d79-996c-47e79ebae943	1800	f	\N	f	f	f	f	0	1	30	6	HmacSHA1	totp	cf004547-830f-4a07-b5fa-386cd9c7d842	fda073a3-8ba9-4d8e-892a-c133e9f5966b	776caa78-f5f5-4435-8668-a0d485f5b456	a7a23995-0f05-4882-98e3-951595cb264f	72229a16-9d72-4c05-a5be-ece0ba7e1b56	2592000	f	900	t	f	c0c1525f-0937-494b-aab6-fa8e02539bf3	0	f	0	0	782cb36d-398b-422e-8a8d-1c0d950eeaed
354b9070-b2b9-4f85-9ab1-d7b290304732	60	300	300	\N	\N	\N	t	f	0	\N	vermeg-sirh	0	\N	t	f	t	f	EXTERNAL	1800	36000	f	f	96861af9-57ec-4594-9587-dd4defa93b53	1800	f	\N	f	f	f	f	0	1	30	6	HmacSHA1	totp	66a70324-e6d8-4619-928c-7868e7322f0e	1a5b2e92-b2e0-4f78-98fb-539431b029fe	a6038308-cc02-49b9-9c2b-c664c0f31a7c	0ad663f0-8f1b-47ad-8731-5fa954b247bb	213f336e-969e-4ae9-9030-9463713396df	2592000	f	900	t	f	281effda-308a-4658-9c7f-7919121c4df7	0	f	0	0	1a0603b9-d25d-4576-9d1b-3f6258a4f87e
\.


--
-- Data for Name: realm_attribute; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.realm_attribute (name, realm_id, value) FROM stdin;
_browser_header.contentSecurityPolicyReportOnly	b748fd0d-b840-453b-b49c-26b926a71139	
_browser_header.xContentTypeOptions	b748fd0d-b840-453b-b49c-26b926a71139	nosniff
_browser_header.referrerPolicy	b748fd0d-b840-453b-b49c-26b926a71139	no-referrer
_browser_header.xRobotsTag	b748fd0d-b840-453b-b49c-26b926a71139	none
_browser_header.xFrameOptions	b748fd0d-b840-453b-b49c-26b926a71139	SAMEORIGIN
_browser_header.contentSecurityPolicy	b748fd0d-b840-453b-b49c-26b926a71139	frame-src 'self'; frame-ancestors 'self'; object-src 'none';
_browser_header.xXSSProtection	b748fd0d-b840-453b-b49c-26b926a71139	1; mode=block
_browser_header.strictTransportSecurity	b748fd0d-b840-453b-b49c-26b926a71139	max-age=31536000; includeSubDomains
bruteForceProtected	b748fd0d-b840-453b-b49c-26b926a71139	false
permanentLockout	b748fd0d-b840-453b-b49c-26b926a71139	false
maxTemporaryLockouts	b748fd0d-b840-453b-b49c-26b926a71139	0
maxFailureWaitSeconds	b748fd0d-b840-453b-b49c-26b926a71139	900
minimumQuickLoginWaitSeconds	b748fd0d-b840-453b-b49c-26b926a71139	60
waitIncrementSeconds	b748fd0d-b840-453b-b49c-26b926a71139	60
quickLoginCheckMilliSeconds	b748fd0d-b840-453b-b49c-26b926a71139	1000
maxDeltaTimeSeconds	b748fd0d-b840-453b-b49c-26b926a71139	43200
failureFactor	b748fd0d-b840-453b-b49c-26b926a71139	30
realmReusableOtpCode	b748fd0d-b840-453b-b49c-26b926a71139	false
firstBrokerLoginFlowId	b748fd0d-b840-453b-b49c-26b926a71139	d253edf1-2667-4235-bf75-c042ac7923d8
displayName	b748fd0d-b840-453b-b49c-26b926a71139	Keycloak
displayNameHtml	b748fd0d-b840-453b-b49c-26b926a71139	<div class="kc-logo-text"><span>Keycloak</span></div>
defaultSignatureAlgorithm	b748fd0d-b840-453b-b49c-26b926a71139	RS256
offlineSessionMaxLifespanEnabled	b748fd0d-b840-453b-b49c-26b926a71139	false
offlineSessionMaxLifespan	b748fd0d-b840-453b-b49c-26b926a71139	5184000
_browser_header.contentSecurityPolicyReportOnly	354b9070-b2b9-4f85-9ab1-d7b290304732	
_browser_header.xContentTypeOptions	354b9070-b2b9-4f85-9ab1-d7b290304732	nosniff
_browser_header.referrerPolicy	354b9070-b2b9-4f85-9ab1-d7b290304732	no-referrer
_browser_header.xRobotsTag	354b9070-b2b9-4f85-9ab1-d7b290304732	none
_browser_header.xFrameOptions	354b9070-b2b9-4f85-9ab1-d7b290304732	SAMEORIGIN
_browser_header.contentSecurityPolicy	354b9070-b2b9-4f85-9ab1-d7b290304732	frame-src 'self'; frame-ancestors 'self'; object-src 'none';
_browser_header.xXSSProtection	354b9070-b2b9-4f85-9ab1-d7b290304732	1; mode=block
_browser_header.strictTransportSecurity	354b9070-b2b9-4f85-9ab1-d7b290304732	max-age=31536000; includeSubDomains
bruteForceProtected	354b9070-b2b9-4f85-9ab1-d7b290304732	false
permanentLockout	354b9070-b2b9-4f85-9ab1-d7b290304732	false
maxTemporaryLockouts	354b9070-b2b9-4f85-9ab1-d7b290304732	0
maxFailureWaitSeconds	354b9070-b2b9-4f85-9ab1-d7b290304732	900
minimumQuickLoginWaitSeconds	354b9070-b2b9-4f85-9ab1-d7b290304732	60
waitIncrementSeconds	354b9070-b2b9-4f85-9ab1-d7b290304732	60
quickLoginCheckMilliSeconds	354b9070-b2b9-4f85-9ab1-d7b290304732	1000
maxDeltaTimeSeconds	354b9070-b2b9-4f85-9ab1-d7b290304732	43200
failureFactor	354b9070-b2b9-4f85-9ab1-d7b290304732	30
realmReusableOtpCode	354b9070-b2b9-4f85-9ab1-d7b290304732	false
defaultSignatureAlgorithm	354b9070-b2b9-4f85-9ab1-d7b290304732	RS256
offlineSessionMaxLifespanEnabled	354b9070-b2b9-4f85-9ab1-d7b290304732	false
offlineSessionMaxLifespan	354b9070-b2b9-4f85-9ab1-d7b290304732	5184000
actionTokenGeneratedByAdminLifespan	354b9070-b2b9-4f85-9ab1-d7b290304732	43200
actionTokenGeneratedByUserLifespan	354b9070-b2b9-4f85-9ab1-d7b290304732	300
oauth2DeviceCodeLifespan	354b9070-b2b9-4f85-9ab1-d7b290304732	600
oauth2DevicePollingInterval	354b9070-b2b9-4f85-9ab1-d7b290304732	5
webAuthnPolicyRpEntityName	354b9070-b2b9-4f85-9ab1-d7b290304732	keycloak
webAuthnPolicySignatureAlgorithms	354b9070-b2b9-4f85-9ab1-d7b290304732	ES256
webAuthnPolicyRpId	354b9070-b2b9-4f85-9ab1-d7b290304732	
webAuthnPolicyAttestationConveyancePreference	354b9070-b2b9-4f85-9ab1-d7b290304732	not specified
webAuthnPolicyAuthenticatorAttachment	354b9070-b2b9-4f85-9ab1-d7b290304732	not specified
webAuthnPolicyRequireResidentKey	354b9070-b2b9-4f85-9ab1-d7b290304732	not specified
webAuthnPolicyUserVerificationRequirement	354b9070-b2b9-4f85-9ab1-d7b290304732	not specified
webAuthnPolicyCreateTimeout	354b9070-b2b9-4f85-9ab1-d7b290304732	0
webAuthnPolicyAvoidSameAuthenticatorRegister	354b9070-b2b9-4f85-9ab1-d7b290304732	false
webAuthnPolicyRpEntityNamePasswordless	354b9070-b2b9-4f85-9ab1-d7b290304732	keycloak
webAuthnPolicySignatureAlgorithmsPasswordless	354b9070-b2b9-4f85-9ab1-d7b290304732	ES256
webAuthnPolicyRpIdPasswordless	354b9070-b2b9-4f85-9ab1-d7b290304732	
webAuthnPolicyAttestationConveyancePreferencePasswordless	354b9070-b2b9-4f85-9ab1-d7b290304732	not specified
webAuthnPolicyAuthenticatorAttachmentPasswordless	354b9070-b2b9-4f85-9ab1-d7b290304732	not specified
webAuthnPolicyRequireResidentKeyPasswordless	354b9070-b2b9-4f85-9ab1-d7b290304732	not specified
webAuthnPolicyUserVerificationRequirementPasswordless	354b9070-b2b9-4f85-9ab1-d7b290304732	not specified
webAuthnPolicyCreateTimeoutPasswordless	354b9070-b2b9-4f85-9ab1-d7b290304732	0
webAuthnPolicyAvoidSameAuthenticatorRegisterPasswordless	354b9070-b2b9-4f85-9ab1-d7b290304732	false
cibaBackchannelTokenDeliveryMode	354b9070-b2b9-4f85-9ab1-d7b290304732	poll
cibaExpiresIn	354b9070-b2b9-4f85-9ab1-d7b290304732	120
cibaInterval	354b9070-b2b9-4f85-9ab1-d7b290304732	5
cibaAuthRequestedUserHint	354b9070-b2b9-4f85-9ab1-d7b290304732	login_hint
parRequestUriLifespan	354b9070-b2b9-4f85-9ab1-d7b290304732	60
firstBrokerLoginFlowId	354b9070-b2b9-4f85-9ab1-d7b290304732	04a11733-be63-45d0-aba3-d9e29cea5b3d
\.


--
-- Data for Name: realm_default_groups; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.realm_default_groups (realm_id, group_id) FROM stdin;
\.


--
-- Data for Name: realm_enabled_event_types; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.realm_enabled_event_types (realm_id, value) FROM stdin;
\.


--
-- Data for Name: realm_events_listeners; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.realm_events_listeners (realm_id, value) FROM stdin;
b748fd0d-b840-453b-b49c-26b926a71139	jboss-logging
354b9070-b2b9-4f85-9ab1-d7b290304732	jboss-logging
\.


--
-- Data for Name: realm_localizations; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.realm_localizations (realm_id, locale, texts) FROM stdin;
\.


--
-- Data for Name: realm_required_credential; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.realm_required_credential (type, form_label, input, secret, realm_id) FROM stdin;
password	password	t	t	b748fd0d-b840-453b-b49c-26b926a71139
password	password	t	t	354b9070-b2b9-4f85-9ab1-d7b290304732
\.


--
-- Data for Name: realm_smtp_config; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.realm_smtp_config (realm_id, value, name) FROM stdin;
\.


--
-- Data for Name: realm_supported_locales; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.realm_supported_locales (realm_id, value) FROM stdin;
\.


--
-- Data for Name: redirect_uris; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.redirect_uris (client_id, value) FROM stdin;
4d54aa61-2812-4233-b6c8-1c148de24706	/realms/master/account/*
fcf80481-f9c8-44c6-8f42-0523de9bbcc6	/realms/master/account/*
2c39f546-574c-436f-bd84-c217e5de074c	/admin/master/console/*
321503d7-7ad4-4062-a43b-6ed10dde5585	/realms/vermeg-sirh/account/*
a128520c-0fb1-4780-b35f-0a42e859e46d	/realms/vermeg-sirh/account/*
fa8f3487-99ca-4e48-aca6-c706a7949899	/admin/vermeg-sirh/console/*
65312025-7a16-4921-843b-47c7a1f5fc29	http://localhost:5173/*
65312025-7a16-4921-843b-47c7a1f5fc29	http://localhost:4200/*
\.


--
-- Data for Name: required_action_config; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.required_action_config (required_action_id, value, name) FROM stdin;
\.


--
-- Data for Name: required_action_provider; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.required_action_provider (id, alias, name, realm_id, enabled, default_action, provider_id, priority) FROM stdin;
f8ceda7f-eb33-45c3-ab11-81d44fad80bc	VERIFY_EMAIL	Verify Email	b748fd0d-b840-453b-b49c-26b926a71139	t	f	VERIFY_EMAIL	50
c64e0839-c072-4b78-8357-820adba24866	UPDATE_PROFILE	Update Profile	b748fd0d-b840-453b-b49c-26b926a71139	t	f	UPDATE_PROFILE	40
17e13992-cba6-4dea-8b2a-e2523618a59b	CONFIGURE_TOTP	Configure OTP	b748fd0d-b840-453b-b49c-26b926a71139	t	f	CONFIGURE_TOTP	10
166f816e-68fd-440d-91b4-1a6fc65b62eb	UPDATE_PASSWORD	Update Password	b748fd0d-b840-453b-b49c-26b926a71139	t	f	UPDATE_PASSWORD	30
f52ea5c7-238d-4e73-96f6-96e411b4c9d5	TERMS_AND_CONDITIONS	Terms and Conditions	b748fd0d-b840-453b-b49c-26b926a71139	f	f	TERMS_AND_CONDITIONS	20
dd7066d0-023c-47c0-8872-354d4fb00bf7	delete_account	Delete Account	b748fd0d-b840-453b-b49c-26b926a71139	f	f	delete_account	60
d68fc27c-d130-4628-ab45-dbf089d056e2	delete_credential	Delete Credential	b748fd0d-b840-453b-b49c-26b926a71139	t	f	delete_credential	100
54dc981a-79fe-401b-8296-24d0859e5c17	update_user_locale	Update User Locale	b748fd0d-b840-453b-b49c-26b926a71139	t	f	update_user_locale	1000
aa1d524e-a3dd-431a-8a59-15c6b1b73904	webauthn-register	Webauthn Register	b748fd0d-b840-453b-b49c-26b926a71139	t	f	webauthn-register	70
2323f192-d15e-47d2-b56d-9b9efeec6d64	webauthn-register-passwordless	Webauthn Register Passwordless	b748fd0d-b840-453b-b49c-26b926a71139	t	f	webauthn-register-passwordless	80
ccfad09c-5dc9-406c-8d15-35e327042664	VERIFY_PROFILE	Verify Profile	b748fd0d-b840-453b-b49c-26b926a71139	t	f	VERIFY_PROFILE	90
723f5dfb-ec2d-4b07-94da-ac6cec98ed3b	VERIFY_EMAIL	Verify Email	354b9070-b2b9-4f85-9ab1-d7b290304732	t	f	VERIFY_EMAIL	50
35975b19-669b-44e1-b824-df6ec2e06f9c	UPDATE_PROFILE	Update Profile	354b9070-b2b9-4f85-9ab1-d7b290304732	t	f	UPDATE_PROFILE	40
4ef9216e-64f7-43d0-86b2-6dd1ea41e6cc	CONFIGURE_TOTP	Configure OTP	354b9070-b2b9-4f85-9ab1-d7b290304732	t	f	CONFIGURE_TOTP	10
4c8da1c9-2c74-452e-a13a-043bbcc34abb	UPDATE_PASSWORD	Update Password	354b9070-b2b9-4f85-9ab1-d7b290304732	t	f	UPDATE_PASSWORD	30
f4b5527e-c93f-4e94-b35f-1a07b2a57a73	TERMS_AND_CONDITIONS	Terms and Conditions	354b9070-b2b9-4f85-9ab1-d7b290304732	f	f	TERMS_AND_CONDITIONS	20
f06db360-9ac0-4a8d-a46f-647971135243	delete_account	Delete Account	354b9070-b2b9-4f85-9ab1-d7b290304732	f	f	delete_account	60
46e4c769-4002-4364-8ba5-534cf646fab9	delete_credential	Delete Credential	354b9070-b2b9-4f85-9ab1-d7b290304732	t	f	delete_credential	100
d4ee8db1-8ca3-4eeb-84e5-90eb5053cf2e	update_user_locale	Update User Locale	354b9070-b2b9-4f85-9ab1-d7b290304732	t	f	update_user_locale	1000
438b91a1-242e-45f6-9f07-efc487421b82	webauthn-register	Webauthn Register	354b9070-b2b9-4f85-9ab1-d7b290304732	t	f	webauthn-register	70
3149f913-2ea2-47e7-b7b2-00570414794d	webauthn-register-passwordless	Webauthn Register Passwordless	354b9070-b2b9-4f85-9ab1-d7b290304732	t	f	webauthn-register-passwordless	80
6beaed34-a409-4370-8797-62367cbedd2a	VERIFY_PROFILE	Verify Profile	354b9070-b2b9-4f85-9ab1-d7b290304732	t	f	VERIFY_PROFILE	90
\.


--
-- Data for Name: resource_attribute; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.resource_attribute (id, name, value, resource_id) FROM stdin;
\.


--
-- Data for Name: resource_policy; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.resource_policy (resource_id, policy_id) FROM stdin;
\.


--
-- Data for Name: resource_scope; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.resource_scope (resource_id, scope_id) FROM stdin;
\.


--
-- Data for Name: resource_server; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.resource_server (id, allow_rs_remote_mgmt, policy_enforce_mode, decision_strategy) FROM stdin;
\.


--
-- Data for Name: resource_server_perm_ticket; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.resource_server_perm_ticket (id, owner, requester, created_timestamp, granted_timestamp, resource_id, scope_id, resource_server_id, policy_id) FROM stdin;
\.


--
-- Data for Name: resource_server_policy; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.resource_server_policy (id, name, description, type, decision_strategy, logic, resource_server_id, owner) FROM stdin;
\.


--
-- Data for Name: resource_server_resource; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.resource_server_resource (id, name, type, icon_uri, owner, resource_server_id, owner_managed_access, display_name) FROM stdin;
\.


--
-- Data for Name: resource_server_scope; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.resource_server_scope (id, name, icon_uri, resource_server_id, display_name) FROM stdin;
\.


--
-- Data for Name: resource_uris; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.resource_uris (resource_id, value) FROM stdin;
\.


--
-- Data for Name: role_attribute; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.role_attribute (id, role_id, name, value) FROM stdin;
\.


--
-- Data for Name: salary_requests; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.salary_requests (id, created_at, details, employee_email, file_data, file_name, month, status, user_id, year) FROM stdin;
\.


--
-- Data for Name: scope_mapping; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.scope_mapping (client_id, role_id) FROM stdin;
fcf80481-f9c8-44c6-8f42-0523de9bbcc6	f0ae8753-c8b8-4b37-9c6c-408b0181cad2
fcf80481-f9c8-44c6-8f42-0523de9bbcc6	287301ad-8076-43a9-9ff2-544149507722
a128520c-0fb1-4780-b35f-0a42e859e46d	1ce1b465-8cf1-4fac-aba9-9c315ab34626
a128520c-0fb1-4780-b35f-0a42e859e46d	0d9e077c-1f18-49a7-8bb7-7c7fae36764f
\.


--
-- Data for Name: scope_policy; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.scope_policy (scope_id, policy_id) FROM stdin;
\.


--
-- Data for Name: user_attribute; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.user_attribute (name, value, user_id, id, long_value_hash, long_value_hash_lower_case, long_value) FROM stdin;
\.


--
-- Data for Name: user_consent; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.user_consent (id, client_id, user_id, created_date, last_updated_date, client_storage_provider, external_client_id) FROM stdin;
\.


--
-- Data for Name: user_consent_client_scope; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.user_consent_client_scope (user_consent_id, scope_id) FROM stdin;
\.


--
-- Data for Name: user_entity; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.user_entity (id, email, email_constraint, email_verified, enabled, federation_link, first_name, last_name, realm_id, username, created_timestamp, service_account_client_link, not_before) FROM stdin;
b622d56d-af41-42cb-a289-b722f06cfc46	admin@vermeg.com	admin@vermeg.com	t	t	\N	Admin	VERMEG	354b9070-b2b9-4f85-9ab1-d7b290304732	admin@vermeg.com	\N	\N	0
337bad47-9d8d-45bd-acac-b20997ee568b	manager@vermeg.com	manager@vermeg.com	t	t	\N	Marc	Manager	354b9070-b2b9-4f85-9ab1-d7b290304732	manager@vermeg.com	\N	\N	0
662f0129-70d9-480f-bd5f-8c13163e5d99	recruiter@vermeg.com	recruiter@vermeg.com	t	t	\N	Rita	Recruteur	354b9070-b2b9-4f85-9ab1-d7b290304732	recruiter@vermeg.com	\N	\N	0
f5121e97-fd33-4fc0-b11d-3e47ea5f485a	employee@vermeg.com	employee@vermeg.com	t	t	\N	Eric	Employe	354b9070-b2b9-4f85-9ab1-d7b290304732	employee@vermeg.com	\N	\N	0
23339660-b61a-4379-99be-262522d6d506	\N	c905d904-7ca2-409d-bdbc-7e11e39cefac	f	t	\N	\N	\N	b748fd0d-b840-453b-b49c-26b926a71139	admin	1775131328443	\N	0
ed68e8ce-6e3f-447e-b6b9-a492ee46b5d8	hassanmezzi5@gmail.com	hassanmezzi5@gmail.com	t	t	\N	o	m	354b9070-b2b9-4f85-9ab1-d7b290304732	hassanmezzi5@gmail.com	1775131423345	\N	0
\.


--
-- Data for Name: user_federation_config; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.user_federation_config (user_federation_provider_id, value, name) FROM stdin;
\.


--
-- Data for Name: user_federation_mapper; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.user_federation_mapper (id, name, federation_provider_id, federation_mapper_type, realm_id) FROM stdin;
\.


--
-- Data for Name: user_federation_mapper_config; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.user_federation_mapper_config (user_federation_mapper_id, value, name) FROM stdin;
\.


--
-- Data for Name: user_federation_provider; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.user_federation_provider (id, changed_sync_period, display_name, full_sync_period, last_sync, priority, provider_name, realm_id) FROM stdin;
\.


--
-- Data for Name: user_group_membership; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.user_group_membership (group_id, user_id) FROM stdin;
\.


--
-- Data for Name: user_required_action; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.user_required_action (user_id, required_action) FROM stdin;
\.


--
-- Data for Name: user_role_mapping; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.user_role_mapping (role_id, user_id) FROM stdin;
68d859f3-377e-4275-9624-5ea338b091b4	b622d56d-af41-42cb-a289-b722f06cfc46
26325d0e-fb28-4f0c-ac88-b9f638808ec2	337bad47-9d8d-45bd-acac-b20997ee568b
2282bfc8-df36-4a2c-9140-7aa480515b60	662f0129-70d9-480f-bd5f-8c13163e5d99
8a39cd47-6c32-447a-845f-f641728b413e	f5121e97-fd33-4fc0-b11d-3e47ea5f485a
782cb36d-398b-422e-8a8d-1c0d950eeaed	23339660-b61a-4379-99be-262522d6d506
5dc37d22-3d72-4ac5-96e2-f8a03ac8b49d	23339660-b61a-4379-99be-262522d6d506
1a0603b9-d25d-4576-9d1b-3f6258a4f87e	ed68e8ce-6e3f-447e-b6b9-a492ee46b5d8
e95cabc6-0d98-4fd3-9cfe-3c503a9d7416	ed68e8ce-6e3f-447e-b6b9-a492ee46b5d8
\.


--
-- Data for Name: user_session; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.user_session (id, auth_method, ip_address, last_session_refresh, login_username, realm_id, remember_me, started, user_id, user_session_state, broker_session_id, broker_user_id) FROM stdin;
\.


--
-- Data for Name: user_session_note; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.user_session_note (user_session, name, value) FROM stdin;
\.


--
-- Data for Name: username_login_failure; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.username_login_failure (realm_id, username, failed_login_not_before, last_failure, last_ip_failure, num_failures) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.users (id, avatar_url, city, contract_type, country, department, diploma, email, experience, full_name, leave_balance, manager_id, phone, "position", role, salary, total_hours) FROM stdin;
1	\N	\N	\N	\N	Non defini	\N	admin@vermeg.com	\N	Admin VERMEG	25	\N	\N	\N	HR_ADMIN	\N	0
3	\N	\N	\N	\N	\N	\N	hassanmezzi5@gmail.com	\N	o m	25	\N	\N	\N	CANDIDATE	\N	0
4	\N	\N	\N	\N	Non defini	\N	manager@vermeg.com	\N	Marc Manager	25	\N	\N	\N	MANAGER	\N	0
7	\N	\N	\N	\N	RH	\N	recruiter@vermeg.com	5 ans	Rita Recruteur	20	\N	\N	Talent Acquisition	RECRUITER	\N	1200
9	\N	\N	\N	\N	IT	\N	candidate@vermeg.com	1 an	Camille Candidate	25	\N	\N	Developpeur React	CANDIDATE	\N	0
2	\N	\N	\N	\N	Non defini	\N	employee@vermeg.com	\N	Eric Employe	25	4	\N	\N	EMPLOYEE	\N	0
\.


--
-- Data for Name: web_origins; Type: TABLE DATA; Schema: public; Owner: vermeg
--

COPY public.web_origins (client_id, value) FROM stdin;
2c39f546-574c-436f-bd84-c217e5de074c	+
fa8f3487-99ca-4e48-aca6-c706a7949899	+
65312025-7a16-4921-843b-47c7a1f5fc29	http://localhost:4200
65312025-7a16-4921-843b-47c7a1f5fc29	http://localhost:5173
\.


--
-- Name: applications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vermeg
--

SELECT pg_catalog.setval('public.applications_id_seq', 1, true);


--
-- Name: approval_decisions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vermeg
--

SELECT pg_catalog.setval('public.approval_decisions_id_seq', 1, false);


--
-- Name: contract_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vermeg
--

SELECT pg_catalog.setval('public.contract_types_id_seq', 3, true);


--
-- Name: departments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vermeg
--

SELECT pg_catalog.setval('public.departments_id_seq', 3, true);


--
-- Name: document_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vermeg
--

SELECT pg_catalog.setval('public.document_requests_id_seq', 1, false);


--
-- Name: interviews_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vermeg
--

SELECT pg_catalog.setval('public.interviews_id_seq', 1, false);


--
-- Name: job_offers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vermeg
--

SELECT pg_catalog.setval('public.job_offers_id_seq', 2, true);


--
-- Name: leave_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vermeg
--

SELECT pg_catalog.setval('public.leave_requests_id_seq', 1, false);


--
-- Name: messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vermeg
--

SELECT pg_catalog.setval('public.messages_id_seq', 1, false);


--
-- Name: news_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vermeg
--

SELECT pg_catalog.setval('public.news_id_seq', 1, true);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vermeg
--

SELECT pg_catalog.setval('public.notifications_id_seq', 1, true);


--
-- Name: positions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vermeg
--

SELECT pg_catalog.setval('public.positions_id_seq', 1, false);


--
-- Name: salary_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vermeg
--

SELECT pg_catalog.setval('public.salary_requests_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vermeg
--

SELECT pg_catalog.setval('public.users_id_seq', 9, true);


--
-- Name: username_login_failure CONSTRAINT_17-2; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.username_login_failure
    ADD CONSTRAINT "CONSTRAINT_17-2" PRIMARY KEY (realm_id, username);


--
-- Name: keycloak_role UK_J3RWUVD56ONTGSUHOGM184WW2-2; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.keycloak_role
    ADD CONSTRAINT "UK_J3RWUVD56ONTGSUHOGM184WW2-2" UNIQUE (name, client_realm_constraint);


--
-- Name: applications applications_pkey; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.applications
    ADD CONSTRAINT applications_pkey PRIMARY KEY (id);


--
-- Name: approval_decisions approval_decisions_pkey; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.approval_decisions
    ADD CONSTRAINT approval_decisions_pkey PRIMARY KEY (id);


--
-- Name: client_auth_flow_bindings c_cli_flow_bind; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.client_auth_flow_bindings
    ADD CONSTRAINT c_cli_flow_bind PRIMARY KEY (client_id, binding_name);


--
-- Name: client_scope_client c_cli_scope_bind; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.client_scope_client
    ADD CONSTRAINT c_cli_scope_bind PRIMARY KEY (client_id, scope_id);


--
-- Name: client_initial_access cnstr_client_init_acc_pk; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.client_initial_access
    ADD CONSTRAINT cnstr_client_init_acc_pk PRIMARY KEY (id);


--
-- Name: realm_default_groups con_group_id_def_groups; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.realm_default_groups
    ADD CONSTRAINT con_group_id_def_groups UNIQUE (group_id);


--
-- Name: broker_link constr_broker_link_pk; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.broker_link
    ADD CONSTRAINT constr_broker_link_pk PRIMARY KEY (identity_provider, user_id);


--
-- Name: client_user_session_note constr_cl_usr_ses_note; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.client_user_session_note
    ADD CONSTRAINT constr_cl_usr_ses_note PRIMARY KEY (client_session, name);


--
-- Name: component_config constr_component_config_pk; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.component_config
    ADD CONSTRAINT constr_component_config_pk PRIMARY KEY (id);


--
-- Name: component constr_component_pk; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.component
    ADD CONSTRAINT constr_component_pk PRIMARY KEY (id);


--
-- Name: fed_user_required_action constr_fed_required_action; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.fed_user_required_action
    ADD CONSTRAINT constr_fed_required_action PRIMARY KEY (required_action, user_id);


--
-- Name: fed_user_attribute constr_fed_user_attr_pk; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.fed_user_attribute
    ADD CONSTRAINT constr_fed_user_attr_pk PRIMARY KEY (id);


--
-- Name: fed_user_consent constr_fed_user_consent_pk; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.fed_user_consent
    ADD CONSTRAINT constr_fed_user_consent_pk PRIMARY KEY (id);


--
-- Name: fed_user_credential constr_fed_user_cred_pk; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.fed_user_credential
    ADD CONSTRAINT constr_fed_user_cred_pk PRIMARY KEY (id);


--
-- Name: fed_user_group_membership constr_fed_user_group; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.fed_user_group_membership
    ADD CONSTRAINT constr_fed_user_group PRIMARY KEY (group_id, user_id);


--
-- Name: fed_user_role_mapping constr_fed_user_role; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.fed_user_role_mapping
    ADD CONSTRAINT constr_fed_user_role PRIMARY KEY (role_id, user_id);


--
-- Name: federated_user constr_federated_user; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.federated_user
    ADD CONSTRAINT constr_federated_user PRIMARY KEY (id);


--
-- Name: realm_default_groups constr_realm_default_groups; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.realm_default_groups
    ADD CONSTRAINT constr_realm_default_groups PRIMARY KEY (realm_id, group_id);


--
-- Name: realm_enabled_event_types constr_realm_enabl_event_types; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.realm_enabled_event_types
    ADD CONSTRAINT constr_realm_enabl_event_types PRIMARY KEY (realm_id, value);


--
-- Name: realm_events_listeners constr_realm_events_listeners; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.realm_events_listeners
    ADD CONSTRAINT constr_realm_events_listeners PRIMARY KEY (realm_id, value);


--
-- Name: realm_supported_locales constr_realm_supported_locales; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.realm_supported_locales
    ADD CONSTRAINT constr_realm_supported_locales PRIMARY KEY (realm_id, value);


--
-- Name: identity_provider constraint_2b; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.identity_provider
    ADD CONSTRAINT constraint_2b PRIMARY KEY (internal_id);


--
-- Name: client_attributes constraint_3c; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.client_attributes
    ADD CONSTRAINT constraint_3c PRIMARY KEY (client_id, name);


--
-- Name: event_entity constraint_4; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.event_entity
    ADD CONSTRAINT constraint_4 PRIMARY KEY (id);


--
-- Name: federated_identity constraint_40; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.federated_identity
    ADD CONSTRAINT constraint_40 PRIMARY KEY (identity_provider, user_id);


--
-- Name: realm constraint_4a; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.realm
    ADD CONSTRAINT constraint_4a PRIMARY KEY (id);


--
-- Name: client_session_role constraint_5; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.client_session_role
    ADD CONSTRAINT constraint_5 PRIMARY KEY (client_session, role_id);


--
-- Name: user_session constraint_57; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.user_session
    ADD CONSTRAINT constraint_57 PRIMARY KEY (id);


--
-- Name: user_federation_provider constraint_5c; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.user_federation_provider
    ADD CONSTRAINT constraint_5c PRIMARY KEY (id);


--
-- Name: client_session_note constraint_5e; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.client_session_note
    ADD CONSTRAINT constraint_5e PRIMARY KEY (client_session, name);


--
-- Name: client constraint_7; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT constraint_7 PRIMARY KEY (id);


--
-- Name: client_session constraint_8; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.client_session
    ADD CONSTRAINT constraint_8 PRIMARY KEY (id);


--
-- Name: scope_mapping constraint_81; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.scope_mapping
    ADD CONSTRAINT constraint_81 PRIMARY KEY (client_id, role_id);


--
-- Name: client_node_registrations constraint_84; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.client_node_registrations
    ADD CONSTRAINT constraint_84 PRIMARY KEY (client_id, name);


--
-- Name: realm_attribute constraint_9; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.realm_attribute
    ADD CONSTRAINT constraint_9 PRIMARY KEY (name, realm_id);


--
-- Name: realm_required_credential constraint_92; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.realm_required_credential
    ADD CONSTRAINT constraint_92 PRIMARY KEY (realm_id, type);


--
-- Name: keycloak_role constraint_a; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.keycloak_role
    ADD CONSTRAINT constraint_a PRIMARY KEY (id);


--
-- Name: admin_event_entity constraint_admin_event_entity; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.admin_event_entity
    ADD CONSTRAINT constraint_admin_event_entity PRIMARY KEY (id);


--
-- Name: authenticator_config_entry constraint_auth_cfg_pk; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.authenticator_config_entry
    ADD CONSTRAINT constraint_auth_cfg_pk PRIMARY KEY (authenticator_id, name);


--
-- Name: authentication_execution constraint_auth_exec_pk; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.authentication_execution
    ADD CONSTRAINT constraint_auth_exec_pk PRIMARY KEY (id);


--
-- Name: authentication_flow constraint_auth_flow_pk; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.authentication_flow
    ADD CONSTRAINT constraint_auth_flow_pk PRIMARY KEY (id);


--
-- Name: authenticator_config constraint_auth_pk; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.authenticator_config
    ADD CONSTRAINT constraint_auth_pk PRIMARY KEY (id);


--
-- Name: client_session_auth_status constraint_auth_status_pk; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.client_session_auth_status
    ADD CONSTRAINT constraint_auth_status_pk PRIMARY KEY (client_session, authenticator);


--
-- Name: user_role_mapping constraint_c; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.user_role_mapping
    ADD CONSTRAINT constraint_c PRIMARY KEY (role_id, user_id);


--
-- Name: composite_role constraint_composite_role; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.composite_role
    ADD CONSTRAINT constraint_composite_role PRIMARY KEY (composite, child_role);


--
-- Name: client_session_prot_mapper constraint_cs_pmp_pk; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.client_session_prot_mapper
    ADD CONSTRAINT constraint_cs_pmp_pk PRIMARY KEY (client_session, protocol_mapper_id);


--
-- Name: identity_provider_config constraint_d; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.identity_provider_config
    ADD CONSTRAINT constraint_d PRIMARY KEY (identity_provider_id, name);


--
-- Name: policy_config constraint_dpc; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.policy_config
    ADD CONSTRAINT constraint_dpc PRIMARY KEY (policy_id, name);


--
-- Name: realm_smtp_config constraint_e; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.realm_smtp_config
    ADD CONSTRAINT constraint_e PRIMARY KEY (realm_id, name);


--
-- Name: credential constraint_f; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.credential
    ADD CONSTRAINT constraint_f PRIMARY KEY (id);


--
-- Name: user_federation_config constraint_f9; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.user_federation_config
    ADD CONSTRAINT constraint_f9 PRIMARY KEY (user_federation_provider_id, name);


--
-- Name: resource_server_perm_ticket constraint_fapmt; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.resource_server_perm_ticket
    ADD CONSTRAINT constraint_fapmt PRIMARY KEY (id);


--
-- Name: resource_server_resource constraint_farsr; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.resource_server_resource
    ADD CONSTRAINT constraint_farsr PRIMARY KEY (id);


--
-- Name: resource_server_policy constraint_farsrp; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.resource_server_policy
    ADD CONSTRAINT constraint_farsrp PRIMARY KEY (id);


--
-- Name: associated_policy constraint_farsrpap; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.associated_policy
    ADD CONSTRAINT constraint_farsrpap PRIMARY KEY (policy_id, associated_policy_id);


--
-- Name: resource_policy constraint_farsrpp; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.resource_policy
    ADD CONSTRAINT constraint_farsrpp PRIMARY KEY (resource_id, policy_id);


--
-- Name: resource_server_scope constraint_farsrs; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.resource_server_scope
    ADD CONSTRAINT constraint_farsrs PRIMARY KEY (id);


--
-- Name: resource_scope constraint_farsrsp; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.resource_scope
    ADD CONSTRAINT constraint_farsrsp PRIMARY KEY (resource_id, scope_id);


--
-- Name: scope_policy constraint_farsrsps; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.scope_policy
    ADD CONSTRAINT constraint_farsrsps PRIMARY KEY (scope_id, policy_id);


--
-- Name: user_entity constraint_fb; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.user_entity
    ADD CONSTRAINT constraint_fb PRIMARY KEY (id);


--
-- Name: user_federation_mapper_config constraint_fedmapper_cfg_pm; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.user_federation_mapper_config
    ADD CONSTRAINT constraint_fedmapper_cfg_pm PRIMARY KEY (user_federation_mapper_id, name);


--
-- Name: user_federation_mapper constraint_fedmapperpm; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.user_federation_mapper
    ADD CONSTRAINT constraint_fedmapperpm PRIMARY KEY (id);


--
-- Name: fed_user_consent_cl_scope constraint_fgrntcsnt_clsc_pm; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.fed_user_consent_cl_scope
    ADD CONSTRAINT constraint_fgrntcsnt_clsc_pm PRIMARY KEY (user_consent_id, scope_id);


--
-- Name: user_consent_client_scope constraint_grntcsnt_clsc_pm; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.user_consent_client_scope
    ADD CONSTRAINT constraint_grntcsnt_clsc_pm PRIMARY KEY (user_consent_id, scope_id);


--
-- Name: user_consent constraint_grntcsnt_pm; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.user_consent
    ADD CONSTRAINT constraint_grntcsnt_pm PRIMARY KEY (id);


--
-- Name: keycloak_group constraint_group; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.keycloak_group
    ADD CONSTRAINT constraint_group PRIMARY KEY (id);


--
-- Name: group_attribute constraint_group_attribute_pk; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.group_attribute
    ADD CONSTRAINT constraint_group_attribute_pk PRIMARY KEY (id);


--
-- Name: group_role_mapping constraint_group_role; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.group_role_mapping
    ADD CONSTRAINT constraint_group_role PRIMARY KEY (role_id, group_id);


--
-- Name: identity_provider_mapper constraint_idpm; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.identity_provider_mapper
    ADD CONSTRAINT constraint_idpm PRIMARY KEY (id);


--
-- Name: idp_mapper_config constraint_idpmconfig; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.idp_mapper_config
    ADD CONSTRAINT constraint_idpmconfig PRIMARY KEY (idp_mapper_id, name);


--
-- Name: migration_model constraint_migmod; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.migration_model
    ADD CONSTRAINT constraint_migmod PRIMARY KEY (id);


--
-- Name: offline_client_session constraint_offl_cl_ses_pk3; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.offline_client_session
    ADD CONSTRAINT constraint_offl_cl_ses_pk3 PRIMARY KEY (user_session_id, client_id, client_storage_provider, external_client_id, offline_flag);


--
-- Name: offline_user_session constraint_offl_us_ses_pk2; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.offline_user_session
    ADD CONSTRAINT constraint_offl_us_ses_pk2 PRIMARY KEY (user_session_id, offline_flag);


--
-- Name: protocol_mapper constraint_pcm; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.protocol_mapper
    ADD CONSTRAINT constraint_pcm PRIMARY KEY (id);


--
-- Name: protocol_mapper_config constraint_pmconfig; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.protocol_mapper_config
    ADD CONSTRAINT constraint_pmconfig PRIMARY KEY (protocol_mapper_id, name);


--
-- Name: redirect_uris constraint_redirect_uris; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.redirect_uris
    ADD CONSTRAINT constraint_redirect_uris PRIMARY KEY (client_id, value);


--
-- Name: required_action_config constraint_req_act_cfg_pk; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.required_action_config
    ADD CONSTRAINT constraint_req_act_cfg_pk PRIMARY KEY (required_action_id, name);


--
-- Name: required_action_provider constraint_req_act_prv_pk; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.required_action_provider
    ADD CONSTRAINT constraint_req_act_prv_pk PRIMARY KEY (id);


--
-- Name: user_required_action constraint_required_action; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.user_required_action
    ADD CONSTRAINT constraint_required_action PRIMARY KEY (required_action, user_id);


--
-- Name: resource_uris constraint_resour_uris_pk; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.resource_uris
    ADD CONSTRAINT constraint_resour_uris_pk PRIMARY KEY (resource_id, value);


--
-- Name: role_attribute constraint_role_attribute_pk; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.role_attribute
    ADD CONSTRAINT constraint_role_attribute_pk PRIMARY KEY (id);


--
-- Name: user_attribute constraint_user_attribute_pk; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.user_attribute
    ADD CONSTRAINT constraint_user_attribute_pk PRIMARY KEY (id);


--
-- Name: user_group_membership constraint_user_group; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.user_group_membership
    ADD CONSTRAINT constraint_user_group PRIMARY KEY (group_id, user_id);


--
-- Name: user_session_note constraint_usn_pk; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.user_session_note
    ADD CONSTRAINT constraint_usn_pk PRIMARY KEY (user_session, name);


--
-- Name: web_origins constraint_web_origins; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.web_origins
    ADD CONSTRAINT constraint_web_origins PRIMARY KEY (client_id, value);


--
-- Name: contract_types contract_types_pkey; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.contract_types
    ADD CONSTRAINT contract_types_pkey PRIMARY KEY (id);


--
-- Name: databasechangeloglock databasechangeloglock_pkey; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.databasechangeloglock
    ADD CONSTRAINT databasechangeloglock_pkey PRIMARY KEY (id);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: document_requests document_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.document_requests
    ADD CONSTRAINT document_requests_pkey PRIMARY KEY (id);


--
-- Name: interviews interviews_pkey; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.interviews
    ADD CONSTRAINT interviews_pkey PRIMARY KEY (id);


--
-- Name: job_offers job_offers_pkey; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.job_offers
    ADD CONSTRAINT job_offers_pkey PRIMARY KEY (id);


--
-- Name: leave_requests leave_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: news news_pkey; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.news
    ADD CONSTRAINT news_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: client_scope_attributes pk_cl_tmpl_attr; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.client_scope_attributes
    ADD CONSTRAINT pk_cl_tmpl_attr PRIMARY KEY (scope_id, name);


--
-- Name: client_scope pk_cli_template; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.client_scope
    ADD CONSTRAINT pk_cli_template PRIMARY KEY (id);


--
-- Name: resource_server pk_resource_server; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.resource_server
    ADD CONSTRAINT pk_resource_server PRIMARY KEY (id);


--
-- Name: client_scope_role_mapping pk_template_scope; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.client_scope_role_mapping
    ADD CONSTRAINT pk_template_scope PRIMARY KEY (scope_id, role_id);


--
-- Name: positions positions_pkey; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.positions
    ADD CONSTRAINT positions_pkey PRIMARY KEY (id);


--
-- Name: default_client_scope r_def_cli_scope_bind; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.default_client_scope
    ADD CONSTRAINT r_def_cli_scope_bind PRIMARY KEY (realm_id, scope_id);


--
-- Name: realm_localizations realm_localizations_pkey; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.realm_localizations
    ADD CONSTRAINT realm_localizations_pkey PRIMARY KEY (realm_id, locale);


--
-- Name: resource_attribute res_attr_pk; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.resource_attribute
    ADD CONSTRAINT res_attr_pk PRIMARY KEY (id);


--
-- Name: salary_requests salary_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.salary_requests
    ADD CONSTRAINT salary_requests_pkey PRIMARY KEY (id);


--
-- Name: keycloak_group sibling_names; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.keycloak_group
    ADD CONSTRAINT sibling_names UNIQUE (realm_id, parent_group, name);


--
-- Name: identity_provider uk_2daelwnibji49avxsrtuf6xj33; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.identity_provider
    ADD CONSTRAINT uk_2daelwnibji49avxsrtuf6xj33 UNIQUE (provider_alias, realm_id);


--
-- Name: users uk_6dotkott2kjsp8vw4d0m25fb7; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT uk_6dotkott2kjsp8vw4d0m25fb7 UNIQUE (email);


--
-- Name: client uk_b71cjlbenv945rb6gcon438at; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT uk_b71cjlbenv945rb6gcon438at UNIQUE (realm_id, client_id);


--
-- Name: contract_types uk_bj1mlga5tdj2vbtb9w5h0fukj; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.contract_types
    ADD CONSTRAINT uk_bj1mlga5tdj2vbtb9w5h0fukj UNIQUE (name);


--
-- Name: client_scope uk_cli_scope; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.client_scope
    ADD CONSTRAINT uk_cli_scope UNIQUE (realm_id, name);


--
-- Name: user_entity uk_dykn684sl8up1crfei6eckhd7; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.user_entity
    ADD CONSTRAINT uk_dykn684sl8up1crfei6eckhd7 UNIQUE (realm_id, email_constraint);


--
-- Name: resource_server_resource uk_frsr6t700s9v50bu18ws5ha6; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.resource_server_resource
    ADD CONSTRAINT uk_frsr6t700s9v50bu18ws5ha6 UNIQUE (name, owner, resource_server_id);


--
-- Name: resource_server_perm_ticket uk_frsr6t700s9v50bu18ws5pmt; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.resource_server_perm_ticket
    ADD CONSTRAINT uk_frsr6t700s9v50bu18ws5pmt UNIQUE (owner, requester, resource_server_id, resource_id, scope_id);


--
-- Name: resource_server_policy uk_frsrpt700s9v50bu18ws5ha6; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.resource_server_policy
    ADD CONSTRAINT uk_frsrpt700s9v50bu18ws5ha6 UNIQUE (name, resource_server_id);


--
-- Name: resource_server_scope uk_frsrst700s9v50bu18ws5ha6; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.resource_server_scope
    ADD CONSTRAINT uk_frsrst700s9v50bu18ws5ha6 UNIQUE (name, resource_server_id);


--
-- Name: departments uk_j6cwks7xecs5jov19ro8ge3qk; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT uk_j6cwks7xecs5jov19ro8ge3qk UNIQUE (name);


--
-- Name: user_consent uk_jkuwuvd56ontgsuhogm8uewrt; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.user_consent
    ADD CONSTRAINT uk_jkuwuvd56ontgsuhogm8uewrt UNIQUE (client_id, client_storage_provider, external_client_id, user_id);


--
-- Name: realm uk_orvsdmla56612eaefiq6wl5oi; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.realm
    ADD CONSTRAINT uk_orvsdmla56612eaefiq6wl5oi UNIQUE (name);


--
-- Name: user_entity uk_ru8tt6t700s9v50bu18ws5ha6; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.user_entity
    ADD CONSTRAINT uk_ru8tt6t700s9v50bu18ws5ha6 UNIQUE (realm_id, username);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: fed_user_attr_long_values; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX fed_user_attr_long_values ON public.fed_user_attribute USING btree (long_value_hash, name);


--
-- Name: fed_user_attr_long_values_lower_case; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX fed_user_attr_long_values_lower_case ON public.fed_user_attribute USING btree (long_value_hash_lower_case, name);


--
-- Name: idx_admin_event_time; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_admin_event_time ON public.admin_event_entity USING btree (realm_id, admin_event_time);


--
-- Name: idx_assoc_pol_assoc_pol_id; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_assoc_pol_assoc_pol_id ON public.associated_policy USING btree (associated_policy_id);


--
-- Name: idx_auth_config_realm; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_auth_config_realm ON public.authenticator_config USING btree (realm_id);


--
-- Name: idx_auth_exec_flow; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_auth_exec_flow ON public.authentication_execution USING btree (flow_id);


--
-- Name: idx_auth_exec_realm_flow; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_auth_exec_realm_flow ON public.authentication_execution USING btree (realm_id, flow_id);


--
-- Name: idx_auth_flow_realm; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_auth_flow_realm ON public.authentication_flow USING btree (realm_id);


--
-- Name: idx_cl_clscope; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_cl_clscope ON public.client_scope_client USING btree (scope_id);


--
-- Name: idx_client_att_by_name_value; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_client_att_by_name_value ON public.client_attributes USING btree (name, substr(value, 1, 255));


--
-- Name: idx_client_id; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_client_id ON public.client USING btree (client_id);


--
-- Name: idx_client_init_acc_realm; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_client_init_acc_realm ON public.client_initial_access USING btree (realm_id);


--
-- Name: idx_client_session_session; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_client_session_session ON public.client_session USING btree (session_id);


--
-- Name: idx_clscope_attrs; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_clscope_attrs ON public.client_scope_attributes USING btree (scope_id);


--
-- Name: idx_clscope_cl; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_clscope_cl ON public.client_scope_client USING btree (client_id);


--
-- Name: idx_clscope_protmap; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_clscope_protmap ON public.protocol_mapper USING btree (client_scope_id);


--
-- Name: idx_clscope_role; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_clscope_role ON public.client_scope_role_mapping USING btree (scope_id);


--
-- Name: idx_compo_config_compo; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_compo_config_compo ON public.component_config USING btree (component_id);


--
-- Name: idx_component_provider_type; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_component_provider_type ON public.component USING btree (provider_type);


--
-- Name: idx_component_realm; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_component_realm ON public.component USING btree (realm_id);


--
-- Name: idx_composite; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_composite ON public.composite_role USING btree (composite);


--
-- Name: idx_composite_child; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_composite_child ON public.composite_role USING btree (child_role);


--
-- Name: idx_defcls_realm; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_defcls_realm ON public.default_client_scope USING btree (realm_id);


--
-- Name: idx_defcls_scope; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_defcls_scope ON public.default_client_scope USING btree (scope_id);


--
-- Name: idx_event_time; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_event_time ON public.event_entity USING btree (realm_id, event_time);


--
-- Name: idx_fedidentity_feduser; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_fedidentity_feduser ON public.federated_identity USING btree (federated_user_id);


--
-- Name: idx_fedidentity_user; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_fedidentity_user ON public.federated_identity USING btree (user_id);


--
-- Name: idx_fu_attribute; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_fu_attribute ON public.fed_user_attribute USING btree (user_id, realm_id, name);


--
-- Name: idx_fu_cnsnt_ext; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_fu_cnsnt_ext ON public.fed_user_consent USING btree (user_id, client_storage_provider, external_client_id);


--
-- Name: idx_fu_consent; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_fu_consent ON public.fed_user_consent USING btree (user_id, client_id);


--
-- Name: idx_fu_consent_ru; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_fu_consent_ru ON public.fed_user_consent USING btree (realm_id, user_id);


--
-- Name: idx_fu_credential; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_fu_credential ON public.fed_user_credential USING btree (user_id, type);


--
-- Name: idx_fu_credential_ru; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_fu_credential_ru ON public.fed_user_credential USING btree (realm_id, user_id);


--
-- Name: idx_fu_group_membership; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_fu_group_membership ON public.fed_user_group_membership USING btree (user_id, group_id);


--
-- Name: idx_fu_group_membership_ru; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_fu_group_membership_ru ON public.fed_user_group_membership USING btree (realm_id, user_id);


--
-- Name: idx_fu_required_action; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_fu_required_action ON public.fed_user_required_action USING btree (user_id, required_action);


--
-- Name: idx_fu_required_action_ru; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_fu_required_action_ru ON public.fed_user_required_action USING btree (realm_id, user_id);


--
-- Name: idx_fu_role_mapping; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_fu_role_mapping ON public.fed_user_role_mapping USING btree (user_id, role_id);


--
-- Name: idx_fu_role_mapping_ru; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_fu_role_mapping_ru ON public.fed_user_role_mapping USING btree (realm_id, user_id);


--
-- Name: idx_group_att_by_name_value; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_group_att_by_name_value ON public.group_attribute USING btree (name, ((value)::character varying(250)));


--
-- Name: idx_group_attr_group; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_group_attr_group ON public.group_attribute USING btree (group_id);


--
-- Name: idx_group_role_mapp_group; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_group_role_mapp_group ON public.group_role_mapping USING btree (group_id);


--
-- Name: idx_id_prov_mapp_realm; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_id_prov_mapp_realm ON public.identity_provider_mapper USING btree (realm_id);


--
-- Name: idx_ident_prov_realm; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_ident_prov_realm ON public.identity_provider USING btree (realm_id);


--
-- Name: idx_keycloak_role_client; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_keycloak_role_client ON public.keycloak_role USING btree (client);


--
-- Name: idx_keycloak_role_realm; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_keycloak_role_realm ON public.keycloak_role USING btree (realm);


--
-- Name: idx_offline_css_preload; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_offline_css_preload ON public.offline_client_session USING btree (client_id, offline_flag);


--
-- Name: idx_offline_uss_by_user; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_offline_uss_by_user ON public.offline_user_session USING btree (user_id, realm_id, offline_flag);


--
-- Name: idx_offline_uss_by_usersess; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_offline_uss_by_usersess ON public.offline_user_session USING btree (realm_id, offline_flag, user_session_id);


--
-- Name: idx_offline_uss_createdon; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_offline_uss_createdon ON public.offline_user_session USING btree (created_on);


--
-- Name: idx_offline_uss_preload; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_offline_uss_preload ON public.offline_user_session USING btree (offline_flag, created_on, user_session_id);


--
-- Name: idx_protocol_mapper_client; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_protocol_mapper_client ON public.protocol_mapper USING btree (client_id);


--
-- Name: idx_realm_attr_realm; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_realm_attr_realm ON public.realm_attribute USING btree (realm_id);


--
-- Name: idx_realm_clscope; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_realm_clscope ON public.client_scope USING btree (realm_id);


--
-- Name: idx_realm_def_grp_realm; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_realm_def_grp_realm ON public.realm_default_groups USING btree (realm_id);


--
-- Name: idx_realm_evt_list_realm; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_realm_evt_list_realm ON public.realm_events_listeners USING btree (realm_id);


--
-- Name: idx_realm_evt_types_realm; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_realm_evt_types_realm ON public.realm_enabled_event_types USING btree (realm_id);


--
-- Name: idx_realm_master_adm_cli; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_realm_master_adm_cli ON public.realm USING btree (master_admin_client);


--
-- Name: idx_realm_supp_local_realm; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_realm_supp_local_realm ON public.realm_supported_locales USING btree (realm_id);


--
-- Name: idx_redir_uri_client; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_redir_uri_client ON public.redirect_uris USING btree (client_id);


--
-- Name: idx_req_act_prov_realm; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_req_act_prov_realm ON public.required_action_provider USING btree (realm_id);


--
-- Name: idx_res_policy_policy; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_res_policy_policy ON public.resource_policy USING btree (policy_id);


--
-- Name: idx_res_scope_scope; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_res_scope_scope ON public.resource_scope USING btree (scope_id);


--
-- Name: idx_res_serv_pol_res_serv; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_res_serv_pol_res_serv ON public.resource_server_policy USING btree (resource_server_id);


--
-- Name: idx_res_srv_res_res_srv; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_res_srv_res_res_srv ON public.resource_server_resource USING btree (resource_server_id);


--
-- Name: idx_res_srv_scope_res_srv; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_res_srv_scope_res_srv ON public.resource_server_scope USING btree (resource_server_id);


--
-- Name: idx_role_attribute; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_role_attribute ON public.role_attribute USING btree (role_id);


--
-- Name: idx_role_clscope; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_role_clscope ON public.client_scope_role_mapping USING btree (role_id);


--
-- Name: idx_scope_mapping_role; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_scope_mapping_role ON public.scope_mapping USING btree (role_id);


--
-- Name: idx_scope_policy_policy; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_scope_policy_policy ON public.scope_policy USING btree (policy_id);


--
-- Name: idx_update_time; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_update_time ON public.migration_model USING btree (update_time);


--
-- Name: idx_us_sess_id_on_cl_sess; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_us_sess_id_on_cl_sess ON public.offline_client_session USING btree (user_session_id);


--
-- Name: idx_usconsent_clscope; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_usconsent_clscope ON public.user_consent_client_scope USING btree (user_consent_id);


--
-- Name: idx_user_attribute; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_user_attribute ON public.user_attribute USING btree (user_id);


--
-- Name: idx_user_attribute_name; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_user_attribute_name ON public.user_attribute USING btree (name, value);


--
-- Name: idx_user_consent; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_user_consent ON public.user_consent USING btree (user_id);


--
-- Name: idx_user_credential; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_user_credential ON public.credential USING btree (user_id);


--
-- Name: idx_user_email; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_user_email ON public.user_entity USING btree (email);


--
-- Name: idx_user_group_mapping; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_user_group_mapping ON public.user_group_membership USING btree (user_id);


--
-- Name: idx_user_reqactions; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_user_reqactions ON public.user_required_action USING btree (user_id);


--
-- Name: idx_user_role_mapping; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_user_role_mapping ON public.user_role_mapping USING btree (user_id);


--
-- Name: idx_user_service_account; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_user_service_account ON public.user_entity USING btree (realm_id, service_account_client_link);


--
-- Name: idx_usr_fed_map_fed_prv; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_usr_fed_map_fed_prv ON public.user_federation_mapper USING btree (federation_provider_id);


--
-- Name: idx_usr_fed_map_realm; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_usr_fed_map_realm ON public.user_federation_mapper USING btree (realm_id);


--
-- Name: idx_usr_fed_prv_realm; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_usr_fed_prv_realm ON public.user_federation_provider USING btree (realm_id);


--
-- Name: idx_web_orig_client; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX idx_web_orig_client ON public.web_origins USING btree (client_id);


--
-- Name: user_attr_long_values; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX user_attr_long_values ON public.user_attribute USING btree (long_value_hash, name);


--
-- Name: user_attr_long_values_lower_case; Type: INDEX; Schema: public; Owner: vermeg
--

CREATE INDEX user_attr_long_values_lower_case ON public.user_attribute USING btree (long_value_hash_lower_case, name);


--
-- Name: client_session_auth_status auth_status_constraint; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.client_session_auth_status
    ADD CONSTRAINT auth_status_constraint FOREIGN KEY (client_session) REFERENCES public.client_session(id);


--
-- Name: identity_provider fk2b4ebc52ae5c3b34; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.identity_provider
    ADD CONSTRAINT fk2b4ebc52ae5c3b34 FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: client_attributes fk3c47c64beacca966; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.client_attributes
    ADD CONSTRAINT fk3c47c64beacca966 FOREIGN KEY (client_id) REFERENCES public.client(id);


--
-- Name: federated_identity fk404288b92ef007a6; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.federated_identity
    ADD CONSTRAINT fk404288b92ef007a6 FOREIGN KEY (user_id) REFERENCES public.user_entity(id);


--
-- Name: client_node_registrations fk4129723ba992f594; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.client_node_registrations
    ADD CONSTRAINT fk4129723ba992f594 FOREIGN KEY (client_id) REFERENCES public.client(id);


--
-- Name: client_session_note fk5edfb00ff51c2736; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.client_session_note
    ADD CONSTRAINT fk5edfb00ff51c2736 FOREIGN KEY (client_session) REFERENCES public.client_session(id);


--
-- Name: user_session_note fk5edfb00ff51d3472; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.user_session_note
    ADD CONSTRAINT fk5edfb00ff51d3472 FOREIGN KEY (user_session) REFERENCES public.user_session(id);


--
-- Name: client_session_role fk_11b7sgqw18i532811v7o2dv76; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.client_session_role
    ADD CONSTRAINT fk_11b7sgqw18i532811v7o2dv76 FOREIGN KEY (client_session) REFERENCES public.client_session(id);


--
-- Name: redirect_uris fk_1burs8pb4ouj97h5wuppahv9f; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.redirect_uris
    ADD CONSTRAINT fk_1burs8pb4ouj97h5wuppahv9f FOREIGN KEY (client_id) REFERENCES public.client(id);


--
-- Name: user_federation_provider fk_1fj32f6ptolw2qy60cd8n01e8; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.user_federation_provider
    ADD CONSTRAINT fk_1fj32f6ptolw2qy60cd8n01e8 FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: client_session_prot_mapper fk_33a8sgqw18i532811v7o2dk89; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.client_session_prot_mapper
    ADD CONSTRAINT fk_33a8sgqw18i532811v7o2dk89 FOREIGN KEY (client_session) REFERENCES public.client_session(id);


--
-- Name: realm_required_credential fk_5hg65lybevavkqfki3kponh9v; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.realm_required_credential
    ADD CONSTRAINT fk_5hg65lybevavkqfki3kponh9v FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: resource_attribute fk_5hrm2vlf9ql5fu022kqepovbr; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.resource_attribute
    ADD CONSTRAINT fk_5hrm2vlf9ql5fu022kqepovbr FOREIGN KEY (resource_id) REFERENCES public.resource_server_resource(id);


--
-- Name: user_attribute fk_5hrm2vlf9ql5fu043kqepovbr; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.user_attribute
    ADD CONSTRAINT fk_5hrm2vlf9ql5fu043kqepovbr FOREIGN KEY (user_id) REFERENCES public.user_entity(id);


--
-- Name: user_required_action fk_6qj3w1jw9cvafhe19bwsiuvmd; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.user_required_action
    ADD CONSTRAINT fk_6qj3w1jw9cvafhe19bwsiuvmd FOREIGN KEY (user_id) REFERENCES public.user_entity(id);


--
-- Name: keycloak_role fk_6vyqfe4cn4wlq8r6kt5vdsj5c; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.keycloak_role
    ADD CONSTRAINT fk_6vyqfe4cn4wlq8r6kt5vdsj5c FOREIGN KEY (realm) REFERENCES public.realm(id);


--
-- Name: realm_smtp_config fk_70ej8xdxgxd0b9hh6180irr0o; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.realm_smtp_config
    ADD CONSTRAINT fk_70ej8xdxgxd0b9hh6180irr0o FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: realm_attribute fk_8shxd6l3e9atqukacxgpffptw; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.realm_attribute
    ADD CONSTRAINT fk_8shxd6l3e9atqukacxgpffptw FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: composite_role fk_a63wvekftu8jo1pnj81e7mce2; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.composite_role
    ADD CONSTRAINT fk_a63wvekftu8jo1pnj81e7mce2 FOREIGN KEY (composite) REFERENCES public.keycloak_role(id);


--
-- Name: authentication_execution fk_auth_exec_flow; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.authentication_execution
    ADD CONSTRAINT fk_auth_exec_flow FOREIGN KEY (flow_id) REFERENCES public.authentication_flow(id);


--
-- Name: authentication_execution fk_auth_exec_realm; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.authentication_execution
    ADD CONSTRAINT fk_auth_exec_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: authentication_flow fk_auth_flow_realm; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.authentication_flow
    ADD CONSTRAINT fk_auth_flow_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: authenticator_config fk_auth_realm; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.authenticator_config
    ADD CONSTRAINT fk_auth_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: client_session fk_b4ao2vcvat6ukau74wbwtfqo1; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.client_session
    ADD CONSTRAINT fk_b4ao2vcvat6ukau74wbwtfqo1 FOREIGN KEY (session_id) REFERENCES public.user_session(id);


--
-- Name: user_role_mapping fk_c4fqv34p1mbylloxang7b1q3l; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.user_role_mapping
    ADD CONSTRAINT fk_c4fqv34p1mbylloxang7b1q3l FOREIGN KEY (user_id) REFERENCES public.user_entity(id);


--
-- Name: client_scope_attributes fk_cl_scope_attr_scope; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.client_scope_attributes
    ADD CONSTRAINT fk_cl_scope_attr_scope FOREIGN KEY (scope_id) REFERENCES public.client_scope(id);


--
-- Name: client_scope_role_mapping fk_cl_scope_rm_scope; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.client_scope_role_mapping
    ADD CONSTRAINT fk_cl_scope_rm_scope FOREIGN KEY (scope_id) REFERENCES public.client_scope(id);


--
-- Name: client_user_session_note fk_cl_usr_ses_note; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.client_user_session_note
    ADD CONSTRAINT fk_cl_usr_ses_note FOREIGN KEY (client_session) REFERENCES public.client_session(id);


--
-- Name: protocol_mapper fk_cli_scope_mapper; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.protocol_mapper
    ADD CONSTRAINT fk_cli_scope_mapper FOREIGN KEY (client_scope_id) REFERENCES public.client_scope(id);


--
-- Name: client_initial_access fk_client_init_acc_realm; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.client_initial_access
    ADD CONSTRAINT fk_client_init_acc_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: component_config fk_component_config; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.component_config
    ADD CONSTRAINT fk_component_config FOREIGN KEY (component_id) REFERENCES public.component(id);


--
-- Name: component fk_component_realm; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.component
    ADD CONSTRAINT fk_component_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: realm_default_groups fk_def_groups_realm; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.realm_default_groups
    ADD CONSTRAINT fk_def_groups_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: user_federation_mapper_config fk_fedmapper_cfg; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.user_federation_mapper_config
    ADD CONSTRAINT fk_fedmapper_cfg FOREIGN KEY (user_federation_mapper_id) REFERENCES public.user_federation_mapper(id);


--
-- Name: user_federation_mapper fk_fedmapperpm_fedprv; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.user_federation_mapper
    ADD CONSTRAINT fk_fedmapperpm_fedprv FOREIGN KEY (federation_provider_id) REFERENCES public.user_federation_provider(id);


--
-- Name: user_federation_mapper fk_fedmapperpm_realm; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.user_federation_mapper
    ADD CONSTRAINT fk_fedmapperpm_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: associated_policy fk_frsr5s213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.associated_policy
    ADD CONSTRAINT fk_frsr5s213xcx4wnkog82ssrfy FOREIGN KEY (associated_policy_id) REFERENCES public.resource_server_policy(id);


--
-- Name: scope_policy fk_frsrasp13xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.scope_policy
    ADD CONSTRAINT fk_frsrasp13xcx4wnkog82ssrfy FOREIGN KEY (policy_id) REFERENCES public.resource_server_policy(id);


--
-- Name: resource_server_perm_ticket fk_frsrho213xcx4wnkog82sspmt; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.resource_server_perm_ticket
    ADD CONSTRAINT fk_frsrho213xcx4wnkog82sspmt FOREIGN KEY (resource_server_id) REFERENCES public.resource_server(id);


--
-- Name: resource_server_resource fk_frsrho213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.resource_server_resource
    ADD CONSTRAINT fk_frsrho213xcx4wnkog82ssrfy FOREIGN KEY (resource_server_id) REFERENCES public.resource_server(id);


--
-- Name: resource_server_perm_ticket fk_frsrho213xcx4wnkog83sspmt; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.resource_server_perm_ticket
    ADD CONSTRAINT fk_frsrho213xcx4wnkog83sspmt FOREIGN KEY (resource_id) REFERENCES public.resource_server_resource(id);


--
-- Name: resource_server_perm_ticket fk_frsrho213xcx4wnkog84sspmt; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.resource_server_perm_ticket
    ADD CONSTRAINT fk_frsrho213xcx4wnkog84sspmt FOREIGN KEY (scope_id) REFERENCES public.resource_server_scope(id);


--
-- Name: associated_policy fk_frsrpas14xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.associated_policy
    ADD CONSTRAINT fk_frsrpas14xcx4wnkog82ssrfy FOREIGN KEY (policy_id) REFERENCES public.resource_server_policy(id);


--
-- Name: scope_policy fk_frsrpass3xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.scope_policy
    ADD CONSTRAINT fk_frsrpass3xcx4wnkog82ssrfy FOREIGN KEY (scope_id) REFERENCES public.resource_server_scope(id);


--
-- Name: resource_server_perm_ticket fk_frsrpo2128cx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.resource_server_perm_ticket
    ADD CONSTRAINT fk_frsrpo2128cx4wnkog82ssrfy FOREIGN KEY (policy_id) REFERENCES public.resource_server_policy(id);


--
-- Name: resource_server_policy fk_frsrpo213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.resource_server_policy
    ADD CONSTRAINT fk_frsrpo213xcx4wnkog82ssrfy FOREIGN KEY (resource_server_id) REFERENCES public.resource_server(id);


--
-- Name: resource_scope fk_frsrpos13xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.resource_scope
    ADD CONSTRAINT fk_frsrpos13xcx4wnkog82ssrfy FOREIGN KEY (resource_id) REFERENCES public.resource_server_resource(id);


--
-- Name: resource_policy fk_frsrpos53xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.resource_policy
    ADD CONSTRAINT fk_frsrpos53xcx4wnkog82ssrfy FOREIGN KEY (resource_id) REFERENCES public.resource_server_resource(id);


--
-- Name: resource_policy fk_frsrpp213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.resource_policy
    ADD CONSTRAINT fk_frsrpp213xcx4wnkog82ssrfy FOREIGN KEY (policy_id) REFERENCES public.resource_server_policy(id);


--
-- Name: resource_scope fk_frsrps213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.resource_scope
    ADD CONSTRAINT fk_frsrps213xcx4wnkog82ssrfy FOREIGN KEY (scope_id) REFERENCES public.resource_server_scope(id);


--
-- Name: resource_server_scope fk_frsrso213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.resource_server_scope
    ADD CONSTRAINT fk_frsrso213xcx4wnkog82ssrfy FOREIGN KEY (resource_server_id) REFERENCES public.resource_server(id);


--
-- Name: composite_role fk_gr7thllb9lu8q4vqa4524jjy8; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.composite_role
    ADD CONSTRAINT fk_gr7thllb9lu8q4vqa4524jjy8 FOREIGN KEY (child_role) REFERENCES public.keycloak_role(id);


--
-- Name: user_consent_client_scope fk_grntcsnt_clsc_usc; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.user_consent_client_scope
    ADD CONSTRAINT fk_grntcsnt_clsc_usc FOREIGN KEY (user_consent_id) REFERENCES public.user_consent(id);


--
-- Name: user_consent fk_grntcsnt_user; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.user_consent
    ADD CONSTRAINT fk_grntcsnt_user FOREIGN KEY (user_id) REFERENCES public.user_entity(id);


--
-- Name: group_attribute fk_group_attribute_group; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.group_attribute
    ADD CONSTRAINT fk_group_attribute_group FOREIGN KEY (group_id) REFERENCES public.keycloak_group(id);


--
-- Name: group_role_mapping fk_group_role_group; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.group_role_mapping
    ADD CONSTRAINT fk_group_role_group FOREIGN KEY (group_id) REFERENCES public.keycloak_group(id);


--
-- Name: realm_enabled_event_types fk_h846o4h0w8epx5nwedrf5y69j; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.realm_enabled_event_types
    ADD CONSTRAINT fk_h846o4h0w8epx5nwedrf5y69j FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: realm_events_listeners fk_h846o4h0w8epx5nxev9f5y69j; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.realm_events_listeners
    ADD CONSTRAINT fk_h846o4h0w8epx5nxev9f5y69j FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: identity_provider_mapper fk_idpm_realm; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.identity_provider_mapper
    ADD CONSTRAINT fk_idpm_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: idp_mapper_config fk_idpmconfig; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.idp_mapper_config
    ADD CONSTRAINT fk_idpmconfig FOREIGN KEY (idp_mapper_id) REFERENCES public.identity_provider_mapper(id);


--
-- Name: web_origins fk_lojpho213xcx4wnkog82ssrfy; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.web_origins
    ADD CONSTRAINT fk_lojpho213xcx4wnkog82ssrfy FOREIGN KEY (client_id) REFERENCES public.client(id);


--
-- Name: scope_mapping fk_ouse064plmlr732lxjcn1q5f1; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.scope_mapping
    ADD CONSTRAINT fk_ouse064plmlr732lxjcn1q5f1 FOREIGN KEY (client_id) REFERENCES public.client(id);


--
-- Name: protocol_mapper fk_pcm_realm; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.protocol_mapper
    ADD CONSTRAINT fk_pcm_realm FOREIGN KEY (client_id) REFERENCES public.client(id);


--
-- Name: credential fk_pfyr0glasqyl0dei3kl69r6v0; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.credential
    ADD CONSTRAINT fk_pfyr0glasqyl0dei3kl69r6v0 FOREIGN KEY (user_id) REFERENCES public.user_entity(id);


--
-- Name: protocol_mapper_config fk_pmconfig; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.protocol_mapper_config
    ADD CONSTRAINT fk_pmconfig FOREIGN KEY (protocol_mapper_id) REFERENCES public.protocol_mapper(id);


--
-- Name: default_client_scope fk_r_def_cli_scope_realm; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.default_client_scope
    ADD CONSTRAINT fk_r_def_cli_scope_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: required_action_provider fk_req_act_realm; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.required_action_provider
    ADD CONSTRAINT fk_req_act_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: resource_uris fk_resource_server_uris; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.resource_uris
    ADD CONSTRAINT fk_resource_server_uris FOREIGN KEY (resource_id) REFERENCES public.resource_server_resource(id);


--
-- Name: role_attribute fk_role_attribute_id; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.role_attribute
    ADD CONSTRAINT fk_role_attribute_id FOREIGN KEY (role_id) REFERENCES public.keycloak_role(id);


--
-- Name: realm_supported_locales fk_supported_locales_realm; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.realm_supported_locales
    ADD CONSTRAINT fk_supported_locales_realm FOREIGN KEY (realm_id) REFERENCES public.realm(id);


--
-- Name: user_federation_config fk_t13hpu1j94r2ebpekr39x5eu5; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.user_federation_config
    ADD CONSTRAINT fk_t13hpu1j94r2ebpekr39x5eu5 FOREIGN KEY (user_federation_provider_id) REFERENCES public.user_federation_provider(id);


--
-- Name: user_group_membership fk_user_group_user; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.user_group_membership
    ADD CONSTRAINT fk_user_group_user FOREIGN KEY (user_id) REFERENCES public.user_entity(id);


--
-- Name: policy_config fkdc34197cf864c4e43; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.policy_config
    ADD CONSTRAINT fkdc34197cf864c4e43 FOREIGN KEY (policy_id) REFERENCES public.resource_server_policy(id);


--
-- Name: identity_provider_config fkdc4897cf864c4e43; Type: FK CONSTRAINT; Schema: public; Owner: vermeg
--

ALTER TABLE ONLY public.identity_provider_config
    ADD CONSTRAINT fkdc4897cf864c4e43 FOREIGN KEY (identity_provider_id) REFERENCES public.identity_provider(internal_id);


--
-- PostgreSQL database dump complete
--

\unrestrict wmwExmqZ5Pm8WOAzgjl3DDu5YdRl8MhGFZtxYdCj5d6j3ypllC7U86icxSbtk3W

