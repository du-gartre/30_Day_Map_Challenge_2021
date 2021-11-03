
#' Día 1: 
#' Nombres de los esquites por estado
#' 
#' 30 Day map Challenge (Noviembre, 2021)
#' México
#' 
#' Por:
#'  David Garibay
#'  Karen Santoyo


# Importar librerías ------------------------------------------------------
library(sf)      # para leer mapas
library(leaflet) # para crear mapas
library(dplyr)
library(mapview) # para guardar leaflet en png o jpg


# Importar datos ----------------------------------------------------------

## Base con nombres de esquites por Entidad Federativa ----
#' Esta base la creamos manualmente a partir de la información de:
#' https://es.wikipedia.org/wiki/Esquites
df_esquites <- read.csv(file = "data/nombres_esquites.csv") %>%
  # Ordenamos las entidades por orden alfabético
  arrange(Entidad) 
  

## Shapefile a nivel Entidad Federativa ----
# Este mapa fue obtenido del Marco Geoestadístico de Septiembre de 2019 del 
# INEGI. En particular, descargamos el Marco Geoestadístico Integrado Sept 2019

# https://www.inegi.org.mx/app/biblioteca/ficha.html?upc=889463776079

# Luego de ello, en QGIS volvimos el mapa a formato GeoJson y se le agregó el 
# CRS WGS-84

shp_ent <- st_read("data/estados.geojson")



# Renombramos columna de entidades federativas
shp_ent$NOMGEO <- df_esquites$Entidad


# Manipulación de datos ---------------------------------------------------

## Unimos las bases de datos ----
shp_datos <- merge(x = shp_ent, 
                   y = df_esquites,  
                   by.x = "NOMGEO", 
                   by.y = "Entidad", 
                   all.x = TRUE)

## Creamos variables categóricas (factors) ----
shp_datos$Nombre <- factor(x = shp_datos$Nombre, 
                           levels = c("Esquite", "Elote en vaso", 
                                      "Cóctel de elote", "Chasca", 
                                      "Elote desgranado", "Trolelote",
                                      "Vasolote"))


# Creación del mapa -------------------------------------------------------
## Paleta de colores ----
pal_fac <- colorFactor(palette = "Set2", 
                       domain = shp_datos$Nombre)

## pop-up ----
# Son los mensajes que aparecen cuando damos click a alguno de los
# estados
popup <-  paste0(
  "<b>", "Estado: ", "</b>", as.character(shp_datos$NOMGEO), "<br>",
  "<b>", "Nombre: ", "</b>", as.character(shp_datos$Nombre), "<br>")


## Leaflet (interactivo) ----
# En este caso es interactivo, seguí el tutorial de 
# Juvenal Campos:
# https://juvenalcampos.com/2020/01/13/tutorial-de-mapas-en-leaflet/
lft_esquites <- leaflet(data = shp_datos, 
        options = leafletOptions(zoomControl = FALSE)) %>%
  addProviderTiles("Esri.WorldTerrain") %>%
  addPolygons(color = "#444444", # Color de los bordes
              fillColor = ~pal_fac(shp_datos$Nombre),  # Relleno de estados 
              layerId = ~shp_datos$NOMGEO,
              opacity = 1, # Opacidad de los bordes
              smoothFactor = 0.5, 
              weight = 1, # Grosor de los bordes
              fillOpacity = 0.7,
              highlightOptions = highlightOptions(color = "white", 
                                                  weight = 2, 
                                                  bringToFront = TRUE),
              label = ~shp_datos$Nombre, 
              labelOptions = labelOptions(direction = "auto"), 
              popup = popup) %>% 
  addLegend(position = "bottomleft", 
            pal = pal_fac, 
            values = ~shp_datos$Nombre, 
            title = "Nombre de esquites")



# Guardar mapa  ---------------------------------------------------
## como PNG ----
# https://r-spatial.github.io/mapview/reference/mapshot.html
mapshot(lft_esquites, file = "figs/mapa_esquites.png")

## Como HTML ----
htmlwidgets::saveWidget(lft_esquites, "figs/mapa_esquites.html")



