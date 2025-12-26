Scriptname GR_PlayerAliasScript extends ReferenceAlias

GR_MimicPlacer Property lib Auto
GR_MimicLocationScanner Property scanner Auto 
GR_MimicObserver Property observer Auto
Quest Property consequences Auto

Event OnPlayerLoadGame()
    If !lib
        lib = GetOwningQuest() as GR_MimicPlacer
    EndIf
    (lib as GR_MimicPlacer).Debug("OnPlayerLoadGame()")
    (lib as GR_MimicPlacer).Maintenance()
    RegisterForSingleUpdate(0.75)

    if !scanner
        lib.Error("GR_MimicConsequences is null?! " + scanner)
    EndIf
    (scanner as GR_MimicLocationScanner).Maintenance()

    if !observer
        lib.Error("GR_MimicObserver is null?! " + observer)
    EndIf
    (observer as GR_MimicObserver).Maintenance()

    lib.Error("GR_MimicConsequences: " + consequences)
    (consequences as GR_MimicConsequences).Maintenance()
EndEvent

Event OnCellLoad()
    RegisterForSingleUpdate(0.75)
EndEvent

Event OnUpdate()
    scanner.ProcessCell()
EndEvent
