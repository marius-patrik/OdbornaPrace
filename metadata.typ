// ─────────────────────────────────────────────────────────────
//  Metadata práce — jediné místo, které je potřeba upravit.
// ─────────────────────────────────────────────────────────────

#let meta = (
  nazev: "Název odborné práce",
  podnazev: none,

  autor: "Jméno Příjmení",
  trida: "4.a",
  vedouci: "Jméno vedoucího práce",
  konzultant: none,

  skola: "Název střední školy",
  // Zkratka použitá v textu prohlášení.
  skola-zkratka: "ZKRATKA",
  mesto: "Město",
  rok: 2026,

  // Anotace — 3–5 vět: cíl, metoda, výsledek.
  anotace: [
    Zde uveďte stručnou anotaci práce v českém jazyce. Popište cíl práce,
    použité metody a nejdůležitější dosažené výsledky.
  ],
  abstract: [
    Provide a short English abstract here. Describe the aim of the thesis,
    the methods used and the most important results achieved.
  ],

  klicova-slova: ("první", "druhé", "třetí"),
  keywords: ("first", "second", "third"),

  // Nepovinné — `none` pro vynechání.
  podekovani: none,
)
