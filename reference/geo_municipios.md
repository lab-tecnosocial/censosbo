# Geometrías de los municipios de Bolivia

Objeto \`sf\` con los 343 municipios del CPV-2024 y sus geometrías
poligonales, incluidos los cuatro Gobiernos Autónomos Indígena
Originario Campesinos (GAIOC) creados entre 2016 y 2023.

## Usage

``` r
geo_municipios
```

## Format

Un \`sf\` data.frame con 343 filas y 8 columnas (más geometría):

- idep:

  Código de departamento

- nombre_dep:

  Nombre del departamento

- iprov:

  Código de provincia

- nombre_prov:

  Nombre de la provincia

- imun:

  Código de municipio

- nombre_mun:

  Nombre del municipio

- capital:

  Capital del municipio

- superficie_km2:

  Superficie en kilómetros cuadrados

- geometry:

  Geometría de polígono (CRS: WGS84 / EPSG:4326)

## Source

Varias fuentes, detalladas en la viñeta \*Mapas coropléticos\*. Límites,
capital y superficie: SDSN Bolivia (2025), \*Límites Municipales Bolivia
2025\* \\Archivo shapefile\\,
\<https://sdsnbolivia.org/datos-espaciales/\>. Códigos y nombres: INE
Bolivia (Redatam, CPV-2024).

## Details

Las geometrías están simplificadas preservando la topología, así que los
bordes entre municipios vecinos son idénticos y no quedan franjas vacías
entre ellos. Los únicos huecos interiores del país son cuerpos de agua
excluidos de la división municipal: el Salar de Uyuni y los lagos Poopó
y Uru Uru.

Los códigos \`idep\`/\`iprov\`/\`imun\` se verificaron uno a uno contra
los puntos de comunidades del CPV-2024 (\[get_geo_comunidades()\]) y
contra la población municipal de los microdatos, que coincide
exactamente en los 343 municipios.

## See also

\[geo_departamentos\], \[mapa_mun()\], \[geo_bolivia\]
