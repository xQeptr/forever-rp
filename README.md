# Forever RP – Eternal Ink

**Forever RP** is an unofficial World of Warcraft roleplay addon for item-use emotes.
It can announce confirmed consumption of food, drinks, potions and healthstones,
and handles the Hearthstone separately. It offers random `/me` and `/say` lines,
Last Item RP, category-specific English sample templates and per-character settings.

## Status

Current development build: **0.9.17**, Retail **beta**, WoW Forever **preview**.
Healthstone charge-only uses (unchanged stack count) are not confirmed: no
charge-count API semantics have been verified on either target client. Do not
assume every Healthstone use is announced or that Last Item means last charge.
Before enabling charge support, record client/build, carried stack counts,
remaining uses (including bank/includeUses API behavior), and spell/bag event
ordering for 3->2->1->0 uses on both clients. No charge API is inferred here.
The concrete per-client test checklist is tracked in [issue #4](https://github.com/xQeptr/forever-rp/issues/4).

Real `/say` delivery and item behavior on WoW Forever have not yet been tested.
Automatic chat may be limited by Blizzard's client restrictions. Do not assume
messages were delivered to another player unless you have tested this.

## Installing

1. Download the correct zip for Retail or Forever from GitHub Actions artifacts
   or a published GitHub Release.
2. Extract the `ForeverRP` folder into the client's `Interface/AddOns/` directory.
3. In game, use `/frp config` to open the configuration.

Your saved phrases are stored in per-character SavedVariables. Replacing the addon
folder does not reset them. Back them up before testing a new version.

## Development

The canonical source is in [`ForeverRP/`](ForeverRP/). Both client packages are
built from the same source; the build script changes **only** the TOC interface
and version metadata for each flavor.

```shell
python3 tools/package.py --version 0.9.17
```

Two self-contained installable archives appear in `dist/`. Pull requests and
pushes run Lua syntax checks, simulated UI/event tests and a package build.
Publish a GitHub Release tagged `v1.0.0` to attach both flavor ZIPs.

## Roadmap before v1.0

- Real client tests on WoW Forever, especially `/say` and healthstones.
- Test Last Item replacement, shared cooldown, alcohol interactions.
- Review in-game UI, icon visibility and editor error popup behavior.
- Decide an explicit license and provide screenshots and changelog.

## Attribution

WoW and its names are trademarks of their owners. This project is an unofficial
fan-made addon, not affiliated with or endorsed by Blizzard Entertainment.
