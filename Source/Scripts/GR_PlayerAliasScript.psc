Scriptname GR_PlayerAliasScript extends ReferenceAlias

Event OnPlayerLoadGame()
    GR_MimicPlacer mainQuest = GetOwningQuest() as GR_MimicPlacer
    if mainQuest
        mainQuest.Maintenance()

        ; Diamonds are forever but PO3_SKSEFunctions.SetLinkedRef  
        ; is temporary so we need to prepare the mimics on every reload
        ; mainQuest.FixMimicsInCell() 
        mainQuest.FixMimicsInCell()
    endif
EndEvent

Event OnCellLoad()
    GR_MimicPlacer mainQuest = GetOwningQuest() as GR_MimicPlacer
    mainQuest.PrepareCell()
    mainQuest.FixMimicsInCell()
EndEvent