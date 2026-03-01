;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 18
Scriptname PRKF__0A0430D2 Extends Perk Hidden

;BEGIN FRAGMENT Fragment_15
Function Fragment_15(ObjectReference akTargetRef, Actor akActor)
;BEGIN CODE
activatorRef = akTargetRef
OnPerkActivate()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

ObjectReference activatorRef

Function OnPerkActivate()
	(TrapMimicObserver as GR_TrapMimicObserver).OnActivateMimic(activatorRef)
EndFunction

Quest Property TrapMimicObserver Auto
