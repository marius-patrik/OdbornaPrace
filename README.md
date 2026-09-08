# Odborná práce — Autonomní pipeline pro vývoj softwaru

> Odborná práce na Gymnáziu J. K. Tyla. Autor: **Patrik Marius**, 4.D.
> Vedoucí práce: **Michal Dočekal**. Rok: **2026**.

Práce se zabývá návrhem a realizací autonomního systému pro vývoj softwaru.
Praktickou částí je systém [DarkFactory](https://github.com/marius-patrik/DarkFactory),
který práci zároveň sází a publikuje.

> [!WARNING]
> **Text je rozpracovaný.** Kapitoly obsahují koncept vygenerovaný jako osnova,
> nikoli odevzdatelný text. Před odevzdáním je nutné je přepsat vlastními slovy —
> viz kapitola 5.3 *Plagiát* školního průvodce. Každý soubor v `kapitoly/`
> začíná poznámkou `TODO`, dokud přepsán není.

## Sazba

```bash
brew install typst
make watch      # živý náhled
make build      # out/prace.pdf
```

Písma jsou přibalena v `fonts/`, takže výsledek je shodný na jakémkoli počítači.

## Struktura

| Cesta | Účel |
| :--- | :--- |
| `metadata.typ` | Údaje o práci — název, autor, škola, anotace |
| `kapitoly/*.typ` | Text práce, jeden soubor na kapitolu |
| `bib/references.bib` | Zdroje ve formátu BibTeX |
| `lib/odborna-prace.typ` | Šablona převzatá z [`template-OdbornaPrace`](https://github.com/marius-patrik/template-OdbornaPrace) |
| `img/` | Obrázky včetně loga školy |

## Odkazy

| | |
| :--- | :--- |
| Vysázená práce | <https://marius-patrik.github.io/OdbornaPrace/> |
| Vydané verze | [Releases](https://github.com/marius-patrik/OdbornaPrace/releases) |
| Šablona | [`template-OdbornaPrace`](https://github.com/marius-patrik/template-OdbornaPrace) |
| Praktická část | [`DarkFactory`](https://github.com/marius-patrik/DarkFactory) |

## Rozsah

Školní průvodce stanoví minimum 18 000 znaků včetně mezer (10 normostran),
počítáno od úvodu po závěr. Aktuální stav ověříte příkazem:

```bash
make build && pdftotext out/prace.pdf - | wc -c
```
