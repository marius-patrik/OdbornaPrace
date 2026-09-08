// ─────────────────────────────────────────────────────────────
//  Šablona pro odbornou práci na Gymnáziu J. K. Tyla.
//
//  Rozvržení odpovídá kapitole 4 („Formální stránka práce“)
//  školního Průvodce tvorbou odborné práce:
//    • okraje 2,5 cm, u hřbetu navíc 0,5 cm (tedy 3 cm)
//    • hlavní text patkovým písmem 12 b, zarovnaný do bloku
//    • řádkování 1,5; mezera pod odstavcem 8 b; bez odsazení
//    • číslování kapitol bez tečky za poslední číslicí
//    • nadpisy tučně 16 / 14 / 12 b
//    • čísla stran v zápatí, na střed, 11 b, od úvodu
//
//  Šablona sama neobsahuje žádné jméno ani logo.
// ─────────────────────────────────────────────────────────────

// Caladea je patkové písmo metricky shodné s Cambrií a je přibaleno
// v adresáři `fonts/`, takže sazba je všude identická.
#let PISMO = ("Caladea", "New Computer Modern")

#let nadpis-bez-cisla(text-nadpisu) = {
  heading(numbering: none, outlined: true, text-nadpisu)
}

#let titulni-list(meta, logo: none) = {
  set align(center)

  if logo != none {
    block(image(logo, height: 3cm))
    v(0.5cm)
  } else {
    v(1cm)
  }

  text(size: 14pt, weight: "bold", meta.skola)

  v(1fr)

  text(size: 26pt, weight: "bold", meta.nazev)

  if meta.at("podnazev", default: none) != none {
    v(0.4cm)
    text(size: 14pt, meta.podnazev)
  }

  v(0.7cm)
  text(size: 15pt, tracking: 2pt, "ODBORNÁ PRÁCE")

  v(1fr)

  set align(left)
  set text(size: 12pt)
  [Autor práce: #meta.autor#if meta.at("trida", default: none) != none [, #meta.trida]]
  linebreak()
  if meta.at("vedouci", default: none) != none [Vedoucí práce: #meta.vedouci]
  if meta.at("konzultant", default: none) != none {
    linebreak()
    [Konzultant: #meta.konzultant]
  }

  v(0.8cm)
  set align(center)
  text(size: 12pt, str(meta.rok))

  pagebreak()
}

#let prohlaseni(meta) = {
  nadpis-bez-cisla[Prohlášení]

  let zkratka = meta.at("skola-zkratka", default: meta.skola)
  [
    Prohlašuji, že jsem tuto studentskou odbornou práci vypracoval/a
    samostatně pod dohledem vedoucího uvedeného na první straně. Všechny
    použité zdroje jsou uvedeny v seznamu zdrojů a informace z nich získané
    jsou v textu řádně označeny odkazem na zdroj. Souhlasím s tím, aby
    tištěná forma práce byla uchována na #meta.skola a tam používána jako
    tištěný zdroj např. pro další studentské práce či pro prezentaci
    vzdělávání na #zkratka.
  ]

  v(1.5cm)
  [V #meta.mesto dne #box(width: 4.5cm, repeat("…")) #h(1fr) Podpis autora práce: #box(width: 4.5cm, repeat("…"))]

  pagebreak()
}

#let podekovani-strana(meta) = {
  let p = meta.at("podekovani", default: none)
  if p == none { return }
  nadpis-bez-cisla[Poděkování]
  p
  pagebreak()
}

#let anotace-strana(meta) = {
  nadpis-bez-cisla[Anotace]
  meta.anotace

  nadpis-bez-cisla[Klíčová slova]
  meta.klicova-slova.join(", ")

  nadpis-bez-cisla[Annotation]
  meta.abstract

  nadpis-bez-cisla[Keywords]
  meta.keywords.join(", ")

  pagebreak()
}

#let odborna-prace(
  meta: (:),
  // Cesta k logu školy, např. "/img/logo.jpeg". `none` = bez loga.
  logo: none,
  pismo: PISMO,
  velikost: 12pt,
  radkovani: 1.5,
  mezera-odstavec: 8pt,
  // Seznam obrázků a tabulek — vyžadován, obsahuje-li práce součásti textu.
  seznam-soucasti: true,
  bibliografie: "/bib/references.bib",
  // "iso-690-numeric" = číselné odkazy, "iso-690-author-date" = harvardský
  // systém. Způsob citací určuje vedoucí práce.
  bib-styl: "iso-690-numeric",
  body,
) = {
  set document(title: meta.nazev, author: meta.autor)

  // Okraje 2,5 cm; u hřbetu (vlevo) navíc 0,5 cm kvůli vazbě.
  set page(
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 2.5cm),
    // Titulní strana a přední část se počítají, ale nečíslují.
    footer: none,
  )

  set text(font: pismo, size: velikost, lang: "cs", hyphenate: true)
  set par(
    justify: true,
    leading: radkovani * 0.65em,
    spacing: mezera-odstavec,
    // První řádek odstavce se zleva zvlášť neodsazuje.
    first-line-indent: 0pt,
  )
  // Za poslední číslicí čísla kapitoly se nepíše tečka.
  set heading(numbering: "1.1")

  // Mezera před nadpisem = velikost písma nadpisu + 5 b, a je vždy větší
  // než mezera pod nadpisem, aby bylo zřejmé, ke které kapitole text patří.
  show heading.where(level: 1): it => {
    if it.numbering != none { pagebreak(weak: true) }
    block(above: 21pt, below: 10pt, text(size: 16pt, weight: "bold", it))
  }
  show heading.where(level: 2): it => {
    block(above: 19pt, below: 9pt, text(size: 14pt, weight: "bold", it))
  }
  show heading.where(level: 3): it => {
    block(above: 17pt, below: 8pt, text(size: 12pt, weight: "bold", it))
  }

  // Popisky součástí textu: stejné písmo jako text, velikost 10 b.
  show figure.caption: set text(size: 10pt)
  show raw: set text(font: "DejaVu Sans Mono", size: 10pt)
  show link: set text(fill: rgb("#0b4f9e"))
  set table(stroke: 0.5pt)
  set figure(numbering: "1")

  // ── Přední část ──────────────────────────────────────────
  titulni-list(meta, logo: logo)
  prohlaseni(meta)
  podekovani-strana(meta)
  anotace-strana(meta)

  outline(title: "Obsah", depth: 3, indent: auto)

  if seznam-soucasti {
    pagebreak(weak: true)
    outline(
      title: "Seznam obrázků a tabulek",
      target: figure.where(kind: image).or(figure.where(kind: table)),
    )
  }

  // ── Vlastní text ─────────────────────────────────────────
  // Čísla stran se uvádí od úvodu; za stranu 1 se považuje titulní strana,
  // proto se čítač nikde nenuluje.
  set page(footer: context align(center, text(
    font: pismo, size: 11pt, counter(page).display("1"),
  )))

  body

  // ── Zadní část ───────────────────────────────────────────
  if bibliografie != none {
    pagebreak(weak: true)
    bibliography(bibliografie, style: bib-styl, title: "Seznam zdrojů")
  }
}

// Přílohy se číslují a odkazuje se na ně v textu; obsahuje-li práce
// přílohy, musí obsahovat i jejich seznam.
#let prilohy(body) = {
  pagebreak(weak: true)
  // Nadpis seznamu vzniká ještě před `set`, aby sám sebe nezahrnul.
  nadpis-bez-cisla[Seznam příloh]
  counter(heading).update(0)
  set heading(numbering: "A.1", supplement: [Příloha])
  outline(title: none, target: heading.where(supplement: [Příloha]))
  body
}
