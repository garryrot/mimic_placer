

# 1.3.0

- Overhaul of loot retrieval system
    - Adds mimic combat system: each hit can either cause a loot ejection or a whip attack 
        - NOTE: Requires patched mimic script
        - Whip attacks may initiate a regular struggle/devour minigame, which can end in the player being devoured. 
        - Chances may depend on various factors such as gear/actor values (See spoilers)
    - Legacy loot method (looting from within the mimic) is now default-disabled

- Fix the "Stolen Loot" Quest so it can be actually completed
    - If you upgrade and the quest is already running you must manually end it in Console with `CompleteQuest GR_MimicStolenQuest` command

- Overhaul of vore bad-end system (which was utterly broken)
    - NOTE: Requires patched mimic

- Optional patched Baka Mimic Chest that fixes various things in TNTR v0.7x 
    - Vore mimics no longer stuck forever and eject the player instead
    - Provide functionality for new combat system

# 0.0.3

- Preserve ObjectReferences when moving items to the player to not break certain quests (like Jorns Drum)
- Fix various loot-related configuration settings being ignored
- Increase default loot retrevial chance and increase default amount of maximum retrieved items to 3

# 0.0.2

- Ignore chests that are controlled via `Enable Parent`. These chests have a visibility that is controlled by game progression and they cannot be disabled.
- Ignore chests that are re-scaled more than 10%. The value be changed in settings.
- Improved error handling for debug spells: No longer attempt to create mimics when no viable chests exist


# TNTR Known Bugs

- Vore mimics now either eject or kill the player instead of trapping him forever
    -> Fixed

- Heels offset is now removed correctly for animations
    -> It seems to be removed
    -> Issue probably related to player race

- Panties are not removed
    -> Seems to depend on specific item for some 
    -> PO3 . AddAllEquippedItemsToArray seems to not list all equipped items for some reason
        - Elden Small Works
        - Modular mage does not
