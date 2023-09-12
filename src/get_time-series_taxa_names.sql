-------------------------------------------------------------------------------
-- SQL script to query from Atlas all taxa names in time_series table
--
-- Only taxa names at the species rank are returned
-- 2023-09-05
-- Victor Cameron
-------------------------------------------------------------------------------

select distinct tobs.scientific_name
from time_series ts
left join taxa_obs tobs on ts.id_taxa_obs = tobs.id
where tobs.rank LIKE 'species'

