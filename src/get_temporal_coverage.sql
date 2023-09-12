-------------------------------------------------------------------------------
-- SQL script to query from Atlas the temporal coverage
--
-- 2023-09-05
-- Victor Cameron
-------------------------------------------------------------------------------

with count as (
	select fid, type, 
	min(year_obs) first_year,
	max(year_obs) last_year,
	max(year_obs) - min(year_obs) + 1 as time_depth,
	count(distinct(year_obs)) 
	from atlas_api.obs_region_counts
	where type = 'hex'
		and scale = 100
	group by fid, type
)
select 
	count years_covered,
	first_year,
	last_year,
	time_depth,
	count.fid,
	within_quebec,
	ST_AsText(r.geom) geom
from regions r
left join count on r.fid=count.fid
where scale = 100