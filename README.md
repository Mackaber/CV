# CV

This repository supports local and Docker-based builds for multiple CV and cover-letter variants.

## Requirements

- GNU Make

For local builds:

- `lualatex`
- `Noto Sans`
- TeX packages required by [cv_es.tex](cv_es.tex)

On Debian or Ubuntu, install the local toolchain with:

```sh
make install-local-deps
```

For Docker builds:

- Docker

## Output Layout

- `output/`: all intermediate LaTeX artifacts (`.aux`, `.log`, `.out`, generated PDFs before copy)
- `pdf/`: final generated versions ready to share

## Build CV Versions

Build one CV variant:

```sh
make cv LANG=en PROFILE=ai-engineer INCLUDE_SUMMARY=1
```

Supported values:

- `LANG`: `en` or `es`
- `PROFILE`: `ai-engineer` or `academic`
- `INCLUDE_SUMMARY`: `1` (include summary) or `0` (hide summary)

Build all CV combinations:

```sh
make cv-all
```

`make pdf` remains available as an alias for `make cv` with defaults (`LANG=es`, `PROFILE=ai-engineer`).

## Build Cover Letters

Build one cover-letter variant:

```sh
make cover-letter LANG=en PROFILE=academic
```

Build all cover-letter combinations:

```sh
make cover-letter-all
```

The templates are:

- `cover_letter_en.tex`
- `cover_letter_es.tex`

## Configuration in LaTeX

CV files (`cv_en.tex`, `cv_es.tex`) accept:

- `\CVProfile` (`ai-engineer`, `academic`)
- `\IncludeSummary` (`1`, `0`)

Cover-letter files accept:

- `\CVProfile`
- `\CompanyName`
- `\RoleTitle`

The Makefile sets `\CVProfile` and `\IncludeSummary` automatically for generated variants.

## Other Commands

Install local dependencies (Debian/Ubuntu):

```sh
make install-local-deps
```

Clean generated artifacts:

```sh
make clean
```

Open a shell inside the build image:

```sh
make shell
```
