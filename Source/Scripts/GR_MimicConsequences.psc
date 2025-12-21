Scriptname GR_MimicConsequences extends Quest  

String ConsequenceType = "../MimicPlacer/ConsequenceType.json"

Event OnInit()
	Maintenance()
EndEvent

Function Maintenance()
    If JsonUtil.GetIntValue(ConsequenceType, "simple-consequences") == 1
        return
    EndIf
    Debug("Using full consequences...")

    RegisterForModEvent("Mimic_StruggleStart", "OnStruggleStart")
    RegisterForModEvent("Mimic_StruggleFail", "OnStruggleFail")
EndFunction

Function Debug(String msg)
	Debug.Trace("[GRMP] " + msg)
	; Debug.Notification("[GRMP] " + msg)
EndFunction


Event OnStruggleStrat()
EndEvent






; Bool VoreStarted = false
; Bool mimicObserved = false
; Event OnUpdate()
	
; 	; If mimicTrap && ! mimicObserved
; 	; 	mimicObserved = true
; 	; 	Debug("Observing FormId Ref " + mimicTrap.GetFormID())
; 	; EndIf

;     ; If (PlayerRef.IsInFaction(VoreFaction))
;     ;     If !VoreStarted
; 	; 		VoreStarted = true
; 	; 		SendModEvent("Mimic_VoreStarted")
;     ;     Else
;     ;         Debug.Trace("Still in vore")
;     ;     EndIf
;     ; Else
;     ;     If (VoreStarted)
; 	; 		VoreStarted = false
; 	; 		SendModEvent("Mimic_VoreDone")
;     ;     Else
;     ;         Debug.Trace("Not in faction")
;     ;     EndIf
;     ; EndIf
;     RegisterForSingleUpdate(2.0)
; EndEvent
