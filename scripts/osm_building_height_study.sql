-- SELECT tags->'height' as height, count(*)
-- FROM planet_osm_polygon WHERE tags ? 'height'
-- GROUP BY tags->'height' ORDER BY tags->'height' DESC;

select count(*) from planet_osm_polygon where defined(tags, 'height');

select count(*) from planet_osm_polygon where defined(tags, 'HEIGHT');
select count(*) from planet_osm_polygon where defined(tags, 'height:estimate');
select count(*) from planet_osm_polygon where defined(tags, 'height:feet');
select count(*) from planet_osm_polygon where defined(tags, 'height:meters');
select count(*) from planet_osm_polygon where defined(tags, 'building:height');
select count(*) from planet_osm_polygon where defined(tags, 'building:height:avg');
select count(*) from planet_osm_polygon where (tags -> 'landcover') = 'trees';


-- SELECT count(*) FROM buildings where "height" IS NULL;
-- SELECT count(*) FROM buildings where height IS NOT NULL;
-- SELECT count(*) FROM buildings where height ~ E'[0-9.]';
-- SELECT count(*) FROM buildings where height ~ E'^([0-9.]+)$';
-- SELECT count(*) FROM buildings where height ~ E'[^0-9.]';
-- SELECT count(*) FROM buildings where height ~ E'[\']';
-- SELECT count(*) FROM buildings where height ~ E'[\"]';
-- SELECT count(*) FROM buildings where height ~ E'e[\+]';
-- SELECT count(*) FROM buildings where height ~ E'[m]';
-- SELECT count(*) FROM buildings where height ~ E'[M]';
-- SELECT count(*) FROM buildings where height ~ E'[f]';
-- SELECT count(*) FROM buildings where height ~ E'[\;]';
-- SELECT count(*) FROM buildings where height ~ E'[-\;\"\'mMf]|e[\+]|stories';
-- SELECT count(*) FROM buildings where height ~ E'[-]';
-- SELECT count(*) FROM buildings where height ~ E'stories';

-- SELECT height, count(*) as ct FROM buildings where height ~ E'[0-9.]'
-- GROUP BY height ORDER BY ct DESC;
SELECT height, count(*) as ct FROM buildings where height ~ E'^([0-9.]+)$'
GROUP BY height ORDER BY ct DESC;
-- SELECT height, count(*) as ct FROM buildings where height ~ E'[^0-9.]'
-- GROUP BY height ORDER BY ct DESC;
-- SELECT height, count(*) as ct FROM buildings where height ~ E'[\']'
-- GROUP BY height ORDER BY ct DESC;
-- SELECT height, count(*) as ct FROM buildings where height ~ E'[\"]'
-- GROUP BY height ORDER BY ct DESC;
-- SELECT height, count(*) as ct FROM buildings where height ~ E'[\+]'
-- GROUP BY height ORDER BY ct DESC;
-- SELECT height, count(*) as ct FROM buildings where height ~ E'[m]'
-- GROUP BY height ORDER BY ct DESC;
-- SELECT height, count(*) as ct FROM buildings where height ~ E'[M]'
-- GROUP BY height ORDER BY ct DESC;
-- SELECT height, count(*) as ct FROM buildings where height ~ E'[f]'
-- GROUP BY height ORDER BY ct DESC;
-- SELECT height, count(*) as ct FROM buildings where height ~ E'[\;]'
-- GROUP BY height ORDER BY ct DESC;

-- SELECT osm_id FROM buildings where height ~ E'[^0-9.]'
-- EXCEPT
-- SELECT osm_id FROM buildings where height ~ E'[\;\"\'mMf]|e[\+]';

-- SELECT height FROM buildings WHERE osm_id IN (126293863, 242666977);
-- SELECT height, count(*) as ct FROM buildings where height ~* E'[-]'
-- GROUP BY height ORDER BY ct DESC;
-- SELECT height, count(*) as ct FROM buildings where height ~* E'stories'
-- GROUP BY height ORDER BY ct DESC;

