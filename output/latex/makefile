PDF_DIR := ../pdf
TEX_FILES := $(wildcard *.tex)
PDF_FILES := $(addprefix $(PDF_DIR)/, $(TEX_FILES:.tex=.pdf))

all: $(PDF_FILES)

$(PDF_DIR)/%.pdf: %.tex
	@mkdir -p $(PDF_DIR)
	latexmk -pdf -lualatex -outdir=. $<
	@mv $(basename $<).pdf $(PDF_DIR)

clean:
	latexmk -CA

delete:
	rm -rf $(PDF_DIR)

.PHONY: all clean delete
