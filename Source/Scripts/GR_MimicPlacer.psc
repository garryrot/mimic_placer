Scriptname GR_MimicPlacer extends Quest Hidden 

; Dependencies: Papyrus Utils AE/SE for JsonUtil.GetFormValue  -  https://www.nexusmods.com/skyrimspecialedition/mods/13048
; PO3s Papyrus Extender             for adding XMarkers 

Bool VoreStarted = false

; ---- Base Game
Actor PlayerRef
Form XMarkerForm
Form XMarkerHeadingForm

; ---- Baka
Faction VoreFaction

Keyword BakaMimicDispenseKeyword
Keyword BakaMimicPosKeyword

Form BakaMimicForm
Form BakaTrapTriggerBoxForm

; ---- "Boss Chest" Clutter\Ruins\Ruins_LargeChest	--- RefCount

; High Hrothgar Chest -> Replace it with Snowy
; HHChest01 "Chest" [CONT:00099D87] 					1

; E3DemoTrollChest "Chest" [CONT:00099A50]				1
; DEMODraugrChestLarge02 "Chest" [CONT:000BCD2C]		0
; DEMODraugrChestLarge04 "Chest" [CONT:000BCD2F]		0
; TreasAfflictedChestBoss "Chest" [CONT:0008EA5D]		0
; TG04GulumEiKillChest "Chest" [CONT:000EF578]			1
; TreasBanditChestBossEMPTY "Chest" [CONT:0007AA90] 	1
; TreasWerewolfChestBoss "Chest" [CONT:00020661]    	2
; TreasDraugrChestEMPTYLarge "Chest" [CONT:00020672] 	2
; LargeChestNoRespawn "Chest" [CONT:000F8476]			2

; ----
; TreasCWImperialChestBossLarge "Chest" [CONT:0008B1F0] 3
; TreasCWSonsChestBossLarge "Chest" [CONT:0008B1F1]		3
; TreasOrcChestBoss "Chest" [CONT:000774C9]				5
; TreasGiantChestBoss "Chest" [CONT:000774BF]			7
; TreasForswornChestBoss "Chest" [CONT:00020658] 		8
; TreasHagravenChestBoss "Chest" [CONT:00020667]		13
; TreasVampireChestBoss "Chest" [CONT:00020664] 		14
; TreasWarlockChestBoss "Chest" [CONT:0002065D]			22
; TreasBanditChestBoss "Chest" [CONT:0002064F]			81
; TreasDraugrChestBoss "Chest" [CONT:00020671]			67

; ---- DLC
; DLC2TreasRieklingChestBoss "Chest" [CONT:04025E46]	7
; DLC2TreasBanditChestBoss "Chest" [CONT:0402AABF]		7
; DLC2TreasDraugrChestBoss "Chest" [CONT:0402AAC2]		8

Event OnInit()
	Maintenance()
EndEvent

ObjectReference Function GetNearestViableContainer()
	ObjectReference foundRef = Game.FindClosestReferenceOfType(Game.GetForm(0x2064F), PlayerRef.GetPositionX(), PlayerRef.GetPositionY(), PlayerRef.GetPositionZ(), 500.0)
 	return foundRef
EndFunction

ObjectReference Function GetNextViableContainers()
	ObjectReference foundRef = Game.FindRandomReferenceOfTypeFromRef(Game.GetForm(0x2064F), PlayerRef, 4000.0)
 	return foundRef
EndFunction

Function Maintenance()
	PlayerRef = Game.GetPlayer()
	XMarkerForm = Game.GetForm(0x3B)
	XMarkerHeadingForm = Game.GetForm(0x34)

	Spell debugSpell = Game.GetFormFromFile(0xAA01, "GR_MimicPlacer.esp") as Spell
	If !Game.GetPlayer().HasSpell(debugSpell)
		Game.GetPlayer().AddSpell(debugSpell)
	EndIf

    VoreFaction = Game.GetFormFromFile(0xE05, "TNTR.esp") as Faction
    If !VoreFaction
        Debug("VoreAction not found for configured formID")
    EndIf

	BakaMimicForm = Game.GetFormFromFile(0x8e0, "TNTR.esp")
	If !BakaMimicForm
        Debug("BakaMimicForm not found for configured formID")
	EndIf

	BakaTrapTriggerBoxForm = Game.GetFormFromFile(0x83E, "TNTR.esp")
	If !BakaTrapTriggerBoxForm
        Debug("BakaTrapTriggerBoxForm not found for configured formID")
	EndIf

	BakaMimicDispenseKeyword = Game.GetFormFromFile(0xDFE, "TNTR.esp") as Keyword
	If !BakaMimicDispenseKeyword
        Debug("MimicDispenseKeyword not found for configured formID")
	EndIf

	BakaMimicPosKeyword = Game.GetFormFromFile(0x8F2, "TNTR.esp") as Keyword
	If !BakaMimicPosKeyword
        Debug("BakaMimicPosKeyword not found for configured formID")
	EndIf

    RegisterForAnimationEvent(PlayerRef, "MimicVoreSpitLoop")
    RegisterForAnimationEvent(PlayerRef, "DeathWormVoreSuccessLoop")

	; SnareRopeActivateLoop
	; SnareRopeUndoSelfFailEvent

	RegisterForModEvent("GRMP_VoreStarted", "OnVoreEvent")
	RegisterForModEvent("GRMP_VoreSuccess", "OnVoreEvent")
	RegisterForModEvent("GRMP_VoreFail", "OnVoreEvent")
	
    UnregisterForUpdate()
    RegisterForSingleUpdate(2.0)

	Debug("maintenance done")
EndFunction

Event OnVoreEvent(String eventName, String strArg, Float numArg, Form sender)
	Debug("AE" + eventName)
EndEvent

Function OnAnimationEvent(objectreference akSource, String asEventName) 
    Debug.MessageBox("MQ Anim " + asEventName)
EndFunction

Bool mimicObserved = false
Event OnUpdate()
	BakaTrapMimic mimicTrap = Game.FindClosestReferenceOfType(BakaMimicForm, PlayerRef.GetPositionX(), PlayerRef.GetPositionY(), PlayerRef.GetPositionZ(), 200.0) as BakaTrapMimic
	If !mimicTrap
		mimicObserved = false
	EndIf
	If mimicTrap && ! mimicObserved
		mimicObserved = true
		Debug("Observing FormId Ref " + mimicTrap.GetFormID())
		RegisterForAnimationEvent(mimicTrap, "TriggerVoreStart")
		RegisterForAnimationEvent(mimicTrap, "TriggerVoreInstant")
		RegisterForAnimationEvent(mimicTrap, "TriggerMimicShake")
		RegisterForAnimationEvent(mimicTrap, "TriggerMimicThrowup")
		RegisterForAnimationEvent(mimicTrap, "TriggerVoreSpit")
		RegisterForAnimationEvent(mimicTrap, "TriggerVoreMimicBurp")
		RegisterForAnimationEvent(mimicTrap, "TriggerVoreSexA01")
		RegisterForAnimationEvent(mimicTrap, "TriggerVoreSexA02")
	EndIf

    If (PlayerRef.IsInFaction(VoreFaction))
        If !VoreStarted
			VoreStarted = true
			SendModEvent("GRMP_VoreStarted")
        Else
            Debug.Trace("Still in vore")
        EndIf
    Else
        If (VoreStarted)
			VoreStarted = false
			SendModEvent("GRMP_VoreFail")
        Else
            Debug.Trace("Not in faction")
        EndIf
    EndIf
    RegisterForSingleUpdate(2.0)
EndEvent

ObjectReference Function ReplaceWithMimic(ObjectReference target)
	target.DisableNoWait()
	ObjectReference mimic = target.PlaceAtMe(BakaMimicForm)

	BakaTrapTriggerBox box = mimic.PlaceAtMe(BakaTrapTriggerBoxForm) as BakaTrapTriggerBox
	box.TrapType = 2 ; 2 => Mimic
	box.VoreTrapref = mimic
	PO3_SKSEFunctions.SetLinkedRef(mimic, box)
	Debug("Placed trigger box " + box)

	ObjectReference DispenseXmarker = mimic.PlaceAtMe(XMarkerForm)
	ObjectReference x = PO3_SKSEFunctions.SetLinkedRef(mimic, DispenseXmarker, BakaMimicDispenseKeyword)
	Debug("Placed Dispense Marker " + x)

	ObjectReference PosXmarker = mimic.PlaceAtMe(XMarkerHeadingForm) 
	x = PO3_SKSEFunctions.SetLinkedRef(mimic, PosXmarker, BakaMimicPosKeyword)
	Debug("Placed Position Marker " + x)
	return mimic
EndFunction

Function Debug(String msg)
	Debug.Trace("[GRMP] " + msg)
	Debug.Notification("[GRMP] " + msg)
EndFunction