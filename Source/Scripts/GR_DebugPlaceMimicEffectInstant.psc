Scriptname GR_DebugPlaceMimicEffectInstant extends ActiveMagicEffect

GR_MimicPlacer Property lib Auto

Event OnEffectStart(Actor target, Actor caster)
	lib.PlaceBakaMimicClosestChest(3)
	Debug.Notification("Created Mimic (Instant)")
EndEvent
