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
  merge(geo_municipios, datos, by = c("idep", "iprov", "imun"), all.x = TRUE)
}

# Resuelve nombre(s) o código(s) de municipio a enteros XXYYZZ del parquet INE
.resolve_mun_codes <- function(municipio, departamento = NULL) {
  if (is.null(municipio)) {
    cli::cli_abort("{.arg municipio} es requerido para {.fn mapa_man}.")
  }

  dep_codes <- if (!is.null(departamento)) .resolve_dep_codes(departamento) else NULL

  codigos <- vapply(as.character(municipio), function(mun) {
    # Si ya es un entero XXYYZZ (5-6 dígitos), usarlo directamente
    if (grepl("^[0-9]{5,6}$", mun)) {
      return(as.integer(mun))
    }
    # Buscar por nombre en geo_bolivia (exacto primero, parcial como fallback)
    base <- if (!is.null(dep_codes)) {
      geo_bolivia[geo_bolivia$idep %in% dep_codes, ]
    } else {
      geo_bolivia
    }
    idx <- which(tolower(base$nombre_mun) == tolower(mun))
    if (length(idx) == 0) {
      idx <- grep(tolower(mun), tolower(base$nombre_mun), fixed = TRUE)
    }
    if (length(idx) == 0) {
      cli::cli_abort(c(
        "Municipio no encontrado: {.val {mun}}",
        "i" = "Usa {.code municipios()} para ver los nombres válidos."
      ))
    }
    if (length(idx) > 1) {
      opciones <- paste0(base$nombre_dep[idx], " / ", base$nombre_prov[idx],
                         " / ", base$nombre_mun[idx])
      cli::cli_abort(c(
        "Nombre ambiguo: {.val {mun}} coincide con varios municipios.",
        "i" = "Especifica {.arg departamento} o usa el nombre completo.",
        "i" = paste0("Coincidencias: ", paste(opciones, collapse = "; "))
      ))
    }
    if (tolower(base$nombre_mun[idx]) != tolower(mun)) {
      cli::cli_inform("Municipio interpretado como: {.val {base$nombre_mun[idx]}}")
    }
    row <- base[idx, ]
    as.integer(paste0(as.integer(row$idep),
                      sprintf("%02d", as.integer(row$iprov)),
                      sprintf("%02d", as.integer(row$imun))))
  }, integer(1))

  unique(codigos)
}

# Lee el parquet de manzanos filtrado por municipio y lo convierte a sf
.read_manzanos <- function(ruta, codigos_mun) {
  df <- arrow::open_dataset(ruta) |>
    dplyr::filter(.data$codigo_municipio %in% codigos_mun) |>
    dplyr::collect()
  if (nrow(df) == 0) {
    cli::cli_abort("No se encontraron manzanos para el/los municipio(s) indicado(s).")
  }
  geo <- df[, setdiff(names(df), "geometry")]
  geo$geometry <- sf::st_as_sfc(df$geometry, crs = 4326)
  sf::st_sf(geo)
}

# Une geometrías de manzanos con datos del usuario por la columna 'codigo'
.geo_join_manzanos <- function(geo_sf, datos) {
  sin_geo <- sum(!datos$codigo %in% geo_sf$codigo)
  if (sin_geo > 0) {
    cli::cli_warn("{sin_geo} manzano(s) en los datos no tienen geometría disponible.")
  }
  merge(geo_sf, datos, by = "codigo", all.x = TRUE)
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

  geo_datos <- merge(geo_departamentos, datos, by = "idep", all.x = TRUE)

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

#' Visualiza una variable censal a nivel de manzano
#'
#' Genera un mapa coroplético a nivel de manzano usando las geometrías del
#' Geoportal INE. Requiere especificar al menos un municipio para limitar
#' la carga de datos (el parquet cubre 247,000 manzanos en todo el país).
#'
#' @param datos Data.frame con al menos las columnas `codigo` (código único
#'   de manzano del INE, formato `"XXXXXXXXXXX-X"`) y `variable`.
#'   Típicamente datos del CPV-2024 agregados a nivel de manzano.
#' @param variable Nombre (caracter) de la columna a visualizar.
#' @param municipio Nombre o código XXYYZZ del municipio a mostrar.
#'   Acepta un vector para mostrar varios municipios a la vez.
#' @param departamento Nombre o código de departamento para resolver nombres
#'   de municipio ambiguos (que existen en más de un departamento).
#' @param titulo Título del mapa. Si `NULL`, genera `"variable — municipio"`.
#' @param etiqueta_fill Etiqueta de la leyenda. Si `NULL`, usa `variable`.
#' @param paleta Paleta de color. Por defecto `"Blues"` (continua) o `"Set3"`
#'   (categórica).
#' @param na_color Color para manzanos sin datos. Por defecto `"grey80"`.
#' @param mostrar_nombres Si `TRUE`, agrega etiquetas con el nombre del manzano
#'   (barrio/zona). Recomendado solo con pocos manzanos.
#' @param overwrite Si `TRUE`, re-descarga el parquet aunque exista en caché.
#'
#' @return Un objeto `ggplot` modificable con capas adicionales de ggplot2.
#'
#' @details
#' Las geometrías provienen del Geoportal INE Bolivia (CPV-2024). El parquet
#' se descarga automáticamente desde GitHub Releases la primera vez y se
#' almacena en caché local ([censosbo_cache_dir()]).
#'
#' La clave de unión entre `datos` y las geometrías es la columna `codigo`
#' del parquet INE (formato `"XXXXXXXXXXX-X"`).
#'
#' @importFrom rlang .data
#' @export
#' @examples
#' \dontrun{
#' library(dplyr)
#' # Obtener códigos de manzano del parquet y crear datos de ejemplo
#' ruta <- censosbo_cache_dir() |> file.path("manzanos_ine.parquet")
#' codigos <- arrow::open_dataset(ruta) |>
#'   filter(codigo_municipio == 20101) |>
#'   collect() |>
#'   pull(codigo)
#' datos <- data.frame(codigo = codigos, valor = runif(length(codigos)))
#' mapa_man(datos, "valor", municipio = "La Paz",
#'          titulo = "Variable aleatoria por manzano - La Paz")
#' }
mapa_man <- function(datos, variable, municipio, departamento = NULL,
                     titulo = NULL, etiqueta_fill = NULL, paleta = NULL,
                     na_color = "grey80", mostrar_nombres = FALSE,
                     overwrite = FALSE) {
  rlang::check_installed("ggplot2", reason = "para generar mapas")

  if (!is.character(variable) || length(variable) != 1) {
    cli::cli_abort("{.arg variable} debe ser un nombre de columna (caracter de longitud 1).")
  }
  if (!"codigo" %in% names(datos)) {
    cli::cli_abort(c(
      "Los datos no tienen la columna {.val codigo}.",
      "i" = "Usa el campo {.val codigo} del parquet de manzanos como clave de unión."
    ))
  }
  if (!variable %in% names(datos)) {
    cli::cli_abort("La columna {.val {variable}} no existe en los datos.")
  }

  codigos_mun <- .resolve_mun_codes(municipio, departamento)
  ruta        <- .download_parquet("manzanos_ine.parquet", overwrite = overwrite)
  geo_sf      <- .read_manzanos(ruta, codigos_mun)
  geo_datos   <- .geo_join_manzanos(geo_sf, datos)

  mun_label  <- paste(as.character(municipio), collapse = ", ")
  titulo_fin <- if (is.null(titulo)) paste0(variable, " — ", mun_label) else titulo
  etiq_fin   <- if (is.null(etiqueta_fill)) variable else etiqueta_fill

  es_cat <- is.character(geo_datos[[variable]]) || is.factor(geo_datos[[variable]])
  pal    <- if (is.null(paleta)) (if (es_cat) "Set3" else "Blues") else paleta

  p <- ggplot2::ggplot(geo_datos) +
    ggplot2::geom_sf(ggplot2::aes(fill = .data[[variable]]),
                     color = "white", linewidth = 0.05) +
    .scale_fill_auto(es_cat, pal, na_color, etiq_fin) +
    ggplot2::labs(title = titulo_fin) +
    ggplot2::theme_void() +
    ggplot2::theme(
      plot.title      = ggplot2::element_text(hjust = 0.5, size = 13, face = "bold"),
      legend.position = "right"
    )

  if (mostrar_nombres) {
    con_datos  <- geo_datos[!is.na(geo_datos[[variable]]), ]
    centroides <- sf::st_centroid(con_datos)
    p <- p + ggplot2::geom_sf_text(
      data = centroides,
      ggplot2::aes(label = .data$nombre),
      size = 1.5, color = "black"
    )
  }

  p
}
