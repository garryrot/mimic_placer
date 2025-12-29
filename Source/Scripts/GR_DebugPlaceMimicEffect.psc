Scriptname GR_DebugPlaceMimicEffect extends ActiveMagicEffect

GR_MimicPlacer Property lib Auto

Event OnEffectStart(Actor target, Actor caster)
	lib.PlaceBakaMimicClosestChest(2)
	Debug.Notification("Created Mimic (Sex)")
EndEvent
