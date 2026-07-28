# Datos agregados del CPV-2024 por manzano urbano y comunidad rural.
#
# A diferencia de las tablas de microdatos, estas no vienen de los archivos de
# microdato del INE sino de las "fichas resumen" que publica el geoportal para
# cada unidad censal. Son conteos ya agregados, no registros individuales.

# Traduce el argumento `area` a los códigos con que se almacena (1 = Urbana,
# 2 = Rural, el mismo dominio que la variable `area` de los microdatos) y filtra.
# Se aceptan las palabras porque son mucho más legibles en el código del usuario.
.AREA_CODES <- c(urbano = 1L, urbana = 1L, rural = 2L, "1" = 1L, "2" = 2L)

.apply_area <- function(ds, area) {
  if (is.null(area)) return(ds)
  claves <- tolower(trimws(as.character(area)))
  codigos <- unname(.AREA_CODES[claves])
  if (anyNA(codigos)) {
    cli::cli_abort(c(
      "Valor de {.arg area} no reconocido: {.val {area[is.na(codigos)]}}",
      "i" = "Usa {.val urbano} o {.val rural} (o los códigos {.val 1} y {.val 2})."
    ))
  }
  codigos <- unique(codigos)
  dplyr::filter(ds, .data$area %in% !!codigos)
}

#' Accede al universo de unidades censales del CPV-2024
#'
#' Devuelve todas las unidades censales de Bolivia —manzanos urbanos y
#' comunidades rurales— con su población, sus viviendas y si el INE libera su
#' ficha de indicadores. Es el nivel geográfico más fino disponible del Censo
#' 2024: 268.604 unidades, frente a los 343 municipios de las demás funciones.
#'
#' @param departamento Nombre o código del departamento (e.g., `"Cochabamba"`
#'   o `"03"`). `NULL` (defecto) devuelve todo el país.
#' @param provincia Nombre o código de la provincia. Opcional.
#' @param municipio Nombre o código del municipio. Opcional.
#' @param area Filtra por tipo de unidad: `"urbano"` (manzanos) o `"rural"`
#'   (comunidades). `NULL` (defecto) devuelve ambas. La columna `area` se
#'   almacena con el mismo código que en los microdatos (1 = Urbana,
#'   2 = Rural), así que también acepta `1` o `2`.
#' @param variables Vector de nombres de variables a devolver. Las columnas
#'   geográficas se conservan siempre. `NULL` (defecto) devuelve todas.
#' @param as Formato de retorno: `"arrow"` (por defecto), `"tibble"` o
#'   `"duckdb"` (tabla `"unidades"`).
#' @param overwrite Lógico. Si `TRUE`, re-descarga aunque exista en caché.
#' @param verbose Lógico. Mostrar progreso.
#'
#' @return Un `Dataset` de arrow, un `tibble` o una conexión DuckDB, según `as`.
#'
#' @details
#' La columna `ficha` indica si esta unidad tiene indicadores en
#' [get_fichas_2024()]. El INE no publica la ficha de las unidades con poca
#' población, por reserva estadística: deja fuera al 47% de los manzanos, pero
#' las 150.744 unidades con ficha cubren el 92% de la población, porque las
#' excluidas son las pequeñas.
#'
#' Los códigos de unidad (`codigo`) no son jerárquicos: no contienen el
#' departamento ni el municipio. Por eso las columnas `idep`, `iprov` e `imun`
#' vienen desnormalizadas, y se pueden etiquetar con [etiquetar_geografia()].
#'
#' La columna `personas` agregada por municipio coincide **exactamente** con
#' [get_personas_2024()] en los 343 municipios. En cambio `viviendas` da un
#' 0,23% menos que [get_viviendas_2024()] (4.480.201 frente a 4.490.488): el
#' déficit es sistemático —323 municipios por debajo, ninguno por encima— y
#' procede del propio INE, que cuenta las viviendas de forma distinta en el
#' geoportal y en los microdatos. Para el total de viviendas de un territorio
#' conviene usar [get_viviendas_2024()].
#'
#' @source
#' Geoportal del INE Bolivia, <https://geoportal.ine.gob.bo/>.
#'
#' @seealso [get_fichas_2024()] para los indicadores, [get_geo_manzanos()] y
#'   [get_geo_comunidades()] para las geometrías.
#'
#' @export
#' @examples
#' \dontrun{
#' # Todas las unidades de Cochabamba
#' get_unidades_2024(departamento = "Cochabamba")
#'
#' # Comunidades rurales de Potosí, con nombres de la geografía
#' library(dplyr)
#' get_unidades_2024(departamento = "Potosí", area = "rural", as = "tibble") |>
#'   etiquetar_geografia()
#'
#' # ¿Qué parte de la población queda cubierta por las fichas?
#' get_unidades_2024(municipio = "Sucre", as = "tibble") |>
#'   summarise(cobertura = sum(personas[ficha]) / sum(personas))
#' }
get_unidades_2024 <- function(
    departamento = NULL,
    provincia    = NULL,
    municipio    = NULL,
    area         = NULL,
    variables    = NULL,
    as           = c("arrow", "tibble", "duckdb"),
    overwrite    = FALSE,
    verbose      = TRUE
) {
  as <- match.arg(as)
  local_path <- .download_ficha("unidad.parquet", overwrite = overwrite, verbose = verbose)
  ds <- arrow::open_dataset(local_path, format = "parquet")
  ds <- .apply_geo_filters(ds, departamento, provincia, municipio)
  ds <- .apply_area(ds, area)
  ds <- .apply_variable_selection(ds, variables)
  .return_as(ds, as, table_name = "unidades", verbose = verbose)
}

#' Accede a los indicadores del CPV-2024 por manzano y comunidad
#'
#' Devuelve las 194 variables de la ficha resumen del INE para cada unidad
#' censal que la tenga disponible: población por edad y sexo, educación, salud,
#' migración, empleo, actividad económica, vivienda, servicios básicos, TIC,
#' materiales de construcción, hacinamiento y tipo de hogar.
#'
#' @inheritParams get_unidades_2024
#' @param as Formato de retorno: `"arrow"` (por defecto), `"tibble"` o
#'   `"duckdb"` (tabla `"fichas"`).
#'
#' @return Ver [get_unidades_2024()].
#'
#' @details
#' Contiene 150.744 unidades: las que el INE libera (`ficha == TRUE` en
#' [get_unidades_2024()]). Para el universo completo, con población y viviendas
#' de todas las unidades, usa esa función.
#'
#' Todas las variables son conteos de personas, viviendas u hogares. Cada bloque
#' temático trae su propio total, que sirve de denominador:
#'
#' \describe{
#'   \item{`pob_*`}{Población por grupo de edad y sexo. Total: `pob_total_*`.}
#'   \item{`edu_*`}{Nivel de instrucción de la población de 19 o más años.}
#'   \item{`salud_lugar_*`}{Dónde acude por problemas de salud. **Respuesta
#'     múltiple**: las categorías suman más que el total.}
#'   \item{`salud_seguro_*`}{Registro al SUS o afiliación a seguros.}
#'   \item{`nac_*`, `res_*`}{Lugar de nacimiento y residencia habitual.}
#'   \item{`ocup_*`, `act_*`}{Categoría ocupacional y actividad económica de la
#'     población de 14 o más años.}
#'   \item{`viv_*`}{Tipo, condición de ocupación y tenencia de la vivienda.}
#'   \item{`serv_*`}{Energía eléctrica, agua, desagüe, combustible y basura.}
#'   \item{`tic_*`}{Equipamiento del hogar. **Respuesta múltiple**.}
#'   \item{`mat_*`}{Material de paredes, revoque, techo y piso.}
#'   \item{`hac_*`}{Hacinamiento por dormitorio: sin, medio o alto.}
#'   \item{`hogar_*`}{Tipología del hogar.}
#' }
#'
#' Los bloques `mat_*`, `hac_*` y `hogar_*` tienen como base las viviendas
#' particulares con personas presentes, es decir `viv_tipo_presentes`.
#'
#' Los sufijos `_h` y `_m` son hombres y mujeres; `_ns` es "sin especificar".
#' Usa `codebook(tabla = "ficha")` para la lista completa con sus etiquetas.
#'
#' @source
#' Geoportal del INE Bolivia, <https://geoportal.ine.gob.bo/>.
#'
#' @export
#' @examples
#' \dontrun{
#' # Acceso a agua por cañería en los manzanos de El Alto
#' library(dplyr)
#' get_fichas_2024(municipio = "El Alto", as = "tibble") |>
#'   mutate(pct_caneria = 100 * serv_agua_caneria / serv_agua_total) |>
#'   select(codigo, pct_caneria)
#'
#' # Solo algunas variables, para no traer las 194
#' get_fichas_2024(departamento = "Oruro",
#'                 variables = c("pob_total_h", "pob_total_m", "tic_internet"))
#' }
get_fichas_2024 <- function(
    departamento = NULL,
    provincia    = NULL,
    municipio    = NULL,
    area         = NULL,
    variables    = NULL,
    as           = c("arrow", "tibble", "duckdb"),
    overwrite    = FALSE,
    verbose      = TRUE
) {
  as <- match.arg(as)
  local_path <- .download_ficha("ficha.parquet", overwrite = overwrite, verbose = verbose)
  ds <- arrow::open_dataset(local_path, format = "parquet")
  ds <- .apply_geo_filters(ds, departamento, provincia, municipio)
  ds <- .apply_area(ds, area)
  ds <- .apply_variable_selection(ds, variables)
  .return_as(ds, as, table_name = "fichas", verbose = verbose)
}

# Lee uno o más Parquet de geometrías y los convierte en un objeto sf.
# La columna `geometria` viene en WKB (EPSG:4326), que sf lee directamente.
.leer_geometrias <- function(paths, geo) {
  rlang::check_installed("sf", reason = "para trabajar con geometrías")

  ds <- arrow::open_dataset(paths, format = "parquet")
  # `filter_dep = TRUE` es imprescindible aquí: las comunidades van en un único
  # archivo nacional, así que sin este filtro `departamento = "Pando"` devolvía
  # las 21.175 del país. En los manzanos es redundante —el departamento ya
  # decidió qué archivos se abren— pero inocuo.
  ds <- .apply_geo(ds, geo, filter_dep = TRUE)
  df <- dplyr::collect(ds)

  if (nrow(df) == 0) {
    cli::cli_warn(c(
      "El filtro geográfico no devolvió ninguna unidad.",
      "i" = "Revisa los nombres con {.code municipios()}."
    ))
  }

  df$geometria <- sf::st_as_sfc(structure(df$geometria, class = "WKB"), EWKB = FALSE)
  sf::st_as_sf(df, sf_column_name = "geometria", crs = 4326)
}

#' Descarga las geometrías de los manzanos urbanos del CPV-2024
#'
#' @inheritParams get_unidades_2024
#'
#' @return Un objeto `sf` con columnas `codigo`, `nombre`, `idep`, `iprov`,
#'   `imun` y `geometria` (polígonos, EPSG:4326).
#'
#' @details
#' Los archivos están partidos por departamento (0,3 a 6,7 MB cada uno). Sin el
#' argumento `departamento` se descargan los nueve, unos 25 MB en total; para
#' un mapa de un municipio conviene acotar.
#'
#' @seealso [mapa_man()] para dibujarlas, [get_geo_comunidades()] para el área
#'   rural.
#'
#' @export
#' @examples
#' \dontrun{
#' manzanos <- get_geo_manzanos(municipio = "Sucre")
#' plot(manzanos["nombre"])
#' }
get_geo_manzanos <- function(
    departamento = NULL,
    provincia    = NULL,
    municipio    = NULL,
    overwrite    = FALSE,
    verbose      = TRUE
) {
  geo <- .resolve_geo(departamento, provincia, municipio)
  deps <- if (is.null(geo$dep_codes)) sprintf("%02d", 1:9) else geo$dep_codes

  if (verbose && is.null(geo$dep_codes)) {
    cli::cli_inform(c(
      "i" = "Descargando geometrías de {length(deps)} departamento{?s} (~25 MB).",
      " " = "Para descargar menos usa el argumento {.arg departamento}."
    ))
  }

  paths <- vapply(sprintf("geo_manzano_dep%s.parquet", deps), function(f) {
    .download_ficha(f, overwrite = overwrite, verbose = verbose)
  }, character(1))

  .leer_geometrias(paths, geo)
}

#' Descarga las geometrías de las comunidades rurales del CPV-2024
#'
#' @inheritParams get_unidades_2024
#'
#' @return Un objeto `sf` con columnas `codigo`, `nombre`, `idep`, `iprov`,
#'   `imun` y `geometria` (EPSG:4326).
#'
#' @details
#' El INE publica la mayoría de las comunidades rurales como **puntos** (un
#' centro aproximado), no como polígonos. Para mapas de coropletas rurales no
#' hay superficie que rellenar: conviene usar [ggplot2::geom_sf()] con puntos
#' graduados por tamaño o color.
#'
#' @export
#' @examples
#' \dontrun{
#' comunidades <- get_geo_comunidades(departamento = "Pando")
#' plot(comunidades["nombre"])
#' }
get_geo_comunidades <- function(
    departamento = NULL,
    provincia    = NULL,
    municipio    = NULL,
    overwrite    = FALSE,
    verbose      = TRUE
) {
  geo  <- .resolve_geo(departamento, provincia, municipio)
  path <- .download_ficha("geo_comunidad.parquet", overwrite = overwrite, verbose = verbose)
  .leer_geometrias(path, geo)
}
