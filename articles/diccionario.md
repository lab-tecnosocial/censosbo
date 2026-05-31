# Diccionario de datos del CPV-2024

El **Censo de Población y Vivienda 2024 (CPV-2024)** de Bolivia incluye
**168 variables** organizadas en cuatro tablas. Este artículo documenta
cada variable con su nombre técnico, descripción en español, tipo de
dato y, para las variables categóricas, todos los códigos y sus
etiquetas.

Las tablas son interactivas: puedes **buscar** por nombre de variable,
descripción o categoría, y **ordenar** por cualquier columna.

------------------------------------------------------------------------

**Descargar el diccionario completo:**

``` r

# Ruta al CSV incluido en el paquete (tabla larga: una fila por código)
ruta <- system.file("extdata/diccionario_cpv2024.csv", package = "censosbo")
diccionario <- read.csv(ruta, encoding = "UTF-8")
head(diccionario)
```

También puedes consultar el diccionario directamente en R con
[`codebook()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook.md)
y
[`codebook_valores()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook_valores.md).

------------------------------------------------------------------------

## Persona (`get_personas`)

Datos de cada persona empadronada: **114** variables.

------------------------------------------------------------------------

## Vivienda (`get_viviendas`)

Características de cada vivienda particular: **44** variables.

------------------------------------------------------------------------

## Emigración (`get_emigracion`)

Personas que emigraron al exterior en los últimos 5 años: **4**
variables.

------------------------------------------------------------------------

## Mortalidad (`get_mortalidad`)

Fallecimientos en el hogar durante los últimos 12 meses: **6**
variables.

------------------------------------------------------------------------

## Clave geográfica

Todas las tablas comparten la **clave de hogar** que permite unirlas
entre sí:

| Variable | Descripción                                 |
|----------|---------------------------------------------|
| `idep`   | Código de departamento (01–09)              |
| `iprov`  | Código de provincia dentro del departamento |
| `imun`   | Código de municipio dentro de la provincia  |
| `i00`    | Identificador de vivienda/hogar             |

``` r

# Join personas + viviendas usando la clave completa
library(DBI)
con <- DBI::dbConnect(duckdb::duckdb())
duckdb::duckdb_register_arrow(con, "personas",  get_personas(departamento  = "07"))
duckdb::duckdb_register_arrow(con, "viviendas", get_viviendas(departamento = "07"))

DBI::dbGetQuery(con, "
  SELECT COUNT(*) AS personas_en_join
  FROM personas p
  JOIN viviendas v
    ON p.idep = v.idep AND p.iprov = v.iprov
   AND p.imun = v.imun AND p.i00  = v.i00
")
DBI::dbDisconnect(con)
```

## Fuente

> Instituto Nacional de Estadística (INE). (2024). *Censo de Población y
> Vivienda 2024 — Diccionario de Variables*. Bolivia.
> <https://anda.ine.gob.bo/index.php/catalog/132>
