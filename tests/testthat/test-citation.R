# `inst/CITATION` es código que se ejecuta, y se ejecuta en condiciones que la máquina
# del autor nunca reproduce: R CMD check lo lee **desde el tarball, con el paquete sin
# instalar**. La versión anterior llamaba a `utils::packageDescription()`, que en ese
# caso devuelve NA, y `NA$Version` abortaba con "$ operator is invalid for atomic
# vectors". El check local pasaba —aquí el paquete siempre está instalado— y el fallo
# lo reportó win-builder en el primer envío a CRAN.
#
# Estos tests recorren los `meta` con los que R lo lee de verdad, incluidos los casos
# degradados. Si alguien vuelve a escribir `meta$campo` sin comprobar, salta aquí.

ruta_citation <- function() {
  # Instalado: inst/ se aplana a la raíz del paquete. En desarrollo: inst/CITATION.
  p <- system.file("CITATION", package = "censosbo")
  if (nzchar(p)) return(p)
  test_path("..", "..", "inst", "CITATION")
}

leer <- function(meta) utils::readCitationFile(ruta_citation(), meta = meta)

descripcion <- function() {
  dcf <- test_path("..", "..", "DESCRIPTION")
  skip_if_not(file.exists(dcf), "DESCRIPTION no accesible (paquete instalado)")
  as.list(read.dcf(dcf)[1, ])
}

test_that("el CITATION se lee con el DESCRIPTION del tarball, que es como lo lee CRAN", {
  cita <- leer(descripcion())
  expect_s3_class(cita, "bibentry")
  expect_match(format(cita, style = "text"), "censosbo", fixed = TRUE)
})

test_that("el CITATION no depende de que el paquete este instalado", {
  # El fallo exacto que reporto win-builder: `meta` no es una lista.
  expect_s3_class(leer(NA), "bibentry")
  expect_s3_class(leer(NULL), "bibentry")
})

test_that("el CITATION sobrevive a un meta sin Title ni Version", {
  cita <- leer(list(Package = "censosbo"))
  expect_s3_class(cita, "bibentry")
  # Debe caer a un titulo utilizable, no a "censosbo: NA".
  expect_no_match(format(cita, style = "text"), "NA", fixed = TRUE)
})

test_that("el anio sale de Date/Publication cuando CRAN lo pone", {
  d <- descripcion()
  cita <- leer(c(d, list("Date/Publication" = "2027-03-04 10:20:03 UTC")))
  expect_match(format(cita, style = "text"), "2027", fixed = TRUE)
})

test_that("el CITATION es ASCII puro", {
  # readCitationFile() aborta con "non-ASCII input in a CITATION file without a
  # declared encoding" si el archivo lleva tildes y el meta recibido no trae Encoding.
  # Siendo ASCII, esa dependencia desaparece.
  lineas <- readLines(ruta_citation(), warn = FALSE)
  expect_false(any(grepl("[^\x01-\x7f]", lineas, useBytes = TRUE)))
})
