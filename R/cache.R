#' Directorio de caché local del paquete
#'
#' Devuelve la ruta donde se guardan los archivos Parquet descargados.
#' Por defecto usa el directorio estándar del sistema operativo, pero puede
#' redirigirse a cualquier ruta local (por ejemplo, dentro del proyecto actual)
#' estableciendo la opción `censosbo.cache_dir` antes de llamar a `get_*()`.
#'
#' @return Ruta al directorio de caché (cadena de caracteres).
#'
#' @details
#' Para guardar el caché dentro de tu proyecto en lugar del directorio del
#' sistema, añade esto al inicio de tu script o en tu `.Rprofile`:
#'
#' ```r
#' options(censosbo.cache_dir = "data/censosbo")
#' ```
#'
#' El directorio se crea automáticamente si no existe.
#'
#' @export
#' @examples
#' censosbo_cache_dir()
#'
#' # Redirigir el caché a una carpeta del proyecto
#' anterior <- options(censosbo.cache_dir = file.path(tempdir(), "censosbo"))
#' censosbo_cache_dir()
#' options(anterior)
censosbo_cache_dir <- function() {
  opt <- getOption("censosbo.cache_dir", default = NULL)
  if (!is.null(opt)) return(as.character(opt))
  tools::R_user_dir("censosbo", which = "cache")
}

#' Información sobre los archivos en caché
#'
#' Muestra los archivos Parquet descargados localmente, con sus tamaños
#' y fechas de descarga.
#'
#' @return Un data.frame con columnas `archivo`, `tamanio` y `modificado`,
#'   o `NULL` invisible si el caché está vacío.
#' @export
#' @examples
#' censosbo_cache_info()
censosbo_cache_info <- function() {
  cache_dir <- censosbo_cache_dir()
  if (!fs::dir_exists(cache_dir)) {
    cli::cli_inform("El directorio de cach\u00e9 no existe a\u00fan: {.path {cache_dir}}")
    return(invisible(NULL))
  }
  files <- fs::dir_info(cache_dir, recurse = TRUE, type = "file")
  if (nrow(files) == 0) {
    cli::cli_inform("El cach\u00e9 est\u00e1 vac\u00edo. Usa {.code get_personas_2024()} o {.code get_censo()} para descargar datos.")
    return(invisible(NULL))
  }
  result <- data.frame(
    archivo    = as.character(fs::path_rel(files$path, start = cache_dir)),
    tamanio    = format(files$size, units = "auto"),
    modificado = format(files$modification_time, "%Y-%m-%d %H:%M"),
    stringsAsFactors = FALSE
  )
  result
}

#' Limpia el caché local de datos
#'
#' Elimina todos los archivos Parquet descargados localmente. Los datos
#' se pueden volver a descargar usando las funciones `get_*()`.
#'
#' @param ask Lógico. Si `TRUE` (defecto), pide confirmación antes de borrar.
#' @return Invisible `NULL`.
#' @export
#' @examples
#' \dontrun{
#' censosbo_cache_clear()
#' }
censosbo_cache_clear <- function(ask = TRUE) {
  cache_dir <- censosbo_cache_dir()
  if (!fs::dir_exists(cache_dir)) {
    cli::cli_inform("No hay cach\u00e9 que limpiar.")
    return(invisible(NULL))
  }
  # Borrar SOLO los parquets de censosbo. El directorio de caché es configurable
  # (opción censosbo.cache_dir) y puede apuntar a una carpeta del proyecto con
  # otros archivos del usuario: un dir_delete() del directorio raíz los perdería.
  parquets <- fs::dir_ls(cache_dir, recurse = TRUE, type = "file", glob = "*.parquet")
  if (length(parquets) == 0) {
    cli::cli_inform("El cach\u00e9 ya est\u00e1 vac\u00edo (no hay archivos {.file .parquet}).")
    return(invisible(NULL))
  }
  total_size <- sum(fs::file_size(parquets))
  if (ask) {
    ok <- .preguntar_si_no(sprintf(
      "\u00bfEliminar %s en %d archivo(s) Parquet de cach\u00e9 en %s? [s/N] ",
      format(total_size, units = "auto", standard = "SI"),
      length(parquets),
      cache_dir
    ))
    # Borrar es irreversible, asi que sin confirmacion no se borra. Pero cuando no
    # se puede preguntar hay que DECIRLO: antes esto cancelaba en silencio en
    # scripts y CI, y el usuario no tenia forma de saber por que no pasaba nada.
    if (is.na(ok)) {
      cli::cli_abort(c(
        "No se puede pedir confirmaci\u00f3n en una sesi\u00f3n no interactiva.",
        "i" = "Usa {.code censosbo_cache_clear(ask = FALSE)} si de verdad quieres borrar el cach\u00e9."
      ))
    }
    if (!ok) {
      cli::cli_inform("Operaci\u00f3n cancelada.")
      return(invisible(NULL))
    }
  }
  fs::file_delete(parquets)
  # Limpiar los subdirectorios propios del paquete (censos históricos y fichas
  # por manzano/comunidad) si quedaron vacíos.
  for (sub in c("historico", "fichas")) {
    sub_dir <- fs::path(cache_dir, sub)
    if (fs::dir_exists(sub_dir) &&
        length(fs::dir_ls(sub_dir, recurse = TRUE, type = "file")) == 0) {
      fs::dir_delete(sub_dir)
    }
  }
  cli::cli_alert_success(
    "Cach\u00e9 eliminado: {length(parquets)} archivo(s), {format(total_size, units = 'auto', standard = 'SI')}."
  )
  invisible(NULL)
}

# Pregunta sí/no por consola. Devuelve TRUE, FALSE, o NA si no se puede preguntar
# porque la sesión no es interactiva.
#
# Existe como función propia por dos razones. Una: `readline()` en una sesión no
# interactiva devuelve "" sin mostrar nada, así que un `if (resp == "s")` cancela
# en silencio —el usuario ve que no pasó nada y no sabe por qué—. Dos: envolverla
# aquí la hace mockeable en los tests, cosa que `base::readline` no es.
.preguntar_si_no <- function(prompt) {
  if (!rlang::is_interactive()) return(NA)
  resp <- readline(prompt)
  tolower(trimws(resp)) %in% c("s", "si", "s\u00ed", "y", "yes")
}

# Crea el directorio de caché, pidiendo permiso la primera vez.
#
# La política de CRAN no permite escribir de forma persistente fuera del directorio
# temporal de la sesión sin consentimiento del usuario. `tools::R_user_dir()` es la
# ubicación correcta, pero el permiso hay que pedirlo igual.
#
# El contrato importante es lo que hace en una sesión NO interactiva: **procede sin
# preguntar**. De eso dependen los consumidores que corren el paquete headless —la
# app censos-explorer descarga geometrías dentro de un contenedor sin tty—, y un
# prompt que abortara ahí rompería la app en silencio. Hay un test que lo fija.
#
# Tampoco pregunta cuando ya no hace falta: si el directorio existe, el usuario ya
# dijo sí en su día; y si fijó `censosbo.cache_dir`, la ruta la eligió él.
.asegurar_cache_dir <- function(dir_destino) {
  if (fs::dir_exists(dir_destino)) return(invisible(TRUE))

  raiz          <- censosbo_cache_dir()
  ruta_elegida  <- !is.null(getOption("censosbo.cache_dir", default = NULL))
  ya_autorizado <- isTRUE(getOption("censosbo.consent")) || fs::dir_exists(raiz)

  # La condicion incluye is_interactive() para no llegar siquiera a informar ni a
  # preguntar en una sesion sin tty: un "\u00bfquieres crearlo?" impreso en el log de un
  # contenedor, seguido de la creacion igual, es ruido que confunde.
  if (!ruta_elegida && !ya_autorizado && rlang::is_interactive()) {
    cli::cli_inform(c(
      "i" = "censosbo guarda los datos descargados en {.path {raiz}} para no volver a bajarlos.",
      " " = "Se pueden borrar en cualquier momento con {.code censosbo_cache_clear()}."
    ))
    ok <- .preguntar_si_no("\u00bfCrear ese directorio de cach\u00e9? [s/N] ")
    if (isFALSE(ok)) {
      cli::cli_abort(c(
        "Descarga cancelada: sin cach\u00e9 no se pueden servir los datos.",
        "i" = "Para autorizarlo de antemano: {.code options(censosbo.consent = TRUE)}.",
        "i" = "Para usar otra ruta: {.code options(censosbo.cache_dir = \"data/censosbo\")}."
      ))
    }
  }

  fs::dir_create(dir_destino, recurse = TRUE)
  invisible(TRUE)
}

.cache_path <- function(filename, subdir = NULL) {
  if (is.null(subdir)) {
    fs::path(censosbo_cache_dir(), filename)
  } else {
    fs::path(censosbo_cache_dir(), subdir, filename)
  }
}

.is_cached <- function(filename, subdir = NULL) {
  fs::file_exists(.cache_path(filename, subdir = subdir))
}
