Scriptname GR_TrapTriggerBox extends ObjectReference  

Actor Property LastActivator Auto Hidden
Actor Property PlayerRef Auto
Float Property Timer = 15.0 Auto 
Bool property bTriggerEnter = True auto
Bool property trapFired = false auto
Sound Property WindupSound auto
Keyword Property DeathWormVoreColKeyword Auto
Keyword Property DeathWormVoreNColKeyword Auto
Quest Property TNTRController Auto; as TNTRControllerScript
TNTRMCM Property MCM Auto
{Type 1: Alphabet, Type 0: Normal struggle bar}
BakaTrapQTEWidgetEx Property StruggleBar Auto
ObjectReference Property VoreTrapref Auto Hidden
int RunningScenario
Sound Property BakaTrapDeathWormVoreStruggle auto
Int Property TrapType auto
{0 = Null, 1 = DeathWorm, 2 = Mimic, 3 = SnareRope}
Float FillDifficulty = 0.0
Float FillThreshold = 0.0
int Time = 0
Float DownedTime ; How much time the player will be stayed down.


Int StrafeL
Int StrafeR
Int StrafeF

event onCellLoad()
	Gotostate("IdleState")
endEvent

Function DesignateTarget(actor akactor)
	LastActivator = akactor
EndFunction

Function CameraShake(actor akRef)
	Game.ShakeCamera(akRef as ObjectReference, 0.8, 2.0)
EndFunction

Function ResetTrigger()
	trapFired = false
	GotoState("IdleState")
EndFunction

Function FireQTE(Objectreference akref)
	VoreTrapref = akref ;Normally this would be getLinkedRef(DeathWormVoreNColKeyword)
	if MCM.TrapTypeint == 1
		gotostate("QTETextEnter")
	else
		gotostate("QTEEnter")
	endif
EndFunction

Function Abort()
	ResetTrigger()
	;Reset Trap WIP
EndFunction

Function QTERestore()
if MCM.TrapTypeint == 1
else
	Time = 0
	FillDifficulty = 0.0
	StruggleBarDisplay(False)
endif
EndFunction

Function QTESet(int stage = 1)
if MCM.TrapTypeint == 1
	(TNTRController as TNTRControllerScript).QTETextStart(self, stage)
else
	DownedTime = (TNTRController as TNTRControllerScript).StruggleDuration
	FillThreshold = 0.1 / (TNTRController as TNTRControllerScript).StrafeDifficulty
	StruggleBarDisplay(true)
endif
EndFunction

Function StruggleBarDisplay(Bool Display = True)
If Display == true
	StruggleBar.Alpha = 100.0
;	If ((SLApproach_Config as SLApproachConfigScript).ResistType == "$Attack");Need MCM to work WIP
;		StrafeL = Input.GetMappedKey("Left Attack/Block")
;		StrafeR = Input.GetMappedKey("Right Attack/Block")
;	Else
	if Game.UsingGamepad()
		StrafeF = Input.GetMappedKey("DPAD_UP")
	else
		;StrafeL = Input.GetMappedKey("Strafe Left")
		;StrafeR = Input.GetMappedKey("Strafe Right")
		StrafeF = Input.GetMappedKey("Forward")
	endif
;	Endif

;0x10A  266  DPAD_UP
;0x10B  267  DPAD_DOWN
;0x10C  268  DPAD_LEFT
;0x10D  269  DPAD_RIGHT
;0x10E  270  START
;0x10F  271  BACK
;0x110  272  LEFT_THUMB
;0x111  273  RIGHT_THUMB
;0x112  274  LEFT_SHOULDER
;0x113  275  RIGHT_SHOULDER
;0x114  276  A
;0x115  277  B
;0x116  278  X
;0x117  279  Y
;0x118  280  LT
;0x119  281  RT

	;RegisterForKey(StrafeL)
	;RegisterForKey(StrafeR)
	RegisterForKey(StrafeF)
Else
	StruggleBar.Alpha = 0.0
	StruggleBar.Percent = 0.0
	;FillDifficulty = 0.0
	
	;UnregisterForKey(StrafeL)
	;UnregisterForKey(StrafeR)
	UnregisterForKey(StrafeF)
EndIf

EndFunction


Event OnUpdate()
EndEvent

Event OnTriggerEnter(objectReference triggerRef)
Endevent

Event OnTriggerLeave(objectReference triggerRef)
EndEvent

Event OnKeyDown(Int KeyCode)
EndEvent

Auto State IdleState

Event onBeginState()
	UnregisterForUpdate()
endEvent

event OnTriggerEnter( objectReference triggerRef )
	if (triggerRef as actor) && (trapFired == false) && (bTriggerEnter == true)
		trapFired = true
		LastActivator = triggerRef as actor
		RunningScenario = 0
		GotoState("StandBy")
	;elseif triggerRef as objectReference; WIP
	endif
endEvent

event OnTriggerLeave(objectReference triggerRef)      
	;Nothing
endEvent

EndState

State StandBy

Event onBeginState()
	WindupSound.play(self as ObjectReference)
	if LastActivator == PlayerRef
		CameraShake(LastActivator)
	endif
	RegisterForSingleUpdate(Timer)
endEvent

Event OnUpdate()
	;Debug.notification("StandBy Go")
	if getstate() == "StandBy"
		;Debug.notification("Emerge Go")
		GotoState("Emerge")
	endif
EndEvent

event OnTriggerLeave(objectReference triggerRef)      
	if triggerRef == LastActivator
		ResetTrigger()
	endif
endEvent

EndState

State Emerge

Event onBeginState()
	Actorbase LastActivatorBase = LastActivator.getactorbase()
	BakaTrapDeathWormVore BakaTrapDWVoreCol = getLinkedRef(DeathWormVoreColKeyword) as BakaTrapDeathWormVore;This is not vore actually. Collidable. Hit the actor away.
	BakaTrapDeathWormVore BakaTrapDWVoreNCol = getLinkedRef(DeathWormVoreNColKeyword) as BakaTrapDeathWormVore;To make it capable of devouring something, this has to be non-collidable.
	
	;if getLinkedRef() && !LastActivator.isdead()
	if (getLinkedRef(DeathWormVoreColKeyword) || getLinkedRef(DeathWormVoreNColKeyword)) && !LastActivator.isdead()
		
		;Debug.notification("getLinkedRef")
		if LastActivatorBase.isessential() || LastActivatorBase.isprotected() || LastActivator.getflyingstate() != 0
			BakaTrapDWVoreCol.DesignateTarget(LastActivator)
			BakaTrapDWVoreCol.gotostate("Idleessential")
			getLinkedRef(DeathWormVoreColKeyword).activate(getLinkedRef(DeathWormVoreColKeyword));Deathworm with collision
			RunningScenario = 1
		elseif LastActivatorBase.GetSex() == 0;male
			BakaTrapDWVoreNCol.DesignateTarget(LastActivator)
			BakaTrapDWVoreNCol.gotostate("IdleMale")
			getLinkedRef(DeathWormVoreNColKeyword).activate(getLinkedRef(DeathWormVoreNColKeyword));Deathworm without collision
			RunningScenario = 2
		else
			BakaTrapDWVoreNCol.DesignateTarget(LastActivator)
			BakaTrapDWVoreNCol.gotostate("IdleFemale")
			getLinkedRef(DeathWormVoreNColKeyword).activate(getLinkedRef(DeathWormVoreNColKeyword))
			RunningScenario = 3
		endif

	endif
EndEvent

event OnTriggerEnter( objectReference triggerRef )
	;Nothing
Endevent

event OnTriggerLeave(objectReference triggerRef);Error, abort the current status
	if RunningScenario == 1
		resettrigger()
	endif
endEvent

EndState

State QTEEnter

	Event OnBeginState()
		QTESet(1)
		RegisterForSingleUpdate(1.0)
	EndEvent
	
	event OnTriggerLeave(objectReference triggerRef);Error, abort the current status 
		if triggerRef == LastActivator
			;Abort() ;WIP. It may happen when the actor leaves the triggerbox because of the motion
		endif
	endEvent

	Event OnUpdate() ; Loop to check the situation every 1 second.
		Time += 1
		;Actor akRef = talkingActor.GetReference() as Actor
		If StruggleBar.Percent >= 1.0
			gotostate("QTESuccess")
			Return
		Elseif Time > DownedTime
			gotostate("QTEFail")
			Return
		Endif
		if TrapType <= 4
			if Time == 3.0
				BakaTrapDeathWormVoreStruggle.play(LastActivator as ObjectReference)
			elseif Time == 7.0
				BakaTrapDeathWormVoreStruggle.play(LastActivator as ObjectReference)
			endif
			if TrapType == 2
				(VoreTrapref as BakaTrapMimic).MimicShake()
			endif
		endif
	;(TNTRController as TNTRControllerScript).StrggleBarAlpha(100);just in case
	StruggleBar.Alpha = 100.0
	RegisterForSingleUpdate(1.0)
	EndEvent

	Event OnKeyDown(Int KeyCode)
		If (KeyCode == StrafeF)
			FillDifficulty += FillThreshold
			StruggleBar.Percent = FillDifficulty
		endif
;		If ((KeyCode == StrafeL) && LeftRight)
;			LeftRight = False
;			FillDifficulty += FillThreshold
;			StruggleBar.Percent = (FillDifficulty)
;		Elseif ((KeyCode == StrafeR) && !LeftRight)
;			LeftRight = True
;			FillDifficulty += FillThreshold
;			StruggleBar.Percent = (FillDifficulty)
;		Endif
	EndEvent

EndState

State QTETextEnter
	Event OnBeginState()
		RegisterForSingleUpdate(1.0)
		QTESet(1)
	EndEvent

	event OnTriggerLeave(objectReference triggerRef);Error, abort the current status 
	endEvent

	Event OnUpdate() ; Loop to check the situation every 1 second.
		Time += 1
		if TrapType <= 4
			if Time == 3.0
				BakaTrapDeathWormVoreStruggle.play(LastActivator as ObjectReference)
			elseif Time == 7.0
				BakaTrapDeathWormVoreStruggle.play(LastActivator as ObjectReference)
			endif
			if TrapType == 2
				(VoreTrapref as BakaTrapMimic).MimicShake()
			endif
		endif
		RegisterForSingleUpdate(1.0)
	EndEvent

	Event OnKeyDown(Int KeyCode)
	EndEvent
EndState

State QTESuccess
	Event OnBeginState()
		QTERestore()
		if TrapType == 1
			(VoreTrapref as BakaTrapDeathWormVore).FailVore()
		elseif TrapType == 2
			(VoreTrapref as BakaTrapMimic).FailVore()
		elseif TrapType == 3
			(VoreTrapref as BakaSnareTrap).QTESuccess()
		elseif TrapType == 4
			(VoreTrapref as bakarieklingrestraintpoleTrap).QTESuccess()
		elseif TrapType == 5
			(VoreTrapref as BakaSkeletonLurkerTrap).QTESuccess()
		endif
	EndEvent
	
	event OnTriggerLeave(objectReference triggerRef);Error, abort the current status 
	endEvent
EndState

State QTEFail
	Event OnBeginState()
		QTERestore()
		if TrapType == 1
			(VoreTrapref as BakaTrapDeathWormVore).SuccessVore()
		elseif TrapType == 2
			(VoreTrapref as BakaTrapMimic).SuccessVore()
		elseif TrapType == 3
			(VoreTrapref as BakaSnareTrap).QTEFail()
		elseif TrapType == 4
			(VoreTrapref as bakarieklingrestraintpoleTrap).QTEFail()
		elseif TrapType == 5
			(VoreTrapref as BakaSkeletonLurkerTrap).QTEFail()
		endif
	EndEvent
	
	event OnTriggerLeave(objectReference triggerRef);Error, abort the current status 
	endEvent
EndState