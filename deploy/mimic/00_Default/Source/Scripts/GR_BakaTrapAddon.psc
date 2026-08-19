Scriptname GR_BakaTrapAddon extends ObjectReference  

GR_MimicPlacer Property lib Auto

ObjectReference Property SnareRef Auto 
ObjectReference Property TriggerBox Auto

; See comments in BakaMimicAddon

Event OnCellLoad()
    Debug("OnCellLoad()")
    LinkRefsIfRequired()
EndEvent

Function AttachTriggerBox(ObjectReference trapRef)
	BakaTrapTriggerBox box = trapRef.PlaceAtMe(lib.BakaTrapTriggerBoxForm, 1, true) as BakaTrapTriggerBox
	box.TrapType = 3 ; Snare
	box.VoreTrapref = trapRef

	SnareRef = trapRef
	TriggerBox = box
	Debug("Attaching addon (" + self as Form + ") to snare " + SnareRef as Form)
	LinkRefsIfRequired()
EndFunction

Bool Function LinkRefsIfRequired()
	If (SnareRef.GetNthLinkedRef(1) as BakaTrapTriggerBox)
		return False
	EndIf

    Debug("Linking mimic " + SnareRef as Form)
	PO3_SKSEFunctions.SetLinkedRef(SnareRef, TriggerBox)
	return True
EndFunction

Function DestroyTrap()
	Debug("DestroyTrap()")
 	PO3_SKSEFunctions.SetLinkedRef(SnareRef, None)
    SnareRef.Delete()
    TriggerBox.Delete()
EndFunction

String Function GetCell()
	return GetParentCell() + " (" + SnareRef.GetPositionX() + "," + SnareRef.GetPositionY() + "," + SnareRef.GetPositionZ() + ")"
EndFunction

Function Debug(String msg)
    Debug.Trace("[omnom] ADDN: " + msg)
EndFunction