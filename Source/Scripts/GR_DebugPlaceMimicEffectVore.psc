Scriptname GR_DebugPlaceMimicEffectVore extends ActiveMagicEffect

GR_MimicPlacer Property lib Auto

Event OnEffectStart(Actor target, Actor caster)
	If lib.PlaceBakaMimicClosestChest(1)
		Debug.Notification("Created Mimic (Vore)")
	Else
		Debug.Notification("Nearest chest not viable")
	EndIf
EndEvent
