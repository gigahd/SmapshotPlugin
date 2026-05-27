# Smapshot Plugin

A Roblox Studio plugin for saving and loading maps as portable snapshots — capture your map once, then load it into any place, either from a snapshot saved in your game or directly from a Roblox asset id at runtime.

The plugin gives you a GUI for everything the Smapshot package can do, so you don't need to write code to capture and restore maps.

## Installation

Install from the [Roblox Creator Store](https://create.roblox.com/store/asset/109345457910746/Smapshot). The plugin will appear in your Plugins toolbar in Studio.

## Usage

Open the **Smapshot** panel from the Plugins toolbar. The panel is a visual editor for the same config object the [`Smapshot.Snapshot`](https://gigahd.github.io/Smapshot/api/Smapshot#Snapshot) function takes — every field you'd pass in code has a control in the UI.

### Saving a snapshot

1. Open the Smapshot panel.
2. Toggle on the subsystems you want to capture (terrain, lighting, workspace, sound, materials, instances). Each subsystem expands to show its options — whitelists, blacklists, region slicing, camera capture, and so on. Leave a subsystem off to skip it entirely.
3. Set a name for the snapshot and your Snapshots will be saved in a Smapshot Folder inside of `ServerStorage`.
4. Click **Save Snapshot**. The plugin calls `Smapshot.Snapshot` with your config.

You can then publish the snapshot folder as a Roblox asset if you want to load it dynamically via `LoadAssetAsync` at runtime.

### Loading a snapshot

1. Select an existing snapshot `Folder` in the Explorer, or enter a Roblox asset id.
2. Choose load options: **consume** (reparent instead of clone, faster but one-shot) and **keep dirty** (additively layer onto existing state instead of clearing).
3. Click **Load** — the plugin calls `Smapshot.Load` (for a selected folder) or `Smapshot.LoadAssetAsync` (for an asset id) with your options.

### Installing the package into your place

If you want to call Smapshot from your own scripts at runtime, click **Install Package** in the panel. The plugin drops the Smapshot module into `ReplicatedStorage`, ready to `require`.

## What gets captured

Smapshot can capture any combination of:

- Terrain (full or sliced to a region)
- Lighting (properties, effects, atmospheres, skies)
- Workspace (parts, models, optionally the camera CFrame)
- SoundService (music, ambient sounds)
- MaterialService (material variants)
- Arbitrary instances anywhere in the DataModel

Each subsystem supports whitelist/blacklist filtering so you can capture exactly what you want.

## Using the package directly

If you'd rather write code than use the GUI, the underlying Smapshot package is available via [Wally](https://wally.run/package/gigahd/smapshot), [Pesde](https://pesde.dev/packages/gigahd/smapshot), or [source on GitHub](https://github.com/gigahd/Smapshot).

See the [API reference](https://gigahd.github.io/Smapshot/api/Smapshot) for full details.
