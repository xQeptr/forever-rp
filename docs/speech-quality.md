# Speech source quality and quest exclusion

## Findings before this change

The nine classes each supplied 19 speech entries but only three distinct strings:
one reused for ordinary use across categories, one for final items, and one for
Hearthstone. Skyborne had the same limitation. The eight original racial libraries
had 45 distinct speech lines each but only 2-4 per category/context. Consequently,
single-line class/race pools could trigger the old no-repeat reroute toward general
text after a 50/30/20 draw. Adding general text alone did not fix that weakness.

## Current expansion

`IdentitySpeechLibrary.lua` adds 603 class and 352 racial English speech lines,
all category-specific, with stable `voice-NN` IDs and `migrationMatch=false`.
The nine classes now have 70 distinct speech strings each across their contexts;
Skyborne has 51. Existing phrase IDs, text and disable preferences remain unchanged.
The additions are original RP writing, not lore quotations or claims about actual
item effects. Hearthstone lines describe departure, never arrival; Healthstone
lines make no claim about detecting charges. Text is gender-neutral and is checked
against historical wording, other additions and the expanded 255-byte chat budget.

Supported enriched classes: Warrior, Paladin, Hunter, Rogue, Priest, Shaman, Mage,
Warlock, Druid. Enriched racial sources: Human, Orc, Dwarf, Night Elf, Forsaken,
Tauren, Gnome, Troll, Skyborne. No invented numeric Skyborne identity is added.
Other/unknown identities use available pools; sources are never borrowed from an
unrelated race/class.

Selection is 50/30/20 among available default source pools, not among individual
lines. Custom-text ticket weighting remains separate. The selector excludes the
last global/per-item text before drawing a source. It then uses the original pool
and its shuffle deck, retaining no-repeat checks when switching item/category or
regular/Last Item context. Missing/disabled/singleton-repeated sources are reweighted;
if only one unique phrase remains it may repeat rather than silently disabling RP.

Regression coverage measures 20,000 draws for each of food/drink/potion regular
and Last Item pools, plus missing-race and missing-class fallback. Each measured
source must stay within two percentage points of its expected probability. Tests
also enumerate every enriched race/class/category/context and verify counts,
opt-outs, stable unique IDs, originality and no-immediate-repeat behaviour.

## Quest filtering

`QuestItems.lua` reads the client's container quest association, item class and
quest binding. It never infers quest status from a localized item name or from
having received an item as a quest reward. Positive evidence hides both carried
and remembered items, suppresses active sends and survives missing cached data.
Temporary bag associations may clear with reliable normal-item and bag metadata;
permanent quest-class/binding evidence is not cleared by an unrelated cache miss.
No saved item or phrase arrays are deleted or reset. Hidden invalid drafts are
archived. Optional APIs, malformed results and secret values are guarded.

The regression fixtures include the screenshot's ID 5457 with quest-bound metadata,
not a hardcoded ID blacklist. The actual client still needs a smoke test: quest
items disappear after `/reload` + `/frp scan`, ordinary food/rewards remain, race
and class match `/frp compat`, and another player observes intended group output.

API signature references (Forever client UI documentation):
[container quest information](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/ContainerDocumentation.lua)
and [item class/binding metadata](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/ItemDocumentation.lua).


## German in 0.10.0

The additional German speech library has 966 stable native-0100 IDs: 192 general,
432 class and 342 racial entries. It is authored as German dialogue rather than
a phrase-for-phrase translation. Both regular and final-item situations have
category-specific lines; reusable Hearthstones have departure lines only.
Existing English IDs/text and saved German/custom data remain unchanged.

Tests verify every identity/category, unique new German wording, 200-byte UTF-8
templates and expanded 255-byte budgets with a 120-byte item link. German regular
and Last Item selections each undergo 20,000 weighted draws and immediate-repeat
checks. Runtime tests cover automatic locale selection, persisted overrides,
separate custom/Last Item pools, invalid drafts, migration and the unchanged
shared cooldown. These simulations do not prove client font layout or chat delivery.

Client smoke test: run /reload, confirm 0.10.0-forever-preview (or retail-beta),
choose Automatic with a German game client, inspect categories/menus/validation,
switch to English and back, save one custom line in each language, test regular
and final consumption in a supported group and ask a second player what arrived.
Also verify language selection and opt-outs after another /reload.
