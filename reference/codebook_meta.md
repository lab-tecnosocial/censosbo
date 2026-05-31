# Diccionario de variables del CPV-2024

Metadatos de todas las variables del Censo de Población y Vivienda 2024
de Bolivia, extraídos del Diccionario de Variables oficial del INE.

## Usage

``` r
codebook_meta
```

## Format

Un data.frame con las siguientes columnas:

- variable:

  Nombre de la variable (minúsculas, igual que en los datos)

- etiqueta:

  Descripción en español de la variable

- tabla:

  Tabla a la que pertenece: \`"persona"\`, \`"vivienda"\`,
  \`"emigracion"\` o \`"mortalidad"\`

- tipo:

  Tipo de dato: \`"numerica"\`, \`"categorica"\` o \`"texto"\`

- valores_codigos:

  Lista de data.frames con los códigos y etiquetas para variables
  categóricas; \`NULL\` para variables numéricas

## Source

INE Bolivia, CPV-2024. Diccionario de Variables CPV 2024.xlsx.
