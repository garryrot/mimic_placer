;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 21
Scriptname SF_GR_TrapApproachScene_0901A7F1 Extends Scene Hidden

;BEGIN FRAGMENT Fragment_12
Function Fragment_12()
;BEGIN CODE
Debug.Trace("[OMNOM] TRAP.DEFT (S)TrapApproachScene P2 Comp")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_16
Function Fragment_16()
;BEGIN CODE
Debug.Trace("[OMNOM] TRAP.DEFT (S)TrapApproachScene PEH 2 Start #2")
GetOwningQuest().SetStage(11)
GetOwningQuest().RegisterForSingleUpdate(2)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
Debug.Trace("[OMNOM] TRAP.DEFT (S)TrapApproachScene P1 Compl")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
Debug.Trace("[OMNOM] TRAP.DEFT (S)TrapApproachScene P1 Start")
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
