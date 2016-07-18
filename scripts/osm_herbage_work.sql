
-- landuse forest
-- natural wood
-- leaf_type=*
-- leaf_cycle=*

-- SELECT tags->'height' as height, count(*)
-- FROM planet_osm_polygon WHERE tags ? 'height'
-- GROUP BY tags->'height' ORDER BY tags->'height' DESC;

SELECT count(*) FROM planet_osm_polygon

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

SELECT count(*) FROM planet_osm_polygon p WHERE p.natural IS NOT NULL;
SELECT count(*) FROM planet_osm_polygon WHERE landuse IS NOT NULL;
SELECT count(*) FROM planet_osm_polygon WHERE wood IS NOT NULL;
SELECT count(*) FROM planet_osm_polygon WHERE landuse = 'forest';
SELECT count(*) FROM planet_osm_polygon WHERE defined(tags, 'leaf_type');
SELECT count(*) FROM planet_osm_polygon WHERE defined(tags, 'leaf_cycle');
SELECT count(*) FROM planet_osm_polygon WHERE (tags -> 'landcover') = 'trees';
SELECT count(*) FROM planet_osm_polygon p WHERE p.natural = 'wood';
SELECT count(*) FROM planet_osm_polygon p WHERE p.natural = 'forest';
SELECT count(*) FROM planet_osm_polygon p WHERE p.natural = 'woodland';
SELECT count(*) FROM planet_osm_polygon p WHERE p.natural = 'trees';
SELECT count(*) FROM planet_osm_polygon p WHERE p.natural = 'tree';


SELECT key, count(*) FROM
(SELECT (each(tags)).key FROM planet_osm_polygon where landuse = 'forest') AS stat
GROUP BY key
ORDER BY count DESC, key
LIMIT 20;

SELECT count(*) FROM planet_osm_polygon p WHERE
  p.wood IS NOT NULL OR
  p.natural = 'wood' OR
  p.landuse = 'forest';

SELECT p.natural, count(*) FROM planet_osm_polygon p
WHERE p.natural IS NOT NULL
GROUP BY p.natural
ORDER BY count DESC, p.natural;


SELECT p.landuse, count(*) FROM planet_osm_polygon p
WHERE p.landuse = 'forest'
GROUP BY p.landuse
ORDER BY count DESC, p.landuse;


SELECT key, count(*) FROM (
  SELECT (each(tags)).key FROM
    planet_osm_polygon p WHERE
  p.landuse = 'forest'
) AS stat
GROUP BY key
ORDER BY count DESC, key
LIMIT 20;


SELECT count(*) FROM (
  SELECT * FROM planet_osm_polygon p WHERE
  wood IS NOT NULL OR
  p.natural = 'wood' OR
  p.natural = 'forest' OR
  p.natural = 'woodland' OR
  p.natural = 'trees' OR
  p.natural = 'tree' OR
  landuse = 'forest' OR
  (tags -> 'landcover') = 'trees'
  INTERSECT
  SELECT * FROM planet_osm_polygon p WHERE
  defined(tags, 'leaf_type') OR
  defined(tags, 'leaf_cycle')
) AS stat;

SELECT
  osm_id,
  tags->'leaf_type' AS leaf_type,
  tags->'leaf_cycle' AS leaf_cycle
FROM planet_osm_polygon p WHERE
  p.wood IS NOT NULL OR
  defined(tags, 'leaf_type');

SELECT * FROM herbage WHERE height > 0;


DROP TABLE IF EXISTS wood;
CREATE TABLE wood AS SELECT
	osm_id,
	name,
	way,
	CASE WHEN tags->'height' ~ E'^([0-9.]+)$' THEN
	    CAST (tags->'height' AS NUMERIC)
	ELSE
	    NULL
	END AS height
FROM planet_osm_polygon p WHERE
    wood IS NOT NULL;
ALTER TABLE wood ADD PRIMARY KEY (osm_id);
CREATE INDEX ON wood USING GIST (way);

DROP TABLE IF EXISTS forest;
CREATE TABLE forest AS SELECT
	osm_id,
	name,
	way,
	CASE WHEN tags->'height' ~ E'^([0-9.]+)$' THEN
	    CAST (tags->'height' AS NUMERIC)
	ELSE
	    NULL
	END AS height
FROM planet_osm_polygon p WHERE
    landuse = 'forest';
ALTER TABLE forest ADD PRIMARY KEY (osm_id);
CREATE INDEX ON forest USING GIST (way);

DROP TABLE IF EXISTS landcover;
CREATE TABLE landcover AS SELECT
	osm_id,
	name,
	way,
	CASE WHEN tags->'height' ~ E'^([0-9.]+)$' THEN
	    CAST (tags->'height' AS NUMERIC)
	ELSE
	    NULL
	END AS height
FROM planet_osm_polygon p WHERE
    (tags -> 'landcover') = 'trees';
ALTER TABLE landcover ADD PRIMARY KEY (osm_id);
CREATE INDEX ON landcover USING GIST (way);

DROP TABLE IF EXISTS leaftype;
CREATE TABLE leaftype AS SELECT
	osm_id,
	name,
	way,
	CASE WHEN tags->'height' ~ E'^([0-9.]+)$' THEN
	    CAST (tags->'height' AS NUMERIC)
	ELSE
	    NULL
	END AS height
FROM planet_osm_polygon p WHERE
    defined(tags, 'leaf_type');
ALTER TABLE leaftype ADD PRIMARY KEY (osm_id);
CREATE INDEX ON leaftype USING GIST (way);

DROP TABLE IF EXISTS leafcycle;
CREATE TABLE leafcycle AS SELECT
	osm_id,
	name,
	way,
	CASE WHEN tags->'height' ~ E'^([0-9.]+)$' THEN
	    CAST (tags->'height' AS NUMERIC)
	ELSE
	    NULL
	END AS height
FROM planet_osm_polygon p WHERE
    defined(tags, 'leaf_cycle');
ALTER TABLE leafcycle ADD PRIMARY KEY (osm_id);
CREATE INDEX ON leafcycle USING GIST (way);

--natural
DROP TABLE IF EXISTS wood1;
CREATE TABLE wood1 AS SELECT
	osm_id,
	name,
	way,
	CASE WHEN tags->'height' ~ E'^([0-9.]+)$' THEN
	    CAST (tags->'height' AS NUMERIC)
	ELSE
	    NULL
	END AS height
FROM planet_osm_polygon p WHERE
    p.natural = 'wood';
ALTER TABLE wood1 ADD PRIMARY KEY (osm_id);
CREATE INDEX ON wood1 USING GIST (way);

DROP TABLE IF EXISTS forest1;
CREATE TABLE forest1 AS SELECT
	osm_id,
	name,
	way,
	CASE WHEN tags->'height' ~ E'^([0-9.]+)$' THEN
	    CAST (tags->'height' AS NUMERIC)
	ELSE
	    NULL
	END AS height
FROM planet_osm_polygon p WHERE
    p.natural = 'forest';
ALTER TABLE forest1 ADD PRIMARY KEY (osm_id);
CREATE INDEX ON forest1 USING GIST (way);

DROP TABLE IF EXISTS woodland;
CREATE TABLE woodland AS SELECT
	osm_id,
	name,
	way,
	CASE WHEN tags->'height' ~ E'^([0-9.]+)$' THEN
	    CAST (tags->'height' AS NUMERIC)
	ELSE
	    NULL
	END AS height
FROM planet_osm_polygon p WHERE
    p.natural = 'woodland';
ALTER TABLE woodland ADD PRIMARY KEY (osm_id);
CREATE INDEX ON woodland USING GIST (way);

DROP TABLE IF EXISTS trees;
CREATE TABLE trees AS SELECT
	osm_id,
	name,
	way,
	CASE WHEN tags->'height' ~ E'^([0-9.]+)$' THEN
	    CAST (tags->'height' AS NUMERIC)
	ELSE
	    NULL
	END AS height
FROM planet_osm_polygon p WHERE
    p.natural = 'trees';
ALTER TABLE trees ADD PRIMARY KEY (osm_id);
CREATE INDEX ON trees USING GIST (way);

DROP TABLE IF EXISTS tree;
CREATE TABLE tree AS SELECT
	osm_id,
	name,
	way,
	CASE WHEN tags->'height' ~ E'^([0-9.]+)$' THEN
	    CAST (tags->'height' AS NUMERIC)
	ELSE
	    NULL
	END AS height
FROM planet_osm_polygon p WHERE
	p.natural = 'tree';
ALTER TABLE tree ADD PRIMARY KEY (osm_id);
CREATE INDEX ON tree USING GIST (way);
