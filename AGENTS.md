# Codex instructions for Forever RP

Applies to the entire repository. Keep changes focused on the requested task; preserve existing player data and RP behavior unless a behavior change is explicitly requested.

## Project map
- `ForeverRP/` is the canonical addon source shared by both clients.
- `ForeverRP/ForeverRP.toc` defines metadata, per-character SavedVariables and Lua load order. Core loads first; preserve dependencies when adding modules.
- `Core.lua`: initialization, defaults, slash commands and event routing.
- `Compat.lua`: read-only capability diagnostics. `Inventory.lua`: bag scanning, cast/decrement correlation and Hearthstone handling.
- `Categories.lua` and the sample modules: classification and phrase libraries. `Scopes.lua`: context permissions. `Emotes.lua`: phrase validation, selection, chat and throttling.
- `Config.lua` and `Minimap.lua`: editor/UI. `Media/`: packaged artwork.
- `tests/mock_ui.lua`, `tests/mock_events.lua`: standalone WoW simulations.
- `tools/package.py`: dual-client ZIP packaging. `.github/workflows/build.yml` checks and packages; `release.yml` attaches packages to published releases.
- Read `README.md`, `CHANGELOG.md` and relevant modules before editing. No external addon libraries are currently required.

## Retail and Forever builds
- Use one source tree; do not maintain divergent copies of addon logic.
- Current package targets: Retail interface `120105`, suffix `retail-beta`; Forever interface `16001`, suffix `forever-preview`. These are repository targets, not proof of runtime compatibility.
- Run `python3 tools/package.py --version 0.9.17` from the repository root (or the explicitly requested release version; Python 3.9+). It writes both archives to `dist/`.
- Packaging rewrites TOC Interface/Version and `A.version` in packaged Core.lua. Other source behavior must stay identical across flavors. Each archive must contain `ForeverRP/ForeverRP.toc` at the installable folder level.
- Do not commit generated ZIPs, change interface numbers, bump versions or publish releases as an incidental part of a fix.
- Forever is a Mainline-architecture candidate, not automatically a Classic API target. Verify capabilities and actual client behavior; keep beta/preview and unverified-delivery wording accurate.

## SavedVariables compatibility
- Preserve `## SavedVariablesPerCharacter: ForeverRPDB`, addon folder/name and numeric item-ID keys in `db.items`.
- Make migrations additive, type-checked and idempotent. Fill missing defaults without overwriting explicit false values, custom phrases, category overrides, scopes, output modes or minimap preferences.
- Keep legacy English /me phrases in `cfg.lines`; preserve `sayLines`, `deMeLines`, `deSayLines` and stock pools `outMeLines`, `outSayLines`, `outDeMeLines`, `outDeSayLines`. Dormant German data must survive the current English-only initialization.
- Newly discovered items stay OFF. Existing enabled consumables default Last Item ON only when unset; preserve explicit opt-outs. Hearthstone has Last Item OFF.
- Preserve persisted cooldown timestamps. Do not reset user data to solve a migration problem. Exercise old, missing and explicitly disabled settings in migration tests; back up real SavedVariables before client testing.

## Lua and WoW API care
- Match existing module style (`local A=ForeverRP`); avoid new globals except deliberate WoW entry points. Avoid language/library features unsupported by either target client even if Lua 5.4 CI accepts them.
- Guard optional APIs and handle nil/uncached item information. Prefer capability checks over assuming a client from its interface number.
- Respect combat lockdown, restricted/secret values and hardware-event requirements. Do not bypass protected actions, automate item use/combat or add insecure hooks to force chat.
- Keep diagnostics read-only and event handlers bounded. Preserve cast GUID deduplication and event-order handling. UI/config changes must not consume items or send chat.
- Never equate a successful API call or own chat echo with delivery to other players. Mocks cannot establish client compatibility.

## RP, consumption and cooldown invariants
- Announce consumables only after matching player spell success AND a corresponding item-count decrease within the existing 3-second correlation window, in either event order.
- Bag movement, sale, trade, destruction or spell success alone must not announce consumption. Ambiguous items sharing a spell must not produce a guessed announcement. Count all equipped bags/stacks; do not scan bank/warbank as carried stock.
- A verified final consumption with remaining count zero may use the enabled Last Item pool; it REPLACES the regular line. Send at most one message per use.
- Hearthstone (item 6948) is reusable: announce the attempted departure at cast START, never on arrival or again at success. Cancellation cannot retract chat or reset its independent 120-second throttle.
- Preserve the shared persisted cooldown across item IDs, regular/Last Item output, channels and Hearthstone. Default 30 seconds; allowed settings 0/15/30/60/120. Setting zero must not remove the independent Hearthstone throttle.
- Update send timestamps only after the chat API accepts the attempt; do not consume cooldown for rejected, disabled, invalid or scope-suppressed output. Do not queue delayed chat to evade cooldowns.
- Respect auto mode, per-item enablement, output mode and effective scope (`always/group/instance/off`). Scope is an eligibility rule, not a request to change the chat destination.
- /me uses EMOTE; /say uses SAY. Mixed selects one eligible channel, not both. Preserve the outdoor automatic-/say guard and never silently substitute /me for a /say-only choice.
- Keep local preview behavior when automatic output is disabled and the chat-lockdown checks. Report blocked/unverified sends honestly.
- Preserve newline-separated phrase pools, shuffle/no-immediate-repeat behavior, optional `{item}`, genuine item hyperlinks when required, and rejection of pasted hyperlinks. Current limits: 100 phrases per pool, 200 bytes per phrase, 255 bytes after expansion. Validate before replacing saved phrases.

## Verification
Run relevant checks from the repository root. CI currently uses Lua 5.4:
- Syntax: `find ForeverRP -name '*.lua' -print0 | xargs -0 -n1 luac5.4 -p` on Linux; on Windows invoke an available equivalent `luac -p` once per Lua file.
- UI simulation: `lua5.4 tests/mock_ui.lua`.
- Event simulation: `lua5.4 tests/mock_events.lua`.
- Both packages: `python3 tools/package.py --version 0.9.17`; inspect archive paths and flavor metadata. A locally installed Lua executable may be named `lua`.
- Add focused regression cases for changed behavior, especially migrations, event order, false consumption, Last Item replacement, cross-item cooldowns and Hearthstone interruptions. For UI changes cover autosave, item/tab/channel switches and invalid-draft preservation.
- For documentation-only changes inspect the diff, paths and commands; do not invent test results or add tests that merely restate documentation.
- When runtime behavior changes, manually verify both clients with `/frp compat`, `/frp status`, scopes, reload persistence, interruption and a second player's observation of /me and /say. Record client/build and what remains untested. Existing README explicitly leaves real /say delivery and Forever item behavior unverified.

## Git and pull requests
- Inspect status/diff before editing; preserve unrelated user changes. Work on a focused new branch when possible, never force-push or reset the user's checkout.
- Stage only intended files, inspect the staged diff and whitespace, and use a descriptive commit message. Keep documentation-only tasks free of functional/version changes.
- Open a PR against `main` when requested/authorized; describe the concrete result, scope, validation actually performed and client-test limitations. Do not merge or publish a release without a request.
- Treat GitHub Actions as required validation evidence when available; distinguish pending, failed and passed checks. Never claim mocks prove external chat delivery.
