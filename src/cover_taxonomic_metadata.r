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