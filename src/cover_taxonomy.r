###############################################################################
# Generates the metadata matrix for the taxonomic coverage using checklists.
#
# 2023-08-30
# Victor Cameron
###############################################################################

# Arguments
cover_taxonomic_metadata <- function(species_list, col_species){
    as.data.frame(do.call(rbind, list(
        list(
            taxa="Araignées",
            taxa_name = "Araignées",
            species_list=species_list,
            checklist="data/checklist_araignées.csv",
            col_species=col_species,
            col_check="NOM_SCI",
            source="other"
        ),
        list(
            taxa="Bryophytes",
            taxa_name = "bryophyta",
            species_list=species_list,
            checklist="data/checklist_bryophytes.csv",
            col_species=col_species,
            col_check="Species",
            source=''
        ),
        list(
            taxa="Insectes",
            taxa_name = "insecta",
            species_list=species_list,
            checklist="data/checklist_insectarium_mtl.csv",
            col_species=col_species,
            col_check="Species",
            source="canadensys"
        ),
        list(
            taxa="Vasculaires",
            taxa_name = "tracheophyta",
            species_list=species_list,
            checklist="data/checklist_vasculaires.csv",
            col_species=col_species,
            col_check="Species",
            source='other'
        ),
        list(
            taxa="Vertébrés",
            taxa_name = "vertebrata",
            species_list=species_list,
            checklist="data/checklist_vertébrés.csv",
            col_species=col_species,
            col_check="Nom_scientifique",
            source='other'
        ),
        list(
            taxa="Odonates",
            taxa_name = "odonates",
            species_list=species_list,
            checklist="data/checklist_odonates.csv",
            col_species=col_species,
            col_check="NOM_SCI",
            source='other'
        ),
        list(
            taxa="Lichen",
            taxa_name = "Lichen",
            species_list=species_list,
            checklist="data/checklist_lichens_hlm.csv",
            col_species=col_species,
            col_check="species",
            source='gbif'
        ),
        list(
            taxa="Bryophytes_htm",
            taxa_name = "bryophytes",
            species_list=species_list,
            checklist="data/checklist_bryophytes_hlm.csv",
            col_species=col_species,
            col_check="species",
            source='gbif'
        ),
        list(
            taxa="Plantes_gbif",
            taxa_name = "plantae",
            species_list=species_list,
            checklist="data/quebec_plantae_checklist_gbif.csv",
            col_species=col_species,
            col_check="species",
            source="gbif"
        ),
        list(
            taxa="Animaux_gbif",
            taxa_name = "animalia",
            species_list=species_list,
            checklist="data/quebec_animalia_checklist_gbif.csv",
            col_species=col_species,
            col_check="species",
            source="gbif"
        ),
        list(
            taxa="Champignons_gbif",
            taxa_name = "fungi",
            species_list=species_list,
            checklist="data/gbif_qcfungi.csv",
            col_species=col_species,
            col_check="species",
            source="gbif"
        )
    )))
}


###############################################################################
# Functions to compute toxonomic cover of Atlas
#
# Input:
#   species_list: List of species names
#
# 2023-08-30
# Victor Cameron
###############################################################################

cover_taxonomy <- function(species_list, col_species) {
    # Get metadata
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
    # saveRDS(cover, "results/cover.rds")
    return(cover)
}


################################################################################
# Functions for Taxa Comparison R Script
# Author: Raphael
# Adapted to R by: Victor Cameron
# Date: 01-09-2023
# Description: This script compares species lists from two CSV files and identifies common species.
#              It also provides functions for removing duplicates and calculating coverage rates.
# Usage: Replace the file paths and customize the script as needed.
################################################################################

compare_taxa_check <- function(species_list, checklist, col_species, col_check, source) {
  # Initialisation of the returned list
  compared <- character(0)

  # Read the CSV files
  obs_list <- read.csv(species_list, stringsAsFactors = FALSE)
  ref_list <- read.csv(checklist, stringsAsFactors = FALSE)

  # Comparison loop
  if (tolower(source) == "canadensys") {
    overlap <- sum(unique(tolower(gsub(" ", "", ref_list[, col_check]))) %in% unique(tolower(gsub(" ", "", obs_list[, col_species]))), na.rm = TRUE)
    # for (i in seq_len(nrow(checklist))) {
    #   if (checklist[i, "Taxon.Rank"] == 'species') {
    #     check <- checklist[i, col_check]
    #     for (specie in species_list[, col_species]) {
    #       if (tolower(gsub(" ", "", specie)) == tolower(gsub(" ", "", check))) {
    #         compared <- c(compared, specie)
    #       }
    #     }
    #   }
    # }
  } else if (tolower(source) == "gbif") {
    overlap <- sum(unique(tolower(gsub(" ", "", ref_list[, col_check]))) %in% unique(tolower(gsub(" ", "", obs_list[, col_species]))), na.rm = TRUE)


    # for (i in seq_len(nrow(checklist))) {
    #   if (checklist[i, "taxonRank"] %in% c('SPECIES', 'VARIETY')) {
    #     check <- checklist[i, col_check]
    #     if (is.na(check)) next
    #     for (specie in species_list[, col_species]) {
    #       if (tolower(gsub(" ", "", specie)) == tolower(gsub(" ", "", check))) {
    #         compared <- c(compared, specie)
    #       }
    #     }
    #   }
    # }
  } else {
    overlap <- sum(unique(tolower(gsub(" ", "", ref_list[, col_check]))) %in% unique(tolower(gsub(" ", "", obs_list[, col_species]))), na.rm = TRUE)
  }


  return(overlap)
}

remove_duplicates <- function(duped_list) {
  cleared_list <- unique(duped_list)
  cleared_list <- cleared_list[!is.na(cleared_list)]
  cleared_list <- sort(cleared_list)
  return(cleared_list)
}

show_coverture <- function(nbr_spec_atlas, nbr_spec_check) {
  covert_rate <- round((nbr_spec_atlas / nbr_spec_check) * 100, 2)
  return(c(nb_atlas = nbr_spec_atlas, nb_checklist = nbr_spec_check, cover = covert_rate))
}