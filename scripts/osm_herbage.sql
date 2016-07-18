DROP TABLE IF EXISTS herbage;
CREATE TABLE herbage AS SELECT
  p.osm_id AS osm_id,
  p.name AS name,
  p.way AS way,
  p.tags->'leaf_type' AS leaf_type,
  p.tags->'leaf_cycle' AS leaf_cycle,
  CASE WHEN p.tags->'height' ~ E'^([0-9.]+)$' THEN
    CAST (p.tags->'height' AS NUMERIC)
  ELSE
    NULL
  END AS height
FROM planet_osm_polygon p WHERE
  p.wood IS NOT NULL OR
  p.landuse = 'forest' OR
  p.natural = 'wood' OR
  p.natural = 'forest' OR
  p.natural = 'woodland' OR
  p.natural = 'trees' OR
  p.natural = 'tree' OR
  (p.tags -> 'landcover') = 'trees';
ALTER TABLE herbage ADD PRIMARY KEY (osm_id);
CREATE INDEX ON herbage USING GIST (way);
