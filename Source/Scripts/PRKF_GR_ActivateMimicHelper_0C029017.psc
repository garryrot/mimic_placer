;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 18
Scriptname PRKF_GR_ActivateMimicHelper_0C029017 Extends Perk Hidden

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
	(MimicPlacer as GR_MimicBakaObserver).OnActivateMimic(activatorRef)
EndFunction

FormList Property Mimics Auto ; Unused, check via perk
Quest Property MimicPlacer Auto
