## Propone la correspondencia de nombres DDI <-> codebook para el censo 2012.
##
## El DDI del ANDA usa nombre largo `STEM_SUFIJO` (P23_PARENTES, P17A_RADIO) y el
## codebook del paquete —que viene de open-redatam— usa solo el stem (P23, P17A).
## El join exacto es 0, así que hace falta una tabla de correspondencia.
##
## Una regla pura no basta: `sub("_.*$", "", name)` acierta en 61 de 92 stems pero
##   - colisiona: P23_PARENTES y P23_NUEVO_NROPER dan los dos "P23"; igual TOT_*;
##   - destruye el nombre en ID_BC_* e I_BC_VIV;
##   - falla en 6 pares cuyo sufijo el codebook conserva o cambia
##     (P30_IDIOMA <-> P30B, P42B_OCUPCOD <-> P42, ...).
##
## Este script genera una PROPUESTA y la valida comparando la etiqueta del DDI
## (sin el número de pregunta) contra la del codebook: en 2012 coinciden casi
## verbatim, así que una similitud baja delata un emparejamiento equivocado.
## El resultado se revisa a mano y se guarda como nombres_ddi_2012.csv.
##
## Uso:  Rscript data-raw/taxonomia/proponer_nombres_2012.R

source("data-raw/ddi/parse_ddi.R")
load("data/codebook_historico_meta.rda")

SALIDA <- "data-raw/taxonomia/nombres_ddi_2012_propuesta.csv"

# Normaliza texto para comparar etiquetas: minúsculas, sin acentos, sin
# puntuación, sin el número de pregunta inicial y sin espacios redundantes.
normalizar_texto <- function(x) {
  x <- tolower(ifelse(is.na(x), "", x))
  x <- sub("^[0-9]+[a-z]?(\\.[0-9a-z]+)*\\.?[[:space:]]*", "", x)
  x <- iconv(x, to = "ASCII//TRANSLIT")
  x <- gsub("[^a-z0-9 ]", " ", x)
  x <- trimws(gsub("[[:space:]]+", " ", x))
  x
}

# Similitud 0-1 por distancia de edición normalizada.
similitud <- function(a, b) {
  if (!nzchar(a) || !nzchar(b)) return(0)
  1 - utils::adist(a, b)[1, 1] / max(nchar(a), nchar(b))
}

ddi <- leer_ddi(2012)
cb <- codebook_historico_meta[["2012"]]

# Emparejamiento: para cada fila del DDI, busca en el codebook de la MISMA tabla
# el candidato con mayor similitud de etiqueta, restringiendo a los que comparten
# el stem o cuyo nombre es prefijo del otro. Así el texto decide entre candidatos
# plausibles, en vez de emparejar por texto a ciegas.
stem_de <- function(x) toupper(sub("_.*$", "", x))

# Los identificadores de registro (I00_FOLIO, ID_BC_*, P23_NUEVO_NROPER...) no
# tienen par en el codebook y sus stems son cortos y genéricos ("ID", "I"), lo
# que produce emparejamientos absurdos (ID_BC_DISC -> idep). Se excluyen.
origen_ddi <- derivar_origen(
  ddi$variable_ddi, ddi$labl, ddi$regla_derivacion,
  resolver_pregunta(ddi$labl, ddi$variable_ddi)$pregunta
)

filas <- lapply(seq_len(nrow(ddi)), function(i) {
  v_ddi <- ddi$variable_ddi[i]
  tabla <- ddi$tabla[i]
  st <- stem_de(v_ddi)

  if (origen_ddi[i] %in% c("identificador", "geografia")) {
    return(data.frame(
      variable_ddi = v_ddi, tabla = tabla, variable_cb = NA_character_,
      similitud = NA_real_, labl_ddi = ddi$labl[i], etiqueta_cb = NA_character_,
      nota = paste0("no se empareja: ", origen_ddi[i]), stringsAsFactors = FALSE
    ))
  }

  cand <- cb[cb$tabla == tabla, ]
  if (nrow(cand) == 0) cand <- cb
  nm <- toupper(cand$variable)

  # Candidatos por nombre. Las reglas de prefijo solo se aplican a stems que
  # parecen un identificador de pregunta (P/V + dígitos, >= 3 caracteres), para
  # que un stem genérico no arrastre medio codebook.
  parece_pregunta <- function(s) nchar(s) >= 3 & grepl("^[PV][0-9]", s)
  plausible <- nm == st | nm == toupper(v_ddi)
  if (parece_pregunta(st)) {
    plausible <- plausible |
      (startsWith(nm, st)) |                                    # P30 -> P30B, P31 -> P31B1
      (parece_pregunta(nm) & startsWith(st, nm))                # P42B -> P42, P44B1 -> P44
  }
  cand <- cand[plausible, , drop = FALSE]

  if (nrow(cand) == 0) {
    return(data.frame(
      variable_ddi = v_ddi, tabla = tabla, variable_cb = NA_character_,
      similitud = NA_real_, labl_ddi = ddi$labl[i], etiqueta_cb = NA_character_,
      nota = "sin candidato", stringsAsFactors = FALSE
    ))
  }

  a <- normalizar_texto(ddi$labl[i])
  sims <- vapply(normalizar_texto(cand$etiqueta), function(b) similitud(a, b), numeric(1))
  j <- which.max(sims)

  data.frame(
    variable_ddi = v_ddi, tabla = tabla, variable_cb = cand$variable[j],
    similitud = round(sims[j], 3), labl_ddi = ddi$labl[i],
    etiqueta_cb = cand$etiqueta[j], nota = "", stringsAsFactors = FALSE
  )
})

prop <- do.call(rbind, filas)

# Diagnóstico
cat("== Propuesta de correspondencia DDI 2012 -> codebook ==\n")
cat("filas DDI:", nrow(prop), "| emparejadas:", sum(!is.na(prop$variable_cb)),
    "| sin candidato:", sum(is.na(prop$variable_cb)), "\n\n")

flojas <- prop[!is.na(prop$similitud) & prop$similitud < 0.6, ]
cat("--- similitud < 0.6 (REVISAR A MANO:", nrow(flojas), ") ---\n")
if (nrow(flojas)) {
  print(flojas[order(flojas$similitud),
               c("variable_ddi", "variable_cb", "similitud", "labl_ddi", "etiqueta_cb")],
        row.names = FALSE, right = FALSE)
}

sin <- prop[is.na(prop$variable_cb), ]
cat("\n--- sin candidato (", nrow(sin), ") ---\n")
if (nrow(sin)) print(sin[, c("variable_ddi", "tabla", "labl_ddi")], row.names = FALSE, right = FALSE)

# Variables del codebook que ninguna fila del DDI reclama.
huerfanas <- setdiff(
  paste(cb$tabla, cb$variable),
  paste(prop$tabla, prop$variable_cb)
)
cat("\n--- del codebook sin par en el DDI (", length(huerfanas), ") ---\n")
if (length(huerfanas)) {
  h <- cb[paste(cb$tabla, cb$variable) %in% huerfanas, c("tabla", "variable", "etiqueta")]
  print(h, row.names = FALSE, right = FALSE)
}

# Un mismo destino reclamado por dos filas del DDI: hay que desambiguar.
dup <- prop[!is.na(prop$variable_cb), ]
clave <- paste(dup$tabla, dup$variable_cb)
dups <- clave[duplicated(clave)]
cat("\n--- destinos reclamados por >1 variable del DDI (", length(unique(dups)), ") ---\n")
if (length(dups)) {
  print(dup[clave %in% dups, c("variable_ddi", "tabla", "variable_cb", "similitud", "labl_ddi")],
        row.names = FALSE, right = FALSE)
}

utils::write.csv(prop, SALIDA, row.names = FALSE, na = "")
cat("\nPropuesta escrita en", SALIDA, "\n")
cat("Revisa las secciones de arriba, corrige, y guarda como nombres_ddi_2012.csv\n")
