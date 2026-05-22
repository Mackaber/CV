IMAGE_NAME := cv-latex
OUTPUT_DIR := output
PDF_DIR := pdf
PROFILES := ai-engineer academic
LANGUAGES := es en
PROFILE ?= ai-engineer
LANG ?= es
INCLUDE_SUMMARY ?= 1
LATEX_COMMON := lualatex -interaction=nonstopmode -halt-on-error -output-directory=$(OUTPUT_DIR)
APT_PACKAGES := fonts-noto-core texlive-fonts-recommended texlive-lang-english texlive-lang-spanish texlive-latex-base texlive-latex-extra texlive-latex-recommended texlive-luatex

.PHONY: image cv cv-all cover-letter cover-letter-all pdf pdf-en pdf-all compile-cv-local compile-cover-letter-local cv-docker cover-letter-docker install-local-deps clean shell

image:
	docker build -t $(IMAGE_NAME) .

cv:
	mkdir -p $(OUTPUT_DIR) $(PDF_DIR)/$(LANG)/cv
	@if command -v lualatex >/dev/null 2>&1; then \
		echo "Using local lualatex toolchain"; \
		$(MAKE) compile-cv-local LANG=$(LANG) PROFILE=$(PROFILE) INCLUDE_SUMMARY=$(INCLUDE_SUMMARY); \
	elif command -v docker >/dev/null 2>&1; then \
		echo "Local lualatex not found, using Docker toolchain"; \
		$(MAKE) cv-docker LANG=$(LANG) PROFILE=$(PROFILE) INCLUDE_SUMMARY=$(INCLUDE_SUMMARY); \
	else \
		echo "Neither lualatex nor docker is available"; \
		exit 1; \
	fi

cover-letter:
	mkdir -p $(OUTPUT_DIR) $(PDF_DIR)/$(LANG)/cover-letter
	@if command -v lualatex >/dev/null 2>&1; then \
		echo "Using local lualatex toolchain"; \
		$(MAKE) compile-cover-letter-local LANG=$(LANG) PROFILE=$(PROFILE); \
	elif command -v docker >/dev/null 2>&1; then \
		echo "Local lualatex not found, using Docker toolchain"; \
		$(MAKE) cover-letter-docker LANG=$(LANG) PROFILE=$(PROFILE); \
	else \
		echo "Neither lualatex nor docker is available"; \
		exit 1; \
	fi

cv-all:
	@for lang in $(LANGUAGES); do \
		for profile in $(PROFILES); do \
			$(MAKE) cv LANG=$$lang PROFILE=$$profile INCLUDE_SUMMARY=$(INCLUDE_SUMMARY); \
		done; \
	done

cover-letter-all:
	@for lang in $(LANGUAGES); do \
		for profile in $(PROFILES); do \
			$(MAKE) cover-letter LANG=$$lang PROFILE=$$profile; \
		done; \
	done

pdf: cv

pdf-en:
	$(MAKE) cv LANG=en PROFILE=ai-engineer INCLUDE_SUMMARY=$(INCLUDE_SUMMARY)

pdf-all: cv-all

compile-cv-local:
	LC_ALL=C.UTF-8 LANG=C.UTF-8 $(LATEX_COMMON) -jobname=cv_$(LANG)_$(PROFILE) "\\def\\CVProfile{$(PROFILE)}\\def\\IncludeSummary{$(INCLUDE_SUMMARY)}\\input{src/$(LANG)/cv/cv.tex}"
	cp $(OUTPUT_DIR)/cv_$(LANG)_$(PROFILE).pdf $(PDF_DIR)/$(LANG)/cv/cv_$(LANG)_$(PROFILE).pdf

compile-cover-letter-local:
	LC_ALL=C.UTF-8 LANG=C.UTF-8 $(LATEX_COMMON) -jobname=cover_letter_$(LANG)_$(PROFILE) "\\def\\CVProfile{$(PROFILE)}\\input{src/$(LANG)/cover-letter/cover-letter.tex}"
	cp $(OUTPUT_DIR)/cover_letter_$(LANG)_$(PROFILE).pdf $(PDF_DIR)/$(LANG)/cover-letter/cover_letter_$(LANG)_$(PROFILE).pdf

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

cv-docker: image
	mkdir -p $(OUTPUT_DIR) $(PDF_DIR)/$(LANG)/cv
	docker run --rm -v "$(CURDIR)":/workdir -w /workdir $(IMAGE_NAME) \
		make compile-cv-local LANG=$(LANG) PROFILE=$(PROFILE) INCLUDE_SUMMARY=$(INCLUDE_SUMMARY)

cover-letter-docker: image
	mkdir -p $(OUTPUT_DIR) $(PDF_DIR)/$(LANG)/cover-letter
	docker run --rm -v "$(CURDIR)":/workdir -w /workdir $(IMAGE_NAME) \
		make compile-cover-letter-local LANG=$(LANG) PROFILE=$(PROFILE)

clean:
	rm -rf $(OUTPUT_DIR) $(PDF_DIR) build

shell: image
	docker run --rm -it -v "$(CURDIR)":/workdir -w /workdir $(IMAGE_NAME) /bin/bash
