# Censos históricos de Bolivia (1976–2012)

`censosbo` incluye microdatos de los cuatro censos bolivianos anteriores
al CPV-2024: **1976, 1992, 2001 y 2012**. Los datos se descargan bajo
demanda desde GitHub Releases y se almacenan en el mismo caché local que
los datos del 2024.

## Tablas disponibles por año

| Año | Tablas | Filas | Columnas geográficas |
|----|----|---:|----|
| 1976 | `poblacion` (alias: `persona`), `vivienda` | ~4.6M | `idep`, `iprov` (string `"01"`–`"09"`) |
| 1992 | `persona`, `vivienda`, `mortalidad` | ~6.4M | `idep`, `iprov`, `imun` |
| 2001 | `persona`, `vivienda` | ~8.3M | `idep`, `iprov`, `imun` |
| 2012 | `persona`, `vivienda`, `emigracion`, `discapacidad` | ~10M | `idep`, `iprov`, `imun` |
| 2024 | `persona`, `vivienda`, `emigracion`, `mortalidad` | ~11.4M | `idep`, `iprov`, `imun`, `i00` |

[`get_censo()`](https://lab-tecnosocial.github.io/censosbo/reference/get_censo.md)
acepta también `anio = 2024`: en ese caso delega en
[`get_personas_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_personas_2024.md)
y sus funciones hermanas, así que la API es la misma para todos los
censos. Esta viñeta se centra en los cuatro censos anteriores.

Todas las tablas traen las columnas geográficas armonizadas
`idep`/`iprov`/`imun` (mismo formato que el CPV-2024), por lo que se
puede filtrar por geografía directamente, sin reconstruir la jerarquía
REDATAM ni hacer joins.

## API: `get_censo()` y funciones cortas

La función principal es `get_censo(anio, tabla, ...)`. También hay
funciones cortas por año.

``` r

# API genérica — forma canónica
get_censo(2012, "persona", departamento = "Pando", verbose = FALSE)
#> FileSystemDataset (query)
#> PERSONA_REF_ID: int32
#> VIVIENDA_REF_ID: int32
#> P23: int32
#> P24: int32
#> P27: int32
#> P28A: int32
#> P28B: int32
#> P28C: int32
#> P28D: int32
#> P28E: int32
#> P28F: int32
#> P28G: int32
#> P32A: int32
#> P32J: int32
#> P33H: int32
#> P34A: int32
#> P34H: int32
#> P45: int32
#> P46: int32
#> P47: int32
#> P49A: int32
#> P49B: int32
#> P43: int32
#> P30B: int32
#> P31B1: int32
#> P35: int32
#> P36: int32
#> P37A_NIVELNUE: int32
#> P42: int32
#> P44: int32
#> PEA: int32
#> PET: int32
#> PEI: int32
#> area: int32
#> P25: int32
#> P26: int32
#> P33A: int32
#> P29C: int32
#> idep: string
#> iprov: string
#> imun: string
#> 
#> * Filter: is_in(idep, {value_set=string:[
#>   "09"
#> ], null_matching_behavior=SKIP})
#> See $.data for the source Arrow object
```

``` r

# Funciones cortas equivalentes
get_personas_2012(departamento = "07")
get_personas_2001(departamento = "La Paz")
get_personas_1992(departamento = "03")
get_poblacion_1976(departamento = "05")
```

Los parámetros son los mismos que en
[`get_personas_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_personas_2024.md):

| Parámetro      | Descripción                                    |
|----------------|------------------------------------------------|
| `anio`         | Año del censo: 1976, 1992, 2001, 2012 o 2024   |
| `tabla`        | Nombre de la tabla (ver tabla arriba)          |
| `departamento` | Código `"01"`–`"09"` o nombre del departamento |
| `provincia`    | Código de provincia (no disponible en 1976)    |
| `municipio`    | Código de municipio (no disponible en 1976)    |
| `variables`    | Vector de columnas a seleccionar               |
| `as`           | `"arrow"` (defecto), `"tibble"`, o `"duckdb"`  |

## Descarga y caché

La primera llamada descarga el archivo Parquet desde GitHub Releases.
Las siguientes usan el caché local:

``` r

# Primera vez: descarga ~99 MB
personas_1992 <- get_personas_1992(departamento = "07")

# Siguiente vez: instantáneo (caché)
personas_1992 <- get_personas_1992(departamento = "07")

# Forzar re-descarga
personas_1992 <- get_personas_1992(departamento = "07", overwrite = TRUE)

# Ver qué hay en caché
censosbo_cache_info()
```

Los archivos históricos se guardan en subcarpetas por año:
`censosbo_cache_dir()/historico/1992/persona.parquet`, etc.

## Filtros geográficos

``` r

# Por departamento (nombre o código)
get_personas_2012(departamento = "Santa Cruz")
get_personas_2012(departamento = "07")

# Por departamento + provincia
get_viviendas_1992(departamento = "03", provincia = "01")

# Por municipio (1992, 2001, 2012 — no disponible en 1976).
# El código de municipio se repite entre provincias, así que por código hay que
# indicar también la provincia; por nombre no hace falta.
get_personas_2012(municipio = "Cotoca")
get_personas_2012(departamento = "07", provincia = "01", municipio = "01")
```

Un ejemplo real, contando personas por municipio de Pando en 2012:

``` r

get_personas_2012(departamento = "Pando", verbose = FALSE) |>
  count(idep, iprov, imun) |>
  collect() |>
  etiquetar_geografia() |>
  arrange(desc(n)) |>
  head(5)
#> # A tibble: 5 × 7
#>   idep  iprov imun      n nombre_dep nombre_prov    nombre_mun           
#>   <chr> <chr> <chr> <int> <chr>      <chr>          <chr>                
#> 1 09    01    01    46267 Pando      Nicolás Suárez Cobija               
#> 2 09    03    03     8258 Pando      Madre de Dios  Sena                 
#> 3 09    03    01     8160 Pando      Madre de Dios  Puerto Gonzalo Moreno
#> 4 09    01    02     7948 Pando      Nicolás Suárez Porvenir             
#> 5 09    03    02     7652 Pando      Madre de Dios  San Lorenzo
```

Hay dos situaciones distintas cuando un municipio no aparece:

- Si **no está en el catálogo geográfico** del paquete, es un error
  inmediato, antes de descargar nada.
- Si **está en el catálogo pero no tiene registros en ese censo**, se
  emite una advertencia y se retorna `NULL`.

``` r

# "100" no es un código de municipio válido — error con sugerencia
get_personas_1992(municipio = "100")
#> Error in `.match_geo_level()`:
#> ! municipio no encontrado en el catálogo: "100"
#> ℹ Acepta código (p.ej. "01") o nombre (p.ej. "Cochabamba").
#> ℹ Consulta los valores válidos con `municipios(departamento)`.
```

> **Nota:** El número de municipios cambió entre censos (1992: 339,
> 2001: 343, 2012: 339, 2024: 343). Un código válido en un año puede no
> existir en otro.

## Censo 1976: estructura diferente

El censo de 1976 no usa REDATAM. Conserva sus columnas originales y
además expone las armonizadas `idep`/`iprov` (string `"01"`–`"09"`, como
el resto):

- `idep` / `iprov` — departamento y provincia armonizados (recomendadas)
- `dep` — código de departamento original (1–9, entero)
- `pro` — código de provincia original
- `can` — código de cantón (1976 no tuvo municipios comparables → no hay
  `imun`; el filtro `municipio` se aplica sobre el cantón)

``` r

# Población del censo 1976 en el depto de Cochabamba (código 3)
pob_cbba_76 <- get_poblacion_1976(departamento = "03", verbose = FALSE)

# Ver algunas columnas: p03 = sexo, p04 = edad (p02 es parentesco)
pob_cbba_76 |>
  select(dep, pro, can, sexo = p03, edad = p04) |>
  collect() |>
  head()
#> # A tibble: 6 × 5
#>     dep   pro   can  sexo  edad
#>   <int> <int> <int> <int> <int>
#> 1     3    29     0     1    36
#> 2     3    29     0     2    33
#> 3     3    29     0     2    13
#> 4     3    29     0     2     9
#> 5     3    29     0     1     7
#> 6     3    29     0     1     4
```

``` r

# Viviendas 1976
get_viviendas_1976(departamento = "La Paz")
```

## Consulta básica con dplyr

``` r

# Distribución por sexo en el censo 2012, Pando
get_personas_2012(departamento = "Pando", verbose = FALSE) |>
  count(P24) |>   # P24 = sexo en 2012
  collect() |>
  etiquetar_valores()
#> # A tibble: 2 × 2
#>   P24        n
#>   <fct>  <int>
#> 1 Mujer  50685
#> 2 Hombre 59751

# Nivel educativo en el censo 2001, Pando
get_personas_2001(departamento = "Pando", verbose = FALSE) |>
  count(P39NIV) |>   # P39NIV = nivel de instrucción en 2001
  collect() |>
  arrange(desc(n)) |>
  head(5)
#> # A tibble: 5 × 2
#>   P39NIV     n
#>    <int> <int>
#> 1     13 10973
#> 2     16  9186
#> 3     10  6923
#> 4     15  5741
#> 5     11  5506
```

## Codebook para censos históricos

Cada censo tiene su propio diccionario. Usa `codebook(anio = ...)` o las
funciones cortas:

``` r

# Buscar variables relacionadas con educación en 1992
codebook_1992(buscar = "nivel") |> select(variable, etiqueta, tabla)
#>   variable                                                            etiqueta
#> 1      P12 Ciclo o Nivel más alto que asiste o asistió en la enseñanza regular
#> 2      P13                                          Finalizo ese ciclo o nivel
#> 3      P14                            Ultimo Año o curso aprobado en ese nivel
#>     tabla
#> 1 persona
#> 2 persona
#> 3 persona

# Variable específica en 2001
codebook(variable = "P39NIV", anio = 2001) |> select(variable, etiqueta, tipo)
#>   variable                                 etiqueta       tipo
#> 1   P39NIV Nivel más alto de instrucción que aprobó categorica

# Ver los códigos de una variable categórica
codebook_valores("P24", anio = 2012)   # sexo en 2012
#> # A tibble: 2 × 2
#>   codigo etiqueta
#> * <chr>  <chr>   
#> 1 1      Mujer   
#> 2 2      Hombre
codebook_valores("p03", anio = 1976)   # sexo en 1976
#> # A tibble: 2 × 2
#>   codigo etiqueta
#> * <chr>  <chr>   
#> 1 1      HOMBRE  
#> 2 2      MUJER
```

``` r

# Ver todas las variables del censo 2012
codebook_2012()
```

## Etiquetado de resultados

[`etiquetar_valores()`](https://lab-tecnosocial.github.io/censosbo/reference/etiquetar_valores.md)
y
[`etiquetar_variables()`](https://lab-tecnosocial.github.io/censosbo/reference/etiquetar_variables.md)
detectan automáticamente el censo a partir de los nombres de columna,
por lo que funcionan igual para datos históricos que para el CPV-2024:

``` r

# 1992: detección automática por el nombre de columna "P03"
get_personas_1992(departamento = "Pando", verbose = FALSE) |>
  count(P03) |>
  collect() |>
  etiquetar_valores() |>
  etiquetar_variables()
#> # A tibble: 2 × 2
#>   `Es hombre o mujer`     n
#>   <fct>               <int>
#> 1 Hombre              21090
#> 2 Mujer               16982

# 2012: estado civil
get_personas_2012(departamento = "Pando", verbose = FALSE) |>
  count(P45) |>
  collect() |>
  etiquetar_valores() |>
  etiquetar_variables()
#> # A tibble: 7 × 2
#>   `Estado Civil`                 n
#>   <fct>                      <int>
#> 1 NA                         40625
#> 2 Conviviente o concubina(o) 24850
#> 3 Soltera(o)                 26273
#> 4 Casada(o)                  15016
#> 5 Viuda(o)                    1422
#> 6 Separada(o)                 1588
#> 7 Divorciada(o)                662

# 1976: idioma que habla
get_poblacion_1976(departamento = "Pando", verbose = FALSE) |>
  count(p09) |>
  collect() |>
  etiquetar_valores() |>
  etiquetar_variables()
#> # A tibble: 10 × 2
#>    `IDOMA QUE HABLA`             n
#>    <fct>                     <int>
#>  1 CASTELLANO                24782
#>  2 AUN NO HABLA               8506
#>  3 CASTELLANO CON OTRO         508
#>  4 CASTELLANO/QUECHUA          361
#>  5 CASTELLANO/AYMARA/QUECHUA    48
#>  6 CASTELLANO/AYMARA            92
#>  7 AYMARA                       12
#>  8 OTRO NAT                    182
#>  9 QUECHUA                       1
#> 10 AYMARA/QUECHUA                1
```

Si el data frame tiene muy pocas columnas o solo columnas genéricas,
puedes especificar el año con el argumento `anio`:

``` r

df |> etiquetar_valores(anio = 1992)
df |> etiquetar_variables(anio = 2001)
```

## Consulta SQL con DuckDB

``` r

library(DBI)

# Censo 2012 con DuckDB
con <- get_censo(2012, "persona", departamento = "Pando", as = "duckdb",
                 verbose = FALSE)
#> duckdb keeps downloaded extensions and secrets in a temporary directory:
#> ℹ /tmp/Rtmp731GUu/duckdb
#> This is removed when the R session ends.
#> • Extensions are re-downloaded each session.
#> • Secrets are lost.
#> ℹ Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
#> ℹ Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
#> ℹ See ?duckdb_storage for details and alternatives.

DBI::dbGetQuery(con, "
  SELECT P24 AS sexo, COUNT(*) AS total,
         ROUND(AVG(P25) * 1.0, 1) AS edad_prom
  FROM persona
  GROUP BY P24
  ORDER BY P24
")
#>   sexo total edad_prom
#> 1    1 50685      22.7
#> 2    2 59751      24.2

DBI::dbDisconnect(con, shutdown = TRUE)
```

Con `as = "duckdb"` la tabla se registra con el nombre que se pasó en
`tabla` (`persona`, `vivienda`, …). En el CPV-2024 el nombre va en
plural (`personas`, `viviendas`), porque `get_censo(2024, ...)` delega
en
[`get_personas_2024()`](https://lab-tecnosocial.github.io/censosbo/reference/get_personas_2024.md).

## Selección de variables

Con `variables` se piden solo las columnas necesarias. Las columnas
geográficas que existan en la tabla (`idep`, `iprov`, `imun` y, en el
CPV-2024, `i00`) se añaden **siempre**, haya o no filtro por
departamento: son la clave para agregar por territorio y para unir
tablas.

``` r

# Censo 2012: solo sexo, edad y nivel educativo
get_personas_2012(
  departamento = "Pando",
  variables    = c("P24", "P25", "P37A_NIVELNUE"),
  verbose      = FALSE
) |>
  names()
#> [1] "idep"          "iprov"         "imun"          "P24"          
#> [5] "P25"           "P37A_NIVELNUE"

# El censo 1976 no tiene imun (usó cantones): solo se añaden idep e iprov
get_poblacion_1976(
  departamento = "Pando",
  variables    = c("p03", "p04"),
  verbose      = FALSE
) |>
  names()
#> [1] "idep"  "iprov" "p03"   "p04"
```

## Comparación entre dos censos (mismo año de referencia)

``` r

# Distribución de sexo en 2012 y 2024 para Pando
dep <- "Pando"

sexo_2012 <- get_personas_2012(departamento = dep, verbose = FALSE) |>
  count(sexo = P24) |>
  collect() |>
  mutate(anio = 2012L)

sexo_2024 <- get_personas_2024(departamento = dep, verbose = FALSE) |>
  count(sexo = p25_sexo) |>
  collect() |>
  mutate(anio = 2024L)

bind_rows(sexo_2012, sexo_2024) |>
  arrange(anio, sexo)
#> # A tibble: 4 × 3
#>    sexo     n  anio
#>   <int> <int> <int>
#> 1     1 50685  2012
#> 2     2 59751  2012
#> 3     1 63355  2024
#> 4     2 70839  2024
```

Los códigos de `sexo` coinciden por casualidad en 2012 y 2024 (1 =
Mujer, 2 = Hombre), pero en 1976, 1992 y 2001 están invertidos. Para
comparar entre censos sin revisar los códigos año por año, usa
[`get_temporal()`](https://lab-tecnosocial.github.io/censosbo/reference/get_temporal.md)
(ver la viñeta **[Análisis
temporal](https://lab-tecnosocial.github.io/censosbo/articles/analisis-temporal.md)**).

Para comparaciones sistemáticas entre múltiples censos con variables
armonizadas, ver la viñeta **[Análisis
temporal](https://lab-tecnosocial.github.io/censosbo/articles/analisis-temporal.md)**.

## Metadatos de los cuatro censos históricos

Para los cuatro, además del diccionario de microdatos, el paquete
incorpora los diccionarios DDI del catálogo ANDA del INE (estudios 8,
10, 47 y 46). Eso añade tres cosas que no estaban:

``` r

# El tema de cada variable, con el mismo vocabulario que el CPV-2024
codebook(tema = "educacion", tabla = "persona", anio = 2012)
codebook(tema = "educacion", tabla = "poblacion", anio = 1976)

# A quién se le preguntó. 2012 es el único censo cuyo DDI no declara filtros de edad;
# 2001, 1992 y 1976 sí los traen
table(codebook(anio = 2001)$universo)

# La agrupación oficial del INE de esa época
table(codebook(anio = 2001)$grupo_ine)

# Definición conceptual y pregunta literal
codebook_docs("P24", anio = 2012, campos = "definicion")
```

Los capítulos (`capitulo`) son la única columna solo-2024: los
cuestionarios anteriores tienen otra estructura, y los de 1976 y 1992
numeran vivienda y persona en paralelo. La columna existe vacía en los
cuatro censos históricos, de modo que
[`codebook()`](https://lab-tecnosocial.github.io/censosbo/reference/codebook.md)
devuelve la misma forma en los cinco años y se pueden combinar sin
fricción.

### Etiquetas de valor completadas

Los DDI traen algunas etiquetas de valor que la extracción de REDATAM no
recuperó, y se usaron para rellenar huecos. La columna `valores_fuente`
indica el origen de cada una (`"redatam"` o `"ddi"`). **Nada
preexistente se sobrescribió**: el contraste reveló que el DDI del INE
tiene errores puntuales —en 2012, la variable de estado civil viene con
las categorías de otra pregunta— así que las discrepancias se registran
para revisión en vez de aplicarse.

En la práctica el aporte fue pequeño: las variables categóricas sin
códigos son claves geográficas y catálogos de ocupación, que no llevan
etiquetas enumerables.

## Tablas complementarias

Los censos 2012, 2001 y 1992 tienen tablas adicionales:

``` r

# Emigración internacional (2012): registros por departamento de origen
get_emigracion_2012(verbose = FALSE) |>
  count(idep) |>
  collect() |>
  etiquetar_geografia() |>
  arrange(desc(n)) |>
  head(5)
#> # A tibble: 5 × 3
#>   idep       n nombre_dep
#>   <chr>  <int> <chr>     
#> 1 02    134713 La Paz    
#> 2 03    113607 Cochabamba
#> 3 07    110987 Santa Cruz
#> 4 05     42867 Potosí    
#> 5 01     31356 Chuquisaca

# Discapacidad (2012) y mortalidad (1992), acotadas a un departamento
get_discapacidad_2012(departamento = "Pando", verbose = FALSE) |> nrow()
#> [1] 2747
get_mortalidad_1992(departamento = "Pando", verbose = FALSE) |> nrow()
#> [1] 8401
```
