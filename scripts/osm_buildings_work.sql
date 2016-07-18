-- SELECT tags->'height' as height, count(*)
-- FROM planet_osm_polygon WHERE tags ? 'height'
-- GROUP BY tags->'height' ORDER BY tags->'height' DESC;

-- SELECT count(*) FROM buildings where height IS NULL;
-- SELECT count(*) FROM buildings where height IS NOT NULL;
-- SELECT count(*) FROM buildings where height ~ E'[0-9.]';
-- SELECT count(*) FROM buildings where height ~ E'^([0-9.]+)$';
-- SELECT count(*) FROM buildings where height ~ E'[^0-9.]';
-- SELECT count(*) FROM buildings where height ~ E'[\']';
-- SELECT count(*) FROM buildings where height ~ E'[\"]';
-- SELECT count(*) FROM buildings where height ~ E'e[\+]';
-- SELECT count(*) FROM buildings where height ~ E'[m]';
-- SELECT count(*) FROM buildings where height ~ E'[M]';
-- SELECT count(*) FROM buildings where height ~ E'[f]';
-- SELECT count(*) FROM buildings where height ~ E'[\;]';
-- SELECT count(*) FROM buildings where height ~ E'[-\;\"\'mMf]|e[\+]|stories';
-- SELECT count(*) FROM buildings where height ~ E'[-]';
-- SELECT count(*) FROM buildings where height ~ E'stories';

-- SELECT height, count(*) as ct FROM buildings where height ~ E'[0-9.]'
-- GROUP BY height ORDER BY ct DESC;
SELECT height, count(*) as ct FROM buildings where height ~ E'^([0-9.]+)$'
GROUP BY height ORDER BY ct DESC;
-- SELECT height, count(*) as ct FROM buildings where height ~ E'[^0-9.]'
-- GROUP BY height ORDER BY ct DESC;
-- SELECT height, count(*) as ct FROM buildings where height ~ E'[\']'
-- GROUP BY height ORDER BY ct DESC;
-- SELECT height, count(*) as ct FROM buildings where height ~ E'[\"]'
-- GROUP BY height ORDER BY ct DESC;
-- SELECT height, count(*) as ct FROM buildings where height ~ E'[\+]'
-- GROUP BY height ORDER BY ct DESC;
-- SELECT height, count(*) as ct FROM buildings where height ~ E'[m]'
-- GROUP BY height ORDER BY ct DESC;
-- SELECT height, count(*) as ct FROM buildings where height ~ E'[M]'
-- GROUP BY height ORDER BY ct DESC;
-- SELECT height, count(*) as ct FROM buildings where height ~ E'[f]'
-- GROUP BY height ORDER BY ct DESC;
-- SELECT height, count(*) as ct FROM buildings where height ~ E'[\;]'
-- GROUP BY height ORDER BY ct DESC;

-- SELECT osm_id FROM buildings where height ~ E'[^0-9.]'
-- EXCEPT
-- SELECT osm_id FROM buildings where height ~ E'[\;\"\'mMf]|e[\+]';

-- SELECT height FROM buildings WHERE osm_id IN (126293863, 242666977);
-- SELECT height, count(*) as ct FROM buildings where height ~* E'[-]'
-- GROUP BY height ORDER BY ct DESC;
-- SELECT height, count(*) as ct FROM buildings where height ~* E'stories'
-- GROUP BY height ORDER BY ct DESC;

--DROP TABLE IF EXISTS buildings;
--
--CREATE TABLE buildings (
--    id bigint NOT NULL,
--    name text,
--    way geometry(Geometry, 3857),
--    building text,
--    height numeric,
--    CONSTRAINT buildings_pkey PRIMARY KEY (id)
--);
--CREATE INDEX ON buildings USING GIST (way);
--
--WITH upd AS (SELECT
--	osm_id AS id,
--	name,
--	way,
--	building,
--	CASE WHEN tags->'height' ~ E'^([0-9.]+)$' THEN
--	    CAST (tags->'height' AS NUMERIC)
--	ELSE
--	    NULL
--	END AS height
--	FROM planet_osm_polygon WHERE building IS NOT NULL)
--INSERT INTO buildings SELECT * FROM upd;

-- DROP VIEW IF EXISTS buildings0 CASCADE;
--
--CREATE VIEW buildings0 AS SELECT
--	osm_id,
--	name,
--	way,
--	building,
--	CASE WHEN tags->'height' ~ E'^([0-9.]+)$' THEN
--	    CAST (tags->'height' AS NUMERIC)
--	ELSE
--	    NULL
--	END AS height
--	FROM planet_osm_polygon WHERE building IS NOT NULL;


--DROP TABLE IF EXISTS buildings;
--DROP VIEW IF EXISTS goodh CASCADE;
--DROP VIEW IF EXISTS buildings0 CASCADE;
--
--CREATE VIEW buildings0 AS SELECT
--	osm_id,
--	name,
--	way,
--	building,
--	tags->'height' AS height
--	FROM planet_osm_polygon WHERE building IS NOT NULL;
--
--CREATE VIEW goodh AS SELECT
--    osm_id,
--    CAST (height AS NUMERIC)
--    FROM buildings0 where height ~ E'^([0-9.]+)$';
--
--CREATE TABLE buildings AS SELECT
--	p.osm_id AS id,
--	p.name AS name,
--	p.way AS way,
--	p.building AS type,
--	h.height AS height
--	FROM buildings0 p LEFT OUTER JOIN goodh h ON p.osm_id = h.osm_id;

--ALTER TABLE buildings ADD PRIMARY KEY (id);
--CREATE INDEX ON buildings USING GIST (way) TABLESPACE main_index;

