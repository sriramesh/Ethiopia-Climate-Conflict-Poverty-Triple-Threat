# load required libraries
library(raster)
library(leaflet)
library(rgdal)
library(tidyverse)

ETH_prec_2.5_Nov_Crop
ETH_elev # precipitation raster has lower resolution than elevation raster, so must resample it

# resample elevation raster using bilinear interpolation (continuous variables)
ETH_prec_2.5_Nov_Crop_resampled <- ETH_prec_2.5_Nov_Crop %>%
  raster::resample(ETH_elev, method="bilinear")

# apply map algebra - but what function to use?
r1 <- ETH_prec_2.5_Nov_Crop_resampled
r2 <- ETH_elev

r3 <- overlay(r1, r2, fun=function(x,y){return(x*y)}) # multiplication

# colormap
raster_colorPal_elev <- colorNumeric(palette = topo.colors(64),
                                     domain = values(r3),
                                     na.color = NA)
leaflet() %>% # Plot
  addProviderTiles("CartoDB.Positron") %>%
  addRasterImage(x = r3,
                 color = raster_colorPal_elev) %>%
  addLegend(title = "Elevation and Temp multiplied",
            values = values(r3),
            pal = raster_colorPal_elev) 

r4 <- overlay(r1, r2, fun=function(x,y){return(x+y)}) # addition

# colormap
raster_colorPal_elev <- colorNumeric(palette = topo.colors(64),
                                     domain = values(r4),
                                     na.color = NA)
leaflet() %>% # Plot
  addProviderTiles("CartoDB.Positron") %>%
  addRasterImage(x = r4,
                 color = raster_colorPal_elev) %>%
  addLegend(title = "Elevation and Temp added",
            values = values(r4),
            pal = raster_colorPal_elev) 
