#' Directorio de caché local del paquete
#'
#' @return Ruta al directorio de caché (cadena de caracteres).
#' @export
#' @examples
#' censosbo_cache_dir()
censosbo_cache_dir <- function() {
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
    cli::cli_inform("El caché está vacío. Usa {.code get_personas()} para descargar datos.")
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

.cache_path <- function(filename) {
  fs::path(censosbo_cache_dir(), filename)
}

.is_cached <- function(filename) {
  fs::file_exists(.cache_path(filename))
}
