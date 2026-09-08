// TODO: Tento text je koncept vygenerovaný jako osnova. Před odevzdáním jej přepište
// vlastními slovy — odevzdání cizího textu je plagiát (Průvodce, kap. 5.3).

= Teoretická část

Tato kapitola vymezuje pojmy, o které se opírá praktická část: řízení verzí,
kontinuální integraci, orchestraci jazykových modelů a řízení automatizovaných
změn. Cílem není vyčerpávající přehled, nýbrž zavedení pojmů v podobě, v jaké
s nimi pracuje navržený systém.

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

Velké jazykové modely (angl. _large language models_) jsou statistické modely
jazyka, které lze použít i ke generování a úpravě zdrojového kódu. Pro praktické
nasazení je však podstatnější než samotná schopnost generovat text to, jak je
model zasazen do procesu.

=== Kontext a nástroje

Model sám o sobě nevidí repozitář. Aby mohl provést změnu, potřebuje kontext
(popis úkolu, obsah souborů) a nástroje (čtení souborů, spouštění příkazů).
Kvalita výsledku závisí na obojím přinejmenším stejně jako na modelu samotném.

=== Ověřitelnost výstupu

Zásadní je, zda lze výsledek strojově ověřit. Tam, kde existují testy
a statická kontrola, může systém sám rozpoznat, že se změna nepovedla, a pokusit
se o nápravu. Tam, kde správnost posoudí až člověk, zůstává přínos automatizace
omezený — a tato hranice je pro celý přístup určující.

=== Problém jediného poskytovatele

Spoléhá-li systém na jediného poskytovatele modelu, zastaví se ve chvíli, kdy
tento poskytovatel vyčerpá přidělenou kvótu, změní rozhraní nebo je nedostupný.
Řešením je vrstva, která umí tentýž úkol předat kterémukoli z několika
poskytovatelů. Rozhraní se u jednotlivých poskytovatelů liší, takže tato vrstva
musí úkol popsat způsobem nezávislým na konkrétním rozhraní.

== Governance automatizovaných změn

Čím je systém samostatnější, tím důležitější je otázka, kde do procesu vstupuje
člověk. Úplná autonomie není cílem; cílem je autonomie v rutinních krocích
a lidské rozhodnutí tam, kde je nevratné nebo kde chybí měřítko správnosti.

=== Schvalovací body

Schvalovací bod je místo, kde se proces zastaví a čeká na potvrzení. Jeho
umístění je kompromisem: příliš mnoho schvalování popírá smysl automatizace,
příliš málo znamená ztrátu kontroly. Osvědčeným řešením je schvalovat _záměr_
(co se má udělat) a _plán_ (jak se to má udělat) dříve, než vznikne kód.

=== Dohledatelnost

Aby byla automatizovaná změna přezkoumatelná, musí být zřejmé, z jakého
požadavku vzešla. Uchování doslovného znění původního zadání je proto součástí
návrhu, nikoli formalitou: parafráze ztrácí význam, který do zadání vložil ten,
kdo je formuloval.

=== Hlášení selhání

Systém, který své vlastní selhání zamlčí, je nebezpečnější než systém, který
zjevně spadne: nespolehlivost je v něm neviditelná. U automatizovaného provozu
je proto hlášení chyb stejně důležitou vlastností jako vlastní funkce, jak
ukazují i výsledky uvedené v kapitole 4.
