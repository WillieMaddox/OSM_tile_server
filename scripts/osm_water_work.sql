
select count(*) from planet_osm_polygon where landuse = 'basin';
select count(*) from planet_osm_polygon where landuse = 'reservoir';
select count(*) from planet_osm_polygon where landuse = 'salt_pond';
select count(*) from planet_osm_polygon where waterway = 'riverbank';
select count(*) from planet_osm_polygon p where p.natural = 'water';
select count(*) from planet_osm_polygon p where p.natural = 'wetland';
select count(*) from planet_osm_polygon p where p.natural = 'bay';
select count(*) from planet_osm_polygon p where p.natural = 'waterway';

DROP TABLE IF EXISTS water;

CREATE TABLE water AS SELECT
	p.osm_id,
	p.name,
	p.way
FROM planet_osm_polygon p WHERE
	landuse = 'basin' OR
	landuse = 'reservoir' OR
	landuse = 'salt_pond' OR
	waterway = 'riverbank' OR
	p.natural = 'water' OR
	p.natural = 'wetland' OR
    p.natural = 'bay' OR
	p.natural = 'pond' OR
	p.natural = 'waterway';

ALTER TABLE water ADD PRIMARY KEY (osm_id);
CREATE INDEX ON water USING GIST (way);

SELECT * FROM water;

SELECT key, count(*) FROM
(SELECT (each(tags)).key FROM planet_osm_polygon p where p.natural = 'water') AS stat
GROUP BY key
ORDER BY count DESC, key
LIMIT 20;

