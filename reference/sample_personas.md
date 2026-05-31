# Datos de muestra del CPV-2024 (100 filas por departamento)

Subconjunto de los microdatos de personas del Censo de Población y
Vivienda 2024, extraído de los fixtures de prueba: 100 filas de cada uno
de los 9 departamentos (900 registros en total). Incluye las variables
más utilizadas para análisis demográficos.

## Usage

``` r
sample_personas
```

## Format

Un data.frame con 900 filas y 16 columnas:

- idep:

  Código de departamento (01-09)

- iprov:

  Código de provincia

- imun:

  Código de municipio

- i00:

  Identificador de hogar

- p24_parentes:

  Parentesco con jefa/jefe de hogar (1-16)

- p25_sexo:

  Sexo: 1 = Mujer, 2 = Hombre

- p26_edad:

  Edad en años cumplidos

- g_edad:

  Grupo de edad: 1 = 0-14, 2 = 15-64, 3 = 65+

- p38_asiste:

  Asistencia a establecimiento educativo

- p40_lee:

  Sabe leer y escribir: 1 = Sí, 2 = No

- nivel_edu:

  Nivel educativo: 1 = Ninguno, 2 = Primaria, 3 = Secundaria, 4 =
  Superior

- aestudio:

  Años de estudio aprobados

- p32_pueblo_per:

  Se auto-identifica con un pueblo indígena: 1 = Sí, 2 = No, 3 = NS/NR

- p32_pueblos:

  Nombre del pueblo indígena (si aplica)

- p53_ecivil:

  Estado civil

- p28_cn:

  Nacimiento inscrito en el registro civil boliviano

## Source

INE Bolivia, CPV-2024. Microdatos de personas (muestra de prueba).

## Details

Este dataset está diseñado para ejemplos y prototipado rápido sin
necesidad de descargar los datos completos.

## See also

\[get_personas()\] para acceder a los datos completos.
