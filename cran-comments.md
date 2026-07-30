# cran-comments.md

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

Checked with `--as-cran --run-donttest` on:

| Platform | R | Result |
|---|---|---|
| macOS builder (mac.R-project.org) | 4.6.1 Patched | OK |
| win-builder | R-devel (r90317) | 1 NOTE (new submission) |
| win-builder | 4.5.3 (oldrelease) | 1 NOTE (new submission) |
| GitHub Actions: Ubuntu, macOS, Windows | release | OK |
| Local (macOS 14.5, arm64) | 4.6.0 | 1 NOTE (new submission) |

## Reverse dependencies

None: this is a first submission, so there are no downstream dependencies to check.

## Notes for the reviewer

Five points that are deliberate choices rather than oversights, each with its
reason.

### 1. Documentation, vignettes and messages are in Spanish

The package gives access to the population and housing census microdata of
Bolivia, whose variables, value labels and questionnaires are published in
Spanish by the national statistics institute. Its users are Bolivian and Latin
American researchers, public servants and journalists working with those files.

The Spanish text is not an interface choice, it is the data: the value labels the
package returns are the official category names of the census questionnaire, accents
included. Translating them would break the correspondence with the source, which is
what makes the package useful.

`Title`, `Description` and this file are in English, so that the package is
intelligible to all CRAN users, and `Language: es` is declared in DESCRIPTION.
This follows what comparable packages on CRAN do -- for instance 'censo2022arg'
(Argentinian census microdata), 'enaho' (Peruvian household survey) and 'eph'
(Argentinian household survey), all of which document in Spanish with an English
Title and Description.

### 2. Some examples are wrapped in `\dontrun{}`

Every example that can run offline does run: the variable dictionaries, the
thematic taxonomy, the geographic catalogues and the labelling functions all work
on data shipped inside the package, and their examples are executable.

The ones left in `\dontrun{}` are those that call the `get_*()` download
functions. They cannot run on a check machine: each one fetches tens to hundreds
of megabytes of census microdata over the network. Two examples
(`censosbo_cache_clear()`) are also destructive -- they delete the user's cached
files -- so running them automatically would be wrong even with a network
available.

### 3. The package downloads data on demand, and caches it

The census microdata are far too large to ship in a package (the 2024 person
table alone is 282 MB as Parquet), so they live in a companion data repository and
are downloaded only when the user asks for a specific census, table and
geographic subset.

* Nothing is downloaded at install, load or check time. No test, example or
  vignette accesses the network: the tests use local fixtures with mocked
  download bindings, and the one vignette that needs real data is precompiled.
* Downloads fail gracefully: on a network error the user gets an informative
  message naming the file and suggesting what to check, not an unhandled error.
* Files are cached under `tools::R_user_dir("censosbo", "cache")`. **In an
  interactive session the package asks for confirmation before creating that
  directory the first time**, and offers `options(censosbo.consent = TRUE)` to
  authorise it in advance and `options(censosbo.cache_dir = ...)` to place it
  elsewhere. In a non-interactive session it proceeds without prompting, so
  scripts and containers are not blocked by a question nobody can answer.

### 4. Included data and its provenance

The package ships variable dictionaries and municipal/departmental geometries
derived from public data published by the Bolivian National Statistics Institute
(INE, <https://www.ine.gob.bo/>), its 2024 census portal and its ANDA
microdata catalogue. These are official public statistics, published for free
reuse; the source of each dataset is documented in its `@source` field. The
package redistributes them in a tidier form, without altering their content.

### 5. Non-ASCII text

The R code is pure ASCII: user-facing messages use `\uXXXX` escapes. The Spanish
label tables -- the census category names the user sees in their results -- are
stored in `R/sysdata.rda` instead, because rewriting accented category names as
escape sequences would make a piece of data unreadable for the maintainer.
`checking data for non-ASCII characters` passes.
