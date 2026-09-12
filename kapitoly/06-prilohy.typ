#import "../lib/odborna-prace.typ": note, issue, alert

#let ai(body) = highlight(fill: yellow, body)

#alert[Nevyvážený rozsah a obsah příloh: Přílohy práce jsou silně redukovány (pouze 2 položky, z nichž jedna duplikuje konfiguraci z kapitoly 3). Pro odbornou práci tohoto typu je žádoucí rozšířit přílohovou část o: A) Obsah přiloženého média, B) Kompletní JSON schéma souboru `darkfactory.json`, C) Ukázku volaného sdíleného GitHub Actions workflow a D) Systémový prompt použitý pro plánovacího a kódovacího agenta.]

= Obsah přiloženého média

Odevzdaný archiv obsahuje zdrojové soubory této práce a odkaz na veřejný
repozitář se zdrojovým kódem systému DarkFactory.

= Referenční specifikace konfiguračního souboru

Tato příloha uvádí kompletní referenční strukturu konfiguračního manifestu `darkfactory.json`. Soubor slouží jako jediný zdroj pravdy pro chování sdíleného vývojového pipeline a parametrizaci agentů v cílovém repozitáři.

#figure(
  ```json
  {
    "$schema": "https://json.schemastore.org/darkfactory.json",
    "identity": {
      "owner": "marius-patrik",
      "repo": "DarkFactory",
      "display_name": "DarkFactory",
      "default_branch": "darkfactory",
      "agent_slug": "darkfactory-agent",
      "description": "Autonomní vývojová továrna pro pipeline řízené agenty",
      "topics": [
        "autonomous-agents",
        "continuous-integration",
        "github-actions",
        "software-engineering"
      ]
    },
    "versioning": {
      "mode": "semver",
      "tag_prefix": "v",
      "initial": "0.1.0",
      "changelog_path": "CHANGELOG.md"
    },
    "license": {
      "spdx": "Apache-2.0",
      "holder": "Patrik Marius",
      "year": "2026"
    },
    "areas": {
      "$default": "ci",
      "agents": {
        "description": "Orchestrace, persony a CLI adaptéry modelů",
        "keywords": ["agent", "harness", "persona", "prompt", "llm"]
      },
      "governance": {
        "description": "Pravidla ochrany větví, požadované kontroly a board",
        "keywords": ["governance", "rule", "protection", "board", "gate"]
      },
      "ci": {
        "description": "Pracovní postupy GitHub Actions, skripty runneru a kontejnery",
        "keywords": ["ci", "action", "workflow", "docker", "runner"]
      },
      "docs": {
        "description": "Dokumentační stránky, sazba textu a architektura",
        "keywords": ["doc", "docs", "typst", "paper", "guide"]
      }
    },
    "board": {
      "global_title": "Global",
      "link_boards": ["Global", "DarkFactory", "Omnis", "ChessWithQuests"]
    },
    "required_checks": [
      "pipeline (3.10)",
      "pipeline (3.11)",
      "pipeline (3.12)",
      "pipeline (3.13)",
      "rust",
      "paper",
      "math",
      "web",
      "docs",
      "verify-bound-issue"
    ],
    "environment": {
      "detect": {
        "code": ["pyproject.toml", "Cargo.toml", "package.json", "go.mod"],
        "paper": ["typst.toml", ".latexmkrc"],
        "math": ["lakefile.toml"]
      },
      "python": "3.12",
      "typst": "0.15.1"
    },
    "pages": {
      "build_type": "workflow"
    },
    "upstream": {
      "repo": "marius-patrik/DarkFactory",
      "ref": "v0.1.0"
    }
  }
  ```,
  caption: [Úplná referenční specifikace konfiguračního souboru `darkfactory.json` vymezující identitu, doménové oblasti, ochranu větví a parametry prostředí.],
) <kod-full-manifest>

Jednotlivé sekce plní tyto systémové role:
- *identity*: Vymezuje vlastníka, název repozitáře, výchozí větev a identifikátor bota (`agent_slug`), podle něhož agent rozpoznává a filtruje vlastní komentáře v diskusních vláknech.
- *versioning*: Řídí sémantické verzování (SemVer) a automatické generování changelogu při vydání nové verze.
- *areas*: Jednotný zdroj pravdy pro štítkování požadavků (prefix `area:`), povolené konvence pro commity (Conventional Commits) a automatické směrování agentů podle shody klíčových slov v zadání.
- *board*: Určuje vazby na globální i repozitářové nástěnky GitHub Projects v2.
- *required_checks*: Deklarace stavových kontrol, které musí úspěšně skončit před povolením sloučení pull requestu (ochrana proti uváznutí na přeskočených kontrolách).
- *environment*: Pravidla rozpoznávání prostředí v repozitáři podle manifestních souborů s možností explicitního přepsání verzí nástrojů.
- *upstream*: Zajišťuje připnutí sdíleného workflow ke konkrétní verzi či commitu upstream repozitáře, což brání nechtěným rozpadům při aktualizacích.

= Protokol revizních značek v sazebním systému Typst

Tato příloha uvádí referenční definici a použití vizuálních revizních značek pro řízení a dohled nad generovaným textem v ekosystému DarkFactory.

#figure(
  ```typ
  #import "lib/odborna-prace.typ": ai, note, issue, alert

  // 1. Návrh agenta čekající na autorské posouzení:
  #ai[Tento odstavec navrhl autonomní model v rámci řešení požadavku.]

  // 2. Návrh na věcné či stylistické vylepšení:
  #note[Doplňte porovnání rychlosti kompilace mezi verzemi 0.1 a 0.2.]

  // 3. Věcná nebo formální chyba vyžadující opravu:
  #issue[Uvedená citace neodpovídá zdroji v souboru bib/references.bib.]

  // 4. Strukturální upozornění na nevyváženost textu:
  #alert[Kapitola postrádá shrnutí naměřených výsledků před diskusí.]
  ```,
  caption: [Ukázka zápisu a použití revizních značek v jazyce Typst.],
) <kod-znacky-typst>

Každá značka plní jasnou komunikační roli v procesu lidského schvalování: zatímco finální text zůstává zcela bez značek, neověřené pasáže jsou okamžitě patrné díky žlutému zvýraznění a náměty či chyby jsou separovány do barevných panelů na okraji textu.

