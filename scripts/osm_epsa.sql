
SET enable_seqscan TO off;

-- landuse forest
-- natural wood
-- leaf_type=*
-- leaf_cycle=*

-- SELECT tags->'height' as height, count(*)
-- FROM planet_osm_polygon WHERE tags ? 'height'
-- GROUP BY tags->'height' ORDER BY tags->'height' DESC;

SELECT count(*) FROM planet_osm_polygon
SELECT count(*) FROM planet_osm_polygon where 'landuse' IS NOT NULL;
SELECT count(*) FROM planet_osm_polygon where 'natural' IS NOT NULL;
SELECT count(*) FROM planet_osm_polygon where landuse IS NOT NULL;

SELECT column_name, count(*) as ct FROM (
SELECT column_name FROM information_schema.columns WHERE table_name='planet_osm_polygon') AS stat
GROUP BY column_name
ORDER BY ct DESC, column_name;


SELECT p.natural , count(*) FROM planet_osm_polygon p where p.natural IS NOT NULL
GROUP BY p.natural
ORDER BY count DESC, p.natural ;


SELECT landuse, count(*) FROM planet_osm_polygon
where landuse = 'forest'
GROUP BY landuse
ORDER BY count DESC, landuse;

select count(*) from planet_osm_polygon where wood IS NOT NULL;
select count(*) from planet_osm_polygon where landuse = 'forest';
select count(*) from planet_osm_polygon p where p.natural = 'wood';
select count(*) from planet_osm_polygon p where p.natural = 'forest';
select count(*) from planet_osm_polygon where defined(tags, 'leaf_type');
select count(*) from planet_osm_polygon where defined(tags, 'leaf_cycle');
select count(*) from planet_osm_polygon where (tags -> 'landcover') = 'trees';

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



DROP TABLE IF EXISTS herbage;

CREATE TABLE herbage AS SELECT
	osm_id,
	name,
	way,
	CASE WHEN tags->'height' ~ E'^([0-9.]+)$' THEN
	    CAST (tags->'height' AS NUMERIC)
	ELSE
	    NULL
	END AS height
FROM planet_osm_polygon p WHERE
    wood IS NOT NULL OR
	p.natural = 'wood' OR
	p.natural = 'forest' OR
    p.natural = 'woodland' OR
    p.natural = 'trees' OR
	p.natural = 'tree' OR
	p.natural = 'treerow' OR
    landuse = 'forest' OR
    (tags -> 'landcover') = 'trees' OR
    defined(tags, 'leaf_type') OR
    defined(tags, 'leaf_cycle');

--Feature id (gml:id) is based on primary key column
--http://download.deegree.org/documentation/3.3.16/html/featurestores.html
ALTER TABLE herbage ADD PRIMARY KEY (osm_id);
CREATE INDEX ON herbage USING GIST (way);

SELECT count(*) FROM herbage;

SELECT key, count(*) FROM
(SELECT (each(tags)).key FROM planet_osm_polygon where landuse = 'forest') AS stat
GROUP BY key
ORDER BY count DESC, key
LIMIT 20;

SELECT key, count(*) FROM
(SELECT (each(tags)).key FROM planet_osm_polygon p where p.natural = 'water') AS stat
GROUP BY key
ORDER BY count DESC, key
LIMIT 20;

-- ROADS
highway
