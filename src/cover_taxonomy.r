###############################################################################
# Function to compute toxonomic cover of Atlas
#
# Input:
#   species_list: List of species names
#
# 2023-08-30
# Victor Cameron
###############################################################################

cover_taxonomy <- function(species_list, col_species) {
    source("src/compareCSVs.r")
    source("src/cover_taxonomic_metadata.r")

    # Arguments
    checklists <- cover_taxonomic_metadata(species_list, col_species)

    # Compute cover
    cover <- list()
    for (i in 1:nrow(checklists)) {
        atlas <- compare_taxa_check(species_list=checklists$species_list[i][[1]],
                                    checklist=checklists$checklist[i][[1]],
                                    col_species=checklists$col_species[i][[1]],
                                    col_check=checklists$col_check[i][[1]],
                                    source=checklists$source[i][[1]])
        
        ref_list <- read.csv(checklists$checklist[i][[1]])[,checklists$col_check[i][[1]]] |>
            remove_duplicates()

        metrics <- show_coverture(atlas, length(ref_list))

        cover[[i]] <- metrics
    }

    cover <- do.call(rbind, cover) |> as.data.frame()
    cover$taxa <- checklists$taxa
    order_vec <- order(cover$cover, decreasing = TRUE)
    cover <- cover[order_vec,]

    # Save results
    saveRDS(cover, "results/cover.rds")
    return(cover)
}
