#TODO
all:

clean:
	rm -rf doc/{}

doc: doc/proyecto-i.pdf

dist: proyecto-i.zip

doc/proyecto-i.pdf: doc/proyecto-i.tex doc/proyecto-i.bib
	cd doc && latexmk -pdf proyecto-i.tex

proyecto-i.zip: doc/proyecto-i.pdf
	zip -r $@ $^

.PHONY: all clean doc dist
