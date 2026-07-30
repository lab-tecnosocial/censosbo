#!/usr/bin/env Rscript
# Descarga al caché los microdatos que exige test-reconciliacion-oficial.R, y
# comprueba que no falte ninguno antes de ceder el paso a los tests.
#
# Por qué existe como script y no como código dentro del YAML: la primera versión
# llevaba la lista de descargas escrita a mano en el workflow, se desincronizó del
# test —olvidaba `historico/1976/vivienda.parquet`— y el fallo solo apareció en CI,
# porque en la máquina donde se validó ese archivo ya estaba en el caché. Un script
# se ejecuta en local antes de subirlo; un bloque `run:` de YAML, no.
#
# Uso: Rscript .github/scripts/reconciliacion-descargar.R
# Requiere que el paquete se pueda cargar con devtools::load_all() y, si se quiere
# el caché en otro sitio, la variable R_USER_CACHE_DIR.

suppressPackageStartupMessages(devtools::load_all(quiet = TRUE))

# Las rutas que cada test declara como imprescindibles, leídas del propio test para
# que no haya una segunda lista que mantener. El argumento de skip_reconciliacion()
# se evalúa: son llamadas a c()/sprintf()/file.path(), todas de base R.
archivos_requeridos <- function(
  ruta = "tests/testthat/test-reconciliacion-oficial.R"
) {
  src <- readLines(ruta, warn = FALSE)
  llamadas <- regmatches(src, regexpr("skip_reconciliacion\\(.*\\)$", src))
  llamadas <- llamadas[nzchar(llamadas)]
  if (!length(llamadas)) {
    stop("No se encontró ninguna llamada a skip_reconciliacion() en ", ruta,
         ": ¿cambió el nombre del helper?")
  }
  unique(unlist(lapply(llamadas, function(l) {
    eval(parse(text = sub("^skip_reconciliacion\\(", "c(", l)))
  })))
}

req <- archivos_requeridos()
cat("El test exige", length(req), "archivos en el caché.\n")
cat("Caché:", censosbo_cache_dir(), "\n\n")

# Las descargas se derivan del listado, no de una lista paralela: añadir un censo
# al test no obliga a tocar este script. Se pide una sola variable porque lo que
# los tests necesitan es el archivo en el caché, no las columnas en memoria; la
# descarga del parquet es completa igual.
if (any(grepl("^persona_dep", req))) {
  cat("-> personas 2024 (9 departamentos)\n")
  invisible(get_personas_2024(variables = "idep"))
}
if ("vivienda.parquet" %in% req) {
  cat("-> viviendas 2024\n")
  invisible(get_viviendas_2024(variables = "urbrur", universo = "todos"))
}
if (file.path("fichas", "unidad.parquet") %in% req) {
  cat("-> fichas: unidades del geoportal\n")
  invisible(get_unidades_2024(as = "tibble"))
}
for (h in grep("^historico/", req, value = TRUE)) {
  partes <- strsplit(h, "/", fixed = TRUE)[[1]]
  anio  <- as.integer(partes[2])
  tabla <- sub("\\.parquet$", "", partes[3])
  cat("-> censo", anio, "tabla", tabla, "\n")
  # `universo` solo aplica a vivienda; pasarlo a otra tabla aborta a propósito.
  if (identical(tabla, "vivienda")) {
    invisible(get_censo(anio, tabla = tabla, universo = "todos"))
  } else {
    invisible(get_censo(anio, tabla = tabla))
  }
}

# La comprobación que convierte un desajuste en un error inmediato y con nombre, en
# lugar de un test saltado veinte líneas más abajo.
faltan <- req[!file.exists(file.path(censosbo_cache_dir(), req))]
if (length(faltan)) {
  stop("Estos archivos siguen sin estar en el caché:\n  ",
       paste(faltan, collapse = "\n  "),
       "\nAñade su descarga a este script.")
}

cat("\nLos", length(req), "archivos están en el caché.\n")
print(censosbo_cache_info())
