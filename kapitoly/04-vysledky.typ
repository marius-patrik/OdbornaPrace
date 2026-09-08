= Výsledky a diskuse

== Nasazení

Systém byl nasazen na tři repozitáře. Sdílení jednoho pracovního postupu místo
kopií vedlo k odstranění přibližně 7 800 řádků duplicitního kódu.

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

== Chyby, které se projevily až v provozu

Nasazení odhalilo několik chyb, které se při návrhu neprojevily:

/ Uváznutí souběžnosti: Volající i volaný pracovní postup použily stejný název
  skupiny souběžnosti, takže volaný čekal na skupinu drženou vlastním volajícím.
  Běh skončil bez jediné úlohy a bez chybového hlášení.

/ Přejmenování kontrol: Volaný pracovní postup hlásí výsledek pod složeným názvem.
  Ochrana větve vyžadující původní název by zablokovala každé sloučení.

/ Tiché selhání zápisu na nástěnku: Zápisy na projektovou nástěnku byly obaleny
  zachycením všech výjimek, takže selhání skončilo hlášením o úspěchu. Chyba
  vyšla najevo až ručním porovnáním obsahu nástěnky.

== Diskuse

Poslední z uvedených chyb je pro celou práci nejpoučnější. Systém, který své
vlastní selhání zamlčí, je nebezpečnější než systém, který spadne: nespolehlivost
je v něm neviditelná. Z toho plyne obecnější závěr — u automatizovaného provozu je
hlášení chyb stejně důležitou vlastností jako samotná funkce.

== Omezení

Systém předpokládá, že úkol lze ověřit strojově. Tam, kde správnost posoudí až
člověk, zůstává přínos automatizace omezený.
