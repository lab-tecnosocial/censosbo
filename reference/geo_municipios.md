# Geometrías de los municipios de Bolivia

Objeto \`sf\` con 339 de los 343 municipios del CPV-2024 y sus
geometrías poligonales. Los 4 municipios sin cobertura en la fuente
cartográfica no están incluidos.

## Usage

``` r
geo_municipios
```

## Format

Un \`sf\` data.frame con 339 filas y 7 columnas (más geometría):

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

- geometry:

  Geometría de polígono (CRS: WGS84 / EPSG:4326)

## Source

INE Bolivia. Límites administrativos de municipios, derivados de
cartografía electoral (2025).

## Note

4 municipios del CPV-2024 no tienen cobertura cartográfica en la fuente
y no aparecerán en los mapas generados con \[mapa_mun()\]: los TIOC
Raqaypampa (Cochabamba), Jatun Ayllu Yura (Potosí) y Territorio Indígena
Multiétnico (Beni), más San Pedro de Macha (Potosí).

## See also

\[geo_departamentos\], \[mapa_mun()\]
