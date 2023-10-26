################################################################################
# Functions for Richness Comparison R Script
#
# Author: Victor Cameron
# Date: 02-10-2023
# Description: This script compares taxa richness of checklists and Atlas.
# Usage: Replace the file paths and customize the script as needed.
################################################################################

compare_richness <- function() {
    # 4. Get taxa_counts (branch tips using match_taxa [resting on api.taxa] and obs_summary)
    ## Wayyy too long to execute
    source("src/cover_taxonomy.r")
    metadata <- cover_taxonomic_metadata("data/species_list.csv", "scientific_name")
    taxa_counts <- c()

    for (group in metadata$taxa_name) {
        match_taxa <- get_function_data("match_taxa", schema="api", taxa_name=group)
        n_taxa <- nrow(match_taxa)
        if (n_taxa <= 1) {
            taxa_counts <- c(taxa_counts, n_taxa)
        } else {
            obs_summary <- get_function_data("obs_summary", schema="atlas_api", min_year = 1950, max_year = 2020, region_type = "hex", taxa_keys = match_taxa$id_taxa_obs)
            taxa_counts <- c(taxa_counts, obs_summary$taxa_count)
        }    
    }

    out <- data.frame(
        taxa_group = unlist(metadata$taxa_name), 
        taxa_counts = taxa_counts)
    
    return(out)
}