# 0.0.3

- Preserve ObjectReferences when moving items to the player to not break certain quests (like Jorns Drum)
- Fix various loot-related configuration settings being ignored
- Increase default loot retrevial chance and increase default amount of maximum retrieved items to 3

# 0.0.2

- Ignore chests that are controlled via `Enable Parent`. These chests have a visibility that is controlled by game progression and they cannot be disabled.
- Ignore chests that are re-scaled more than 10%. The value be changed in settings.
- Improved error handling for debug spells: No longer attempt to create mimics when no viable chests exist
