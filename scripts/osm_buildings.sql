DROP TABLE IF EXISTS buildings;
CREATE TABLE buildings AS SELECT
	osm_id,
	name,
	way,
	building,
	CASE
	WHEN tags->'height' = '.' THEN
	    NULL
	WHEN tags->'height' ~ E'^([0-9.]+)$' THEN
	    CAST (tags->'height' AS NUMERIC)
	ELSE
	    NULL
	END AS height
	FROM planet_osm_polygon WHERE building IS NOT NULL;

--Feature id (gml:id) is based on primary key column
--http://download.deegree.org/documentation/3.3.16/html/featurestores.html
ALTER TABLE buildings ADD PRIMARY KEY (osm_id);
CREATE INDEX ON buildings USING GIST (way);

