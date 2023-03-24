ASFLAGS ?= -g
LDFLAGS ?= -g

TEX_TMP = $(addprefix doc/proyecto-i.,aux bbl bcf blg fls log out pdf run.xml fdb_latexmk)

all: img-decrypt

clean:
	rm -rf $(TEX_TMP) img-decrypt{,.o} katherine-johnson.out

doc: doc/proyecto-i.pdf

dist: proyecto-i.zip

test: img-decrypt tests/*.txt tests/*.ref
	for N in $$(seq 3); do \
		echo "Test #$$N..." >&2; \
		RSA_N=$$(grep 'n =' tests/$$N.params | head -1 | tr '=' ' ' | awk '{ print $$2; }'); \
		RSA_D=$$(grep 'd =' tests/$$N.params | head -1 | tr '=' ' ' | awk '{ print $$2; }'); \
		WIDTH=$$(grep 'width =' tests/$$N.params | head -1 | tr '=' ' ' | awk '{ print $$2; }'); \
		HEIGHT=$$(grep 'height =' tests/$$N.params | head -1 | tr '=' ' ' | awk '{ print $$2; }'); \
		./img-decrypt $$(($$WIDTH * $$HEIGHT)) $$RSA_N $$RSA_D \
			<tests/$$N.txt >tests/$$N.out \
			&& cmp -b tests/$$N.{out,ref} \
	; done

img-decrypt: img-decrypt.o
	$(CC) -o $@ $(LDFLAGS) $<

img-decrypt.o: img-decrypt.S
	$(CC) -c -o $@ $(ASFLAGS) $<

doc/proyecto-i.pdf: doc/proyecto-i.tex doc/proyecto-i.bib
	cd doc && latexmk -pdf proyecto-i.tex

proyecto-i.zip: doc/proyecto-i.pdf
	zip -r $@ $^

.PHONY: all clean doc dist test
