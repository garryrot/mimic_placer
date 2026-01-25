;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 33
Scriptname SF_GR_TrapAttackApproachT1_09033DB0 Extends Scene Hidden

;BEGIN FRAGMENT Fragment_15
Function Fragment_15()
;BEGIN CODE
Debug.Trace("[omnom] TRAP.ATTC (S)TrapAttackApproachT1 P2 Complete - Bleedout")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
Debug.Trace("[omnom] TRAP.ATTC (S)TrapAttackApproachT1 P1 Start")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_31
Function Fragment_31()
;BEGIN CODE
Debug.Trace("[omnom] TRAP.ATTC (S)TrapAttackApproachT1 P3 Done")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_30
Function Fragment_30()
;BEGIN CODE
Debug.Trace("[omnom] TRAP.ATTC (S)TrapAttackApproachT1 P3 Start")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_17
Function Fragment_17()
;BEGIN CODE
Debug.Trace("[omnom] TRAP.ATTC (S)TrapAttackApproachT1 P2 Start")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
Debug.Trace("[omnom] TRAP.ATTC (S)TrapAttackApproachT1 P1 Complete")
GetOwningQuest().SetStage(20) ; Stops timeout
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
