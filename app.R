# INSERT Libraries HERE
library(sf)
library(shiny)
library(ggplot2)
library(gridExtra)
library(jsonlite)


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
                h2("Couverture taxonomique"),
                shiny::hr(),
                shiny::fluidRow(
                  shiny::column(5,
                                shiny::plotOutput("cover_taxonomy")
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
                  shiny::column(5,
                                shiny::plotOutput("cover_temp_accumulated_obs")
                  ),
                  shiny::column(5,
                                shiny::plotOutput("cover_temp_year_counts")
                  )
                ),
                shiny::fluidRow(
                  shiny::column(10,
                                shiny::plotOutput("cover_time_depth_hex")
                  )
                )
              ),
              tabPanel("Séries temporelles", icon=icon("chart-line"),
                h2("Couverture taxonomique"),
                shiny::hr(),
                shiny::fluidRow(
                  shiny::column(5,
                                shiny::plotOutput("cover_time_series")
                  )
                ),
                h2("Couverture spatiale"),
                shiny::hr(),
                shiny::fluidRow(
                  shiny::column(10,
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

  # Figure: Taxonomic coverage ------------------------------------------------
  cover <- readRDS("results/cover.rds")
  output$cover_taxonomy <- renderPlot({
      par(mar=c(10, 4, 4, 2))
      barplot(cover$cover, names.arg=cover$taxa, 
          col="lightblue", 
          main="Couverture des listes de références", 
          ylab="Couverture (%)", 
          ylim=c(0,100),
          las = 2 # Rotate labels by 90 degrees
      )
  })

  # Figure: Spatial coverage ------------------------------------------------
  spatial_cover <- read.csv("data/observations_spatial_cover.csv") |>
    sf::st_as_sf(wkt="geom")

  output$cover_spatial <- renderPlot({
      # plot time_depth with as a continuous variable
      spatial_cover$taxa_count <- as.numeric(spatial_cover$taxa_count)
      spatial_cover$obs_count <- as.numeric(spatial_cover$obs_count)

      # Plot
      plot_taxa <- ggplot(spatial_cover[,"taxa_count"], aes(fill = taxa_count)) +
          geom_sf() +
          scale_fill_gradient() +
          theme(panel.background = element_rect(fill='transparent'), text = element_text(size = 15)) +
          ggtitle("Nombre de taxons observés")
      plot_obs <- ggplot(spatial_cover[,"obs_count"], aes(fill = log(obs_count))) +
          geom_sf() +
          scale_fill_gradient() +
          theme(panel.background = element_rect(fill='transparent'), text = element_text(size = 15)) +
          ggtitle("Nombre d'observations")
      # Arrange the plots side by side
      grid.arrange(plot_obs, plot_taxa, ncol = 2)
   })

  # Figure: Temporal coverage ------------------------------------------------
  temporal <- read.csv("data/accumulated_obs.csv")
  output$cover_temp_accumulated_obs <- renderPlot({
    plot(temporal$year_obs, temporal$accumulated_count, 
        type="l", 
        col="#0000FF88", 
        lwd=2, 
        xlim=c(1950, 2020), 
        xlab="Année", 
        ylab="Nombre cumulé de taxons observés",
        main="Cumul des taxons observés")
    # Add polygon for the number of accumulated_count
    polygon(c(temporal$year_obs, rev(temporal$year_obs)), c(temporal$accumulated_count, rep(0, length(temporal$accumulated_count))), col="#0000FF88", border=NA)
    # Add polygon for the number of accumulated_count_quebec and another for accumulated_count_outside
    polygon(c(temporal$year_obs, rev(temporal$year_obs)), c(temporal$accumulated_count_outside, rep(0, length(temporal$accumulated_count_outside))), col="#FF000088", border=NA)
    polygon(c(temporal$year_obs, rev(temporal$year_obs)), c(temporal$accumulated_count_quebec, rep(0, length(temporal$accumulated_count_quebec))), col="#00FF0088", border=NA)
    # Legend
    legend("topleft", 
        legend=c("Québec", "Extérieur", "Total"), 
        col=c("#00FF0088", "#FF000088", "#0000FF88"), 
        lty=1, 
        lwd=2,
        bty = "n")
  })

  # Figure: Temporal coverage ------------------------------------------------
  # Read year_counts json from file
  year_counts <- read.csv("data/year_counts.csv")
  year_counts <- lapply(year_counts, function(x) fromJSON(x))
  year_counts <- do.call("rbind", lapply(year_counts, as.data.frame))

  # # Barplot of the number of observations per year
  # barplot(year_counts$count_obs, names.arg=year_counts$year, 
  #         col="lightblue", 
  #         main="Nombre d'observations par année", 
  #         ylab="Nombre d'observations", 
  #         # ylim=c(0,100000),
  #         las = 2 # Rotate labels by 90 degrees
  # )

  # Add a column to year_counts for the accumulated_count
  year_counts$accumulated_count <- cumsum(year_counts$count_obs)
  year_counts$accumulated_species <- cumsum(year_counts$count_species)

  output$cover_temp_year_counts <- renderPlot({
    # Params
    # par(mfrow = c(1, 2)) 

    # plot
    plot(year_counts$year, year_counts$accumulated_count, 
        type="n", 
        col="#0000FF88", 
        lwd=2, 
        # ylim=c(0, 100000), 
        xlab="Année", 
        ylab="Nombre cumulé d'observations",
        main="Cumul des observations")
    # Add a polygon for the number of accumulated_count
    polygon(c(year_counts$year, rev(year_counts$year)), c(year_counts$accumulated_count, rep(0, length(year_counts$accumulated_count))), col="#0000FF88", border=NA)

    # plot(year_counts$year, year_counts$accumulated_species, 
    #     type="n", 
    #     col="#FF000088", 
    #     lwd=2, 
    #     # ylim=c(0, 100000), 
    #     xlab="Année", 
    #     ylab="Nombre cumulé de taxons observés",
    #     main="Cumul des observations de taxons")
    # # Add a polygon for the number of accumulated_count
    # polygon(c(year_counts$year, rev(year_counts$year)), c(year_counts$accumulated_species, rep(0, length(year_counts$accumulated_species))), col="#FF000088", border=NA)
  })

  # Figure: Time depth ------------------------------------------------
  time_depth <- read.csv("data/time_depth_hex.csv") |>
    sf::st_as_sf(wkt="geom")

  # plot time_depth with as a continuous variable
  time_depth$time_depth <- as.numeric(time_depth$time_depth)
  time_depth$years_covered <- as.numeric(time_depth$years_covered)

  output$cover_time_depth_hex <- renderPlot({
    # Plot
    plot1 <- ggplot(time_depth[,"time_depth"], aes(fill = time_depth)) +
        geom_sf() +
        scale_fill_gradient() +
        theme(panel.background = element_rect(fill='transparent'), text = element_text(size = 15)) +
        ggtitle("Étendue de la période couverte")
    plot2 <- ggplot(time_depth[,"years_covered"], aes(fill = years_covered)) +
        geom_sf() +
        scale_fill_gradient() +
        theme(panel.background = element_rect(fill='transparent'), text = element_text(size = 15)) +
        ggtitle("Nombre d'années couvert")
    # Arrange the plots side by side
    grid.arrange(plot1, plot2, ncol = 2)
  })

  #===========================================================================
  # Time series
  #===========================================================================

  # Figure: Time series coverage ------------------------------------------------
  ts <- readRDS("results/cover_time-series.rds")
  output$cover_time_series <- renderPlot({
    par(mar=c(10, 4, 4, 2))
    barplot(ts$cover, names.arg=ts$taxa,
        col="lightblue", 
        main="Couverture des listes de références", 
        ylab="Couverture (%)", 
        ylim=c(0,100),
        las = 2, # Rotate labels by 90 degrees
        )
   })

  # Figure: Time series temporal coverage ------------------------------------
  spatial_cover_ts <- read.csv("data/time_series_spatial_cover.csv") |>
    sf::st_as_sf(wkt="geom")

  output$cover_spatial_ts <- renderPlot({
      # plot time_depth with as a continuous variable
      spatial_cover_ts$taxa_count <- as.numeric(spatial_cover_ts$taxa_count)
      spatial_cover_ts$ts_count <- as.numeric(spatial_cover_ts$ts_count)

      # Plot
      plot_taxa <- ggplot(spatial_cover_ts[,"taxa_count"], aes(fill = taxa_count)) +
          geom_sf() +
          scale_fill_gradient() +
          theme(panel.background = element_rect(fill='transparent')) +
          ggtitle("Nombre de taxons observés")
      plot_ts <- ggplot(spatial_cover_ts[,"ts_count"], aes(fill = ts_count)) +
          geom_sf() +
          scale_fill_gradient() +
          theme(panel.background = element_rect(fill='transparent')) +
          ggtitle("Nombre de séries temporelles")
      # Arrange the plots side by side
      grid.arrange(plot_ts, plot_taxa, ncol = 2)
   })

  # Figure: Time series temporal coverage ------------------------------------
  years_ts <- read.csv("data/time_series_years.csv") |>
    sf::st_as_sf(wkt="geom")

  output$cover_temporal1_ts <- renderPlot({
    hist(years_ts$year_val, breaks = length(unique(years_ts$year_val)), col = "lightblue", border = "black", main = "Années couvertes", xlab = "Year", ylab = "Frequency")
  })

  # Figure : Time series temporal coverage ------------------------------------
  temporal_ts <- read.csv("data/time_series_temporal_cover.csv") |>
    sf::st_as_sf(wkt="geom")
  temporal_ts$id <- 1:nrow(temporal_ts)
  temporal_ts <- temporal_ts[order(temporal_ts$min_year), ]

  output$cover_temporal2_ts <- renderPlot({
    old_par <- par()
    # Double figure height
    par(fig = c(0, 1, 0, 1), mar = c(5, 4, 4, 2) + 0.1, new = TRUE)
    # Create an empty plot with the desired x-axis limits
    plot(1:10, xlim = c(1950, 2020), ylim = c(1, nrow(temporal_ts)), 
        type="n", ylab = "",
        xlab = "Année", main = "Étendue de la période couverte par les séries temporelles",
        yaxt = "n" )

    # Loop through the rows and draw line segments
    for (i in 1:nrow(temporal_ts)) {
      segments(temporal_ts$min_year[i], i, temporal_ts$max_year[i], i, 
              lwd = 0.5, lineend = "round")
    }
    # Add a histogram
    hist_data <- hist(temporal_ts$year_interval, plot = FALSE)
    par(fig = c(0.1, 0.6, 0.5, 1), new = TRUE)
    plot(hist_data, col = "lightblue", border = "black", main = "",
        xlab = "Durée de la série temporelle", ylab = "")
    par(old_par)
  })

  # Figure: Time series temporal coverage ------------------------------------
  output$cover_temporal3_ts <- renderPlot({
    hist(temporal_ts$year_count, col = "lightblue", border = "black", main = "Nombre de mesures par série temporelle", xlab = "Nombre d'années", ylab = "Frequence")
  })


  summary(temporal_ts$year_count)
}


##################################
##### Call shinyApp function #####
##################################
shinyApp(ui = ui, server = server)
