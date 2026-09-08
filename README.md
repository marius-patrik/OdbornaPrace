# template-OdbornaPrace

> Šablona pro **odbornou práci na Gymnáziu J. K. Tyla** sázenou v [Typstu](https://typst.app).

Kompletní kostra práce: titulní list, prohlášení, anotace v češtině
i angličtině, automatický obsah, seznam obrázků a tabulek, číslované
kapitoly, křížové odkazy, citace a přílohy.

Rozvržení odpovídá kapitole 4 školního *Průvodce tvorbou odborné práce*.

## Rychlý start

```bash
# 1. Vytvořte si repozitář z této šablony (tlačítko „Use this template“)
brew install typst          # macOS
$EDITOR metadata.typ        # 2. vyplňte údaje o práci
make watch                  # 3. živý náhled — PDF se aktualizuje při uložení
```

Výsledné PDF vznikne příkazem `make build` v `out/prace.pdf`.

## Soulad se školními pravidly

| Požadavek (Průvodce, kap. 4) | Implementace |
| :--- | :--- |
| Okraje 2,5 cm, u hřbetu navíc 0,5 cm | `margin: (left: 3cm, ostatní 2.5cm)` |
| Hlavní text patkovým písmem 12 b, do bloku | Caladea 12 b, `justify: true` |
| Řádkování 1,5; mezera pod odstavcem 8 b | `leading: 1.5 × 0.65em`, `spacing: 8pt` |
| První řádek odstavce se neodsazuje | `first-line-indent: 0pt` |
| Číslování kapitol **bez tečky** za poslední číslicí | `numbering: "1.1"` |
| Nadpisy tučně 16 / 14 / 12 b | `show heading.where(level: …)` |
| Mezera před nadpisem = písmo + 5 b, větší než pod ním | `above: 21/19/17pt`, `below: 10/9/8pt` |
| Čísla stran v zápatí, na střed, 11 b, **od úvodu** | vlastní `footer`, čítač se nenuluje |
| Titulní strana se počítá za stranu 1 | úvod proto nezačíná na straně 1 |
| Automatický obsah s čísly kapitol a stran | `outline(depth: 3)` |
| Popisky součástí textu 10 b, automatický seznam | `figure.caption` 10 b + `outline(target: figure)` |
| Přílohy se číslují a mají svůj seznam | `#show: prilohy` |

> **Pozor:** velikost písma 12 b a **patkový** font jsou závazné. Řada
> odevzdaných prací používá 11 b Calibri (bezpatkové), což pravidlům
> neodpovídá.

## Struktura

| Cesta | Účel |
| :--- | :--- |
| `metadata.typ` | **Jediný soubor, který je nutné upravit** — název, autor, škola, anotace |
| `main.typ` | Skládá práci dohromady; volitelné úpravy vzhledu |
| `lib/odborna-prace.typ` | Vlastní šablona — titulní list, prohlášení, sazba |
| `kapitoly/*.typ` | Text práce, jeden soubor na kapitolu |
| `bib/references.bib` | Zdroje ve formátu BibTeX |
| `fonts/` | Přibalená písma (Caladea) — sazba je všude identická |
| `img/` | Obrázky |

## Příkazy

| Příkaz | Popis |
| :--- | :--- |
| `make build` | Vysází práci do `out/prace.pdf` |
| `make watch` | Živý náhled |
| `make png` | Vyexportuje strany do `out/pages/` |
| `make check` | Ověří, že práce jde vysázet bez chyb |

## Způsob citací

Průvodce připouští dva systémy; který použijete, určuje vedoucí práce.

```typst
bib-styl: "iso-690-numeric",      // číselné odkazy (výchozí)
bib-styl: "iso-690-author-date",  // harvardský systém
```

## Logo a jméno

Šablona záměrně **neobsahuje logo školy ani konkrétní jméno.** Obojí
doplňte až ve vlastní práci vytvořené z této šablony:

```typst
#show: odborna-prace.with(meta: meta, logo: "/img/logo.jpeg")
```

## Licence

Šablona je volně k použití. Text vaší práce je vaše dílo.
Přibalená písma jsou pod SIL Open Font License 1.1 (viz `fonts/README.md`).
