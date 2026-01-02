Scriptname GR_DebugPlaceMimicEffect extends ActiveMagicEffect

GR_MimicPlacer Property lib Auto

Event OnEffectStart(Actor target, Actor caster)
	If lib.PlaceBakaMimicClosestChest(2)
		Debug.Notification("Created Mimic")
	Else
		Debug.Notification("Nearest chest not viable")
	EndIf
EndEvent
