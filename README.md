# OMNOMS: Not (so) Obvious Mimics for Skyrim

Dynamically replaces chests with Mimics from Bakas outstanding [Traps NTR](https://www.nexusmods.com/skyrimspecialedition/mods/107836) asset mod. 

THIS IS SOME EARLY PREVIEW USE AT YOUR OWN RISK.

If you have a good acronym please DM.

## Features

- Mimics will randomly replace vanilla in-game containers. 
    * No more "I've never seen this chest before, its obviously fishy" moments, Mimics will catch you by surprise!
    * Mimic placement is stored in your save and will not change when re-entering cell
- Bad End or SS+ outcome for "Vore" Mimics
- Outcomes for getting trapped
    - Very basic mechanism that just observes the duration of the encounter from the outside, and then rolls for consequences.
    - Chance to loot items from the original chest
        * Longer duration means higher chance to loot things
    - Bad End: Vore Traps can actually kill you character
        * Longer duration means higher chance to trigger "bad end"
        * Death Alternative: Good ol' Simple Slavery. Nearby NPCs "notice" you being trapped and take advantage of that. 
- ESL-flagged esp

## Requirements

*Hard Requirements:*
- [Traps NTR](https://www.nexusmods.com/skyrimspecialedition/mods/107836) **v0.73 only** - I did not test any other version.
- [PO3s Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854)
- [Papyrus Utils AE/SE](https://www.nexusmods.com/skyrimspecialedition/mods/13048)

*Soft Requirements:*

- SS+ for Simple Slavery Outcome
- TNTR Optional Requirements: Inflation Frameworks like FillHerUp to make use of the vanilla TNTR Cum Inflation features (as an additional spice/punishment/effect)

## Important

- This will permanently change your in-game world, replace chests with mimics, etc.
- If you really decide to use this WORK IN PROGRESS in some playthrough, you will not be able to remove it easily, even if something is dysfunctional or I change it up in future versions
- Dynamic placement of baka chests only works with some tricks and custom scripts (needs external x-markers that are referenced to the mimic object etc.), so once you uninstall this mods the placed mimics no longer work.

## Compatibility

- **FillHerUp (Baka)** - Some Issues - If you are inflated the "deflation" animation will interrupt the Baka Trap Animation and cause no more consequences to be triggered. This already breaks vanilla TNTR, but I just included it here for completeness.
- **O-SHIT** - Works, but it is advised to remove its "impact framework" config. otherwise, hitting Mimics will destroy them and make their container loot unatainnable. I've included a patch in the MO2 installer to do that for you!
- **Watch your Step** - Some Issues. Places a lot of sling traps right next to eligible chests, if you trigger both at the same time, animations will bug out. If you avoid that, you are perfectly fine.
- **Dang Its Mimics** - Appears to work, but it targets the same chests so the overall mimic chance will be higher than in the config. Chests replaced by Dang Its Mimics will not have their container loot available. 
- **Deviously Enchanted Chests** - Works. DEC operates on containers and Baka Mimics are plain activators.
- **Devious Devices** - Some Issues. TNTR Mimics will unequip devious devices and co-objects.

## FAQ

### A Mimic breaks my quest-progression

This shouldn't happen. Please make a bug-report, but to help you out right away do the follwing:

1. Load a Save before interacting with the chest (might only be necessary if you already "looted" the quest item)
2. Open console and type `help "destroy closest mimic"` to get the ID of the debug SPEL
3. Learn it: `player.addspell xxxD3815` 
4. Cast `Destroy closest mimic` in front of the offending mimic. This will remove the mimic and give you access to the underlying vanilla chest.

### Known Issues

#### OMNMON

- Upper limit of 128 boss chests per current cell. (Should never be an issue, unless you manually place 150 of them)
- Wearing certain devious devices can make the mimic activation slow or not work at all (no Idea why)

#### TNTR 0.73

There's some known issues with v0.73 of TNTR.

=> THESE ARE NOT CAUSED BY THIS MOD <=

- Mimics will unequip worn devious devices (and co-objects)
- "Vore" traps don't release or kill the player 
    * **Fix**: enable "bad-end" or "bad-end-simple-slavery" outcome for Vore Traps

- QTE text is permanently visible in the UI outside of qte-games
    * **Fix (maybe)**: after installting TNTR, save the game and reload it before you touch the MCM. After reload, do your settings. After that don't touch the MCM again.

- Chests are sometimes invisible
    * **Fix (maybe)** Try the patched file. Its most likely some shader issue that occus when applying the "skinned" shader to the vanilla large-container mesh. 

## Testing

If you want to test whether it works:

- `coc WarehouseTraps` contains vanilla chests that may get replaced. 
    - When you enter the room, chests will be turned into mimics based on current settings.
    - There are debug spells in the .esp that you can use to manually turn chests into mimics. 
    - You can use the debug spells to replace additional chests with mimics, or turn them back into chests, to look whats inside.
    - These containers will have coupled containers, so you can test the loot retrieval functions.
- `coc BakaTrapZone` Showcase of vanilla Baka Traps, the mimics DO NOT have a coupled container, so you won't be able to test the

## Notes for Modders

### How Outcomes Work

- I use a perk and `RegisterForAnimation` to observe mimic activation and player release.
- When that happens I dispatch a `Mimic_VoreStart` and `Mimic_VoreEnd` event
- The time between those events is used to calculate the severity of the outcomes

Please note that if you use BaseObjectSwapper to replace other containers their loot will be gone!

### How Mimic Placement Works

- I dynamically scan the environment for viable containers (OnCell load and in an interval)
- I store processed container prids in a list, so they aren't rolled/processed again.
- When a chest is replaced, I disable the container and place a "Mimic" at the same position


## Ideas - Not (yet?) implemented

I may eventually add an MCM, but its always such a pain to do and maintain

 * Support Mimics from other Mods (MadMansMimics, Chainbeasts etc.)
 * Equip Tentacle Parasite DD items
    * Lose/Drop items (and move them into the container, so you can try to 'recover' them)
    * Dissolving Gear/Gold
 * Estrus Chaurus Impregnation
 * Add cum overlays
 * Aphrodisiac - Chests add effect that increases OSA horniness for some time 
 * Mimic Fatique/Mind Break - Escaping becomes progressively easier/harder

### Backlog 

1. Mimics steal gear and or weapons (and move it into container)
2. Detailed distribution (based on chest type)
2. Lose/Drop Gold
3. Move config to global vars?