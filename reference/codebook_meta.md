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

  Tipo de dato: \`"categorica"\`, \`"numerica"\` o \`"texto"\`. Una
  variable es \`"categorica"\` si sus valores son códigos con etiquetas
  (aunque sean números, como \`sexo\` 1/2) o si su nombre indica un
  código de clasificación (sufijo \`cod\`: códigos geográficos, de
  ocupación, etc.); \`"texto"\` si almacena texto libre; \`"numerica"\`
  en los demás casos (conteos y medidas)

- valores_codigos:

  Lista de data.frames con los códigos y etiquetas para variables
  categóricas; \`NULL\` para variables numéricas o de texto

## Source

INE Bolivia, CPV-2024. Diccionario de Variables CPV 2024.xlsx.
