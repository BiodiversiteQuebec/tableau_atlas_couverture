-------------------------------------------------------------------------------
-- SQL script to query from Atlas the spatial coverage of observations
--
-- 2023-09-05
-- Victor Cameron
-------------------------------------------------------------------------------

with count as (
	select fid, type, 
	count(distinct(id_taxa_obs)) obs_count
	from atlas_api.obs_region_counts
	where type = 'hex'
		and scale = 100
	group by fid, type
)
select 
	obs_count,
	count.fid,
	within_quebec,
	ST_AsText(r.geom) geom
from regions r
left join count on r.fid=count.fid
where scale = 100