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
    archivo     = fs::path_file(files$path),
    tamanio     = format(files$size, units = "auto"),
    modificado  = format(files$modification_time, "%Y-%m-%d %H:%M"),
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
  all_files <- fs::dir_ls(cache_dir, recurse = TRUE, type = "file")
  if (length(all_files) == 0) {
    cli::cli_inform("El caché ya está vacío.")
    return(invisible(NULL))
  }
  total_size <- sum(fs::file_size(all_files))
  if (ask) {
    resp <- readline(sprintf(
      "¿Eliminar %s de caché en %s? [s/N] ",
      format(total_size, units = "auto", standard = "SI"),
      cache_dir
    ))
    if (!tolower(trimws(resp)) %in% c("s", "si", "sí", "y", "yes")) {
      cli::cli_inform("Operación cancelada.")
      return(invisible(NULL))
    }
  }
  fs::dir_delete(cache_dir)
  cli::cli_alert_success("Caché eliminado ({format(total_size, units = 'auto', standard = 'SI')}).")
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
