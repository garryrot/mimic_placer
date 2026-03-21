Scriptname BakaTrapBear extends ObjectReference  

TrapHitBase hitBase
bool property OnlyPC = false Auto
{Only PC will get stuck}
bool property StuckEvent = True Auto
{Actor will get stuck to the trap}
bool property StartOpen = True Auto
perk property LightFoot auto
bool property checkForLightFootPerk = true Auto
bool property QTE = false Auto
{default == true}
Quest Property TNTRController Auto
globalVariable property LightFootTriggerPercent auto
actor property playerRef Auto
actor property actorref auto hidden
idle property BearTrapEscape auto
idle property BearTrapStruggle auto
idle property BearTrapStuck auto
idle property StaggerStart auto
Package Property TNTRDoNothing auto
BakaTrapQTEWidgetEx Property StruggleBar Auto
;float property SpeedMult auto

;Trigger01 Open to ClosePlay
;Auto Trans01 ClosePlay to CloseStuck
;Trans03 CloseStuck to ClosedStandBy
;Auto Trans04 ClosedStandBy to Closed
;Reset01 Closed to OpenPlay
;Auto Trans02 OpenPlay to Open

Event onReset()
	goToState("Closed")
	self.reset()
endEvent

event onLoad()
	hitBase = (self as objectReference) as TrapHitBase
	ResolveLeveledDamage()
	if StartOpen
		playAnimation("StartOpen")
		goToState("Open")
	endif
endEvent

auto state Closed
	Event OnBeginState()
	endEvent
	
	event OnTriggerEnter(objectReference TriggerRef)
	endEvent
	
	event OnActivate(objectReference TriggerRef)
		playAnimationAndWait("Reset01","Trans02")
		goToState("Open")
	endEvent
endState

state Open
	Event OnBeginState()
; 		debug.Trace(self + " has entered state Open")
	endEvent

	event OnTriggerEnter(objectReference TriggerRef)
	actorref = TriggerRef as actor
		if checkPerks(TriggerRef) && actorref
			GoToState("Busy")
			if actorref.issprinting()
				hitBase.goToState("CannotHit")
				playAnimationAndWait("Triggerinstant01","Trans05")
				goToState("Closed")
				return
			elseif actorref.isrunning()
				debug.sendanimationevent(actorref, "StaggerIdleStart")
			endif

			actorref.playidle(BearTrapStuck)
			(TNTRController as TNTRControllerScript).SetCoordinates(actorref, self, 1)
			actorref.moveto(self, 0.0, 0.0, 0.0, false)
			playAnimation("Trigger01");to ClosePlay
			hitBase.goToState("CanHit")
			WaitForAnimationEvent("Trans01");to CloseStuck
			hitBase.goToState("CannotHit")
			GoToState("ClosedStuck")
		endif
	endEvent
	
	event OnActivate(objectReference TriggerRef);WIP
		GoToState("Busy")
		hitBase.goToState("CannotHit")
		playAnimationAndWait("Trigger01","Trans01")
		playAnimationAndWait("Trans03","Trans04")
		goToState("Closed")
	endEvent
endState

State ClosedStuck
	Event OnBeginState()
		actorref.playidle(beartrapStruggle) ;It's not sequence animation
		Bool qteInstalled = Game.GetModByName("AcheronExtensionLibrary.esp") != 255
		If playerRef == actorref && qteInstalled
			SendModEvent("GR_TrapStart", "bear")
			RegisterForModEvent("AEL_GameEnd", "OnGameEnd")
			AELStruggle.MakeGame(65)
		EndIf

		if QTE
			Utility.wait(3.0)
		else
			Utility.wait(3.0)
		endif

		If playerRef != actorref || !qteInstalled
			BearTrapEscape()
		EndIf
	endEvent
	
	Event OnGameEnd(string eventName, string strArg, float numArg, form sender)
		SPE_Interface.CloseCustomMenu()
		If numArg > 0
			UnregisterForModEvent("AEL_GameEnd")
			BearTrapEscape()
			SendModEvent("GR_TrapEscape", "bear")
		Else
			SendModEvent("GR_TrapProgress", "bear")
			Utility.Wait(8.0)
			AELStruggle.MakeGame(90)
		EndIf
	EndEvent

	event OnTriggerEnter(objectReference TriggerRef)
	endEvent
	
	event OnActivate(objectReference TriggerRef)
	endEvent
EndState

State Busy	;Dummy state to prevent interaction while animating
	Event OnBeginState()
	endEvent
EndState

event OnTriggerEnter(objectReference TriggerRef)
endEvent
	
event OnActivate(objectReference TriggerRef)
endEvent

Bool function checkPerks(objectReference triggerRef)
	if checkForLightFootPerk
; 		;debug.Trace(self + " is checking if " + triggerRef + " has LightFoot Perk")
		if  (triggerRef as actor).hasPerk(LightFoot)
; 			;debug.Trace(self + " has found that " + triggerRef + " has LightFoot Perk")
			if utility.randomFloat(0.0,100.00) <= LightFootTriggerPercent.getValue()
; 				;debug.Trace(self + " is returning false due to failed lightfoot roll")
				return False
			else
; 				;debug.Trace(self + " is returning true due to successful lightfoot roll")
				return True
			endif
		Else
; 			debug.Trace(self + " has found that " + triggerRef + " doesn't have the LightFoot Perk")
			Return True
		EndIf
	else
		return True
	endif
endFunction

Event OnGameEnd(string eventName, string strArg, float numArg, form sender)
EndEvent

Function BearTrapEscape()
	actorref.playidle(beartrapescape)
	playAnimation("Trans03")
	WaitForAnimationEvent("Trans04")
	(TNTRController as TNTRControllerScript).ResetCoordinates(actorref)
	goToState("Closed")
EndFunction

;==========================================================
int property LvlThreshold1 auto
int property LvlDamage1 auto
int property LvlThreshold2 auto
int property LvlDamage2 auto
int property LvlThreshold3 auto
int property LvlDamage3 auto
int property LvlThreshold4 auto
int property LvlDamage4 auto
int property LvlThreshold5 auto
int property LvlDamage5 auto
int property LvlDamage6 auto
int property TrapLevel = 2 auto

Function ResolveLeveledDamage()
	int damageLevel
	int damage
	damageLevel = CalculateEncounterLevel(TrapLevel)
	
	damage = LvlDamage1
	
	if (damageLevel > LvlThreshold1 && damageLevel <= LvlThreshold2)
		damage = LvlDamage2
		;Trace("damage threshold =")
		;Trace("2")
	endif
	if (damageLevel > LvlThreshold2 && damageLevel <= LvlThreshold3)
		damage = LvlDamage3
		;Trace("damage threshold =")
		;Trace("3")
	endif
	if (damageLevel > LvlThreshold3 && damageLevel <= LvlThreshold4)
		damage = LvlDamage4
		;Trace("damage threshold =")
		;Trace("4")
	endif
	if (damageLevel > LvlThreshold4 && damageLevel <= LvlThreshold5)
		damage = LvlDamage5
		;Trace("damage threshold =")
		;Trace("5")
	endif
	if (damageLevel > LvlThreshold5)
		damage = LvlDamage6
		;Trace("damage threshold =")
		;Trace("6")
	endif
	
	;Trace("damage =")
	;Trace(damage)
	
	;return damage
	hitBase.damage = damage
EndFunction
