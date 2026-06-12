#' Descarga un archivo Parquet del CPV-2024 desde GitHub Releases
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
      release_tag <- .CENSOSBO_RELEASE_TAG
      cli::cli_abort(c(
        "Error al descargar {.file {filename}}.",
        "x" = conditionMessage(e),
        "i" = "Verifica tu conexión o que el release {.val {release_tag}} exista en GitHub."
      ))
    }
  )

  invisible(as.character(dest))
}

#' Descarga un archivo de un censo histórico desde su GitHub Release
#'
#' @param anio Año del censo (1976, 1992, 2001 o 2012).
#' @param filename Nombre del archivo (e.g., `"persona.parquet"`)
#' @param overwrite Lógico. Si `TRUE`, re-descarga aunque exista en caché.
#' @param verbose Lógico. Mostrar progreso.
#' @return Ruta local al archivo (invisible).
#' @keywords internal
.download_censo <- function(anio, filename, overwrite = FALSE, verbose = TRUE) {
  subdir <- paste0("historico/", anio)
  dest   <- .cache_path(filename, subdir = subdir)

  if (.is_cached(filename, subdir = subdir) && !overwrite) {
    if (verbose) {
      cli::cli_inform(c("v" = "Usando caché: {.file {filename}} (censo {anio})"))
    }
    return(invisible(as.character(dest)))
  }

  fs::dir_create(fs::path_dir(dest), recurse = TRUE)

  tag <- .CENSO_RELEASE_TAGS[[as.character(anio)]]
  url <- paste0("https://github.com/", .CENSOSBO_REPO,
                "/releases/download/", tag, "/", filename)

  tabla <- tools::file_path_sans_ext(filename)
  est_mb <- .CENSO_SIZE_MB[[as.character(anio)]][[tabla]]
  size_msg <- if (!is.null(est_mb)) paste0(" (~", est_mb, " MB)") else ""

  if (verbose) {
    cli::cli_progress_step(
      "Descargando {.file {filename}} (censo {anio}){size_msg}...",
      msg_done = "Descargado {.file {filename}}"
    )
  }

  tryCatch(
    curl::curl_download(url, as.character(dest), quiet = TRUE),
    error = function(e) {
      if (fs::file_exists(dest)) fs::file_delete(dest)
      cli::cli_abort(c(
        "Error al descargar {.file {filename}} del censo {anio}.",
        "x" = conditionMessage(e),
        "i" = "Verifica tu conexión o que el release {.val {tag}} exista en GitHub."
      ))
    }
  )

  invisible(as.character(dest))
}
