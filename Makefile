IMAGE_NAME := cv-latex
OUTPUT_DIR := build
PDF := $(OUTPUT_DIR)/cv.pdf
PDF_EN := $(OUTPUT_DIR)/cv_en.pdf
LATEX_COMMON := lualatex -interaction=nonstopmode -halt-on-error -output-directory=$(OUTPUT_DIR)
LATEX_ES := $(LATEX_COMMON) -jobname=cv cv_es.tex
LATEX_EN := $(LATEX_COMMON) -jobname=cv_en cv_en.tex
APT_PACKAGES := fonts-noto-core texlive-fonts-recommended texlive-lang-english texlive-lang-spanish texlive-latex-base texlive-latex-extra texlive-latex-recommended texlive-luatex

.PHONY: image pdf pdf-en pdf-all pdf-local pdf-local-en pdf-docker pdf-docker-en install-local-deps clean shell

image:
	docker build -t $(IMAGE_NAME) .

pdf:
	mkdir -p $(OUTPUT_DIR)
	@if command -v lualatex >/dev/null 2>&1; then \
		echo "Using local lualatex toolchain"; \
		$(LATEX_ES); \
	elif command -v docker >/dev/null 2>&1; then \
		echo "Local lualatex not found, using Docker toolchain"; \
		$(MAKE) pdf-docker; \
	else \
		echo "Neither lualatex nor docker is available"; \
		exit 1; \
	fi

pdf-en:
	mkdir -p $(OUTPUT_DIR)
	@if command -v lualatex >/dev/null 2>&1; then \
		echo "Using local lualatex toolchain"; \
		$(LATEX_EN); \
	elif command -v docker >/dev/null 2>&1; then \
		echo "Local lualatex not found, using Docker toolchain"; \
		$(MAKE) pdf-docker-en; \
	else \
		echo "Neither lualatex nor docker is available"; \
		exit 1; \
	fi

pdf-all: pdf pdf-en

pdf-local:
	mkdir -p $(OUTPUT_DIR)
	$(LATEX_ES)

pdf-local-en:
	mkdir -p $(OUTPUT_DIR)
	$(LATEX_EN)

install-local-deps:
	@if command -v apt-get >/dev/null 2>&1; then \
		if command -v sudo >/dev/null 2>&1; then SUDO=sudo; else SUDO=; fi; \
		$$SUDO apt-get update; \
		$$SUDO apt-get install -y $(APT_PACKAGES); \
	else \
		echo "Automatic dependency installation is supported only on Debian/Ubuntu systems"; \
		echo "Install lualatex, Noto Sans, and the TeX Live packages listed in the Makefile manually"; \
		exit 1; \
	fi

pdf-docker: image
	mkdir -p $(OUTPUT_DIR)
	docker run --rm -v "$(CURDIR)":/workdir -w /workdir $(IMAGE_NAME) $(LATEX_ES)

pdf-docker-en: image
	mkdir -p $(OUTPUT_DIR)
	docker run --rm -v "$(CURDIR)":/workdir -w /workdir $(IMAGE_NAME) $(LATEX_EN)

clean:
	rm -rf $(OUTPUT_DIR)

shell: image
	docker run --rm -it -v "$(CURDIR)":/workdir -w /workdir $(IMAGE_NAME) /bin/bash