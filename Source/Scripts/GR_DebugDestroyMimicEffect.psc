Scriptname GR_DebugDestroyMimicEffect extends ActiveMagicEffect

GR_MimicPlacer Property lib Auto

Event OnEffectStart(Actor target, Actor caster)
	if lib.RemoveBakaMimicClosest()
		Debug.Notification("Mimic returned to chest")
	Else
		Debug.Notification("Nearest Mimic not viable")
	EndIf
EndEvent
