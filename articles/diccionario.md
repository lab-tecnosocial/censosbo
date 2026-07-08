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

La columna **Tipo** clasifica cada variable como:

- **`categorica`** — sus valores son códigos con significado. Incluye
  variables cuyos valores son números pero representan categorías
  (p. ej. `sexo` 1/2) y códigos de clasificación con nombre terminado en
  `cod` (departamento, municipio, ocupación, idioma…), aunque no todos
  sus códigos estén enumerados.
- **`numerica`** — conteos y medidas continuas (edad, número de
  habitaciones…).
- **`texto`** — texto libre.

Esta clasificación está disponible también en la columna `tipo` de los
`diccionario_variables.parquet` publicados.

------------------------------------------------------------------------

## CPV-2024

### Persona (`get_personas_2024`)

Datos de cada persona empadronada: **118** variables.

------------------------------------------------------------------------

### Vivienda (`get_viviendas_2024`)

Características de cada vivienda: **47** variables.

------------------------------------------------------------------------

### Emigración (`get_emigracion_2024`)

Personas que emigraron al exterior en los últimos 5 años: **7**
variables.

------------------------------------------------------------------------

### Mortalidad (`get_mortalidad_2024`)

Fallecimientos en el hogar durante los últimos 12 meses: **9**
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

### Área urbana/rural y grupos de edad derivados (CPV-2024)

Algunas columnas de la tabla **persona** son **derivadas** por el INE
(no son preguntas del cuestionario). Todas están en el diccionario y se
etiquetan con
[`etiquetar_valores()`](https://lab-tecnosocial.github.io/censosbo/reference/etiquetar_valores.md).

**Urbano/rural.** El mismo concepto usa dos nombres según la tabla:

| Tabla    | Columna  | Códigos                   |
|----------|----------|---------------------------|
| persona  | `area`   | `1 = Urbana`, `2 = Rural` |
| vivienda | `urbrur` | `1 = Urbana`, `2 = Rural` |

``` r

codebook_valores("area")     # persona
codebook_valores("urbrur")   # vivienda
```

**Grupos de edad.** La tabla persona trae varias agrupaciones de edad,
además de la edad exacta en años (`p26_edad`, numérica). Se distinguen
por sus cortes:

| Variable | Descripción | Cortes |
|----|----|----|
| `edad_qui` | Edad quinquenal | 0–4, 5–9, …, 95–99, 100+ |
| `g_edad` | Grandes grupos de edad (estándar internacional) | 0–14, 15–64, 65+ |
| `g_edad_bol` | Grandes grupos de edad (corte boliviano) | 0–14, 15–59, 60+ |
| `gedadedu` | Grupo de edad según asistencia educativa | 0–3, 4–5, 6–11, 12–17, 18–24, 25–59, 60+ |

``` r

codebook_valores("g_edad")       # 0-14 / 15-64 / 65 y más
codebook_valores("g_edad_bol")   # 0-14 / 15-59 / 60 y más (Bolivia)
codebook_valores("edad_qui")     # quinquenios
codebook_valores("gedadedu")     # grupos de edad educativa
```

------------------------------------------------------------------------

## Censo 2012

### Persona (`get_personas_2012`)

**39** variables.

------------------------------------------------------------------------

### Vivienda (`get_viviendas_2012`)

**33** variables.

------------------------------------------------------------------------

### Emigración (`get_emigracion_2012`)

**7** variables.

------------------------------------------------------------------------

### Discapacidad (`get_discapacidad_2012`)

**9** variables.

------------------------------------------------------------------------

## Censo 2001

### Persona (`get_personas_2001`)

**68** variables.

------------------------------------------------------------------------

### Vivienda (`get_viviendas_2001`)

**40** variables.

------------------------------------------------------------------------

## Censo 1992

### Persona (`get_personas_1992`)

**56** variables.

------------------------------------------------------------------------

### Vivienda (`get_viviendas_1992`)

**45** variables.

------------------------------------------------------------------------

### Mortalidad (`get_mortalidad_1992`)

**15** variables.

------------------------------------------------------------------------

## Censo 1976

### Población (`get_poblacion_1976`)

**48** variables.

------------------------------------------------------------------------

### Vivienda (`get_viviendas_1976`)

**29** variables.

------------------------------------------------------------------------

### Fuentes

> Instituto Nacional de Estadística (INE). Bolivia. Censos Nacionales de
> Población y Vivienda, 1976, 1992, 2001, 2012 y 2024.
> <https://anda.ine.gob.bo>
