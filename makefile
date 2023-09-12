# Taxa observed in Atlas
    taxa_obs=data/taxa_obs.csv

# Checklists
	araignees=data/checklist_araignées.csv
	bryophytes_hlm/data/checklist_bryophytes_hlm.csv
	bryophytes=data/checklist_bryophytes.csv
	insectes=data/checklist_insectarium_mtl.csv
	lichens=data/checklist_lichens.csv
	odonates=data/checklist_odonates.csv
	vasculaires=data/checklist_vasculaires.csv
	vertebres=data/checklist_vertébrés.csv
	champignons=data/gbif_qcfundi.csv
	animaux=data/quebec_animalia_checklist_gbif.csv
	plantes=data/quebec_plantae_checklist_gbif.csv

# Taxonomic cover of Atlas

	TAXO_COVER=results/cover.rds
	SRC_TAXO_COVER=src/cover_taxonomy.r	
	TS_COVER=results/cover_time-series.rds
	SRC_TS_COVER=src/cover_time-series_taxonomy.r

# Install dependencies
@Rscript -e "install.packages('shiny'); install.packages('sf'); install.packages('ggplot2'); install.packages('gridExtra'); install.packages('jsonlite')"

# Compute taxonomic cover of Atlas
$(TAXO_COVER): $(SRC_TAXO_COVER) $(araignees) $(bryophytes_hlm) $(bryophytes) $(insectes) $(lichens) $(odonates) $(vasculaires) $(vertebres) $(champignons) $(animaux) $(plantes)
	@Rscript -e "source('$(SRC_TAXO_COVER)')"

# Compute taxonomic cover of time series
$(TS_COVER): $(SRC_TS_COVER) $(araignees) $(bryophytes_hlm) $(bryophytes) $(insectes) $(lichens) $(odonates) $(vasculaires) $(vertebres) $(champignons) $(animaux) $(plantes)
	@Rscript -e "source('$(SRC_TS_COVER)')"

