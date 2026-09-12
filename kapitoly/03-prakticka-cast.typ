#import "../lib/odborna-prace.typ": note, issue, alert, struct-alert, critique, added, draft, unconfirmed, confirmed, removed, diff

= Praktická část

#confirmed[
Praktickou částí práce je systém *DarkFactory* — sada pravidel, skriptů
a pracovních postupů, které z repozitáře udělají samostatně pracující vývojový
provoz. Zdrojový kód je veřejně dostupný @darkfactory.
]

== Cíl a rozsah systému

#confirmed[
Systém má převzít rutinní kroky vývojového procesu: přijetí požadavku, jeho
interpretaci, naplánování, provedení změny a její ověření. Nemá nahradit
rozhodování o tom, co se má stavět; to zůstává člověku, a systém je navržen tak,
aby si toto rozhodnutí vyžádal dříve, než začne pracovat.
]

== Architektura

#draft[
Systém DarkFactory je navržen jako modulární stavebnice složená z řídicích skriptů v jazyce Python, šablon pracovních postupů pro GitHub Actions a hermetického#footnote(numbering: "*")[Pojem *hermetické prostředí* (angl. _hermetic environment_) označuje v softwarovém inženýrství takové výpočetní a běhové prostředí, které je zcela izolované od nekontrolovaných stavů hostitelského operačního systému a okolní sítě. Veškeré nástroje, knihovny a systémové závislosti jsou v něm explicitně deklarovány a uzamčeny na konkrétních verzích, což zaručuje absolutní determinismus a reprodukovatelnost: proces spuštěný v hermetickém kontejneru skončí vždy identickým výsledkem bez ohledu na to, kde a kdy byl vyvolán.] kontejnerového prostředí. Architektura striktně odděluje deklarativní konfiguraci konkrétního repozitáře od samotné logiky orchestrace.
]

#figure(
  image("../img/components-darkfactory.svg", width: 100%),
  caption: [Dekompozice komponent systému DarkFactory: třívrstvá architektura propojující platformu GitHub, výkonné skriptové jádro a izolované běhové prostředí s modely.],
) <fig-komponenty>

#draft[
Celý systém je dekomponován do tří funkčních vrstev znázorněných na @fig-komponenty:

1. *Vrstva deklarace a platformy GitHub*: Zahrnuje centrální konfigurační soubor `darkfactory.json` jako jediný zdroj pravdy pro daný repozitář, rozhraní GitHub Issues pro zadávání požadavků v doslovném znění a projektovou nástěnku GitHub Projects v2, která vizualizuje stav pipeline napříč všemi zapojenými repozitáři v sedmi stavech (od _Backlog_ po _Done_).
2. *Výkonné jádro pipeline (`.github/scripts/`)*: Tvoří jej sada úzce spolupracujících skriptů v jazyce Python. Klíčovým prvkem je `agent_runner.py` jako hlavní stavový automat řídící životní cyklus požadavku. Doplňuje jej `harnesses.py` pro sjednocení rozhraní různých modelů (Antigravity, Claude Code, Codex, Kimi) a rotaci kvótových účtů, `project_automation.py` pro obousměrnou synchronizaci stavů přes GraphQL rozhraní a skripty `open_pr.py` spolu s `handle_pr_approval.py` zajišťující automatické vystavení pull requestu botem a následný bezpečný squash-merge po schválení člověkem.
3. *Izolované běhové prostředí a nástroje*: Zahrnuje kontejnerový sandbox (`docker/Dockerfile.agent`), který hermeticky izoluje běh agenta od hostitelského CI runneru. Agent operuje v izolované větvi repozitáře a veškerý postup je průběžně atomicky serializován do kontrolních bodů (`.checkpoint.json`), což umožňuje bezeztrátové předání štafety mezi různými poskytovateli.

Návrh vychází z jednoho základního požadavku: pracovní postupy i skripty musí být ve všech repozitářích totožné. Kdyby se kopírovaly, začaly by se rozcházet, a oprava chyby by se musela provádět tolikrát, kolik je repozitářů.
]

=== Sdílení místo kopírování

#draft[
Pracovní postupy jsou proto _volané_, nikoli kopírované. Repozitář, který systém
používá, obsahuje pouze krátký soubor odkazující na sdílený pracovní postup
připnutý ke konkrétní verzi. Připnutí je podstatné: bez něj by se změna sdíleného
postupu okamžitě promítla do všech repozitářů, včetně těch, které na ni nejsou
připraveny.
]

=== Jediný konfigurační soubor

#confirmed[
Vše, co se mezi repozitáři liší, je soustředěno do jediného souboru
`darkfactory.json`. Ten popisuje totožnost repozitáře, jeho oblasti, nástěnky,
na které patří jeho úkoly, a případné odchylky od výchozího chování. Sdílený
postup je díky tomu ve všech repozitářích shodný bajt po bajtu.
]

#figure(
  ```json
  {
    "identity": {
      "owner": "marius-patrik",
      "repo": "DarkFactory",
      "default_branch": "darkfactory"
    },
    "versioning": {
      "mode": "semver",
      "tag_prefix": "v",
      "initial": "0.1.0"
    },
    "areas": {
      "$default": "ci",
      "agents": {
        "description": "Orchestration, personas, adapters",
        "keywords": ["agent", "harness", "persona", "prompt"]
      },
      "governance": {
        "description": "Branch protection, required checks",
        "keywords": ["governance", "rule", "protection", "board"]
      },
      "ci": {
        "description": "GitHub Actions workflows, runner scripts",
        "keywords": ["ci", "action", "workflow", "docker"]
      }
    },
    "board": {
      "global_title": "Global",
      "link_boards": ["Global", "DarkFactory", "Omnis", "ChessWithQuests"]
    }
  }
  ```,
  caption: [Ukázka konfigurace v souboru `darkfactory.json` vymezující identitu repozitáře, doménové oblasti (`areas`) a propojení s projektovými nástěnkami.],
) <kod-darkfactory-json>

#draft[
Jak je patrné z @kod-darkfactory-json, sekce `areas` slouží jako jednotný zdroj pravdy pro štítkování úkolů i směrování agentů podle shody klíčových slov. Sekce `board` pak zajišťuje agregaci do globální i repozitářové GitHub Projects nástěnky bez nutnosti manuální konfigurace v samotných workflow.
]

== Životní cyklus požadavku

#draft[
Požadavek prochází systémem v pevně daných krocích, mezi nimiž jsou striktně vyžadovány schvalovací body pro udržení lidské kontroly nad rozsahem i kvalitou implementace.
]

#figure(
  image("../img/lifecycle-darkfactory.svg", width: 100%),
  caption: [Stavový diagram životního cyklu požadavku v systému DarkFactory: přechody mezi stavy od založení issue přes schvalovací brány (Human Gates), tvorbu větve a PR až po automatické sloučení a uzavření úkolu.],
) <fig-zivotni-cyklus>

#draft[
Jednotlivé kroky životního cyklu znázorněné na @fig-zivotni-cyklus na sebe navazují v přesně daném pořadí:

+ *Zadání úkolu*: Uživatel založí požadavek (GitHub Issue) s doslovným zněním svého zadání.
+ *Interpretace*: Systém požadavek analyzuje (`interpreted`) a předloží své porozumění rozsahu.
+ *Human Gate 1 (Schválení záměru)*: Člověk potvrdí, že systém pochopil cíl správně.
+ *Návrh plánu*: Po schválení vzniká podřízený úkol (`planned`) s technickým rozpisem kroků.
+ *Human Gate 2 (Schválení plánu)*: Člověk schválí technický plán dříve, než dojde k zásahu do kódu.
+ *Kódování a verifikace*: Systém vytvoří větev (`branch created`), agent napíše kód i testy a provede vlastní přezkoumání a ověření proti plánu.
+ *Návrh změny (`PR open`)*: Bot otevře pull request a spustí integrační CI kontroly.
+ *Human Gate 3 a dokončení*: Po schválení pull requestu člověkem systém provede automatické sloučení (`auto-merge`), smaže větev a uzavře rodičovský úkol.

Doslovné znění zadání je uchováno záměrně. Zkušenost z vývoje ukázala, že právě parafráze bývá zdrojem nedorozumění: shrnutí požadavku se zdá výstižné tomu, kdo je psal, a přitom už neobsahuje to, na čem zadavateli záleželo.
]

#critique[Pochybná autonomie a paralýza lidským faktorem: Název „DarkFactory“ evokuje bezobslužnou továrnu (angl. _lights-out manufacturing_), která běží plně autonomně bez lidského zásahu. Zavedení tří synchronních schvalovacích bran (Human Gate 1: záměr, Human Gate 2: plán, Human Gate 3: PR) však z procesu činí silně blokující workflow. Pokud musí člověk manuálně schválit každou fázi drobného úkolu, tráví agent 95 % životního cyklu čekáním na lidskou reakci. Skutečná průchodnost systému je pak determinována latencí člověka, nikoli rychlostí modelů. Práce navíc ignoruje fenomén únavy ze schvalování (_review fatigue_), kdy člověk po desítkách syntetických notifikací rezignuje na důkladnou kontrolu a začne plány i diffy schvalovat mechanicky bez čtení.]

== Popis prostředí repozitáře

#draft[
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
]

=== Domény a prostředí

#draft[
Rozlišení dvou úrovní se ukázalo jako nutné až v průběhu práce. _Prostředí_ říká,
jaký nástroj je potřeba; _doména_ říká, jakému způsobu řízení výsledek podléhá.
Python a Rust jsou dvě prostředí téže domény — kód se testuje a balí. Typst
a LaTeX jsou dvě prostředí jiné domény — text se sází a publikuje.

Toto rozlišení dovoluje popsat i repozitář, který obsahuje zároveň program
a text — jako právě tato práce, jejíž praktickou částí je software popisovaný
v @tab-prostredi. Bez něj by bylo nutné buď považovat sazbu za zvláštní případ
kódu, nebo pro texty vytvořit samostatný systém.
]

=== Deklarace jako doplněk rozpoznávání

#draft[
Rozpoznávání nemůže vidět všechno. Repozitář této práce například přibaluje
vlastní písma, takže příkaz pro sazbu není výchozí. Konfigurační soubor proto
umožňuje výchozí chování přepsat, aniž by bylo nutné vypnout rozpoznávání jako
celek.
]

#note[Doporučení k názornosti: Uvést konkrétní ukázku z konfiguračního souboru nebo příkazové řádky ukazující, jak se přepisuje výchozí příkaz pro sazbu (např. parametr `--font-path fonts`), aby měl čtenář přímou představu o realizaci doplňkové deklarace.]

== Orchestrace napříč poskytovateli

#draft[
Systém neváže na jednoho poskytovatele modelu. Úkol je popsán způsobem nezávislým
na rozhraní a předán prvnímu dostupnému poskytovateli; vyčerpá-li tento kvótu,
předá se tentýž úkol dalšímu v pořadí, místo aby se proces zastavil.

Tato vlastnost byla přímou reakcí na provozní zkušenost: zastavení celého procesu
kvůli vyčerpané kvótě jediného poskytovatele bylo nejčastější příčinou prostoje.

Mechanika předávání štafety (_baton handover_) probíhá zcela pod kontrolou nadřazeného procesu (`agent_runner`). Jakmile volající skript zachytí vyčerpání limitů (např. HTTP kód 429 nebo chybový stav `RESOURCE_EXHAUSTED`), okamžitě zmrazí aktuální běh a provede atomickou serializaci stavu:
+ *Pracovní strom v Gitu*: Veškeré rozpracované úpravy v souborovém systému jsou uloženy do pracovní větve a vytvoří se kontrolní otisk (`git diff`).
+ *Serializace kontextu a štafety*: Log konverzace (předchozí kroky, volání nástrojů i vrácená pozorování) je spolu s metadaty úkolu zapsán do strukturovaného kontrolního bodu (_checkpoint_ ve formátu JSON).
+ *Rotace po žebříčku kapacit*: Runner neponižuje model na slabší variantu v témže fondu (což by novou kapacitu nepřineslo), nýbrž rotuje účty, oddělené kvótové fondy (_quota pools_) nebo přepne na záložní CLI harness (např. Antigravity, Claude Code či Codex).
+ *Rekonstituce a navázání*: Náhradní agent obdrží serializovanou štafetu, jeho adaptér přeloží historii kroků do nativního formátu nového poskytovatele a ověří stav repositáře. Běh plynule naváže v přesném bodě přerušení, aniž by došlo ke ztrátě dosavadní práce či kontextu.
]

#critique[Kritická slepá skvrna v heterogenní štafetě: Představa, že odlišný model (např. Claude po Antigravity či Codexu) plynule naváže na rozpracovanou práci pouhým načtením serializovaného logu a git diff, zamlčuje zásadní problém nekompatibility vnímání kontextu (_prompt sensitivity_). Každá modelová rodina vyžaduje diametrálně odlišný formát nástrojů, odlišně reaguje na systémový prompt a jinak interpretuje mezivýsledky. V reálném provozu vede synteticky přeložená historie často k okamžité dezorientaci nového modelu, opakování již hotových kroků nebo halucinaci neexistujících nástrojů. Práce neobsahuje žádné empirické vyhodnocení úspěšnosti štafety: Kolik úloh po předání štafety skutečně úspěšně doběhlo a v kolika procentech případů vedla rotace k havárii a divergenci kontextu?]

== Ověřování změn

#draft[
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
]

== Hlášení selhání

#alert[Strukturální nepoměr a fragmentace: Samostatná kapitola 2. úrovně (==) tvořená jediným odstavcem o čtyřech řádcích působí nevyváženě. Z hlediska logické výstavby textu je vhodnější tuto pasáž začlenit jako podsekci (===) pod sekci „Ověřování změn“, případně ji sloučit s popisem celkové architektury a hlášení chyb do GitHub Issues.]

#draft[
Selhání kterékoli úlohy zakládá úkol s odkazem na neúspěšný běh. Opakované
selhání téže úlohy nezakládá další úkol, nýbrž doplní komentář ke stávajícímu;
bez toho by úloha selhávající při každé změně zahltila seznam úkolů. Jakmile
úloha znovu uspěje, úkol se sám uzavře.
]

== Automaticky generovaná dokumentace

#added[
V moderním softwarovém vývoji představuje manuální údržba dokumentace permanentní zdroj chyb a desynchronizace: jakmile se kód vyvíjí rychleji než textové popisy, dokumentace se nevyhnutelně stává zastaralou a nespolehlivou. Systém DarkFactory proto prosazuje striktní princip stoprocentního odvozování veškeré projektové a API dokumentace přímo ze zdrojového kódu a strukturovaných inline komentářů (tzv. _living documentation_).

Tento přístup využívá přirozené standardy konkrétních programovacích jazyků a prostředí:
- *Python*: Dokumentační komentáře v konvenci Google-style docstrings, z nichž generátor automaticky extrahuje typy parametrů, návratové hodnoty a signatury výjimek.
- *TypeScript / JavaScript*: Standardizované bloky TSDoc (`/** ... */`) anotující rozhraní, typové definice a exportované funkce.
- *Rust*: Integrované dokumentační komentáře `///` kompilované nativním nástrojem `cargo doc`.

Zásadní inovací je zařazení striktní verifikace do každého integračního běhu v CI (např. voláním `properdocs build --strict` či odpovídajících linterů dokumentace). Jakýkoli chybějící docstring nově přidané funkce, syntaktická chyba v parametrech nebo neplatný křížový odkaz na neexistující symbol způsobí okamžité selhání validační úlohy v CI a zablokuje sloučení změny. Když autonomní agent implementuje nový modul, je tímto mechanismem deterministicky nucen vytvořit a aktualizovat i kompletní dokumentační anotace.

Po úspěšném schválení pull requestu člověkem a jeho sloučení do hlavní větve centrální pracovní postup automaticky sestaví statickou podobu dokumentačního portálu a publikuje jej na GitHub Pages. Tím odpadá jakákoli manuální údržba externích zrcadel a dokumentace zůstává v absolutní shodě s reálným stavem kódu.
]

== Systém revizních značek pro lidský dohled nad textem

#draft[
Při rozšiřování systému DarkFactory na správu a tvorbu dokumentace (doména textu) vyvstala potřeba formalizovat spolupráci člověka a autonomního agenta přímo v sazebním formátu Typst. Výsledkem je protokol vizuálních revizních značek (*Review Markers*) a textových revizních funkcí, který barevně a sémanticky rozlišuje stav zpracování jednotlivých pasáží:
]

#note[Konstruktivní doporučení, nápady na rozšíření, doplnění schémat či návrhy na praktické propojení. Po zapracování se panel smaže.]

#issue[Detekované věcné nepřesnosti, logické mezery, překlepy nebo duplicita obsahu. Značka přesně formuluje vadu a zaniká s jejím odstraněním.]

#alert[Upozornění na hloubkovou nevyváženost kapitol, chybějící dekompozice komponent či nesoulad s osnovou práce.]

#critique[Hloubková teoretická a architektonická oponentura bez servítků — odhalování slepých míst, neověřených předpokladů, bezpečnostních rizik a metodologických slabin formulovaných jako břitké otázky k obhajobě.]

#draft[
V toku textu se uplatňují tyto zvýrazňovací a srovnávací funkce:
]

- #draft[Žluté zvýraznění (`#draft[...]` / `#unconfirmed[...]`): Označuje neověřený text konceptu čekající na autorské posouzení a revizi.]
- #added[Zelené zvýraznění (`#added[...]`): Označuje nově přidaný text vygenerovaný autonomním agentem na základě požadavku či doporučení.]
- #confirmed[Modré zvýraznění (`#confirmed[...]`): Označuje text potvrzený uživatelem, který dosud neprošel finální integrací.]
- #removed[Červené zvýraznění s přeškrtnutím (`#removed[...]`): Označuje text navržený k odstranění z rukopisu.]
- #diff[Původní nahrazovaný text][Srovnávací diff (`#diff(old, new)`): Zobrazuje původní text přeškrtnutý v červené barvě následovaný novým textem v zelené barvě.]
- Čistý neoznačený text představuje finální, autorsky schválený a přijatý text v hlase autora (v rozpracovaném stavu konceptu jsou veškeré dosud neuzavřené pasáže zviditelněny revizními funkcemi).

#draft[
Tento protokol umožňuje autonomnímu agentovi navrhovat změny s transparentním vyznačením míry jistoty a člověku poskytuje okamžitou vizuální kontrolu nad tím, které části rukopisu již prošly lidskou redakcí a které ještě čekají na posouzení.
]
