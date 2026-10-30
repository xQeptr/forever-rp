# Editor UX follow-up: rationale and client acceptance

PR #6 was already merged when this follow-up began. Changes build on its merged
main commit, retaining its stable defaults, migrations and tooltip single-return
fix. No version, target interface or release change is part of this work.

## Focus diagnosis and design

The multiline ScrollChild previously had no explicit top-left anchor and a
96-pixel minimum height inside a roughly 261-pixel viewport. Its hit rectangle
did not reliably cover the visible writing area. A click-forwarding overlay
would compete with native selection. Instead the native EditBox explicitly
anchors at the viewport origin, uses its width and at least its height, and
grows with measured wrapped text. A hidden FontString with the same font and
width measures text; no unsupported EditBox GetStringHeight call is assumed.

A mouse-down hook preserves native placement on text lines and moves the caret
to the end only below the measured final line. Coordinates account for effective
UI scale and the scrolled child's top. The scrollbar, tabs and buttons remain
outside the EditBox. No delayed focus or chat action is introduced.

## Consistent activation

Defaults use a 34-by-24 ON/OFF segment, following the existing inventory status
control. This keeps the established meaning and a useful target larger than a
small checkmark. Labels communicate state independently of color. OFF phrases
are gray; ON restores full general/racial color. The text retains 568 pixels and
wraps rather than truncating. Hover previews remain available. Only the compact
status segment toggles; the row's text does not become a large invisible switch.
Rows are reused, with entry/state/color rebound on every refresh. Stored IDs
still specify category, channel and Regular/Last context; they are not item flags.

## Evidence and required game checks

Strict simulations exercise left/middle/right and blank-area focus, native-line
caret preservation, scroll offsets, UI scale, wrapped/long/empty text, viewport
resize, autosave, context changes, invalid drafts and reload opt-outs. They model
hit testing and do not run Blizzard's native input/layout engine. In particular,
actual HookScript timing, drag selection, scrollbar capture and font metrics
still need client confirmation. No Retail or Forever executable was tested here.

Before testing, back up real per-character SavedVariables. Record client/build
and `/frp compat` plus `/frp status` separately for Retail and Forever:

1. Select Morvain's item 3382 and open the separate custom editor. Click left,
   center and right on a line, then below the final line. Type at each caret;
   the blank-area click should append. Repeat with an empty pool.
2. Drag-select across wrapped lines, Shift-click, scroll a long draft with wheel
   and scrollbar, and repeat at different UI scales. Click buttons and tabs;
   none should insert a caret or start a window drag in the writing region.
3. Verify autosave, item/channel/Regular/Last switches and reload. Invalid text
   must stay recoverable, rather than replacing saved valid phrases.
4. Switch one elixir default OFF, inspect another elixir, then a potion. Only
   that elixir/context/channel/ID is disabled. Reload, then restore ON; confirm
   race color returns. Check long text wrapping, hover and reused rows.
5. Inspect Forsaken elixir additions and General/racial color separation. With
   auto disabled, local preview must send no chat. Verify scopes and reload
   persistence before observing automatic output with a second player.
6. Retain the existing consumption/interruption/cooldown/Hearthstone and external
   /me-/say checks. A local API acceptance or own echo is not delivery evidence.

Keep the follow-up PR Draft until explicit real-client acceptance. No merge or
release is authorized by these checks alone.
