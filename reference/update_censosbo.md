# Actualiza el paquete censosbo y limpia el caché

Reinstala la última versión de \`censosbo\` desde GitHub y elimina el
caché local de datos Parquet, para que los datos se vuelvan a descargar
en su versión más reciente. Útil cuando se publica una nueva versión que
incluye correcciones en los datos o nuevas variables.

## Usage

``` r
update_censosbo(clear_cache = TRUE)
```

## Arguments

- clear_cache:

  Lógico. Si \`TRUE\` (defecto), limpia el caché local automáticamente
  tras actualizar el paquete. Usa \`FALSE\` solo si quieres conservar
  los archivos descargados.

## Value

Invisible \`NULL\`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Actualizar paquete y limpiar caché (recomendado)
update_censosbo()

# Solo actualizar el paquete sin tocar el caché
update_censosbo(clear_cache = FALSE)
} # }
```
