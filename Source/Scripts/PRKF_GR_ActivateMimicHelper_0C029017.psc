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
	Debug.Trace("[GRMP]  OnPerkActivate")
	If Mimics.HasForm( activatorRef.GetBaseObject() )
		Debug.Trace("[GRMP]  Mimics.HasForm " + (MimicPlacer as GR_MimicPlacer))
		(MimicPlacer as GR_MimicPlacer).OnActivateMimic(activatorRef)
	Else
		Debug.Trace("[GRMP] NOT Mimics.HasForm")
	EndIf
EndFunction

FormList Property Mimics Auto
Quest Property MimicPlacer Auto
