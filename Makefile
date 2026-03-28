IMAGE_NAME := cv-latex
OUTPUT_DIR := build
PDF := $(OUTPUT_DIR)/cv.pdf
LATEX := lualatex -interaction=nonstopmode -halt-on-error -output-directory=$(OUTPUT_DIR) cv.tex
APT_PACKAGES := fonts-noto-core texlive-fonts-recommended texlive-lang-english texlive-latex-base texlive-latex-extra texlive-latex-recommended texlive-luatex

.PHONY: image pdf pdf-local pdf-docker install-local-deps clean shell

image:
	docker build -t $(IMAGE_NAME) .

pdf:
	mkdir -p $(OUTPUT_DIR)
	@if command -v lualatex >/dev/null 2>&1; then \
		echo "Using local lualatex toolchain"; \
		$(LATEX); \
	elif command -v docker >/dev/null 2>&1; then \
		echo "Local lualatex not found, using Docker toolchain"; \
		$(MAKE) pdf-docker; \
	else \
		echo "Neither lualatex nor docker is available"; \
		exit 1; \
	fi

pdf-local:
	mkdir -p $(OUTPUT_DIR)
	$(LATEX)

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
	docker run --rm -v "$(CURDIR)":/workdir -w /workdir $(IMAGE_NAME) $(LATEX)

clean:
	rm -rf $(OUTPUT_DIR)

shell: image
	docker run --rm -it -v "$(CURDIR)":/workdir -w /workdir $(IMAGE_NAME) /bin/bash