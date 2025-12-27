Scriptname GR_DebugRemoveMimicEffect extends ActiveMagicEffect

Event OnEffectStart(Actor target, Actor caster)
	(Game.GetFormFromFile( 0x5900, "GR_MimicPlacer.esp" ) as GR_MimicPlacer).PlaceBakaMimicClosestChest(1)
	Debug.Notification("Created Mimic (Instant)")
EndEvent
