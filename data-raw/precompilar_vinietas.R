# ==============================================================================
# Precompila las viñetas que necesitan descargar datos
# ==============================================================================
#
# POR QUÉ
#
# Las máquinas de check de CRAN reconstruyen las viñetas en cada plataforma, sin
# garantía de red, y la política exige que el uso de recursos de internet falle
# con gracia. Una viñeta que llama a `get_personas_2024()` al compilarse no puede
# cumplir eso.
#
# La salida es el patrón "precomputed vignettes" de r-pkgs.org: la fuente vive en
# `introduccion.Rmd.orig` —que sí descarga y sí se ejecuta, aquí, a mano— y el
# `.Rmd` que viaja en el paquete lleva los resultados ya escritos dentro. Para R
# es una viñeta normal sin ningún chunk que haga red.
#
# CÓMO
#
#   source("data-raw/precompilar_vinietas.R")
#
# Requiere red y el paquete instalado (`R CMD INSTALL .`), porque knit corre
# contra la versión instalada, no contra load_all(). Después hay que **revisar el
# .Rmd generado** y commitearlo junto al .orig: es un artefacto versionado, no un
# archivo temporal.
#
# GOTCHA
#
# knitr resuelve las rutas relativas al directorio de trabajo, así que hay que
# hacer el knit DENTRO de vignettes/ para que las figuras queden junto al .Rmd y
# los enlaces `figuras-...png` funcionen en el HTML final. De ahí el setwd().

if (!requireNamespace("knitr", quietly = TRUE)) {
  stop("Hace falta knitr para precompilar las vinietas.", call. = FALSE)
}

VINIETAS <- c("introduccion")

# El setwd va dentro de una función a propósito: `on.exit()` en el nivel superior
# de un script se dispara al acabar SU PROPIA expresión, no al acabar el script,
# así que el directorio volvía atrás antes del bucle y el knit no encontraba nada.
.precompilar <- function(vinietas) {
  anterior <- setwd("vignettes")
  on.exit(setwd(anterior), add = TRUE)

  for (v in vinietas) {
    orig <- paste0(v, ".Rmd.orig")
    if (!file.exists(orig)) {
      stop("No existe vignettes/", orig, call. = FALSE)
    }
    message("Precompilando ", orig, " ...")
    knitr::knit(orig, output = paste0(v, ".Rmd"))
  }
}

.precompilar(VINIETAS)

message("\nListo. Revisa los .Rmd generados y las figuras antes de commitear.")
message("Comprueba tambien que ningun chunk quedo con codigo de descarga sin evaluar.")
