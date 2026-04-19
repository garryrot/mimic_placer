Scriptname GR_DebugDestroyMimicEffect extends ActiveMagicEffect

VisualEffect Property effx Auto
Quest Property lib Auto

Event OnEffectStart(Actor target, Actor caster)
	GR_BakaMimicAddon addon = (lib as GR_MimicPlacer).RemoveBakaMimicClosest()
	if addon && addon.PairedContainer
		effx.Play(addon.PairedContainer, 3.0)
	Else
		Debug.Notification("Nothing happened")
	EndIf
EndEvent
