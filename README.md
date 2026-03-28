# CV

This repository supports both local and Docker-based builds.

## Requirements

- GNU Make

For local builds:

- `lualatex`
- `Noto Sans`
- TeX packages required by [cv.tex](/workspaces/CV/cv.tex)

On Debian or Ubuntu, install the local toolchain with:

```sh
make install-local-deps
```

For Docker builds:

- Docker

## Build

Build the PDF with:

```sh
make pdf
```

`make pdf` prefers the local `lualatex` toolchain when available and falls back to Docker otherwise.

The generated file is written to `build/cv.pdf` on the host.

To force one mode explicitly:

```sh
make pdf-local
make pdf-docker
```

## Other Commands

Clean generated artifacts:

```sh
make clean
```

Open a shell inside the build image:

```sh
make shell
```

## Local Setup Notes

The document uses `fontspec`, `babel`, and `Noto Sans`, so local builds need a Unicode-capable engine and the font installed on the host. On Debian or Ubuntu, the Dockerfile reflects the package set that is known to work.

`make install-local-deps` installs that same package set with `apt-get`. On non-Debian systems, use the package list in [Makefile](/workspaces/CV/Makefile) as the reference for manual installation.

## Manual Docker Usage

Build the image:

```sh
docker build -t cv-latex .
```

Compile the document:

```sh
docker run --rm -v "$PWD":/workdir -w /workdir cv-latex \
	lualatex -interaction=nonstopmode -halt-on-error -output-directory=build cv.tex
```

## Why Docker Here

The document in [cv.tex](/workspaces/CV/cv.tex) uses `fontspec` and `Noto Sans`, so portability depends on both the TeX engine and installed fonts. Containerizing the build makes that dependency set explicit and repeatable.

Docker is still the most reproducible option. The local path is there for cases like Codespaces, devcontainers, or personal machines that already have a working LaTeX installation.