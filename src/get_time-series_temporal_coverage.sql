-------------------------------------------------------------------------------
-- SQL script to query from Atlas the temporal coverage of time_series
--
-- 2023-09-05
-- Victor Cameron
-------------------------------------------------------------------------------

SELECT
    ST_AsText(geom) as geom,
    MIN(year_val) AS min_year,
    MAX(year_val) AS max_year,
    MAX(year_val) - MIN(year_val) AS year_interval,
    COUNT(year_val) AS year_count,
	id
FROM (
    SELECT geom, unnest(years) AS year_val, id
    FROM time_series
) AS subquery
GROUP BY geom, id;