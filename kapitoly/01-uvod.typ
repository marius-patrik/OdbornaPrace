#import "../lib/odborna-prace.typ": note, issue, alert, struct-alert, critique, added, draft, unconfirmed, confirmed, removed, diff

= Úvod

#draft[
Vývoj softwaru se za posledních dvacet let z velké části zautomatizoval.
Sestavení programu, spuštění testů, kontrola stylu i nasazení do provozu dnes
obstarávají stroje a nikdo je nepovažuje za práci hodnou lidského času. Jeden
krok však zůstal ruční: samotná změna zdrojového kódu. Právě tam se tvoří většina
prodlev — mezi okamžikem, kdy někdo popíše požadavek, a okamžikem, kdy se změna
dostane k uživatelům.

Výrobní průmysl zná pojem _dark factory_, tedy „temná továrna“: provoz, který
běží bez lidské obsluhy, a proto v něm nemusí svítit. Nejde o představu úplného
vyloučení člověka — i temná továrna má konstruktéry, kteří rozhodují, co se bude
vyrábět — nýbrž o vyloučení člověka z opakujících se úkonů. Tato práce zkoumá,
nakolik lze týž princip uplatnit ve vývoji softwaru a kde jsou jeho hranice.
]

== Motivace

#draft[
S rozšířením velkých jazykových modelů se objevila možnost automatizovat i psaní
kódu. Většina dostupných nástrojů však řeší jen dílčí krok: vygenerují návrh
změny, který někdo musí zasadit do procesu, ověřit a schválit. Chybí popis toho,
jak má takový nástroj zapadnout do vývojového procesu jako celku — kdo schvaluje,
co se stane při selhání a jak se pozná, že je výsledek správný.

Právě tato mezera je předmětem práce. Zajímavá není otázka, zda model dokáže
napsat kód; to je dnes doloženo. Zajímavá je otázka, jaké okolí musí kolem
takového modelu vzniknout, aby jeho výstupu bylo možné důvěřovat.
]

== Cíl práce

#draft[
Cílem této práce je navrhnout, realizovat a ověřit systém, který automatizuje
vývojový proces od přijetí požadavku po vytvoření ověřené změny, aniž by se vzdal
lidského schválení v rozhodujících bodech.

Dílčí cíle:

+ Popsat současný stav automatizace vývoje softwaru a orchestrace jazykových
  modelů.
+ Navrhnout architekturu systému, který provede požadavek celým procesem.
+ Systém realizovat a nasadit na reálné repozitáře.
+ Vyhodnotit jeho chování a pojmenovat omezení, na která v provozu narazil.
]

#note[Formulace výzkumných otázek: Pro zvýšení vědeckého a metodického přínosu práce u obhajoby doporučuji pod cíle práce doplnit 2–3 explicitní výzkumné otázky (např. zda lze dosáhnout bezobslužného běhu pipeline při zachování striktních deterministických záruk a jaké jsou limitující faktory současných LLM při samostatné práci nad rozsáhlým repozitářem).]

== Metodika

#draft[
Práce je z povahy tématu konstrukční: hlavním výstupem je funkční systém, nikoli
měření. Postup odpovídá vývoji softwaru — po nastudování východisek následoval
návrh, realizace a nasazení na reálné repozitáře, přičemž zjištění z provozu se
vracela zpět do návrhu.

Ověření proto neprobíhalo formou experimentu s kontrolní skupinou, nýbrž
sledováním chování systému v provozu. Sledovány byly zejména nalezené chyby,
neboť právě ty ukazují na rozdíl mezi předpokladem a skutečností.
]

#critique[Metodologická zranitelnost u obhajoby: Tvrzení, že „hlavním výstupem je funkční systém, nikoli měření“, je z hlediska exaktního výzkumu v softwarovém inženýrství nepřijatelná berlička. Pouhé sledování chování systému bez kontrolní skupiny či standardizovaných srovnávacích benchmarků (např. SWE-bench, `pass@k` či měření poměru úspěšnosti) činí celou práci zranitelnou vůči námitce, že jde pouze o subjektivní případovou studii autora nad vlastními třemi repozitáři. Oponent se zeptá: Jaká je statistická úspěšnost vyřešení issue na první pokus? Kolik tokenů pipeline spálí na banální chybu? Kde je baseline srovnání s manuálním vývojem?]

#note[Doporučuji v metodice explicitně uvést zkoumané repozitáře (vlastní systém DarkFactory, vícejazyčná aplikace omnis a menší projekt ChessWithQuests) a specifikovat, že ověření probíhá sledováním reálných běhů automatizovaného GitHub Actions workflow nad reálnými issues a pull requesty.]

== Struktura práce

#draft[
Kapitola 2 shrnuje teoretická východiska: řízení verzí, kontinuální integraci,
architekturu a orchestraci jazykových modelů a princip zapojení člověka do smyčky
(_Human-in-the-loop_). Kapitola 3 popisuje vlastní systém DarkFactory — jeho
architekturu, životní cyklus požadavku a způsob, jímž rozpoznává obsah repozitáře.
Kapitola 4 hodnotí výsledky nasazení včetně chyb, které se projevily až v provozu,
a kapitola 5 je shrnuje.
]
