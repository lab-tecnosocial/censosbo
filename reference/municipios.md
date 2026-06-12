# Lista los municipios de Bolivia

Lista los municipios de Bolivia

## Usage

``` r
municipios(departamento = NULL, provincia = NULL)
```

## Arguments

- departamento:

  Código o nombre del departamento. Opcional.

- provincia:

  Código de provincia. Opcional.

## Value

Un data.frame con columnas \`idep\`, \`nombre_dep\`, \`iprov\`,
\`nombre_prov\`, \`imun\`, \`nombre_mun\`.

## Examples

``` r
municipios(departamento = "Cochabamba")
#>    idep nombre_dep iprov   nombre_prov imun                 nombre_mun
#> 1    03 Cochabamba    01       Cercado   01                 Cochabamba
#> 2    03 Cochabamba    02       Campero   01                    Aiquile
#> 3    03 Cochabamba    02       Campero   02                   Pasorapa
#> 4    03 Cochabamba    02       Campero   03                   Omereque
#> 5    03 Cochabamba    03       Ayopaya   01                    Ayopaya
#> 6    03 Cochabamba    03       Ayopaya   02                  Morochata
#> 7    03 Cochabamba    03       Ayopaya   03                   Cocapata
#> 8    03 Cochabamba    04  Esteban Arze   01                     Tarata
#> 9    03 Cochabamba    04  Esteban Arze   02                    Anzaldo
#> 10   03 Cochabamba    04  Esteban Arze   03                    Arbieto
#> 11   03 Cochabamba    04  Esteban Arze   04                  Sacabamba
#> 12   03 Cochabamba    05         Arani   01                      Arani
#> 13   03 Cochabamba    05         Arani   02                      Vacas
#> 14   03 Cochabamba    06         Arque   01                      Arque
#> 15   03 Cochabamba    06         Arque   02                   Tacopaya
#> 16   03 Cochabamba    07      Capinota   01                   Capinota
#> 17   03 Cochabamba    07      Capinota   02                 Santiváñez
#> 18   03 Cochabamba    07      Capinota   03                     Sicaya
#> 19   03 Cochabamba    08 Germán Jordán   01                      Cliza
#> 20   03 Cochabamba    08 Germán Jordán   02                       Toco
#> 21   03 Cochabamba    08 Germán Jordán   03                     Tolata
#> 22   03 Cochabamba    09   Quillacollo   01                Quillacollo
#> 23   03 Cochabamba    09   Quillacollo   02                   Sipesipe
#> 24   03 Cochabamba    09   Quillacollo   03                  Tiquipaya
#> 25   03 Cochabamba    09   Quillacollo   04                      Vinto
#> 26   03 Cochabamba    09   Quillacollo   05                Colcapirhua
#> 27   03 Cochabamba    10       Chapare   01                     Sacaba
#> 28   03 Cochabamba    10       Chapare   02                     Colomi
#> 29   03 Cochabamba    10       Chapare   03               Villa Tunari
#> 30   03 Cochabamba    11      Tapacarí   01                   Tapacarí
#> 31   03 Cochabamba    12      Carrasco   01                     Totora
#> 32   03 Cochabamba    12      Carrasco   02                       Pojo
#> 33   03 Cochabamba    12      Carrasco   03                     Pocona
#> 34   03 Cochabamba    12      Carrasco   04                    Chimoré
#> 35   03 Cochabamba    12      Carrasco   05          Puerto Villarroel
#> 36   03 Cochabamba    12      Carrasco   06                 Entre Ríos
#> 37   03 Cochabamba    13        Mizque   01                     Mizque
#> 38   03 Cochabamba    13        Mizque   02                  Vila Vila
#> 39   03 Cochabamba    13        Mizque   03                     Alalay
#> 40   03 Cochabamba    13        Mizque   04            TIOC-Raqaypampa
#> 41   03 Cochabamba    14        Punata   01                     Punata
#> 42   03 Cochabamba    14        Punata   02               Villa Rivero
#> 43   03 Cochabamba    14        Punata   03                 San Benito
#> 44   03 Cochabamba    14        Punata   04                    Tacachi
#> 45   03 Cochabamba    14        Punata   05 Villa Gualberto Villarroel
#> 46   03 Cochabamba    15       Bolívar   01                    Bolívar
#> 47   03 Cochabamba    16       Tiraque   01                    Tiraque
#> 48   03 Cochabamba    16       Tiraque   02                  Shinahota
municipios(departamento = "02", provincia = "217")
#> [1] idep        nombre_dep  iprov       nombre_prov imun        nombre_mun 
#> <0 rows> (or 0-length row.names)
```
