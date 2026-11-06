# Changelog

## 0.10.0
- Add Automatic / English / Deutsch selection in the header and `/frp language auto|en|de`; Automatic follows the game locale (deDE German, otherwise English).
- Translate the configuration, validation, menus and common feedback into German; switch immediately without changing chat transport.
- Add 966 independently authored German group speech lines: 192 general, 432 class and 342 racial, with Last Item lines and Hearthstone departures.
- Preserve separate custom pools and stable opt-outs in both languages; save valid edits before switching, block invalid switches and retain language-tagged drafts across locale changes.
- Keep shared cooldowns and saved player data across language switches; package Unicode text explicitly as UTF-8.
- Add bilingual UI, locale/migration/draft, active group-send, German text-quality and 50/30/20 regressions. Real-client locale/layout and recipient delivery remain unverified.
- Hide quest tools/quest-associated items from scans, remembered lists and active sends using guarded quest, class and binding metadata; preserve saved data and archived invalid drafts.
- Add 955 original race/class speech lines (603 class, 352 racial) with category-specific regular and Last Item dialogue.
- Choose eligible default sources at 50/30/20 before phrase selection; preserve shuffle/no-repeat across items, proportional fallback and custom-text tickets, and show active source counts/weights.
- Focus the active addon on automatic group speech, with Groups (all), Dungeons, Raids and Disabled policies; detect PARTY/RAID/INSTANCE_CHAT and suppress solo/PvP contexts.
- Remove action/speech mode and channel controls; keep legacy local send code, phrase pools, modes and scopes dormant and preserve unsaved legacy drafts.
- Add 192 category-specific English speech lines, including 72 Last Item lines and 12 Hearthstone departures.
- Correlate shared-spell consumables with passively observed bag/action/item-use identity, while still requiring spell success and a matching stock decrease within three seconds.
- Default automatic RP to PARTY/RAID/INSTANCE_CHAT, with no solo send; retain local chat as an explicit alternative and preserve phrase pools and saved preferences.
- Add opt-in manual chat confirmation (`/frp manual on`, `/frp send`) for clients blocking automatic RP chat; opening a draft never sends or spends cooldown.
- Add regression checks for manual drafts, scope/channel guards, expiration and own-echo cooldown tracking.

## v0.9.21-beta (pre-release)
- Add Skyborne defaults with silver-blue text and Skyborne/Skybourne FileString detection, without guessing a numeric race ID.
- Add nine class-specific phrase pools in class colors and 380 new identity phrases.
- Select eligible default sources with nominal 50/30/20 general/race/class weighting; no-repeat rules can affect observed proportions.
- Show the loaded addon version dynamically and remove Eternal Ink from current UI/README labeling.
- Add identity regression coverage to Lua 5.1/5.4 CI and release validation.
- Preserve existing phrase IDs, custom texts, opt-outs, consumption rules and cooldowns.
- Retail remains beta and Forever preview; real-client checks and Healthstone charges remain unverified.

## v0.9.20-beta (pre-release)
- Fill the custom writing viewport with the native EditBox; focus blank clicks at text end while preserving native selection and scrolling.
- Use compact ON/OFF controls for default phrases, preserving category opt-outs and restoring source colors on reused rows.
- Add 188 original category/race phrases, with extra elixir variety; freeze all 1,968 historical entries and keep coincidentally identical existing custom text independent.
- Document lore sources, editorial limitations and reproducible variety metrics; add focused byte-budget, grammar, identity and migration regressions.
- Move custom phrases into an independent editor; show wrapping defaults without headers, with active checkboxes and whole-phrase race colors.
- Preserve invalid editor drafts across reload; flush valid edits on logout and keep per-pool contexts explicit.
- Fix library-hover tooltip crashes caused by passing the substitution count as a native color argument; reset reused opt-out row colors.
- Replace manual sample imports with shared read-only default pools and category-wide disable flags.
- Automatically select matching racial English pools, including Gnome; unknown or conflicting race data uses neutral defaults.
- Preserve legacy arrays and effective-empty opt-outs; add explicit ownership recovery for ambiguous historical sample matches.
- Add migration/race/selection regressions and document remaining client verification.
- Seed missing Last Item pools immediately when changing output mode.
- Invalidate pending casts when delayed bag scans reveal shared-spell ambiguity.
- Guard optional item-class metadata during Hearthstone and known-item scans.
- Reject empty/whitespace saved phrases before channel selection without changing original pools or spending cooldown.
- Fix scanner metadata gaps, reject shared-spell ambiguity and invalidate removals on stock gains (issue #2).
- Guard restricted cast values, quarantine malformed settings and ignore invalid phrases without deleting originals.
- Seed missing Last Item pools for the output mode and validate template imports.
- Gate release uploads on syntax and simulations; add real scanner regressions.
- Document unverified Healthstone charges and required client tests.

## v0.9.17
- Scroll the multiline text editor to the caret after typing or pressing Enter at the end of the list.
- Reset the text editor scroll position when selecting another item or text pool.


## 0.9.16 – Editor validation
- `{item}` is optional; literal line breaks separate phrases.
- Line-numbered validation errors and a check of the resolved chat message length.
- Confirmation before discarding invalid unsaved text.
- Item icons render above row selection and hover highlights.
- Existing texts and consumption behavior preserved.

## 0.9.15 – Quality of life
- Auto-saving editor, quick ON/OFF per item, Last Item opt-out.
- Alcohol sample templates and rounded UI corners.

## 0.9.14 – Eternal Ink interface
- Restyled panels, native-looking tabs and persistent inventory list.
