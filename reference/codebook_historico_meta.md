# Diccionarios de variables de los censos históricos de Bolivia

Lista nombrada con los metadatos de variables de los censos 1976, 1992,
2001 y 2012. Cada elemento es un data.frame con la misma estructura que
\[codebook_meta\].

## Usage

``` r
codebook_historico_meta
```

## Format

Una lista con elementos \`"1976"\`, \`"1992"\`, \`"2001"\` y \`"2012"\`,
cada uno un data.frame con columnas:

- variable:

  Nombre original de la variable en el censo

- etiqueta:

  Descripción de la variable

- tabla:

  Tabla/entidad REDATAM de origen

- tipo:

  \`"categorica"\`, \`"numerica"\` o \`"texto"\` (misma regla que en
  \[codebook_meta\]: códigos con etiquetas o con nombre tipo \`cod\` son
  categóricos aunque sus valores sean números)

- valores_codigos:

  Lista de data.frames con códigos y etiquetas

## Source

INE Bolivia. Diccionarios Parquet generados por open-redatam.
