= Praktická část

Praktickou částí práce je systém *DarkFactory* — sada pravidel, skriptů
a pracovních postupů, které z repozitáře udělají samostatně pracující vývojový
provoz. Zdrojový kód je veřejně dostupný @darkfactory.

== Cíl a rozsah systému

Systém má převzít rutinní kroky vývojového procesu: přijetí požadavku, jeho
interpretaci, naplánování, provedení změny a její ověření. Nemá nahradit
rozhodování o tom, co se má stavět; to zůstává člověku, a systém je navržen tak,
aby si toto rozhodnutí vyžádal dříve, než začne pracovat.

== Architektura

Návrh vychází z jednoho požadavku: pracovní postupy i skripty musí být ve všech
repozitářích totožné. Kdyby se kopírovaly, začaly by se rozcházet, a oprava chyby
by se musela provádět tolikrát, kolik je repozitářů.

=== Sdílení místo kopírování

Pracovní postupy jsou proto _volané_, nikoli kopírované. Repozitář, který systém
používá, obsahuje pouze krátký soubor odkazující na sdílený pracovní postup
připnutý ke konkrétní verzi. Připnutí je podstatné: bez něj by se změna sdíleného
postupu okamžitě promítla do všech repozitářů, včetně těch, které na ni nejsou
připraveny.

=== Jediný konfigurační soubor

Vše, co se mezi repozitáři liší, je soustředěno do jediného souboru
`darkfactory.json`. Ten popisuje totožnost repozitáře, jeho oblasti, nástěnky,
na které patří jeho úkoly, a případné odchylky od výchozího chování. Sdílený
postup je díky tomu ve všech repozitářích shodný bajt po bajtu.

== Životní cyklus požadavku

Požadavek prochází systémem v pevně daných krocích, mezi nimiž jsou schvalovací
body:

+ Uživatel založí požadavek s doslovným zněním svého zadání.
+ Systém požadavek interpretuje a čeká na schválení této interpretace.
+ Po schválení vzniká plán jako samostatný podřízený úkol.
+ Po schválení plánu vzniká větev a návrh změny.
+ Změna projde vlastním přezkoumáním a ověřením proti plánu.
+ Po splnění požadovaných kontrol a schválení je změna sloučena.

Doslovné znění zadání je uchováno záměrně. Zkušenost z vývoje ukázala, že právě
parafráze bývá zdrojem nedorozumění: shrnutí požadavku se zdá výstižné tomu, kdo
je psal, a přitom už neobsahuje to, na čem zadavateli záleželo.

== Popis prostředí repozitáře

Aby systém věděl, které úlohy má spustit, musí rozpoznat, z čeho se repozitář
skládá. Rozpoznávání vychází z názvů souborů popisujících balíček; jejich
přítomnost je spolehlivější než jakýkoli ruční záznam, protože se nemůže rozejít
se skutečností.

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left, left, left),
    table.header([*Soubor*], [*Prostředí*], [*Doména*]),
    [`pyproject.toml`], [Python], [kód],
    [`Cargo.toml`],     [Rust],   [kód],
    [`package.json`],   [Node],   [kód],
    [`go.mod`],         [Go],     [kód],
    [`typst.toml`],     [Typst],  [text],
    [`.latexmkrc`],     [LaTeX],  [text],
    [`lakefile.toml`],  [Lean],   [matematika],
  ),
  caption: [Rozpoznávání prostředí podle souboru popisujícího balíček.],
) <tab-prostredi>

=== Domény a prostředí

Rozlišení dvou úrovní se ukázalo jako nutné až v průběhu práce. _Prostředí_ říká,
jaký nástroj je potřeba; _doména_ říká, jakému způsobu řízení výsledek podléhá.
Python a Rust jsou dvě prostředí téže domény — kód se testuje a balí. Typst
a LaTeX jsou dvě prostředí jiné domény — text se sází a publikuje.

Toto rozlišení dovoluje popsat i repozitář, který obsahuje zároveň program
a text — jako právě tato práce, jejíž praktickou částí je software popisovaný
v @tab-prostredi. Bez něj by bylo nutné buď považovat sazbu za zvláštní případ
kódu, nebo pro texty vytvořit samostatný systém.

=== Deklarace jako doplněk rozpoznávání

Rozpoznávání nemůže vidět všechno. Repozitář této práce například přibaluje
vlastní písma, takže příkaz pro sazbu není výchozí. Konfigurační soubor proto
umožňuje výchozí chování přepsat, aniž by bylo nutné vypnout rozpoznávání jako
celek.

== Orchestrace napříč poskytovateli

Systém neváže na jednoho poskytovatele modelu. Úkol je popsán způsobem nezávislým
na rozhraní a předán prvnímu dostupnému poskytovateli; vyčerpá-li tento kvótu,
předá se tentýž úkol dalšímu v pořadí, místo aby se proces zastavil.

Tato vlastnost byla přímou reakcí na provozní zkušenost: zastavení celého procesu
kvůli vyčerpané kvótě jediného poskytovatele bylo nejčastější příčinou prostoje.

== Ověřování změn

Každá změna musí projít požadovanými kontrolami. Ty jsou navrženy tak, aby vždy
skončily nějakým výsledkem — úloha, která se může „přeskočit“, by jinak
zablokovala slučování napořád, jak bylo vysvětleno v kapitole 2.

#figure(
  ```yaml
  paper:
    steps:
      - name: Detect the paper domain
        id: detect
      - name: Typeset with Typst
        if: steps.detect.outputs.typst == 'true'
      - name: No paper in this repository
        if: steps.detect.outputs.present != 'true'
        run: echo "nothing to typeset."
  ```,
  caption: [Zjednodušená úloha, která vždy skončí výsledkem.],
) <kod-uloha>

Struktura v @kod-uloha je pro celý systém typická: nejprve se zjistí, zda je
v repozitáři co dělat, a teprve pak se pracuje. Poslední krok zajišťuje, že úloha
skončí úspěchem i tam, kde není co ověřovat.

== Hlášení selhání

Selhání kterékoli úlohy zakládá úkol s odkazem na neúspěšný běh. Opakované
selhání téže úlohy nezakládá další úkol, nýbrž doplní komentář ke stávajícímu;
bez toho by úloha selhávající při každé změně zahltila seznam úkolů. Jakmile
úloha znovu uspěje, úkol se sám uzavře.
