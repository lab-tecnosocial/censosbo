## Genera variable_temporal_map.rda: mapeo de variables armonizadas
## entre censos de Bolivia (1976, 1992, 2001, 2012, 2024).
## Ejecutar desde la raíz del paquete: source("data-raw/build_harmonization_table.R")

variable_temporal_map <- data.frame(
  variable       = character(),
  etiqueta       = character(),
  descripcion    = character(),
  tabla          = character(),
  armonizada     = logical(),
  v1976          = character(),
  v1992          = character(),
  v2001          = character(),
  v2012          = character(),
  v2024          = character(),
  notas          = character(),
  stringsAsFactors = FALSE
)

add_var <- function(variable, etiqueta, descripcion,
                     v1976 = NA, v1992 = NA, v2001 = NA, v2012 = NA, v2024 = NA,
                     notas = "", tabla = "persona", armonizada = TRUE) {
  variable_temporal_map <<- rbind(variable_temporal_map, data.frame(
    variable, etiqueta, descripcion,
    tabla,
    armonizada,
    v1976 = as.character(v1976),
    v1992 = as.character(v1992),
    v2001 = as.character(v2001),
    v2012 = as.character(v2012),
    v2024 = as.character(v2024),
    notas,
    stringsAsFactors = FALSE
  ))
}

# ===========================================================================
# TABLA PERSONA
# ===========================================================================

# --- Demografía básica ---
add_var("sexo", "Sexo",
        "Sexo del individuo. Harmonizado a 1=Mujer, 2=Hombre para todos los censos",
        v1976 = "p03", v1992 = "P03", v2001 = "P28", v2012 = "P24", v2024 = "p25_sexo",
        notas = "1976/1992/2001: codificación original 1=Hombre, 2=Mujer (invertida). 2012/2024: 1=Mujer, 2=Hombre. get_temporal() harmoniza todo a 1=Mujer, 2=Hombre.")

add_var("edad", "Edad en años",
        "Edad del individuo en años cumplidos",
        v1976 = "p04", v1992 = "P04", v2001 = "P29", v2012 = "P25", v2024 = "p26_edad",
        notas = "2001: P29 re-exportado con .dicx corregido (bug fieldsize exportaba 3 bits en vez de 7). 2012: P25 re-exportado desde .dicx (el .dic binario no la exportaba).")

add_var("grupo_edad", "Grupos de edad quinquenales",
        "Grupo de edad en intervalos de 5 años (0-4, 5-9, ..., 80+)",
        v1976 = "p04", v1992 = "P04", v2001 = "P29", v2012 = "P25", v2024 = "p26_edad",
        notas = "Se calcula en todos los censos desde la edad individual en años con (edad %/% 5) * 5, por lo que los intervalos son idénticos y comparables entre años. (Antes 1976/1992 usaban las variables ya agrupadas edad5/GEDAD, cuyos códigos NO eran quinquenios y rompían la comparación.)")

add_var("parentesco", "Relación con el/la jefe/a del hogar",
        "Parentesco o relación del individuo con el jefe o jefa del hogar. NO armonizada: los códigos varían entre censos.",
        v1976 = "p02", v1992 = "P02", v2001 = "P31", v2012 = "P23", v2024 = "p24_parentes",
        notas = "NO ARMONIZADA: get_temporal() devuelve los códigos crudos de cada censo, que no son comparables. Consulta codebook_ANIO() por año para interpretarlos.",
        armonizada = FALSE)

add_var("estado_civil", "Estado conyugal o civil",
        "Situación conyugal del individuo. Harmonizado a 4 categorías: 1=Soltero/a, 2=Casado/a o conviviente, 3=Separado/a o divorciado/a, 4=Viudo/a.",
        v1976 = "p05", v1992 = "P05", v2001 = "P48", v2012 = "P45", v2024 = "p53_ecivil",
        notas = "Harmonizado al máximo nivel comparable (limitado por 1992, que agrupa casado/conviviente y separado/divorciado). 1976: 1=Soltero→1, 2=Casado→2, 3=Viudo→4, 4=Divorciado→3 (sin categoría conviviente ni separado). 1992: 1=Casado/conviviente→2, 2=Viudo→4, 3=Separado/divorciado→3, 4=Soltero→1. 2001/2012: 1=Soltero→1, 2=Casado→2, 3=Conviviente→2, 4=Separado→3, 5=Divorciado→3, 6=Viudo→4. 2024: 1=Casado→2, 2=Conviviente→2, 3=Separado→3, 4=Divorciado→3, 5=Viudo→4, 6=Soltero→1, 9=Sin especificar→NA. ATENCIÓN — EL UNIVERSO CAMBIA ENTRE CENSOS: en 1992 la pregunta se registró para toda la población, incluidos los menores, que quedan como 'Soltero'; en 2001 y 2012 se aplica desde los 15 años y en 1976 y 2024 desde los 12. Comparar la distribución entre censos exige filtrar por edad (p.ej. edad >= 15).")

# --- Educación ---
add_var("sabe_leer", "Sabe leer y escribir",
        "Indica si el individuo sabe leer y escribir. Harmonizado a 1=Sí, 2=No",
        v1976 = "p10", v1992 = "P10", v2001 = "P36", v2012 = "P35", v2024 = "p40_lee",
        notas = "1992 (P10): códigos 7=Sí, 8=No (distinto al resto). get_temporal() harmoniza a 1=Sí, 2=No.")

add_var("nivel_edu", "Nivel de instrucción",
        "Nivel educativo más alto alcanzado. Para comparación temporal se harmoniza a 4 categorías: 0=Sin instrucción, 1=Primaria, 2=Secundaria, 3=Superior",
        v1976 = "nivela", v1992 = "P12", v2001 = "P39NIV", v2012 = "P37A_NIVELNUE", v2024 = "nivel_edu",
        notas = "1976: 'nivela' es var. derivada (1=Ninguno..5=Técnico). 1992: P12 solo cubre quienes asistieron; Ninguno se obtiene combinando con P11 en get_temporal(). 2001: P39NIV con códigos reales 11=Ninguno,12=Preescolar,13=Básico,14=Intermedio,15=Medio,16=Primaria,17=Secundaria,18=Licenciatura,19=Técnico,20=Normal,21-23=Otros. 2012: P37A_NIVELNUE usa códigos no secuenciales (1,2,3,9,10,11-18,99). La Ley Avelino Siñani (2010) cambió la nomenclatura en 2012. ATENCIÓN — EL UNIVERSO CAMBIA ENTRE CENSOS: la variable derivada 'nivel_edu' del CPV-2024 solo cubre a la población de 19 años o más residente en el país, mientras que en 1992, 2001 y 2012 cubre desde los 6 años. Por eso 2024 tiene muchos más NA. Para comparar la distribución entre censos hay que filtrar edad >= 19 en todos los años.")

add_var("asistencia_escolar", "Asistencia educativa actual",
        "Indica si el individuo asiste actualmente a un centro educativo. 1=Sí asiste, 2=No asiste.",
        v1976 = "p11", v1992 = "P11", v2001 = "P37", v2012 = "P36", v2024 = "p38_asiste",
        notas = "1992: 1=Asiste, 2=No asiste pero asistió, 3=Nunca asistió → harmonizado a 1=Asiste, 2=No. 2001: CÓDIGOS INVERTIDOS — 1=NO asiste, 2=SÍ (pública), 3=SÍ (privada). 2012: 1/2/3=SÍ (pública/privada/convenio), 4=No asiste.")

# --- Actividad económica ---
add_var("pea", "Condición de actividad (PEA)",
        "Condición de actividad económica de la Población Económicamente Activa. 1=Ocupado, 2=Cesante, 3=Aspirante. Los inactivos (fuera de la PEA) quedan como NA.",
        v1976 = "pea", v1992 = "NPEA", v2001 = NA, v2012 = "PEA", v2024 = "pea_13",
        notas = "Codificación idéntica en todos los años: 1=Ocupado, 2=Cesante, 3=Aspirante. NO disponible en 2001 (retorna NA). 2024: se usa pea_13 (Población Económicamente Activa, 13° CIET); NO confundir con fft_19 (fuera de la fuerza de trabajo) ni ft_19 (condición de actividad de la fuerza de trabajo).")

add_var("pet", "Población en Edad de Trabajar",
        "Indica si el individuo está en edad de trabajar. Harmonizado a 1=Sí (en edad de trabajar), 2=No.",
        v1976 = "pet", v1992 = "NPET", v2001 = NA, v2012 = "PET", v2024 = "pet_13",
        notas = "Harmonizado a 1=Sí, 2=No. 1976: 1=PET→1, 2=PENT→2. 1992 NPET: 1=PET→1, 0=PENT→2. 2012 PET: 1=trabajar→1, 0=no trabajar→2. 2024 pet_13: 1=PET→1, 2=PENT→2, 9=no especificó→NA. NO disponible en 2001 (retorna NA). La edad mínima de referencia puede variar entre censos (7+ en 2024).")

add_var("categoria_ocupacion", "Categoría en el empleo",
        "Categoría ocupacional del individuo. 1=Empleado/Obrero, 2=Cuenta propia, 3=Empleador/Patrón, 4=Familiar no remunerado, 5=Otro",
        v1976 = "p18", v1992 = "P18", v2001 = "P46", v2012 = "P43", v2024 = "p50_semp",
        notas = "Solo aplica a personas ocupadas (PEA). 1976 p18: 1/2=Obrero/Empleado→1, 4=Cta propia→2, 5=Patrón→3, 3=Familiar→4. 1992 P18: 1/2=Obrero/Empleado→1, 3=Cta propia→2, 4=Patrón→3, 7=Familiar→4, 5/6=Otro→5. 2012 P43: 1/5=Obrero/TrabHogar→1, 2=Cta propia→2, 3=Empleador→3, 4=Familiar→4, 6=Coop→5. 2024 p50_semp: 2/5=Obrero/TrabHogar→1, 1=Cta propia→2, 3=Empleador→3, 4=Familiar→4, 6/7=Otro→5.")

# --- Identidad cultural ---
add_var("identidad_indigena", "Autoidentificación con pueblo indígena",
        "Indica si el individuo se autoidentifica con alguna nación o pueblo indígena originario campesino o afroboliviano. 1=Sí, 2=No.",
        v1976 = NA, v1992 = NA, v2001 = "P491", v2012 = "P29C", v2024 = "p32_pueblo_per",
        notas = "NO disponible en 1976 ni 1992 (retorna NA). 2001 P491: 1-6=pueblo indígena→1, 7=NINGUNO→2. 2012 P29C: código de pueblo (1-123)→1, 0=NOTAPPLICABLE (no se identifica)→2, otros→NA. 2024 p32_pueblo_per: 1=Sí→1, 2=No→2.")

add_var("idioma_materno", "Idioma materno o principal",
        "Idioma aprendido en la niñez o idioma principal. 1=Castellano, 2=Quechua, 3=Aymara, 4=Guaraní, 5=Otro nativo boliviano, 6=Otro idioma.",
        v1976 = "p09", v1992 = NA, v2001 = "P35", v2012 = "P30B", v2024 = "p341_idiomat_cod",
        notas = "LIMITACIÓN METODOLÓGICA: 1976 p09 captura 'idioma que habla' (no materno), con combinaciones bilingüísticas (ej. código 5=Castellano/Aymara → se clasifica como Aymara). 1992 NO disponible (solo flags binarios de idiomas hablados, no maternal). 2001-2024: primer idioma aprendido en la niñez. 2012/2024: códigos 1-37 para lenguas nativas (6=Castellano, 2=Aymara, 27=Quechua, 12=Guaraní); códigos >=38 son idiomas extranjeros.")

# --- Migración ---
add_var("migracion_nac_dpto", "Migración: departamento de nacimiento vs residencia",
        "Compara el departamento de nacimiento con el de residencia actual. 1=Nacido en el mismo dpto, 2=Nacido en otro dpto del país, 3=Nacido en el exterior.",
        v1976 = "lugnac", v1992 = "P07A", v2001 = "DEP34", v2012 = "P32J", v2024 = "p35j_deptocod",
        notas = "Variable DERIVADA: compara columna de dpto de nacimiento con dpto de residencia (idep o dep). 1976: lugnac=1-9 (dpto nac), 10=exterior. 1992: P07A=dpto nac (1-9). 2001: DEP34=dpto nac (1-9). 2012: P32J=dpto nac (1-9), 99=ignorado. 2024: p35j_deptocod=dpto nac (1-9). La comparación con idep actual se hace en get_temporal().")

add_var("migracion_rec_dpto", "Migración reciente: residencia hace 5 años vs actual",
        "Compara el departamento de residencia hace 5 años con el actual. 1=Mismo dpto, 2=Otro dpto del país, 3=Estaba en el exterior, 4=No había nacido.",
        v1976 = "resh5", v1992 = "P08A", v2001 = "DEP41", v2012 = "P34H", v2024 = "p37j_deptocod",
        notas = "Variable DERIVADA: compara dpto hace 5 años con dpto actual (idep o dep). 1976: resh5=10→exterior, 11→NA. 2024: p37_lugres5=4 (no había nacido) → se usa como indicador alternativo; p37j_deptocod para comparar dpto.")

# --- Fertilidad ---
add_var("hijos_nacidos_vivos", "Total de hijos e hijas nacidos vivos",
        "Número total de hijos nacidos vivos que ha tenido la persona (para mujeres de 12+ años).",
        v1976 = "p20", v1992 = "P20", v2001 = "P50", v2012 = "P46", v2024 = "p54_hvtot",
        notas = "Solo aplica a mujeres de 12 o más años. Hombres y mujeres menores de edad retornan 0 o NA. 1992: P20 (el diccionario del parquet confirma P20=nacidos vivos, P21=vivos actualmente). 2024: p54_hvtot es el total (existe también p54a/p54b por sexo del hijo).")

add_var("hijos_sobrevivientes", "Total de hijos e hijas que viven actualmente",
        "Número de hijos nacidos vivos que están vivos al momento del censo.",
        v1976 = "p21", v1992 = "P21", v2001 = "P51", v2012 = "P47", v2024 = "p55_hstot",
        notas = "Subconjunto de hijos_nacidos_vivos. Solo aplica a mujeres 12+. 1992: P21 (el diccionario del parquet confirma P21=vivos actualmente).")

# --- Geografía y área ---
add_var("area", "Área urbana o rural",
        "Área de residencia: 1=Urbana, 2=Rural. Columna directa en todas las tablas de persona.",
        v1976 = "area", v1992 = "area", v2001 = "area", v2012 = "area", v2024 = "area",
        notas = "Columna 'area' presente en todos los parquets de persona. 1976: fuente SPSS directa. 1992/2012: derivada de URBRUR de vivienda (pre-unida). 2001: derivada de TURUR de vivienda (pre-unida). 2024: derivada de urbrur de vivienda (pre-unida). Siempre 1=Urbana, 2=Rural, sin NAs.")

add_var("departamento", "Departamento",
        "Código de departamento (01-09)",
        v1976 = "dep", v1992 = "idep", v2001 = "idep", v2012 = "idep", v2024 = "idep",
        notas = "En 1976: columna 'dep' (numérica 1-9). En censos REDATAM: 'idep' se calcula desde REDCODEN via join con munic.parquet; get_temporal() lo fuerza automáticamente.")


# ===========================================================================
# TABLA VIVIENDA
# ===========================================================================

add_var("material_paredes", "Material de construcción de las paredes",
        "Material predominante de las paredes exteriores. 1=Ladrillo/Bloque/Hormigón, 2=Adobe/Tapial, 3=Madera/Tabique/Caña/Palma, 4=Piedra, 5=Otro.",
        v1976 = "v03", v1992 = "V03", v2001 = "V06", v2012 = "P03", v2024 = "v03_pared",
        notas = "1976/1992: 1=Adobe revocado→2, 2=Adobe/tapial→2, 3=Ladrillo/bloque/cemento→1, 4=Piedra→4, 5=Madera→3, 6=Caña/palma→3, 7=Otros→5. 2001/2012/2024: 1=Ladrillo→1, 2=Adobe/tapial→2, 3=Tabique/quinche→3, 4=Piedra→4, 5=Madera→3, 6=Caña/palma→3, 7=Otro→5.",
        tabla = "vivienda")

add_var("material_techo", "Material de construcción del techo",
        "Material predominante del techo. 1=Calamina/Plancha/Teja, 2=Losa de hormigón, 3=Paja/Caña/Palma/Barro, 4=Otro.",
        v1976 = "v04", v1992 = "V04", v2001 = "V08", v2012 = "P05", v2024 = "v05_techo",
        notas = "Códigos muy consistentes entre censos: 1=Calamina→1, 2=Tejas→1, 3=Losa hormigón→2, 4=Paja/caña/palma→3, 5=Otro→4. Idéntico en los 5 censos.",
        tabla = "vivienda")

add_var("material_piso", "Material del piso",
        "Material predominante del piso. 1=Tierra, 2=Cemento/Ladrillo, 3=Mosaico/Parquet/Madera, 4=Otro.",
        v1976 = "v05", v1992 = "V05", v2001 = "V09", v2012 = "P06", v2024 = "v06_piso",
        notas = "1976/1992: 1=Madera→3, 2=Mosaico→3, 3=Ladrillo→2, 4=Cemento→2, 5=Tierra→1, 6=Otros→4. 2001/2012/2024: 1=Tierra→1, y demás materiales mapeados a 2-4.",
        tabla = "vivienda")

add_var("fuente_agua", "Fuente de agua para beber y cocinar",
        "Fuente principal de agua. 1=Cañería/red pública, 2=Otra fuente protegida (pozo con bomba, carro, pileta), 3=Fuente no protegida (río, acequia, pozo sin bomba).",
        v1976 = "v07", v1992 = "V07", v2001 = "V10", v2012 = "P07", v2024 = "v07_aguapro",
        notas = "1976 usa v07 (procedencia), no v06 (distribución). 1976: 1/2=Red→1, 3/4=Pozo/aljibe→2, 5=Río/lago→3, 6=Carro→2, 7=Otra→2. 1992: 1=Red→1, 2=Pozo→2, 3=Río→3, 4=Carro→2, 5=Otra→2. 2001: 1=Cañería→1, 2=Pileta→1, 3=Carro→2, 4=Pozo bomba→2, 5=Pozo sin bomba→3, 6/7=Río/lago→3. 2024: 3=Cosecha lluvia→3, 6=Vertiente protegida→2.",
        tabla = "vivienda")

add_var("energia_electrica", "Disponibilidad de energía eléctrica",
        "Si el hogar cuenta con energía eléctrica (cualquier fuente). 1=Sí, 2=No.",
        v1976 = "v09", v1992 = "V09", v2001 = "V15", v2012 = "P11", v2024 = "v09_energia",
        notas = "1976/1992: 1=Sí, 2=No. 2001 V15: 5=Sí→1, 6=No→2 (codificación distinta). 2012 P11: 1-4=cualquier fuente (red/motor/solar/otra)→1, 5=No tiene→2. 2024: 1-4=cualquier fuente→1, 5=No tiene→2.",
        tabla = "vivienda")

add_var("servicio_sanitario", "Disponibilidad de servicio sanitario",
        "Si el hogar tiene baño, water o letrina. 1=Sí tiene, 2=No tiene.",
        v1976 = "v081", v1992 = "V08", v2001 = "V12", v2012 = "P09", v2024 = "v15_servsan",
        notas = "1976: 1/2=Tiene→1, 3=No→2. 1992: 1/2=Tiene (con/sin descarga)→1, 3=No→2. 2001: 1=Tiene→1, 2=No→2. 2012 P09: 1/2=Tiene (privado/compartido)→1, 3=No→2. 2024: 1/2=Tiene (solo/compartido)→1, 3=No→2.",
        tabla = "vivienda")

add_var("tenencia_vivienda", "Tenencia de la vivienda",
        "Forma en que el hogar ocupa la vivienda. 1=Propia, 2=Alquilada, 3=Cedida/anticrético/servicios, 4=Otra.",
        v1976 = "v14", v1992 = "V14", v2001 = "V21", v2012 = "P19", v2024 = "v17_tenencia",
        notas = "Categorías muy consistentes entre censos. 1→1 (Propia), 2→2 (Alquiler), anticrético/cedida/servicios→3, otro→4. 2024: código 1/2=Propia pagada/pagando→1, código 4=Alquilada→2, códigos 3/5/6/7=Cedida/anticr/servicios→3, 8=Otra→4.",
        tabla = "vivienda")

add_var("habitaciones_total", "Total de habitaciones del hogar",
        "Número de habitaciones que ocupa el hogar (sin contar baño y cocina).",
        v1976 = "v10", v1992 = "V10", v2001 = "V18", v2012 = "P14", v2024 = "v13_habitac",
        notas = "Variable numérica en 1976/1992/2001. 2012 P14: valores 1-7 directos, 8='8 y más', 98/99=NA. 2024 v13_habitac codificada como categorías ordinales (1=Una, ..., 8=Ocho o más). Se recomienda tratar como ordinal.",
        tabla = "vivienda")


# ===========================================================================
# Guardar
# ===========================================================================

usethis::use_data(variable_temporal_map, overwrite = TRUE)
message("variable_temporal_map guardado en data/variable_temporal_map.rda")
message("\nVariables armonizadas (", nrow(variable_temporal_map), " total) por tabla:")
print(table(variable_temporal_map$tabla))
message("\nDetalle:")
print(variable_temporal_map[, c("variable", "etiqueta", "tabla")])
