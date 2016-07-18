DROP TABLE IF EXISTS water;
CREATE TABLE water AS SELECT
	p.osm_id AS osm_id,
	p.name AS name,
	p.way AS way
FROM planet_osm_polygon p WHERE
	p.landuse = 'basin' OR
	p.landuse = 'reservoir' OR
	p.landuse = 'salt_pond' OR
	p.waterway = 'riverbank' OR
	p.natural = 'water' OR
	p.natural = 'wetland' OR
    p.natural = 'bay' OR
	p.natural = 'pond' OR
	p.natural = 'waterway';

ALTER TABLE water ADD PRIMARY KEY (osm_id);
CREATE INDEX ON water USING GIST (way);

