Scriptname GR_PlayerAliasScript extends ReferenceAlias

GR_MimicPlacer Property lib Auto
GR_MimicScanner Property scanner Auto 
GR_MimicConsequences Property consequences Auto

Bool GameLoad = True
Event OnPlayerLoadGame()
    If !lib
        lib = GetOwningQuest() as GR_MimicPlacer
    EndIf
    lib.Debug("OnPlayerLoadGame()")
    lib.Maintenance()
    scanner.Maintenance()
    consequences.Maintenance()
    GameLoad = True
    RegisterForSingleUpdate(2.0)
EndEvent

Event OnCellLoad()
    RegisterForSingleUpdate(5.0)
EndEvent

Event OnUpdate()
    If GameLoad 
        GameLoad = False
        scanner.FixMimicsOnGameLoad()
    EndIf
    scanner.ProcessCell()
EndEvent
