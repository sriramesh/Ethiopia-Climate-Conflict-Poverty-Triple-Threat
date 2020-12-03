library(sp)
library(leaflet)
library(tidyverse)
library(rgdal)

# load shapefile
refugee_sites <- readOGR("ETH-refugee-campsites", "Eth_refugee_camps_unhcr_2019") # refugee sites

# reproject data
wgs84 <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
refugee_sites <- spTransform(refugee_sites, wgs84)

# map refugee sites
basemap <- leaflet() %>% addProviderTiles("Esri.OceanBasemap")
basemap %>%
  addCircleMarkers(data=refugee_sites,
                   color='darkblue',
                   radius=10,
                   stroke = F,
                   popup = Name)
