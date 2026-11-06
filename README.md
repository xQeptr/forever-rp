# Forever RP

Forever RP adds automatic English or German RP speech to group chat after verified item use.
It supports food, drinks, potions, healthstones, bandages, elixirs, alcohol and other
consumables, plus a separate Hearthstone departure announcement.

## Current test build

Version **0.10.0**: Retail beta and WoW Forever preview. This working build
focuses on group speech only. Existing saved player data and dormant local-chat
implementations are preserved. Real-client compatibility is not established by
mock tests. Healthstone uses without a stack-count decrease remain unconfirmed;
Last Item means the final carried item, not a verified last charge.

The user tested Forever **1.60.1, build 70790**: automatic local chat was blocked,
manual local emotes appeared, and automatic group speech was reported working.
The latest policy/editor/item-source changes still need in-client testing, and
another player's observation of delivery has not been recorded. See
[the client test checklist](docs/group-speech.md).

## Language / Sprache

**Automatic** is the default: a German game client (`deDE`) selects German;
every other client locale uses English. The **Language / Sprache** dropdown in
the window header lets you choose Automatic, English or Deutsch. The choice
applies to both the editor and outgoing group speech and persists across reloads.

Alternatively use `/frp language auto`, `/frp language en` or
`/frp language de`. No reload is needed for a manual switch. It chooses your
own outgoing language; it does not detect another player's language or translate
incoming chat.

The German expansion has **966 independently written speech lines**: 192 general,
432 class and 342 racial, including Last Item text and Hearthstone departures.
It covers the same nine classes and nine race identities as the English library.
The **50% general / 30% race / 20% class** mix applies in both languages, with
proportional fallback for unavailable identities or disabled pools.

English and German custom texts and opt-outs remain separate. Valid pending
edits save into their original language before switching; invalid edits must be
corrected or explicitly discarded. If the game locale changes between sessions,
an unsaved draft is retained in `languageDrafts` for its original language and
recovered when you return to that language. Existing English data and dormant
German/action pools are preserved. A historical explicit German choice remains
manual German; the historically forced English default becomes Automatic.

**Deutsch:** Standardmäßig folgt Forever RP der Spielsprache. Oben im Fenster
kannst du jederzeit zwischen Automatisch, Englisch und Deutsch wechseln.
Eigene Texte werden für beide Sprachen getrennt gespeichert. Ein Sprachwechsel
setzt weder deine Einstellungen noch die gemeinsame RP-Abklingzeit zurück.

## Group output

Choose **Groups (all)**, **Dungeons**, **Raids** or **Disabled**, globally or for an
individual item (which may inherit the global choice). Groups includes all three
supported group contexts; Dungeons and Raids are filters for those contexts.
Solo, battleground and arena contexts do not produce automatic output.

The addon detects the actual group and chooses the channel automatically:

| Current group | Channel |
| --- | --- |
| Normal party | PARTY |
| Raid, including an outdoor raid | RAID |
| Instance-category group | INSTANCE_CHAT |

A manually assembled party inside a dungeon still uses PARTY; a manually
assembled raid uses RAID. The group type filter and chat destination are separate.

There are no action/speech mode controls. All active output uses the existing
speech pools for the selected language (`sayLines` / `outSayLines` or
`deSayLines` / `outDeSayLines`) and speech defaults. The library
includes **192 additional speech phrases**: 12 regular and 8 Last Item lines for
each consumable category, plus 12 Hearthstone departures. Category, race and class
defaults remain shared, with individual opt-outs and separate custom texts.
The default-source draw is **50% general / 30% race / 20% class**, independent
of how many phrases a pool contains. Missing or entirely disabled sources are
reweighted proportionally. Custom phrases keep their separate ticket weighting.
No-immediate-repeat filtering happens before source selection; a source reduced
to a single repeated line by opt-outs can be temporarily unavailable.

The current speech expansion adds **955 identity lines**: 603 for the nine class
pools and 352 for the eight original race pools plus Skyborne. These are original,
category-specific lines, including final-item dialogue. Old IDs, phrases and
opt-outs stay stored. The editor shows active pool sizes and effective nominal
weights; `/frp status` and debug output show the selected source. Other/unknown
races or classes use the available sources without guessing an identity.

Quest-associated items, quest-class items and quest-bound tools are excluded from
the carried-item scan and every editor filter, including remembered items. Positive
quest evidence is kept across cache misses. A temporary bag quest association can
clear when bag and item metadata positively identify normal supplies again.
Ordinary usable quest rewards are not excluded merely because they were rewards.
Old item settings, custom phrases and invalid editor drafts are preserved rather
than deleted; a hidden quest item's unsaved draft is archived in `questEditorDrafts`.

A verified final consumption uses the enabled Last Item pool instead of a regular
line. One use produces at most one message. The shared cooldown defaults to 30
seconds; the reusable Hearthstone also keeps an independent 120-second throttle
and only announces at cast start, never arrival.

## Installing and testing

1. Back up per-character SavedVariables, then extract the `ForeverRP` folder from
   the appropriate client ZIP into `Interface/AddOns/`.
2. Run `/reload` and `/frp config`. Newly discovered items remain OFF.
3. Enable a test item, choose a group setting and join a group.
4. Use the item. No `/frp send` or manual chat confirmation is required.

Useful commands:

- `/frp config`, `/frp scan`, `/frp status`, `/frp compat`
- `/frp auto on` or `/frp auto off` (local preview only when disabled)
- `/frp groups groups|dungeons|raids|disabled` (choose one value)
- `/frp cooldown 0|15|30|60|120`, `/frp debug on|off`, `/frp preview`

The four group settings replace the old scope controls. Migration is additive:
old `always`/`group` becomes Groups, `instance` becomes Dungeons, and `off` becomes
Disabled. Per-item overrides follow the same mapping; choosing inheritance later
is not overwritten on reload. Explicit new policy choices, timestamps, text
arrays, category opt-outs, item enablement and minimap preferences survive.

## Preserved local-chat code and data

The local `/me` and `/say` send implementations and manual-draft support remain
in code for future client support. They are dormant in the active product path:
old `outputMode`, `chatDestination`, manual flags and legacy scopes are retained
but do not select the active transport or phrase style. No migration copies action
text into speech pools. Existing German arrays retain their content; selecting German now uses its speech pools. An unsaved legacy
action-editor draft is archived in `legacyEditorDrafts`; a speech draft is restored
in the editor, including invalid text that must be corrected or discarded.

## Shared food/drink use spells

Passive secure post-hooks observe explicit bag-slot, item-ID or item action-slot
use calls. When carried foods share a spell, this extra identity can resolve the
candidate only alongside spell success and a matching item-count decrease within
three seconds. Hooks never use items or send chat. Missing, restricted, stale or
conflicting identity remains suppressed. Macro/action routes exposing only a
spell may still be ambiguous; real-client hook coverage requires verification.

## Development

`ForeverRP/` is the canonical source for both clients. Package with Python 3.9+:

```shell
python3 tools/package.py --version 0.10.0
```

The script writes Retail (`120105`) and Forever (`16001`) ZIPs to `dist/`, changing
only client/version metadata. GitHub Actions checks Lua syntax, runs all mock
suites under Lua 5.1/5.4 and builds both packages. Release uploads are also gated
on syntax and mock checks. Generated packages are not committed.

WoW and its names are trademarks of their owners. This unofficial fan addon is
not affiliated with or endorsed by Blizzard Entertainment.
