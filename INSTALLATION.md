# Installation

## OMNOM

- Install OMNOM-0.0.1 archive like any other mod

### Optional Patches

These are strictly optional and most of them are just things I did in my personal setup. Sharing them in case they are useful, install like any other mod if you decide to use them:

- **Patch 1**: If you run "O.S.H.I.T", this simply removes the impact framework configuration, so you can't accidentally turn mimics into a bag of gold and make your loot unattainable. You can still end up killing them with Bakas default behavior, though.

- **Patch 2**: Mimic mesh that (hopefully) gets rid of the "invisible" chest bug, which seems to be plaguing TNTR mimics. (I changed the "skinned" shaders, which fixed it for me, not sure if it works for everyone. Please let me know if that fixed it to you, I can report it to Baka, I think he has been trying to fix this bug for some time)

- **Patch 3**: A patch for the default **clutter/LargeChest.nif**, to get rid of small shader differences. This worked for my specific ENB configuration. Let me know if it worked for you.

- **Path 4**: Renames "Mimic Trap" to "Chest" and changes the activation text from "Open" to "Search" so it matches vanilla chests exactly.

## Installing TNTR

Follow the regular NTR instructions:

- Needs to be v0.73 specifically
- Use with QTE-Minigame
- Make some challenging presets for the QTE-Game (unless you hate fun)
- Please read about known bugs and issues below

## Configuration

I tried to do sensible defaults, so changing these should hopefully not be necessary. 

Mimics are somewhat common but not too common to be intrusive.

- If you want to customize it (and spoiler yourself), check the json files in `SKSE\Plugins\MimicPlacer`
    * `Consequences.json` - Things that happen when you get trapped
    * `Distribution.json` - Control probability and "type" of mimics. 
    * `Settings.json` - General settings, mostly used for debugging
    * `BakaMimics.json` - You probably won't need it. Contains base forms of the baka traps and adds options to add foreign form ids from mods that add new baka traps (like the snowy chest from O.S.H.I.T)


## Uninstalling the mod

You won't be able to uninstall this easily (for now). 

- If you remove this mod, BEST CASE you will have some broken Mimics scattered in your dungeons and chests you won't be able to access.
- You can try to set dump-mimics=1.0 to coc into the cell of all mimics, and use the debug spell to destroy them.


### Consequnces.json

```
    "mimic-vore-bad-end": 1,
    "mimic-vore-bad-end-min-ticks": 11,
    "mimic-vore-bad-end-simple-slavery": 0
```

Default Behavior: Vore Traps will kill you if you fail all 3 escape games. If you want simple slavery instead, set "mimic-vore-bad-end-simple-slavery" to 1 and leave "mimic-vore-bad-end" on 1.


```
    "mimic-loot": 1
```

Set to 0 if you don't want to be able to retrieve loot from mimics.
    
```
    "mimic-loot-max-item-count": 2,
    "mimic-loot-max-gold-count": 20,
```

How much gold/items can be retrieved from the mimc.

```
    "mimic-loot-chance-per-tick": 0.05
    "mimic-loot-chance-accumulates": 1,
```

The chance to retrieve loot.

### Distribution.json

```
"debug-dump-mimics": 0
```

Setting this to 1 will dump a list of all existing mimics (and their cells/positions) whenever a new mimic is created.

```
    "scan-radius": 10000.0,
    "scan-radius-outside": 20000.0, 
    "scan-interval": 30.0,
```

Changes how/when the detector looks for chests to turn into mimics.

```
    "mimic-chance": 0.28,      
    "mimic-weight-vore": 30.0,
    "mimic-weight-sex": 60.0,
    "mimic-weight-instant": 30.0
```

Change the base chance for mimics (default 28%) and the weighting for the different vore types.