= Teoretická část

Teoretická část shrnuje současný stav poznání a zavádí pojmy, se kterými
dále pracujete. Vše převzaté musí být řádně ocitováno @knuth1984.

== Citování zdrojů

Citace se vkládají zavináčem a klíčem ze souboru `bib/references.bib`:
citace v závorce @lamport1994, citace jako součást věty popisuje
#cite(<knuth1984>, form: "prose").

Poznámky pod čarou lze použít pro doplňující komentář.#footnote[
  Takto vypadá poznámka pod čarou.
]

== Obrázky a tabulky

Na obrázky i tabulky se odkazujte křížovým odkazem, nikoli slovy
„na obrázku níže“ — viz @obr-schema a @tab-srovnani.

#figure(
  image("/img/placeholder.png", width: 60%),
  caption: [Popis obrázku patří pod obrázek.],
) <obr-schema>

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left, center, center),
    table.header([*Metoda*], [*Přesnost*], [*Čas [s]*]),
    [Referenční], [82,4 %], [12,1],
    [Navržená],   [91,7 %], [8,4],
  ),
  caption: [Popis tabulky patří nad tabulku.],
) <tab-srovnani>

== Zdrojový kód

#figure(
  ```python
  def fibonacci(n: int) -> int:
      a, b = 0, 1
      for _ in range(n):
          a, b = b, a + b
      return a
  ```,
  caption: [Ukázka zdrojového kódu.],
) <kod-fib>
