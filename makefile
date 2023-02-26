# Converts the markdown file in ./entries into LaTeX, then moves it to LaTeX dir
build: $(wildcard ./source/markdown/*.md)
	./pandoc/latex/pandoc.sh $?
	$(MAKE) -C output/latex/

clean:
	$(MAKE) -C output/latex/ clean