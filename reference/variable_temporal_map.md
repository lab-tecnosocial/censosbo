# Variables armonizadas para análisis temporal

Tabla de correspondencia entre variables de los censos de Bolivia (1976,
1992, 2001, 2012 y CPV-2024), con las variables que pueden compararse a
lo largo del tiempo.

## Usage

``` r
variable_temporal_map
```

## Format

Un data.frame con columnas:

- variable:

  Nombre armonizado (e.g., \`"sexo"\`, \`"nivel_edu"\`)

- etiqueta:

  Descripción en español

- descripcion:

  Descripción detallada y notas de comparabilidad

- tabla:

  Tabla de origen: \`"persona"\` o \`"vivienda"\`

- v1976, v1992, v2001, v2012, v2024:

  Nombre de la columna en cada censo (\`NA\` si no disponible)

- notas:

  Advertencias sobre diferencias metodológicas entre censos

## Source

Elaboración propia a partir de los diccionarios oficiales del INE
Bolivia.
