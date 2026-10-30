# Automatic RP library (planned 0.9.18 feature; source version unchanged)

Defaults are immutable source entries, resolved by category, language, Regular/Last
Item and /me-/say. They are never copied into new item settings. Existing sample
modules remain available as historical reference. The frozen registry covers their
complete public library; revised Healthstone wording retains `legacyText` aliases.
IDs are explicit literals: do not renumber, reuse or derive them from runtime array
positions. Text edits retain the ID and, when needed, a historical migration alias.

## Race selection

`UnitRace("player")` is guarded by pcall and secret-value checks. The stable
FileString is mandatory. If an ID is supplied it must agree with the known Retail
mapping; unknown/custom IDs, unknown FileStrings, mismatches and missing/throwing
APIs give general templates only. No localized race-name guessing, faction guessing,
manual racial selector or numeric-only fallback exists. No Forever-specific ID is
assumed. Recognized races without authored templates also use general templates.
The Blizzard API definition is mirrored in
[UnitDocumentation.lua](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/UnitDocumentation.lua).

Authored English pools cover Forsaken (`Scourge`), Dwarf, Gnome, Orc, Troll, Tauren,
Human and Night Elf. Gnome uses teal; each complete racial phrase carries its subtle
race color; general phrases are white. The original race pack has two entries per race/category/pool. Additive editorial
entries extend selected pools, with extra attention to elixirs; see the
[writing guide](rp-writing-guide.md) and [full count matrix](rp-variety-report.md). Hearthstone has
no Last Item defaults. Old explicitly undead/Lordaeron flavor is restricted to
Scourge, including dormant German templates. Healthstones describe breaking fel
stones; no charge support or change to consumption confirmation is introduced.

## Selection and controls

Both RP tabs and /me-/say subtabs remain. The main text area contains only
read-only default phrases in one scrollable list, without section headers or
collapsible groups. Every default starts ON (active); switching its compact status button OFF disables it
across every item in that category/pool via `ForeverRPDB.defaultDisabled[stableID]`.
Existing opt-outs remain OFF. General phrases are white and racial phrases
use their race color. Phrases wrap rather than being truncated; hover also shows
an item-expanded preview. Counts reflect the effective current pool.

**Edit custom phrases** opens a separate movable window with its own Regular/Last
Item and /me-/say tabs, context title, multiline custom editor, local preview and
**Edit preserved matches as own texts** recovery. The native EditBox fills the writing viewport; left-clicking below the last line
places the caret at the end. Text placement/drag selection remain native, without
a mouse-forwarding overlay. Buttons and scrollbar are outside that hit rectangle.
It never sends chat. Valid edits
save after 0.7 seconds, on blur, close, context switch and PLAYER_LOGOUT. Invalid
input blocks item/tab/channel switches; closing offers explicit discard or keep
editing. Clients without confirmation support keep the editor open. The main
window and custom editor have independent visibility.

The additive `ForeverRPDB.editorDraft` stores the current item, tab, channel and
raw text immediately on editing. Invalid drafts survive reload and are restored
when configuration is next built, before another item can overwrite them. Saving
or explicitly discarding clears the draft; existing phrase arrays are changed
only after validation. Legacy data and selection weights are unchanged.

With both default sources available, the default source draw is 70% general and
30% matching race. With only one source, that source is used. Each custom phrase
receives one ticket against the combined number of eligible defaults; after the
default side wins, its 70:30 split applies. For example 30 general + 2 racial + 1
custom gives the custom 1/33 of draws. Custom text identical to an active default
appears once, as explicitly owned custom text. Shuffles are maintained separately
for each item/pool/source and invalidate on membership changes. No-repeat is kept
when alternatives exist. If a user reduces a source to one phrase and it was just
used, another available source takes precedence over the weighted draw; with only
one total phrase repetition is unavoidable. Empty means no send, no fallback and
no cooldown expenditure. There is no cross-language fallback to English.

## Non-destructive migration and unavoidable ambiguity

The old addon stored imported sample strings and user-authored strings in the same
arrays with **no provenance**. A deliberately identical own phrase cannot be
reliably distinguished from an import. The migration does not claim otherwise.

- The original arrays, numeric item IDs and all existing settings remain stored.
  Initialization adds only `librarySchema=1`, `libraryLegacyEmpty` and the global
  disable map. No phrases are rewritten/deleted during initialization.
- Exact known historical library strings (including aliases) are treated as
  library matches at runtime and hidden from the custom editor. They cannot
  duplicate defaults or evade default disables. Matching spans old categories so
  changing an item's category cannot turn imports into ungoverned custom texts.
- Altered/custom phrases are eligible as per-item text. Saving the custom editor
  keeps unclaimed historical matches in the original saved array. Intentionally
  removed, explicitly owned custom texts remain deletable.
- **Edit preserved matches as own texts** loads the retained strings for review.
  The action marks a draft; ordinary validated autosave/blur/item switch claims
  entered matching strings in `libraryCustom[field][text]=true`. Those deliberate
  own texts then operate independently of default disables. Invalid drafts remain
  subject to the existing validation/discard behavior. Merely opening the addon
  never claims ownership.
- Existing table pools with zero valid phrases, including empty/blank/invalid-only
  pools, retain their no-output behavior via `libraryLegacyEmpty[field]`. The UI
  offers an explicit per-item/pool action to enable defaults. New inventory items
  carry the schema marker from creation so reload cannot mistake their initially
  empty custom editor for an old opt-out.
- Previously deleted individual sample strings cannot be inferred as historical
  opt-outs from a partially filled old array: imports might simply have been
  selective. No automatic global disable is invented from absence. Existing
  `defaultDisabled` flags remain untouched. This ambiguity and intentional-equal
  ownership recovery warrant leaving the feature PR open for migration review.
- German own text and stock arrays remain untouched and dormant under the existing
  English-only initialization. No English stock pool is fabricated for German.

Back up real SavedVariables before client trials. Downgrading retains the old
arrays (and ignores the additive metadata); it cannot reproduce the new central
library or disable behavior.

## Verification and remaining client work

Regression coverage: all three existing mock suites plus `tests/mock_library.lua`;
Gnome/Forsaken isolation, unknown/conflicting/secret race data, stable IDs/reordering,
exact deterministic 70:30, category-wide disables across Potion IDs, custom ownership,
legacy aliases/retention, all-disabled no-send, empty/malformed pools, reload/new
items, DE preservation, UI collapse/autosave/tab-channel switches and invalid drafts.
Build and release workflows include the fourth suite; no release is created here.

Real Retail/Forever UI, client race FileStrings/IDs, item events, restricted API
behavior and external /me-/say delivery have **not** been tested. Existing scanner,
Healthstone charge limitations, three-second correlation, shared cooldown,
Hearthstone cast-start/120-second throttle and chat-lockdown rules remain in force.
The PR records the actual local, independent-review and Actions results.

New editorial entries set `migrationMatch=false`: adding a newly authored default
must not retroactively classify an identical existing custom phrase as a legacy
import. Frozen historical aliases still participate in conservative migration.
