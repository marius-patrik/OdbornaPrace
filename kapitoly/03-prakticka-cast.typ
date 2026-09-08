= Praktická část

Praktickou částí práce je systém *DarkFactory* — sada pravidel, skriptů
a pracovních postupů, které z repozitáře udělají samostatně pracující vývojový
provoz. Zdrojový kód je veřejně dostupný @darkfactory.

== Přehled architektury

Systém je navržen tak, aby byl sdílen mezi repozitáři beze změny: pracovní postupy
i skripty jsou ve všech repozitářích totožné a jediné, co se liší, je konfigurační
soubor popisující daný repozitář.

#figure(
  image("/img/logo.jpeg", width: 25%),
  caption: [Logo Gymnázia J. K. Tyla.],
) <obr-logo>

== Životní cyklus požadavku

Požadavek prochází systémem v pevně daných krocích, mezi nimiž jsou schvalovací
body:

+ Uživatel založí požadavek s doslovným zněním svého zadání.
+ Systém požadavek interpretuje a čeká na schválení této interpretace.
+ Po schválení vzniká plán jako samostatný podřízený úkol.
+ Po schválení plánu vzniká větev a návrh změny.
+ Změna projde vlastním přezkoumáním a ověřením proti plánu.

Doslovné znění zadání je uchováno záměrně: parafráze ztrácí význam, který do ní
zadavatel vložil.

== Popis prostředí repozitáře

Aby systém věděl, které úlohy má spustit, musí rozpoznat, z čeho se repozitář
skládá. Rozpoznávání vychází z názvů souborů popisujících balíček — například
`pyproject.toml` značí Python, `Cargo.toml` jazyk Rust.

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left, left, left),
    table.header([*Soubor*], [*Prostředí*], [*Doména*]),
    [`pyproject.toml`], [Python], [kód],
    [`Cargo.toml`],     [Rust],   [kód],
    [`package.json`],   [Node],   [kód],
    [`typst.toml`],     [Typst],  [text],
    [`.latexmkrc`],     [LaTeX],  [text],
  ),
  caption: [Rozpoznávání prostředí podle souboru popisujícího balíček.],
) <tab-prostredi>

Rozdělení na *domény* a *prostředí* dovoluje popsat i repozitář, který obsahuje
zároveň program a text — jako právě tato práce, jejíž praktickou částí je
software popisovaný v @tab-prostredi.

== Orchestrace napříč poskytovateli

Systém neváže na jednoho poskytovatele modelu. Vyčerpá-li jeden z nich kvótu,
předá se tentýž úkol dalšímu v pořadí, místo aby se proces zastavil.

== Ověřování změn

Každá změna musí projít požadovanými kontrolami. Ty jsou navrženy tak, aby vždy
skončily nějakým výsledkem — úloha, která se může „přeskočit“, by jinak zablokovala
slučování napořád.
