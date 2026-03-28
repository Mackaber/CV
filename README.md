# CV

This repository builds the CV inside Docker to avoid host LaTeX dependency drift.

## Requirements

- Docker
- GNU Make

## Build

Build the PDF with:

```sh
make pdf
```

The generated file is written to `build/cv.pdf` on the host.

## Other Commands

Clean generated artifacts:

```sh
make clean
```

Open a shell inside the build image:

```sh
make shell
```

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