# RP library variety audit

Reproduce from the repository root: `lua tools/export_library.lua | python3 tools/audit_library.py > docs/rp-variety-report.md`.

Historical entries: **1968**; additive entries: **188**; total: **2156**. Counts include dormant German historical entries.

Lexical triage normalizes case/punctuation/whitespace and replaces the item placeholder. Near duplicates use token-set Jaccard >= 0.75, at least five distinct non-item tokens on both sides, within one language, including cross-category/context pairs. This is a review aid, not semantic proof; shared short syntax can score high.

Exact normalized duplicate groups: **81** (481 extra occurrences). Near-duplicate pairs: **2076**; pairs involving additions: **0**.

## Category

| Value | Historical | Added | Total |
|---|---:|---:|---:|
| alcohol | 204 | 16 | 220 |
| bandage | 204 | 16 | 220 |
| bufffood | 204 | 16 | 220 |
| drink | 204 | 16 | 220 |
| elixir | 204 | 48 | 252 |
| food | 204 | 16 | 220 |
| healthstone | 204 | 16 | 220 |
| hearthstone | 132 | 12 | 144 |
| other | 204 | 16 | 220 |
| potion | 204 | 16 | 220 |

## Source / race

| Value | Historical | Added | Total |
|---|---:|---:|---:|
| Dwarf | 76 | 14 | 90 |
| Gnome | 76 | 14 | 90 |
| Human | 76 | 14 | 90 |
| NightElf | 76 | 14 | 90 |
| Orc | 76 | 14 | 90 |
| Scourge | 92 | 14 | 106 |
| Tauren | 76 | 14 | 90 |
| Troll | 76 | 14 | 90 |
| universal | 1344 | 76 | 1420 |

## Language

| Value | Historical | Added | Total |
|---|---:|---:|---:|
| de | 400 | 0 | 400 |
| en | 1568 | 188 | 1756 |

## Channel

| Value | Historical | Added | Total |
|---|---:|---:|---:|
| me | 984 | 94 | 1078 |
| say | 984 | 94 | 1078 |

## Context

| Value | Historical | Added | Total |
|---|---:|---:|---:|
| last | 648 | 84 | 732 |
| regular | 1320 | 104 | 1424 |

## Full category / source / channel / context matrix

English only; each row is a selectable pool, not a claim of equal runtime weighting.

| Category | Source | Channel | Context | Historical | Added | Total |
|---|---|---|---|---:|---:|---:|
| alcohol | Dwarf | me | last | 2 | 0 | 2 |
| alcohol | Dwarf | me | regular | 2 | 1 | 3 |
| alcohol | Dwarf | say | last | 2 | 0 | 2 |
| alcohol | Dwarf | say | regular | 2 | 0 | 2 |
| alcohol | Gnome | me | last | 2 | 0 | 2 |
| alcohol | Gnome | me | regular | 2 | 1 | 3 |
| alcohol | Gnome | say | last | 2 | 0 | 2 |
| alcohol | Gnome | say | regular | 2 | 0 | 2 |
| alcohol | Human | me | last | 2 | 0 | 2 |
| alcohol | Human | me | regular | 2 | 1 | 3 |
| alcohol | Human | say | last | 2 | 0 | 2 |
| alcohol | Human | say | regular | 2 | 0 | 2 |
| alcohol | NightElf | me | last | 2 | 0 | 2 |
| alcohol | NightElf | me | regular | 2 | 1 | 3 |
| alcohol | NightElf | say | last | 2 | 0 | 2 |
| alcohol | NightElf | say | regular | 2 | 0 | 2 |
| alcohol | Orc | me | last | 2 | 0 | 2 |
| alcohol | Orc | me | regular | 2 | 1 | 3 |
| alcohol | Orc | say | last | 2 | 0 | 2 |
| alcohol | Orc | say | regular | 2 | 0 | 2 |
| alcohol | Scourge | me | last | 2 | 0 | 2 |
| alcohol | Scourge | me | regular | 2 | 1 | 3 |
| alcohol | Scourge | say | last | 2 | 0 | 2 |
| alcohol | Scourge | say | regular | 2 | 0 | 2 |
| alcohol | Tauren | me | last | 2 | 0 | 2 |
| alcohol | Tauren | me | regular | 2 | 1 | 3 |
| alcohol | Tauren | say | last | 2 | 0 | 2 |
| alcohol | Tauren | say | regular | 2 | 0 | 2 |
| alcohol | Troll | me | last | 2 | 0 | 2 |
| alcohol | Troll | me | regular | 2 | 1 | 3 |
| alcohol | Troll | say | last | 2 | 0 | 2 |
| alcohol | Troll | say | regular | 2 | 0 | 2 |
| alcohol | universal | me | last | 20 | 2 | 22 |
| alcohol | universal | me | regular | 30 | 2 | 32 |
| alcohol | universal | say | last | 20 | 2 | 22 |
| alcohol | universal | say | regular | 30 | 2 | 32 |
| bandage | Dwarf | me | last | 2 | 0 | 2 |
| bandage | Dwarf | me | regular | 2 | 0 | 2 |
| bandage | Dwarf | say | last | 2 | 1 | 3 |
| bandage | Dwarf | say | regular | 2 | 0 | 2 |
| bandage | Gnome | me | last | 2 | 0 | 2 |
| bandage | Gnome | me | regular | 2 | 0 | 2 |
| bandage | Gnome | say | last | 2 | 1 | 3 |
| bandage | Gnome | say | regular | 2 | 0 | 2 |
| bandage | Human | me | last | 2 | 0 | 2 |
| bandage | Human | me | regular | 2 | 0 | 2 |
| bandage | Human | say | last | 2 | 1 | 3 |
| bandage | Human | say | regular | 2 | 0 | 2 |
| bandage | NightElf | me | last | 2 | 0 | 2 |
| bandage | NightElf | me | regular | 2 | 0 | 2 |
| bandage | NightElf | say | last | 2 | 1 | 3 |
| bandage | NightElf | say | regular | 2 | 0 | 2 |
| bandage | Orc | me | last | 2 | 0 | 2 |
| bandage | Orc | me | regular | 2 | 0 | 2 |
| bandage | Orc | say | last | 2 | 1 | 3 |
| bandage | Orc | say | regular | 2 | 0 | 2 |
| bandage | Scourge | me | last | 2 | 0 | 2 |
| bandage | Scourge | me | regular | 2 | 0 | 2 |
| bandage | Scourge | say | last | 2 | 1 | 3 |
| bandage | Scourge | say | regular | 2 | 0 | 2 |
| bandage | Tauren | me | last | 2 | 0 | 2 |
| bandage | Tauren | me | regular | 2 | 0 | 2 |
| bandage | Tauren | say | last | 2 | 1 | 3 |
| bandage | Tauren | say | regular | 2 | 0 | 2 |
| bandage | Troll | me | last | 2 | 0 | 2 |
| bandage | Troll | me | regular | 2 | 0 | 2 |
| bandage | Troll | say | last | 2 | 1 | 3 |
| bandage | Troll | say | regular | 2 | 0 | 2 |
| bandage | universal | me | last | 20 | 2 | 22 |
| bandage | universal | me | regular | 30 | 2 | 32 |
| bandage | universal | say | last | 20 | 2 | 22 |
| bandage | universal | say | regular | 30 | 2 | 32 |
| bufffood | Dwarf | me | last | 2 | 1 | 3 |
| bufffood | Dwarf | me | regular | 2 | 0 | 2 |
| bufffood | Dwarf | say | last | 2 | 0 | 2 |
| bufffood | Dwarf | say | regular | 2 | 0 | 2 |
| bufffood | Gnome | me | last | 2 | 1 | 3 |
| bufffood | Gnome | me | regular | 2 | 0 | 2 |
| bufffood | Gnome | say | last | 2 | 0 | 2 |
| bufffood | Gnome | say | regular | 2 | 0 | 2 |
| bufffood | Human | me | last | 2 | 1 | 3 |
| bufffood | Human | me | regular | 2 | 0 | 2 |
| bufffood | Human | say | last | 2 | 0 | 2 |
| bufffood | Human | say | regular | 2 | 0 | 2 |
| bufffood | NightElf | me | last | 2 | 1 | 3 |
| bufffood | NightElf | me | regular | 2 | 0 | 2 |
| bufffood | NightElf | say | last | 2 | 0 | 2 |
| bufffood | NightElf | say | regular | 2 | 0 | 2 |
| bufffood | Orc | me | last | 2 | 1 | 3 |
| bufffood | Orc | me | regular | 2 | 0 | 2 |
| bufffood | Orc | say | last | 2 | 0 | 2 |
| bufffood | Orc | say | regular | 2 | 0 | 2 |
| bufffood | Scourge | me | last | 2 | 1 | 3 |
| bufffood | Scourge | me | regular | 2 | 0 | 2 |
| bufffood | Scourge | say | last | 2 | 0 | 2 |
| bufffood | Scourge | say | regular | 2 | 0 | 2 |
| bufffood | Tauren | me | last | 2 | 1 | 3 |
| bufffood | Tauren | me | regular | 2 | 0 | 2 |
| bufffood | Tauren | say | last | 2 | 0 | 2 |
| bufffood | Tauren | say | regular | 2 | 0 | 2 |
| bufffood | Troll | me | last | 2 | 1 | 3 |
| bufffood | Troll | me | regular | 2 | 0 | 2 |
| bufffood | Troll | say | last | 2 | 0 | 2 |
| bufffood | Troll | say | regular | 2 | 0 | 2 |
| bufffood | universal | me | last | 20 | 2 | 22 |
| bufffood | universal | me | regular | 30 | 2 | 32 |
| bufffood | universal | say | last | 20 | 2 | 22 |
| bufffood | universal | say | regular | 30 | 2 | 32 |
| drink | Dwarf | me | last | 2 | 0 | 2 |
| drink | Dwarf | me | regular | 2 | 1 | 3 |
| drink | Dwarf | say | last | 2 | 0 | 2 |
| drink | Dwarf | say | regular | 2 | 0 | 2 |
| drink | Gnome | me | last | 2 | 0 | 2 |
| drink | Gnome | me | regular | 2 | 1 | 3 |
| drink | Gnome | say | last | 2 | 0 | 2 |
| drink | Gnome | say | regular | 2 | 0 | 2 |
| drink | Human | me | last | 2 | 0 | 2 |
| drink | Human | me | regular | 2 | 1 | 3 |
| drink | Human | say | last | 2 | 0 | 2 |
| drink | Human | say | regular | 2 | 0 | 2 |
| drink | NightElf | me | last | 2 | 0 | 2 |
| drink | NightElf | me | regular | 2 | 1 | 3 |
| drink | NightElf | say | last | 2 | 0 | 2 |
| drink | NightElf | say | regular | 2 | 0 | 2 |
| drink | Orc | me | last | 2 | 0 | 2 |
| drink | Orc | me | regular | 2 | 1 | 3 |
| drink | Orc | say | last | 2 | 0 | 2 |
| drink | Orc | say | regular | 2 | 0 | 2 |
| drink | Scourge | me | last | 2 | 0 | 2 |
| drink | Scourge | me | regular | 4 | 1 | 5 |
| drink | Scourge | say | last | 2 | 0 | 2 |
| drink | Scourge | say | regular | 2 | 0 | 2 |
| drink | Tauren | me | last | 2 | 0 | 2 |
| drink | Tauren | me | regular | 2 | 1 | 3 |
| drink | Tauren | say | last | 2 | 0 | 2 |
| drink | Tauren | say | regular | 2 | 0 | 2 |
| drink | Troll | me | last | 2 | 0 | 2 |
| drink | Troll | me | regular | 2 | 1 | 3 |
| drink | Troll | say | last | 2 | 0 | 2 |
| drink | Troll | say | regular | 2 | 0 | 2 |
| drink | universal | me | last | 20 | 2 | 22 |
| drink | universal | me | regular | 28 | 2 | 30 |
| drink | universal | say | last | 20 | 2 | 22 |
| drink | universal | say | regular | 30 | 2 | 32 |
| elixir | Dwarf | me | last | 2 | 1 | 3 |
| elixir | Dwarf | me | regular | 2 | 1 | 3 |
| elixir | Dwarf | say | last | 2 | 1 | 3 |
| elixir | Dwarf | say | regular | 2 | 2 | 4 |
| elixir | Gnome | me | last | 2 | 1 | 3 |
| elixir | Gnome | me | regular | 2 | 1 | 3 |
| elixir | Gnome | say | last | 2 | 1 | 3 |
| elixir | Gnome | say | regular | 2 | 2 | 4 |
| elixir | Human | me | last | 2 | 1 | 3 |
| elixir | Human | me | regular | 2 | 1 | 3 |
| elixir | Human | say | last | 2 | 1 | 3 |
| elixir | Human | say | regular | 2 | 2 | 4 |
| elixir | NightElf | me | last | 2 | 1 | 3 |
| elixir | NightElf | me | regular | 2 | 1 | 3 |
| elixir | NightElf | say | last | 2 | 1 | 3 |
| elixir | NightElf | say | regular | 2 | 2 | 4 |
| elixir | Orc | me | last | 2 | 1 | 3 |
| elixir | Orc | me | regular | 2 | 1 | 3 |
| elixir | Orc | say | last | 2 | 1 | 3 |
| elixir | Orc | say | regular | 2 | 2 | 4 |
| elixir | Scourge | me | last | 2 | 1 | 3 |
| elixir | Scourge | me | regular | 2 | 1 | 3 |
| elixir | Scourge | say | last | 2 | 1 | 3 |
| elixir | Scourge | say | regular | 2 | 2 | 4 |
| elixir | Tauren | me | last | 2 | 1 | 3 |
| elixir | Tauren | me | regular | 2 | 1 | 3 |
| elixir | Tauren | say | last | 2 | 1 | 3 |
| elixir | Tauren | say | regular | 2 | 2 | 4 |
| elixir | Troll | me | last | 2 | 1 | 3 |
| elixir | Troll | me | regular | 2 | 1 | 3 |
| elixir | Troll | say | last | 2 | 1 | 3 |
| elixir | Troll | say | regular | 2 | 2 | 4 |
| elixir | universal | me | last | 20 | 2 | 22 |
| elixir | universal | me | regular | 30 | 2 | 32 |
| elixir | universal | say | last | 20 | 2 | 22 |
| elixir | universal | say | regular | 30 | 2 | 32 |
| food | Dwarf | me | last | 2 | 0 | 2 |
| food | Dwarf | me | regular | 2 | 0 | 2 |
| food | Dwarf | say | last | 2 | 0 | 2 |
| food | Dwarf | say | regular | 2 | 1 | 3 |
| food | Gnome | me | last | 2 | 0 | 2 |
| food | Gnome | me | regular | 2 | 0 | 2 |
| food | Gnome | say | last | 2 | 0 | 2 |
| food | Gnome | say | regular | 2 | 1 | 3 |
| food | Human | me | last | 2 | 0 | 2 |
| food | Human | me | regular | 2 | 0 | 2 |
| food | Human | say | last | 2 | 0 | 2 |
| food | Human | say | regular | 2 | 1 | 3 |
| food | NightElf | me | last | 2 | 0 | 2 |
| food | NightElf | me | regular | 2 | 0 | 2 |
| food | NightElf | say | last | 2 | 0 | 2 |
| food | NightElf | say | regular | 2 | 1 | 3 |
| food | Orc | me | last | 2 | 0 | 2 |
| food | Orc | me | regular | 2 | 0 | 2 |
| food | Orc | say | last | 2 | 0 | 2 |
| food | Orc | say | regular | 2 | 1 | 3 |
| food | Scourge | me | last | 2 | 0 | 2 |
| food | Scourge | me | regular | 3 | 0 | 3 |
| food | Scourge | say | last | 2 | 0 | 2 |
| food | Scourge | say | regular | 3 | 1 | 4 |
| food | Tauren | me | last | 2 | 0 | 2 |
| food | Tauren | me | regular | 2 | 0 | 2 |
| food | Tauren | say | last | 2 | 0 | 2 |
| food | Tauren | say | regular | 2 | 1 | 3 |
| food | Troll | me | last | 2 | 0 | 2 |
| food | Troll | me | regular | 2 | 0 | 2 |
| food | Troll | say | last | 2 | 0 | 2 |
| food | Troll | say | regular | 2 | 1 | 3 |
| food | universal | me | last | 20 | 2 | 22 |
| food | universal | me | regular | 29 | 2 | 31 |
| food | universal | say | last | 20 | 2 | 22 |
| food | universal | say | regular | 29 | 2 | 31 |
| healthstone | Dwarf | me | last | 2 | 0 | 2 |
| healthstone | Dwarf | me | regular | 2 | 0 | 2 |
| healthstone | Dwarf | say | last | 2 | 0 | 2 |
| healthstone | Dwarf | say | regular | 2 | 1 | 3 |
| healthstone | Gnome | me | last | 2 | 0 | 2 |
| healthstone | Gnome | me | regular | 2 | 0 | 2 |
| healthstone | Gnome | say | last | 2 | 0 | 2 |
| healthstone | Gnome | say | regular | 2 | 1 | 3 |
| healthstone | Human | me | last | 2 | 0 | 2 |
| healthstone | Human | me | regular | 2 | 0 | 2 |
| healthstone | Human | say | last | 2 | 0 | 2 |
| healthstone | Human | say | regular | 2 | 1 | 3 |
| healthstone | NightElf | me | last | 2 | 0 | 2 |
| healthstone | NightElf | me | regular | 2 | 0 | 2 |
| healthstone | NightElf | say | last | 2 | 0 | 2 |
| healthstone | NightElf | say | regular | 2 | 1 | 3 |
| healthstone | Orc | me | last | 2 | 0 | 2 |
| healthstone | Orc | me | regular | 2 | 0 | 2 |
| healthstone | Orc | say | last | 2 | 0 | 2 |
| healthstone | Orc | say | regular | 2 | 1 | 3 |
| healthstone | Scourge | me | last | 2 | 0 | 2 |
| healthstone | Scourge | me | regular | 2 | 0 | 2 |
| healthstone | Scourge | say | last | 2 | 0 | 2 |
| healthstone | Scourge | say | regular | 2 | 1 | 3 |
| healthstone | Tauren | me | last | 2 | 0 | 2 |
| healthstone | Tauren | me | regular | 2 | 0 | 2 |
| healthstone | Tauren | say | last | 2 | 0 | 2 |
| healthstone | Tauren | say | regular | 2 | 1 | 3 |
| healthstone | Troll | me | last | 2 | 0 | 2 |
| healthstone | Troll | me | regular | 2 | 0 | 2 |
| healthstone | Troll | say | last | 2 | 0 | 2 |
| healthstone | Troll | say | regular | 2 | 1 | 3 |
| healthstone | universal | me | last | 20 | 2 | 22 |
| healthstone | universal | me | regular | 30 | 2 | 32 |
| healthstone | universal | say | last | 20 | 2 | 22 |
| healthstone | universal | say | regular | 30 | 2 | 32 |
| hearthstone | Dwarf | me | regular | 2 | 0 | 2 |
| hearthstone | Dwarf | say | regular | 2 | 1 | 3 |
| hearthstone | Gnome | me | regular | 2 | 0 | 2 |
| hearthstone | Gnome | say | regular | 2 | 1 | 3 |
| hearthstone | Human | me | regular | 2 | 0 | 2 |
| hearthstone | Human | say | regular | 2 | 1 | 3 |
| hearthstone | NightElf | me | regular | 2 | 0 | 2 |
| hearthstone | NightElf | say | regular | 2 | 1 | 3 |
| hearthstone | Orc | me | regular | 2 | 0 | 2 |
| hearthstone | Orc | say | regular | 2 | 1 | 3 |
| hearthstone | Scourge | me | regular | 2 | 0 | 2 |
| hearthstone | Scourge | say | regular | 2 | 1 | 3 |
| hearthstone | Tauren | me | regular | 2 | 0 | 2 |
| hearthstone | Tauren | say | regular | 2 | 1 | 3 |
| hearthstone | Troll | me | regular | 2 | 0 | 2 |
| hearthstone | Troll | say | regular | 2 | 1 | 3 |
| hearthstone | universal | me | regular | 30 | 2 | 32 |
| hearthstone | universal | say | regular | 30 | 2 | 32 |
| other | Dwarf | me | last | 2 | 1 | 3 |
| other | Dwarf | me | regular | 2 | 0 | 2 |
| other | Dwarf | say | last | 2 | 0 | 2 |
| other | Dwarf | say | regular | 2 | 0 | 2 |
| other | Gnome | me | last | 2 | 1 | 3 |
| other | Gnome | me | regular | 2 | 0 | 2 |
| other | Gnome | say | last | 2 | 0 | 2 |
| other | Gnome | say | regular | 2 | 0 | 2 |
| other | Human | me | last | 2 | 1 | 3 |
| other | Human | me | regular | 2 | 0 | 2 |
| other | Human | say | last | 2 | 0 | 2 |
| other | Human | say | regular | 2 | 0 | 2 |
| other | NightElf | me | last | 2 | 1 | 3 |
| other | NightElf | me | regular | 2 | 0 | 2 |
| other | NightElf | say | last | 2 | 0 | 2 |
| other | NightElf | say | regular | 2 | 0 | 2 |
| other | Orc | me | last | 2 | 1 | 3 |
| other | Orc | me | regular | 2 | 0 | 2 |
| other | Orc | say | last | 2 | 0 | 2 |
| other | Orc | say | regular | 2 | 0 | 2 |
| other | Scourge | me | last | 2 | 1 | 3 |
| other | Scourge | me | regular | 2 | 0 | 2 |
| other | Scourge | say | last | 2 | 0 | 2 |
| other | Scourge | say | regular | 2 | 0 | 2 |
| other | Tauren | me | last | 2 | 1 | 3 |
| other | Tauren | me | regular | 2 | 0 | 2 |
| other | Tauren | say | last | 2 | 0 | 2 |
| other | Tauren | say | regular | 2 | 0 | 2 |
| other | Troll | me | last | 2 | 1 | 3 |
| other | Troll | me | regular | 2 | 0 | 2 |
| other | Troll | say | last | 2 | 0 | 2 |
| other | Troll | say | regular | 2 | 0 | 2 |
| other | universal | me | last | 20 | 2 | 22 |
| other | universal | me | regular | 30 | 2 | 32 |
| other | universal | say | last | 20 | 2 | 22 |
| other | universal | say | regular | 30 | 2 | 32 |
| potion | Dwarf | me | last | 2 | 1 | 3 |
| potion | Dwarf | me | regular | 2 | 0 | 2 |
| potion | Dwarf | say | last | 2 | 0 | 2 |
| potion | Dwarf | say | regular | 2 | 0 | 2 |
| potion | Gnome | me | last | 2 | 1 | 3 |
| potion | Gnome | me | regular | 2 | 0 | 2 |
| potion | Gnome | say | last | 2 | 0 | 2 |
| potion | Gnome | say | regular | 2 | 0 | 2 |
| potion | Human | me | last | 2 | 1 | 3 |
| potion | Human | me | regular | 2 | 0 | 2 |
| potion | Human | say | last | 2 | 0 | 2 |
| potion | Human | say | regular | 2 | 0 | 2 |
| potion | NightElf | me | last | 2 | 1 | 3 |
| potion | NightElf | me | regular | 2 | 0 | 2 |
| potion | NightElf | say | last | 2 | 0 | 2 |
| potion | NightElf | say | regular | 2 | 0 | 2 |
| potion | Orc | me | last | 2 | 1 | 3 |
| potion | Orc | me | regular | 2 | 0 | 2 |
| potion | Orc | say | last | 2 | 0 | 2 |
| potion | Orc | say | regular | 2 | 0 | 2 |
| potion | Scourge | me | last | 2 | 1 | 3 |
| potion | Scourge | me | regular | 2 | 0 | 2 |
| potion | Scourge | say | last | 2 | 0 | 2 |
| potion | Scourge | say | regular | 2 | 0 | 2 |
| potion | Tauren | me | last | 2 | 1 | 3 |
| potion | Tauren | me | regular | 2 | 0 | 2 |
| potion | Tauren | say | last | 2 | 0 | 2 |
| potion | Tauren | say | regular | 2 | 0 | 2 |
| potion | Troll | me | last | 2 | 1 | 3 |
| potion | Troll | me | regular | 2 | 0 | 2 |
| potion | Troll | say | last | 2 | 0 | 2 |
| potion | Troll | say | regular | 2 | 0 | 2 |
| potion | universal | me | last | 20 | 2 | 22 |
| potion | universal | me | regular | 30 | 2 | 32 |
| potion | universal | say | last | 20 | 2 | 22 |
| potion | universal | say | regular | 30 | 2 | 32 |

## Addition similarity flags

No addition reaches the stated near-duplicate threshold.

## Historical repeated-syntax examples (English)

- 9 occurrences: searches the satchel for another {item}, but finds only an empty space.
- 9 occurrences: realizes that was the last {item}. "A most inconvenient discovery."
- 9 occurrences: checks every pocket for another {item}. None remains.
- 9 occurrences: stares at the empty place where the {item} used to be.
- 9 occurrences: takes stock of the supplies. Not a single {item} remains.
- 9 occurrences: shakes an empty pouch once held full of {item}. "How unfortunate."
- 9 occurrences: finishes the final {item} and makes a mental note to restock.
- 9 occurrences: looks for another {item}, then sighs at the barren inventory.

## Retained wording and byte-budget audit

| Registry | English gendered-pronoun lines | English /me with embedded quotes | Maximum template bytes | Over 255 with 120-byte substitution |
|---|---:|---:|---:|---:|
| Historical | 26 | 444 | 156 | 7 |
| Added | 0 | 0 | 91 | 0 |

Embedded dialogue in historical /me is stylistically mixed, not necessarily invalid chat syntax. New actions use narration only. The 120-byte substitution is a stated test budget, not a guaranteed upper bound for every real hyperlink; send-time validation remains mandatory.

Semantic review and retained historical issues: [writing guide](rp-writing-guide.md). No historical line was removed to improve these metrics.
