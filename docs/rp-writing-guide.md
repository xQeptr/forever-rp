# RP writing guide and editorial rationale

This is an additive English editorial pass, not a rewrite of player data. The
1,360 frozen historical entries and 608 previously authored racial entries retain
their IDs, texts, aliases and opt-outs. `EditorialLibrary.lua` adds 188 original
entries: 76 general and 112 racial. No existing default is silently retired.
The quantitative audit is in [rp-variety-report.md](rp-variety-report.md).

## Research record

Research checked 30 October 2026. The eight individual official race URLs
(`/game/races/undead`, `/gnome`, `/dwarf`, `/orc`, `/troll`, `/tauren`, `/human`,
`/night-elf`) returned HTTP 403 to direct browsing. They were attempted, not
represented as successfully read. The official [race index](https://worldofwarcraft.blizzard.com/en-us/game/races/)
was available, but is too brief to establish detailed cultural habits.
The usable sources below were official text indexed by web search. Direct PDF
retrieval of the US manual timed out; indexed sections were available. This
distinction matters: no supposed newly discovered client-specific lore is used.

| Source | What it supports | Editorial consequence |
| --- | --- | --- |
| Blizzard [Taking Your First Steps in WoW Classic](https://worldofwarcraft.blizzard.com/en-gb/news/23317716/taking-your-first-steps-in-world-of-warcraft-classic) | Eight race introductions, including orc honor, the Darkspear's displacement and alliance, ancient night elves | Honor becomes keeping promises; trolls receive a distinct voice without caricatured spelling; night elves get patience and observation. |
| Blizzard [US Classic manual](https://us.media.blizzard.com/manuals/wow/wow-classic-manual-enUS.pdf), indexed Forsaken and Night Elf sections | Forsaken autonomy and Lordaeron history; night elf antiquity and the costs of war | Memories and personal agency are stronger motifs than a compulsory death joke in every sentence. |
| Blizzard [UK Classic manual](https://eu.media.blizzard.com/manuals/wow/eu/classic/wow-classic-manual-enGB.pdf), indexed race introductions | Dwarven storytelling, gnomish technology, human resilience, tauren attachment to nature | Dwarves get expeditions and company; gnomes notice workmanship; humans get practical travel and civic habits; tauren get gratitude and care for the land. |
| Blizzard [original game manual](https://bnetcmsus-a.akamaihd.net/cms/template_resource/263A8NGR8HLZ1556919642368.pdf), indexed Tauren and Troll sections | Earth Mother tradition, travel across the plains, Darkspear history | One Earth Mother farewell is optional racial flavor, not a class assumption or a universal religious declaration. |
| Dark Horse/Blizzard [Chronicle volume 1 sample](https://images.darkhorse.com/darkhorse/newsletter/2016blasts/WoWChronicleSample.pdf), Ancient Kalimdor | Loa veneration and varied troll customs | A brief thanksgiving can mention the loa; no specific patron, tribe, ritual equipment or dialect is forced. |

These sources establish broad fictional contexts, not personalities. The new
sentences are original writing. Nothing is copied from dialogue, manuals or RPG
books. Historical faction leaders, political slogans and expansion-specific
events are avoided because the same source serves Retail and Forever. Old manual
class restrictions and old claims about immortality are not client specifications.
Licensed tabletop RPG material is not used to establish game canon.

## What the existing library needed

The historical samples include male assumptions such as `his gauntlet`, `his
pulse` and `his satchel`. Much of the healthstone language once treated a fel
stone as a snack; the frozen registry already contains explicit corrections and
aliases for those entries. Some general historical phrases retain undead flavor.
The new pass does not change the meaning of those shipped IDs to solve this.

The 608 racial entries are substantial, but their construction exposes repeated
scaffolding: an action plus a quotation in `/me`, then the same quotation with a
category suffix in `/say`. Examples include `The dose of {item} is taken.`,
`A moment for {item}.` and `Ready after {item}.` Stock pools repeat inventory
shortage announcements across categories. This is useful coverage, but numerical
size overstates dramatic diversity. Literal duplication, shared sentence frames
and repeated semantic beats are different problems; a token-similarity score
cannot judge all three.

The new entries therefore add distinct small scenes: a folded label kept for
restocking, residue against glass, a batch mark copied into notes, a quiet toast,
an expedition tally, a knot checked before walking. They avoid merely exchanging
an adjective or a race name in a common sentence. Racial flavor can be restrained;
not every line needs a lore proper noun.

For Morvain using item 3382, the change applies through **Elixir / Flask**, not
an item-ID special case or a claim about troll blood ingredients. Forsaken gain
five additional elixir lines and general elixirs gain eight. One example is
`Another alchemical precaution. I would settle for keeping everything attached.`
Another is the quieter `/me` inspection of sediment after taking the dose. No
line guarantees health restoration, mana gain or a measured buff duration.

## Writing rules for future additions

- Aim loosely for 60% immersive observation, 25% dry wit and 15% darker irony.
  This is a palette, not a statistical selection rule. Do not turn every racial
  pool into jokes or every shortage into catastrophe.
- `/me` continues the character name with a present-tense action. New entries
  use pure action, without slash commands, stage directions around speech or
  second messages. `/say` is the spoken sentence itself, without outer quotation
  marks or an action narrator. Historical mixed emote/speech entries are retained.
- Avoid gendered pronouns, assumed beards, profession, class, named companions,
  certain geography, weather, injuries to a particular limb or an inventory item
  the player may not own. Modest travel props are narrative flavor, not game
  state. There is no instruction to spawn objects, consume another item or act.
- Healthstones break or release fel energy. Potions are brief draughts without a
  guaranteed healing/mana result. Elixirs suggest measured preparation for a
  longer journey, not a fast emergency heal or an asserted numeric duration.
- Food is a meal, drink a pause to drink, buff food deliberate preparation.
  Alcohol stays optional and never defines dwarven identity. Bandages dress
  physical wounds without declaring full recovery. Other remains neutral.
- Hearthstone lines concern calling/trying/departing at cast START. There is no
  arrival statement, successful-teleport guarantee or Last Item hearthstone pool.
- Last Item replaces Regular and means zero remaining of this item ID, never
  zero of the whole category. Express that specific exhausted reserve; do not
  announce the shortage and then imply a second dose remains. Never infer the
  last healthstone charge from the wording.
- `{item}` is optional. If present, use it once and let runtime insert the real
  hyperlink; never paste hyperlinks or color codes into authored text. Omitting
  it sometimes produces more natural speech and leaves more chat-byte headroom.
- Source phrases must validate under the existing 200-byte limit. Keep new lines
  short enough to expand a 120-byte test hyperlink within 255 bytes. This is a
  tested fixture, not proof that arbitrary future/localized links always fit;
  runtime expansion validation remains authoritative. WoW limits bytes, not
  displayed characters.

## Race voice without compulsory stereotypes

| Race | Preferred motifs | Avoid |
| --- | --- | --- |
| Forsaken (`Scourge`) | Habit outliving appetite, remembered courtesy, bodily maintenance, autonomy, dry preservation jokes | Assuming a pulse, universal cruelty, mandatory affiliation with an apothecary organization |
| Dwarf | Expedition craft, storytelling, dependable company, difficult roads | Every line about beer, beards, drunkenness or a single clan |
| Gnome | Curious attention, stable mixtures, useful notes, quiet ingenuity | Every item exploding, constant comedy, assuming an engineer class/profession |
| Orc | Plain promises, preparation, loyalty, restraint around fel power | Shouting honor slogans, compulsory rage or a named clan |
| Troll | Resourcefulness, patience, remembrance, occasional respectful loa reference | Forced phonetic accent, borrowed real-world ritual details, treating all tribes as one |
| Tauren | Thanks, care for provisions and land, patient attention | Every line a sermon, assuming druid/shaman powers or naming a tribe |
| Human | Varied travel habits, trade, ledgers, home and company | Treating every human as nobility, a soldier or a Stormwind citizen |
| Night Elf | Quiet observation, practiced patience, memory | Claiming personal age, immortality, omniscience, a particular faith or class |

## Compatibility and limits of this pass

New IDs use the literal `:editorial-` namespace and must never be recycled or
renumbered. New entries set `migrationMatch=false`: an existing custom phrase
which happens to equal a newly added line must remain owned custom text rather
than becoming a historical sample import. No new migration aliases are required
because no historical text changed. New defaults begin enabled; existing stable
opt-outs stay category/pool-specific. Selection still uses the existing 70/30
general/racial weighting, not the numerical proportions of this expansion.

The new distribution deliberately gives every race one additional line in each
category, then four additional elixir lines per race. General entries cover all
38 valid category/context/channel pools. The reported count increase is 188,
not thousands of generated combinations. A larger uniform expansion would have
concealed the same repetitive scaffolding this pass is intended to reduce.

Preserving historical IDs also preserves historical editorial imperfections.
The audit counts 26 English historical lines with gendered pronouns and seven
historical lines over 255 bytes under the 120-byte substitution fixture. They
are retained, not presented as corrected: actual overlong expansions remain
suppressed by the existing send-time guard. None of the 188 additions has either
issue under that fixture.
They remain visible and selectable; this pass improves variety without pretending
to have replaced the entire library. Similarity findings need human review and
are reported separately from hard format failures. No mock establishes in-game
delivery, visual layout or Forever mechanics. Retail and Forever approval remains
an explicit real-client task with backed-up SavedVariables and a second player.
