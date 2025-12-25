Scriptname StandaloneBakaTrapMimic extends BakaMovingTrap ; extends ObjectReference

import debug
import utility

int Mimichitcount
int Property MimicHealth = 3 Auto
int Property MimicType = 2 Auto
{0 = Attack, 1 = VoreSimple, 2 = VoreSex, 3 = VoreInstant}
Actor Property actorref Auto Hidden
bool property FemaleOnlyTrigger = True Auto
bool property playerOnlyTrigger = True Auto
float property initialDelay = 0.25 auto
bool LockPosition = false
bool btrapDisarmed = false
bool RemoveHeel

string property startDamage = "startDamage" auto hidden
string property stopDamage = "stopDamage" auto hidden

Faction Property MimicVoreDefaultFaction Auto ;XX1EBFB1

Keyword Property MimicPosKeyword Auto
Keyword Property MimicDispenseKeyword Auto
ObjectReference PosXmarker
ObjectReference DispenseXmarker

bool property StartOpen = True Auto
;bool property QTE = false Auto
{default == true}
globalVariable property LightFootTriggerPercent auto
actor property playerRef Auto

idle property MimicVoreStart auto
idle property MimicVoreLoop auto
idle property MimicVoreEndFail auto
idle property MimicVoreEndSuccess auto
idle property MimicVoreEndSuccessDefault auto
idle property MimicVoreEndSuccessLoop auto
idle property MimicVoreStage02Preface auto
idle property MimicVoreStage02Start auto
idle property MimicVoreStage02Loop auto
idle property MimicVoreStage02EndPreface auto
idle property MimicVoreStage02Fail auto
idle property MimicVoreStage02Success auto
idle property MimicVoreStage02SuccessLoop auto
idle property MimicVoreStage02Finale auto
idle property MimicVoreIdle auto
idle property MimicVoreSpit auto
idle property MimicVoreSexEnter auto
idle property MimicVoreSexLoop auto
idle property MimicVoreSexStop auto

idle property MimicVoreGetUpAfterSpit auto
idle property MimicVoreInstant auto

Package Property TNTRDoNothing auto
Quest Property TNTRController Auto; as TNTRControllerScript

int iLower
int iSkirt
int iUpper

String Property TNTRRemoveLowerFormList = "tntr.removelower" autoreadonly hidden
String Property TNTRRemoveSkirtFormList = "tntr.removeskirt" autoreadonly hidden
String Property TNTRRemoveUpperFormList = "tntr.removeupper" autoreadonly hidden

int Xaxis
int Yaxis

Float AngleZ
Float rMoveX
Float rMoveY
Float rMoveZ

actor VoiceActor
float finterval
int icount
int iVoiceStrength

; ############################ My Snippets ################

; MimicVoreDefaultFaction "MimicVoreDefaultFaction" [FACT:05000E05]
; MimicVoreEndFail [IDLE:050008E4]
; MimicVoreEndSuccess [IDLE:050008E5]
; MimicVoreEndSuccessDefault [IDLE:05000E06]
; MimicVoreEndSuccessLoop [IDLE:050008E6]
; MimicVoreGetUpAfterSpit [IDLE:05000D68]
; MimicVoreIdle [IDLE:050008EF]
; MimicVoreInstant [IDLE:05000D67]
; MimicVoreLoop [IDLE:050008E3]
; MimicVoreSexEnter [IDLE:0503DB28]
; MimicVoreSexLoop [IDLE:0503DB29]
; MimicVoreSexStop [IDLE:0503DB2A]
; MimicVoreSpit [IDLE:050008F0]
; MimicVoreStage02EndPreface [IDLE:050008EA]
; MimicVoreStage02Fail [IDLE:050008EB]
; MimicVoreStage02Finale [IDLE:050008EE]
; MimicVoreStage02Loop [IDLE:050008E9]
; MimicVoreStage02Preface [IDLE:050008E7]
; MimicVoreStage02Start [IDLE:050008E8]
; MimicVoreStage02Success [IDLE:050008EC]
; MimicVoreStage02SuccessLoop [IDLE:050008ED]
; MimicVoreStart [IDLE:050008E2]
; TNTRController "TNTRController" [QUST:0500086A]
; TNTRDoNothing [PACK:05000885]

; Support for not previously set up dispense-markers
ObjectReference Function GetDispenseMarker()
    If !DispenseXmarker
	    DispenseXmarker = PlaceAtMe(Game.GetForm(0x3B)) ; XMarker
    EndIf
    return DispenseXmarker
EndFunction

; Support for not previously set up pos-markers
ObjectReference Function GetPosMarker()
    If !PosXmarker
        PosXmarker = PlaceAtMe(Game.GetForm(0x34)) ; XMarkerHeading
    EndIf
    return PosXmarker
EndFunction

; Support for not previously set up trigger box
BakaTrapTriggerBox _triggerBox
BakaTrapTriggerBox Function GetTriggerBox()
	If !_triggerBox
        _triggerBox = PlaceAtMe(Game.GetFormFromFile(0x83E, "TNTR.esp")) as BakaTrapTriggerBox
		_triggerBox.TrapType = 2 ; 2 for Mimic
		_triggerBox.VoreTrapref = self
    EndIf
    return _triggerBox
EndFunction

; ----------------- Game -----------------

GR_GameQTEText gameQteText
GR_GameAEL gameAel
Function StartGame(int stage)
	; If (JsonUtil.GetIntValue("../MimicPlacer/AdvancedSettings.json", "use-alternative-qte") == 1)
		If (!gameAel)
			gameAel = PlaceAtMe(Game.GetFormFromFile(0x23F0F, "GR_MimicPlacer.esp")) as GR_GameAEL
		EndIf
		RegisterForModEvent("GR_GameSuccess", "OnGameSuccess")
		RegisterForModEvent("GR_GameFail", "OnGameFail")
		RegisterForModEvent("GR_GameTick", "OnGameTick")
		gameAel.StartGame(self, stage)
	
	; QTE Text is broken
	; Else
	; 	Debug.Trace("[GRMP] QteText")
	; 	If (!gameQteText)
	; 		Debug.Trace("[GRMP] !gameQteText")
	; 		gameQteText = PlaceAtMe(Game.GetFormFromFile(0x23F16, "GR_MimicPlacer.esp")) as GR_GameQTEText
	; 	EndIf
	; 	Debug.Trace("[GRMP] " + gameQteText)
	; 	RegisterForModEvent("GR_GameSuccess", "OnGameSuccess")
	; 	RegisterForModEvent("GR_GameFail", "OnGameFail")
	; 	RegisterForModEvent("GR_GameTick", "OnGameTick")
	; 	Debug.Trace("[GRMP] starting" + gameQteText)
	; 	gameQteText.StartGame(self, stage)
	; EndIf	
EndFunction

Function UnregisterGame()
	UnregisterForModEvent("GR_GameSuccess")
	UnregisterForModEvent("GR_GameFail")
	UnregisterForModEvent("GR_GameTick")
EndFunction

Event OnGameSuccess(string eventName, string strArg, float numArg, form sender)
	UnregisterGame()
	FailVore()
EndEvent

Event OnGameFail(string eventName, string strArg, float afNumArg, form sender)
	UnregisterGame()
	SuccessVore()
EndEvent

Event OnGameTick(string eventName, string strArg, float afNumArg, form sender)
	MimicShake()
EndEvent

; ############################ Original Code Begins #########################

; TriggerVoreStart - Mimic Start

Function ResetTrap()
	ResetCoordinates(actorref)
	actorref.removefromfaction(MimicVoreDefaultFaction)
	if isLoaded
		isFiring = false
		;btrapDisarmed = false
		GetTriggerBox().ResetTrigger()
		goToState("Ready")
	endif
EndFunction

Function MimicTest()
EndFunction

Function DispenseArmor(String FormlistString, bool bUnequipall)
	GetDispenseMarker().MoveToNode(Self, "4_Mimic_Sucker14")
	(TNTRController as TNTRControllerScript).RemoveArmorfromList(actorref, GetDispenseMarker(), FormlistString, bUnequipall)
	(TNTRController as TNTRControllerScript).RemoveWeapon(ActorRef, GetDispenseMarker(), false, true)
EndFunction

int function acceptableTrigger(objectReference triggerRef)
;0 = Shake
;1 = Attack
;2 = Swallow
;3 = InstantSwallow

; 	debug.Trace(self + " is checking if " + triggerRef + " is an acceptable trigger")
	if playerOnlyTrigger
		if triggerRef == PlayerRef
			actorref = triggerRef as actor
			if FemaleOnlyTrigger && (triggerRef as actor).getactorbase().getsex() == 1
				return 2
			elseif FemaleOnlyTrigger && (triggerRef as actor).getactorbase().getsex() == 0
				return 1
			else
				return 1
			endif
		Else
			return 0
		endif
	Else
		if (triggerRef as actor)
			actorref = triggerRef as actor
			if FemaleOnlyTrigger && (triggerRef as actor).getactorbase().getsex() == 1
				return 2
			elseif FemaleOnlyTrigger && (triggerRef as actor).getactorbase().getsex() == 0
				return 1
			else
				return 1
			endif
		else
			return 0
		endif
	endif
endFunction

Function ResetCoordinates(Actor akactor)
	if LockPosition
		MuJointFixUtil.ToggleFixes(akactor, 2, true);MuJointFixToggle
		MuJointFixUtil.ToggleFixes(akactor, 4, true)
		MuJointFixUtil.ToggleFixes(akactor, 10, true)
		akactor.SetVehicle(None)
		;Game.EnablePlayerControls()
		If (akactor == PlayerRef)
			Game.SetPlayerAIDriven(false)
			;akactor.SetAnimationVariableBool("bHumanoidFootIKEnable", true)
		endif
		akactor.SetRestrained(False)
		akactor.SetDontMove(False)
		akactor.SetHeadTracking(TRUE)
		ActorUtil.RemovePackageOverride(akactor, TNTRDoNothing)
		LockPosition = false
	endif
EndFunction

Function SetCoordinates(Actor akactor)
		MuJointFixUtil.ToggleFixes(akactor, 2, false);MuJointFixToggle
		MuJointFixUtil.ToggleFixes(akactor, 4, false)
		MuJointFixUtil.ToggleFixes(akactor, 10, false)
		If (akactor == PlayerRef)
			Game.SetPlayerAIDriven(true)
			;akactor.SetDontMove(True)
			ActorUtil.AddPackageOverride(akactor, TNTRDoNothing, 100, 1)
			akactor.EvaluatePackage()
		Else
			ActorUtil.AddPackageOverride(akactor, TNTRDoNothing, 100, 1)
			akactor.EvaluatePackage()
			akactor.SetHeadTracking(true)
			akactor.SetRestrained(true)
			akactor.SetDontMove(True)
		Endif
	;akactor.SetVehicle(Self)
		DispenseXmarker = GetDispenseMarker() ; getLinkedRef(MimicDispenseKeyword)
		PosXmarker = GetPosMarker() ; getLinkedRef(MimicPosKeyword);It should be placed y axis -60 of the mimic
		Xaxis = 0
		Yaxis = -60
		Utility.Wait(0.5)
		AngleZ = Self.GetAngleZ()
		rMoveX = (Math.sin(AngleZ) * Yaxis) + (Math.cos(AngleZ) * Xaxis)
		rMoveY = (Math.cos(AngleZ) * Yaxis) - (Math.sin(AngleZ) * Xaxis)
		rMoveZ = -10.0;I have no idea but it seems the actor always gets +10.0 z axis.
		
		PosXmarker.MoveTo(self, rMoveX, rMoveY, rMoveZ)
		PosXmarker.setangle(0, 0, AngleZ)
		
		if PosXmarker
			akactor.SetVehicle(PosXmarker)
			akactor.MoveTo(PosXmarker)
		endif
		LockPosition = true
EndFunction

Function FireVoreInstantTrap()
	isFiring = True
			;play windup sound

	wait( initialDelay )		;wait for windup
	;TRACE("Initial Delay complete")
	
	if (fireOnlyOnce == True)	;If this can be fired only once then disarm
		btrapDisarmed = True
	endif
	actorref.SheatheWeapon()
	SetCoordinates(actorref)
	wait( initialDelay )
	PlayAnimation("TriggerVoreInstant")
	actorref.playidle(MimicVoreInstant)
	WaitForAnimationEvent("TransVoreInstant")
	actorref.playidle(MimicVoreIdle)
	Wait(1.0)
	GetTriggerBox().DesignateTarget(actorref)
	GotoState("VoreInstantQTE")
	;SuccessInstantVore()
EndFunction

Function FireVoreSimpleTrap()
	isFiring = True
			;play windup sound
	if (TNTRController as TNTRControllerScript).RemoveHeelEffect(actorref)
		RemoveHeel = true
	endif
	wait( initialDelay )		;wait for windup
	;TRACE("Initial Delay complete")
	
	if (fireOnlyOnce == True)	;If this can be fired only once then disarm
		btrapDisarmed = True
	endif
	actorref.SheatheWeapon()
	actorref.addtofaction(MimicVoreDefaultFaction);for oar
	SetCoordinates(actorref)
	StartGame( 0 )
	wait( initialDelay )
	PlayAnimation("TriggerVoreStart")
	actorref.playidle(MimicVoreStart)
	WaitForAnimationEvent("TransVoreStart")
	actorref.playidle(MimicVoreLoop)
	;actorref.moveto(PosXmarker)
	;Wait(1.0)
EndFunction

Function FireVoreSexTrap()
	isFiring = True
			;play windup sound
	if (TNTRController as TNTRControllerScript).RemoveHeelEffect(actorref)
		RemoveHeel = true
	endif
	wait( initialDelay )		;wait for windup
	;TRACE("Initial Delay complete")
	
	if (fireOnlyOnce == True)	;If this can be fired only once then disarm
		btrapDisarmed = True
	endif
	actorref.SheatheWeapon()
	SetCoordinates(actorref)
	wait( initialDelay )
	PlayAnimation("TriggerVoreStart")
	actorref.playidle(MimicVoreStart)
	PlayVoice(ActorRef, 30, 50, 3.0)
	WaitForAnimationEvent("TransVoreStart")
	actorref.playidle(MimicVoreLoop)
	;actorref.moveto(PosXmarker)
	(TNTRController as TNTRControllerScript).CheckArmor(actorref)
	StartGame(0) ; TODO if "fast-start"
	; Wait(1.0)
EndFunction

Function FailVore()
	PlayVoiceInstantStop()
	PlayAnimation("TransVoreLooptoFail")
	actorref.playidle(MimicVoreEndFail)
	WaitForAnimationEvent("TransVoreEndFail")
	if RemoveHeel
		(TNTRController as TNTRControllerScript).ResetHeelEffect(actorref)
	endif
	ResetTrap()
EndFunction

Function PrefaceVorePhase02()
	PlayVoiceInstantStop()
	PlayAnimation("TransVoreStage02Loop")
	actorref.playidle(MimicVoreStage02EndPreface)
	WaitForAnimationEvent("TransVoreStage02EndPreface");This goes to VoreInert state again.
	actorref.playidle(MimicVoreIdle)
	actorref.moveto(GetPosMarker())
EndFunction

Function FailVorePhase02()
	PrefaceVorePhase02()
	PlayVoice(ActorRef, 80, 2, 3.5)
	Wait(5.0)
	PlayAnimation("TriggerVoreStage02Fail")
	actorref.playidle(MimicVoreStage02Fail)
	WaitForAnimationEvent("TransVoreStage02Fail")
	actorref.playidle(MimicVoreIdle)
	
	(TNTRController as TNTRControllerScript).SetMorphValue(actorref, 0.0, 1)
	(TNTRController as TNTRControllerScript).SetMorphValue(actorref, 0.0, 2)
	(TNTRController as TNTRControllerScript).SetMorphValue(actorref, 0.0, 3)
	Wait(10.0)
	
	PlayAnimation("TriggerVoreSpit")
	actorref.playidle(MimicVoreSpit)
	
	WaitForAnimationEvent("TransPlay")
	
	if RemoveHeel
		(TNTRController as TNTRControllerScript).ResetHeelEffect(actorref)
	endif
	Wait(6.0)
	actorref.playidle(MimicVoreGetUpAfterSpit)
	ResetTrap()
EndFunction

Function SuccessVore()
	PlayVoiceInstantStop()
	actorref.moveto(GetPosMarker())
	;actorref.MoveTo(self, rMoveX, rMoveY, rMoveZ)
	if actorref.isinfaction(MimicVoreDefaultFaction)
		PlayAnimation("TransVoreLooptoSuccessDefault")
		actorref.playidle(MimicVoreEndSuccessDefault)
		WaitForAnimationEvent("TransVoreEndSuccessDefault")
		actorref.playidle(MimicVoreIdle)
	else
		form thisarmor = (TNTRController as TNTRControllerScript).FindArmorFromList(actorref, "tntr.removelower", false)
		Debug.Trace("thisarmor " + thisarmor + " actorref " + actorref)
		PlayVoice(ActorRef, 30, 4, 2.0)
		PlayAnimation("TransVoreLooptoSuccess")
		actorref.playidle(MimicVoreEndSuccess)
		if WaitForAnimationEvent("StripEventLowerA")
			(TNTRController as TNTRControllerScript).SetMorphValue(actorref, 1.0, 2)
			PlayVoice(ActorRef, 30, 1, 3.0)
			actorref.UnequipItem(thisarmor)
		endif
		WaitForAnimationEvent("TransVoreEndSuccess")
		actorref.playidle(MimicVoreEndSuccessLoop)
		(TNTRController as TNTRControllerScript).InflationEventcustom(actorref, 2, 10.0)
		PlayVoice(ActorRef, 40, 3, 3.0)
		Wait(20.0)
		PlayAnimation("TransVoreEndSuccessLoop")
		actorref.playidle(MimicVoreStage02Preface)
		WaitForAnimationEvent("TransVoreStage02Preface");This goes to VoreInert state
		actorref.playidle(MimicVoreIdle)
	endif

;------------------------VoreInert State-------------------------------
;This is where Mimic completely gulped the actor and closed the lid.
;You can put QTE event here along with Mimicshake animation.
;I'll just skip another QTE round this time.
;actorref.MoveTo(self, rMoveX, rMoveY, rMoveZ)

goToState("VoreQTEStage01")


;unequip event
Wait(7.0)
;actorref.MoveTo(self, rMoveX, rMoveY, rMoveZ)
actorref.moveto(GetPosMarker())
;---------------------------------------------------------------
	

EndFunction

bool property banimating = false auto hidden

Function MimicShake()
	;Null
EndFunction

Function SetMorphValueZero()
	(TNTRController as TNTRControllerScript).SetMorphValue(actorref, 0.0, 1)
	(TNTRController as TNTRControllerScript).SetMorphValue(actorref, 0.0, 2)
	(TNTRController as TNTRControllerScript).SetMorphValue(actorref, 0.0, 3)
EndFunction

State VoreQTEStage01
	Event OnBeginState()
		actorref.moveto(GetPosMarker())
		Wait(7.0)
		PlayVoice(ActorRef, 30, 3, 3.0)
		playAnimationAndWait("TriggerMimicShake","TransMimicShake01");Mimic shake goes back to VoreInert State.
		; GetTriggerBox().FireQTE(self);QTE
		StartGame( 1 )
	endEvent

	Function MimicShake()
		if !banimating
			banimating = true
			playAnimationAndWait("TriggerMimicShake","TransMimicShake01")
			banimating = false
		endif
	EndFunction

	Function FailVore()
		while banimating
			Wait(1.0)
		endwhile
		PlayVoice(ActorRef, 80, 2, 3.5)
		Wait(1.0)
		SetMorphValueZero()
		Wait(3.0)
		PlayAnimation("TriggerVoreSpit")
		actorref.playidle(MimicVoreSpit)
		WaitForAnimationEvent("TransPlay")
		if RemoveHeel
			(TNTRController as TNTRControllerScript).ResetHeelEffect(actorref)
		endif
		Wait(6.0)
		actorref.playidle(MimicVoreGetUpAfterSpit)
		ResetTrap()
	EndFunction

	Function SuccessVore()
		while banimating
			Wait(1.0)
		endwhile
		playAnimationAndWait("TriggerMimicShake","TransMimicShake01")
		(TNTRController as TNTRControllerScript).Getnaked(actorref, true, true)
		PlayVoice(ActorRef, 40, 3, 3.0)
		playAnimationAndWait("TriggerMimicShake","TransMimicShake01")
		PlayAnimation("TriggerMimicThrowup");it spits skull
		WaitForAnimationEvent("EventMimicThrowup")
		DispenseArmor("tntr.removeupper", true)
		WaitForAnimationEvent("TransMimicThrowup")
		GotoState("VoreQTEStage02")
	EndFunction
EndState

State VoreQTEStage02
	Event OnBeginState()
		PlayVoice(ActorRef, 30, 3, 3.0)
		playAnimationAndWait("TriggerMimicShake","TransMimicShake01");Mimic shake goes back to VoreInert State.
		; GetTriggerBox().FireQTE(self);QTE
		StartGame( 2 )
	endEvent

	Function MimicShake()
		if !banimating
			banimating = true
			playAnimationAndWait("TriggerMimicShake","TransMimicShake01")
			banimating = false
		endif
	EndFunction

	Function FailVore()
		while banimating
			Wait(1.0)
		endwhile
		PlayVoice(ActorRef, 80, 2, 3.5)
		Wait(1.0)
		SetMorphValueZero()
		Wait(3.0)
		PlayAnimation("TriggerVoreSpit")
		actorref.playidle(MimicVoreSpit)
		WaitForAnimationEvent("TransPlay")
		if RemoveHeel
			(TNTRController as TNTRControllerScript).ResetHeelEffect(actorref)
		endif
		Wait(6.0)
		actorref.playidle(MimicVoreGetUpAfterSpit)
		ResetTrap()
	EndFunction	

	Function SuccessVore()
		while banimating
			Wait(1.0)
		endwhile
		if actorref.isinfaction(MimicVoreDefaultFaction)
			playAnimationAndWait("TriggerMimicBurp","TransMimicBurp");Digestion complete

			PlayAnimation("TriggerVoreSpit");This is test so it doesn't actually kill the actor.
			actorref.playidle(MimicVoreSpit)
			
			;actorref.kill()
			
			WaitForAnimationEvent("TransPlay")
			if RemoveHeel
				(TNTRController as TNTRControllerScript).ResetHeelEffect(actorref)
			endif
			actorref.playidle(MimicVoreGetUpAfterSpit)
			ResetTrap()
		else
			(TNTRController as TNTRControllerScript).InflationEventcustom(actorref, 6, 0.5)
			(TNTRController as TNTRControllerScript).SetMorphValue(actorref, 1.0, 1)
			(TNTRController as TNTRControllerScript).SetMorphValue(actorref, 1.0, 2)
			PlayVoice(ActorRef, 30, 30, 4.0)
			PlayAnimation("TriggerVoreStage02Start");Phase 02 start
			actorref.playidle(MimicVoreStage02Start)
			WaitForAnimationEvent("TransVoreStage02Start")
			actorref.playidle(MimicVoreStage02Loop)
			Wait(15.0)
			actorref.moveto(GetPosMarker())
			PlayVoiceInstantStop()
			PlayAnimation("TransVoreStage02Loop")
			actorref.playidle(MimicVoreStage02EndPreface)
			WaitForAnimationEvent("TransVoreStage02EndPreface");This goes to VoreInert state again.
			actorref.playidle(MimicVoreIdle)
			(TNTRController as TNTRControllerScript).InflationEventcustom(actorref, 6, 0.5);Anal and Oral
			GotoState("VoreQTEStage03")
			;GetTriggerBox().FireVorePhase02(self);QTE
		endif
	EndFunction

EndState

State VoreQTEStage03
	Event OnBeginState()
		PlayVoice(ActorRef, 30, 3, 3.0)
		playAnimationAndWait("TriggerMimicShake","TransMimicShake01");Mimic shake goes back to VoreInert State.
		; GetTriggerBox().FireQTE(self);QTE
		StartGame( 3 )
	endEvent

	Function MimicShake()
		if !banimating
			banimating = true
			playAnimationAndWait("TriggerMimicShake","TransMimicShake01")
			banimating = false
		endif
	EndFunction

	Function FailVore()
		while banimating
			Wait(1.0)
		endwhile
		PlayVoice(ActorRef, 80, 2, 3.5)
		Wait(1.0)
		SetMorphValueZero()
		Wait(3.0)
		PlayAnimation("TriggerVoreSpit")
		actorref.playidle(MimicVoreSpit)
		WaitForAnimationEvent("TransPlay")
		if RemoveHeel
			(TNTRController as TNTRControllerScript).ResetHeelEffect(actorref)
		endif
		Wait(6.0)
		actorref.playidle(MimicVoreGetUpAfterSpit)
		ResetTrap()
	EndFunction	

	Function SuccessVore()
		while banimating
			Wait(1.0)
		endwhile
		(TNTRController as TNTRControllerScript).InflationEventcustom(actorref, 1, 1.0)
		(TNTRController as TNTRControllerScript).SetMorphValue(actorref, 1.0, 1)
		(TNTRController as TNTRControllerScript).SetMorphValue(actorref, 1.0, 2)
		(TNTRController as TNTRControllerScript).SetMorphValue(actorref, 1.0, 3)

		Wait(5.0)
		PlayVoice(ActorRef, 80, 20, 3.0)
		PlayAnimation("TriggerVoreSexA01")
		actorref.playidle(MimicVoreSexEnter)
		WaitForAnimationEvent("TransVoreSex")
		actorref.playidle(MimicVoreSexLoop)
		Wait(20.0)
		PlayAnimation("TriggerVoreSexA02")
		actorref.playidle(MimicVoreSexStop)
		WaitForAnimationEvent("TransVoreStage02EndPreface")
		actorref.playidle(MimicVoreIdle)
		PlayVoiceInstantStop()
		Wait(5.0)
		PlayVoice(ActorRef, 30, 2, 2.0)
		(TNTRController as TNTRControllerScript).InflationEventcustom(actorref, 1, 2.0)
		GotoState("VoreQTEStage04")
	EndFunction

EndState

State VoreQTEStage04
	Event OnBeginState()
		PlayVoice(ActorRef, 30, 3, 3.0)
		playAnimationAndWait("TriggerMimicShake","TransMimicShake01");Mimic shake goes back to VoreInert State.
		StartGame( 4 )
	endEvent

	Function MimicShake()
		if !banimating
			banimating = true
			playAnimationAndWait("TriggerMimicShake","TransMimicShake01")
			banimating = false
		endif
	EndFunction

	Function FailVore()
		while banimating
			Wait(1.0)
		endwhile
		PlayVoice(ActorRef, 80, 2, 3.5)
		Wait(1.0)
		SetMorphValueZero()
		Wait(3.0)
		PlayAnimation("TriggerVoreSpit")
		actorref.playidle(MimicVoreSpit)
		WaitForAnimationEvent("TransPlay")
		if RemoveHeel
			(TNTRController as TNTRControllerScript).ResetHeelEffect(actorref)
		endif
		Wait(6.0)
		actorref.playidle(MimicVoreGetUpAfterSpit)
		ResetTrap()
	EndFunction	

	Function SuccessVore()
		while banimating
			Wait(1.0)
		endwhile
		(TNTRController as TNTRControllerScript).InflationEventcustom(actorref, 1, 5.0)
		(TNTRController as TNTRControllerScript).SetMorphValue(actorref, 1.0, 1)
		(TNTRController as TNTRControllerScript).SetMorphValue(actorref, 1.0, 2)
		(TNTRController as TNTRControllerScript).SetMorphValue(actorref, 1.0, 3)

		Wait(5.0)
		PlayVoice(ActorRef, 80, 20, 3.0)
		PlayAnimation("TriggerVoreStage02Success")
		actorref.playidle(MimicVoreStage02Success)
		WaitForAnimationEvent("TransVoreStage02Success")
		actorref.playidle(MimicVoreStage02SuccessLoop)
		
		Wait(30.0)
		actorref.moveto(GetPosMarker())
		Wait(1.0)
		
		PlayAnimation("TransVoreStage02SuccessLoop")
		actorref.playidle(MimicVoreStage02Finale)
		PlayVoiceInstantStop()
		WaitForAnimationEvent("TransVoreStage02Finale")
		actorref.playidle(MimicVoreIdle)
		(TNTRController as TNTRControllerScript).SetMorphValue(actorref, 0.0, 1)
		(TNTRController as TNTRControllerScript).SetMorphValue(actorref, 0.0, 2)
		(TNTRController as TNTRControllerScript).SetMorphValue(actorref, 0.0, 3)
		PlayVoice(ActorRef, 30, 2, 2.0)
		(TNTRController as TNTRControllerScript).InflationEventcustom(actorref, 7, 15.0)
		
		Wait(10.0)
		
		PlayAnimation("TriggerVoreSpit")
		actorref.playidle(MimicVoreSpit)
		WaitForAnimationEvent("TransPlay")
		if RemoveHeel
			(TNTRController as TNTRControllerScript).ResetHeelEffect(actorref)
		endif
		ResetTrap()
	EndFunction

EndState

State VoreInstantQTE
	Event OnBeginState()
	(TNTRController as TNTRControllerScript).InflationEventcustom(actorref, 2, 10.0)
	Wait(7.0)
	playAnimationAndWait("TriggerMimicShake","TransMimicShake01");Mimic shake goes back to VoreInert State.
	Wait(3.0)
	playAnimationAndWait("TriggerMimicShake","TransMimicShake01")
	;unequip event
	Wait(7.0)

	PlayAnimation("TriggerVoreStage02Start");Phase 02 start
	actorref.playidle(MimicVoreStage02Start)
	WaitForAnimationEvent("TransVoreStage02Start")
	actorref.playidle(MimicVoreStage02Loop)
	actorref.moveto(GetPosMarker())
	StartGame( 1 )
	endEvent

	Function FailVore()
		PrefaceVorePhase02()
		PlayVoice(ActorRef, 80, 2, 3.5)
		Wait(1.0)
		SetMorphValueZero()
		Wait(3.0)
		PlayAnimation("TriggerVoreSpit")
		actorref.playidle(MimicVoreSpit)
		WaitForAnimationEvent("TransPlay")
		if RemoveHeel
			(TNTRController as TNTRControllerScript).ResetHeelEffect(actorref)
		endif
		Wait(6.0)
		actorref.playidle(MimicVoreGetUpAfterSpit)
		ResetTrap()
	EndFunction	

	Function SuccessVore()
		PrefaceVorePhase02()
		(TNTRController as TNTRControllerScript).SetMorphValue(actorref, 1.0, 3)
		Wait(5.0)
		PlayVoice(ActorRef, 80, 20, 3.0)
		PlayAnimation("TriggerVoreStage02Success")
		actorref.playidle(MimicVoreStage02Success)
		WaitForAnimationEvent("TransVoreStage02Success")
		actorref.playidle(MimicVoreStage02SuccessLoop)
		
		Wait(30.0)
		actorref.moveto(GetPosMarker())
		;actorref.MoveTo(self, rMoveX, rMoveY, rMoveZ)
		Wait(10.0)
		
		PlayAnimation("TransVoreStage02SuccessLoop")
		actorref.playidle(MimicVoreStage02Finale)
		PlayVoiceInstantStop()
		WaitForAnimationEvent("TransVoreStage02Finale")
		actorref.playidle(MimicVoreIdle)
		(TNTRController as TNTRControllerScript).SetMorphValue(actorref, 0.0, 1)
		(TNTRController as TNTRControllerScript).SetMorphValue(actorref, 0.0, 2)
		(TNTRController as TNTRControllerScript).SetMorphValue(actorref, 0.0, 3)
		PlayVoice(ActorRef, 30, 2, 2.0)
		(TNTRController as TNTRControllerScript).InflationEventcustom(actorref, 1, 15.0)
		
		Wait(10.0)
		
		PlayAnimation("TriggerVoreSpit")
		actorref.playidle(MimicVoreSpit)
		WaitForAnimationEvent("TransPlay")
		if RemoveHeel
			(TNTRController as TNTRControllerScript).ResetHeelEffect(actorref)
		endif
		ResetTrap()
	EndFunction


EndState

Event onReset()
	goToState("EndPhase")
	self.reset()
endEvent

event OnTriggerEnter(objectReference TriggerRef)
endEvent
	
event OnActivate(objectReference TriggerRef)
endEvent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
EndEvent

event onLoad()
	BakahitBase = (self as objectReference) as BakaTrapHitBase
	ResolveLeveledDamage()
	if StartOpen
		playAnimationAndWait("TriggerMimicShake","TransMimicShake01")
		Wait(1.0)
		playAnimation("Reset")
		goToState("Ready")
	endif
endEvent

state EndPhase
	Event OnBeginState()
	endEvent
	
	event OnTriggerEnter(objectReference TriggerRef)
	endEvent
	
	event OnActivate(objectReference TriggerRef)
		playAnimation("Reset")
	endEvent
endState

State Dead
	Event OnBeginState()
	endEvent
	
	event OnTriggerEnter(objectReference TriggerRef)
	endEvent
	
	event OnActivate(objectReference TriggerRef)
		goToState("Open")
	endEvent
endstate

State Open
	Event OnBeginState()
		isfiring = true
		playAnimationAndWait("TriggerOpen","TransOpen")
		;Open Inventory
		isfiring = false
	endEvent
	
	event OnTriggerEnter(objectReference TriggerRef)
	endEvent
	
	event OnActivate(objectReference TriggerRef)
		if !isfiring
			goToState("Close")
		endif
	endEvent
Endstate

state Close
	Event OnBeginState()
		isfiring = true
		playAnimationAndWait("TransOpenIdle","TransClose")
		isfiring = false
		playAnimation("Reset")
		goToState("Ready");Go to ready state. Recycle the trap
	endEvent
	
	event OnTriggerEnter(objectReference TriggerRef)
	endEvent
	
	event OnActivate(objectReference TriggerRef)
	endEvent
endState

auto State Ready

	Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
		if !isfiring
			isfiring == true
			Mimichitcount += 1
			
			if MimicHealth >= Mimichitcount
				;DeadSound WIP
				playAnimationAndWait("TriggerDie","TransDie01")
				goToState("Dead")
			else
				playAnimationAndWait("TriggerAttack","TransPlay")
				;HitSound WIP
			endif
			isfiring = false
		endif
		
	EndEvent

	Event OnBeginState()
		isfiring = false
		PlayAnimation("Reset")
		playerRef = Game.GetPlayer()
	endEvent
	
	event OnTriggerEnter(objectReference TriggerRef)
	endEvent

	event OnActivate(objectReference TriggerRef)
	Debug.Trace("OnActivate 6 "  + (triggerRef as Form)  + " "  + (playerRef as Form))
	TNTRDoNothing = Game.GetFormFromFile( 0x0885, "TNTR.esp") as Package
	int itrigger
	if !isfiring
		if MimicType == 2
			itrigger = acceptableTrigger(TriggerRef)
		else
			itrigger = MimicType
			actorref = triggerRef as actor
		endif
		Debug.Trace(itrigger + " " + btrapDisarmed)
		if itrigger == 1
			if btrapDisarmed
				goToState("ShakeBusy")
			else
				goToState("VoreStartDefaultState")
			endif
		elseif itrigger == 2
			if btrapDisarmed
				goToState("AttackBusy")
			else
				goToState("VoreStartState")
			endif
		elseif itrigger == 3
			if btrapDisarmed
				goToState("AttackBusy")
			else
				goToState("VoreInstantState")
			endif
		else
			goToState("AttackBusy")
		endif
	endif
	endEvent

	Function MimicTest()
		int itrigger = acceptableTrigger(PlayerRef)
			if itrigger == 1
				goToState("ShakeBusy")
			elseif itrigger == 2
				if btrapDisarmed
					goToState("AttackBusy")
				else
					goToState("VoreStartState")
				endif
			elseif itrigger == 3
				goToState("AttackBusy")
			endif
	EndFunction

EndState

state VoreStartDefaultState
	Event OnBeginState()
		FireVoreSimpleTrap()
	endEvent

	event OnTriggerEnter(objectReference TriggerRef)
	endEvent
	
	event OnActivate(objectReference TriggerRef);WIP
	endEvent
endState

state VoreStartState
	Event OnBeginState()
		FireVoreSexTrap()
	endEvent

	event OnTriggerEnter(objectReference TriggerRef)
	endEvent
	
	event OnActivate(objectReference TriggerRef);WIP
	endEvent
endState

state VoreInstantState
	Event OnBeginState()
		FireVoreInstantTrap()
	endEvent

	event OnTriggerEnter(objectReference TriggerRef)
	endEvent
	
	event OnActivate(objectReference TriggerRef);WIP
	endEvent
endState

State Busy	;Dummy state to prevent interaction while animating
	Event OnBeginState()
	endEvent
	event OnActivate(objectReference TriggerRef)
	endevent
EndState

State AttackBusy
	Event OnBeginState()
		;playAnimationAndWait("TriggerAttack","TransPlay")
		PlayAnimation("TriggerAttack")
		;WaitForAnimationEvent(startDamage)
		BakahitBase.goToState("CanHit")
		;finishedPlaying = True
		WaitForAnimationEvent(stopDamage)
		BakahitBase.goToState("CannotHit")
		WaitForAnimationEvent("TransPlay")
		goToState("Ready")
	endEvent
	event OnActivate(objectReference TriggerRef)
	endevent
EndState

State ShakeBusy
	Event OnBeginState()
		playAnimationAndWait("TriggerMimicShake","TransMimicShake01")
		Utility.wait(0.1)
		playAnimation("Reset")
		goToState("Ready")
	endEvent
	event OnActivate(objectReference TriggerRef)
	endevent
EndState

;==========================================================

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

Function PlayVoice(actor akactor, int VoiceStrength = 80, int numcount = 1, float interval = 3.5)
icount = numcount
finterval = interval
iVoiceStrength = VoiceStrength
VoiceActor = akactor
Registerforsingleupdate(0.1)
EndFunction

Function PlayVoiceInstantStop()
	icount = 0
	VoiceActor = none
EndFunction

Event Onupdate()
	if VoiceActor
		(TNTRController as TNTRControllerScript).PlayVoice(VoiceActor, true, iVoiceStrength)
	endif
	if icount > 0
		icount -= 1
		Registerforsingleupdate(finterval)
	endif
EndEvent