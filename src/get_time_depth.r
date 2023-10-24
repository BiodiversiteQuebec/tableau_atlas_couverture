#-------------------------------------------------------------------------------
#-- Script to query from Atlas the temporal coverage of each hexagon
#--
#-- 2023-09-05
#-- Victor Cameron
#-------------------------------------------------------------------------------à
get_time_depth <- function(polygons) {
	    for (i in 1:ceiling(nrow(polygons)/200)) {
        print(i)
        cover_temp <- get_gen("obs_region_counts", .schema="atlas_api", type="hex", scale=100, select="fid, type, year_obs", fid=polygons$fid[((i-1)*200+1):min(i*200, nrow(polygons))]) |>
            # group by fid, type
            group_by(fid, type) |>
            # get min and max year_obs
            mutate(first_year=min(year_obs), last_year=max(year_obs)) |>
            # get time_depth
            mutate(time_depth=last_year - first_year + 1) |>
            # get number of years covered
            mutate(years_covered=n_distinct(year_obs)) |>
            # Collapse to one row per hexagon
            summarise(first_year=first(first_year), last_year=last(last_year), time_depth=first(time_depth), years_covered=first(years_covered))

        if(i==1) cover <- cover_temp else cover <- rbind(cover, cover_temp)
    }

    cover_res <- polygons |>
        # join with regions
        left_join(cover, by="fid", multiple = "all") 

	return(cover_res)
}
