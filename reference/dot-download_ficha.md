# Descarga un Parquet de datos agregados por manzano o comunidad

Mismo mecanismo que \[.download_parquet()\], pero contra el release
\`data-fichas-\*\` y cacheando bajo \`fichas/\` para no mezclar estos
datos agregados con los microdatos.

## Usage

``` r
.download_ficha(filename, overwrite = FALSE, verbose = TRUE)
```

## Arguments

- filename:

  Nombre del archivo (e.g., \`"ficha.parquet"\`).

- overwrite:

  Lógico. Si \`TRUE\`, re-descarga aunque exista en caché.

- verbose:

  Lógico. Mostrar progreso.

## Value

Ruta local al archivo (invisible).
