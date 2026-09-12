#import "../lib/odborna-prace.typ": note, issue, alert

#let ai(body) = highlight(fill: yellow, body)

= Teoretická část

Tato kapitola vymezuje pojmy, o které se opírá praktická část: řízení verzí,
kontinuální integraci, orchestraci jazykových modelů a princip zapojení člověka
do smyčky (_Human-in-the-loop_). Cílem není vyčerpávající přehled, nýbrž zavedení
pojmů v podobě, v jaké s nimi pracuje navržený systém.

== Řízení verzí

Systém pro řízení verzí uchovává historii změn zdrojového kódu. Distribuovaný
model, jehož nejrozšířenějším zástupcem je Git, se od centralizovaného liší tím,
že každý vývojář má úplnou kopii historie @chacon2014. Změny lze proto vytvářet
a zkoumat i bez spojení se serverem a slučovat je až ve chvíli, kdy jsou hotové.

=== Větve a jejich role

Větev je pojmenovaný ukazatel na určitý stav historie. Práce na nové vlastnosti
probíhá ve větvi oddělené od hlavní vývojové linie, takže rozpracovaný stav
neovlivní ostatní. Tento postup má i důsledek pro automatizaci: dokud změna
existuje pouze ve větvi, lze ji libovolně ověřovat, aniž by hrozila škoda.

=== Model pull requestu

Sloučení větve do hlavní linie se ve většině dnešních projektů odehrává
prostřednictvím _pull requestu_ — návrhu změny, který lze komentovat, ověřovat
a schvalovat. Pull request je proto přirozeným místem, kde se uplatňuje kontrola
kvality, a zároveň místem, kam lze vložit schvalovací bod pro člověka.

== Kontinuální integrace

Kontinuální integrace (angl. _continuous integration_) je praxe, při níž se
každá změna automaticky sestaví a otestuje @humble2010. Namísto dlouhých období,
kdy se změny hromadí a slučují až na konci, se ověřuje průběžně a v malých
dávkách, takže chyba je odhalena blízko svému vzniku.

=== Požadované kontroly

Ke kontinuální integraci patří pojem _požadovaných kontrol_ (angl. required
checks): množina úloh, které musí skončit úspěšně, jinak nelze změnu sloučit.
Tím se z kvality stává vlastnost vynucovaná strojem, nikoli pouze dohodou mezi
vývojáři.

Návrh požadovaných kontrol má jedno nezřejmé úskalí. Úloha, která se za jistých
okolností „přeskočí“, nehlásí žádný výsledek; je-li přitom uvedena mezi
požadovanými, zablokuje slučování napořád. Kontrola proto musí vždy skončit
nějakým závěrem — i kdyby jím bylo konstatování, že v daném repozitáři není
co dělat.

=== Sestavení a artefakty

Výsledkem sestavení bývá _artefakt_: spustitelný soubor, knihovna, nebo — jak
ukazuje praktická část — vysázený dokument. Automatizace vydávání verzí spojuje
artefakt se značkou v historii, takže ke každé vydané verzi existuje doložitelný
výstup.

== Jazykové modely a jejich orchestrace

=== Transformer a LLM

Transformer je architektura hlubokých neuronových sítí představená společností Google v roce 2017 v rámci výzkumu strojového překladu. Na rozdíl od starších architektur (např. rekurentních sítí RNN), které sekvence zpracovávaly krok po kroku a trpěly ztrátou dlouhodobého kontextu, využívá transformer mechanismus zvaný _attention_ (pozornost). Ten modelu umožňuje paralelně vyhodnocovat sémantické souvislosti mezi všemi tokeny v sekvenci bez ohledu na jejich vzájemnou vzdálenost.

LLM neboli _Large Language Model_ (velký jazykový model) je rozsáhlá neuronová síť postavená na architektuře transformeru a předtrénovaná na textových datech o objemu stovek miliard až bilionů tokenů. Díky mechanismu pozornosti model dokáže zachytit hluboké syntaktické i sémantické struktury přirozeného jazyka, což se navenek projevuje schopností generalizace, abstrakce a generování korektního zdrojového kódu.

#ai[
Tento architektonický přelom popsala publikace _Attention Is All You Need_ @vaswani2017. Původní model byl koncipován jako *Encoder-Decoder* (kodér-dekodér) pro strojový překlad: obousměrný kodér nejprve zkomprimoval celou vstupní větu a dekodér za pomoci křížové pozornosti (_cross-attention_) generoval překlad v cílovém jazyce.

Ve vývoji softwaru a moderních agentních systémech se však naprostým standardem stala architektura *Decoder-only* (např. GPT, Claude, LLaMA či DeepSeek). Tyto modely pracují čistě autoregresivně — predikují vždy následující nejpravděpodobnější token na základě celého předcházejícího kontextu. Instrukce, pravidla, kontext repozitáře i rozepsaný kód tvoří jedinou společnou sekvenci, což umožňuje plynulé doplňování kódu i přímé generování volání nástrojů. Architektura pouze s dekodérem navíc vykazuje vynikající vlastnosti při škálování parametrů a efektivní správě KV cache v dlouhých kontextech.
]

=== Tokeny, tokenizér a embedding

#ai[
Text, se kterým člověk pracuje ve formě slov a vět, není pro neuronovou síť přímo srozumitelný. Model interně operuje pouze s čísly a maticovými operacemi. Aby bylo možné přirozený jazyk zpracovat, musí projít procesem tokenizace a následného převodu na vektorové reprezentace.

Základní jednotkou, kterou model vnímá, je *token*. Token nemusí odpovídat celému slovu ani jednotlivému znaku — moderní jazykové modely využívají tzv. sub-word tokenizaci (nejčastěji algoritmy jako Byte-Pair Encoding či WordPiece). Běžná slova jsou často reprezentována jediným tokenem, zatímco méně častá slova, odborné výrazy nebo slova v jazycích s bohatou morfologií a diakritikou (jako je čeština) jsou rozložena do více dílčích tokenů. Průměrně jeden token v angličtině odpovídá přibližně 3 až 4 znakům. V češtině je spotřeba tokenů na slovo znatelně vyšší, což má přímý dopad na efektivní kapacitu kontextového okna i výpočetní náklady inference.

Převod mezi surovým textovým řetězcem a posloupností celočíselných identifikátorů (token IDs) zajišťuje *tokenizér*. Jedná se o deterministický program, který vychází z pevně daného slovníku (tzv. vocabulary, obvykle čítajícího 32 000 až 128 000 unikátních tokenů). Tokenizér provádí obousměrný proces: při vstupu rozseká text na tokeny a přiřadí jim číselné indexy, při výstupu naopak generované indexy skládá zpět do souvislého textu (tzv. detokenizace).

Samotné číslo tokenu však nenese žádnou informaci o jeho významu. Proto následuje vrstva zvaná *embedding* (vektorové vnoření). Každý token je převeden na spojitý vícerozměrný vektor (typicky o dimenzi 4 096 či 8 192 čísel). V tomto geometrickém prostoru jsou slova s podobným významem či kontextem umístěna blízko u sebe (např. měřeno kosinovou podobností).

Jednotlivé geometrické směry a posuny v prostoru navíc odpovídají konkrétním sémantickým relacím a abstraktním vlastnostem. Zjednodušeným a klasickým příkladem fungování tohoto prostoru je vektorová aritmetika pojmů: pokud vezmeme vektor reprezentující pojem „žena“ a přičteme k němu vektor reprezentující posun k „panovnickému stavu / královskému statusu“, výsledný bod v prostoru leží nejblíže reprezentaci slova „královna“ ($arrow(v)("žena") + arrow(v)("královský status") approx arrow(v)("královna")$). Model tak nepracuje se slovy jako s izolovanými symboly, ale manipuluje se vztahy mezi nimi jako s algebraickými posuny ve vícerozměrném prostoru — což se v programování projevuje schopností zachytit vztahy mezi deklarací proměnné, jejím použitím a typovým kontextem.

Aby architektura transformeru zohlednila také pořadí tokenů v sekvenci, přičítá se k sémantickému embeddingu poziční kódování (positional encoding, dnes standardně rotační embedding RoPE). Teprve takto vzniklé vektory vstupují do mechanismu pozornosti k dalšímu výpočtu.
]

#note[Vhodné doplnit malou srovnávací tabulku či praktický příklad: kolik tokenů spotřebuje identický větný význam v češtině oproti angličtině (např. pomocí knihovny tiktoken), což krásně podloží argumentaci o efektivním využití kontextového okna a nákladech na inference.]

=== Multimodální modely

#ai[
Architekturu transformeru lze aplikovat i mimo oblast zpracování přirozeného jazyka. V moderní praxi lze tokenizovat v podstatě jakýkoli diskrétní či spojitý signál — ať už jde o rastrový obraz, sekvenci snímků videa, zvukové vlny nebo trajektorie pohybů v robotice. Zásadní posun nastává ve chvíli, kdy model disponuje oddělenými projekčními vrstvami pro různé typy vstupů (např. kombinací textového tokenizéru a vizuálního enkodéru, jako je ViT — _Vision Transformer_) a mechanismus pozornosti (_cross-attention_) operuje společně nad tokeny textu i obrazu. Model tak dokáže propojovat vizuální a textové sémantické reprezentace ve sdíleném vektorovém prostoru.

V kontextu automatizovaného vývoje softwaru a autonomních pipeline (jako je systém DarkFactory) se multimodální schopnosti uplatňují ve třech klíčových oblastech:
+ *Vizuální regresní testování*: Model dokáže porovnat referenční snímek uživatelského rozhraní se stavem vygenerovaným v CI (např. při testování webových komponent bezhlavým prohlížečem) a identifikovat nežádoucí posuny rozvržení či stylové chyby.
+ *Diagnostika chyb z artefaktů CI*: Při selhání integračních testů může pipeline předat agentovi screenshot chybové obrazovky nebo interaktivního prvku, z něhož agent rozpozná příčinu selhání snáze než z pouhého textového stack trace.
+ *Interpretace grafických zadání*: Vývojář může v zadání úkolu (GitHub Issue) specifikovat požadovanou změnu formou náčrtku, wireframu či diagramu komponent. Multimodální agent takový grafický podklad přímo zanalyzuje a převede jej na strukturovaný kód.
]

=== Context

==== Turn

Každému kroku mezi modelem a uživatelem se říká turn, nebo specificky model turn pro každé spuštění inference.

==== Context Window

Model je schopen přijmout pouze omezený objem vstupu; tomuto limitu se říká kontextové okno (_Context Window_) a vyjadřuje se v počtu tokenů. Na rozdíl od slovníku (_vocabulary_), který vymezuje pouze repertoár známých tokenů, je maximální délka kontextového okna určena architekturou pozičního kódování (např. škálováním frekvenčních bází v RoPE) a hardwarovou náročností mechanismu pozornosti — kvadratickou složitostí $O(N^2)$ a velikostí alokované KV cache v operační či grafické paměti.

==== Compaction

Je akce, kterou provede harness v moment kdy se CW naplní. Prakticky se jedná o externí vyvolaní modelu s intrukcí, aby zkrátil konverzaci a vloženým celým logem konverzace. Výsledný zkracený context je od té chvíle používán místo původní části konverzace.

==== Context Rot

#issue[Jazykové a terminologické nedostatky v definici kontextu: V odstavci Compaction překlepy „intrukcí“ -> *instrukcí*, „zkracený“ -> *zkrácený*, „vyvolaní“ -> *vyvolání*. V odstavci Context Rot hrubka ve shodě přísudku s podmětem („modely ... nejsou schopni“ -> *nejsou schopny*), chybějící čárka před vztažným „čím plnější“ a nepřesný hovorový obrat „ztrácí inteligenci“ namísto odborného popisu degradace pozornosti u dlouhých sekvencí.]

Je koncept, který byl pozorován v praxi, kdy modely ztrácí inteligenci a nejsou schopni si zapamatovat detaily ze začátku čím plnější je CW.

==== KV Caching

KV caching slouží ke snížení výpočetní náročnosti modelu při generování tokenů. Místo toho, abychom při každém kroku inference znovu od začátku počítali pozornost pro celou dosavadní konverzaci, ponechává inferenční engine v paměti uložené již vypočtené vektory klíčů a hodnot (_Key-Value pairs_) a v každém kroku počítá a přidává pouze nově vygenerovaný token.

=== Prompt Engineering

_Prompt engineering_ (inženýrství promptů) je disciplína zaměřená na systematický návrh, formulaci a optimalizaci textových instrukcí předkládaných modelu @anthropic-prompt. V autonomních agentních systémech nepředstavuje prompt pouhou volnou konverzaci, ale slouží jako závazný kontrakt vymezující chování, práva a bezpečnostní mantinely agenta. Mezi klíčové techniky patří:

- *Systémový prompt (System Prompt)*: Základní direktiva definující identitu agenta, dostupné nástroje a striktní provozní pravidla (např. pravidla pro zachování neměnnosti existujících testů, konvence pro formát commitů či zákaz destruktivních operací v repozitáři).
- *Few-shot prompting*: Technika vložení několika vzorových příkladů (vstup-výstup) přímo do kontextu. Tím model získá konkrétní představu o požadovaném schématu (např. syntaxi konfiguračního souboru `darkfactory.json`) bez nutnosti dodatečného dotrénování parametrů.
- *Chain-of-Thought (myšlenkový řetězec)*: Vedení modelu k explicitní formulaci mezikroků a vnitřní dedukce před vygenerováním konečného kódu či akce. Rozklad komplexního zadání na postupné logické kroky zásadně potlačuje halucinace a tvoří základ fáze rozvahy (_Thought_) v cyklu ReAct.
- *Injekce dynamického kontextu*: Průběžné doplňování promptu o aktuální stav repozitáře, stromovou strukturu souborů, chybové výpisy kompilátoru a výsledky testů, díky čemuž agent operuje nad reálnými fakty namísto odhadů.

=== Agent vs Chatbot

#issue[Překlepy a nespisovný styl: Překlepy „stáva ve chvilí“ -> *stává ve chvíli*, hovorová zkratka „AKA“ a neakademické tykání čtenáři („váš počítač“ namísto *hostitelský systém* či *výpočetní prostředí*).]

Rozdíl mezi chatbotem a agentem je v principu, že chatbot je schopný pouze textu v konverzaci AKA chatu, agent se z něj stáva ve chvilí kdy je schopný dělat více než to, tedy když mu přidáme nástroje, se kterými může například prohledávat web, upravovat soubory nebo i přímo ovládat váš počítač.

=== Harness a System Prompt

Harness je řídicí program obklopující jazykový model. Odlišuje se od inferenčního jádra (_inference engine_), které provádí samotné maticové výpočty sítě: harness má na starost rozhraní mezi uživatelem a agentem či chatbotem, předávání systémového promptu, bezpečné spouštění nástrojů a řízení iterativní smyčky neboli ReAct smyčky. Mezi typické příklady patří webová aplikace ChatGPT, terminálové rozhraní Claude Code, desktopová aplikace Codex a další agentní prostředí.

=== ReAct smyčka

Smyčka ReAct (_Reasoning and Acting_) tvoří základní stavební kámen, který z jazykového modelu vytváří autonomního agenta namísto pouhého pasivního generátoru textu @yao2022. Princip nespočívá v pouhém přečtení vstupu a vykonání akce, nýbrž v soustavné alternaci vnitřní rozvahy (_Reasoning_ neboli _Thought_) a vnějšího jednání (_Acting_ neboli _Tool Call_). Model v každém kroku nejprve formuluje hypotézu či myšlenkový postup, na jehož základě provede cílenou akci.

Po vykonání akce harness připojí vrácený výsledek (_Observation_) do kontextového okna na konec logu konverzace. V navazujícím kroku inference model zhodnotí nový stav a cyklus opakuje, dokud úkol není vyřešen nebo dokud nerozhodne, že má dostatek podkladů pro předání finální odpovědi uživateli. Tímto způsobem je dosaženo adaptivního řešení problémů namísto jednorázové slepé generace.

#figure(
  image("../img/react-loop.svg", width: 100%),
  caption: [Architektura autonomní ReAct smyčky (Reasoning + Acting) a tok dat mezi uživatelem, kontextem, modelem a výkonným prostředím.],
) <fig-react-loop>

Diagram na @fig-react-loop znázorňuje základní iterativní cyklus moderních autonomních agentů. Po přijetí uživatelského zadání dochází v rámci inference k fázi rozvahy (_Reasoning_), kdy model formuluje vnitřní myšlenkový postup (_Thought_). Pokud je k vyřešení kroku zapotřebí externí akce, model vygeneruje strukturované volání nástroje (_Tool Call_). Řídicí harness tento požadavek zachytí, bezpečně vykoná v cílovém prostředí (terminál, souborový systém, API či MCP server) a vrácený výsledek (_Observation_) připojí na konec kontextového okna. Celý aktualizovaný kontext je následně předložen modelu v další iteraci, dokud není úkol kompletní a výsledek předán uživateli. Tento princip byl formálně zaveden v práci _ReAct: Synergizing Reasoning and Acting in Language Models_ (@yao2022, #link("https://arxiv.org/abs/2210.03629")[arXiv:2210.03629]).

=== Vyvolávání nástrojů

Abychom z jazykového modelu vytvořili autonomního agenta, musíme jej vybavit rozhraním pro interakci s okolním prostředím — tzv. nástroji (_tools_). V praxi existují dva převažující přístupy k realizaci nástrojů:

1. *Strukturované volání nástrojů (Function / Tool Calling v JSON)*: Model ve svém výstupu zanechá strukturované volání odpovídající schématu zadanému v definici nástroje. Řídicí harness toto volání zachytí, vykoná požadovanou funkci a vrátí výsledek zpět agentovi opět jako strukturovaná data. Tato možnost je spolehlivá pro jednoúčelové operace (např. integraci do podnikových systémů či zákaznické podpory — angl. _customer support_). Pro komplexní softwarový vývoj však představuje nevýhodu vysoká režie formátu JSON: velké množství formátovacích znaků se převádí na tokeny, což zbytečně plní kontextové okno a může vést k degradaci pozornosti (_Context Rot_).

2. *Přímé spouštění kódu (Code Execution)*: Druhou možností je poskytnout agentovi plnohodnotné běhové prostředí (např. Bash, Python či TypeScript). Agent vygeneruje kód pro splnění svého záměru a harness jej spustí buď po jednotlivých příkazech, nebo jako ucelený skript. Z bezpečnostních důvodů je nezbytné, aby agent nepracoval přímo na nechráněném hostitelském počítači, nýbrž ve virtuálním prostředí odděleném bezpečnostní vrstvou — tzv. sandboxu (pískovišti). Tento způsob je pro softwarový vývoj nejefektivnější.

=== Dovednosti, skripty a záchytné body

Tyto standardy vznikly proto, aby vývojáři mohli modulárně upravovat chování agenta a rozšiřovat jeho schopnosti pro specifické doménové úlohy:

- *Dovednost (_Skill_)*: Samostatný adresář sdružující instrukce, reference a pomocné soubory. Klíčovým prvkem je soubor `SKILL.md`, který využívá hlavičku v metadatovém formátu YAML frontmatter (ohraničenou trojicí pomlček `---`). V hlavičce je definován název a stručný popis dovednosti. Řídicí harness do základního systémového promptu vkládá pouze tato metadata; samotný text podrobného návodu se do kontextu načte až ve chvíli, kdy agent danou dovednost vyvolá. Tím se efektivně šetří kapacita kontextového okna.
- *Skript (_Script_)*: Jednoúčelový spustitelný program (např. v jazyce Python či Bash). Skripty jsou pro efektivitu práce vitální: agent nemusí generovat každý příkaz z paměti, ale spouští deterministické a otestované postupy pro analýzu a transformaci kódu.
- *Záchytný bod (_Hook_)*: Skript, který se v harnessu automaticky vyvolá při určité systémové události či stavovém přechodu (např. při inicializaci sezení, před odesláním promptu modelu nebo při selhání nástroje). Hooky umožňují vynucovat bezpečnostní pravidla a logování nezávisle na vůli samotného modelu.

=== MCP Server

#issue[Pravopisné a stylistické chyby v úvodu k MCP: Překlepy „různe standarty“ (správně *různé standardy*), „veděl“ -> *věděl*, chybějící interpunkce v souvětích („API tedy to sjednotí“ -> *API, tudíž sjednocuje*).]

Model Context Protocol vznikl v laboratoři Anthropicu jako způsob pro efektivní interakci agentů s API servery. Ve své podstatě se jedná o nástroje postavené na základu externího API tedy to sjednotí různe standarty do jednoho a přidá "context" efektivně metadata pro každou přítomnou metodu, aby agent veděl co má od nich čekat a nemusel sám přijít na to jak backend funguje.

#ai[
Praktický význam specifikace Model Context Protocol @anthropic-mcp spočívá ve sjednocení dříve fragmentovaného ekosystému proprietárních rozhraní a jednoúčelových integračních skriptů. Řídicí harness se díky standardu stává univerzálním klientem a veškeré externí schopnosti, datové zdroje či nástroje se integrují jako samostatné procesy — tzv. MCP servery. Komunikace probíhá přes standardizovaný protokol JSON-RPC, a to buď lokálně prostřednictvím standardního vstupu a výstupu (`stdio`), nebo vzdáleně pomocí protokolu HTTP se Server-Sent Events (`SSE`). Tento modulární přístup striktně odděluje běhové prostředí agenta od samotné implementace nástrojů: libovolnou schopnost (např. přístup k databázi, vyhledávání v repozitáři nebo správu GitHub úkolů) stačí naimplementovat jednou a lze ji okamžitě zpřístupnit jakémukoli kompatibilnímu agentovi bez nutnosti zásahu do kódu samotného harnessu.
]

=== Meta Harness

#issue[Jazykové nedostatky a chybějící citace: Překlepy „reálném světe“ -> *reálném světě*, „kontiunální“ -> *kontinuální*, „maximalizovaní“ -> *maximalizování*, „costumer support“ -> *customer support*, chybějící interpunkce a chybějící bibliografický odkaz na práci o Meta Harnessu (@metaharness2026).]

V reálném světe se ukázalo že nejefektivnější harness je takový, který dá samotnému agentovi rozhodnou moc nad jeho architekturou a možnost kontiunální změny tedy evoluce. Toto je sice velice efektivní pro maximalizovaní práce agenta, ale v realném světe se toto dá nasadit pouze pro osobního agenta. Například pro costumer support bota firma určitě nestojí o to aby jejich model přišel na to jak dělat něco jiného.

=== Subagenti

#alert[Strukturální torzo: Sekce o subagentech čítá jedinou větu, ačkoli jde o klíčový koncept moderní víceagentní orchestrace. Je nezbytné buď podkapitolu strukturálně rozpracovat (popsat komunikační vzory, hierarchii rolí, asynchronní zasílání zpráv a delegování specializovaných úloh), nebo ji sloučit s bezprostředně navazující sekcí „Workflows neboli Graph Engineering“.]

Když dáme agentovi nástroj s možností vyvolat jiného agenta, zadat mu úlohu, interagovat s ním a sledovat jeho progress drasticky zvýšíme jeho efektivnost pro rozsáhlé úlohy. Tomuto se říká "subagents".

=== Workflows neboli Graph Engineering

Jakmile se snažíme organizovat nebo automatizovat úlohu složitější než pár kroků začne se systém rozpadat. V tom případě pricházejí "workflows" česky pracovní postupy AKA grafy. Grafy se ve softwarovém vývojí používají ve spoustě situacích. Graf se skláda z nodes a edges neboli bodů a spojů v tomto kontextu to znamená že každý bod je izolovaný agent, který má připravený Prompt Skilly a nástroje a spoje mezi nimy vyznačují cestu informací a práce. Abstrakcí tohoto grafového systému jsme schopni tento pipeline nasadit na jakoukoliv práci klidně i dynamicky pomocí orchestrace dalším agentem.

#issue[Gramatická chyba a překlepy: Hrubka ve shodě „mezi nimy“ (správně *mezi nimi*), překlepy „pricházejí“ -> *přicházejí*, „skláda“ -> *skládá*, „ve vývojí“ -> *ve vývoji* a chybějící interpunkce před vedlejšími větami.]

#ai[
Tento koncept se v informatice označuje jako orientovaný acyklický graf (*DAG* — _Directed Acyclic Graph_). Uzly grafu představují samostatné, specializované výpočetní kroky či izolované agenty, zatímco orientované hrany určují pořadí závislostí a tok kontextových informací. V moderních orchestrátorech a CI/CD platformách (zejména v GitHub Actions) se závislosti mezi úlohami deklarují pomocí direktivy `needs: [...]`.

Jak podrobně rozvádí praktická část této práce na architektuře systému DarkFactory, celý životní cyklus automatizovaného požadavku je strukturován právě jako DAG složený z pěti klíčových fází:
1. *Detekce a kontext*: rozpoznání prostředí projektu, načtení konfiguračního souboru `darkfactory.json` a příslušných systémových pravidel.
2. *Interpretace a plánování*: formulace přesného technického postupu a vytvoření plánovacího úkolu dříve, než dojde k samotnému zásahu do kódu.
3. *Implementace (kódování)*: spuštění agenta s přesně vymezenou sadou nástrojů v izolované větvi repozitáře.
4. *Verifikace a testování*: automatické sestavení projektu, spuštění testovací sady a kontrola kvality změn.
5. *Schvalovací brána (Governance)*: podmíněné zastavení toku grafu a vyžádání lidské kontroly před finálním sloučením pull requestu.

Zásadní předností grafového uspořádání je determinismus a striktní bezpečnost: pokud kterýkoli uzel selže (např. automatizované testy detekují regresi), exekuce se v dané větvi grafu okamžitě přeruší a navazující kroky se nespustí, což zabraňuje poškození hlavní vývojové linie.
]

== Human in the loop neboli člověk ve smyčce

Čím je systém samostatnější, tím důležitější je otázka, kde do procesu vstupuje
člověk. Úplná autonomie není cílem; cílem je autonomie v rutinních krocích
a lidské rozhodnutí tam, kde je nevratné nebo kde chybí měřítko správnosti.

=== Schvalovací body

#ai[
Schvalovací bod je místo, kde se proces zastaví a čeká na potvrzení. Jeho
umístění je kompromisem: příliš mnoho schvalování popírá smysl automatizace,
příliš málo znamená ztrátu kontroly. Osvědčeným řešením je schvalovat _záměr_
(co se má udělat) a _plán_ (jak se to má udělat) dříve, než vznikne kód.
]

=== Dohledatelnost

#ai[
Aby byla automatizovaná změna přezkoumatelná, musí být zřejmé, z jakého
požadavku vzešla. Uchování doslovného znění původního zadání je proto součástí
návrhu, nikoli formalitou: parafráze ztrácí význam, který do zadání vložil ten,
kdo je formuloval.
]

=== Hlášení selhání

#alert[Duplicita a tematické zařazení: Téma hlášení selhání se objevuje pod identickým názvem zde v teoretické části (2.4.3) i v praktické části (kapitola 3.7). V teorii navíc detekce a eskalace chyb nepatří úzce pod „Human in the loop“, ale pod obecnou spolehlivost a observabilitu distribuovaných CI/CD procesů (např. dead-letter fronty, automatické notifikace). Doporučuji strukturálně oddělit teoretické principy od praktického popisu chování v DarkFactory.]

Systém, který své vlastní selhání zamlčí, je nebezpečnější než systém, který
zjevně spadne: nespolehlivost je v něm neviditelná. U automatizovaného provozu
je proto hlášení chyb stejně důležitou vlastností jako vlastní funkce, jak
ukazuje praktická část.


