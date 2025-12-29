Scriptname GR_BakaMimicAddon extends ObjectReference  

GR_MimicPlacer Property lib Auto

ObjectReference Property MimicRef Auto 
ObjectReference Property PairedContainer Auto
ObjectReference Property TriggerBox Auto
ObjectReference Property XMarkerPos Auto
ObjectReference Property XMarkerDispense Auto

; The main purpose of this script (in addition to unambiguously 
; connecting each mimic and its-co-objects) is to re-link
; the mimic and its linked references after each game start.

; Explanation: Refs created with PO3.SetLinkedRef are volatile 
; and will be gone whenever the game process stops.

Event OnCellLoad()
    Debug("OnCellLoad()")
    LinkRefsIfRequired()
EndEvent

Function AttachToMimic(ObjectReference mimic, ObjectReference pairedChest)
    If !SanityCheckPreAttach(mimic)
        return
    EndIf

	BakaTrapTriggerBox box = mimic.PlaceAtMe(lib.BakaTrapTriggerBoxForm, 1, true) as BakaTrapTriggerBox
	box.TrapType = 2
	box.VoreTrapref = mimic

	MimicRef = mimic
	PairedContainer = pairedChest
	TriggerBox = box
	XMarkerPos = mimic.PlaceAtMe(Game.GetForm(0x34), 1, true) ; Debug("Created PositionXMarker" + (posXmarkerHeading as Form))
	XMarkerDispense = mimic.PlaceAtMe(Game.GetForm(0x3B), 1, true) ; Debug("Created DispenseXMarker" + (dispenseXmarker as Form))
	Debug("Attaching addon (" + self as Form + " posMarker=" + XMarkerPos as Form \
            + " dispenseMarker=" + XMarkerDispense as Form + " triggerBox=" + TriggerBox as Form \
            +  " pairedChest=" + pairedChest as Form + ") to mimic " + MimicRef as Form)
	LinkRefsIfRequired()
EndFunction

String Function GetCell()
	If !GetParentCell()
		return "World"
	EndIf
	return GetParentCell().GetName()
EndFunction

Bool Function LinkRefsIfRequired()
	If (MimicRef.GetNthLinkedRef(1) as BakaTrapTriggerBox)
		return False
	EndIf

    Debug("Linking mimic " + MimicRef as Form)
	PO3_SKSEFunctions.SetLinkedRef(MimicRef, TriggerBox)
	PO3_SKSEFunctions.SetLinkedRef(MimicRef, XMarkerDispense, lib.BakaMimicDispenseKeyword)
	PO3_SKSEFunctions.SetLinkedRef(MimicRef, XMarkerPos, lib.BakaMimicPosKeyword)
	return True
EndFunction

Function DestroyMimicAndRestoreChest()
 	PO3_SKSEFunctions.SetLinkedRef(MimicRef, None)
 	PO3_SKSEFunctions.SetLinkedRef(MimicRef, None, lib.BakaMimicDispenseKeyword)
 	PO3_SKSEFunctions.SetLinkedRef(MimicRef, None, lib.BakaMimicPosKeyword)
    MimicRef.Delete()
    PairedContainer.Enable()
    TriggerBox.Delete()
    XMarkerPos.Delete()
    XMarkerDispense.Delete()
EndFunction

Function Debug(String msg)
    lib.Debug("ADDN: " + msg)
EndFunction

; TODO Debugging/Removable 
Bool Function SanityCheckPreAttach(ObjectReference mimic)
    If (mimic.GetNthLinkedRef(1) as BakaTrapTriggerBox)
        Debug.MessageBox("Sanity check failed: Mimic " + mimic as Form + " has linked trigger box " + mimic.GetNthLinkedRef(1) as Form)
		return False
	EndIf
	BakaTrapTriggerBox box = Game.FindClosestReferenceOfTypeFromRef(lib.BakaTrapTriggerBoxForm, mimic, 10.0) as BakaTrapTriggerBox
	If box
        Debug.MessageBox("Sanity check failed: Mimic " + mimic as Form + " has existing trigger box " + box as Form)
		return False
	EndIf
    ; Note: Cannot have been moved on creation, i.e. must be exactly on the chest
	ObjectReference dispenseXmarker = Game.FindClosestReferenceOfTypeFromRef(Game.GetForm(0x3B), mimic, 10.0) 
	If dispenseXmarker
        Debug.MessageBox("Sanity check failed: Mimic " + mimic as Form + " has existing dispense marker " + dispenseXmarker as Form)
		return False
	EndIf
	ObjectReference posXmarkerHeading = Game.FindClosestReferenceOfTypeFromRef(Game.GetForm(0x34), mimic, 10.0)
	If posXmarkerHeading
        Debug.MessageBox("Sanity check failed: Mimic " + mimic as Form + " has existing position marker " + posXmarkerHeading as Form)
		return False
	EndIf
    return True
EndFunction