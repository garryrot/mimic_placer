Scriptname GR_PlayerAliasScript extends ReferenceAlias

GR_MimicPlacer Property lib Auto
GR_MimicScanner Property scanner Auto 
GR_MimicBakaObserver Property observer Auto
GR_MimicConsequences Property consequences Auto

Event OnPlayerLoadGame()
    If !lib
        lib = GetOwningQuest() as GR_MimicPlacer
    EndIf
    lib.Debug("OnPlayerLoadGame()")
    lib.Maintenance()
    scanner.Maintenance()
    observer.Maintenance()
    consequences.Maintenance()
    RegisterForSingleUpdate(3.00)
EndEvent

Event OnCellLoad()
    RegisterForSingleUpdate(1.0)
EndEvent

Event OnUpdate()
    scanner.ProcessCell()
EndEvent
