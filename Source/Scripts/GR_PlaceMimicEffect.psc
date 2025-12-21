Scriptname GR_PlaceMimicEffect extends ActiveMagicEffect

Event OnEffectStart(Actor target, Actor caster)
	GR_MimicPlacer mainQuest = Game.GetFormFromFile( 0x5900, "GR_MimicPlacer.esp" ) as GR_MimicPlacer
	ObjectReference result = Game.FindClosestReferenceOfAnyTypeInListFromRef(mainQuest.LargeChestForms, Game.GetPlayer(), 500.0)
	ObjectReference mimic = mainQuest.ReplaceWithMimic(result, 2)
	Debug.Notification("Created Mimic")
EndEvent
