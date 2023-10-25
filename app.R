# INSERT Libraries HERE
library(sf)
library(shiny)
library(ggplot2)
library(dplyr)
library(gridExtra)
library(jsonlite)
library(viridis)
library(ratlas)
source("src/cover_taxonomy.r")


##########################
##### User interface #####
##########################
ui <- fluidPage(

    tags$head(
        # Note the wrapping of the string in HTML()
        tags$style(HTML("
        .container-fluid { 
            margin-left: 40px; 
            margin-right: 40px;
        }"))
    ),

    # Title
    titlePanel(tagList(
        img(src = "logo.png", height = 60, width = 50),

        span("Tableau de bord des données d'Atlas")
        ),
            windowTitle = "Atlas - Couverture"
    ),
    tabsetPanel(type="tabs",
        tabPanel("Occurences", icon=icon("map-marker-alt"),
            shiny::fluidRow(
                shiny::column(5,
                    h2("Couverture taxonomique"),
                    shiny::hr(),
                    shiny::plotOutput("cover_taxonomy")
                ),
                shiny::column(5,
                    h2("Jeux de données"),
                    shiny::hr(),
                    shiny::plotOutput("cover_datasets")
                )
            ),
            h2("Couverture spatiale"),
            shiny::hr(),
            shiny::fluidRow(
            shiny::column(10,
                shiny::plotOutput("cover_spatial")
            )
            ),
            h2("Couverture temporelle"),
            shiny::hr(),
            shiny::fluidRow(
            shiny::column(3,
                shiny::plotOutput("cover_temp_accumulated")
            ),
            shiny::column(7,
                shiny::plotOutput("cover_time_depth_hex")
            )
            )
        ),
        tabPanel("Séries temporelles", icon=icon("chart-line"),
            shiny::fluidRow(
                shiny::column(4,
                    h2("Couverture taxonomique"),
                    shiny::hr(),
                    shiny::plotOutput("cover_time_series")
                ),
                shiny::column(3,
                    h2("Diagnostiques"),
                    shiny::hr(),
                    shiny::textOutput("ts_diagnoses_1"),
                    shiny::textOutput("ts_diagnoses_2"),
                    shiny::textOutput("ts_diagnoses_3")
                ),
                shiny::column(4,
                    h2("Couverture spatiale"),
                    shiny::hr(),
                    shiny::plotOutput("cover_spatial_ts")
                )
            ),
            h2("Couverture temporelle"),
            shiny::hr(),
            shiny::fluidRow(
                shiny::column(5,
                    shiny::plotOutput("cover_temporal1_ts")
                ),
                shiny::column(width = 5,
                    shiny::plotOutput("cover_temporal3_ts")
                ) 
            ),
            shiny::fluidRow(
                shiny::column(width = 5, style = "height:800px;",
                    shiny::plotOutput("cover_temporal2_ts", height = "100%")
                )
            )
        ),
        tabPanel("Checklists", icon=icon("list"),
            h2("Couverture taxonomique"),
            shiny::hr(),
            h2("Couverture spatiale"),
            shiny::hr(),
            h2("Couverture temporelle"),
            shiny::hr()
        )

    )
)


###########################
##### Server function #####
###########################
server <- function(input, output, session) {

    #===========================================================================
    # Occurences
    #===========================================================================
    
    # Load the Quebec boundaries data
    quebec_boundaries <- st_read("data/QUEBEC_CR_NIV_01.gpkg")
    # Create the base map with Quebec boundaries
    base_map <- ggplot() +
        geom_sf(data = quebec_boundaries, fill = "transparent", color = "black", size = 0.5)

    # Figure: Taxonomic coverage ------------------------------------------------
    # 1. REQUEST: Get the list of species and synonyms
    taxa_ref <- get_gen("taxa_ref", select=c("scientific_name", "id", "rank")) # get_gen has fewer bugs...
    species_list <- data.frame(scientific_name = unique(taxa_ref$scientific_name))
    write.csv(species_list, "data/species_list.csv", row.names = FALSE)
    rm(species_list)
    
    # 2. Compute cover
    cover <- cover_taxonomy("data/species_list.csv", "scientific_name")
    
    # 3. RENDER PLOT
    output$cover_taxonomy <- renderPlot({
        par(mar=c(10, 4, 4, 2))
        bp <- barplot(cover$cover, names.arg=cover$taxa, 
            col="lightblue", 
            main="Couverture des listes de références", 
            ylab="Couverture (%)", 
            ylim=c(0,100),
            las = 2 # Rotate labels by 90 degrees
        )

    # 4. Get taxa_counts (branch tips using match_taxa [resting on api.taxa] and obs_summary)
    ## Wayyy too long to execute
    #   source("src/cover_taxonomic_metadata.r")
    #   metadata <- cover_taxonomic_metadata("data/species_list.csv", "scientific_name")
    #   taxa_counts <- c()
    #   for (group in metadata$taxa_name) {
    #     match_taxa <- get_function_data("match_taxa", schema="api", taxa_name=group)
    #     obs_summary <- get_function_data("obs_summary", schema="atlas_api", min_year = 1950, max_year = 2020, region_type = "hex", taxa_keys = match_taxa$id_taxa_obs)
    #     taxa_counts <- c(taxa_counts, obs_summary$taxa_count) 
    #   }
    

    # Add nb_atlas on top of the bars
    text(bp, cover$cover, labels = paste0(cover$nb_atlas,"/", cover$nb_checklist), pos = 3, cex = 0.8)
    })


    # Diagnoses ------------------------------------------------
    obs_summary <- get_function_data("obs_summary", schema="atlas_api", min_year = 1950, max_year = 2020, region_type = "hex", taxa_group_key =19)
    obs_count <- obs_summary$obs_count
    obs_summary_qc <- get_function_data("obs_summary", schema="atlas_api", min_year = 1950, max_year = 2020, region_type = "hex", taxa_group_key = 20)
    obs_count_qc <- obs_summary_qc$obs_count
    taxa_count_qc <- obs_summary_qc$taxa_count
    output$occ_diagnoses_1 <- renderPrint({
        cat("Nombre total d'observations: ", obs_count, "\n")
    })
    output$occ_diagnoses_2 <- renderPrint({
        cat("Observations au Québec: ", obs_count_qc, " (", obs_count_qc/obs_count * 100,"%)\n")
    })
    output$occ_diagnoses_3 <- renderPrint({
        cat("Nombre de taxons observés au Québec: ", taxa_count_qc,"\n")
    })


    # Figure: Datasets coverage -----------------------------------------------
    # 1. REQUEST: Get the list of datasets
    datasets <- get_gen("datasets", select = c("id", "open_data", "exhaustive", "direct_obs"))
    datasets_dat <- data.frame(
        variable = c("Total", "Ouverts", "Exhaustifs", "Observations directes"),
        value = c(nrow(datasets),
            sum(datasets$open_data[datasets$open_data], na.rm = TRUE), 
            sum(datasets$exhaustive[datasets$exhaustive], na.rm = TRUE), 
            sum(datasets$direct_obs[datasets$direct_obs], na.rm = TRUE))
    )
    datasets_dat$labels = (paste0(floor(datasets_dat$value/datasets_dat$value[1]*100), "%"))
    # 2. RENDER PLOT
    output$cover_datasets <- renderPlot({
        bp <- barplot(datasets_dat$value, names.arg = datasets_dat$variable, col = "lightblue", border = "black", main = "Couverture des jeux de données", xlab = "Type de données", ylab = "Nombre de jeux de données", ylim = c(0, nrow(datasets)*1.1))
        # Add values on top of the bars
        text(bp, datasets_dat$value, labels = datasets_dat$labels, pos = 3, cex = 0.8)

    })

    # Figure: Spatial coverage ------------------------------------------------
    # 1. REQUEST: Get the spatial cover
    # Get hexagons
    polygons <- get_regions(select="fid, geom", type="hex", scale=100)
    # Get spatial counts
    source("src/get_spatial_counts.r")
    spatial_cover <- get_spatial_counts()

    ## 2. RENDER PLOT
    output$cover_spatial <- renderPlot({
        plot_taxa <- base_map +
            geom_sf(data = spatial_cover[,"count_species"], aes(fill = count_species), alpha = 0.8) +
            scale_fill_viridis(name = "Taxons") +
            theme(panel.background = element_rect(fill='transparent'), text = element_text(size = 15)) +
            ggtitle("Nombre de taxons observés")
        plot_obs <- base_map +
            geom_sf(data = spatial_cover[,"count_obs"], aes(fill = count_obs), alpha = 0.8) +
            # scale_fill_gradient() +
            scale_fill_viridis(name = "Observations", trans = "log10") +
            theme(panel.background = element_rect(fill='transparent'), text = element_text(size = 15)) +
            ggtitle("Nombre d'observations")
        # Arrange the plots side by side
        grid.arrange(plot_obs, plot_taxa, ncol = 2)
    })


    # Figure: Temporal coverage ------------------------------------------------
    # 1. REQUEST: Get the year counts
    year_counts_qc <- get_gen("rpc/get_year_counts", .schema="atlas_api", taxagroupkey=20) # group20 = Qc
    year_counts <- get_gen("rpc/get_year_counts", .schema="atlas_api", taxagroupkey=19) # group19 = all species
    ## Add a column to year_counts for the accumulated_count
    year_counts_qc$accumulated_count <- cumsum(year_counts_qc$count_obs)
    year_counts_qc$accumulated_species <- cumsum(year_counts_qc$count_species)
    year_counts$accumulated_count <- cumsum(year_counts$count_obs)
    year_counts$accumulated_species <- cumsum(year_counts$count_species)

    # 2. RENDER PLOT
    output$cover_temp_accumulated <- renderPlot({
        old_par <- par()
        # Stack the two plots one on top of the other
        par(mfrow=c(2,1))
        # Plot 1
        plot(year_counts$year, year_counts$accumulated_species, 
            type="n", 
            col="#0000FF88", 
            lwd=2, 
            xlim=c(1950, 2020), 
            xlab="Année", 
            ylab="Nombre cumulé de taxons observés",
            main="Cumul des taxons observés")
        # Add polygon for the number of accumulated_count
        polygon(c(year_counts$year, rev(year_counts$year)), c(year_counts$accumulated_species, rep(0, length(year_counts$accumulated_species))), col="#FF000088", border=NA)
        polygon(c(year_counts_qc$year, rev(year_counts_qc$year)), c(year_counts_qc$accumulated_species, rep(0, length(year_counts_qc$accumulated_species))), col="#0000FF88", border=NA)
        # Legend
        legend("topleft", 
            legend=c("Québec", "Total"), 
            col=c("#0000FF88", "#e8204288"), 
            lty=1, 
            lwd=2,
            bty = "n")
        
        # Plot 2
        plot(year_counts$year, year_counts$accumulated_count, 
            type="n", 
            col="#0000FF88", 
            lwd=2, 
            # ylim=c(0, 100000), 
            xlab="Année", 
            ylab="Nombre cumulé d'observations",
            main="Cumul des observations")
        # Add a polygon for the number of accumulated_count
        polygon(c(year_counts$year, rev(year_counts$year)), c(year_counts$accumulated_count, rep(0, length(year_counts$accumulated_count))), col="#FF000088", border=NA)
        polygon(c(year_counts_qc$year, rev(year_counts_qc$year)), c(year_counts_qc$accumulated_count, rep(0, length(year_counts_qc$accumulated_count))), col="#0000FF88", border=NA)
        # Legend
        legend("topleft", 
            legend=c("Québec", "Total"), 
            col=c("#0000FF88", "#e8204288"), 
            lty=1, 
            lwd=2,
            bty = "n")
        par(old_par)
    })

    # Figure: Time depth ------------------------------------------------
    # 1. REQUEST: Get the time_depth
    source("src/get_time_depth.r")
    time_depth <- get_time_depth(polygons)

    # 2. RENDER PLOT
    # plot time_depth with as a continuous variable
    time_depth$time_depth <- as.numeric(time_depth$time_depth)
    time_depth$years_covered <- as.numeric(time_depth$years_covered)

    output$cover_time_depth_hex <- renderPlot({
        # Plot
        plot1 <- base_map +
            geom_sf(data = time_depth[,"time_depth"], aes(fill = time_depth), alpha = 0.8) +
            scale_fill_viridis(name = "Années") +
            theme(panel.background = element_rect(fill='transparent'), text = element_text(size = 15)) +
            ggtitle("Étendue de la période couverte")
        plot2 <- base_map +
            geom_sf(data = time_depth[,"years_covered"], aes(fill = years_covered), alpha = 0.8) +
            scale_fill_viridis(name = "Années") +
            theme(panel.background = element_rect(fill='transparent'), text = element_text(size = 15)) +
            ggtitle("Nombre d'années échantillonnées")
        # Arrange the plots side by side
        grid.arrange(plot1, plot2, ncol = 2)
    })

    #===========================================================================
    # Time series
    #===========================================================================

    # Figure: Time series coverage ------------------------------------------------
    # 1. REQUEST: Get the scientific_names from time_series
    time_series <- get_table_data("time_series", output_geometry = TRUE)
    source("src/get_time-series_taxa_names.r")
    taxa_ts <- get_time_series_taxa_names(time_series, taxa_ref)

    write.csv(taxa_ts, "data/species_list_ts.csv", row.names = FALSE)
    
    # 2. Compute cover
    cover_ts <- cover_taxonomy("data/species_list_ts.csv", "scientific_name")

    # 3. RENDER PLOT
    output$cover_time_series <- renderPlot({
        par(mar=c(10, 4, 4, 2))
        bp <- barplot(cover_ts$cover, names.arg=cover_ts$taxa,
            col="lightblue", 
            main="Couverture des listes de références", 
            ylab="Couverture (%)", 
            ylim=c(0,100),
            las = 2, # Rotate labels by 90 degrees
            )
        # Add nb_atlas on top of the bars
        text(bp, cover_ts$cover, labels = paste0(cover_ts$nb_atlas,"/", cover_ts$nb_checklist), pos = 3, cex = 0.8)
    })

    
        # Diagnoses ------------------------------------------------
        ## transform time_series to quebec_boundaries crs
        time_series <- st_transform(time_series, crs = st_crs(quebec_boundaries))
        ## Subset for Quebec using base_map as a mask
        time_series$within_qc <- as.logical(st_intersects(time_series, quebec_boundaries$geom))
        time_series$within_qc[is.na(time_series$within_qc)] <- FALSE
            
        output$ts_diagnoses_1 <- renderPrint({
            cat("Nombre total de séries temporelles: ", nrow(time_series), "\n")
        })
        output$ts_diagnoses_2 <- renderPrint({
            cat("Séries temporelles au Québec: ", sum(time_series$within_qc), " (", round(mean(time_series$within_qc) * 100, 0),"%)\n")
        })
        output$ts_diagnoses_3 <- renderPrint({
            cat("Nombre de taxons suivis au Québec: ", length(unique(time_series$id_taxa_obs[time_series$within_qc])), " (", floor(length(unique(time_series$id_taxa_obs[time_series$within_qc]))/length(unique(time_series$id_taxa_obs)) * 100), "%)\n")
        })

    # Figure: Time series temporal coverage ------------------------------------
    # 1. REQUEST: Get the spatial cover
    spatial_cover_ts <- time_series |>
        group_by(geometry) |> 
        summarise(ts_count=n(), 
        taxa_count=n_distinct(id_taxa_obs), 
        within_qc=first(within_qc)) |> 
        arrange(desc(taxa_count))

    # 2. RENDER PLOT
    output$cover_spatial_ts <- renderPlot({
        # Plot
        base_map +
            geom_sf(data = spatial_cover_ts[spatial_cover_ts$within_qc,"ts_count"], aes(color = ts_count), size = 5, alpha = 0.7) +
            scale_color_viridis(trans = "log10") +
            theme(panel.background = element_rect(fill='transparent'), text = element_text(size = 15)) +
            ggtitle("Nombre de séries temporelles")
    })

    # Figure: Time series temporal coverage ------------------------------------
    years_ts <- time_series |>
        tidyr::unnest(years) |>
        group_by(id)
        # Plot
        output$cover_temporal1_ts <- renderPlot({
            hist(years_ts$years, breaks = length(unique(years_ts$years)), col = "lightblue", border = "black", main = "Mesures par années", xlab = "Year", ylab = "Frequency")
        })

    # Figure : Time series temporal coverage ------------------------------------
    time_series$min_year <- sapply(time_series$years, min)
    time_series$max_year <- sapply(time_series$years, max)
    time_series$year_interval <- sapply(time_series$years, function(x) max(x)-min(x)+1)
    time_series$year_count <- sapply(time_series$years, length)
    # Order by year_min
    time_series <- time_series[order(time_series$min_year),]
    time_series_qc <- time_series[time_series$within_qc,]

    output$cover_temporal2_ts <- renderPlot({
        old_par <- par()
        # Double figure height
        par(fig = c(0, 1, 0, 1), mar = c(5, 4, 4, 2) + 0.1, new = TRUE)
        # Create an empty plot with the desired x-axis limits
        plot(1:10, xlim = c(1950, 2020), ylim = c(1, nrow(time_series_qc)), 
            type="n", ylab = "",
            xlab = "Année", main = "Étendue de la période couverte par les séries temporelles au Québec",
            yaxt = "n" )

        # Loop through the rows and draw line segments
        for (i in 1:nrow(time_series_qc)) {
        segments(time_series_qc$min_year[i], i, time_series_qc$max_year[i], i, 
                lwd = 0.5, lineend = "round")
        }
        # Add a histogram
        hist_data <- hist(time_series_qc$year_interval, plot = FALSE)
        par(fig = c(0.1, 0.6, 0.5, 1), new = TRUE)
        plot(hist_data, col = "lightblue", border = "black", main = "",
            xlab = "Durée de la série temporelle", ylab = "")
        par(old_par)
    })

    # Figure: Time series temporal coverage ------------------------------------
    output$cover_temporal3_ts <- renderPlot({
        hist(time_series_qc$year_count, col = "lightblue", border = "black", main = "Nombre de mesures par série temporelle", xlab = "Nombre de mesures (années)", ylab = "Frequence")
    })
}


##################################
##### Call shinyApp function #####
##################################
shinyApp(ui = ui, server = server)
