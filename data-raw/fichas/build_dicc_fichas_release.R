## Genera el diccionario de las fichas para publicarlo en el release.
##
## El release data-fichas-v1.0.0 no publicaba diccionario, y de ahí nació el
## problema que esta entrega resuelve: `q-censosbo/scripts/build_dicc_fichas.py`
## hacía urllib contra `data-raw/fichas/campos.csv` en raw.githubusercontent, generaba
## un CSV, y ese CSV acabó copiado byte a byte en q-censosbo y en censos-explorer,
## con las etiquetas ya divergiendo entre los dos.
##
## Ahora se publica el diccionario como asset, generado DESDE codebook_meta, que a su
## vez sale de campos.csv. Una sola fuente.
##
## Escribe `data-raw/fichas/release/diccionario_fichas_v1.{parquet,csv}`. El CSV es
## para consumidores que no quieran depender de arrow/pyarrow.
##
## Ejecutar DESPUÉS de build_codebook_fichas.R y add_taxonomia_to_codebook.R:
##   Rscript data-raw/fichas/build_dicc_fichas_release.R

library(arrow)

SALIDA <- "data-raw/fichas/release"

load("data/codebook_meta.rda")
load("data/censo_bloques_meta.rda")
load("data/censo_temas_meta.rda")

dicc <- codebook_meta[codebook_meta$tabla %in% c("ficha", "unidad"), ]
stopifnot(nrow(dicc) == 208)

out <- data.frame(
  tabla             = dicc$tabla,
  variable          = dicc$variable,
  etiqueta          = dicc$etiqueta,
  tipo              = dicc$tipo,
  bloque            = dicc$bloque,
  bloque_etiqueta   = censo_bloques_meta$etiqueta[match(dicc$bloque, censo_bloques_meta$bloque)],
  bloque_orden      = censo_bloques_meta$orden[match(dicc$bloque, censo_bloques_meta$bloque)],
  tema              = dicc$tema,
  tema_etiqueta     = censo_temas_meta$etiqueta[match(dicc$tema, censo_temas_meta$tema)],
  capitulo          = dicc$capitulo,
  denominador       = dicc$denominador,
  stringsAsFactors  = FALSE
)

stopifnot(!anyNA(out$bloque), !anyNA(out$bloque_etiqueta), !anyNA(out$tema))

# Orden del selector: por bloque y, dentro del bloque, dejando el total primero.
out <- out[order(out$bloque_orden, !grepl("_total", out$variable, fixed = TRUE),
                 out$variable), ]
rownames(out) <- NULL

if (!dir.exists(SALIDA)) dir.create(SALIDA, recursive = TRUE)
write_parquet(out, file.path(SALIDA, "diccionario_fichas_v1.parquet"))
utils::write.csv(out, file.path(SALIDA, "diccionario_fichas_v1.csv"),
                 row.names = FALSE, na = "")

message(sprintf("diccionario_fichas_v1: %d filas (%d ficha, %d unidad), %d con denominador",
                nrow(out), sum(out$tabla == "ficha"), sum(out$tabla == "unidad"),
                sum(!is.na(out$denominador))))
message("Columnas: ", paste(names(out), collapse = ", "))
message("\nNota para los consumidores: las filas 'ambos sexos' (expr = (x_h + x_m)) NO")
message("están aquí, porque no son columnas reales del parquet. Se derivan sumando")
message("los pares _h/_m. Ver dev-docs/consumidores-taxonomia.md")
