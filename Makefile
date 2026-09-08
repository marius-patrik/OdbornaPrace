TYPST ?= typst
FONTS := --font-path fonts
MAIN  := main.typ
OUT   := out/prace.pdf

.PHONY: help build watch png clean check

help:
	@echo "make build   – vysází práci do $(OUT)"
	@echo "make watch   – průběžná sazba s živým náhledem"
	@echo "make png     – vyexportuje jednotlivé strany do out/pages"
	@echo "make check   – ověří, že práce jde vysázet bez chyb"
	@echo "make clean   – smaže adresář out/"

build:
	@mkdir -p $(dir $(OUT))
	$(TYPST) compile $(FONTS) $(MAIN) $(OUT)
	@echo "Hotovo: $(OUT)"

watch:
	@mkdir -p $(dir $(OUT))
	$(TYPST) watch $(FONTS) $(MAIN) $(OUT)

png:
	@mkdir -p out/pages
	$(TYPST) compile $(FONTS) $(MAIN) "out/pages/strana-{0p}.png" --ppi 150

check:
	$(TYPST) compile $(FONTS) $(MAIN) --format pdf /dev/stdout > /dev/null

clean:
	rm -rf out
