Scriptname GR_PlayerAliasScript extends ReferenceAlias

GR_MimicPlacer Property lib Auto
GR_MimicLocationScanner Property scanner Auto 
GR_MimicObserver Property observer Auto
Quest Property consequences Auto

Event OnPlayerLoadGame()
    If !lib
        lib = GetOwningQuest() as GR_MimicPlacer
    EndIf
    lib.Debug("OnPlayerLoadGame()")
    lib.Maintenance()
    scanner.Maintenance()
    observer.Maintenance()
    (consequences as GR_MimicConsequences).Maintenance()
    RegisterForSingleUpdate(3.00)
EndEvent

Event OnCellLoad()
    RegisterForSingleUpdate(1.0)
EndEvent

Event OnUpdate()
    scanner.ProcessCell()
EndEvent
