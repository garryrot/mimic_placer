Scriptname GR_PlayerAliasScript extends ReferenceAlias

Event OnPlayerLoadGame()
    Debug.Notification("OnPlayerLoadGame")
    GR_MimicPlacer mainQuest = GetOwningQuest() as GR_MimicPlacer
    if mainQuest
        mainQuest.Maintenance()
    endif
EndEvent
