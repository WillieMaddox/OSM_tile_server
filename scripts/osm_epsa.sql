
DROP TABLE IF EXISTS buildings0;
DROP TABLE IF EXISTS goodh;
DROP TABLE IF EXISTS buildings;

CREATE TABLE buildings0 AS SELECT
	osm_id,
	name,
	way,
	building AS type,
	tags->'height' AS height
	FROM planet_osm_polygon WHERE building IS NOT NULL;

CREATE TABLE goodh AS SELECT
    osm_id,
    CAST (height AS NUMERIC)
    FROM buildings0 where height ~ E'^([0-9.]+)$';

CREATE TABLE buildings AS SELECT
	p.osm_id,
	p.name,
	p.way,
	p.type AS type,
	h.height AS height
	FROM buildings0 p LEFT OUTER JOIN goodh h ON p.osm_id = h.osm_id;

ALTER TABLE buildings ADD PRIMARY KEY (osm_id);

DROP TABLE IF EXISTS goodh;
DROP TABLE IF EXISTS buildings0;

