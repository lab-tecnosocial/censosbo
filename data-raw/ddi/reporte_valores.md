# Contraste de `valores_codigos`: REDATAM vs DDI del ANDA

Generado por `data-raw/taxonomia/completar_valores.R` (vía
`add_taxonomia_to_codebook.R`). **No modifica ningún valor preexistente**:
las variables que ya tenían códigos se comparan y se reportan aquí; solo se
rellenan las que estaban vacías.

Los códigos y etiquetas se comparan normalizados (minúsculas, sin acentos,
sin puntuación, ceros a la izquierda irrelevantes), así que lo que aparece
abajo son diferencias reales de contenido, no de formato.

## Severidad

- **GRAVE** — la mayoría de los códigos comunes tienen etiquetas que no se
  parecen: el DDI probablemente le pegó a esa variable las categorías de otra
  pregunta. Es un error del metadato del INE, no del paquete.
- **CODIFICACION** — los dos catálogos describen lo mismo con códigos
  distintos (el DDI usa letras y REDATAM números para la misma clasificación).
  Usar las etiquetas del DDI sobre datos de REDATAM daría un cruce equivocado.
- **CODIGOS** — a uno de los dos le faltan categorías que el otro sí tiene.
- **CENTINELA** — difieren solo en los códigos de no respuesta.
- **REDACCION** — truncamiento del DDI, tildes, «Sí» vs «Si». Ruido.

## Por qué se completan tan pocas

Las variables categóricas sin `valores_codigos` en 2012 y 2001 son, casi
todas, claves geográficas (`idep`, `iprov`, `imun`) y códigos de
clasificación ocupacional o de actividad económica. Ni unas ni otros llevan
etiquetas de valor enumerables en el DDI: las geográficas se resuelven con
`etiquetar_geografia()` y los códigos COB/CAEB son catálogos de cientos de
entradas que el ANDA no publica. En la práctica, REDATAM ya trae todas las
etiquetas de valor que existen, así que el aporte del DDI en este frente es
marginal; su valor real está en `codebook_docs_meta` (definición, universo,
pregunta literal e instrucciones al censista).

## Censo 2012

### Completadas desde el DDI (0)

_ninguna_

### Discrepancias en las que ya tenían códigos (11)

Severidad — GRAVE: 1 · CODIFICACION: 1 · CODIGOS: 2 · CENTINELA: 3 · REDACCION: 4.

### [GRAVE] `P45` / persona — Estado Civil
- etiqueta distinta: `1` REDATAM="Soltera(o)" vs DDI="buscó trabajo habiendo trabajado antes"; `2` REDATAM="Casada(o)" vs DDI="buscó trabajo por primera vez"; `3` REDATAM="Conviviente o concubina(o)" vs DDI="estuvo estudiando"; `4` REDATAM="Separada(o)" vs DDI="realizó labores de casa"; `5` REDATAM="Divorciada(o)" vs DDI="es jubilado, pensionista o rentista"; `6` REDATAM="Viuda(o)" vs DDI="Otra"

### [CODIFICACION] `P44` / persona — Actividad económica del establecimiento donde trabaja
- solo en el DDI: `A` = Agricultura, ganaderia, silvicultura y pesca, `B` = Explotación de minas y canteras, `C` = Industria manufacturera, `D` = Suministro de electricidad Gas, vapor y aire acondicionado, `E` = Suministro de agua, evacuacion de aguas residuales, gestion, `F` = Construccion, `G` = Comercio al por mayor y menor, reparacion de vehiculos, `H` = Transporte y almacenamiento, `I` = Actividades de alojamiento y de servicios de comida, `J` = Informacion y comunicaciones, `K` = Actividades financieras y de seguros, `L` = Actividades inmobiliarias, `M` = Actividades profesionales, cientificas y tecnicas, `N` = Actividades de servicios administrativos y de apoyo, `O` = Administracion publica, defensa y planes de seguridad social, `P` = Servicios de Educación, `Q` = Servicios de salud y de asistencia social, `R` = Actividades artisticas, de entretenimiento y recreativas, `S` = Otras actividades de servicios, `T` = Actividades de los hogares privados como empleadores, activi, `U` = Servicios de organizaciones y órganos extraterritoriales, `V` = Sin especificar, `W` = Descripciones incompletas
- solo en REDATAM: `1` = A: Agricultura, ganadería, silvicultura y pesca, `10` = J: Información y comunicaciones, `11` = K: Actividades financieras y de seguros, `12` = L: Actividades inmobiliarias, `13` = M: Actividades profesionales, científicas y técnicas, `14` = N: Actividades de servicios administrativos y de apoyo, `15` = O: Administración pública, defensa y planes de seguridad social de afiliacion obligatoria, `16` = P: Servicios de Educación, `17` = Q: Servicios de salud y de asistencia social, `18` = R: Actividades artísticas, de entretenimiento y recreativas, `19` = S: Otras actividades de servicios, `2` = B: Explotación de minas y canteras, `20` = T: Actividades de los hogares privados como empleadores, actividades no diferenciadas de los hogares como productores de bienes y servicios como uso propio, `21` = U: Servicios de organizaciones y órganos extraterritoriales, `22` = V: Sin especificar, `23` = W: Descripciones incompletas, `3` = C: Industria manufacturera, `4` = D: Suministro de electricidad Gas, vapor y aire acondicionado, `5` = E: Suministro de agua, evacuación de aguas residuales, gestion de desechos y descontaminación, `6` = F: Construcción, `7` = G: Comercio al por mayor y menor, reparación de vehículos, `8` = H: Transporte y almacenamiento, `9` = I: Actividades de alojamiento y de servcios de comida

### [CODIGOS] `P23` / persona — Relación de parentesco con jefa o jefe del hogar
- solo en REDATAM: `12` = Persona en tránsito, `13` = Persona que vive en la calle

### [CODIGOS] `P37A_NIVELNUE` / persona — Nivel más alto de instrucción que aprobó
- solo en el DDI: `4` = Sistema Antiguo: Básico (1 a 5 años), `5` = Sistema Antiguo: Intermedio (1 a 3 años), `6` = Sistema Antiguo: Medio (1 a 4 años), `7` = Sistema Anterior: Primaria (1 a 8 años), `8` = Sistema Anterior: Secundario 1 a 4 años)
- solo en REDATAM: `99` = Sin especificar

### [CENTINELA] `P35` / persona — Sabe leer y escribir
- solo en REDATAM: `9` = Sin especificar

### [CENTINELA] `P36` / persona — Asiste a una escuela o colegio
- solo en REDATAM: `9` = Sin especificar

### [CENTINELA] `P26` / persona — Su nacimiento está inscrito en el registro civil o cívico
- solo en REDATAM: `9` = Sin especificar

### [REDACCION] `P01` / vivienda — Tipo de vivienda
- etiqueta distinta: `6` REDATAM="Vivienda colectiva (Hoteles, Hospitales, Asilos, Cuarteles, Otros)" vs DDI="Vivienda colectiva (Hoteles, Hospitales, Asilos, Cuarteles,"

### [REDACCION] `P02` / vivienda — Condición de Ocupación de la vivienda
- etiqueta distinta: `0` REDATAM="Vivienda ocupada sin persona de referencia" vs DDI="Vivienda ocupada con personas presentes sin Jefe"

### [REDACCION] `P08` / vivienda — Como se distribuye el agua que utilizan
- etiqueta distinta: `2` REDATAM="Por cañería fuera de la vivienda , pero dentro del lote o terreno" vs DDI="Por cañería fuera de la vivienda , pero dentro del lote o te"; `9` REDATAM="Sin especificar" vs DDI="Ignorado"

### [REDACCION] `P27` / persona — Tiene carnet o cédula de identidad
- etiqueta distinta: `1` REDATAM="Sí" vs DDI="Si"


## Censo 2001

### Completadas desde el DDI (1)

- `idep` / persona — 9 categorías (Chuquisaca; La Paz; Cochabamba; Oruro)

### Discrepancias en las que ya tenían códigos (44)

Severidad — CODIGOS: 4 · CENTINELA: 5 · REDACCION: 35.

### [CODIGOS] `V06` / vivienda — Material de Construcción mas utilizado en las paredes de la vivienda
- solo en el DDI: `0` = No permitido, `9` = Múltiple
- etiqueta distinta: `1` REDATAM="LADRILLO, BLOQUE DE CEMENTO, HORMIGON" vs DDI="Ladrillo/Bloque de cemento/Hormigón"

### [CODIGOS] `V08` / vivienda — Material mas utilizado en los Techos de la vivienda
- solo en el DDI: `0` = No permitido, `9` = Múltiple
- etiqueta distinta: `1` REDATAM="CALAMINA, PLANCHA" vs DDI="Calamina o plancha"; `2` REDATAM="TEJAS" vs DDI="Tejas (cemento/arcilla/fibrocemento)"; `3` REDATAM="LOSA DE HORMIGON ARMADO" vs DDI="Losa de hormigón armado"

### [CODIGOS] `V09` / vivienda — Material mas utilizado en los Pisos de la vivienda
- solo en el DDI: `0` = No permitido, `9` = Múltiple
- etiqueta distinta: `2` REDATAM="TABLON DE MADERA" vs DDI="Tablón de madera"; `4` REDATAM="ALFOMBRA, TAPIZON" vs DDI="Alfombra/tapizón"; `6` REDATAM="MOSAICO, BALDOSA, CERAMICA" vs DDI="Mosaico/Baldosa/Cerámica"

### [CODIGOS] `V16` / vivienda — Principalmente, ¿que tipo de combustible o energia utiliza para cocina
- solo en el DDI: `8` = Múltiple
- etiqueta distinta: `2` REDATAM="GUANO, BOSTA, TAQUIA" vs DDI="Guano/Bosta o taquia"; `3` REDATAM="KEROSEN" vs DDI="Kerosén"; `4` REDATAM="GAS" vs DDI="Gas (garrafa o por cañería)"

### [CENTINELA] `P36` / persona — Sabe leer y escribir
- solo en REDATAM: `9` = Sin especificar

### [CENTINELA] `P37` / persona — Asiste a una escuela o colegio
- solo en REDATAM: `9` = Sin especificar
- etiqueta distinta: `2` REDATAM="SI A UNA PUBLICA" vs DDI="Si, a una pública"; `3` REDATAM="SI A UNA PRIVADA" vs DDI="Sí a una privada"

### [CENTINELA] `P38` / persona — Nivel de Asistencia
- solo en REDATAM: `99` = Sin especificar
- etiqueta distinta: `12` REDATAM="EDUCACION PREESCOLAR" vs DDI="Educación Pre-escolar (Pre kínder - Kínder)"; `16` REDATAM="PRIMARIA" vs DDI="Primaria (Básico e intermedio)"; `17` REDATAM="SECUNDARIA" vs DDI="Secundaria (Medio)"

### [CENTINELA] `P39NIV` / persona — Nivel más alto de instrucción que aprobó
- solo en REDATAM: `99` = Sin especificar
- etiqueta distinta: `12` REDATAM="EDUCACION PREESCOLAR" vs DDI="Educación Pre-escolar (Pre Kínder-Kínder)"; `13` REDATAM="BASICO" vs DDI="Básico"; `18` REDATAM="LICENCIATURA" vs DDI="Universidad - Licenciatura"; `19` REDATAM="TECNICO" vs DDI="Universidad - Técnico"; `22` REDATAM="TECNICO DE INSTITUTO" vs DDI="Técnico de Instituto"

### [CENTINELA] `P40NIV` / persona — Para ingresar al nivel no universitario, que nivel aprobó
- solo en REDATAM: `99` = Sin especificar
- etiqueta distinta: `13` REDATAM="BASICO" vs DDI="Básico"

### [REDACCION] `V04` / vivienda — Tipo de Vivienda
- etiqueta distinta: `13` REDATAM="HABITACIONES SUELTAS" vs DDI="Cuartos o habitaciones sueltas"; `14` REDATAM="VIVIENDA IMPROVISADA" vs DDI="Vivienda improvisada o vivienda móvil"; `15` REDATAM="LOCAL NO DESTINADO PARA HABITACION" vs DDI="Local no destinado para habitación"; `17` REDATAM="HOSPITAL, CLINICA" vs DDI="Hospital - Clínica"; `19` REDATAM="CONVENTO" vs DDI="Convento o residencia religiosa"; `20` REDATAM="INTERNADO" vs DDI="Internado o residencia educativa"; `21` REDATAM="ESTABLECIMIENTO MILITAR" vs DDI="Establecimiento militar o policial"; `22` REDATAM="CARCEL, ESTABLEC. CORRECCIONAL" vs DDI="Cárcel o establecimiento correccional"; `24` REDATAM="TRANSEUNTES" vs DDI="Transeúntes y personas que viven en la calle"

### [REDACCION] `V05` / vivienda — Condicion de ocupacion
- etiqueta distinta: `1` REDATAM="HABITANTES PRESENTES" vs DDI="Ocupadas con habitantes presentes"; `2` REDATAM="HABITANTES AUSENTES" vs DDI="Ocupadas con habitantes ausentes"; `3` REDATAM="ALQUILER O VENTA" vs DDI="Desocupadas para alquilar y/o vender"; `4` REDATAM="EN CONSTRUCCION O REPARACION" vs DDI="Desocupadas en construcción o reparación"

### [REDACCION] `V07` / vivienda — Paredes interiores de esta vivienda tienen revoque
- etiqueta distinta: `7` REDATAM="SI" vs DDI="Sí"

### [REDACCION] `V10` / vivienda — Principalmente, ¿de donde obtiene el agua para beber y cocinar?
- etiqueta distinta: `1` REDATAM="CAÑERIA DE RED" vs DDI="Cañería de red"; `2` REDATAM="PILETA PUBLICA" vs DDI="Pileta pública"; `3` REDATAM="CARRO REPARTIDOR" vs DDI="Carro repartidor (aguatero)"; `6` REDATAM="RIO, VERTIENTE, ACEQUIA" vs DDI="Río/Vertiente/Acequia"

### [REDACCION] `V11` / vivienda — El agua para beber y cocinar se distribuye...
- etiqueta distinta: `6` REDATAM="POR CAÑERIA DENTRO VIVIENDA" vs DDI="Por cañería dentro la vivienda"; `7` REDATAM="POR CAÑERIA FUERA VIVIENDA" vs DDI="Por cañería fuera de la vivienda, dentro del lote"; `8` REDATAM="NO SE DIST. POR CAÑERIA" vs DDI="No se distribuye por cañería"

### [REDACCION] `V12` / vivienda — ¿Tiene baño, water o letrina?
- etiqueta distinta: `1` REDATAM="TIENE BANO" vs DDI="Tiene baño"; `2` REDATAM="NO TIENE BANO" vs DDI="No tiene baño"

### [REDACCION] `V13` / vivienda — El baño, water o letrina es...
- etiqueta distinta: `3` REDATAM="USO SOLO POR EL HOGAR" vs DDI="Usado solo por su hogr"; `4` REDATAM="COMPARTE CON OTROS HOGARES" vs DDI="Compartido con otros hogares"

### [REDACCION] `V14` / vivienda — El baño, water o letrina tiene desague...
- etiqueta distinta: `2` REDATAM="CAMARA SEPTICA" vs DDI="Cámara séptica"; `4` REDATAM="SUPERFICIE" vs DDI="Superficie (calle/quebrada/río)"

### [REDACCION] `V15` / vivienda — ¿Usa energia electrica para alumbrar esta vivienda?
- etiqueta distinta: `5` REDATAM="SI" vs DDI="Sí"

### [REDACCION] `V17` / vivienda — Tiene un cuarto solo para cocinar
- etiqueta distinta: `7` REDATAM="SI" vs DDI="Sí"

### [REDACCION] `V18` / vivienda — Cuantos cuartos o habitaciones ocupa su hogar, sin contar cuartos de b
- etiqueta distinta: `8` REDATAM="OCHO O MAS" vs DDI="Ocho o más"

### [REDACCION] `V19` / vivienda — De estos cuartos o habitaciones, ¿cuántos se utilizan para dormir?
- etiqueta distinta: `8` REDATAM="OCHO O MAS" vs DDI="Ocho o más"

### [REDACCION] `V21` / vivienda — La vivienda que ocupan es
- etiqueta distinta: `3` REDATAM="CONTRATO, ANTICRETICO" vs DDI="Contrato anticrético"; `7` REDATAM="OTRO" vs DDI="Otra"

### [REDACCION] `V221` / vivienda — En este hogar, ¿cuantas personas presentan ceguera?
- etiqueta distinta: `0` REDATAM="NINGUNO" vs DDI="Ninguna"; `1` REDATAM="UNO" vs DDI="1"; `2` REDATAM="DOS" vs DDI="2"; `3` REDATAM="TRES Y MAS" vs DDI="3 o más"

### [REDACCION] `V222` / vivienda — En este hogar, ¿cuantas personas presentan sordomudez?
- etiqueta distinta: `0` REDATAM="NINGUNO" vs DDI="Ninguna"; `1` REDATAM="UNO" vs DDI="1"; `2` REDATAM="DOS" vs DDI="2"; `3` REDATAM="TRES Y MAS" vs DDI="3 o más"

### [REDACCION] `V223` / vivienda — En este hogar, ¿cuantas personas presentan paralisis, amputación?
- etiqueta distinta: `0` REDATAM="NINGUNO" vs DDI="Ninguna"; `1` REDATAM="UNO" vs DDI="1"; `2` REDATAM="DOS" vs DDI="2"; `3` REDATAM="TRES Y MAS" vs DDI="3 o más"

### [REDACCION] `V23` / vivienda — Durante el año 2000, murió alguna persona que vivia con ustedes
- etiqueta distinta: `1` REDATAM="SI" vs DDI="Sí"

### [REDACCION] `V24` / vivienda — Esta persona, era mujer de 15 años o mas años de edad
- etiqueta distinta: `1` REDATAM="SI" vs DDI="Sí"

### [REDACCION] `V25` / vivienda — Su fallecimiento se produjo...
- etiqueta distinta: `5` REDATAM="HASTA LOS 2 MESES" vs DDI="Hasta los 2 meses despues de dar a luz"

### [REDACCION] `P30` / persona — Su nacimiento esta inscrito en el registro civil
- etiqueta distinta: `3` REDATAM="SI" vs DDI="Sí"

### [REDACCION] `P31` / persona — Relación o parentesco con jefa o jefe del hogar
- etiqueta distinta: `1` REDATAM="JEFE(A) DEL HOGAR" vs DDI="Jefe o jefa del hogar"; `9` REDATAM="PARIENTE EMPLEADA(O) DEL HOGAR" vs DDI="Pariente de la empleada(o) del hogar"; `10` REDATAM="OTRO NO PARIENTE" vs DDI="Otro que no es pariente"; `11` REDATAM="MIEMBRO DE VIVIENDA COLECTIVA" vs DDI="MIEMBRODE VIVIENDA COLECTIVA"

### [REDACCION] `P324` / persona — Idioma o lengua que habla 4to Código
- etiqueta distinta: `1` REDATAM="GUARANI" vs DDI="Guaraní"

### [REDACCION] `P33A` / persona — Donde vive habitualmente
- etiqueta distinta: `1` REDATAM="AQUI" vs DDI="Aquí"; `2` REDATAM="EN OTRO LUGAR" vs DDI="En otro lugar del país"

### [REDACCION] `P34A` / persona — Donde nació
- etiqueta distinta: `1` REDATAM="AQUI" vs DDI="Aquí"; `2` REDATAM="EN OTRO LUGAR" vs DDI="En otro lugar del país"

### [REDACCION] `P35` / persona — Idioma o lengua que aprendió a hablar en su niñez
- etiqueta distinta: `4` REDATAM="GUARANI" vs DDI="Guaraní"

### [REDACCION] `P41A` / persona — Dónde vivia hace 5 años
- etiqueta distinta: `1` REDATAM="AQUI" vs DDI="Aquí"; `2` REDATAM="EN OTRO LUGAR" vs DDI="En otro lugar del país"; `4` REDATAM="AUN NO NACIO" vs DDI="Aún no nació"

### [REDACCION] `P42` / persona — Durante la semana pasada, ¿trabajo?
- etiqueta distinta: `1` REDATAM="SI" vs DDI="Sí"

### [REDACCION] `P43` / persona — Si no trabajo, que hizo la semana pasada
- etiqueta distinta: `1` REDATAM="TENIA TRABAJO" vs DDI="Tenía trabajo, pero no trabajo"; `2` REDATAM="ATENDIO CULTIVO AGRICOLA O GANADO" vs DDI="Atendió en los cultivos agrícolas"; `3` REDATAM="ATEND ALGUN NEGOCIO PROPIO O FAMILIAR" vs DDI="Atendió en algún negocio propio o familiar"; `4` REDATAM="REALIZO ALGUNA ACTIVIDAD POR INGRESO" vs DDI="Realizó alguna actividad por ingreso"

### [REDACCION] `P44` / persona — Durante la semana pasada...
- etiqueta distinta: `1` REDATAM="BUSCO TRABAJO" vs DDI="Busco trabajo habiendo trabajado antes"; `4` REDATAM="REALIZA LABORES DE CASA" vs DDI="Realizó labores de casa"

### [REDACCION] `P46` / persona — En esa ocupación usted trabajó como...
- etiqueta distinta: `3` REDATAM="OBRERO, EMPLEADO" vs DDI="Obrero o empleado"; `5` REDATAM="PATRON, SOCIO O EMPLEADOR" vs DDI="Patrón, socio o empleador"; `6` REDATAM="COOPERATIVISTA" vs DDI="Cooperativista de producción"; `7` REDATAM="TRABAJADOR FAMILIAR O APRENDIZ SIN REMUNERACION" vs DDI="Trabajador familiar o aprendíz sin remuneración"

### [REDACCION] `P48` / persona — Estado Civil
- etiqueta distinta: `3` REDATAM="CONVIVIENTE O CONCUBINO" vs DDI="Conviviente o concubino(a)"

### [REDACCION] `P491` / persona — Se considera perteneciente a alguno de los pueblos originarios o indíg
- etiqueta distinta: `3` REDATAM="GUARANI" vs DDI="Guaraní"

### [REDACCION] `P53M` / persona — Mes que nació su última hija(o) nacida (o) viva (o)
- etiqueta distinta: `99` REDATAM="SIN RESPUESTA" vs DDI="Sin respuesta o no válido"

### [REDACCION] `P54` / persona — Donde tuvo lugar su último parto
- etiqueta distinta: `1` REDATAM="EN ESTABLECIMIENTO DE SALUD" vs DDI="En un establecimiento de salud"; `8` REDATAM="SIN DECLARACION" vs DDI="No válido"

### [REDACCION] `P55` / persona — ¿Quién atendio su parto?
- etiqueta distinta: `1` REDATAM="MEDICO" vs DDI="Médico"; `2` REDATAM="ENFERMERA" vs DDI="Enfermera o Auxiliar de enfermería"; `8` REDATAM="SIN DECLARACION" vs DDI="No válido"


## Censo 1992

### Completadas desde el DDI (1)

- `idep` / persona — 9 categorías (Chuquisaca; La paz; Cochabamba; Oruro)

### Discrepancias en las que ya tenían códigos (25)

Severidad — GRAVE: 3 · CODIGOS: 1 · CENTINELA: 2 · REDACCION: 19.

### [GRAVE] `V09` / vivienda — Tiene energía eléctrica
- etiqueta distinta: `1` REDATAM="Si" vs DDI="Si tiene energía eléctrica"; `2` REDATAM="No" vs DDI="No tiene energía eléctrica"

### [GRAVE] `P07` / persona — Donde nació
- etiqueta distinta: `1` REDATAM="Aqui" vs DDI="Aquí"

### [GRAVE] `P08` / persona — Donde vivía hace 5 años
- etiqueta distinta: `1` REDATAM="Aqui" vs DDI="Aquí"

### [CODIGOS] `P12` / persona — Ciclo o Nivel más alto que asiste o asistió en la enseñanza regular
- solo en REDATAM: `0` = Primaria, `1` = Secundaria
- etiqueta distinta: `2` REDATAM="Basico" vs DDI="Básico"; `5` REDATAM="Ensenanza tecnica" vs DDI="Enseñanza técnica"

### [CENTINELA] `I122` / vivienda — Categoría rural
- solo en el DDI: `9` = No aplica

### [CENTINELA] `P06` / persona — Donde vive habitualmente
- solo en el DDI: `9` = Nr/ns (no responde)

### [REDACCION] `V01` / vivienda — Tipo de vivienda
- etiqueta distinta: `3` REDATAM="Habitaciones sueltas" vs DDI="Habitación suelta"; `7` REDATAM="Hotel, residencia o alojamiento" vs DDI="Hotel, residencial o alojamiento"; `8` REDATAM="Cuarte, establecimiento militar o policial" vs DDI="Cuartel, establecimiento militar o policial"; `10` REDATAM="Carcel o establecimiento correccional" vs DDI="Cárcel o establecimiento correccional"; `12` REDATAM="Otra colectiva" vs DDI="Otra"

### [REDACCION] `V02` / vivienda — Condición de ocupación
- etiqueta distinta: `1` REDATAM="Ocupada - ocupantes presentes" vs DDI="Ocupada con ocupantes presentes"; `2` REDATAM="Ocupada - ocupantes ausentes" vs DDI="Ocupada con ocupantes ausentes"; `3` REDATAM="Desocupada - alquiler, venta" vs DDI="Desocupada para alquiler, venta, etc."; `4` REDATAM="Desocupada - en construcción, reparación" vs DDI="Desocupada terminándose de construir o reparar"

### [REDACCION] `V03` / vivienda — Paredes
- etiqueta distinta: `3` REDATAM="Ladrillo, bloques de cemento, hormigón" vs DDI="Ladrillo, bloques de cemento, hormigón, etc."

### [REDACCION] `V04` / vivienda — Techos
- etiqueta distinta: `2` REDATAM="Tejas(cemento, arcilla, etc)" vs DDI="Tejas (cemento, arcilla, fibra, cemento, etc.)"; `3` REDATAM="Losa hormigón armado" vs DDI="Losa de hormigón armado"

### [REDACCION] `V05` / vivienda — Pisos
- etiqueta distinta: `1` REDATAM="Madera" vs DDI="Madera o baldosas"; `2` REDATAM="Mosaico o baldosas" vs DDI="Mosaico-baldosas"

### [REDACCION] `V06` / vivienda — Abastecimiento de agua para beber y cocinar
- etiqueta distinta: `1` REDATAM="Por cañería dentro de la vivienda" vs DDI="Por cañería dentra de la vivienda"; `2` REDATAM="Por cañería fuera de la vivienda, pero dentro del edificio, lote o terreno" vs DDI="Por cañería fuera de la vivienda, pero dentro del edificio,"; `3` REDATAM="Por cañería fiera del lote o terreno" vs DDI="Por cañería fuera del lote o terreno"

### [REDACCION] `V07` / vivienda — Procedencia del agua
- etiqueta distinta: `3` REDATAM="Rio, lago, vertiente o acequia" vs DDI="Río, lago, vertiente o acequía"

### [REDACCION] `V08` / vivienda — Servicio sanitario
- etiqueta distinta: `1` REDATAM="Tiene con descarga instantánea de agua" vs DDI="Tiene con descarga instantánea de agrua"; `3` REDATAM="No Tiene" vs DDI="No tiene servicio sanatorio"

### [REDACCION] `V12` / vivienda — Tiene un cuarto especial para la cocina
- etiqueta distinta: `1` REDATAM="Si" vs DDI="Tiene"; `2` REDATAM="No" vs DDI="No tiene"

### [REDACCION] `V13` / vivienda — Principal combustible utilizado para cocinar
- etiqueta distinta: `2` REDATAM="Guano, bosta o taquia" vs DDI="Guano, bosta, taquia"

### [REDACCION] `V17` / vivienda — En este hogar murió alguna persona el año pasado
- etiqueta distinta: `1` REDATAM="Si" vs DDI="Si murio"; `2` REDATAM="No" vs DDI="No murio"

### [REDACCION] `P02` / persona — Relación de parentesco con jefa o jefe del hogar
- etiqueta distinta: `0` REDATAM="Jefe o Jefa del hogar particular" vs DDI="Jefe(a) del hogar particular"; `3` REDATAM="Yerno_nuera" vs DDI="Yerno o nuera"; `6` REDATAM="Empleada(o) domestica(o)" vs DDI="Empleada(o) doméstica(o)"; `7` REDATAM="Otro no pariente" vs DDI="Otro pariente"

### [REDACCION] `P06A` / persona — Departamento donde vive habitualmente
- etiqueta distinta: `1` REDATAM="Chuquisaca" vs DDI="Sucre"; `5` REDATAM="Potosi" vs DDI="Potosí"

### [REDACCION] `P07A` / persona — Departamento donde nació
- etiqueta distinta: `1` REDATAM="Chuquisaca" vs DDI="Sucre"; `5` REDATAM="Potosi" vs DDI="Potosí"

### [REDACCION] `P08A` / persona — Departamento donde vivía hace 5 años
- etiqueta distinta: `1` REDATAM="Chuquisaca" vs DDI="Sucre"; `5` REDATAM="Potosi" vs DDI="Potosí"

### [REDACCION] `P09C` / persona — Idioma y/o dialecto - Aymara
- etiqueta distinta: `3` REDATAM="Aymara" vs DDI="Aymará"

### [REDACCION] `P09D` / persona — Idioma y/o dialecto - Guaraní
- etiqueta distinta: `4` REDATAM="Guarani" vs DDI="Guaraní"

### [REDACCION] `P15` / persona — Trabajo la semana pasada
- etiqueta distinta: `0` REDATAM="Trabajo la semana pasada" vs DDI="Trabajó la semana pasada"; `1` REDATAM="No trabajo pero tiene trabajo" vs DDI="No trabajó, pero tiene trabajo (licencia, enfermedad, vacaci"; `2` REDATAM="Realizo labores de casa y trabajo" vs DDI="Labores de casa y trabajó"; `3` REDATAM="Busco trabajo habiendo trabajado antes" vs DDI="Buscó trabajo, habiendo trabajado antes (cesante)"; `4` REDATAM="Busco trabajo por primera vez" vs DDI="Buscó trabajo por primera vez"; `5` REDATAM="Es jubilado, pensionista o rentista y no trabajo" vs DDI="Jubilado, pensionista o rentista y no trabajó"; `6` REDATAM="Es estudiante y no trabajo" vs DDI="Estudiante y no trabajó"; `7` REDATAM="Realizó labores de casa y no trabajo" vs DDI="Labores de casa y no trabajó"

### [REDACCION] `P18` / persona — Categoría Ocupacional
- etiqueta distinta: `4` REDATAM="Patron, socio o empleador" vs DDI="Patrón, socio o empleador"


## Censo 1976

### Completadas desde el DDI (1)

- `idep` / vivienda — 9 categorías (Chuquisaca; La Paz; Cochabamba; Oruro)

### Discrepancias en las que ya tenían códigos (21)

Severidad — GRAVE: 3 · CODIGOS: 1 · REDACCION: 17.

### [GRAVE] `v06` / vivienda — V06-ABASTE-AGUA
- etiqueta distinta: `1` REDATAM="CDV-CANERIA-DENT" vs DDI="Por cañería dentro de la vivienda"; `2` REDATAM="CFV-CANERIA-FUER" vs DDI="Por cañería fuera de la vivienda, pero dentro del edificio,"; `3` REDATAM="CFL-CANER-FUE-LO" vs DDI="Por cañería fuera del lote o terreno"; `4` REDATAM="NRC-NO-POR-CANER" vs DDI="No recibe agua por cañería"

### [GRAVE] `v081` / vivienda — V081-USO-SERV-S
- etiqueta distinta: `1` REDATAM="PRIVADO-DE-HOGAR" vs DDI="Tiene de uso privado o exclusivo"; `2` REDATAM="COMPARTIDO-OTROS" vs DDI="Tiene de uso común o compartido"

### [GRAVE] `v12` / vivienda — V12-COCINA
- etiqueta distinta: `1` REDATAM="TIENE-COCINA" vs DDI="Si"; `2` REDATAM="NO-TIENE-COCINA" vs DDI="No"

### [CODIGOS] `p14` / poblacion — NIVEL Y CURSO APROBADO
- solo en el DDI: `2` = Intermedio, `3` = Medio, `4` = Primaria, `5` = Secundaria, `6` = Normal, `7` = Universitario, `8` = Otro
- solo en REDATAM: `11` = BASICO 1, `12` = BASICO 2, `13` = BASICO 3, `14` = BASICO 4, `15` = BASICO 5, `21` = INTERMEDIO 1, `22` = INTERMEDIO 2, `23` = INTERMEDIO 3, `31` = MEDIO 1, `32` = MEDIO 2, `33` = MEDIO 3, `34` = MEDIO 4, `41` = PRIMARIA 1, `42` = PRIMARIA 2, `43` = PRIMARIA 3, `44` = PRIMARIA 4, `45` = PRIMARIA 5, `46` = PRIMARIA 6, `51` = SECUNDARIA 1, `52` = SECUNDARIA 2, `53` = SECUNDARIA 3, `54` = SECUNDARIA 4, `55` = SECUNDARIA 5, `56` = SECUNDARIA 6, `61` = NORMAL 1, `62` = NORMAL 2, `63` = NORMAL 3, `64` = NORMAL 4, `71` = UNIVERSIDAD 1, `72` = UNIVERSIDAD 2, `73` = UNIVERSIDAD 3, `74` = UNIVERSIDAD 4, `75` = UNIVERSIDAD 5, `81` = OTRO 1, `82` = OTRO 2, `83` = OTRO 3, `84` = OTRO 4
- etiqueta distinta: `1` REDATAM="SOLO ALFABETIZADO" vs DDI="Básico"

### [REDACCION] `dep` / poblacion — DEPARTAMENTO'
- etiqueta distinta: `3` REDATAM="COCHABAMBA" vs DDI="Chochabamba"; `5` REDATAM="POTOSI" vs DDI="Potosí"

### [REDACCION] `p02` / poblacion — RELACION DE PARENTESCO CON EL JEFE
- etiqueta distinta: `1` REDATAM="JEFE DEL HOGAR PART" vs DDI="Jefe (a)"; `2` REDATAM="ESPOSA(O) CONVIVIEN" vs DDI="Esposa o Conviviente"; `3` REDATAM="HIJO, ENTENADO" vs DDI="Hijo (a) o Entenado"; `5` REDATAM="NIETO" vs DDI="Nieto (a)"; `6` REDATAM="PADRES SUEGROS" vs DDI="Padre o Suegro"; `9` REDATAM="NO FAMILIAR,OTRO" vs DDI="No familiar"

### [REDACCION] `p10` / poblacion — LEE Y  ESCRIBE
- etiqueta distinta: `1` REDATAM="SI LEE Y ESCRIBE" vs DDI="Si"; `2` REDATAM="NO LEE NI ESCRIBE" vs DDI="No"

### [REDACCION] `p11` / poblacion — ASISTE A ESCUELA U OTRO CENTRO EDUCATIVO
- etiqueta distinta: `1` REDATAM="SI ASISTE" vs DDI="Si"; `2` REDATAM="NO ASISTE" vs DDI="No"

### [REDACCION] `p15` / poblacion — TRABAJO
- etiqueta distinta: `1` REDATAM="TRABAJO" vs DDI="Trabajó"; `2` REDATAM="NO TRABAJO PTT" vs DDI="No trabajo, pero tenía trabajo?"; `4` REDATAM="BUSCO TRABAJO" vs DDI="Buscó trabajo por primera vez?"; `5` REDATAM="SOLO LABORES DE CASA" vs DDI="Sólo labores de casa?"; `6` REDATAM="ESTUDIANTE, NO TRABAJÓ" vs DDI="Sólo estudiante?"; `7` REDATAM="JUBILADO RENTISTA" vs DDI="Jubilado y o rentista?"; `8` REDATAM="OTRO" vs DDI="Otros?.."

### [REDACCION] `p05` / poblacion — ESTADO CIVIL
- etiqueta distinta: `1` REDATAM="SOLTERO" vs DDI="Soltero (a)"; `2` REDATAM="CASADO" vs DDI="Casado (a) o conviviente"; `3` REDATAM="VIUDO" vs DDI="Viudo (a)"; `4` REDATAM="DIVOTVIADO" vs DDI="Divorciado (a) o Separado (a)"

### [REDACCION] `v01` / vivienda — V01-TIPO DE VIVIENDA
- etiqueta distinta: `13` REDATAM="HABITACIONES SUELTAS" vs DDI="habitación (es) sueltas (s) en casa de vecindad"; `16` REDATAM="NO CONST PARA VIVIEN" vs DDI="Local no destinado a vivienda"; `17` REDATAM="OTRA PARTICULAR" vs DDI="Otra"; `21` REDATAM="HOTEL, RESIDENCIA" vs DDI="Hotel, residencial"; `22` REDATAM="CUARTEL, EST.MILITAR" vs DDI="Cuartel, establecimiento militar o policial"; `23` REDATAM="HOSPITAL, CLINICA" vs DDI="Hospital, Sanatorio, Clínica"; `24` REDATAM="CARCEL,CORRECCIONAL" vs DDI="Cárcel , establecimiento correccional"; `25` REDATAM="CONVENTO,INST.RELIGI" vs DDI="Convento, institución correccional"; `26` REDATAM="INTERNADO EDUCACIONA" vs DDI="Internado educacional"; `27` REDATAM="OTRA COLECTIVA" vs DDI="Otra"

### [REDACCION] `v02` / vivienda — V02-CONDICION DE OCUPACION
- etiqueta distinta: `1` REDATAM="OCUPANTES PRESENTES" vs DDI="Con ocupantes presentes"; `2` REDATAM="OCUPANTES AUSENTES" vs DDI="Con ocupantes ausentes"

### [REDACCION] `v03` / vivienda — V03-PAREDES
- etiqueta distinta: `1` REDATAM="ADOBE-RVOCADO" vs DDI="Adobe revocado"; `2` REDATAM="ADS-TAPIAL" vs DDI="Adobe sin revocar y tapial"; `3` REDATAM="LADRILLOS-BLCEME" vs DDI="Ladrillo, bloque de cemento, etc."; `6` REDATAM="CANA-PALMA-TROCO" vs DDI="Caña, palma ,trocos"

### [REDACCION] `v04` / vivienda — V04-TECHOS
- etiqueta distinta: `2` REDATAM="TEJAS" vs DDI="Tejas (Cemento, arcilla, fibrocemento, etc.)"; `3` REDATAM="LOSA-HORMIGON" vs DDI="Losa de hormigón"; `4` REDATAM="PAJA-CANA-PALMA" vs DDI="Paja, caña, palma"

### [REDACCION] `v05` / vivienda — V05-PISOS
- etiqueta distinta: `2` REDATAM="MOSAICO-BALDOSAS" vs DDI="Mosaico o baldosas"

### [REDACCION] `v07` / vivienda — V07-PROCED-AGUA
- etiqueta distinta: `1` REDATAM="RED-PUBLICA" vs DDI="Red pública"; `5` REDATAM="RIO-LAGO-VERTIEN" vs DDI="Rio, lago, vertiente o acequia"

### [REDACCION] `v082` / vivienda — V082-DESAGUE-SS
- etiqueta distinta: `1` REDATAM="ALCANTARILLADO-P" vs DDI="Alcantarillado público"; `2` REDATAM="CAMARA-SEPTICA" vs DDI="Cámara séptica"; `3` REDATAM="LETRINA-POZO-CIE" vs DDI="Letrina o pozo ciego"

### [REDACCION] `v083` / vivienda — V083-DUCHA-TINA
- etiqueta distinta: `1` REDATAM="PRIVADO" vs DDI="Tiene de uso privado o exclusivo"; `2` REDATAM="COMPARTIDO" vs DDI="Tiene de uso común o compartido"

### [REDACCION] `v09` / vivienda — V09-ENERGIA-ELE
- etiqueta distinta: `1` REDATAM="SI-ENERGIA-ELECT" vs DDI="Si"; `2` REDATAM="NO-ENERGIA-ELECT" vs DDI="No"

### [REDACCION] `v14` / vivienda — V14-TENENCIA
- etiqueta distinta: `2` REDATAM="ALQUILADA" vs DDI="Alquiler"; `3` REDATAM="CONANT-CONTR-ANT" vs DDI="Contrato Alquiler"; `4` REDATAM="CONMIX-CONTR-MIX" vs DDI="Contrato mixto (Alquiler anticrético)"; `5` REDATAM="SERVICIOS-CEDIDA" vs DDI="Cedida por servicios"; `6` REDATAM="OTRA" vs DDI="Otra Forma"

### [REDACCION] `v15` / vivienda — V15-IDIOMA-HABLAN-FAMILI
- etiqueta distinta: `4` REDATAM="OTRO-NACIONAL" vs DDI="Otro idioma nacional"; `5` REDATAM="EXTANJERO" vs DDI="Idioma extranjero"


