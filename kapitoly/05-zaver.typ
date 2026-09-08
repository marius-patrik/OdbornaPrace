= Závěr

Cílem práce bylo navrhnout, realizovat a ověřit systém automatizující vývojový
proces od přijetí požadavku po vytvoření ověřené změny, aniž by se vzdal lidského
schválení v rozhodujících bodech. Cíl byl naplněn: systém DarkFactory byl
realizován a nasazen na tři repozitáře, kde odstranil přibližně 7 800 řádků
duplicitního kódu a převzal rutinní kroky vývojového procesu.

Dílčí cíle byly splněny takto. Současný stav automatizace a orchestrace
jazykových modelů je popsán v kapitole 2. Architektura systému, jeho životní
cyklus a způsob rozpoznávání prostředí jsou popsány v kapitole 3. Nasazení
proběhlo na tři repozitáře a jeho výsledky jsou vyhodnoceny v kapitole 4.

Ukázalo se, že hlavní obtíž nespočívá v generování změn, ale v jejich řízení —
v tom, kde do procesu vstupuje člověk a jak systém hlásí vlastní selhání. Všechny
chyby nalezené při nasazení se týkaly této oblasti, nikoli schopnosti změnu
vytvořit. Nejzávažnější z nich, tiché selhání zápisu na projektovou nástěnku,
byla neviditelná právě proto, že systém hlásil úspěch.

Práce rovněž ověřila, že zvolená abstrakce je dostatečně obecná: rozšíření
systému o doménu textu si vyžádalo doplnění tabulek a dvou úloh, nikoli zásah do
vlastní logiky. Tato práce je toho dokladem — je sázena týmž systémem, který
popisuje.

Další rozvoj se nabízí ve dvou směrech. Prvním je rozšíření o další domény,
například o strojově ověřované matematické důkazy, pro něž je systém již
připraven. Druhým je zpřesnění hlášení chyb tak, aby každé selhání zanechalo
trvalý a viditelný záznam — v této práci byl učiněn první krok, kdy selhání
zakládá úkol, který se po nápravě sám uzavře.
