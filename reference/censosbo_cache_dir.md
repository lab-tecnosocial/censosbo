# Directorio de caché local del paquete

Devuelve la ruta donde se guardan los archivos Parquet descargados. Por
defecto usa el directorio estándar del sistema operativo, pero puede
redirigirse a cualquier ruta local (por ejemplo, dentro del proyecto
actual) estableciendo la opción \`censosbo.cache_dir\` antes de llamar a
\`get\_\*()\`.

## Usage

``` r
censosbo_cache_dir()
```

## Value

Ruta al directorio de caché (cadena de caracteres).

## Details

Para guardar el caché dentro de tu proyecto en lugar del directorio del
sistema, añade esto al inicio de tu script o en tu \`.Rprofile\`:

“\`r options(censosbo.cache_dir = "data/censosbo") “\`

El directorio se crea automáticamente si no existe.

## Examples

``` r
censosbo_cache_dir()
#> [1] "/home/runner/.cache/R/censosbo"

# Redirigir el caché a una carpeta del proyecto
anterior <- options(censosbo.cache_dir = file.path(tempdir(), "censosbo"))
censosbo_cache_dir()
#> [1] "/tmp/RtmpzKcBCv/censosbo"
options(anterior)
```
