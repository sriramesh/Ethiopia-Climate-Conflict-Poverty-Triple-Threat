# load required libraries
library(raster)
library(leaflet)
library(rgdal)
library(tidyverse)

# download ETH Adm0 boundaries and tmeanipitation data from worldclim.org ----
ETH_Adm0 <- raster::getData(name = "GADM", country = "ETH", level = 0)

ETH_tmean_2.5 <- raster::getData(name = "worldclim", var = "tmean",
                                res = 2.5) # rasterstack

# Restrict to Jul (rasterlayer)
ETH_tmean_2.5_Jul <- ETH_tmean_2.5[[7]]

# Crop and Mask to Ethiopia extent 
ETH_tmean_2.5_Jul_Crop_Unmasked <- raster::crop(x = ETH_tmean_2.5_Jul, y = ETH_Adm0)
ETH_tmean_2.5_Jul_Crop <- raster::mask(x = ETH_tmean_2.5_Jul_Crop_Unmasked, mask = ETH_Adm0)

# colormap
raster_colorPal_tmean_Jul <- colorNumeric(palette = topo.colors(64),
                                         domain = values(ETH_tmean_2.5_Jul_Crop),
                                         na.color = NA)
# map tmeanipitation
leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addRasterImage(x = ETH_tmean_2.5_Jul_Crop,
                 color = raster_colorPal_tmean_Jul) %>%
  addLegend(title = "Jul average temp (C)<br>(2.5' res)",
            values = values(ETH_tmean_2.5_Jul_Crop),
            pal = raster_colorPal_tmean_Jul)

