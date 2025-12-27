Scriptname GR_DebugDestroyMimicEffect extends ActiveMagicEffect

Event OnEffectStart(Actor target, Actor caster)
	(Game.GetFormFromFile( 0x5900, "GR_MimicPlacer.esp" ) as GR_MimicPlacer).RemoveBakaMimicClosest()
EndEvent
