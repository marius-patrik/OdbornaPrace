= Úvod

Vývoj softwaru se za posledních dvacet let z velké části zautomatizoval. Sestavení
programu, spuštění testů i nasazení do provozu dnes obstarávají stroje. Jeden krok
však zůstal ruční: samotná změna zdrojového kódu. Právě tam se tvoří většina
prodlev — mezi tím, kdy někdo popíše požadavek, a tím, kdy se změna dostane
k uživatelům.

Výrobní průmysl zná pojem _dark factory_, tedy „temná továrna“: provoz, který
běží bez lidské obsluhy, a proto v něm nemusí svítit. Tato práce zkoumá, nakolik
lze stejný princip uplatnit ve vývoji softwaru — a kde jsou jeho hranice.

== Cíl práce

Cílem práce je navrhnout, realizovat a ověřit systém, který automatizuje vývojový
proces od přijetí požadavku po vytvoření ověřené změny, aniž by se vzdal lidského
schválení v rozhodujících bodech.

Dílčí cíle:

+ Popsat současný stav automatizace vývoje softwaru a orchestrace jazykových modelů.
+ Navrhnout architekturu systému, který provede požadavek celým procesem.
+ Systém realizovat a nasadit na reálné repozitáře.
+ Vyhodnotit jeho chování a pojmenovat omezení, na která v provozu narazil.

== Struktura práce

Kapitola 2 shrnuje teoretická východiska. Kapitola 3 popisuje vlastní systém
DarkFactory. Kapitola 4 hodnotí výsledky jeho nasazení a kapitola 5 je shrnuje.
