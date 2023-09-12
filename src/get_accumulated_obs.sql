-------------------------------------------------------------------------------
-- SQL script to query from Atlas the accumulated number of observations per year
--
-- All taxa are included
-- 2023-09-05
-- Victor Cameron
-------------------------------------------------------------------------------

SELECT
    year_obs,
    SUM(CASE WHEN within_quebec is true THEN COUNT(DISTINCT id_taxa_obs) ELSE 0 END) OVER (ORDER BY year_obs) AS accumulated_count_quebec,
    SUM(CASE WHEN within_quebec is not true THEN COUNT(DISTINCT id_taxa_obs) ELSE 0 END) OVER (ORDER BY year_obs) AS accumulated_count_outside,
	SUM(COUNT(DISTINCT id_taxa_obs)) OVER (ORDER BY year_obs) AS accumulated_count
FROM
    observations
GROUP BY
    year_obs, within_quebec
ORDER BY
    year_obs;