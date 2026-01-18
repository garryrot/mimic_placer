Scriptname GR_DebugPlaceMimicEffectInstant extends ActiveMagicEffect

GR_MimicPlacer Property lib Auto

Event OnEffectStart(Actor target, Actor caster)
	If lib.PlaceBakaMimicClosestChest(3)
		Debug.Notification("Created Mimic (Instant)")
	Else
		Debug.Notification("Nearest chest not viable")
	EndIf
EndEvent
