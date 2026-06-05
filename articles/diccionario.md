# Diccionario de datos — Censos de Bolivia (1976–2024)

Este artículo documenta todas las variables de los cinco censos de
Bolivia disponibles en `censosbo`: **1976, 1992, 2001, 2012 y
CPV-2024**. Las tablas son interactivas — puedes buscar por nombre de
variable, descripción o categoría.

Para explorar el diccionario desde R:

``` r

# Buscar una variable en cualquier censo
codebook(buscar = "educacion", anio = 2012)
codebook_2024(buscar = "sexo")

# Ver los códigos de una variable
codebook_valores("p25_sexo")           # CPV-2024
codebook_valores("P24", anio = 2012)   # Censo 2012

# Ver todas las variables de un censo y tabla
codebook_1992(tabla = "persona")
```

------------------------------------------------------------------------

## CPV-2024

### Persona (`get_personas_2024`)

Datos de cada persona empadronada: **114** variables.

------------------------------------------------------------------------

### Vivienda (`get_viviendas_2024`)

Características de cada vivienda: **44** variables.

------------------------------------------------------------------------

### Emigración (`get_emigracion_2024`)

Personas que emigraron al exterior en los últimos 5 años: **4**
variables.

------------------------------------------------------------------------

### Mortalidad (`get_mortalidad_2024`)

Fallecimientos en el hogar durante los últimos 12 meses: **6**
variables.

------------------------------------------------------------------------

### Clave geográfica (CPV-2024)

Todas las tablas del CPV-2024 comparten la **clave de hogar**:

| Variable | Descripción                     |
|----------|---------------------------------|
| `idep`   | Código de departamento (01–09)  |
| `iprov`  | Código de provincia             |
| `imun`   | Código de municipio             |
| `i00`    | Identificador de vivienda/hogar |

``` r

library(DBI)
con <- DBI::dbConnect(duckdb::duckdb())
duckdb::duckdb_register_arrow(con, "personas",  get_personas_2024(departamento = "07"))
duckdb::duckdb_register_arrow(con, "viviendas", get_viviendas_2024(departamento = "07"))
DBI::dbGetQuery(con, "
  SELECT COUNT(*) AS personas_en_join FROM personas p
  JOIN viviendas v ON p.idep=v.idep AND p.iprov=v.iprov
                  AND p.imun=v.imun AND p.i00=v.i00
")
DBI::dbDisconnect(con)
```

------------------------------------------------------------------------

## Censo 2012

### Persona (`get_personas_2012`)

**31** variables.

------------------------------------------------------------------------

### Vivienda (`get_viviendas_2012`)

**30** variables.

------------------------------------------------------------------------

### Emigración (`get_emigracion_2012`)

**4** variables.

------------------------------------------------------------------------

### Discapacidad (`get_discapacidad_2012`)

**6** variables.

------------------------------------------------------------------------

## Censo 2001

### Persona (`get_personas_2001`)

**64** variables.

------------------------------------------------------------------------

### Vivienda (`get_viviendas_2001`)

**37** variables.

------------------------------------------------------------------------

## Censo 1992

### Persona (`get_personas_1992`)

**52** variables.

------------------------------------------------------------------------

### Vivienda (`get_viviendas_1992`)

**42** variables.

------------------------------------------------------------------------

### Mortalidad (`get_mortalidad_1992`)

**12** variables.

------------------------------------------------------------------------

## Censo 1976

### Población (`get_poblacion_1976`)

**46** variables.

------------------------------------------------------------------------

### Vivienda (`get_viviendas_1976`)

**28** variables.

------------------------------------------------------------------------

### Fuentes

> Instituto Nacional de Estadística (INE). Bolivia. Censos Nacionales de
> Población y Vivienda, 1976, 1992, 2001, 2012 y 2024.
> <https://anda.ine.gob.bo>
