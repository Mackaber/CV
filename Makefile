IMAGE_NAME := cv-latex
OUTPUT_DIR := build
PDF := $(OUTPUT_DIR)/cv.pdf

.PHONY: image pdf clean shell

image:
	docker build -t $(IMAGE_NAME) .

pdf: image
	mkdir -p $(OUTPUT_DIR)
	docker run --rm -v "$(CURDIR)":/workdir -w /workdir $(IMAGE_NAME) \
		lualatex -interaction=nonstopmode -halt-on-error -output-directory=$(OUTPUT_DIR) cv.tex

clean:
	rm -rf $(OUTPUT_DIR)

shell: image
	docker run --rm -it -v "$(CURDIR)":/workdir -w /workdir $(IMAGE_NAME) /bin/bash