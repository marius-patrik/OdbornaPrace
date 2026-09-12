#import "../lib/odborna-prace.typ": note, issue, alert, struct-alert, critique, added, draft, unconfirmed, confirmed, removed, diff

= Závěr

#draft[
Hlavním cílem této práce bylo navrhnout, realizovat a v reálném provozu ověřit modulární systém pro autonomní vývoj softwaru, který převezme rutinní inženýrské úkony od přijetí požadavku po vytvoření strojově ověřené změny, aniž by slevil z principu lidského dohledu v rozhodujících fázích. Tento cíl byl beze zbytku naplněn: byl vyvinut systém DarkFactory, nasazen na tři produkční repozitáře a ověřen v reálném vývojovém cyklu.

Naplnění jednotlivých dílčích cílů lze ve vztahu ke stanovené metodice shrnout následovně:
+ *Současný stav a teoretická východiska (Kapitola 2)*: Práce systematicky zmapovala architekturu moderních dekodérových transformerů, mechanismus pozornosti, limity kontextového okna (včetně jevu _Context Rot_ a významu KV cache), techniky inženýrství promptů a formální strukturu autonomní ReAct smyčky alternující vnitřní rozvahu (_Thought_) a volání nástrojů (_Action_).
+ *Architektonický návrh (Kapitola 3)*: Byla navržena třívrstvá dekompozice propojující platformu GitHub, řídicí Python jádro a hermetické kontejnerové prostředí. Životní cyklus požadavku byl formalizován jako orientovaný stavový diagram s explicitními schvalovacími branami.
+ *Realizace a nasazení (Kapitola 3 a 4)*: Systém byl kompletně naprogramován a nasazen na tři repozitáře různého zaměření — vlastní repozitář systému DarkFactory, vícejazyčnou aplikaci `omnis` a projekt `ChessWithQuests`.
+ *Vyhodnocení a provozní analýza (Kapitola 4)*: Sjednocení na volané pracovní postupy vedlo k odstranění přibližně 7 800 řádků duplicitního kódu napříč sledovanými projekty. Nejcennějším zjištěním byla identifikace čtyř subtilních chyb v distribuovaném řízení (uváznutí souběžnosti, skládání názvů kontrol, tiché selhání API zápisů a pevný předpoklad o přítomnosti Pythonu), které byly v systému deterministicky vyřešeny.

V průběhu vývoje a provozního testování vykrystalizovaly klíčové technické inovace, které tvoří hlavní přínos systému DarkFactory:
- *Dvoustupňový Human Gate (oddělení záměru a plánu)*: Na rozdíl od běžných asistentů, kteří bezprostředně po zadání generují kód, DarkFactory zavádí povinné schválení *záměru* (`interpreted`) a následně technického *plánu* (`planned`) v diskusním vlákně GitHub Issues. Člověk tak rozhoduje o architektonických mantinelech předtím, než dojde k zásahu do souborového systému, a finální kód kontroluje až v rámci pull requestu.
- *Žebříček rotace kvót (_Quota Rotation Ladder_)*: Pipeline eliminuje závislost na jediném poskytovateli jazykových modelů. Při vyčerpání kapacitních limitů (HTTP 429 či `RESOURCE_EXHAUSTED`) runner nesnižuje úroveň modelu na méně schopnou variantu v témže fondu, nýbrž rotuje autorizované účty a v případě potřeby přepíná mezi odlišnými CLI harnessy (Antigravity, Claude Code, Codex, Kimi).
- *Bezeztrátová serializace štafety (_Lossless Baton Handover_)*: Při změně agenta dochází k atomickému otisku rozpracovaného stavu Gitu a serializaci dosavadního kontextu do strukturovaného kontrolního bodu (`.checkpoint.json`). Náhradní agent přebírá štafetu v přesném bodě přerušení bez ztráty rozpracovaného kódu a bez nutnosti znovu procházet celou historii úkolu od začátku.
- *Jediný zdroj pravdy (`darkfactory.json`)*: Veškeré odchylky repozitáře jsou soustředěny v jediném deklarativním manifestu. Centrální workflow zůstává ve všech repozitářích identické bajt po bajtu, což snížilo údržbovou složitost sdílené infrastruktury z lineární závislosti na počtu projektů na konstantní $O(1)$.

Ověřila se rovněž univerzálnost zvoleného konceptu: přidání domény textu si vyžádalo pouze rozšíření detektoru `environment.py` a doplnění sazebních úloh, nikoli změnu řídicího jádra. Výsledný text této práce byl vysázen a publikován týmž systémem, který pojednává.

Další rozvoj se nabízí ve dvou hlavních směrech. Prvním je rozšíření podpory o formální verifikaci a strojově dokazované teorémy (např. jazyk Lean). Druhým je hlubší integrace samoléčebných mechanizmů, kdy selhání v CI automaticky vygeneruje regresní test a pověří kódovacího agenta jeho okamžitou nápravou.
]

#critique[Nekritické sebehodnocení a absence ablačních studií: Tvrzení, že stanovený cíl byl „beze zbytku naplněn“, působí v akademickém textu nepatřičně sebevědomě. Práce postrádá jakoukoli ablační studii (_ablation study_), která by empiricky prokázala, které komponenty DarkFactory mají reálný přínos. Pomáhá skutečně dvoustupňový Human Gate kvalitě výsledného kódu, nebo pouze dramaticky prodlužuje dobu řešení úkolu? Jaká je reálná chybovost a kognitivní degradace náhradních modelů při rotaci kvót? Bez exaktního porovnání s přímočarým spuštěním jediného agenta (např. izolovaného Claude Code v CI) nelze vědecky doložit, že přidaná vrstva abstrakce a složitost metaharnessu přináší měřitelnou přidanou hodnotu.]

#note[Jako další směr rozvoje doporučuji zmínit možnost hybridního nasazení lokálních open-weights modelů (např. běžících přes Ollama / vLLM) jako bezplatného prvního stupně pipeline pro rutinní formátování a syntaktickou kontrolu před delegováním komplexních úloh na cloudová API (Claude, GPT).]
