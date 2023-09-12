-------------------------------------------------------------------------------
-- SQL script to query from Atlas the spatial coverage of time_series
--
-- 2023-09-05
-- Victor Cameron
-------------------------------------------------------------------------------

SELECT p.fid AS polygon_id, COUNT(pnt.id) AS point_count, ST_AsText(p.geom) geom
FROM regions AS p
LEFT JOIN time_series AS pnt
ON ST_Contains(p.geom, pnt.geom)
GROUP BY p.fid;