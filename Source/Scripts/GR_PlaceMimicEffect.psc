Scriptname GR_PlaceMimicEffect extends ActiveMagicEffect  

Event OnEffectStart(Actor target, Actor caster)
	GR_MimicPlacer mainQuest = Game.GetFormFromFile( 0x5900, "GR_MimicPlacer.esp" ) as GR_MimicPlacer
	ObjectReference result = mainQuest.GetNearestViableContainer()
	ObjectReference mimic = mainQuest.ReplaceWithMimic(result)
	Debug.Notification("Created Mimic")
EndEvent
