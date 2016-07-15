CREATE TYPE aor AS (
    geom geometry,
    name text,
);

CREATE TYPE building AS (
    geom geometry,
    name text,
    height numeric,
    subtype text
);

CREATE TYPE herbage AS (
    geom geometry,
    name text,
    height numeric,
    subtype text
);

CREATE TYPE water AS (
    geom geometry,
    name text
);

CREATE TYPE road AS (
    geom geometry,
    name text,
    width numeric
    maxspeed numeric,
);

CREATE TYPE wall AS (
    geom geometry,
    name text,
    height numeric,
    width numeric
);

CREATE TYPE feature AS (
    geom geometry,
    name text,
    height numeric,
    width numeric
    maxspeed numeric,
    subtype text
);

