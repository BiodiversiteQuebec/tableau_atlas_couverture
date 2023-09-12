###############################################################################
# Compute toxonomic cover of Atlas' time-series
#
# 2023-08-30
# Victor Cameron
###############################################################################

source("R/compareCSVs.r")
source("R/cover_taxonomic_metadata.r")

# Arguments
species <- cover_taxonomic_metadata(species_list="csv/time_series_names.csv",
                                    col_species="scientific_name") |> 
            as.data.frame()

# Compute cover
cover <- list()
for (i in 1:nrow(species)) {
    atlas <- compare_taxa_check(species_list=species$species_list[i][[1]],
                                checklist=species$checklist[i][[1]],
                                col_species=species$col_species[i][[1]],
                                col_check=species$col_check[i][[1]],
                                source=species$source[i][[1]])
    
    checklist <- read.csv(species$checklist[i][[1]])[,species$col_check[i][[1]]] |>
        remove_duplicates()

    metrics <- show_coverture(length(atlas), length(checklist))

    cover[[i]] <- metrics
}

cover <- do.call(rbind, cover) |> as.data.frame()
cover$taxa <- species$taxa |> unlist()
order_vec <- order(cover$cover, decreasing = TRUE)
cover <- cover[order_vec,]

# Save results
saveRDS(cover, "results/cover_time-series.rds")
