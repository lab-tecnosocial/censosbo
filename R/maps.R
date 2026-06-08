# ── Funciones internas ────────────────────────────────────────────────────────

# Une datos del usuario con geo_municipios, emite advertencia si faltan geometrías
.geo_join_municipios <- function(datos) {
  geo_keys <- paste(geo_municipios$idep, geo_municipios$iprov, geo_municipios$imun)
  dat_keys <- paste(datos$idep,          datos$iprov,          datos$imun)
  sin_geo  <- sum(!dat_keys %in% geo_keys)
  if (sin_geo > 0) {
    cli::cli_warn(c(
      "{sin_geo} municipio(s) en los datos no tienen geometría disponible.",
      "i" = "Aparecerán como áreas grises en el mapa.",
      "i" = "Son los 7 municipios del CPV-2024 sin cobertura cartográfica en la fuente."
    ))
  }
  idx    <- match(geo_keys, dat_keys)
  result <- geo_municipios
  for (col in setdiff(names(datos), c("idep", "iprov", "imun"))) {
    result[[col]] <- datos[[col]][idx]
  }
  result
}


# Elige escala de color según tipo de variable
.scale_fill_auto <- function(es_categorica, paleta, na_color, etiqueta) {
  if (es_categorica) {
    ggplot2::scale_fill_brewer(palette = paleta, na.value = na_color, name = etiqueta)
  } else {
    ggplot2::scale_fill_distiller(palette = paleta, direction = 1,
                                   na.value = na_color, name = etiqueta)
  }
}

# ── Funciones exportadas ──────────────────────────────────────────────────────

#' Visualiza una variable censal a nivel departamental
#'
#' Genera un mapa coroplético de Bolivia a nivel de departamento.
#'
#' @param datos Data.frame con al menos las columnas `idep` y `variable`.
#'   Típicamente el resultado de una agregación con dplyr.
#' @param variable Nombre (caracter) de la columna a visualizar.
#' @param titulo Título del mapa. Si `NULL`, usa el nombre de la variable.
#' @param etiqueta_fill Etiqueta de la leyenda. Si `NULL`, usa `variable`.
#' @param paleta Paleta de color. Por defecto `"Blues"` (continua) o `"Set3"`
#'   (categórica).
#' @param na_color Color para departamentos sin datos. Por defecto `"grey80"`.
#' @param mostrar_nombres Si `TRUE`, agrega etiquetas con nombres de departamentos.
#'
#' @return Un objeto `ggplot` modificable con capas adicionales de ggplot2.
#'
#' @details
#' Compatible con todos los censos (1976–2024): los 9 departamentos son estables.
#' Para el censo 1976, que usa la columna `dep` en lugar de `idep`, primero
#' convierte: `datos$idep <- sprintf("%02d", datos$dep)`.
#'
#' @importFrom rlang .data
#' @export
#' @examples
#' \dontrun{
#' library(dplyr)
#' pob <- get_personas_2024(as = "tibble") |>
#'   count(idep, name = "poblacion")
#' mapa_dep(pob, "poblacion", titulo = "Población por departamento (CPV-2024)")
#' }
mapa_dep <- function(datos, variable, titulo = NULL, etiqueta_fill = NULL,
                     paleta = NULL, na_color = "grey80", mostrar_nombres = FALSE) {
  rlang::check_installed("ggplot2", reason = "para generar mapas")

  if (!is.character(variable) || length(variable) != 1) {
    cli::cli_abort("{.arg variable} debe ser un nombre de columna (caracter de longitud 1).")
  }
  if (!"idep" %in% names(datos)) {
    cli::cli_abort("Los datos no tienen la columna {.val idep}.")
  }
  if (!variable %in% names(datos)) {
    cli::cli_abort("La columna {.val {variable}} no existe en los datos.")
  }

  idx <- match(geo_departamentos$idep, datos$idep)
  geo_datos <- geo_departamentos
  for (col in setdiff(names(datos), "idep")) geo_datos[[col]] <- datos[[col]][idx]

  titulo_fin <- if (is.null(titulo)) variable else titulo
  etiq_fin   <- if (is.null(etiqueta_fill)) variable else etiqueta_fill

  es_cat <- is.character(geo_datos[[variable]]) || is.factor(geo_datos[[variable]])
  pal    <- if (is.null(paleta)) (if (es_cat) "Set3" else "Blues") else paleta

  p <- ggplot2::ggplot(geo_datos) +
    ggplot2::geom_sf(ggplot2::aes(fill = .data[[variable]]),
                     color = "white", linewidth = 0.3) +
    .scale_fill_auto(es_cat, pal, na_color, etiq_fin) +
    ggplot2::labs(title = titulo_fin) +
    ggplot2::theme_void() +
    ggplot2::theme(
      plot.title      = ggplot2::element_text(hjust = 0.5, size = 13, face = "bold"),
      legend.position = "right"
    )

  if (mostrar_nombres) {
    centroides <- sf::st_centroid(geo_datos)
    p <- p + ggplot2::geom_sf_text(
      data = centroides,
      ggplot2::aes(label = .data$nombre_dep),
      size = 2.5, color = "black"
    )
  }

  p
}

#' Visualiza una variable censal a nivel municipal
#'
#' Genera un mapa coroplético de Bolivia a nivel de municipio.
#'
#' @param datos Data.frame con al menos las columnas `idep`, `iprov`, `imun` y
#'   `variable`. Típicamente el resultado de una agregación con dplyr.
#' @param variable Nombre (caracter) de la columna a visualizar.
#' @param departamento Código o nombre de departamento para limitar el mapa.
#'   Si `NULL` (defecto), muestra Bolivia completa.
#' @param titulo Título del mapa. Si `NULL`, usa el nombre de la variable.
#' @param etiqueta_fill Etiqueta de la leyenda. Si `NULL`, usa `variable`.
#' @param paleta Paleta de color. Por defecto `"Blues"` (continua) o `"Set3"`
#'   (categórica).
#' @param na_color Color para municipios sin datos. Por defecto `"grey80"`.
#' @param mostrar_nombres Si `TRUE`, agrega etiquetas de nombres de municipios.
#'   Recomendado solo al filtrar por un departamento.
#'
#' @return Un objeto `ggplot` modificable con capas adicionales de ggplot2.
#'
#' @details
#' Los datos se unen con [geo_municipios] por la clave `idep + iprov + imun`.
#' Los 7 municipios del CPV-2024 sin cobertura cartográfica generan una
#' advertencia informativa y aparecen en gris (`na_color`).
#'
#' Para el censo 1976 (cantones), usar con precaución: los códigos de municipio
#' pueden no corresponder a la división actual.
#'
#' @importFrom rlang .data
#' @export
#' @examples
#' \dontrun{
#' library(dplyr)
#' agua <- get_viviendas_2024(departamento = "07", as = "tibble") |>
#'   group_by(idep, iprov, imun) |>
#'   summarise(pct_agua = mean(v10_agua == 1, na.rm = TRUE) * 100, .groups = "drop")
#' mapa_mun(agua, "pct_agua", departamento = "07",
#'          titulo = "% viviendas con agua por cañería - Santa Cruz (2024)")
#' }
mapa_mun <- function(datos, variable, departamento = NULL,
                     titulo = NULL, etiqueta_fill = NULL,
                     paleta = NULL, na_color = "grey80", mostrar_nombres = FALSE) {
  rlang::check_installed("ggplot2", reason = "para generar mapas")

  if (!is.character(variable) || length(variable) != 1) {
    cli::cli_abort("{.arg variable} debe ser un nombre de columna (caracter de longitud 1).")
  }
  claves <- c("idep", "iprov", "imun")
  faltantes <- setdiff(claves, names(datos))
  if (length(faltantes) > 0) {
    cli::cli_abort(c(
      "Los datos no tienen las columnas geográficas: {.val {faltantes}}",
      "i" = "Asegúrate de que tus datos incluyan {.val idep}, {.val iprov} e {.val imun}."
    ))
  }
  if (!variable %in% names(datos)) {
    cli::cli_abort("La columna {.val {variable}} no existe en los datos.")
  }

  geo_base <- geo_municipios
  dat <- datos
  if (!is.null(departamento)) {
    dep_codes <- .resolve_dep_codes(departamento)
    geo_base  <- geo_base[geo_base$idep %in% dep_codes, ]
    dat       <- dat[dat$idep %in% dep_codes, ]
  }

  # Join con advertencias sobre municipios sin geometría
  geo_datos <- .geo_join_municipios(dat)
  if (!is.null(departamento)) {
    dep_codes <- .resolve_dep_codes(departamento)
    geo_datos <- geo_datos[geo_datos$idep %in% dep_codes, ]
  }

  titulo_fin <- if (is.null(titulo)) variable else titulo
  etiq_fin   <- if (is.null(etiqueta_fill)) variable else etiqueta_fill

  es_cat <- is.character(geo_datos[[variable]]) || is.factor(geo_datos[[variable]])
  pal    <- if (is.null(paleta)) (if (es_cat) "Set3" else "Blues") else paleta

  p <- ggplot2::ggplot(geo_datos) +
    ggplot2::geom_sf(ggplot2::aes(fill = .data[[variable]]),
                     color = "white", linewidth = 0.1) +
    .scale_fill_auto(es_cat, pal, na_color, etiq_fin) +
    ggplot2::labs(title = titulo_fin) +
    ggplot2::theme_void() +
    ggplot2::theme(
      plot.title      = ggplot2::element_text(hjust = 0.5, size = 13, face = "bold"),
      legend.position = "right"
    )

  if (mostrar_nombres) {
    con_datos <- geo_datos[!is.na(geo_datos[[variable]]), ]
    centroides <- sf::st_centroid(con_datos)
    p <- p + ggplot2::geom_sf_text(
      data = centroides,
      ggplot2::aes(label = .data$nombre_mun),
      size = 1.8, color = "black"
    )
  }

  p
}

