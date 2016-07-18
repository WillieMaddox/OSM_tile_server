DROP TABLE IF EXISTS roads;
CREATE TABLE roads AS SELECT
	p.osm_id AS osm_id,
	p.name AS name,
	p.highway AS subtype,
	p.way AS way
FROM planet_osm_line p WHERE
	p.highway IS NOT NULL;

ALTER TABLE roads ADD PRIMARY KEY (osm_id);
CREATE INDEX ON roads USING GIST (way);
