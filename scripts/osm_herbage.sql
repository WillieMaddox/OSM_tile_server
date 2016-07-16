
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
