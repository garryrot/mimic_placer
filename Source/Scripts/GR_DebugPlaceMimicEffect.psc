Scriptname GR_DebugPlaceMimicEffect extends ActiveMagicEffect

Event OnEffectStart(Actor target, Actor caster)
	(Game.GetFormFromFile( 0x5900, "GR_MimicPlacer.esp" ) as GR_MimicPlacer).PlaceBakaMimicClosestChest(2)
	Debug.Notification("Created Mimic (Sex)")
EndEvent
