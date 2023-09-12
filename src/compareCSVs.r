################################################################################
# Functions for Taxa Comparison R Script
# Author: Raphael
# Adapted to R by: Victor Cameron
# Date: 01-09-2023
# Description: This script compares species lists from two CSV files and identifies common species.
#              It also provides functions for removing duplicates and calculating coverage rates.
# Usage: Replace the file paths and customize the script as needed.
################################################################################


library(dplyr)

compare_taxa_check <- function(species_list, checklist, col_species, col_check, source) {
  # Initialisation of the returned list
  compared <- character(0)

  # Read the CSV files
  species_list <- read.csv(species_list, stringsAsFactors = FALSE)
  checklist <- read.csv(checklist, stringsAsFactors = FALSE)

  # Comparison loop
  if (tolower(source) == "canadensys") {
    for (i in seq_len(nrow(checklist))) {
      if (checklist[i, "Taxon.Rank"] == 'species') {
        check <- checklist[i, col_check]
        for (specie in species_list[, col_species]) {
          if (tolower(gsub(" ", "", specie)) == tolower(gsub(" ", "", check))) {
            compared <- c(compared, specie)
          }
        }
      }
    }
  } else if (tolower(source) == "gbif") {
    for (i in seq_len(nrow(checklist))) {
      if (checklist[i, "taxonRank"] %in% c('SPECIES', 'VARIETY')) {
        check <- checklist[i, col_check]
        if (is.na(check)) next
        for (specie in species_list[, col_species]) {
          if (tolower(gsub(" ", "", specie)) == tolower(gsub(" ", "", check))) {
            compared <- c(compared, specie)
          }
        }
      }
    }
  } else {
    for (specie in species_list[, col_species]) {
      for (check in checklist[, col_check]) {
        if (tolower(gsub(" ", "", specie)) == tolower(gsub(" ", "", check))) {
          compared <- c(compared, specie)
        }
      }
    }
  }

  return(unique(compared))
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
