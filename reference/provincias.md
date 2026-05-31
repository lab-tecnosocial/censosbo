# Lista las provincias de un departamento

Lista las provincias de un departamento

## Usage

``` r
provincias(departamento)
```

## Arguments

- departamento:

  Código (e.g., \`"07"\`) o nombre (e.g., \`"Santa Cruz"\`) del
  departamento. Acepta vectores.

## Value

Un data.frame con columnas \`idep\`, \`nombre_dep\`, \`iprov\`,
\`nombre_prov\`.

## Examples

``` r
provincias("Santa Cruz")
#>     idep nombre_dep iprov            nombre_prov
#> 253   07 Santa Cruz    01          Andrés Ibáñez
#> 258   07 Santa Cruz    02                 Warnes
#> 260   07 Santa Cruz    03                Velasco
#> 263   07 Santa Cruz    04                 Ichilo
#> 267   07 Santa Cruz    05              Chiquitos
#> 270   07 Santa Cruz    06                   Sara
#> 273   07 Santa Cruz    07             Cordillera
#> 280   07 Santa Cruz    08           Valle Grande
#> 285   07 Santa Cruz    09                Florida
#> 289   07 Santa Cruz    10     Obispo Santisteban
#> 294   07 Santa Cruz    11        Ñuflo de Chávez
#> 300   07 Santa Cruz    12         Ángel Sandoval
#> 301   07 Santa Cruz    13 Manuel María Caballero
#> 303   07 Santa Cruz    14           Germán Busch
#> 306   07 Santa Cruz    15               Guarayos
provincias("02")
#>     idep nombre_dep iprov               nombre_prov
#> 30    02     La Paz    01                   Murillo
#> 35    02     La Paz    02                  Omasuyos
#> 41    02     La Paz    03                   Pacajes
#> 49    02     La Paz    04                   Camacho
#> 54    02     La Paz    05                   Muñecas
#> 57    02     La Paz    06                  Larecaja
#> 65    02     La Paz    07              Franz Tamayo
#> 67    02     La Paz    08                    Ingavi
#> 74    02     La Paz    09                    Loayza
#> 79    02     La Paz    10                 Inquisivi
#> 85    02     La Paz    11                Sur Yungas
#> 90    02     La Paz    12                 Los Andes
#> 94    02     La Paz    13                     Aroma
#> 101   02     La Paz    14                Nor Yungas
#> 103   02     La Paz    15            Abel Iturralde
#> 105   02     La Paz    16         Bautista Saavedra
#> 107   02     La Paz    17               Manco Kapac
#> 110   02     La Paz    18      Gualberto Villarroel
#> 113   02     La Paz    19 General José Manuel Pando
#> 115   02     La Paz    20                  Caranavi
```
