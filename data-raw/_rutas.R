# ==============================================================================
# Ruta a los datos originales del INE (`od()`)
# ==============================================================================
#
# POR QUÉ EXISTE ESTE ARCHIVO
#
# Las fuentes originales del INE (los .dicX de REDATAM, los shapefiles, los
# parquets intermedios) pesan decenas de GB y viven en un disco externo que **no
# está montado casi nunca**: solo cuando toca regenerar datos.
#
# Antes se accedía a ellas por un symlink `original-data/` en la raíz del
# proyecto, con rutas relativas literales del tipo `"original-data/r/..."`. Eso
# tenía un efecto colateral desagradable: `R CMD build` **copia el árbol del
# proyecto entero a un temporal antes de aplicar `.Rbuildignore`**, así que un
# symlink cuyo destino no existe revienta la construcción del tarball con
# `cp: original-data: No such file or directory`. Es decir: con el disco
# desmontado no se podía ni construir el paquete, y mucho menos enviarlo a CRAN
# — por un enlace que ni siquiera entra en el tarball.
#
# Ahora la ruta se resuelve **a demanda** con `od()`. No hay symlink, así que el
# build nunca tropieza, y los scripts que sí necesitan las fuentes lo dicen con
# un mensaje claro cuando el disco no está.
#
# CÓMO SE USA
#
#   source("data-raw/_rutas.R")
#   od()                            # la raíz de los datos originales
#   od("r/cpv-2024/parquets")       # un subdirectorio
#   od("fuentes/cpv-2024/CEN24.dicX")
#
# `od()` aborta si la ruta pedida no existe, con la causa distinguida: si lo que
# falta es el disco entero, lo dice; si el disco está pero el archivo no, también.
# Un script que muere en la línea 80 porque una ruta era NULL es mucho peor que
# uno que muere en la primera diciendo qué montar.
#
# DÓNDE BUSCA, EN ORDEN
#
#   1. $CENSOSBO_ORIGINAL_DATA   — para otra máquina u otro disco, sin editar código
#   2. /Volumes/eDriveA/...      — el disco habitual
#   3. ./original-data           — si alguien conserva el symlink de antes
#
# Para trabajar con las fuentes en otro sitio:
#   export CENSOSBO_ORIGINAL_DATA=/ruta/a/original-data

.OD_CANDIDATAS <- c(
  Sys.getenv("CENSOSBO_ORIGINAL_DATA", unset = NA),
  "/Volumes/eDriveA/R-original-data/censosbo/original-data",
  "original-data"
)

# Raíz de los datos originales, o NULL si no hay ninguna accesible.
.od_raiz <- function() {
  for (ruta in .OD_CANDIDATAS[!is.na(.OD_CANDIDATAS)]) {
    if (dir.exists(ruta)) return(normalizePath(ruta, mustWork = FALSE))
  }
  NULL
}

#' Ruta a un archivo o directorio de los datos originales
#'
#' @param ... Componentes de la ruta relativa a la raíz de `original-data`.
#' @param exigir Si `TRUE` (defecto), aborta cuando la ruta no existe.
#' @return La ruta absoluta.
od <- function(..., exigir = TRUE) {
  raiz <- .od_raiz()

  if (is.null(raiz)) {
    stop(
      "Los datos originales del INE no están accesibles.\n",
      "  Monta el disco externo (", .OD_CANDIDATAS[2], ")\n",
      "  o apunta a otra copia:  export CENSOSBO_ORIGINAL_DATA=/ruta/a/original-data\n",
      "  Este script solo hace falta para regenerar datos desde las fuentes;\n",
      "  el paquete se instala y se comprueba sin ellas.",
      call. = FALSE
    )
  }

  ruta <- if (length(list(...))) file.path(raiz, ...) else raiz

  if (exigir && !file.exists(ruta)) {
    stop(
      "No existe dentro de los datos originales: ", sub(paste0(raiz, "/?"), "", ruta), "\n",
      "  Raíz en uso: ", raiz, "\n",
      "  El disco está montado, así que o la ruta cambió o falta ese archivo.",
      call. = FALSE
    )
  }

  ruta
}
