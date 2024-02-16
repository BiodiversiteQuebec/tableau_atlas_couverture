#-------------------------------------------------------------------------------
#-- Script to query from Atlas the spatial taxa and obs counts
#--
#-- 2023-09-05
#-- Victor Cameron
#-------------------------------------------------------------------------------
get_spatial_counts <- function() {
  obs_count_req <- db_call_function("rpc/obs_map", schema="atlas_api", 
    region_type = "hex",
    zoom = 5, # 100km hex
    x_min = -106.47949218750001,
    y_min = 43.16512263158296,
    x_max = -44.0771484375,
    y_max = 63.7630651860291,
    taxa_keys = NULL,
    taxa_group_key = 19, # all species
    min_year = 0,
    max_year = 9999)
  obs_count_qc <- obs_count_req$features[[1]] |> tibble::as_tibble()
  # Remove 'properties.' from column names
  names(obs_count_qc) <- gsub("properties\\.", "", names(obs_count_qc))
  # Select columns
  obs_count_qc <- obs_count_qc %>% select(fid, count_obs, count_species)
  # Get hexagons
  hex <- get_regions(select="fid, geom", type="hex", scale=100) 
  # Join 
  spatial_cover <- left_join(hex, obs_count_qc, by = c("fid" = "fid"))
  # Reproject to CRS 4326
  st_crs(spatial_cover) <- 4326

  return(spatial_cover)
}
