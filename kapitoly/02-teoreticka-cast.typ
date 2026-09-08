= Teoretická část

Tato kapitola vymezuje pojmy, o které se opírá praktická část: řízení verzí,
kontinuální integrace a orchestrace jazykových modelů.

== Řízení verzí a model pull requestu

Distribuované řízení verzí umožňuje vést změny odděleně od hlavní vývojové větve
a slučovat je až po přezkoumání. Tento postup — _pull request_ — je dnes ve vývoji
softwaru převládající a je zároveň místem, kde se uplatňuje kontrola kvality.

== Kontinuální integrace

Kontinuální integrace znamená, že se každá změna automaticky sestaví a otestuje.
Zavádí pojem _požadované kontroly_ (angl. required checks): množinu úloh, které
musí skončit úspěšně, jinak změnu nelze sloučit. Tím se z kvality stává vlastnost
vynucovaná strojem, nikoli dohodou.

== Jazykové modely a jejich orchestrace

Velké jazykové modely dokážou generovat i upravovat zdrojový kód. Pro praktické
nasazení je ovšem podstatnější než samotná schopnost generovat text to, jak je
model zasazen do procesu: jaké dostane vstupy, jaké má k dispozici nástroje a kdo
ověřuje jeho výstup.

=== Problém jednoho poskytovatele

Spoléhá-li systém na jediného poskytovatele modelu, zastaví se ve chvíli, kdy
tento poskytovatel vyčerpá kvótu nebo změní rozhraní. Řešením je vrstva, která
umí tentýž úkol předat kterémukoli z několika poskytovatelů.

== Governance automatizovaných změn

Čím je systém samostatnější, tím důležitější je otázka, kde do procesu vstupuje
člověk. Úplná autonomie není cílem — cílem je autonomie v rutinních krocích
a lidské rozhodnutí tam, kde je nevratné.
