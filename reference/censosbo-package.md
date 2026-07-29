# censosbo: Access and Analysis of Bolivian Census Microdata

Programmatic access to the microdata of the Bolivian population and
housing censuses of 1976, 1992, 2001, 2012 and 2024, published by the
National Statistics Institute of Bolivia (INE,
<https://www.ine.gob.bo/>). Data files in Apache Parquet format are
downloaded on demand from a companion data repository, cached locally,
and can be filtered by department, province or municipality. Supports
'dplyr' workflows through Apache Arrow and SQL queries through 'DuckDB'.
Includes variable dictionaries for every census year with a thematic
taxonomy and contextual metadata (reference population, questionnaire
item number and provenance of each variable), derived from the census
questionnaires and from the Data Documentation Initiative (DDI) files of
the INE ANDA catalogue; functions to harmonise variables across censuses
for temporal comparison; and choropleth maps at the department and
municipality level. Also includes the 2024 census aggregates for urban
blocks and rural communities, with their geometries. Documentation and
messages are in Spanish, the language of the source data.

## See also

Useful links:

- <https://lab-tecnosocial.github.io/censosbo/>

- <https://github.com/lab-tecnosocial/censosbo>

- Report bugs at <https://github.com/lab-tecnosocial/censosbo/issues>

## Author

**Maintainer**: Alex Ojeda Copa <alex@labtecnosocial.org> (organization:
Lab TecnoSocial) \[copyright holder\]

Authors:

- Alex Ojeda Copa <alex@labtecnosocial.org> (organization: Lab
  TecnoSocial) \[copyright holder\]

Other contributors:

- Lab TecnoSocial \[copyright holder, funder\]
