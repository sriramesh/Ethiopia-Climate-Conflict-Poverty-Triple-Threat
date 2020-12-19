# load required libraries ---
library(raster)
library(leaflet)
library(rgdal)
library(tidyverse)

# download data: GADM ETH Adm0 boundaries and WorldClim database ----
ETH_Adm0 <- raster::getData(name = "GADM", country = "ETH", level = 0)
ETH_bio <- raster::getData(name = "worldclim", var = "bio", res = 2.5) # rasterstack

# get annual trends data (bio1, annual mean temp and bio12, precipitation) ----
ETH_bio1 <- ETH_bio[[1]] # annual mean temp in Ethiopia from 1970 to 2000
ETH_bio12 <- ETH_bio[[12]] # annual precipitation in Ethiopia from 1970 to 2000

# Crop and mask each raster layer to Ethiopia extent ----
ETH_bio1 <- raster::crop(x = ETH_bio1, y = ETH_Adm0)
ETH_bio1 <- raster::mask(x = ETH_bio1, mask = ETH_Adm0)

ETH_bio12 <- raster::crop(x = ETH_bio12, y = ETH_Adm0)
ETH_bio12 <- raster::mask(x = ETH_bio12, mask = ETH_Adm0)

# map bio1
raster_colorPal <- colorNumeric(palette = topo.colors(64),
                                domain = values(ETH_bio1),
                                na.color = NA)
leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addRasterImage(x = ETH_bio1,
                 color = raster_colorPal) %>%
  addLegend(title = "ETH Bio 1: Annual Mean Temperature",
            values = values(ETH_bio1),
            pal = raster_colorPal)

# map bio12 
raster_colorPal <- colorNumeric(palette = topo.colors(64),
                                domain = values(ETH_bio12),
                                na.color = NA)
leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addRasterImage(x = ETH_bio12,
                 color = raster_colorPal) %>%
  addLegend(title = "ETH Bio 12: Annual Precipitation",
            values = values(ETH_bio12),
            pal = raster_colorPal)

# generate simplified Palmer Drought Index using annual temperature and rainfall data ----

# normalize bio1 data using the following formula: (actual val - min val) / (max val - min val) ----
r1 <- ETH_bio1
min_val = minValue(ETH_bio1)
max_val = maxValue(ETH_bio1)
r1 <- overlay(r1, fun=function(x){return( (x - min_val)/(max_val - min_val) )}) 

raster_colorPal <- colorNumeric(palette = topo.colors(64),
                                domain = values(r1),
                                na.color = NA)

leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addRasterImage(x = r1,
                 color = raster_colorPal) %>%
  addLegend(title = "Bio 1 Annual Mean Temp - Normalized",
            values = values(r1),
            pal = raster_colorPal) 

# normalize bio12 data using same formula ----
r2 <- ETH_bio12
min_val = minValue(ETH_bio12)
max_val = maxValue(ETH_bio12)

r2 <- overlay(r2, fun=function(x){return( (x - min_val)/(max_val - min_val) )})

raster_colorPal <- colorNumeric(palette = topo.colors(64),
                                domain = values(r2),
                                na.color = NA)
leaflet() %>% # Plot
  addProviderTiles("CartoDB.Positron") %>%
  addRasterImage(x = r2,
                 color = raster_colorPal) %>%
  addLegend(title = "Bio 12 Annual Precipitation - Normalized",
            values = values(r2),
            pal = raster_colorPal) 

# resample bio12 raster to bio1 extent and resolution using bilinear interpolation
r2 <- r2 %>%
  raster::resample(r1, method="bilinear")

# generate simplified Palmer Drought Index by taking mean of the two normalized indices ----
r3 <- overlay(r1, r2, fun=function(x, y){return( (x + y)/2 )})

# save raster to disk
writeRaster(r3,'simplified_palmer_index.tif',
            overwrite= TRUE,
            options=c('TFW=YES'))

# aggregate indices to ETH Adm 1 regions to map choropleth ----

# load ETH Adm 1 shapefiles ----
shp <- readOGR("Data/ETH-GADM-Adm-Boundaries", "gadm36_ETH_1")

# calculate mean index vals per polygon ----
r3.vals <- raster::extract(r3, shp)
r3.mean <- lapply(r3.vals, FUN=mean)
shp@data$index_mean = as.numeric(r3.mean)

# map choropleth via leaflet ----
basemap <- leaflet() %>% addProviderTiles('CartoDB.Positron')

# define choropleth color palette for legend using values from other leaflet plots
bins <- c(0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, Inf)
pal <- colorBin("Spectral", domain = shp$index_mean, bins = bins)

# basemap
m <- basemap %>% addPolygons(data=shp,
                             color = "none",
                             weight = 2,
                             fillOpacity = 0.2)
# add ETH Adm 1 regions
m <- m %>%
  addPolygons(data=shp,
              fillColor = ~pal(shp$index_mean),
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
              label = shp$index_mean,
              labelOptions = labelOptions(
                style = list("font-weight" = "normal", padding = "3px 8px"),
                textsize = "15px",
                direction = "auto"))

# add legend
m <- m %>% addLegend(pal = pal,
                     values = shp$index_mean,
                     title = "Mean Flood/Drought Index Value",
                     position = "topright")
m
