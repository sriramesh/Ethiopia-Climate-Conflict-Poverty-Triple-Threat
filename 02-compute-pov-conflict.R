library(raster)
library(leaflet)
library(rgdal)
library(tidyverse)

basemap <- leaflet() %>% addProviderTiles('CartoDB.Positron')

palette = 'Spectral'

# map poverty ----
shp_poverty <- readOGR("Data/final-poverty", "eth_adm1_poverty")

# define choropleth color palette for legend using values from other leaflet plots
bins <- c(seq(0, 0.5, by=0.1), Inf)
pal <- colorBin(palette, domain = shp_poverty$MPI, bins = bins)

# basemap
m <- basemap %>% addPolygons(data=shp_poverty,
                             color = "grey",
                             weight = 2,
                             fillOpacity = 0.2)

# add ETH Adm 1 regions
m <- m %>%
  addPolygons(data=shp_poverty,
              fillColor = ~pal(shp_poverty$MPI),
              stroke = TRUE,
              color = "grey",
              weight=1,
              dashArray = "",
              fillOpacity = 0.35,
              highlight = highlightOptions(
                weight = 3,
                color = "#666",
                dashArray = "",
                fillOpacity = 1,
                bringToFront = TRUE),
              label = shp_poverty$MPI,
              labelOptions = labelOptions(
                style = list("font-weight" = "normal", padding = "3px 8px"),
                textsize = "15px",
                direction = "auto"))

# add legend
m <- m %>% addLegend(pal = pal,
                     values = shp_poverty$MPI,
                     title = "2020 MPI",
                     position = "topright")
m




# map conflict ----
shp_conflict <- readOGR("Data/final-conflict", "eth_adm1_conflict")

# define choropleth color palette for legend using values from other leaflet plots
bins <- c(seq(0, 1.6, by=0.2), Inf)
pal <- colorBin(palette, domain = shp_conflict$fataliti_1, bins = bins)

# basemap
m <- basemap %>% addPolygons(data=shp_conflict,
                             color = "grey",
                             weight = 2,
                             fillOpacity = 0.2)

# add ETH Adm 1 regions
m <- m %>%
  addPolygons(data=shp_conflict,
              fillColor = ~pal(shp_conflict$fataliti_1),
              stroke = TRUE,
              color = "grey",
              weight=1,
              dashArray = "",
              fillOpacity = 0.35,
              highlight = highlightOptions(
                weight = 3,
                color = "#666",
                dashArray = "",
                fillOpacity = 1,
                bringToFront = TRUE),
              label = shp_conflict$fataliti_1,
              labelOptions = labelOptions(
                style = list("font-weight" = "normal", padding = "3px 8px"),
                textsize = "15px",
                direction = "auto"))

# add legend
m <- m %>% addLegend(pal = pal,
                     values = shp_conflict$fataliti_1,
                     title = "Fatalities per 100k",
                     position = "topright")
m

