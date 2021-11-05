


# Establecemos el directorio base
dir_base = "C:/Users/David/Documents/GitHub/30_Day_Map_Challenge_2021/04_atropellamientos/data/"

# Importamos alcaldías de la CDMX
dir_alcaldias = dir_base + "alcaldias.shp"
alcaldias  = QgsVectorLayer(dir_alcaldias, "alcaldias", "ogr")
QgsProject.instance().addMapLayer(alcaldias)

# Importamos Atropellamientos registrados por el C5 en 2020
dir_c5_atr_2020 = dir_base + "c5_atr_2020.shp"
c5_atr_2020  = QgsVectorLayer(dir_c5_atr_2020, "c5_atr_2020", "ogr")
QgsProject.instance().addMapLayer(c5_atr_2020)

######## MANUAL
# Creamos una malla hexagonal:
# primero bajamos el plugin de MMQGIS
# Luego, en MMQGIS/Create/Create Grid layer
# En Geometry type seleccionamos hexágonos
# en X Spacing ponemos 0.005
# Y Spacing se acomoda por default
# en unidades seleccionamos las unidades de la capa
# en Extent poner current window 
# (antes alejar la ventana y centrar la capa vectorial de las alcaldías)
# y en Layer ponemos seleccionamos la capa de alcaldía
# 
# Guardar la capa como hexagons.shp en el dir_base


## Filtramos los hexágonos para quedarnos con los superpuestos a las alcaldías

# Dirección para los hexágonos filtrados
dir_hex_filt = dir_base + "hex_filt.shp"

# Ejecutamos proceso
processing.run("native:extractbylocation", 
    {'INPUT': dir_base + 'hexagons.shp',
    'PREDICATE':[0],
    'INTERSECT': dir_alcaldias,
    'OUTPUT': dir_hex_filt})

# Cargamos los hexágonos que se superponen a las alcaldías
hex_filt = QgsVectorLayer(dir_hex_filt , "hex_filt", "ogr")
QgsProject.instance().addMapLayer(hex_filt)

## Creamos una capa de hexágonos en donde absorba la info de 
## los atropellamientos

# Dirección para los hexágonos con info
dir_hex_info = dir_base + "hex_info.shp"

# Ejecutamos proceso
processing.run("qgis:joinbylocationsummary", 
    {'INPUT':dir_hex_filt,
    'JOIN': dir_c5_atr_2020,
    'PREDICATE':[0],
    'JOIN_FIELDS':[],
    'SUMMARIES':[],
    'DISCARD_NONMATCHING':False,
    'OUTPUT':dir_hex_info})
    
# Cargamos los hexágonos con la info resumida
hex_info = QgsVectorLayer(dir_hex_info , "hex_info", "ogr")
QgsProject.instance().addMapLayer(hex_info)

######## MANUAL
# Luego entramos a la calculadora de campo en hex_info
# Seleccionamos Update existing Field
# Seleccionamos field_1_co
# y escribimos la siguiente expresión:
#  if( "field_1_co" IS NULL ,0, "field_1_co")
# damos click en Ok
# Esto reemplaza todos los NA que tienen los hexágonos y les asigna un 0