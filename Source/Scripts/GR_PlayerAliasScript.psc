Scriptname GR_PlayerAliasScript extends ReferenceAlias

Event OnReset()
    ; Doesnt Work
    AliasMaintenance()
EndEvent

Event OnPlayerLoadGame()
    GR_MimicPlacer mainQuest = GetOwningQuest() as GR_MimicPlacer
    if mainQuest
        mainQuest.Maintenance()
    endif
    AliasMaintenance()
EndEvent

Function AliasMaintenance()
    Debug.MessageBox("Alias Maintenance")
    RegisterForAnimationEvent(Game.GetPlayer() as ObjectReference, "MimicVoreStart")
    RegisterForAnimationEvent(Game.GetPlayer() as ObjectReference, "MimicVoreInstant")
    RegisterForAnimationEvent(Game.GetPlayer() as ObjectReference, "MimicVoreLoop")
    RegisterForAnimationEvent(Game.GetPlayer() as ObjectReference, "MimicVoreSpit")
    RegisterForAnimationEvent(Game.GetPlayer() as ObjectReference, "MimicVoreGetUpAfterSpit")
    
	RegisterForAnimationEvent(Game.GetPlayer() as ObjectReference, "EnterChair")
	RegisterForAnimationEvent(Game.GetPlayer() as ObjectReference, "ExitChair")
	RegisterForAnimationEvent(Game.GetPlayer() as ObjectReference, "NormalAttack")
	RegisterForAnimationEvent(Game.GetPlayer() as ObjectReference, "DrawWeapon")
	RegisterForAnimationEvent(Game.GetPlayer() as ObjectReference, "BlockingStart")

	RegisterForAnimationEvent(Game.GetPlayer(), "BeginCastLeft")
	RegisterForAnimationEvent(Game.GetPlayer(), "BeginCastRight")
	
	RegisterForModEvent("GRMP_VoreStarted", "OnVoreEvent")
	RegisterForModEvent("GRMP_VoreSuccess", "OnVoreEvent")
	RegisterForModEvent("GRMP_VoreFail", "OnVoreEvent")
EndFunction

Function OnAnimationEvent(ObjectReference akSource, string asEventName)
    Debug.MessageBox("Alias Anim" + asEventName)
EndFunction
