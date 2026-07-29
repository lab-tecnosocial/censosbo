# ==============================================================================
# R/sysdata.rda — tablas internas con texto en español
# ==============================================================================
#
# POR QUÉ ESTE ARCHIVO EXISTE
#
# CRAN exige que el código de R sea ASCII puro ("Portable packages must use only
# ASCII characters in their R code"). Los mensajes de `cli` se escapan con
# \uXXXX y se quedan en R/, porque son código. Pero estas tablas son DATOS: son
# las etiquetas que el usuario ve en sus resultados, y escribirlas como
# "Sin instrucción" las volvería imposibles de leer y de mantener.
#
# La salida son los mismos objetos, servidos desde R/sysdata.rda. El check de
# non-ASCII solo mira el código; `checking data for non-ASCII characters` acepta
# UTF-8 en los .rda. Así el dato sigue siendo legible AQUÍ, que es donde se edita.
#
# CÓMO SE EDITA
#
# Se cambia este archivo, se ejecuta entero, y se corre
# tests/testthat/test-datos-internos.R: compara byte a byte contra el fixture
# `datos_internos_ref.rds`, que fija cómo eran las tablas antes de moverlas.
# Si el test falla tras una edición deliberada, hay que regenerar el fixture a
# conciencia (ver el propio test) — nunca "arreglarlo" borrándolo.
#
#   source("data-raw/build_sysdata.R")
#   devtools::test(filter = "datos-internos")

library(usethis)

# ------------------------------------------------------------------------------
# .HARMONIZED_VALUE_LABELS — etiquetas de los códigos armonizados
# ------------------------------------------------------------------------------
# Fuente única de verdad: debe coincidir con los códigos destino de las funciones
# .harmonize_*() de R/temporal.R. Solo incluye variables efectivamente
# armonizadas (códigos comparables entre censos). Las variables passthrough
# (solo `parentesco`) NO se etiquetan porque sus códigos varían entre censos.
.HARMONIZED_VALUE_LABELS <- list(
  # tabla persona
  sexo                = c("1" = "Mujer", "2" = "Hombre"),
  area                = c("1" = "Urbana", "2" = "Rural"),
  estado_civil        = c("1" = "Soltero/a", "2" = "Casado/a o conviviente",
                          "3" = "Separado/a o divorciado/a", "4" = "Viudo/a"),
  pea                 = c("1" = "Ocupado", "2" = "Cesante", "3" = "Aspirante"),
  pet                 = c("1" = "Sí", "2" = "No"),
  sabe_leer           = c("1" = "Sí", "2" = "No"),
  nivel_edu           = c("0" = "Sin instrucción", "1" = "Primaria",
                          "2" = "Secundaria", "3" = "Superior"),
  asistencia_escolar  = c("1" = "Sí asiste", "2" = "No asiste"),
  categoria_ocupacion = c("1" = "Empleado/Obrero", "2" = "Cuenta propia",
                          "3" = "Empleador/Patrón", "4" = "Familiar no remunerado",
                          "5" = "Otro"),
  identidad_indigena  = c("1" = "Sí", "2" = "No"),
  idioma_materno      = c("1" = "Castellano", "2" = "Quechua", "3" = "Aymara",
                          "4" = "Guaraní", "5" = "Otro nativo boliviano",
                          "6" = "Otro idioma (extranjero)"),
  migracion_nac_dpto  = c("1" = "Mismo departamento", "2" = "Otro departamento",
                          "3" = "Exterior", "4" = "No había nacido"),
  migracion_rec_dpto  = c("1" = "Mismo departamento", "2" = "Otro departamento",
                          "3" = "Exterior", "4" = "No había nacido"),
  # tabla vivienda
  material_paredes    = c("1" = "Ladrillo/Bloque/Hormigón", "2" = "Adobe/Tapial",
                          "3" = "Madera/Tabique/Caña/Palma", "4" = "Piedra", "5" = "Otro"),
  material_techo      = c("1" = "Calamina/Plancha/Teja", "2" = "Losa de hormigón",
                          "3" = "Paja/Caña/Palma", "4" = "Otro"),
  material_piso       = c("1" = "Tierra", "2" = "Cemento/Ladrillo",
                          "3" = "Mosaico/Parquet/Madera", "4" = "Otro"),
  fuente_agua         = c("1" = "Cañería/Red pública", "2" = "Otra fuente protegida",
                          "3" = "Fuente no protegida"),
  energia_electrica   = c("1" = "Sí", "2" = "No"),
  servicio_sanitario  = c("1" = "Sí tiene", "2" = "No tiene"),
  tenencia_vivienda   = c("1" = "Propia", "2" = "Alquilada",
                          "3" = "Cedida/Anticrético/Servicios", "4" = "Otra")
)

# ------------------------------------------------------------------------------
# .UNIVERSO_TEXTO / .UNIVERSO_EDAD_MIN — universos divergentes entre censos
# ------------------------------------------------------------------------------
# Los DDI del ANDA declaran, para cada censo, a qué población se le hizo cada
# pregunta. `.avisar_universos()` (R/temporal.R) usa el texto para el aviso y la
# edad mínima para poder sugerir un filtro concreto.
#
# Van juntos a propósito: son dos mitades de la misma tabla y desincronizarlos
# produce un aviso que sugiere un filtro imposible. El script lo valida abajo.
.UNIVERSO_TEXTO <- c(
  todas_personas = "todas las personas",
  personas_4_mas = "personas de 4 años o más",
  personas_5_mas = "personas de 5 años o más",
  personas_6_mas = "personas de 6 años o más",
  personas_7_mas = "personas de 7 años o más",
  personas_12_mas = "personas de 12 años o más",
  personas_15_mas = "personas de 15 años o más",
  personas_19_mas = "personas de 19 años o más",
  mujeres_12_mas = "mujeres de 12 años o más",
  mujeres_15_49 = "mujeres de 15 a 49 años",
  # Nombre del DDI. Abarca todos los registros de la entidad `vivienda`, así que
  # incluye a las personas censadas en la calle o en tránsito, que no son
  # viviendas (ver tipos_vivienda()).
  todas_viviendas = "todos los registros de la entidad vivienda (incluye personas en la calle o en tránsito)",
  viviendas_particulares = "viviendas particulares",
  viviendas_presentes = "viviendas con personas presentes",
  hogares = "todos los hogares"
)

.UNIVERSO_EDAD_MIN <- c(
  personas_4_mas = 4L, personas_5_mas = 5L, personas_6_mas = 6L,
  personas_7_mas = 7L, personas_12_mas = 12L, personas_15_mas = 15L,
  personas_19_mas = 19L, mujeres_12_mas = 12L, mujeres_15_49 = 15L
)

# ------------------------------------------------------------------------------
# .DEP_CODES — código de departamento → nombre
# ------------------------------------------------------------------------------
# Lo usa .resolve_dep_codes() (R/utils.R) para aceptar nombres además de códigos.
.DEP_CODES <- c(
  "01" = "Chuquisaca", "02" = "La Paz",    "03" = "Cochabamba",
  "04" = "Oruro",      "05" = "Potosí",    "06" = "Tarija",
  "07" = "Santa Cruz", "08" = "Beni",      "09" = "Pando"
)

# ------------------------------------------------------------------------------
# Validaciones antes de escribir
# ------------------------------------------------------------------------------
stopifnot(
  "las claves de .UNIVERSO_EDAD_MIN deben existir en .UNIVERSO_TEXTO" =
    all(names(.UNIVERSO_EDAD_MIN) %in% names(.UNIVERSO_TEXTO)),
  "los codigos de departamento van del 01 al 09" =
    identical(names(.DEP_CODES), sprintf("%02d", 1:9))
)

# Forzar UTF-8 explícito. Sin esto, una máquina con locale latin1 serializaría
# las tildes en otra codificación y `etiquetar_valores()` devolvería texto roto
# a quien instale el paquete — el fallo que el test de regresión vigila.
.forzar_utf8 <- function(x) {
  if (is.list(x)) return(lapply(x, .forzar_utf8))
  if (is.character(x)) {
    nms <- names(x)
    x <- enc2utf8(x)
    if (!is.null(nms)) names(x) <- enc2utf8(nms)
  }
  x
}
.HARMONIZED_VALUE_LABELS <- .forzar_utf8(.HARMONIZED_VALUE_LABELS)
.UNIVERSO_TEXTO          <- .forzar_utf8(.UNIVERSO_TEXTO)
.DEP_CODES               <- .forzar_utf8(.DEP_CODES)

# `internal = TRUE` reescribe R/sysdata.rda completo, así que los cuatro objetos
# tienen que ir en la MISMA llamada: pasar uno solo borraría los otros tres.
usethis::use_data(
  .HARMONIZED_VALUE_LABELS,
  .UNIVERSO_TEXTO,
  .UNIVERSO_EDAD_MIN,
  .DEP_CODES,
  internal  = TRUE,
  overwrite = TRUE,
  compress  = "xz"
)
