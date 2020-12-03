# load required libraries
library(raster)
library(leaflet)
library(rgdal)
library(tidyverse)

# download ETH Adm0 boundaries and precipitation data from worldclim.org ----
ETH_Adm0 <- raster::getData(name = "GADM", country = "ETH", level = 0)

ETH_prec_2.5 <- raster::getData(name = "worldclim", var = "prec",
                                res = 2.5) # rasterstack

# Restrict to Nov (rasterlayer)
ETH_prec_2.5_Nov <- ETH_prec_2.5[[11]]

# Crop and Mask to Ethiopia extent 
ETH_prec_2.5_Nov_Crop_Unmasked <- raster::crop(x = ETH_prec_2.5_Nov, y = ETH_Adm0)
ETH_prec_2.5_Nov_Crop <- raster::mask(x = ETH_prec_2.5_Nov_Crop_Unmasked, mask = ETH_Adm0)

# colormap
raster_colorPal_prec_Nov <- colorNumeric(palette = topo.colors(64),
                                         domain = values(ETH_prec_2.5_Nov_Crop),
                                         na.color = NA)
# map precipitation
leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addRasterImage(x = ETH_prec_2.5_Nov_Crop,
                 color = raster_colorPal_prec_Nov) %>%
  addLegend(title = "Nov precipitation (mm)<br>(2.5' res)",
            values = values(ETH_prec_2.5_Nov_Crop),
            pal = raster_colorPal_prec_Nov)
