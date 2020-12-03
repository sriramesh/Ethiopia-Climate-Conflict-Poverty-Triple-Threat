# load required libraries
library(raster)
library(leaflet)
library(rgdal)
library(tidyverse)

# download ETH Adm1 boundaries and elevation data ----
ETH_Adm_1 <- raster::getData(name = "GADM", country = "ETH", level = 1) #Adm1
ETH_elev <- raster::getData(name = "alt", country = "ETH") # Elevation (meters)

# colormap for elevation
raster_colorPal_elev <- colorNumeric(palette = topo.colors(64),
                                     domain = values(ETH_elev),
                                     na.color = NA)
# plot elevation
leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addRasterImage(x = ETH_elev,
                 color = raster_colorPal_elev) %>%
  addLegend(title = "Elevation<br>(meters)",
            values = values(ETH_elev),
            pal = raster_colorPal_elev)