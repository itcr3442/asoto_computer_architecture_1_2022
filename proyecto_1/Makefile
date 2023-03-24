ASFLAGS ?= -g
LDFLAGS ?= -g

TEX_TMP = $(addprefix doc/proyecto-i.,aux bbl bcf blg fls log out pdf run.xml fdb_latexmk)

all: img-decrypt

clean:
	rm -rf $(TEX_TMP) img-decrypt{,.o} katherine-johnson.out

doc: doc/proyecto-i.pdf

dist: proyecto-i.zip

test: img-decrypt katherine-johnson.txt
	./img-decrypt 102400 5963 1631 <katherine-johnson.txt >katherine-johnson.out && cmp -b katherine-johnson.{out,ref}

img-decrypt: img-decrypt.o
	$(CC) -o $@ $(LDFLAGS) $<

img-decrypt.o: img-decrypt.S
	$(CC) -c -o $@ $(ASFLAGS) $<

doc/proyecto-i.pdf: doc/proyecto-i.tex doc/proyecto-i.bib
	cd doc && latexmk -pdf proyecto-i.tex

proyecto-i.zip: doc/proyecto-i.pdf
	zip -r $@ $^

.PHONY: all clean doc dist test
