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
#' # Cambiar a un directorio local (solo para la sesión actual)
#' \dontrun{
#' options(censosbo.cache_dir = "data/censosbo")
#' censosbo_cache_dir()
#' }
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
    cli::cli_inform("El directorio de caché no existe aún: {.path {cache_dir}}")
    return(invisible(NULL))
  }
  files <- fs::dir_info(cache_dir, recurse = TRUE, type = "file")
  if (nrow(files) == 0) {
    cli::cli_inform("El caché está vacío. Usa {.code get_personas_2024()} o {.code get_censo()} para descargar datos.")
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
    cli::cli_inform("No hay caché que limpiar.")
    return(invisible(NULL))
  }
  # Borrar SOLO los parquets de censosbo. El directorio de caché es configurable
  # (opción censosbo.cache_dir) y puede apuntar a una carpeta del proyecto con
  # otros archivos del usuario: un dir_delete() del directorio raíz los perdería.
  parquets <- fs::dir_ls(cache_dir, recurse = TRUE, type = "file", glob = "*.parquet")
  if (length(parquets) == 0) {
    cli::cli_inform("El caché ya está vacío (no hay archivos {.file .parquet}).")
    return(invisible(NULL))
  }
  total_size <- sum(fs::file_size(parquets))
  if (ask) {
    resp <- readline(sprintf(
      "¿Eliminar %s en %d archivo(s) Parquet de caché en %s? [s/N] ",
      format(total_size, units = "auto", standard = "SI"),
      length(parquets),
      cache_dir
    ))
    if (!tolower(trimws(resp)) %in% c("s", "si", "sí", "y", "yes")) {
      cli::cli_inform("Operación cancelada.")
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
    "Caché eliminado: {length(parquets)} archivo(s), {format(total_size, units = 'auto', standard = 'SI')}."
  )
  invisible(NULL)
}

#' Actualiza el paquete censosbo y limpia el caché
#'
#' Reinstala la última versión de `censosbo` desde GitHub y elimina el caché
#' local de datos Parquet, para que los datos se vuelvan a descargar en su
#' versión más reciente. Útil cuando se publica una nueva versión que incluye
#' correcciones en los datos o nuevas variables.
#'
#' @param clear_cache Lógico. Si `TRUE` (defecto), limpia el caché local
#'   automáticamente tras actualizar el paquete. Usa `FALSE` solo si quieres
#'   conservar los archivos descargados.
#' @return Invisible `NULL`.
#' @export
#' @examples
#' \dontrun{
#' # Actualizar paquete y limpiar caché (recomendado)
#' update_censosbo()
#'
#' # Solo actualizar el paquete sin tocar el caché
#' update_censosbo(clear_cache = FALSE)
#' }
update_censosbo <- function(clear_cache = TRUE) {
  if (!requireNamespace("remotes", quietly = TRUE)) {
    cli::cli_abort(
      "El paquete {.pkg remotes} es necesario para actualizar censosbo.
       Instálalo con: {.code install.packages('remotes')}"
    )
  }
  cli::cli_h1("Actualizando censosbo")
  cli::cli_alert_info("Instalando la última versión desde GitHub...")
  remotes::install_github("lab-tecnosocial/censosbo", quiet = FALSE)
  cli::cli_alert_success("Paquete actualizado.")
  if (clear_cache) {
    cli::cli_alert_warning(
      "Se eliminará el caché local para que los datos se descarguen en su versión más reciente."
    )
    censosbo_cache_clear(ask = FALSE)
  }
  cli::cli_alert_success(
    "Listo. Reinicia R y vuelve a cargar el paquete con {.code library(censosbo)}."
  )
  invisible(NULL)
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
