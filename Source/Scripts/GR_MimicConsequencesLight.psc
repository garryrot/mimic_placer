Scriptname GR_MimicConsequencesLight extends Quest  

String ConsequenceType = "../MimicPlacer/ConsequenceType.json"

Event OnInit()
	Maintenance()
EndEvent

Function Maintenance()
    ; TODO Enable this
    ; If JsonUtil.GetIntValue(ConsequenceType, "simple-consequences") != 1
    ;     return
    ; EndIf

    RegisterForAnimationEvent(Game.GetPlayer(), "MimicVoreSpitLoop")			
    RegisterForAnimationEvent(Game.GetPlayer(), "DeathWormVoreSuccessLoop")
    RegisterForAnimationEvent(Game.GetPlayer(), "SnareRopeUndoSelfFailEvent")
    
    Debug("Using fallback consequences...")
EndFunction

Function OnAnimationEvent(ObjectReference source, String eventName)
	If eventName == "MimicVoreSpitLoop"
        Debug.MessageBox("Fallback: Mimic Player Failed Event")
	EndIf
    If eventName == "DeathWormVoreSuccessLoop"
        Debug.MessageBox("Fallback: Deathworm Player Failed Event")
	EndIf
    If eventName == "SnareRopeUndoSelfFailEvent"
        Debug.MessageBox("Fallback: Snare Rope Fail Event")
	EndIf
EndFunction

Function Debug(String msg)
	Debug.Trace("[GRMP] " + msg)
	; Debug.Notification("[GRMP] " + msg)
EndFunction
