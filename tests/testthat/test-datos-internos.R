# Las tablas con texto en español viven en R/sysdata.rda, no en R/, porque CRAN
# exige código ASCII (ver data-raw/build_sysdata.R). El riesgo de ese movimiento
# no es que falle ruidosamente: es que una máquina con locale latin1 serialice las
# tildes en otra codificación y `etiquetar_valores()` empiece a devolver texto roto
# sin que nada avise. Estos tests fijan el contenido byte a byte contra
# `datos_internos_ref.rds`, capturado antes de mover las tablas.
#
# Si fallan tras una edición DELIBERADA de data-raw/build_sysdata.R, hay que
# regenerar el fixture a conciencia, revisando el diff acento por acento:
#
#   ref <- list(etiquetas    = censosbo:::.HARMONIZED_VALUE_LABELS,
#               universo_txt = censosbo:::.UNIVERSO_TEXTO,
#               universo_min = censosbo:::.UNIVERSO_EDAD_MIN,
#               dep_codes    = censosbo:::.DEP_CODES)
#   saveRDS(ref, testthat::test_path("fixtures/datos_internos_ref.rds"), version = 2)

ref <- readRDS(test_path("fixtures/datos_internos_ref.rds"))

test_that("las etiquetas armonizadas sobreviven intactas al viaje por sysdata.rda", {
  expect_identical(.HARMONIZED_VALUE_LABELS, ref$etiquetas)
})

test_that("las tablas de universos y de departamentos sobreviven intactas", {
  expect_identical(.UNIVERSO_TEXTO, ref$universo_txt)
  expect_identical(.UNIVERSO_EDAD_MIN, ref$universo_min)
  expect_identical(.DEP_CODES, ref$dep_codes)
})

test_that("los acentos llegan como UTF-8, no como bytes de otra codificación", {
  # El fallo que esto vigila: "Potosí" serializado en latin1 se lee como "Potos\xed",
  # que no es UTF-8 válido y se muestra roto en cualquier salida del paquete.
  con_tildes <- c(
    .DEP_CODES[["05"]],                        # Potosí
    .HARMONIZED_VALUE_LABELS$nivel_edu[["0"]], # Sin instrucción
    .HARMONIZED_VALUE_LABELS$idioma_materno[["4"]], # Guaraní
    .UNIVERSO_TEXTO[["mujeres_15_49"]]         # mujeres de 15 a 49 años
  )
  expect_true(all(validUTF8(con_tildes)))
  expect_false(any(Encoding(con_tildes) == "latin1"))
  expect_identical(con_tildes[[1]], "Potosí")
  expect_identical(con_tildes[[2]], "Sin instrucción")
})

test_that("las claves de los dos vectores de universo siguen sincronizadas", {
  # Si .UNIVERSO_EDAD_MIN gana una clave que .UNIVERSO_TEXTO no tiene, el aviso de
  # .avisar_universos() sugiere un filtro para un universo que no sabe nombrar.
  expect_true(all(names(.UNIVERSO_EDAD_MIN) %in% names(.UNIVERSO_TEXTO)))
})

test_that("el codigo de R no tiene caracteres no-ASCII fuera de los comentarios", {
  # Es el WARNING que bloquea el envio a CRAN. Se comprueba aqui, y no solo en el
  # check, para que reaparezca en el acto si alguien escribe un mensaje con tildes.
  skip_on_cran()
  archivos <- list.files(file.path(test_path("..", ".."), "R"),
                         pattern = "[.]R$", full.names = TRUE)
  skip_if(length(archivos) == 0, "no se encuentra R/ (paquete instalado, no fuente)")

  culpables <- character()
  for (f in archivos) {
    pd <- utils::getParseData(parse(f, keep.source = TRUE))
    pd <- pd[pd$terminal & pd$token != "COMMENT", ]
    if (any(grepl("[^\x01-\x7f]", pd$text, useBytes = TRUE))) {
      culpables <- c(culpables, basename(f))
    }
  }
  expect_identical(culpables, character(0))
})
