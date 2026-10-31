Forever RP v0.9.20-beta — pre-release test build

- New automatic general/race-specific RP phrase library with 70/30 weighting,
  category-wide ON/OFF toggles and separate custom-text editor.
- Improved editor click focus and consistent ON/OFF controls.
- 188 additional editorial RP lines, for a total of 2,156 defaults.
- Retail beta and WoW Forever preview builds use the same Lua source.
- Existing per-character saved settings and custom phrases should remain intact.
  Back up SavedVariables before testing.
- Healthstone charge-only use, real Forever APIs and external chat delivery still
  need client verification. This is NOT a stable release.

Forever RP v0.9.15 — Eternal Ink quality-of-life polish

- Config text editor automatically saves valid phrases after 0.7 s without typing,
  on blur or when switching items/tabs/channels. No redundant Save Changes button.
  Invalid phrases (e.g. missing {item}) are NOT saved until corrected.
- ON/OFF is directly clickable at the start of each inventory row. Separate
  Enable RP checkbox has been removed from the details pane.
- Last Item RP automatically defaults ON when an item becomes enabled, except for
  the reusable Hearthstone. Explicit per-item opt-outs are preserved, including
  for previously saved settings. Previously enabled items without a Last Item
  preference get the new default, without overwriting customized phrases.
- Missing last-item /me and /say pools get initial stock samples independently.
- Alcohol has a separate set of 30 lightly humorous English /me and 30 /say
  regular templates; previous saved phrases are NOT overwritten. Items stay
  disabled until you opt in, avoiding unexpected extra drunk messages from WoW.
- Transparent, rounded frame corners within the Eternal Ink gold edging.
- The consumable confirmation, hearthstone and global chat throttling logic
  remain unchanged. WoW Forever /say behavior remains unverified in client.
- WoW SavedVariables are written to disk by the WoW client on reload/logout.

/frp config — open configuration

Unpack ForeverRP directly into Interface/AddOns/ForeverRP.
Do not delete your existing SavedVariables file when upgrading.

Changes in v0.9.17:
- Optional {item} placeholder: a text without it is sent verbatim.
- Each literal newline (Enter) starts a new phrase, soft wrapping does not.
- Line-numbered errors for oversized phrases, too many phrases or pasted WoW item links.
- Chat length validated using a genuine current item hyperlink when available,
  and rechecked against WoW's 255-byte limit before any attempted message.
- On closing with invalid unsaved text: native confirmation to discard or keep editing.
- Item icons draw above inventory-row selected/hover backgrounds.
- No changes to consumable confirmation, throttling or SavedVariables fields.
