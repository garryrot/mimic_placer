Scriptname GR_PlaceMimicEffect extends ActiveMagicEffect  

; MimicPosKeyword [KYWD:050008F2]
; MimicDispenseKeyword [KYWD:05000DFE]

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

Event OnEffectStart(Actor target, Actor caster)
	GR_MimicPlacer mainQuest = Game.GetFormFromFile( 0x5900, "GR_MimicPlacer.esp" ) as GR_MimicPlacer

	ObjectReference result = mainQuest.GetNextViableContainers()
	Debug.Notification("Replacing " + result)
	Debug.Notification("Created Mimic " + ReplaceWithMimic(result))
EndEvent

ObjectReference Function ReplaceWithMimic(ObjectReference target)
	target.DisableNoWait()
	ObjectReference mimic = target.PlaceAtMe(Game.GetFormFromFile(0x8e0, "TNTR.esp"))

	BakaTrapTriggerBox box = mimic.PlaceAtMe(Game.GetFormFromFile(0x83E, "TNTR.esp")) as BakaTrapTriggerBox
	box.TrapType = 2 ; 2 => Mimic
	box.VoreTrapref = mimic
	PO3_SKSEFunctions.SetLinkedRef(mimic, box)
	Debug.Trace("[GRMP] Placed trigger box " + box)

	ObjectReference DispenseXmarker = mimic.PlaceAtMe(Game.GetForm(0x3B)) ; Form: XMaker
	ObjectReference x = PO3_SKSEFunctions.SetLinkedRef(mimic, DispenseXmarker, Game.GetFormFromFile(0xDFE, "TNTR.esp") as Keyword) ; MimicDispenseKeyword)
	Debug.Trace("[GRMP] Placed Dispense Marker " + x)

	ObjectReference PosXmarker = mimic.PlaceAtMe(Game.GetForm(0x34)) ; Form: XMarkerHeading
	x = PO3_SKSEFunctions.SetLinkedRef(mimic, PosXmarker, Game.GetFormFromFile(0x8F2, "TNTR.esp") as Keyword) ; MimicPosKeyword
	Debug.Trace("[GRMP] Placed Position Marker " + x)
	return mimic
EndFunction
