# Group speech client verification

Latest working changes: not yet verified in either real client. Local Lua tests
cannot prove chat permission or delivery. Keep Retail beta / Forever preview.

Prior user observations on Forever 1.60.1 build 70790: automatic local chat was
blocked; a manually confirmed local emote appeared; automatic group speech was
reported functional. No second-player delivery confirmation is recorded.

Before testing, back up real SavedVariables. For each target, record client/build,
`/frp compat`, `/frp status`, group context, actual channel and a second player's
observation. Test the following:

- Solo: no automatic output, even with Groups selected.
- Ordinary party, manual dungeon party, outdoor raid and instance-category group:
  Groups permits all; Dungeons/Raids filter the matching contexts; Disabled sends
  nothing. Battleground/arena contexts stay silent.
- Per-item setting and inheritance, including reload after clearing an old override.
- Enabled food and drinks sharing a spell, bag clicks and item action buttons,
  both spell/bag event orders, no accidental sale/trade/destruction announcements.
- Regular and final-item replacement; no doubled speech; Hearthstone start,
  interruption, success/arrival without duplicate, persisted independent throttle.
- Cross-item shared cooldown, all configured durations and reload persistence;
  rejected attempts must not spend cooldown or retry on another channel.
- Old action/speech/custom/German text and opt-outs preserved; action-only custom
  text does not become spoken dialogue. Invalid speech drafts survive switches
  and reload; invalid old action drafts remain archived.
- Editor displays speech only, no mode/channel choices; all four group policies
  fit and remain usable with different UI scales. UI/config clicks send no chat.

Do not infer remote delivery from API success or the player's own echo.
