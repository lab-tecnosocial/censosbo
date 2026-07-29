## Descarga los DDI/XML oficiales del catálogo ANDA del INE Bolivia.
##
## El ANDA publica un DDI por estudio en
##   https://anda.ine.gob.bo/index.php/metadata/export/<estudio>/ddi
## que es la única fuente máquina-legible con metadatos POR VARIABLE: universo,
## definición conceptual, pregunta literal, instrucciones al censista y (en
## 2012/2001) etiquetas de valor.
##
## Los XML se COMMITEAN al repo como snapshots. Motivos:
##   - `original-data/` es un symlink a un volumen externo que no siempre está
##     montado; el enriquecimiento del codebook no debe depender de él.
##   - El build queda reproducible aunque el ANDA cambie o caiga.
##   - Un cambio del INE se ve en el `git diff` en vez de colarse en silencio.
##
## Idempotente: si el archivo del día ya existe no vuelve a descargar. Si el
## sha256 difiere del que registra MANIFEST.csv, escribe un archivo NUEVO con la
## fecha nueva (nunca sobrescribe) y avisa.
##
## Ejecutar desde la raíz del paquete:  source("data-raw/ddi/descargar_ddi.R")

library(xml2)

DDI_DIR <- "data-raw/ddi"
MANIFEST <- file.path(DDI_DIR, "MANIFEST.csv")

# Estudios del ANDA. `n_var_esperado` es el gate: si el INE republica con otro
# número de variables, queremos enterarnos.
DDI_ESTUDIOS <- data.frame(
  anio             = c(2024L, 2012L, 2001L, 1992L, 1976L),
  estudio          = c(132L, 8L, 10L, 47L, 46L),
  idno             = c("BOL-INE-CPV-2024", "BOL-INE-CPV-2012", "BOL-INE-CNPV-2001",
                       "BOL-INE-CNPV-1992", "BOL-INE-CNPV-1976-V3"),
  n_var_esperado   = c(184L, 113L, 86L, 103L, 53L),
  stringsAsFactors = FALSE
)

## Erratas del catálogo que conviene tener presentes: el estudio 46 (censo 1976)
## lleva por título "CNPV1992", igual que el 47. El identificador fiable es el
## IDNo (`BOL-INE-CNPV-1976-V3`), no el título.

ddi_url <- function(estudio) {
  sprintf("https://anda.ine.gob.bo/index.php/metadata/export/%d/ddi", estudio)
}

ddi_path <- function(estudio, fecha) {
  file.path(DDI_DIR, sprintf("ddi_anda_%d_%s.xml", estudio, fecha))
}

# Snapshot más reciente de un estudio ya descargado, o NULL.
ddi_snapshot <- function(estudio) {
  pat <- sprintf("^ddi_anda_%d_\\d{4}-\\d{2}-\\d{2}\\.xml$", estudio)
  hits <- sort(list.files(DDI_DIR, pattern = pat))
  if (length(hits) == 0) NULL else file.path(DDI_DIR, hits[length(hits)])
}

# Cuenta //var sin dejar el documento cargado. El namespace del DDI es
# `http://www.icpsr.umich.edu/DDI`, no `ddi:codebook:2_5`: sin xml_ns_strip()
# cualquier XPath devuelve 0 nodos.
contar_vars <- function(path) {
  x <- xml2::read_xml(path)
  xml2::xml_ns_strip(x)
  length(xml2::xml_find_all(x, "//var"))
}

descargar_uno <- function(anio, estudio, idno, n_var_esperado, fecha) {
  url <- ddi_url(estudio)
  destino <- ddi_path(estudio, fecha)

  if (file.exists(destino)) {
    message(sprintf("  %d (estudio %d): ya existe %s, no se descarga",
                    anio, estudio, basename(destino)))
  } else {
    message(sprintf("  %d (estudio %d): descargando...", anio, estudio))
    tmp <- tempfile(fileext = ".xml")
    res <- utils::download.file(url, tmp, quiet = TRUE, mode = "wb")
    if (res != 0 || !file.exists(tmp)) {
      stop(sprintf("Falló la descarga del DDI del estudio %d (%s)", estudio, url))
    }
    # Verificar que es XML válido y con variables ANTES de aceptarlo: el ANDA
    # devuelve HTTP 200 con HTML de error en algunos endpoints.
    n <- tryCatch(contar_vars(tmp), error = function(e) {
      stop(sprintf("El estudio %d no devolvió XML DDI válido: %s", estudio, conditionMessage(e)))
    })
    if (n == 0) {
      stop(sprintf("El DDI del estudio %d no tiene ninguna //var (¿HTML de error?)", estudio))
    }

    previo <- ddi_snapshot(estudio)
    if (!is.null(previo)) {
      if (unname(tools::md5sum(tmp)) == unname(tools::md5sum(previo))) {
        # Mismo contenido que el snapshot que ya hay: no se crea un archivo nuevo
        # con la fecha de hoy, o el repo acumularía copias idénticas cada vez que
        # se corre el script.
        message(sprintf("  %d: sin cambios respecto a %s, se conserva ese snapshot",
                        anio, basename(previo)))
        unlink(tmp)
        destino <- previo
      } else {
        message(sprintf(
          "  ! %d: el DDI del ANDA CAMBIÓ respecto a %s. Se guarda como archivo nuevo;\n    revisa el diff y actualiza n_var_esperado si corresponde.",
          anio, basename(previo)
        ))
        file.copy(tmp, destino, overwrite = FALSE)
        unlink(tmp)
      }
    } else {
      file.copy(tmp, destino, overwrite = FALSE)
      unlink(tmp)
    }
  }

  n_var <- contar_vars(destino)
  if (n_var != n_var_esperado) {
    message(sprintf(
      "  ! %d: //var = %d, se esperaban %d. El INE cambió el DDI: revisa el parser antes de seguir.",
      anio, n_var, n_var_esperado
    ))
  }

  data.frame(
    anio    = anio,
    estudio = estudio,
    idno    = idno,
    archivo = basename(destino),
    url     = url,
    fecha   = fecha,
    n_var   = n_var,
    sha256  = digest::digest(destino, algo = "sha256", file = TRUE),
    bytes   = file.info(destino)$size,
    stringsAsFactors = FALSE
  )
}

# --- ejecución ----------------------------------------------------------------

if (!dir.exists(DDI_DIR)) dir.create(DDI_DIR, recursive = TRUE)

# La fecha se fija una vez, para que las 3 descargas de una corrida compartan
# nombre de snapshot.
fecha_hoy <- format(Sys.Date(), "%Y-%m-%d")

message("Descargando DDI del ANDA (INE Bolivia)...")
filas <- Map(
  descargar_uno,
  DDI_ESTUDIOS$anio, DDI_ESTUDIOS$estudio, DDI_ESTUDIOS$idno,
  DDI_ESTUDIOS$n_var_esperado, MoreArgs = list(fecha = fecha_hoy)
)
manifest <- do.call(rbind, filas)

utils::write.csv(manifest, MANIFEST, row.names = FALSE)

message("\nMANIFEST.csv:")
print(manifest[, c("anio", "estudio", "archivo", "n_var", "bytes")], row.names = FALSE)
message(sprintf("\nListo: %d snapshots en %s/", nrow(manifest), DDI_DIR))
