#' Descarga un archivo Parquet desde GitHub Releases
#'
#' @param filename Nombre del archivo (e.g., `"persona_dep07.parquet"`)
#' @param overwrite Lógico. Si `TRUE`, re-descarga aunque exista en caché.
#' @param verbose Lógico. Mostrar progreso.
#' @return Ruta local al archivo (invisible).
#' @keywords internal
.download_parquet <- function(filename, overwrite = FALSE, verbose = TRUE) {
  dest <- .cache_path(filename)

  if (.is_cached(filename) && !overwrite) {
    if (verbose) {
      cli::cli_inform(c("v" = "Usando caché: {.file {filename}}"))
    }
    return(invisible(as.character(dest)))
  }

  fs::dir_create(fs::path_dir(dest), recurse = TRUE)
  url <- paste0(.CENSOSBO_BASE_URL, filename)

  # Estimar tamaño para el mensaje
  key <- tools::file_path_sans_ext(filename)
  est_mb <- .PARQUET_SIZE_MB[[key]]
  size_msg <- if (!is.null(est_mb)) paste0(" (~", est_mb, " MB)") else ""

  if (verbose) {
    cli::cli_progress_step(
      "Descargando {.file {filename}}{size_msg}...",
      msg_done = "Descargado {.file {filename}}"
    )
  }

  tryCatch(
    curl::curl_download(url, as.character(dest), quiet = TRUE),
    error = function(e) {
      if (fs::file_exists(dest)) fs::file_delete(dest)
      cli::cli_abort(c(
        "Error al descargar {.file {filename}}.",
        "x" = conditionMessage(e),
        "i" = "Verifica tu conexión o que el release {.val {.CENSOSBO_RELEASE_TAG}} exista en GitHub."
      ))
    }
  )

  invisible(as.character(dest))
}
