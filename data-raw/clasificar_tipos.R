## Clasificador unificado del `tipo` de una variable censal.
##
## Única fuente de verdad usada por:
##   - build_codebook.R            (codebook_meta del CPV-2024)
##   - build_codebooks_historicos.R (codebook_historico_meta 1976-2012)
##   - add_tipo_to_dicts.R         (columna `tipo` de los diccionario_variables.parquet)
##
## Reglas (en orden de prioridad):
##   1. Tiene value labels sustantivos (no centinela) -> "categorica".
##      Captura variables con valores numéricos que en realidad son códigos
##      etiquetados (sexo=1/2, parentesco=1..n, etc.).
##   2. El nombre indica un CÓDIGO de clasificación (sufijo/segmento "cod")
##      -> "categorica". Captura códigos geográficos y de ocupación que son
##      categóricos aunque no tengan todos sus valores enumerados en el
##      diccionario de etiquetas (p35h_muncod, P33COD, P45COD, ...).
##   3. El dato se almacena como texto (string) -> "texto". Campos de texto
##      libre tipo "otro, especifique" (p57b_uhnacan, ...).
##   4. En cualquier otro caso -> "numerica" (conteos y medidas continuas).

# Patrón de nombre que delata un código de clasificación.
CODE_RE <- "(^|_)cod([0-9]|$)|cod$"

# Etiquetas centinela: si TODOS los value labels de una variable son de este
# tipo (omisión, top-coding "8 y más", "ignorado", ...), no se considera
# categórica, porque la variable subyacente es numérica.
SENTINEL_RE <- paste(
  "sin especificar", "sin dato", "omisi.n", "y m.s", "y mas", "no sabe",
  "no responde", "ignorado", "no corresponde", "no aplica",
  sep = "|"
)

tiene_etiquetas_sustantivas <- function(vc) {
  if (is.null(vc) || nrow(vc) == 0) return(FALSE)
  !all(grepl(SENTINEL_RE, tolower(trimws(vc$etiqueta))))
}

# storage_type: "string" | "numeric" | NA_character_ (desconocido)
clasificar_tipo <- function(variable, valores_codigos, storage_type = NA_character_) {
  if (tiene_etiquetas_sustantivas(valores_codigos))        return("categorica")
  if (grepl(CODE_RE, variable, ignore.case = TRUE))         return("categorica")
  if (!is.na(storage_type) && storage_type == "string")     return("texto")
  "numerica"
}

# Mapa nombre_de_columna (en minúsculas) -> "string"|"numeric", leído del
# esquema de uno o más parquets de datos. Refleja el tipo de almacenamiento
# real, que a su vez deriva del tipo declarado en la fuente original
# (.sav de SPSS para 1976; varType de los .dicx REDATAM para 1992-2012;
# CSV del INE para 2024).
storage_map <- function(parquet_paths) {
  suppressMessages(requireNamespace("arrow"))
  m <- character(0)
  for (p in parquet_paths) {
    if (!file.exists(p)) next
    s <- arrow::schema(arrow::read_parquet(p, as_data_frame = FALSE))
    for (f in names(s)) {
      ty <- s[[f]]$type$ToString()
      m[tolower(f)] <- if (grepl("string|utf8|binary", ty, ignore.case = TRUE)) "string" else "numeric"
    }
  }
  m
}

# Conveniencia: todos los parquets de DATOS de un directorio de censo,
# excluyendo los propios diccionarios.
data_parquets_de <- function(dir) {
  ps <- list.files(dir, pattern = "\\.parquet$", full.names = TRUE)
  ps[!grepl("diccionario_(variables|etiquetas)\\.parquet$", basename(ps))]
}
