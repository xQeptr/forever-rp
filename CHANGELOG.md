# Changelog

## Unreleased
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
