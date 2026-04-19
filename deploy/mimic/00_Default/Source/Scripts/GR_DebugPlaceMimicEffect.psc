Scriptname GR_DebugPlaceMimicEffect extends ActiveMagicEffect

VisualEffect Property effx Auto
Quest Property lib Auto
Int Property type Auto

Event OnEffectStart(Actor target, Actor caster)
	GR_BakaMimicAddon addon = (lib as GR_MimicPlacer).PlaceBakaMimicClosestChest(type)
	if addon && addon.MimicRef
		Debug.Notification("The chest begins to shake...")
		effx.Play(addon.MimicRef, 3.0)
    Else
        Debug.Notification("Nothing happened")
    EndIf
EndEvent
