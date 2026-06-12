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
#' @return Un data.frame con columnas `idep` y `nombre_dep`.
#' @export
#' @examples
#' departamentos()
departamentos <- function() {
  res <- unique(geo_bolivia[, c("idep", "nombre_dep")])
  `rownames<-`(res, NULL)
}

#' Lista las provincias de un departamento
#'
#' @param departamento Código (e.g., `"07"`) o nombre (e.g., `"Santa Cruz"`)
#'   del departamento. Acepta vectores.
#' @return Un data.frame con columnas `idep`, `nombre_dep`, `iprov`, `nombre_prov`.
#' @export
#' @examples
#' provincias("Santa Cruz")
#' provincias("02")
provincias <- function(departamento) {
  dep_codes <- .resolve_dep_codes(departamento)
  geo <- geo_bolivia[geo_bolivia$idep %in% dep_codes, ]
  res <- unique(geo[, c("idep", "nombre_dep", "iprov", "nombre_prov")])
  `rownames<-`(res, NULL)
}

#' Lista los municipios de Bolivia
#'
#' @param departamento Código o nombre del departamento. Opcional.
#' @param provincia Código de provincia. Opcional.
#' @return Un data.frame con columnas `idep`, `nombre_dep`, `iprov`,
#'   `nombre_prov`, `imun`, `nombre_mun`.
#' @export
#' @examples
#' municipios(departamento = "Cochabamba")
#' municipios(departamento = "02", provincia = "217")
municipios <- function(departamento = NULL, provincia = NULL) {
  geo <- geo_bolivia
  if (!is.null(departamento)) {
    dep_codes <- .resolve_dep_codes(departamento)
    geo <- geo[geo$idep %in% dep_codes, ]
  }
  if (!is.null(provincia)) {
    geo <- geo[geo$iprov %in% as.character(provincia), ]
  }
  `rownames<-`(geo, NULL)
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
#' @source INE Bolivia. Límites administrativos de departamentos,
#'   derivados de cartografía electoral (2025).
#' @seealso [geo_municipios], [mapa_dep()]
"geo_departamentos"

#' Geometrías de los municipios de Bolivia
#'
#' Objeto `sf` con 336 de los 343 municipios del CPV-2024 y sus geometrías
#' poligonales. Los 7 municipios sin cobertura en la fuente cartográfica
#' no están incluidos.
#'
#' @format Un `sf` data.frame con 336 filas y 7 columnas (más geometría):
#' \describe{
#'   \item{idep}{Código de departamento}
#'   \item{nombre_dep}{Nombre del departamento}
#'   \item{iprov}{Código de provincia}
#'   \item{nombre_prov}{Nombre de la provincia}
#'   \item{imun}{Código de municipio}
#'   \item{nombre_mun}{Nombre del municipio}
#'   \item{geometry}{Geometría de polígono (CRS: WGS84 / EPSG:4326)}
#' }
#' @note 7 municipios del CPV-2024 no tienen cobertura cartográfica en la
#'   fuente y no aparecerán en los mapas generados con [mapa_mun()].
#' @source INE Bolivia. Límites administrativos de municipios,
#'   derivados de cartografía electoral (2025).
#' @seealso [geo_departamentos], [mapa_mun()]
"geo_municipios"
