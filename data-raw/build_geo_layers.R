## Genera geo_municipios.rda y geo_departamentos.rda
##
## Fuente: "Límites Municipales de Bolivia 2025" de SDSN Bolivia (junio 2025),
## la base cartográfica del Atlas Municipal de los ODS. Cubre las 343 unidades
## del CPV-2024 (339 municipios + 4 GAIOC creados entre 2016 y 2023) y es
## topológicamente limpia, a diferencia de la cartografía electoral que se usaba
## antes: aquella solo traía 339 polígonos y dejaba ~1.100 huecos entre vecinos.
##
## Ojo con la columna `Codigo_INE` del shapefile: está desalineada en 7 filas
## (Omasuyos en La Paz y Ñuflo de Chávez en Santa Cruz), así que NO se usa. El
## código de cada polígono se deduce por voto espacial mayoritario con los
## puntos de comunidades del CPV-2024, que sí traen el código del INE usado en
## los microdatos. Eso corrige la desalineación y detectaría cualquier otra.
##
## Requiere: sf, rmapshaper, censosbo instalado (para geo_bolivia y los puntos).
## Ejecutar desde la raíz del paquete:
##   source("data-raw/build_geo_layers.R")

library(sf)
library(censosbo)

sf::sf_use_s2(FALSE)  # las operaciones de topología van en el plano lon/lat

SHP  <- "original-data/geo/sdsn_limites_2025/limites_2025.shp"
KEEP <- 0.05  # proporción de vértices que conserva ms_simplify

# `TRUE` compara la población de SDSN con la de los microdatos municipio a
# municipio. Es la validación más fuerte del emparejamiento código-geometría,
# pero descarga los 9 departamentos de personas si no están en caché.
VALIDAR_POBLACION <- FALSE

.norm <- function(x) {
  x <- iconv(as.character(x), to = "ASCII//TRANSLIT")
  tolower(trimws(gsub("[^a-zA-Z ]", "", x)))
}

# ── 1. LEER LA FUENTE ─────────────────────────────────────────────────────────

mun_raw <- sf::st_read(SHP, quiet = TRUE) |>
  sf::st_transform(4326) |>
  sf::st_make_valid()

stopifnot(nrow(mun_raw) == 343)
message("Polígonos en la fuente: ", nrow(mun_raw))

# ── 2. DEDUCIR EL CÓDIGO INE POR VOTO ESPACIAL ────────────────────────────────

# Los ~21.000 puntos de comunidades rurales del CPV-2024 traen idep/iprov/imun
# tal como aparecen en los microdatos: son el árbitro de qué código le toca a
# cada polígono.
puntos <- do.call(rbind, lapply(sprintf("%02d", 1:9), function(d) {
  get_geo_comunidades(departamento = d, verbose = FALSE)
}))
puntos$key <- paste0(puntos$idep, puntos$iprov, puntos$imun)

dentro <- sf::st_within(sf::st_transform(sf::st_geometry(puntos), 4326),
                        sf::st_geometry(mun_raw))
poly_i <- vapply(dentro, function(i) if (length(i)) i[1] else NA_integer_, integer(1))

votos <- table(poly_i, puntos$key)
key_voto  <- colnames(votos)[apply(votos, 1, which.max)]
share     <- apply(votos, 1, max) / rowSums(votos)
names(key_voto) <- names(share) <- rownames(votos)

# Código de la fuente, solo como respaldo para polígonos sin ningún punto
# (Colcapirhua es 100% urbano y no tiene comunidades rurales).
code5 <- sprintf("%05d", as.integer(mun_raw$Codigo_INE))
key_shp <- paste0(sprintf("%02d", as.integer(substr(code5, 1, 1))),
                  substr(code5, 2, 3), substr(code5, 4, 5))

mun_raw$key <- key_voto[as.character(seq_len(nrow(mun_raw)))]
sin_voto <- which(is.na(mun_raw$key))

# El respaldo solo vale si el nombre del polígono concuerda con el nombre que el
# INE le da a ese código; si no, hay que resolverlo a mano antes de continuar.
geo_bolivia$key <- paste0(geo_bolivia$idep, geo_bolivia$iprov, geo_bolivia$imun)
for (i in sin_voto) {
  nom_ine <- geo_bolivia$nombre_mun[match(key_shp[i], geo_bolivia$key)]
  if (!is.na(nom_ine) && .norm(nom_ine) == .norm(mun_raw$Municipio[i])) {
    mun_raw$key[i] <- key_shp[i]
    message("Sin puntos, código tomado de la fuente: ", mun_raw$Municipio[i],
            " (", key_shp[i], ")")
  } else {
    stop("Polígono sin puntos y sin código verificable: ", mun_raw$Municipio[i])
  }
}

n_corr <- sum(mun_raw$key != key_shp)
message("Códigos corregidos frente a `Codigo_INE` de la fuente: ", n_corr)
if (n_corr > 0) {
  print(data.frame(municipio = mun_raw$Municipio[mun_raw$key != key_shp],
                   fuente    = key_shp[mun_raw$key != key_shp],
                   voto      = mun_raw$key[mun_raw$key != key_shp],
                   row.names = NULL))
}

stopifnot(
  !any(duplicated(mun_raw$key)),                 # un código por polígono
  setequal(mun_raw$key, geo_bolivia$key),        # los 343 del CPV-2024
  min(share, na.rm = TRUE) > 0.5                 # ningún voto ajustado
)

# ── 3. SIMPLIFICAR PRESERVANDO TOPOLOGÍA ──────────────────────────────────────

# ms_simplify (Visvalingam sobre arcos compartidos) mantiene los bordes entre
# vecinos idénticos. st_simplify no: era el origen de los huecos del mapa viejo.
mun_sim <- rmapshaper::ms_simplify(mun_raw, keep = KEEP, keep_shapes = TRUE)
mun_sim <- sf::st_cast(sf::st_make_valid(mun_sim), "MULTIPOLYGON")

stopifnot(nrow(mun_sim) == 343, all(sf::st_is_valid(mun_sim)))

# Solo deben quedar los huecos reales del país: Salar de Uyuni, lago Poopó y
# lago Uru Uru. Cualquier otro sería un artefacto de la simplificación.
anillos <- sf::st_cast(sf::st_geometry(sf::st_union(mun_sim)), "POLYGON")
huecos  <- unlist(lapply(anillos, function(p) {
  if (length(p) > 1) lapply(p[-1], function(r) sf::st_polygon(list(r)))
}), recursive = FALSE)
if (length(huecos)) {
  km2 <- as.numeric(sf::st_area(
    sf::st_transform(sf::st_sfc(huecos, crs = 4326), "ESRI:102033"))) / 1e6
  message("Huecos interiores > 1 km²: ", sum(km2 > 1),
          " (", paste(round(sort(km2[km2 > 1], decreasing = TRUE)), collapse = ", "), " km²)")
  stopifnot(sum(km2 > 1) == 3)
}

# ── 4. ARMAR geo_municipios ───────────────────────────────────────────────────

# Los nombres canónicos salen de geo_bolivia (INE-Redatam), no del shapefile:
# la fuente escribe 12 de ellos distinto ("Vitiche" por Vitichi, "Santa Rosa
# del Sara" por Santa Rosa) y el paquete debe hablar el idioma de los microdatos.
i <- match(mun_sim$key, geo_bolivia$key)

geo_municipios <- mun_sim["geometry"]
geo_municipios$idep           <- geo_bolivia$idep[i]
geo_municipios$nombre_dep     <- geo_bolivia$nombre_dep[i]
geo_municipios$iprov          <- geo_bolivia$iprov[i]
geo_municipios$nombre_prov    <- geo_bolivia$nombre_prov[i]
geo_municipios$imun           <- geo_bolivia$imun[i]
geo_municipios$nombre_mun     <- geo_bolivia$nombre_mun[i]
geo_municipios$capital        <- as.character(mun_sim$Capital)
geo_municipios$superficie_km2 <- round(mun_sim$Sup_Ha / 100, 1)

geo_municipios <- geo_municipios[, c("idep", "nombre_dep", "iprov", "nombre_prov",
                                     "imun", "nombre_mun", "capital",
                                     "superficie_km2", "geometry")]
geo_municipios <- geo_municipios[order(geo_municipios$idep,
                                       geo_municipios$iprov,
                                       geo_municipios$imun), ]
row.names(geo_municipios) <- NULL

stopifnot(!any(is.na(geo_municipios$nombre_mun)),
          !any(is.na(geo_municipios$capital)),
          !any(is.na(geo_municipios$superficie_km2)))

# ── 5. DEPARTAMENTOS POR DISOLUCIÓN ───────────────────────────────────────────

# Derivarlos de los municipios en vez de leer otra capa garantiza que los bordes
# departamentales caigan exactamente sobre los municipales.
geo_departamentos <- rmapshaper::ms_dissolve(geo_municipios, field = "idep")
geo_departamentos <- sf::st_cast(sf::st_make_valid(geo_departamentos), "MULTIPOLYGON")
geo_departamentos$nombre_dep <- geo_bolivia$nombre_dep[
  match(geo_departamentos$idep, geo_bolivia$idep)]
geo_departamentos <- geo_departamentos[, c("idep", "nombre_dep", "geometry")]
geo_departamentos <- geo_departamentos[order(geo_departamentos$idep), ]
row.names(geo_departamentos) <- NULL

stopifnot(nrow(geo_departamentos) == 9,
          !any(is.na(geo_departamentos$nombre_dep)),
          all(sf::st_is_valid(geo_departamentos)))

# ── 6. VALIDAR CONTRA LOS MICRODATOS ──────────────────────────────────────────

# Cuántos puntos del CPV-2024 caen en el municipio que les corresponde. Con la
# cartografía electoral eran el 95,9%; el resto son puntos justo sobre el borde.
dentro2 <- sf::st_within(sf::st_transform(sf::st_geometry(puntos), 4326),
                         sf::st_geometry(geo_municipios))
key_geo <- paste0(geo_municipios$idep, geo_municipios$iprov, geo_municipios$imun)
acierto <- vapply(dentro2, function(k) if (length(k)) key_geo[k[1]] else NA_character_,
                  character(1))
message(sprintf("Puntos del CPV-2024 en su municipio: %.2f%% (%d de %d)",
                100 * mean(acierto == puntos$key, na.rm = TRUE),
                sum(acierto == puntos$key, na.rm = TRUE), nrow(puntos)))

if (VALIDAR_POBLACION) {
  pob_micro <- get_personas_2024(variables = c("idep", "iprov", "imun"), as = "tibble")
  pob_micro <- as.data.frame(table(paste0(pob_micro$idep, pob_micro$iprov, pob_micro$imun)))
  names(pob_micro) <- c("key", "pob")
  j <- match(mun_sim$key, as.character(pob_micro$key))
  message("Municipios con población idéntica a la de la fuente: ",
          sum(pob_micro$pob[j] == mun_sim$Pob_2024), " de 343")
  stopifnot(all(pob_micro$pob[j] == mun_sim$Pob_2024))
}

# ── 7. GUARDAR ────────────────────────────────────────────────────────────────

usethis::use_data(geo_departamentos, overwrite = TRUE)
usethis::use_data(geo_municipios,    overwrite = TRUE)
message("\nGuardado geo_departamentos (", nrow(geo_departamentos), ") y ",
        "geo_municipios (", nrow(geo_municipios), ") en data/")
