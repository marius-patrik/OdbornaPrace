#import "../lib/odborna-prace.typ": note, issue, alert, struct-alert, critique, added, draft, unconfirmed, confirmed, removed, diff

= Výsledky a diskuse

== Metodika ověření

#alert[Strukturální duplicita metodiky: Vymezení metodiky výzkumu a ověření již proběhlo v úvodu práce (sekce 1.4). V kapitole 4 (Výsledky a diskuse) by se text neměl vracet k obecné metodice, ale měl by přímo představit testovací prostředí, profil a charakteristiku nasazených repozitářů a konkrétní naměřené metriky.]

#draft[
Systém byl nasazen na tři repozitáře různé povahy: na vlastní repozitář systému,
na aplikaci psanou v několika jazycích a na menší projekt. Sledovány byly tři
veličiny: počet vlastních skriptů a pracovních postupů v jednotlivých
repozitářích, počet řádků odstraněného duplicitního kódu a chování systému
v provozu.
]

== Sjednocení pracovních postupů

#draft[
Sdílení jednoho centrálního pracovního postupu namísto ad-hoc kopií vedlo k odstranění přibližně 7 800 řádků redundantního kódu napříč sledovanými repozitáři.
]

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

#draft[
Údaje v @tab-vysledky je třeba interpretovat s ohledem na povahu zapojených projektů. U repozitáře DarkFactory se počet skriptů nezměnil, neboť právě on představuje upstreamovou základnu, která sdílené nástroje vyvíjí a spravuje. Zbývající jediný skript v ostatních repozitářích představuje lokální definici struktury jejich vlastní projektové dokumentace, kterou z principu nelze sdílet.

Redukce se konkrétně dotkla čtyř hlavních kategorií skriptů:
- *Kontrola kvality a statická analýza (linting)*: Každý repozitář původně udržoval vlastní skripty volající formátovače, lintery a typové kontroly. Ty byly plně nahrazeny centrální parametrizovanou úlohou.
- *Automatizace vydávání verzí a tagování*: Skripty počítající sémantické verze, generující changelogy a publikující balíčky byly nahrazeny sdíleným postupem řízeným deklarací v manifestu `darkfactory.json`.
- *Sestavení a nasazení dokumentace*: Jednoúčelové deployment skripty pro GitHub Pages byly nahrazeny standardizovaným procesem.
- *Správa závislostí a submodulů*: Pravidelné aktualizační skripty byly sjednoceny pod centrální plánované workflow.

Zásadním přínosem sjednocení je radikální snížení údržbové zátěže. Před zavedením systému vyžadovala jakákoli změna v CI procesu — například bezpečnostní aktualizace akcí, oprava oprávnění tokenů či přechod na novější verzi interpretu — manuální editaci, otestování a schválení pull requestu v každém repozitáři samostatně. Po sjednocení je oprava provedena pouze jednou v centrálním repozitáři DarkFactory. Spotřebitelské projekty změnu převezmou automaticky, případně bezpečným posunem připnuté verze v konfiguračním manifestu, čímž údržbová složitost klesla z lineární závislosti na počtu projektů na konstantní $O(1)$.
]

#critique[Zástupná metrika a iluze nulové údržby: Redukce 7 800 řádků YAML konfigurace je klasická zástupná metrika (_vanity metric_). Celková kognitivní a technická složitost ze systému nezmizela, pouze se přesunula z deklarativních souborů GitHub Actions do složitého vnitřního kódu v Pythonu (`agent_runner.py`, `harnesses.py`, `environment.py`), který musí autor sám vyvíjet, testovat a udržovat. Tvrzení o poklesu údržbové zátěže na $O(1)$ ignoruje fakt, že při chybě v centrálním workflow jsou paralyzovány všechny spotřebitelské repozitáře najednou (jediný bod selhání — _single point of failure_). Zásadní otázka oponentury: Jaká je reálná bilance ušetřeného lidského času oproti desítkám hodin strávených laděním a vývojem samotného metaharnessu?]

== Rozšíření na texty

#draft[
Po sjednocení byl systém rozšířen tak, aby popsal i repozitář obsahující text
místo programu. Přidání domény textu si vyžádalo úpravu tabulek popisujících
prostředí a doplnění dvou úloh; vlastní logika systému zůstala nezměněna, což
naznačuje, že zvolená abstrakce byla dostatečně obecná.

Ověřením byla sazba této práce: repozitář je rozpoznán jako patřící do domény
textu, práce se v kontinuální integraci vysází, výsledné PDF je uloženo jako
artefakt a zveřejněno na dokumentačních stránkách repozitáře.
]

== Chyby, které se projevily až v provozu

#draft[
Nasazení odhalilo několik chyb, které se při návrhu neprojevily. Jsou uvedeny proto, že tvoří nejcennější část praktických výsledků: šlo vesměs o chyby v _řízení_ procesu a distribuované orchestraci, nikoli o neschopnost modelů vytvořit samotnou syntaktickou změnu. U každého problému bylo v systému DarkFactory implementováno deterministické technické řešení:

/ Uváznutí souběžnosti (_Concurrency Deadlock_): Volající i volaný pracovní postup použily stejný název skupiny souběžnosti (`concurrency.group`), takže volající běh držel zámek skupiny a volaný podřízený postup (`workflow_call`) zůstal viset ve frontě čekající na uvolnění skupiny vlastním volajícím. Běh skončil tichým vypršením časového limitu bez chybového hlášení.
  *Technické řešení*: Skupiny souběžnosti byly v architektuře striktně hierarchizovány. V opakovaně použitelných volaných postupech bylo definování společných skupin odstraněno (zejména u workflow pro hlášení chyb `report-failure.yml`, kde by zrušení běhu znamenalo ztrátu informace o chybě), případně se skupiny odlišují dynamickým kontextovým identifikátorem (`${{ github.workflow }}-${{ github.ref }}`), čímž je zamezeno vzájemnému blokování.

/ Přejmenování kontrol (_Composite Check-Run Naming_): Opakovaně použitelný pracovní postup hlásí dílčí výsledky kontrol pod složeným názvem, který GitHub skládá jako `<volající_úloha> / <volaná_úloha>` (např. `pipeline / pipeline (3.12)` nebo `pipeline / docs`). Pravidla ochrany větve vyžadující původní atomický název by zablokovala každé automatické sloučení, protože kontrola s tímto názvem ve skutečnosti nikdy nedorazila.
  *Technické řešení*: Do konfiguračního manifestu `darkfactory.json` byla zavedena deklarace klíče `required_checks`. Automatizační skript `repo_settings.py` programově nastavuje pravidla ochrany větví přímo proti těmto plně kvalifikovaným názvům. Soulad mezi reálně emitovanými názvy úloh v `ci.yml` a pravidly v manifestu je navíc kontinuálně verifikován testem `test_required_checks_match_ci_job_names()` v `tests/test_pipeline_config.py`.

/ Tiché selhání zápisu na nástěnku (_Silent Board Mutation Failure_): Operace zapisující stav na projektovou nástěnku GitHub Projects v2 byly v obslužném kódu obaleny generickým zachycením všech výjimek (`except Exception`), aby selhání API neshodilo celou pipeline. Výsledkem však bylo, že neúspěšné mutace skončily s návratovým kódem 0 jako úspěch a výpadek vyšel najevo až ruční kontrolou nástěnky.
  *Technické řešení*: Skript `project_automation.py` byl přepracován tak, že každé neúspěšné volání REST/GraphQL rozhraní zaznamená do centrálního zásobníku `FAILURES`. Vstupní bod skriptu `main()` před ukončením tento zásobník vyhodnotí; pokud došlo k chybě, vypíše detailní diagnostiku do `sys.stderr` a proces explicitně ukončí s nenulovým kódem (`sys.exit(1)`). Tento pád okamžitě aktivuje záchytné workflow `report-failure.yml`, které založí úkol v GitHub Issues s odkazem na neúspěšný běh.

/ Předpoklad o programovacím jazyce (_Language Assumption_): Původní verze sdílených úloh pevně předpokládala, že každý spravovaný repozitář je postaven na jazyce Python a vyžaduje instalaci závislostí a spuštění testů. Repozitář obsahující pouze text a sazbu (např. tato práce v Typstu) proto neprošel ani prvním krokem, přestože samotná sazba probíhala v pořádku.
  *Technické řešení*: V systému vznikl samostatný detekční subsystém `environment.py`, který dynamicky zkoumá přítomnost manifestů (`pyproject.toml`, `Cargo.toml`, `typst.toml`, `lakefile.toml`) a na jejich základě sestavuje exekuční plán (`build_plan()`, `docs_plan()`). Prostředí je kategorizováno do domén (`kód`, `text`, `matematika`) a jednotlivé kroky workflow jsou podmíněny výstupy detektoru, takže pro repozitář s textem se testy kódu bezpečně přeskočí a úloha skončí neutrálním úspěchem.
]

== Diskuse

#draft[
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

#draft[
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
