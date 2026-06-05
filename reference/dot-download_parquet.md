# Descarga un archivo Parquet del CPV-2024 desde GitHub Releases

Descarga un archivo Parquet del CPV-2024 desde GitHub Releases

## Usage

``` r
.download_parquet(filename, overwrite = FALSE, verbose = TRUE)
```

## Arguments

- filename:

  Nombre del archivo (e.g., \`"persona_dep07.parquet"\`)

- overwrite:

  Lógico. Si \`TRUE\`, re-descarga aunque exista en caché.

- verbose:

  Lógico. Mostrar progreso.

## Value

Ruta local al archivo (invisible).
