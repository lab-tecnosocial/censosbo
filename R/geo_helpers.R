#' Tabla de geografía de Bolivia
#'
#' Tabla con los 343 municipios de Bolivia y sus códigos geográficos oficiales
#' del CPV-2024, extraídos del diccionario Redatam del INE.
#'
#' @format Un data.frame con 343 filas y 6 columnas:
#' \describe{
#'   \item{idep}{Código de departamento (2 dígitos, con cero a la izquierda)}
#'   \item{nombre_dep}{Nombre del departamento}
#'   \item{iprov}{Código de provincia}
#'   \item{nombre_prov}{Nombre de la provincia}
#'   \item{imun}{Código de municipio}
#'   \item{nombre_mun}{Nombre del municipio}
#' }
#' @source INE Bolivia, CPV-2024. Diccionario de variables Redatam (CEN24.dicX).
"geo_bolivia"

#' Lista los departamentos de Bolivia
#'
#' @return Un [tibble][dplyr::tibble] con columnas `idep` y `nombre_dep`.
#' @export
#' @examples
#' departamentos()
departamentos <- function() {
  res <- unique(geo_bolivia[, c("idep", "nombre_dep")])
  dplyr::as_tibble(`rownames<-`(res, NULL))
}

#' Lista las provincias de un departamento
#'
#' @param departamento Código (e.g., `"07"`) o nombre (e.g., `"Santa Cruz"`)
#'   del departamento. Acepta vectores.
#' @return Un [tibble][dplyr::tibble] con columnas `idep`, `nombre_dep`, `iprov`,
#'   `nombre_prov`.
#' @export
#' @examples
#' provincias("Santa Cruz")
#' provincias("02")
provincias <- function(departamento) {
  dep_codes <- .resolve_dep_codes(departamento)
  geo <- geo_bolivia[geo_bolivia$idep %in% dep_codes, ]
  res <- unique(geo[, c("idep", "nombre_dep", "iprov", "nombre_prov")])
  dplyr::as_tibble(`rownames<-`(res, NULL))
}

#' Lista los municipios de Bolivia
#'
#' @param departamento Código o nombre del departamento. Opcional.
#' @param provincia Código o nombre de provincia. Opcional.
#' @return Un [tibble][dplyr::tibble] con columnas `idep`, `nombre_dep`, `iprov`,
#'   `nombre_prov`, `imun`, `nombre_mun`.
#' @export
#' @examples
#' municipios(departamento = "Cochabamba")
#' municipios(departamento = "Cochabamba", provincia = "Cercado")
municipios <- function(departamento = NULL, provincia = NULL) {
  geo <- geo_bolivia
  if (!is.null(departamento)) {
    dep_codes <- .resolve_dep_codes(departamento)
    geo <- geo[geo$idep %in% dep_codes, ]
  }
  if (!is.null(provincia)) {
    geo <- .match_geo_level(geo, provincia, "iprov", "nombre_prov",
                            "provincia", "provincias(departamento)")
  }
  dplyr::as_tibble(`rownames<-`(geo, NULL))
}

#' Añade nombres geográficos legibles a los microdatos
#'
#' Une un data frame de microdatos con [geo_bolivia] para agregar los nombres
#' de departamento, provincia y municipio (`nombre_dep`, `nombre_prov`,
#' `nombre_mun`) a partir de los códigos geográficos (`idep`, `iprov`, `imun`).
#' Es el equivalente geográfico de [etiquetar_valores()] y evita el `left_join`
#' manual con [municipios()] que antes hacía falta para trabajar por municipio.
#'
#' @param df Un data.frame ya materializado (tras `collect()`) que contenga al
#'   menos la columna `idep`. El nivel de detalle se detecta automáticamente
#'   según las columnas presentes: solo `idep` agrega `nombre_dep`; `idep`+`iprov`
#'   agrega también `nombre_prov`; `idep`+`iprov`+`imun` agrega los tres.
#'
#' @return El mismo `df` con las columnas de nombre añadidas. Si ya existían
#'   columnas de nombre, se reemplazan.
#'
#' @details
#' Los códigos se normalizan a 2 dígitos antes de unir, por lo que funciona
#' aunque `idep`/`iprov`/`imun` vengan como enteros. Los nombres provienen de la
#' geografía del CPV-2024 ([geo_bolivia]); en censos históricos algunos códigos
#' de municipio pueden no tener correspondencia y quedar como `NA`.
#'
#' @seealso [etiquetar_valores()], [municipios()]
#' @export
#' @examples
#' \dontrun{
#' library(dplyr)
#' get_personas_2024(departamento = "Cochabamba") |>
#'   count(idep, iprov, imun) |>
#'   collect() |>
#'   etiquetar_geografia()
#' }
etiquetar_geografia <- function(df) {
  cols <- names(df)
  if (!"idep" %in% cols) {
    cli::cli_abort(c(
      "El data frame no tiene la columna {.field idep}.",
      "i" = "Usa microdatos con c\u00f3digos geogr\u00e1ficos (p.ej. de {.fn get_personas_2024})."
    ))
  }

  key <- intersect(c("idep", "iprov", "imun"), cols)
  name_cols <- c(idep = "nombre_dep", iprov = "nombre_prov", imun = "nombre_mun")
  keep_names <- unname(name_cols[key])

  # Normaliza las claves a código de 2 dígitos (acepta enteros o cadenas).
  for (k in key) df[[k]] <- .pad2(df[[k]])

  # Elimina columnas de nombre preexistentes para evitar sufijos .x/.y en el join.
  df <- df[, setdiff(names(df), keep_names), drop = FALSE]

  lookup <- dplyr::as_tibble(unique(geo_bolivia[, c(key, keep_names)]))
  dplyr::left_join(df, lookup, by = key)
}

#' Geometrías de los departamentos de Bolivia
#'
#' Objeto `sf` con los 9 departamentos de Bolivia y sus geometrías poligonales.
#' Compatible con `ggplot2::geom_sf()` y la función [mapa_dep()].
#'
#' @format Un `sf` data.frame con 9 filas y 3 columnas (más geometría):
#' \describe{
#'   \item{idep}{Código de departamento (2 dígitos, con cero a la izquierda)}
#'   \item{nombre_dep}{Nombre del departamento}
#'   \item{geometry}{Geometría de polígono (CRS: WGS84 / EPSG:4326)}
#' }
#' @source Derivado por disolución de [geo_municipios], de modo que los bordes
#'   departamentales coinciden exactamente con los municipales.
#' @seealso [geo_municipios], [mapa_dep()]
"geo_departamentos"

#' Geometrías de los municipios de Bolivia
#'
#' Objeto `sf` con los 343 municipios del CPV-2024 y sus geometrías poligonales,
#' incluidos los cuatro Gobiernos Autónomos Indígena Originario Campesinos
#' (GAIOC) creados entre 2016 y 2023.
#'
#' @format Un `sf` data.frame con 343 filas y 8 columnas (más geometría):
#' \describe{
#'   \item{idep}{Código de departamento}
#'   \item{nombre_dep}{Nombre del departamento}
#'   \item{iprov}{Código de provincia}
#'   \item{nombre_prov}{Nombre de la provincia}
#'   \item{imun}{Código de municipio}
#'   \item{nombre_mun}{Nombre del municipio}
#'   \item{capital}{Capital del municipio}
#'   \item{superficie_km2}{Superficie en kilómetros cuadrados}
#'   \item{geometry}{Geometría de polígono (CRS: WGS84 / EPSG:4326)}
#' }
#' @details
#' Las geometrías están simplificadas preservando la topología, así que los
#' bordes entre municipios vecinos son idénticos y no quedan franjas vacías
#' entre ellos. Los únicos huecos interiores del país son cuerpos de agua
#' excluidos de la división municipal: el Salar de Uyuni y los lagos Poopó y
#' Uru Uru.
#'
#' Los códigos `idep`/`iprov`/`imun` se verificaron uno a uno contra los puntos
#' de comunidades del CPV-2024 ([get_geo_comunidades()]) y contra la población
#' municipal de los microdatos, que coincide exactamente en los 343 municipios.
#'
#' @source Varias fuentes, detalladas en la viñeta *Mapas coropléticos*.
#'   Límites, capital y superficie: SDSN Bolivia (2025), *Límites Municipales
#'   Bolivia 2025* \[Archivo shapefile\], <https://sdsnbolivia.org/datos-espaciales/>.
#'   Códigos y nombres: INE Bolivia (Redatam, CPV-2024).
#' @seealso [geo_departamentos], [mapa_mun()], [geo_bolivia]
"geo_municipios"
