#import "../lib/odborna-prace.typ": note, alert

#let ai(body) = highlight(fill: yellow, body)

= Výsledky a diskuse

== Metodika ověření

#alert[Strukturální duplicita metodiky: Vymezení metodiky výzkumu a ověření již proběhlo v úvodu práce (sekce 1.4). V kapitole 4 (Výsledky a diskuse) by se text neměl vracet k obecné metodice, ale měl by přímo představit testovací prostředí, profil a charakteristiku nasazených repozitářů a konkrétní naměřené metriky.]

#ai[
Systém byl nasazen na tři repozitáře různé povahy: na vlastní repozitář systému,
na aplikaci psanou v několika jazycích a na menší projekt. Sledovány byly tři
veličiny: počet vlastních skriptů a pracovních postupů v jednotlivých
repozitářích, počet řádků odstraněného duplicitního kódu a chování systému
v provozu.
]

== Sjednocení pracovních postupů

Sdílení jednoho centrálního pracovního postupu namísto ad-hoc kopií vedlo k odstranění přibližně 7 800 řádků redundantního kódu napříč sledovanými repozitáři.

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: (left, center, center, right),
    table.header([*Repozitář*], [*Skripty před*], [*Skripty po*], [*Redukce kódu*]),
    [DarkFactory],      [12], [12], [— (upstream)],
    [omnis],            [7],  [1],  [~4 900 řádků],
    [ChessWithQuests],  [5],  [1],  [~2 900 řádků],
  ),
  caption: [Počet vlastních skriptů a rozsah odstraněného kódu před sjednocením a po něm.],
) <tab-vysledky>

Údaje v @tab-vysledky je třeba interpretovat s ohledem na povahu zapojených projektů. U repozitáře DarkFactory se počet skriptů nezměnil, neboť právě on představuje upstreamovou základnu, která sdílené nástroje vyvíjí a spravuje. Zbývající jediný skript v ostatních repozitářích představuje lokální definici struktury jejich vlastní projektové dokumentace, kterou z principu nelze sdílet.

Redukce se konkrétně dotkla čtyř hlavních kategorií skriptů:
- *Kontrola kvality a statická analýza (linting)*: Každý repozitář původně udržoval vlastní skripty volající formátovače, lintery a typové kontroly. Ty byly plně nahrazeny centrální parametrizovanou úlohou.
- *Automatizace vydávání verzí a tagování*: Skripty počítající sémantické verze, generující changelogy a publikující balíčky byly nahrazeny sdíleným postupem řízeným deklarací v manifestu `darkfactory.json`.
- *Sestavení a nasazení dokumentace*: Jednoúčelové deployment skripty pro GitHub Pages byly nahrazeny standardizovaným procesem.
- *Správa závislostí a submodulů*: Pravidelné aktualizační skripty byly sjednoceny pod centrální plánované workflow.

Zásadním přínosem sjednocení je radikální snížení údržbové zátěže. Před zavedením systému vyžadovala jakákoli změna v CI procesu — například bezpečnostní aktualizace akcí, oprava oprávnění tokenů či přechod na novější verzi interpretu — manuální editaci, otestování a schválení pull requestu v každém repozitáři samostatně. Po sjednocení je oprava provedena pouze jednou v centrálním repozitáři DarkFactory. Spotřebitelské projekty změnu převezmou automaticky, případně bezpečným posunem připnuté verze v konfiguračním manifestu, čímž údržbová složitost klesla z lineární závislosti na počtu projektů na konstantní $O(1)$.

== Rozšíření na texty

Po sjednocení byl systém rozšířen tak, aby popsal i repozitář obsahující text
místo programu. Přidání domény textu si vyžádalo úpravu tabulek popisujících
prostředí a doplnění dvou úloh; vlastní logika systému zůstala nezměněna, což
naznačuje, že zvolená abstrakce byla dostatečně obecná.

Ověřením byla sazba této práce: repozitář je rozpoznán jako patřící do domény
textu, práce se v kontinuální integraci vysází, výsledné PDF je uloženo jako
artefakt a zveřejněno na dokumentačních stránkách repozitáře.

== Chyby, které se projevily až v provozu

#ai[
Nasazení odhalilo několik chyb, které se při návrhu neprojevily. Jsou uvedeny
proto, že tvoří nejcennější část výsledků: šlo vesměs o chyby v _řízení_
procesu, nikoli ve schopnosti změnu vytvořit.

/ Uváznutí souběžnosti: Volající i volaný pracovní postup použily stejný název
  skupiny souběžnosti, takže volaný čekal na skupinu drženou vlastním volajícím.
  Běh skončil bez jediné úlohy a bez chybového hlášení.

/ Přejmenování kontrol: Volaný pracovní postup hlásí výsledek pod složeným
  názvem, který obsahuje i jméno volající úlohy. Ochrana větve vyžadující původní
  název by zablokovala každé sloučení, protože kontrola s tímto názvem už
  neexistuje.

/ Tiché selhání zápisu na nástěnku: Zápisy na projektovou nástěnku byly obaleny
  zachycením všech výjimek, takže selhání skončilo hlášením o úspěchu. Chyba
  vyšla najevo až ručním porovnáním obsahu nástěnky s očekáváním.

/ Předpoklad o jazyce: Sdílené úlohy předpokládaly, že každý repozitář obsahuje
  Python. Repozitář s textem proto neprošel ani prvním krokem, přestože sazba
  sama byla v pořádku.
]

#note[Tato kapitola o reálných chybách v řízení je pro posudek práce mimořádně silná. Doporučuji ke každému ze 4 uvedených problémů doplnit konkrétní technické řešení aplikované v DarkFactory (např. rozlišení concurrency group názvů mezi caller/callee workflow, mapování názvů check-runů v branch protection pravidlech, nebo zavedení explicitní detekce domén bez pevného předpokladu přítomnosti Pythonu).]

== Diskuse

#ai[
Nejpoučnější z uvedených chyb je tiché selhání zápisu na nástěnku. Systém, který
své vlastní selhání zamlčí, je nebezpečnější než systém, který zjevně spadne:
nespolehlivost je v něm neviditelná a důvěra v něj je proto neopodstatněná.
Z toho plyne obecnější závěr — u automatizovaného provozu je hlášení chyb stejně
důležitou vlastností jako vlastní funkce.

Druhým opakujícím se motivem je předpoklad o podobě repozitáře. Chyba
s předpokladem o jazyce má stejnou příčinu jako potřeba zavést domény: sdílený
systém musí popisovat, co v repozitáři skutečně je, a nikoli předpokládat, že se
podobá tomu, pro který byl původně napsán.
]

== Omezení

#alert[Chybějící kvantitativní vyhodnocení agentních běhů: Výsledková kapitola obsahuje pouze jedinou srovnávací tabulku zaměřenou na počet řádků skriptů. Chybí strukturální vyhodnocení spolehlivosti a autonomie samotných modelů v pipeline: např. poměr úspěšně schválených PR bez zásahu člověka, průměrná spotřeba tokenů na vyřešení issue, průměrný čas běhu CI workflow a četnost vyčerpání kvót vedoucích k rotaci poskytovatelů.]

#ai[
Systém předpokládá, že úkol lze ověřit strojově. Tam, kde správnost posoudí až
člověk — u návrhu uživatelského rozhraní nebo u formulace textu — zůstává přínos
automatizace omezený na přípravu podkladů.

Druhým omezením je závislost na dostupnosti poskytovatelů jazykových modelů.
Postupné předávání úkolu mezi poskytovateli riziko snižuje, neodstraňuje je však
úplně: vyčerpají-li kvótu všichni, proces se zastaví stejně jako dříve.

Třetím omezením je rozsah ověření. Systém byl nasazen na tři repozitáře jediného
autora, takže zjištění nelze bez dalšího zobecnit na větší tým, kde by přibyly
otázky souběžné práce více lidí nad týmž kódem.
]
