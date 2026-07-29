# Tipos de vivienda de un censo y su grupo

Devuelve los códigos de la variable de tipo de vivienda de un censo, con
su etiqueta y el grupo al que pertenecen. Sirve para auditar qué
registros entran y salen con cada valor de \`universo\` en
\[get_viviendas_2024()\] y \[get_censo()\].

## Usage

``` r
tipos_vivienda(anio = 2024)
```

## Arguments

- anio:

  Entero. Año del censo: \`1976\`, \`1992\`, \`2001\`, \`2012\` o
  \`2024\`.

## Value

Un \`data.frame\` con las columnas:

- \`codigo\`:

  Código de la variable de tipo de vivienda.

- \`etiqueta\`:

  Etiqueta del diccionario del censo.

- \`grupo\`:

  \`"particular"\`, \`"colectiva"\`, \`"no_vivienda"\` (persona en la
  calle o en tránsito) o \`"sin_clasificar"\` (código que aparece en los
  microdatos pero no en el diccionario del censo).

- \`en_universo_viviendas\`:

  \`TRUE\` si el registro cuenta como vivienda para el INE, es decir si
  \`universo = "viviendas"\` lo conserva.

## Details

El grupo \`no_vivienda\` es la razón de que la entidad \`vivienda\` de
REDATAM tenga más registros que el total oficial de viviendas: son
personas censadas fuera de una vivienda. En el CPV-2024 son 10.287
registros (3.311 en la calle y 6.976 en tránsito) de 4.490.488, y
descontarlos da los 4.480.201 del INE.

El censo 1976 no tuvo categorías de calle ni tránsito: ahí ningún código
es \`no_vivienda\` y el universo oficial coincide con la entidad
completa.

Los códigos \`sin_clasificar\` (el 88 de 1976 y el 0 de 1992) \*\*se
conservan\*\* en \`universo = "viviendas"\`: no consta que sean calle ni
tránsito, así que descartarlos sería una decisión sin respaldo en el
diccionario. Sí quedan fuera de \`"particulares"\` y \`"colectivas"\`,
que son selecciones positivas.

## See also

\[get_viviendas_2024()\] y \[get_censo()\] para el argumento
\`universo\`.

## Examples

``` r
tipos_vivienda(2024)
#>    codigo                                         etiqueta       grupo
#> 1       1                                             Casa  particular
#> 2       2                                  Choza, pahuichi  particular
#> 3       3                                     Departamento  particular
#> 4       4             Cuarto(s) o habitación(es) suelta(s)  particular
#> 5       5            Vivienda improvisada o vivienda móvil  particular
#> 6       6       Establecimiento no destinado para vivienda  particular
#> 7       7         Hotel, hostal, residencial o alojamiento   colectiva
#> 8       8               Hospital o clínica con internación   colectiva
#> 9       9     Cuartel o establecimiento militar o policial   colectiva
#> 10     10             Residencia u otro de adultos mayores   colectiva
#> 11     11             Albergue de niñas(os) y adolescentes   colectiva
#> 12     12         Recinto penitenciario o de reintegración   colectiva
#> 13     13                            Campamento de trabajo   colectiva
#> 14     14     Otra (Instituto de rehabilitación, convento)   colectiva
#> 15     15                     Persona que vive en la calle no_vivienda
#> 16     16 En tránsito: terminal, aeropuerto, puerto u otro no_vivienda
#>    en_universo_viviendas
#> 1                   TRUE
#> 2                   TRUE
#> 3                   TRUE
#> 4                   TRUE
#> 5                   TRUE
#> 6                   TRUE
#> 7                   TRUE
#> 8                   TRUE
#> 9                   TRUE
#> 10                  TRUE
#> 11                  TRUE
#> 12                  TRUE
#> 13                  TRUE
#> 14                  TRUE
#> 15                 FALSE
#> 16                 FALSE

# Los códigos que no son vivienda en cada censo
for (a in c(1976, 1992, 2001, 2012, 2024)) {
  t <- tipos_vivienda(a)
  cat(a, ":", paste(t$etiqueta[t$grupo == "no_vivienda"], collapse = "; "), "\n")
}
#> 1976 :  
#> 1992 : Ambulante 
#> 2001 : TRANSEUNTES 
#> 2012 : En tránsito; Persona que vive en la calle 
#> 2024 : Persona que vive en la calle; En tránsito: terminal, aeropuerto, puerto u otro 
```
