# Información sobre los archivos en caché

Muestra los archivos Parquet descargados localmente, con sus tamaños y
fechas de descarga.

## Usage

``` r
censosbo_cache_info()
```

## Value

Un data.frame con columnas \`archivo\`, \`tamanio\` y \`modificado\`, o
\`NULL\` invisible si el caché está vacío.

## Examples

``` r
censosbo_cache_info()
#> El directorio de caché no existe aún: /home/runner/.cache/R/censosbo
```
