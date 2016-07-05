DROP TABLE IF EXISTS buildings;

CREATE TABLE buildings AS SELECT 
	osm_id,
	building AS type,
	name,
	tags->'height' AS height,
	way
	FROM planet_osm_polygon WHERE building IS NOT NULL;

ALTER TABLE buildings ADD PRIMARY KEY (osm_id);