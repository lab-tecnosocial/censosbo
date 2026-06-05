# Descarga un archivo de un censo histórico desde su GitHub Release

Descarga un archivo de un censo histórico desde su GitHub Release

## Usage

``` r
.download_censo(anio, filename, overwrite = FALSE, verbose = TRUE)
```

## Arguments

- anio:

  Año del censo (1976, 1992, 2001 o 2012).

- filename:

  Nombre del archivo (e.g., \`"persona.parquet"\`)

- overwrite:

  Lógico. Si \`TRUE\`, re-descarga aunque exista en caché.

- verbose:

  Lógico. Mostrar progreso.

## Value

Ruta local al archivo (invisible).
