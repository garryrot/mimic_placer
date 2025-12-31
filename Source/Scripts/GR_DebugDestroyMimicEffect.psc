Scriptname GR_DebugDestroyMimicEffect extends ActiveMagicEffect

GR_MimicPlacer Property lib Auto

Event OnEffectStart(Actor target, Actor caster)
	lib.RemoveBakaMimicClosest()
EndEvent
