#-------------------------------------------------------------------------------
#-- Script to query from Atlas the list of taxa_ref taxons for time_series
#--
#-- 2023-09-05
#-- Victor Cameron
#-------------------------------------------------------------------------------
get_time_series_taxa_names <- function(ts, taxa_ref) {
    for (i in 1:ceiling(length(unique(ts$id_taxa_obs))/200)) {
        ids <- unique(ts$id_taxa_obs)[((i-1)*200+1):min(i*200, length(unique(ts$id_taxa_obs)))]
        # From time_series' id_taxa_obs, get the id_taxa_ref
        res <- get_table_data("taxa_obs_ref_lookup", id_taxa_obs=ids)
        lu <- if (i == 1) res else rbind(lu, res)
    }
    taxa_refs <- unique(lu$id_taxa_ref)
    # From taxa_ref_lookup's id_taxa_ref, get the scientific_name
    taxa_ref_list <- taxa_ref$scientific_name[match(taxa_refs, taxa_ref$id)] |> unique()

    taxa_ts <- data.frame(scientific_name = unique(taxa_ref_list))

    return(taxa_ts)
}