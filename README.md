# Agentické inženýrství ve vývoji softwaru

**Návrh a implementace DarkFactory**

Gymnázium J. K. Tyla · Patrik Marius · 2026

## Prohlášení

Prohlašuji, že jsem tuto studentskou odbornou práci vypracoval samostatně pod dohledem vedoucího uvedeného na první straně. Všechny použité zdroje jsou uvedeny v seznamu zdrojů a informace z nich získané jsou v textu řádně označeny odkazem na zdroj. Souhlasím s tím, aby tištěná forma práce byla uchována na Gymnáziu J. K. Tyla a tam používána jako tištěný zdroj např. pro další studentské práce či pro prezentaci vzdělávání na GJKT.

Anotace

Práce se zabývá současným agentickým inženýrstvím ve vývoji softwaru. S rostoucími schopnostmi a adopcí generativní AI se rozšiřují možnosti agentů pro vývoj softwaru, jejich praktické využití je však stále méně rozšířené než běžné používání chatbotů. Cílem práce je popsat a systematizovat principy současného agentického inženýrství a na systému DarkFactory ukázat, co jejich propojení umožňuje v praxi.

Teoretická část vysvětluje vztah mezi jazykovým modelem, agentem a agentní vrstvou a shrnuje práci s kontextem, nástroji, trvalým stavem, specifikací, orchestrací, programovým ověřováním a lidskými rozhodovacími body. Popisuje také současnou podobu softwarové továrny, v níž jsou agenti začleněni do běžného repozitářového procesu.

Praktická část má podobu inženýrské případové studie DarkFactory, záměrně jednoduché agentické softwarové továrny nativně postavené na GitHubu. Systém byl implementován pomocí komerčních agentů. Již v této podobě dokáže agenty sám spouštět a řídit a vytváří základ pro další rozvoj stejným procesem.

Studie ukazuje, že praktický agentický proces vzniká kombinací modelového úsudku s trvalým stavem mimo model, programovou orchestrací, deterministickými kontrolami a lidskými branami. Současně odhaluje omezení počáteční implementace, zejména u modelové revize, opakování verifikace a změn schváleného rozsahu. Přínosem práce je systematizace těchto principů a ukázka jejich konkrétní realizace v jednom produkčním vývojovém procesu.

**Klíčová slova** — coding agenti; harness; softwarová továrna; orchestrace; generativní AI

Abstract

The thesis addresses contemporary agentic engineering in software development. As the capabilities and adoption of generative AI grow, the possibilities of coding agents also expand, but their practical use remains less widespread than ordinary chatbot use. The aim of the thesis is to describe and systematize the principles of contemporary agentic engineering and, using DarkFactory, show what their combination enables in practice.

The theoretical part explains the relationship between the language model, the agent, and the harness layer and summarizes work with context, tools, durable state, specification, orchestration, programmatic verification, and human decision points. It also describes the contemporary form of the software factory, in which coding agents are integrated into ordinary repository workflows.

The practical part takes the form of an engineering case study of DarkFactory, a deliberately simple agentic software factory built natively on GitHub. The system was implemented using commercial coding agents. Even in this initial form, it can already launch and manage agents itself and creates a foundation for further development using the same process.

The study shows that a practical agentic workflow arises from combining model judgment with durable state outside the model, programmatic orchestration, deterministic checks, and human gates. At the same time, it reveals limitations of the initial implementation, particularly in model-based review, repeated verification, and changes to the approved scope. The contribution of the thesis is the systematization of these principles and a demonstration of their concrete implementation in a single production development process.

**Keywords** — coding agents; harness; software factory; orchestration; generative AI

## Obsah

1.  [Prohlášení](#loc-1)
2.  [1 Úvod](#loc-2)
    
    1.  [1.1 Motivace – vývoj a adopce generativní AI](#motivace)
    2.  [1.2 Cíl, výzkumná otázka a vymezení](#intro-goal)
    3.  [1.3 Terminologie](#terminologie)
3.  [2 Teoretická část](#loc-9)
    
    1.  [2.1 Agent – co to je a jak funguje](#theory-first)
        
        1.  [2.1.1 Large Language Model (jazykový model)](#loc-13)
        2.  [2.1.2 Agentní smyčka](#loc-20)
        3.  [2.1.3 Nástroje a rozšíření](#loc-24)
        4.  [2.1.4 Kontext](#loc-34)
    2.  [2.2 Agentické inženýrství](#loc-40)
        
        1.  [2.2.1 Specifikace](#loc-52)
        2.  [2.2.2 Orchestrace](#loc-58)
    3.  [2.3 Softwarová továrna](#software-factory)
4.  [3 Praktická část](#loc-71)
    
    1.  [3.1 Metodika](#practical-first)
    2.  [3.2 Návrh systému DarkFactory](#darkfactory-design)
    3.  [3.3 Architektura systému](#darkfactory-architecture)
    4.  [3.4 Průchod požadavku systémem](#darkfactory-request-flow)
    5.  [3.5 Implementace pomocí agentů](#darkfactory-bootstrap)
5.  [4 Zjištění a diskuse](#findings-discussion)
6.  [5 Závěr](#loc-73)
7.  [Seznam zdrojů](#loc-74)
8.  [Seznam součástí textu](#loc-110)

## 1 Úvod

### 1.1 Motivace – vývoj a adopce generativní AI

Od svého vzniku se nástroje založené na jazykových modelech neustále zlepšují a roste také jejich adopce. Jednou z prvních široce používaných forem ve vývoji softwaru bylo doplňování kódu přímo v editoru ([1](#loc-75)), jehož příklad ukazuje [Obrázek 1](#fig-copilot-inline).

![](paper/components/img/vscode-copilot-inline-suggestions.png)

Obrázek 1 — Doplňování kódu v editoru ([1](#loc-75)).

Potom přišly konverzační chatboty, v nichž model sestavuje odpověď, ale nástroje mu zpravidla nebyly k dispozici, takže další práci stále prováděl uživatel. Tento způsob použití ilustruje [Obrázek 2](#fig-chatgpt-cannot-see).

![](paper/components/img/chatgpt-cannot-see-image.jpg)

Obrázek 2 — Chatbot bez přístupu k obrázku ([2](#loc-76)).

Další posun představují **_Coding Agents (coding agenti)_** ([3](#loc-77); [4](#loc-78); [5](#loc-79)), kteří mohou získat přístup k souborům, příkazům a běhovému prostředí. Model tak již nejen navrhuje výsledek, ale může prostřednictvím nástrojů sám provádět jednotlivé kroky práce.

![](paper/components/img/gradually-ai-usage-2026.svg)

Obrázek 3 — Odhad využití generativní AI podle typu ([6](#loc-80)).

Podle jednoho zveřejněného odhadu používá bezplatné AI chatboty přibližně 28 % světové populace, zatímco pravidelní uživatelé těchto agentů tvoří přibližně 0,36 % ([6](#loc-80)) [Obrázek 3](#fig-gradually-usage). Agentické nástroje jsou tedy stále výrazně méně rozšířené než běžné konverzační použití generativní AI. Motivací této práce je proto ukázat, čeho lze s těmito nástroji dosáhnout při použití současných postupů agentického inženýrství.

### 1.2 Cíl, výzkumná otázka a vymezení

Cílem práce je popsat a systematizovat principy současného agentického inženýrství ve vývoji softwaru a na systému DarkFactory ukázat, co jejich propojení umožňuje v praxi. Pozornost je přitom věnována také způsobu, jakým lze agenty začlenit přímo do běžného repozitářového pracovního postupu. Takové propojení agentů s existujícími procesy vývoje se již používá v produkčním softwarovém inženýrství a představuje současnou podobu myšlenky softwarové továrny ([7](#loc-81); [8](#loc-82)).

Výzkumná otázka práce zní — _Jaké architektonické a procesní principy se opakují v současném agentickém vývoji softwaru a jak jsou realizovány v systému DarkFactory?_

Práce vychází z předpokladu, že jazykový model je v současných agentických systémech pouze jednou částí širšího celku. Praktické použití agentů proto závisí také na způsobu práce s kontextem, nástroji a trvalým stavem, na orchestraci jednotlivých kroků, automatickém ověřování a zapojení člověka do rozhodovacích bodů. Teoretická část tyto opakující se principy popisuje a praktická část ukazuje jejich propojení v jednom konkrétním systému.

Praktická část má podobu inženýrské případové studie DarkFactory, agentické softwarové továrny nativně postavené na GitHubu. Systém byl implementován pomocí komerčních agentů a je záměrně navržen jako jednoduchá počáteční implementace. Již v této podobě dokáže sama spouštět a řídit agenty a vytváří tak základ, který lze pomocí stejného procesu dále rozvíjet. Cílem případové studie není měřit obecnou úspěšnost jazykových modelů ani porovnávat jednotlivé agenty, ale popsat konkrétní realizaci současných postupů agentického inženýrství a ukázat, co jejich spojení umožňuje v praxi.

### 1.3 Terminologie

Anglické odborné termíny jsou v práci uváděny anglicky a při vhodném českém ekvivalentu také česky v závorce. Při prvním zavedení jsou označeny hvězdičkou, tučně a kurzívou. Stručná definice se uvádí v poznámce pod čarou, aby hlavní text mohl pokračovat rovnou mechanismem nebo použitím daného pojmu.

Rozlišení slov **_Agent_** a **_Agentic_** je zachováno i v češtině. Agent označuje samotného jednajícího, zatímco agentic popisuje schopnost systému jednat ([9](#loc-83)). Proto se používá například agentní smyčka, ale agentické inženýrství.

## 2 Teoretická část

### 2.1 Agent – co to je a jak funguje

U \***_Agent_**<sup id="loc-10" role="doc-noteref"><a href="#loc-111">1</a></sup> se rozhodování a provedení dělí mezi model a \***_Harness_**<sup id="loc-11" role="doc-noteref"><a href="#loc-112">2</a></sup> ([10](#loc-84)). Model navrhuje další krok, zatímco harness jej převádí na akci a vrací výsledek zpět do dalšího kroku. Rozvrstvení shrnuje [Obrázek 4](#fig-harness-layers).

![](paper/components/img/harness-layers.svg)

Obrázek 4 — Vrstvy agentického systému.

#### 2.1.1 Large Language Model (jazykový model)

\***_Large Language Model (jazykový model)_**<sup id="loc-14" role="doc-noteref"><a href="#loc-113">3</a></sup> v agentovi vytváří další výstup podle aktuálního kontextu. Současné modely běžně používají architekturu \***_Transformer_**<sup id="loc-15" role="doc-noteref"><a href="#loc-114">4</a></sup> představenou v roce 2017 ([11](#loc-85)).

U \***_Attention (pozornost)_**<sup id="loc-17" role="doc-noteref"><a href="#loc-115">5</a></sup> je prakticky důležité, že každý token může využít informace z ostatních pozic. U standardní plné pozornosti proto rostou výpočetní náklady přibližně s druhou mocninou délky kontextu.

Model sám mezi jednotlivými voláními neudržuje pracovní stav a bez okolního systému nemá přístup k souborům, příkazům ani nástrojům. Při inferenci zpracuje aktuální kontext a vytváří výstupní tokeny. Trvalý stav, nástroje a oprávnění proto musí dodat okolní harness.

U \***_Embedding (vektorová reprezentace)_**<sup id="loc-18" role="doc-noteref"><a href="#loc-116">6</a></sup> lze sémantické vztahy ukázat geometricky. Známým příkladem je vztah mezi slovy král, královna, muž a žena ([12](#loc-86)) [Obrázek 5](#fig-embedding-queen).

![](paper/components/img/vector-embedding-queen.svg)

Obrázek 5 — Sémantické vztahy ve vektorovém prostoru ([12](#loc-86)).

#### 2.1.2 Agentní smyčka

\***_Agent Loop (agentní smyčka)_**<sup id="loc-21" role="doc-noteref"><a href="#loc-117">7</a></sup> se zpravidla řídí vzorem \***_ReAct (Reasoning and Acting)_**<sup id="loc-22" role="doc-noteref"><a href="#loc-118">8</a></sup> ([13](#loc-87)).

Jeden cyklus lze zjednodušit do pěti kroků

-   sestavit kontext — systémové pokyny, dosavadní průběh a stav prostředí
-   nechat model odpovědět
-   provést požadovaný nástroj
-   zapsat výsledek jako pozorování
-   vrátit se k dalšímu kroku

Harness provádí akci mimo model a výsledek vrací zpět do kontextu. Smyčka pokračuje, dokud model nevydá závěrečnou odpověď místo dalšího požadavku na nástroj. Průběh shrnuje [Obrázek 6](#fig-react-loop).

![](paper/components/img/react-loop.svg)

Obrázek 6 — **_ReAct_** ([13](#loc-87)).

#### 2.1.3 Nástroje a rozšíření

Zadání určuje, co má agent udělat, zatímco harness určuje, co skutečně může provést ([10](#loc-84)).

-   \***_Tools (nástroje)_**<sup id="loc-25" role="doc-noteref"><a href="#loc-119">9</a></sup> jsou přímým kanálem mezi modelem a prostředím ([14](#loc-88))
-   \***_Skills (dovednosti)_**<sup id="loc-27" role="doc-noteref"><a href="#loc-120">10</a></sup> sjednocují opakovanou práci do znovu použitelných schopností ([15](#loc-89))
-   \***_Hooks_**<sup id="loc-29" role="doc-noteref"><a href="#loc-121">11</a></sup> přesouvají vybrané kontroly z úsudku modelu do programu ([16](#loc-90))
-   \***_MCP (Model Context Protocol)_**<sup id="loc-31" role="doc-noteref"><a href="#loc-122">12</a></sup> sjednocuje způsob, jakým se tyto externí schopnosti připojují ([17](#loc-91))

Každá akce může být navíc řízena oprávněním, které ji povolí automaticky, vyžádá souhlas člověka nebo ji zakáže.

Projektové instrukce lze verzovat přímo s repozitářem. Soubor `AGENTS.md` poskytuje společné místo pro příkazy sestavení, testy a konvence ([18](#loc-92)). Standard Agent Skills používá pro každou dovednost vstupní soubor `SKILL.md` ([15](#loc-89)).

#### 2.1.4 Kontext

Do \***_Context Window (kontextové okno)_**<sup id="loc-35" role="doc-noteref"><a href="#loc-123">13</a></sup> se v agentním běhu skládají instrukce, části repozitáře, historie nástrojů i výsledky předchozích kroků. Samotná velikost okna nezaručuje správné využití všech informací. Výkon modelů může klesat například tehdy, když se důležitá informace nachází uprostřed dlouhého vstupu ([19](#loc-93)).

Riziko \***_Context Rot (degradace kontextu)_**<sup id="loc-37" role="doc-noteref"><a href="#loc-124">14</a></sup> roste s délkou a množstvím méně relevantních informací ([20](#loc-94)). \***_Compaction (kompakce)_**<sup id="loc-39" role="doc-noteref"><a href="#loc-125">15</a></sup> uvolňuje místo v kontextovém okně, ale zároveň může zahodit detail, který by byl později užitečný ([20](#loc-94)).

Dlouhodobý autoritativní stav je proto vhodné uchovávat mimo samotný přepis konverzace a do pracovního kontextu v každém kroku vybírat jen aktuální informace potřebné pro danou úlohu.

### 2.2 Agentické inženýrství

\***_Agentic Engineering (agentické inženýrství)_**<sup id="loc-41" role="doc-noteref"><a href="#loc-126">16</a></sup> přesouvá pozornost od samotného modelu k celému systému, ve kterém agent pracuje ([21](#loc-95)).

Mezi jeho hlavní oblasti patří \***_Prompt Engineering (inženýrství promptů)_**<sup id="loc-43" role="doc-noteref"><a href="#loc-127">17</a></sup> ([22](#loc-96)), \***_Context Engineering (kontextové inženýrství)_**<sup id="loc-45" role="doc-noteref"><a href="#loc-128">18</a></sup> ([20](#loc-94)), \***_Harness Engineering (inženýrství harnessu)_**<sup id="loc-46" role="doc-noteref"><a href="#loc-129">19</a></sup> ([23](#loc-97); [24](#loc-98)), \***_Loop Engineering (inženýrství smyček)_**<sup id="loc-48" role="doc-noteref"><a href="#loc-130">20</a></sup> ([25](#loc-99)) a \***_Workflow/Graph Engineering (inženýrství pracovních postupů a grafů)_**<sup id="loc-50" role="doc-noteref"><a href="#loc-131">21</a></sup> ([26](#loc-100)).

#### 2.2.1 Specifikace

\***_Spec-first Development (vývoj od specifikace)_**<sup id="loc-53" role="doc-noteref"><a href="#loc-132">22</a></sup> navazuje na starší \***_Requirements Engineering (inženýrství požadavků)_**<sup id="loc-54" role="doc-noteref"><a href="#loc-133">23</a></sup>. IEEE vydalo standard pro Software Requirements Specification už v roce 1984 ([27](#loc-101)) a současný ISO/IEC/IEEE 29148 formalizuje práci s požadavky v průběhu životního cyklu ([28](#loc-102)).

U agentů může specifikace přímo vymezit cíl a hranice implementace, zatímco konkrétní technický postup zvolí agent. Oddělení návrhu plánu od jeho provedení ukazuje [Obrázek 7](#fig-claude-code-plan).

![](paper/components/img/claude-code-plan.png)

Obrázek 7 — Plán před implementací v Claude Code ([29](#loc-103)).

#### 2.2.2 Orchestrace

\***_Orchestration (orchestrace)_**<sup id="loc-59" role="doc-noteref"><a href="#loc-134">24</a></sup> se stává důležitou tam, kde úloha přesahuje jeden agentní běh. Více agentů samo o sobě nezaručuje lepší výsledek. Přínos vzniká až tehdy, když jsou jejich úlohy vhodně rozdělené a výstupy znovu spojeny vůči společnému cíli.

-   \***_Coordinator/Subagent (koordinátor a subagent)_**<sup id="loc-60" role="doc-noteref"><a href="#loc-135">25</a></sup> umožňuje paralelizovat nezávislé části práce [Obrázek 8](#fig-antigravity-subagents)

![](paper/components/img/antigravity-cli-subagents.jpg)

Obrázek 8 — Paralelní subagenti v Google Antigravity ([30](#loc-104)).

-   \***_Workflow Graph (graf pracovního postupu)_**<sup id="loc-62" role="doc-noteref"><a href="#loc-136">26</a></sup> lze vykonávat programově mimo kontext modelu. Claude Code může u dynamických pracovních postupů vytvořit skript, který takový graf realizuje ([31](#loc-105)) [Obrázek 9](#fig-dynamic-workflows)

![](paper/components/img/claude-code-dynamic-workflows.png)

Obrázek 9 — Dynamický pracovní postup v Claude Code ([31](#loc-105)).

-   \***_Goal Loop (cílová smyčka)_**<sup id="loc-64" role="doc-noteref"><a href="#loc-137">27</a></sup> se v jednoduché podobě objevuje ve vzoru \***_Ralph Loop (Ralphova smyčka)_**<sup id="loc-65" role="doc-noteref"><a href="#loc-138">28</a></sup> popsaném Geoffreyem Huntleym ([32](#loc-106)). Podobné cílové smyčky dnes podporují Claude Code i Codex ([25](#loc-99); [33](#loc-107)) [Obrázek 10](#fig-codex-goal)

![](paper/components/img/codex-goal-complete.png)

Obrázek 10 — Cílová smyčka v Codexu ([25](#loc-99)).

-   \***_Human-in-the-loop (člověk v rozhodovací smyčce)_**<sup id="loc-68" role="doc-noteref"><a href="#loc-139">29</a></sup> se může projevit jako schválení specifikace, plánu nebo výsledné změny

### 2.3 Softwarová továrna

Pojem \***_Software Factory (softwarová továrna)_**<sup id="loc-69" role="doc-noteref"><a href="#loc-140">30</a></sup> není nový. Robert W. Bemer jej už na konferenci NATO o softwarovém inženýrství v roce 1968 popsal jako _machine-controlled production environment, or software factory_ ([34](#loc-108)). Program, jeho kontrola i používání měly probíhat uvnitř společného prostředí vybaveného nástroji pro práci se soubory, kompilaci, testování a sestavení systému.

Tradiční automatizace funguje nejlépe tam, kde lze postup předem přesně popsat programem. **_Coding Agents (coding agenti)_** tuto hranici posouvají, protože model může podle aktuálního stavu volit další kroky a používat nástroje i tehdy, když celý postup není dopředu pevně určen. Softwarová továrna tak může spojit deterministickou automatizaci, agentní kroky a lidské rozhodování.

Takové uspořádání se již používá v produkčním softwarovém inženýrství. Stripe uvádí, že jeho interní agenti Minions pravidelně vytvářejí požadavky na sloučení určené k lidské revizi ([7](#loc-81)). Meta popisuje vlastní agentní platformu, která automatizuje hledání a opravu výkonnostních problémů a dovádí proces až k požadavku na sloučení připravenému pro člověka ([8](#loc-82)).

DarkFactory představuje záměrně jednoduchý počáteční základ tohoto přístupu. První implementace už dokáže agenty spouštět a řídit v repozitářovém procesu a současně vytváří základ pro další rozvoj stejným způsobem.

## 3 Praktická část

### 3.1 Metodika

Praktická část má podobu inženýrské případové studie systému DarkFactory, konkrétní realizace širšího vzoru softwarové továrny nativně postavená na GitHubu. Cílem není měřit obecnou úspěšnost jazykových modelů ani porovnávat konkrétní agenty, ale na jednom reálném systému ukázat, jak se principy popsané v teoretické části propojují v produkčním vývojovém procesu.

Popis implementace a následná zjištění se vztahují ke konkrétní revizi DarkFactory `d576ec8f` ([35](#loc-109)). Analýza vychází ze zdrojového kódu, pracovních postupů GitHub Actions, řídicího skriptu, registru harnessů, projektových pravidel a dokumentační konfigurace této revize.

Postup případové studie navazuje na teoretickou část. Nejprve jsou vymezeny opakující se principy agentického vývoje a následně je sledováno, jak jsou realizovány v DarkFactory. Z implementace je rekonstruován celý průchod požadavku systémem a diskuse potom odděleně shrnuje zjištění a omezení konkrétní revize.

DarkFactory byla implementována pomocí komerčních **_Coding Agents (coding agenti)_**. Počáteční podoba je záměrně jednoduchá a slouží jako počáteční základ, který již dokáže stejné agenty spouštět a řídit. Praktická část proto sleduje nejen výslednou architekturu, ale také způsob, jakým se v jednom procesu doplňují agent, harness, programová orchestrace a člověk.

### 3.2 Návrh systému DarkFactory

DarkFactory byla navržena jako záměrně malá realizace principů popsaných v teoretické části. Cílem první verze nebylo pokrýt co nejvíce funkcí, ale uzavřít nejmenší prakticky použitelný vývojový cyklus. Systém přijme požadavek, předá otevřenou inženýrskou práci agentovi, zachová průběžný stav a vrátí výsledek do běžného procesu na GitHubu. Rozsah byl zvolen tak, aby bylo možné první funkční podobu vytvořit v jednom souvislém agentním běhu a další změny už provádět stejným procesem.

GitHub slouží nejen jako hosting repozitáře, ale také jako hlavní rozhraní a trvalá stavová vrstva systému. Požadavek, diskuse, schválení, větev, commity a požadavek na sloučení proto zůstávají mimo kontext modelu a přežívají jednotlivé agentní běhy. Události GitHubu spouštějí příslušné pracovní postupy GitHub Actions, takže DarkFactory pro základní průchod nepotřebuje vlastní trvale běžící server. Každý agentní krok probíhá odděleně a pracovní prostředí je izolováno kontejnerem ([35](#loc-109)).

DarkFactory neimplementuje vlastní agentní běhové prostředí. Produkční **_Harness_** zajišťuje agentní smyčku, komunikaci s modelem, nástroje a práci s kontextem. DarkFactory nad tím řídí pořadí kroků, stav procesu a lidské brány. Otevřené úlohy řeší model prostřednictvím harnessu, zatímco přesně určitelné kroky, například práce s větví, testy, formátování nebo změna stavu, zůstávají programově řízené ([35](#loc-109)).

Dokumentace tvoří rozhraní mezi automatizovaným procesem a člověkem. Ve zkoumané revizi vzniká dokumentace veřejných rozhraní přímo u zdrojového kódu a dokumentační web se generuje z kanonických souborů repozitáře. Publikovaná dokumentace tak není druhou ručně udržovanou kopií systému, ale čitelným pohledem nad stejnými zdroji, se kterými pracují agenti a automatizace ([35](#loc-109)).

Člověk nemusí řídit jednotlivé technické kroky, ale schvaluje záměr a plán před implementací a na konci rozhoduje o přijetí výsledku. Mezi těmito body proces pokračuje automaticky. První verze tak současně tvoří počáteční základ pro další vývoj DarkFactory. Jakmile základní cyklus funguje, může být stejný proces použit i pro další rozšiřování vlastního systému.

### 3.3 Architektura systému

Pipeline je tvořena GitHub Actions workflow a pythonovskými skripty, které řídí jednotlivé fáze a předávají práci produkčnímu harnessu. Architektura tak rozděluje odpovědnost mezi GitHub, GitHub Actions, izolované pracovní prostředí a harness. GitHub uchovává stav, Actions spouštějí jednotlivé fáze, Docker odděluje agentní běh a řídicí skript převádí stav procesu na konkrétní agentní krok. Samotnou agentní smyčku, model a nástroje zajišťuje zvolený harness ([35](#loc-109)). Přehled ukazuje [Obrázek 11](#fig-darkfactory-architecture).

![](paper/components/img/darkfactory-architecture.svg)

Obrázek 11 — Architektura DarkFactory ([35](#loc-109)).

GitHub uchovává uživatelský požadavek, interpretaci a diskusi. Pracovní větev a commity nesou implementaci a požadavek na sloučení slouží k automatické i lidské revizi. Stav proto není závislý na jednom kontextovém okně modelu ([35](#loc-109)).

GitHub Actions reagují na otevření požadavku, nový komentář, komentář k revizi, interní událost nebo ruční spuštění. Každý běh připraví repozitář a spustí agenta v kontejneru. DarkFactory tak používá Actions jako událostní mechanismus i krátkodobé výpočetní prostředí bez vlastní trvale běžící služby ([35](#loc-109)).

Soubor `agent_runner.py` řídí fáze interpretace, plánování, implementace, automatické revize, kontroly souladu s plánem a reakce na zpětnou vazbu. Vlastní agentní práce je oddělena pomocí registru v `harnesses.py`, který popisuje podporované harnessy, jejich příkazové rozhraní, autentizaci a záložní modely ([35](#loc-109)).

Přihlašovací údaje jsou od trvalého stavu oddělené. Operace nad GitHubem používají autorizovaný token nebo GitHub App, zatímco přihlašovací údaje poskytovatelů modelů vstupují pouze do běhu, který je potřebuje ([35](#loc-109)).

### 3.4 Průchod požadavku systémem

Průchod začíná vytvořením požadavku s uživatelským zadáním. Repozitář nabízí předlohu se šesti poli, z nichž tři jsou povinná ([35](#loc-109)). Strukturu shrnuje [Tabulka 1](#fig-issue-template).

| Pole předlohy požadavku |
| --- |
| **`Verbatim User Request`** povinné |
| **`Area / Component`** povinné |
| **`Request Type`** povinné |
| **`Parent Epic`** volitelné |
| **`Proposed Acceptance Criteria`** volitelné |
| **`Additional Context`** volitelné |

Tabulka 1 — Pole předlohy požadavku ([35](#loc-109)).

Řídicí skript předá zadání modelu k interpretaci a výsledek zapíše jako komentář. Po lidském schválení vznikne propojený plánovací požadavek `Plan`, ve kterém agent připraví implementační plán. Také plán musí člověk schválit před vznikem pracovní větve ([35](#loc-109)).

Po schválení plánu vznikne nebo se obnoví pracovní větev. Agent provede změny v izolovaném prostředí a řídicí skript následně spustí dostupné formátovací a testovací příkazy. Při neúspěchu dostane agent jeden opravný krok. Poté se změna uloží do commitu, větev se odešle a otevře se koncept požadavku na sloučení ([35](#loc-109)).

Nad požadavkem na sloučení pokračuje automatická revizní smyčka. Model hledá konkrétní problémy a nález vrací do opravného běhu. Současně se nad větví spouštějí automatické integrační kontroly. Smyčka je omezena na tři iterace. Pokud ani poslední iterace neskončí čistým verdiktem, proces pokračuje ke kontrole souladu s plánem ([35](#loc-109)).

Samostatný modelový krok následně posoudí, zda výsledná změna odpovídá schválenému plánu. Po úspěšném dokončení této kontroly může být změna předána člověku. Celý průchod shrnuje [Obrázek 12](#fig-darkfactory-pipeline).

![](paper/components/img/darkfactory-pipeline.svg)

Obrázek 12 — Průchod požadavku DarkFactory ([35](#loc-109)).

Člověk může změnu schválit nebo vrátit zpětnou vazbu. Požadavek na úpravu spustí další opravný běh na stejné větvi. Konečné schválení zpracuje samostatný pracovní postup, který po splnění podmínek provede sloučení a odstraní pracovní větev ([35](#loc-109)).

Celý proces tak střídá modelový úsudek, deterministickou automatizaci a explicitní lidská rozhodnutí.

### 3.5 Implementace pomocí agentů

DarkFactory byla sama vyvíjena pomocí komerčních **_Coding Agents (coding agenti)_**. Člověk určoval cíl a zásadní rozhodnutí, zatímco samotná implementace proběhla v jednom souvislém agentním běhu.

Běh nezačal psaním kódu, ale plánovacím režimem. Prvním cílem agenta bylo navrhnout architekturu DarkFactory a rozdělit odpovědnost mezi GitHub, automatizaci, Harness a lidské rozhodovací body. V této fázi vznikl plán systému ještě před vlastní implementací.

Po vymezení architektury dostal stejný agent roli orchestrátora. Místo toho, aby celý systém implementoval sekvenčně sám, rozděloval dílčí práci mezi subagenty, přebíral jejich výsledky a skládal je zpět vůči společnému cíli. Praktická implementace tak přímo použila princip koordinátora a subagentů popsaný v teoretické části.

Počáteční rozsah byl záměrně omezen na nejmenší uzavřený proces, který dokáže přijmout požadavek, předat práci agentovi a vrátit výsledek do řízeného procesu na GitHubu. Smyslem bylo co nejrychleji dosáhnout funkčního základu, který už může podporovat vlastní další vývoj.

Před vznikem této základní verze musel člověk agenta spouštět a řídit přímo. Po dokončení základního cyklu už DarkFactory dokáže stejné nástroje spouštět sama nad vlastním repozitářem ([35](#loc-109)). Další funkce tak mohou vznikat postupně prostřednictvím stejného procesu.

## 4 Zjištění a diskuse

Výzkumná otázka se ptá, jaké principy se opakují v současném agentickém vývoji softwaru a jak je realizuje DarkFactory. Z analyzovaných zdrojů vystupuje společný vzor. Model pracuje uvnitř harnessu a širšího procesu, trvalý stav zůstává mimo jeho kontext, otevřený úsudek se odděluje od programově proveditelných kontrol a důležitá rozhodnutí zůstávají člověku ([10](#loc-84); [20](#loc-94); [26](#loc-100)).

DarkFactory tento vzor realizuje pomocí běžného repozitářového procesu. GitHub uchovává stav práce, automatizace řídí pořadí kroků a agent řeší úlohy, které nelze předem přesně naprogramovat ([35](#loc-109)). Výsledek se vrací do větve a požadavku na sloučení, takže agentní práce zůstává čitelná a kontrolovatelná stejnými nástroji jako práce člověka. Podobnou hranici mezi autonomní prací a lidskou revizí popisují také Stripe a Meta ([7](#loc-81); [8](#loc-82)).

Prakticky důležitá je i dokumentace generovaná z kanonických zdrojů. Agent pracuje s verzovanými pravidly a kódem, zatímco člověk dostává čitelný pohled nad stejným systémem. Dokumentace tak propojuje automatizovanou implementaci s lidskou kontrolou ([35](#loc-109)).

Počáteční implementace má současně konkrétní omezení. Modelová revize není deterministickým důkazem správnosti, omezená revizní smyčka může skončit bez čistého verdiktu, verifikace se po jednom opravném kroku znovu neopakuje a změna rozsahu může pokračovat bez obnoveného schválení původního plánu ([35](#loc-109)). Zjištění proto nelze zobecnit na všechny modely nebo repozitáře.

Případ DarkFactory ukazuje především to, že praktický agentický vývoj nevzniká samotným modelem. Vzniká až spojením specifikace, kontextu, nástrojů, trvalého stavu, orchestrace, kontrol a lidského rozhodování. Záměrně malá první verze navíc ukazuje, že takový proces lze použít jako počáteční základ pro další rozvoj stejného systému.

## 5 Závěr

Cílem práce bylo popsat a systematizovat principy současného agentického inženýrství a na systému DarkFactory ukázat jejich praktické propojení. Tento cíl byl naplněn propojením teoretického rozboru s případovou studií konkrétní implementace.

Hlavním závěrem je, že schopnost modelu sama nestačí. Praktický agentický vývoj závisí také na kvalitě specifikace, kontextu, nástrojů, trvalého stavu, orchestrace, programových kontrol a lidských rozhodovacích bodů. DarkFactory ukazuje jednu konkrétní podobu tohoto spojení a zároveň to, že malá počáteční implementace může sloužit jako základ pro další rozvoj pomocí stejného procesu.

Výsledek je omezen na jeden systém a jednu jeho revizi. Další práce by proto měla zpřesnit deterministické brány, znovu vyžadovat schválení při změně rozsahu a ověřit stejné principy na dalších repozitářích a s dalšími harnessy.

Agentické inženýrství tak přesouvá část práce vývojáře od ručního provádění jednotlivých kroků k návrhu prostředí, ve kterém agent ví, co má udělat, co smí udělat, jak se jeho výstup ověří a kdy musí rozhodnout člověk.

## Seznam zdrojů

-   [1.](#loc-3) GITHUB. _GitHub Copilot code suggestions in your IDE_ \[online\]. 2026 \[vid. 2026-09-22\]. Dostupné z: [https://docs.github.com/en/copilot/concepts/completions/code-suggestions](https://docs.github.com/en/copilot/concepts/completions/code-suggestions)
-   [2.](#loc-4) KHURANA, Sonam a Anusha VADDI. ChatGPT From the Perspective of an Academic Oral and Maxillofacial Radiologist. _Cureus_ \[online\]. 2023, **15**(6). Dostupné z: doi:[10.7759/cureus.40053](https://doi.org/10.7759/cureus.40053). Obrázek 4. Screenshot z bezplatné verze ChatGPT, převzato jako ilustrace
-   [3.](#loc-5) GITHUB. _Use GitHub Copilot agents_ \[online\]. 2026 \[vid. 2026-09-22\]. Dostupné z: [https://docs.github.com/en/copilot/how-tos/use-copilot-agents](https://docs.github.com/en/copilot/how-tos/use-copilot-agents)
-   [4.](#loc-5) OPENAI. _Introducing Codex_ \[online\]. 2025 \[vid. 2026-09-22\]. Dostupné z: [https://openai.com/index/introducing-codex/](https://openai.com/index/introducing-codex/)
-   [5.](#loc-5) OPENAI. _Introducing the Codex app_ \[online\]. 2026 \[vid. 2026-09-22\]. Dostupné z: [https://openai.com/index/introducing-the-codex-app/](https://openai.com/index/introducing-the-codex-app/)
-   [6.](#loc-6) HILLEBRANDT, Finn. _How Many People Use AI? Facts & Figures 2026_ \[online\]. 2026 \[vid. 2026-09-22\]. Dostupné z: [https://www.gradually.ai/en/how-many-people-use-ai/](https://www.gradually.ai/en/how-many-people-use-ai/). Published 2026-08-23
-   [7.](#loc-7) STRIPE. _Developer keynote: Advancing developer craft_ \[online\]. 2026 \[vid. 2026-09-30\]. Dostupné z: [https://stripe.com/sessions/2026/developer-keynote](https://stripe.com/sessions/2026/developer-keynote). Stripe Sessions 2026
-   [8.](#loc-7) META. _Capacity Efficiency at Meta: How Unified AI Agents Optimize Performance at Hyperscale_ \[online\]. 2026 \[vid. 2026-09-30\]. Dostupné z: [https://engineering.fb.com/2026/04/16/developer-tools/capacity-efficiency-at-meta-how-unified-ai-agents-optimize-performance-at-hyperscale/](https://engineering.fb.com/2026/04/16/developer-tools/capacity-efficiency-at-meta-how-unified-ai-agents-optimize-performance-at-hyperscale/)
-   [9.](#loc-8) MERRIAM-WEBSTER. _Agentic: Definition & Meaning_ \[online\]. 2026 \[vid. 2026-09-26\]. Dostupné z: [https://www.merriam-webster.com/dictionary/agentic](https://www.merriam-webster.com/dictionary/agentic). Původ slova: agent + -ic, poprvé doloženo 1966
-   [10.](#loc-12) TRIVEDY, Vivek. _The Anatomy of an Agent Harness_ \[online\]. 2026 \[vid. 2026-09-27\]. Dostupné z: [https://www.langchain.com/blog/the-anatomy-of-an-agent-harness](https://www.langchain.com/blog/the-anatomy-of-an-agent-harness). LangChain, 10. března 2026
-   [11.](#loc-16) VASWANI, Ashish, Noam SHAZEER, Niki PARMAR, Jakob USZKOREIT, Llion JONES, Aidan N. GOMEZ, Łukasz KAISER a Illia POLOSUKHIN. Attention Is All You Need. _arXiv preprint arXiv:1706.03762_ \[online\]. 2017. Dostupné z: [https://arxiv.org/abs/1706.03762](https://arxiv.org/abs/1706.03762)
-   [12.](#loc-19) MIKOLOV, Tomas, Wen-tau YIH a Geoffrey ZWEIG. Linguistic Regularities in Continuous Space Word Representations. In: _Proceedings of the 2013 Conference of the North American Chapter of the Association for Computational Linguistics: Human Language Technologies_ \[online\]. 2013, s. 746–751. Dostupné z: [https://aclanthology.org/N13-1090/](https://aclanthology.org/N13-1090/)
-   [13.](#loc-23) YAO, Shunyu, Jeffrey ZHAO, Dian YU, Nan DU, Izhak SHAFRAN, Karthik NARASIMHAN a Yuan CAO. ReAct: Synergizing Reasoning and Acting in Language Models. _arXiv preprint arXiv:2210.03629_ \[online\]. 2022. Dostupné z: [https://arxiv.org/abs/2210.03629](https://arxiv.org/abs/2210.03629)
-   [14.](#loc-26) ANTHROPIC. _Building effective agents_ \[online\]. 2024 \[vid. 2026-09-23\]. Dostupné z: [https://www.anthropic.com/engineering/building-effective-agents](https://www.anthropic.com/engineering/building-effective-agents)
-   [15.](#loc-28) AGENT SKILLS. _Agent Skills: an open format for extending AI agents_ \[online\]. 2025 \[vid. 2026-09-22\]. Dostupné z: [https://agentskills.io/home](https://agentskills.io/home)
-   [16.](#loc-30) OPENAI. _Lifecycle | OpenAI Agents SDK_ \[online\]. 2026 \[vid. 2026-09-22\]. Dostupné z: [https://openai.github.io/openai-agents-python/ref/lifecycle/](https://openai.github.io/openai-agents-python/ref/lifecycle/)
-   [17.](#loc-32) MODEL CONTEXT PROTOCOL. _Model Context Protocol 2026-07-28 specification: server features_ \[online\]. 2026 \[vid. 2026-09-22\]. Dostupné z: [https://modelcontextprotocol.io/specification/2026-07-28/server](https://modelcontextprotocol.io/specification/2026-07-28/server)
-   [18.](#loc-33) AGENTIC AI FOUNDATION. _AGENTS.md_ \[online\]. 2026 \[vid. 2026-09-23\]. Dostupné z: [https://agents.md/](https://agents.md/)
-   [19.](#loc-36) LIU, Nelson F., Kevin LIN, John HEWITT, Ashwin PARANJAPE, Michele BEVILACQUA, Fabio PETRONI a Percy LIANG. Lost in the Middle: How Language Models Use Long Contexts. _Transactions of the Association for Computational Linguistics_ \[online\]. 2024, **12**, 157–173. Dostupné z: [https://arxiv.org/abs/2307.03172](https://arxiv.org/abs/2307.03172)
-   [20.](#loc-38) ANTHROPIC. _Effective context engineering for AI agents_ \[online\]. 2025 \[vid. 2026-09-22\]. Dostupné z: [https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
-   [21.](#loc-42) ALENEZI, Mamdouh. Educating the Agentic Engineer: Curricula, Collaboration, and Continuous Learning in the AI Era. _arXiv preprint arXiv:2607.29610_ \[online\]. 2026 \[vid. 2026-09-26\]. Dostupné z: [https://arxiv.org/abs/2607.29610](https://arxiv.org/abs/2607.29610)
-   [22.](#loc-44) OPENAI. _Prompt engineering_ \[online\]. 2026 \[vid. 2026-09-22\]. Dostupné z: [https://platform.openai.com/docs/guides/prompt-engineering](https://platform.openai.com/docs/guides/prompt-engineering)
-   [23.](#loc-47) ANTHROPIC. _Harness design for long-running application development_ \[online\]. 2026 \[vid. 2026-09-21\]. Dostupné z: [https://www.anthropic.com/engineering/harness-design-long-running-apps](https://www.anthropic.com/engineering/harness-design-long-running-apps)
-   [24.](#loc-47) OPENAI. _Sandbox agents: Concepts | OpenAI Agents SDK_ \[online\]. 2026 \[vid. 2026-09-22\]. Dostupné z: [https://openai.github.io/openai-agents-js/guides/sandbox-agents/concepts/](https://openai.github.io/openai-agents-js/guides/sandbox-agents/concepts/)
-   [25.](#loc-49) OPENAI. _Using Goals in Codex: Persistent Objectives for Long-Running Work_ \[online\]. 2026 \[vid. 2026-09-27\]. Dostupné z: [https://developers.openai.com/cookbook/examples/codex/using\_goals\_in\_codex](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
-   [26.](#loc-51) OPENAI. _Agent orchestration | OpenAI Agents SDK_ \[online\]. 2026 \[vid. 2026-09-21\]. Dostupné z: [https://openai.github.io/openai-agents-python/multi\_agent/](https://openai.github.io/openai-agents-python/multi_agent/)
-   [27.](#loc-55) IEEE. _IEEE Guide for Software Requirements Specifications_ \[online\]. 1984 \[vid. 2026-09-30\]. Dostupné z: [https://standards.ieee.org/ieee/830/1220/](https://standards.ieee.org/ieee/830/1220/). IEEE 830-1984
-   [28.](#loc-56) ISO/IEC/IEEE. _ISO/IEC/IEEE 29148:2018 — Systems and software engineering — Life cycle processes — Requirements engineering_ \[online\]. 2018 \[vid. 2026-09-30\]. Dostupné z: [https://www.iso.org/standard/72089.html](https://www.iso.org/standard/72089.html)
-   [29.](#loc-57) GALLARDO, Luis. _Beyond Cursor: My Experience with Claude Code and Sequential Thinking_ \[online\]. 2025 \[vid. 2026-09-28\]. Dostupné z: [https://lgallardo.com/2025/07/09/beyond-cursor-claude-code-sequential-thinking/](https://lgallardo.com/2025/07/09/beyond-cursor-claude-code-sequential-thinking/). Obrázek s plánem, který Claude Code předkládá ke schválení. Převzatá ilustrace rozhraní, nikoli záznam běhu popsané pipeline
-   [30.](#loc-61) GOOGLE. _Antigravity CLI_ \[online\]. 2026 \[vid. 2026-09-27\]. Dostupné z: [https://antigravity.google/product/antigravity-cli](https://antigravity.google/product/antigravity-cli). Sekce Subagents functionalities. Převzatá ilustrace rozhraní, nikoli záznam běhu
-   [31.](#loc-63) ANTHROPIC. _Orchestrate subagents at scale with dynamic workflows_ \[online\]. 2026 \[vid. 2026-09-27\]. Dostupné z: [https://code.claude.com/docs/en/workflows](https://code.claude.com/docs/en/workflows). Sekce Dynamic workflows. Převzatá ilustrace rozhraní, nikoli záznam běhu
-   [32.](#loc-66) HUNTLEY, Geoffrey. _Ralph Wiggum as a „software engineer“_ \[online\]. 2025 \[vid. 2026-09-27\]. Dostupné z: [https://ghuntley.com/ralph/](https://ghuntley.com/ralph/). 14. července 2025. Původní text, který techniku pojmenoval
-   [33.](#loc-67) ANTHROPIC. _Keep Claude working toward a goal_ \[online\]. 2026 \[vid. 2026-09-27\]. Dostupné z: [https://code.claude.com/docs/en/goal](https://code.claude.com/docs/en/goal)
-   [34.](#loc-70) NATO. _Software Engineering: Report of a Conference Sponsored by the NATO Science Committee, Garmisch, Germany, 7–11 October 1968_ \[online\]. Brussels: NATO, Scientific Affairs Division, 1969 \[vid. 2026-09-27\]. Dostupné z: [http://homepages.cs.ncl.ac.uk/brian.randell/NATO/nato1968.PDF](http://homepages.cs.ncl.ac.uk/brian.randell/NATO/nato1968.PDF). 231 s. Zpráva o softwarové krizi; stažitelný přepis z roku 2001 má 136 stran, číslování citací se vztahuje k původnímu vydání
-   [35.](#loc-72) MARIUS, Patrik. _DarkFactory revize d576ec8f_ \[online\]. 2026 \[vid. 2026-09-26\]. Dostupné z: [https://github.com/marius-patrik/DarkFactory/tree/d576ec8fdb78a654bfffc9d0da165aa81a97b673](https://github.com/marius-patrik/DarkFactory/tree/d576ec8fdb78a654bfffc9d0da165aa81a97b673). Poslední revize, v níž ještě pipeline volá produkční harnessy

## Seznam součástí textu

1.  [Obrázek 1 — Doplňování kódu v editoru (](#fig-copilot-inline)[1](#loc-75)).
2.  [Obrázek 2 — Chatbot bez přístupu k obrázku (](#fig-chatgpt-cannot-see)[2](#loc-76)).
3.  [Obrázek 3 — Odhad využití generativní AI podle typu (](#fig-gradually-usage)[6](#loc-80)).
4.  [Obrázek 4 — Vrstvy agentického systému.](#fig-harness-layers)
5.  [Obrázek 5 — Sémantické vztahy ve vektorovém prostoru (](#fig-embedding-queen)[12](#loc-86)).
6.  [Obrázek 6 — **_ReAct_** (](#fig-react-loop)[13](#loc-87)).
7.  [Obrázek 7 — Plán před implementací v Claude Code (](#fig-claude-code-plan)[29](#loc-103)).
8.  [Obrázek 8 — Paralelní subagenti v Google Antigravity (](#fig-antigravity-subagents)[30](#loc-104)).
9.  [Obrázek 9 — Dynamický pracovní postup v Claude Code (](#fig-dynamic-workflows)[31](#loc-105)).
10.  [Obrázek 10 — Cílová smyčka v Codexu (](#fig-codex-goal)[25](#loc-99)).
11.  [Obrázek 11 — Architektura DarkFactory (](#fig-darkfactory-architecture)[35](#loc-109)).
12.  [Tabulka 1 — Pole předlohy požadavku (](#fig-issue-template)[35](#loc-109)).
13.  [Obrázek 12 — Průchod požadavku DarkFactory (](#fig-darkfactory-pipeline)[35](#loc-109)).

1.  <sup role="doc-backlink"><a href="#loc-10">1</a></sup>**_Agent_** — Systém, v němž model prostřednictvím nástrojů jedná nad prostředím.
2.  <sup role="doc-backlink"><a href="#loc-11">2</a></sup>**_Harness_** — Vrstva kolem modelu, která mu předává kontext, nástroje, oprávnění, stav a pravidla běhu.
3.  <sup role="doc-backlink"><a href="#loc-14">3</a></sup>**_Large Language Model_** — Model, který z kontextu odhaduje pravděpodobnosti následujících tokenů.
4.  <sup role="doc-backlink"><a href="#loc-15">4</a></sup>**_Transformer_** — Neuronová architektura založená na mechanismu pozornosti, která zpracovává vztahy mezi tokeny v kontextu.
5.  <sup role="doc-backlink"><a href="#loc-17">5</a></sup>**_Attention_** — Mechanismus, který při výpočtu reprezentace tokenu váží informace z dalších tokenů v kontextu.
6.  <sup role="doc-backlink"><a href="#loc-18">6</a></sup>**_Embedding_** — Číselný vektor, který zachycuje vlastnosti nebo význam objektu tak, aby podobné objekty ležely v prostoru blízko sebe.
7.  <sup role="doc-backlink"><a href="#loc-21">7</a></sup>**_Agent Loop_** — Opakovaný cyklus, v němž model vyhodnotí stav, zvolí další akci, obdrží její výsledek a pokračuje.
8.  <sup role="doc-backlink"><a href="#loc-22">8</a></sup>**_ReAct_** — Vzor střídající uvažování modelu, akci nad prostředím a pozorování výsledku.
9.  <sup role="doc-backlink"><a href="#loc-25">9</a></sup>**_Tools_** — Funkce zpřístupněné modelu pro práci s prostředím, například čtení souborů, vyhledávání nebo spouštění příkazů.
10.  <sup role="doc-backlink"><a href="#loc-27">10</a></sup>**_Skills_** — Opakovaně použitelné balíčky instrukcí, skriptů a zdrojů pro určitý typ úlohy.
11.  <sup role="doc-backlink"><a href="#loc-29">11</a></sup>**_Hooks_** — Programové reakce na události životního cyklu, které mohou před akcí nebo po ní vynutit další krok.
12.  <sup role="doc-backlink"><a href="#loc-31">12</a></sup>**_MCP (Model Context Protocol)_** — Standard klient–server pro připojování externích nástrojů a datových zdrojů k agentním systémům.
13.  <sup role="doc-backlink"><a href="#loc-35">13</a></sup>**_Context Window_** — Množství vstupních a průběžných informací, které může model zpracovat v jednom běhu.
14.  <sup role="doc-backlink"><a href="#loc-37">14</a></sup>**_Context Rot_** — Zhoršování schopnosti modelu využít relevantní informace s rostoucím nebo nekvalitním kontextem.
15.  <sup role="doc-backlink"><a href="#loc-39">15</a></sup>**_Compaction_** — Nahrazení starší části průběhu kratším souhrnem důležitých rozhodnutí, výsledků a otevřených úkolů.
16.  <sup role="doc-backlink"><a href="#loc-41">16</a></sup>**_Agentic Engineering_** — Návrh a řízení softwarového vývoje tak, aby agenti pracovali uvnitř explicitně navrženého systému pravidel, kontextu, nástrojů, kontrol a lidských rozhodnutí.
17.  <sup role="doc-backlink"><a href="#loc-43">17</a></sup>**_Prompt Engineering_** — Formulace instrukcí, omezení, příkladů a očekávaného výstupu konkrétního modelového kroku.
18.  <sup role="doc-backlink"><a href="#loc-45">18</a></sup>**_Context Engineering_** — Výběr, uspořádání, obnova a kompakce informací dostupných modelu v daném kroku.
19.  <sup role="doc-backlink"><a href="#loc-46">19</a></sup>**_Harness Engineering_** — Návrh okolní vrstvy, která modelu poskytuje nástroje, stav, oprávnění a pravidla běhu.
20.  <sup role="doc-backlink"><a href="#loc-48">20</a></sup>**_Loop Engineering_** — Návrh řídicích smyček, které opakovaně porovnávají stav s cílem a rozhodují o dalším kroku.
21.  <sup role="doc-backlink"><a href="#loc-50">21</a></sup>**_Workflow/Graph Engineering_** — Disciplína zaměřená na návrh pořadí, závislostí a větvení mezi více kroky nebo agenty.
22.  <sup role="doc-backlink"><a href="#loc-53">22</a></sup>**_Spec-first Development_** — Postup, v němž je požadovaný výsledek a jeho omezení popsán před samotnou implementací.
23.  <sup role="doc-backlink"><a href="#loc-54">23</a></sup>**_Requirements Engineering_** — Systematická práce se zjišťováním, popisem a správou požadavků na software.
24.  <sup role="doc-backlink"><a href="#loc-59">24</a></sup>**_Orchestration_** — Řízení pořadí, závislostí, sdíleného stavu a integračních kontrol mezi více kroky nebo agenty.
25.  <sup role="doc-backlink"><a href="#loc-60">25</a></sup>**_Coordinator/Subagent_** — Vzor, v němž koordinátor deleguje dílčí úlohy samostatným agentům s vlastním kontextem.
26.  <sup role="doc-backlink"><a href="#loc-62">26</a></sup>**_Workflow Graph_** — Graf, který předem určuje závislosti, pořadí a větvení kroků.
27.  <sup role="doc-backlink"><a href="#loc-64">27</a></sup>**_Goal Loop_** — Nadřazená smyčka, která po dílčím běhu porovná stav s cílem a rozhodne, zda práce skončí nebo pokračuje.
28.  <sup role="doc-backlink"><a href="#loc-65">28</a></sup>**_Ralph Loop_** — Jednoduchý vzor opakovaného spouštění coding agenta, který drží stav v pracovním stromu místo v přepisu konverzace.
29.  <sup role="doc-backlink"><a href="#loc-68">29</a></sup>**_Human-in-the-loop_** — Zapojení explicitního lidského rozhodnutí do jinak automatizovaného procesu.
30.  <sup role="doc-backlink"><a href="#loc-69">30</a></sup>**_Software Factory_** — Vývojové prostředí, které převádí tvorbu softwaru do co nejvíce řízeného, opakovatelného a nástroji podporovaného procesu.
