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
#>     idep nombre_dep iprov   nombre_prov imun                 nombre_mun
#> 117   03 Cochabamba    01       Cercado   01                 Cochabamba
#> 118   03 Cochabamba    02       Campero   01                    Aiquile
#> 119   03 Cochabamba    02       Campero   02                   Pasorapa
#> 120   03 Cochabamba    02       Campero   03                   Omereque
#> 121   03 Cochabamba    03       Ayopaya   01                    Ayopaya
#> 122   03 Cochabamba    03       Ayopaya   02                  Morochata
#> 123   03 Cochabamba    03       Ayopaya   03                   Cocapata
#> 124   03 Cochabamba    04  Esteban Arze   01                     Tarata
#> 125   03 Cochabamba    04  Esteban Arze   02                    Anzaldo
#> 126   03 Cochabamba    04  Esteban Arze   03                    Arbieto
#> 127   03 Cochabamba    04  Esteban Arze   04                  Sacabamba
#> 128   03 Cochabamba    05         Arani   01                      Arani
#> 129   03 Cochabamba    05         Arani   02                      Vacas
#> 130   03 Cochabamba    06         Arque   01                      Arque
#> 131   03 Cochabamba    06         Arque   02                   Tacopaya
#> 132   03 Cochabamba    07      Capinota   01                   Capinota
#> 133   03 Cochabamba    07      Capinota   02                 Santiváñez
#> 134   03 Cochabamba    07      Capinota   03                     Sicaya
#> 135   03 Cochabamba    08 Germán Jordán   01                      Cliza
#> 136   03 Cochabamba    08 Germán Jordán   02                       Toco
#> 137   03 Cochabamba    08 Germán Jordán   03                     Tolata
#> 138   03 Cochabamba    09   Quillacollo   01                Quillacollo
#> 139   03 Cochabamba    09   Quillacollo   02                   Sipesipe
#> 140   03 Cochabamba    09   Quillacollo   03                  Tiquipaya
#> 141   03 Cochabamba    09   Quillacollo   04                      Vinto
#> 142   03 Cochabamba    09   Quillacollo   05                Colcapirhua
#> 143   03 Cochabamba    10       Chapare   01                     Sacaba
#> 144   03 Cochabamba    10       Chapare   02                     Colomi
#> 145   03 Cochabamba    10       Chapare   03               Villa Tunari
#> 146   03 Cochabamba    11      Tapacarí   01                   Tapacarí
#> 147   03 Cochabamba    12      Carrasco   01                     Totora
#> 148   03 Cochabamba    12      Carrasco   02                       Pojo
#> 149   03 Cochabamba    12      Carrasco   03                     Pocona
#> 150   03 Cochabamba    12      Carrasco   04                    Chimoré
#> 151   03 Cochabamba    12      Carrasco   05          Puerto Villarroel
#> 152   03 Cochabamba    12      Carrasco   06                 Entre Ríos
#> 153   03 Cochabamba    13        Mizque   01                     Mizque
#> 154   03 Cochabamba    13        Mizque   02                  Vila Vila
#> 155   03 Cochabamba    13        Mizque   03                     Alalay
#> 156   03 Cochabamba    13        Mizque   04            TIOC-Raqaypampa
#> 157   03 Cochabamba    14        Punata   01                     Punata
#> 158   03 Cochabamba    14        Punata   02               Villa Rivero
#> 159   03 Cochabamba    14        Punata   03                 San Benito
#> 160   03 Cochabamba    14        Punata   04                    Tacachi
#> 161   03 Cochabamba    14        Punata   05 Villa Gualberto Villarroel
#> 162   03 Cochabamba    15       Bolívar   01                    Bolívar
#> 163   03 Cochabamba    16       Tiraque   01                    Tiraque
#> 164   03 Cochabamba    16       Tiraque   02                  Shinahota
municipios(departamento = "02", provincia = "217")
#> [1] idep        nombre_dep  iprov       nombre_prov imun        nombre_mun 
#> <0 rows> (or 0-length row.names)
```
