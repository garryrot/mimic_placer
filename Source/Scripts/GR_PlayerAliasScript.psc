Scriptname GR_PlayerAliasScript extends ReferenceAlias

GR_MimicPlacer Property lib Auto

Event OnPlayerLoadGame()
    If !lib
        lib = GetOwningQuest() as GR_MimicPlacer
    EndIf
    lib.Debug("OnPlayerLoadGame()")
    lib.Maintenance()
    RegisterForSingleUpdate(0.75)

    (GetOwningQuest() as GR_MimicConsequences).Maintenance()
EndEvent

Event OnCellLoad()
    RegisterForSingleUpdate(0.75)
EndEvent

Event OnUpdate()
    (GetOwningQuest() as GR_MimicPlacer).ProcessCell()
EndEvent

