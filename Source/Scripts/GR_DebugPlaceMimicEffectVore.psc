Scriptname GR_DebugPlaceMimicEffectVore extends ActiveMagicEffect

GR_MimicPlacer Property lib Auto

Event OnEffectStart(Actor target, Actor caster)
	lib.PlaceBakaMimicClosestChest(1)
	Debug.Notification("Created Mimic (Vore)")
EndEvent
