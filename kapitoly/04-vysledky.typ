= Výsledky a diskuse

== Metodika ověření

Systém byl nasazen na tři repozitáře různé povahy: na vlastní repozitář systému,
na aplikaci psanou v několika jazycích a na menší projekt. Sledovány byly tři
veličiny: počet vlastních skriptů a pracovních postupů v jednotlivých
repozitářích, počet řádků odstraněného duplicitního kódu a chování systému
v provozu.

== Sjednocení pracovních postupů

Sdílení jednoho pracovního postupu místo kopií vedlo k odstranění přibližně
7 800 řádků duplicitního kódu.

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left, center, center),
    table.header([*Repozitář*], [*Skripty před*], [*Skripty po*]),
    [DarkFactory],      [12], [12],
    [omnis],            [7],  [1],
    [ChessWithQuests],  [5],  [1],
  ),
  caption: [Počet vlastních skriptů před sjednocením a po něm.],
) <tab-vysledky>

Údaje v @tab-vysledky je třeba číst se dvěma výhradami. U repozitáře DarkFactory
se počet nezměnil, protože právě on skripty vlastní. Zbylý jeden skript
v ostatních repozitářích popisuje strukturu jejich vlastní dokumentace, a proto
sdílet nelze.

== Rozšíření na texty

Po sjednocení byl systém rozšířen tak, aby popsal i repozitář obsahující text
místo programu. Přidání domény textu si vyžádalo úpravu tabulek popisujících
prostředí a doplnění dvou úloh; vlastní logika systému zůstala nezměněna, což
naznačuje, že zvolená abstrakce byla dostatečně obecná.

Ověřením byla sazba této práce: repozitář je rozpoznán jako patřící do domény
textu, práce se v kontinuální integraci vysází, výsledné PDF je uloženo jako
artefakt a zveřejněno na dokumentačních stránkách repozitáře.

== Chyby, které se projevily až v provozu

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

== Diskuse

Nejpoučnější z uvedených chyb je tiché selhání zápisu na nástěnku. Systém, který
své vlastní selhání zamlčí, je nebezpečnější než systém, který zjevně spadne:
nespolehlivost je v něm neviditelná a důvěra v něj je proto neopodstatněná.
Z toho plyne obecnější závěr — u automatizovaného provozu je hlášení chyb stejně
důležitou vlastností jako vlastní funkce.

Druhým opakujícím se motivem je předpoklad o podobě repozitáře. Chyba
s předpokladem o jazyce má stejnou příčinu jako potřeba zavést domény: sdílený
systém musí popisovat, co v repozitáři skutečně je, a nikoli předpokládat, že se
podobá tomu, pro který byl původně napsán.

== Omezení

Systém předpokládá, že úkol lze ověřit strojově. Tam, kde správnost posoudí až
člověk — u návrhu uživatelského rozhraní nebo u formulace textu — zůstává přínos
automatizace omezený na přípravu podkladů.

Druhým omezením je závislost na dostupnosti poskytovatelů jazykových modelů.
Postupné předávání úkolu mezi poskytovateli riziko snižuje, neodstraňuje je však
úplně: vyčerpají-li kvótu všichni, proces se zastaví stejně jako dříve.

Třetím omezením je rozsah ověření. Systém byl nasazen na tři repozitáře jediného
autora, takže zjištění nelze bez dalšího zobecnit na větší tým, kde by přibyly
otázky souběžné práce více lidí nad týmž kódem.
