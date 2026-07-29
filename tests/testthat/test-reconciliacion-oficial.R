# Reconciliación con los agregados publicados por el INE.
#
# El resto de la suite prueba consistencia interna: que los filtros, los joins y
# los formatos de retorno hagan lo que dicen. Eso no garantiza que las cifras
# coincidan con lo que el INE publicó, que es lo que un usuario del paquete va a
# citar. Estos tests fijan esos números.
#
# Requieren los microdatos completos en el caché (~1 GB), así que se saltan por
# defecto. Para correrlos:
#
#   CENSOSBO_TEST_RECONCILIACION=true Rscript -e 'devtools::test()'
#
# Fuentes de las cifras esperadas:
#   - Resultados y tabulados oficiales del CPV-2024, https://cpv2024.ine.gob.bo/
#   - REDATAM del INE, https://redatam.ine.gob.bo/
#   - Geoportal del INE, https://geoportal.ine.gob.bo/ (vía get_unidades_2024())

skip_if_not_installed("arrow")

skip_reconciliacion <- function(archivos) {
  skip_if_not(
    identical(tolower(Sys.getenv("CENSOSBO_TEST_RECONCILIACION")), "true"),
    "Reconciliación oficial: define CENSOSBO_TEST_RECONCILIACION=true para correrla."
  )
  faltan <- archivos[!file.exists(file.path(censosbo_cache_dir(), archivos))]
  skip_if(length(faltan) > 0,
          paste("Faltan en el caché:", paste(faltan, collapse = ", ")))
}

.n <- function(ds) {
  as.integer(dplyr::pull(dplyr::collect(dplyr::summarise(ds, n = dplyr::n())), "n"))
}

# --- Población -------------------------------------------------------------

test_that("la población del CPV-2024 coincide con los resultados oficiales", {
  skip_reconciliacion(sprintf("persona_dep%02d.parquet", 1:9))

  personas <- get_personas_2024(variables = c("idep", "p25_sexo"), verbose = FALSE)
  expect_equal(.n(personas), 11365333L)

  # Ojo con los códigos: en el CPV-2024 `p25_sexo` es 1 = Mujer, 2 = Hombre.
  sexo <- dplyr::arrange(dplyr::collect(dplyr::count(personas, p25_sexo)), p25_sexo)
  expect_equal(sexo$n[sexo$p25_sexo == 1], 5682835L)  # mujeres
  expect_equal(sexo$n[sexo$p25_sexo == 2], 5682498L)  # hombres

  expect_equal(.n(get_personas_2024(departamento = "Chuquisaca", verbose = FALSE)), 606027L)
  expect_equal(.n(get_personas_2024(municipio = "Sucre", departamento = "Chuquisaca",
                                    verbose = FALSE)), 296746L)
})

# --- Vivienda --------------------------------------------------------------

test_that("el universo de vivienda del CPV-2024 reproduce el total oficial", {
  skip_reconciliacion("vivienda.parquet")

  # 4.480.201 viviendas: el total de los tabulados oficiales.
  expect_equal(.n(get_viviendas_2024(verbose = FALSE)), 4480201L)
  expect_equal(.n(get_viviendas_2024(universo = "particulares", verbose = FALSE)), 4463773L)
  expect_equal(.n(get_viviendas_2024(universo = "colectivas", verbose = FALSE)), 16428L)

  # La entidad cruda de REDATAM tiene 10.287 registros más, que no son viviendas.
  expect_equal(.n(get_viviendas_2024(universo = "todos", verbose = FALSE)), 4490488L)

  excluidos <- dplyr::collect(dplyr::count(
    dplyr::filter(get_viviendas_2024(universo = "todos", verbose = FALSE),
                  v01_tipoviv %in% c(15L, 16L)),
    v01_tipoviv
  ))
  excluidos <- dplyr::arrange(excluidos, v01_tipoviv)
  expect_equal(excluidos$n, c(3311L, 6976L))  # calle, tránsito
})

test_that("las viviendas por área coinciden con el tabulado oficial", {
  skip_reconciliacion("vivienda.parquet")

  area <- dplyr::collect(dplyr::count(
    get_viviendas_2024(variables = c("urbrur"), verbose = FALSE), urbrur
  ))
  area <- dplyr::arrange(area, urbrur)
  expect_equal(area$n[area$urbrur == 1], 2898140L)  # urbana
  expect_equal(area$n[area$urbrur == 2], 1582061L)  # rural
})

test_that("las viviendas por municipio coinciden con el geoportal en los 343", {
  skip_reconciliacion(c("vivienda.parquet", file.path("fichas", "unidad.parquet")))

  # Este es el test que desmonta la explicación anterior: la diferencia del 0,23%
  # entre el geoportal y los microdatos NO era que el INE contase distinto en cada
  # producto, sino los registros de calle y tránsito. Restringido al universo
  # oficial, el cuadre es exacto en TODOS los municipios, no solo en el total.
  micro <- dplyr::collect(dplyr::summarise(
    dplyr::group_by(get_viviendas_2024(verbose = FALSE), idep, iprov, imun),
    viviendas_micro = dplyr::n(), .groups = "drop"
  ))
  geo <- dplyr::collect(dplyr::summarise(
    dplyr::group_by(get_unidades_2024(verbose = FALSE), idep, iprov, imun),
    viviendas_geo = sum(viviendas), .groups = "drop"
  ))
  cmp <- dplyr::inner_join(micro, geo, by = c("idep", "iprov", "imun"))

  expect_equal(nrow(cmp), 343L)
  expect_equal(cmp$viviendas_micro, cmp$viviendas_geo)

  # Con la entidad cruda, en cambio, casi ningún municipio cuadraba.
  crudo <- dplyr::collect(dplyr::summarise(
    dplyr::group_by(get_viviendas_2024(universo = "todos", verbose = FALSE),
                    idep, iprov, imun),
    viviendas_crudo = dplyr::n(), .groups = "drop"
  ))
  cmp2 <- dplyr::inner_join(crudo, geo, by = c("idep", "iprov", "imun"))
  expect_equal(sum(cmp2$viviendas_crudo == cmp2$viviendas_geo), 20L)
})

test_that("el universo de vivienda de los censos históricos descuenta calle y tránsito", {
  skip_reconciliacion(file.path("historico", c("1992", "2001", "2012"), "vivienda.parquet"))

  # Estas cifras no están contrastadas con tabulados oficiales de cada año (sí lo
  # está la de 2024): fijan que el criterio del diccionario se aplique igual en
  # todos los censos y avisan si un release cambia los datos por debajo.
  expect_equal(.n(get_viviendas_1992(universo = "todos", verbose = FALSE)), 1706107L)
  expect_equal(.n(get_viviendas_1992(verbose = FALSE)), 1701168L)  # -4.939 ambulantes

  expect_equal(.n(get_viviendas_2001(universo = "todos", verbose = FALSE)), 2290414L)
  expect_equal(.n(get_viviendas_2001(verbose = FALSE)), 2281022L)  # -9.392 transeúntes

  expect_equal(.n(get_viviendas_2012(universo = "todos", verbose = FALSE)), 3172321L)
  expect_equal(.n(get_viviendas_2012(verbose = FALSE)), 3159350L)  # -12.971 tránsito/calle

  # 1976 no preguntó por calle ni tránsito: ambos universos son el mismo.
  skip_reconciliacion(file.path("historico", "1976", "vivienda.parquet"))
  expect_equal(.n(get_viviendas_1976(verbose = FALSE)), 1158482L)
  expect_equal(.n(get_viviendas_1976(universo = "todos", verbose = FALSE)), 1158482L)
})

# --- Denominadores de las tasas oficiales ----------------------------------

test_that("el denominador de la tasa de alfabetismo excluye a los no declarados", {
  skip_reconciliacion(sprintf("persona_dep%02d.parquet", 1:9))

  # El tabulado oficial da 95,8633% de alfabetismo en la población de 15 años o
  # más. Dividir los alfabetos entre TODAS las personas de 15+ da 94,9357%, casi
  # un punto por debajo: el INE deja fuera del denominador los 80.297 registros
  # con `p40_lee = 9` (Sin especificar). Hacerlo da 95,8630%, que explica la
  # diferencia salvo 0,0003 pp (unos 29 registros de denominador), así que la
  # receta oficial lleva algún filtro más que no está documentado. La conclusión
  # práctica es la del test: no se puede inferir una tasa oficial dividiendo una
  # categoría entre todas las filas.
  lee <- dplyr::collect(dplyr::count(
    dplyr::filter(get_personas_2024(variables = c("p26_edad", "p40_lee"),
                                    verbose = FALSE),
                  p26_edad >= 15),
    p40_lee
  ))
  lee <- dplyr::arrange(lee, p40_lee)

  expect_equal(sum(lee$n), 8301489L)                 # población de 15+
  expect_equal(lee$n[lee$p40_lee == 1], 7881078L)    # sabe leer y escribir
  expect_equal(lee$n[lee$p40_lee == 2], 340114L)     # no sabe
  expect_equal(lee$n[lee$p40_lee == 9], 80297L)      # sin especificar

  tasa_cruda <- 100 * lee$n[lee$p40_lee == 1] / sum(lee$n)
  declarados <- sum(lee$n[lee$p40_lee %in% c(1L, 2L)])
  tasa_declarados <- 100 * lee$n[lee$p40_lee == 1] / declarados

  expect_equal(round(tasa_cruda, 4), 94.9357)
  expect_equal(round(tasa_declarados, 4), 95.863)
  # Excluir a los no declarados cubre el 99,96% de la brecha con el 95,8633%
  # oficial; dividir entre todas las filas se queda a casi un punto.
  expect_lt(abs(tasa_declarados - 95.8633), 0.001)
  expect_gt(abs(tasa_cruda - 95.8633), 0.9)
})
