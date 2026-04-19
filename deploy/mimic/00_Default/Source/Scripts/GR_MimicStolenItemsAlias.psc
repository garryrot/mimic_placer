Scriptname GR_MimicStolenItemsAlias extends ReferenceAlias

Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
    if akNewContainer == Game.GetPlayer()
        (GetOwningQuest() as GR_MimicStolenQuest).MarkItemRecovered(GetReference())
    EndIf
EndEvent
