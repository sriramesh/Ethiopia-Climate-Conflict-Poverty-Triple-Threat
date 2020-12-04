# load required libraries
library(raster)
library(leaflet)
library(rgdal)
library(tidyverse)

# download ETH Adm0 boundaries and precipitation data from worldclim.org ----
ETH_Adm0 <- raster::getData(name = "GADM", country = "ETH", level = 0)

ETH_prec_2.5 <- raster::getData(name = "worldclim", var = "prec",
                                res = 2.5) # rasterstack

# Restrict to Jul (rasterlayer)
ETH_prec_2.5_Jul <- ETH_prec_2.5[[7]]

# Crop and Mask to Ethiopia extent 
ETH_prec_2.5_Jul_Crop_Unmasked <- raster::crop(x = ETH_prec_2.5_Jul, y = ETH_Adm0)
ETH_prec_2.5_Jul_Crop <- raster::mask(x = ETH_prec_2.5_Jul_Crop_Unmasked, mask = ETH_Adm0)

# colormap
raster_colorPal_prec_Jul <- colorNumeric(palette = topo.colors(64),
                                         domain = values(ETH_prec_2.5_Jul_Crop),
                                         na.color = NA)
# map precipitation
leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addRasterImage(x = ETH_prec_2.5_Jul_Crop,
                 color = raster_colorPal_prec_Jul) %>%
  addLegend(title = "Jul precipitation (mm)<br>(2.5' res)",
            values = values(ETH_prec_2.5_Jul_Crop),
            pal = raster_colorPal_prec_Jul)

