# Changelog

## Unreleased
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
