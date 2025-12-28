ScriptName GR_MimicScanner extends Quest Hidden 

GR_MimicPlacer Property lib Auto ; GR_MimicPlacer
Actor Property PlayerRef Auto
FormList Property LargeChestForms Auto ; Boss Chests (Any form with Clutter\Ruins\Ruins_LargeChest)
; FormList Property MimicForms Auto ; TODO

String DistributionConfig = "../MimicPlacer/Distribution.json"

; Config
Float ScanInterval = 30.0
Float ScanRadius = 10000.0
Float ScanRadiusExterior = 20000.0 ; unused
Float MimicChance = 0.5
Float Weight1Vore = 20.0 ; Vore
Float Weight2Vore = 80.0 ; Sex
Float Weight3Vore = 20.0 ; Instant-Vore
int cheatNotifyMimics = 0

; Keep track of processed chest reference IDs so that each chest is only 
; rolled for once, to prevent re-rolling until every chest is a mimic.
; Should work okay'ish as there's only 200 viable chests in the entire game
Int[] KnownChests
Int KCI = 0
Int KnownChestBufferSize = 128

; Keep track of all created mimics for debugging and potential cleanup
ObjectReference[] PlacedMimics
Cell[] PlacedMimicLocs
Int PMI = 0

Event OnInit()
	Maintenance()
EndEvent

Function Maintenance()
    Debug("Maintenance()")
	If !KnownChests
        ResetChests()
	Endif
	ProcessCellLock = false ; Just in case it gets stuck
	Init = True
	RegisterForSingleUpdate(0.1)
EndFunction

Bool Init = False
Event OnUpdate()
	Debug("OnUpdate()")
	If Init
		Init = False
		cheatNotifyMimics = JsonUtil.GetIntValue(DistributionConfig, "cheat-notify-mimics")
		ScanRadius = JsonUtil.GetFloatValue(DistributionConfig, "scan-radius")
		ScanRadiusExterior = JsonUtil.GetFloatValue(DistributionConfig, "scan-radius-outside")
		ScanInterval = JsonUtil.GetFloatValue(DistributionConfig, "scan-interval")
		MimicChance = JsonUtil.GetFloatValue(DistributionConfig, "mimic-chance")
		Weight1Vore = JsonUtil.GetFloatValue(DistributionConfig, "mimic-weight-vore")
		Weight2Vore = JsonUtil.GetFloatValue(DistributionConfig, "mimic-weight-sex")
		Weight3Vore = JsonUtil.GetFloatValue(DistributionConfig, "mimic-weight-instant")
		Debug("Init settings ScanInterval=" + ScanInterval + " ScanRadius=" + ScanRadius + " MimicChance=" + MimicChance)
	Else
		If Utility.GetCurrentRealTime() - lastProcessCells > ScanInterval
			ProcessCell()
		Else
			Float secUntil = ScanInterval - (Utility.GetCurrentRealTime() - lastProcessCells)
			Debug("last scna too early, scanning in " + secUntil + "s current-time=" + Utility.GetCurrentRealTime() + " last-scan=" + lastProcessCells)
			RegisterForSingleUpdate(secUntil)
		EndIf
	EndIf
	UnregisterForUpdate()
	RegisterForSingleUpdate(ScanInterval)
EndEvent

Function ResetChests()
	Debug("ResetChests() - resetting known chest...")
	KCI = 0
	PMI = 0
	KnownChestBufferSize = 128
	KnownChests = new Int[128]
	PlacedMimics = new ObjectReference[128]
	PlacedMimicLocs = new Cell[128]
EndFunction

Bool ProcessCellLock = False
Float lastProcessCells = 0.0
Function ProcessCell()
    If !ProcessCellLock
        ProcessCellLock = true
        PlaceMimicsInRadius()
        ; FixBakaMimicsInRadius()
		lastProcessCells = Utility.GetCurrentRealTime()
        ProcessCellLock = false
	Else
		Debug("Locked")
    EndIf
EndFunction

; Search for viable boss chests using 'FindRandomReference' and replace them with a mimic
Function PlaceMimicsInRadius()
	Debug("PlaceMimicsInRadius(): scan-radius=" + ScanRadius + " mimic-chance=" + MimicChance)
	Int visited = 0
	Int skipped = 0
	Int placed = 0

	ObjectReference[] largeChests = PO3_SKSEFunctions.FindAllReferencesOfType(PlayerRef, LargeChestForms, ScanRadius)
	Int i = 0
	While i < largeChests.Length
		ObjectReference largeChest = largeChests[i]
		If !largeChest.IsDisabled() && KnownChests.Find(largeChest.GetFormID()) < 0
			KnownChests[ KCI ] = largeChest.GetFormID()
			KCI += 1
			If KCI >= KnownChestBufferSize
				KCI = 0
			EndIf
			visited += 1
			Debug("Processing chest " + largeChest as Form)
			If Utility.RandomFloat() < MimicChance
				placed += 1
				Float rollType = Utility.RandomFloat(0.0, Weight1Vore + Weight2Vore + Weight3Vore)
				ObjectReference mimic
				If rollType < Weight1Vore
					If cheatNotifyMimics > 0
						Debug.Notification("Mimic created (Vore)")
					EndIf
					mimic = lib.PlaceBakaMimic(largeChest, 1)
				ElseIf rollType < (Weight1Vore + Weight2Vore)
					If cheatNotifyMimics > 0
						Debug.Notification("Mimic created")
					EndIf
					mimic = lib.PlaceBakaMimic(largeChest, 2)
				Else
					If cheatNotifyMimics > 0
						Debug.Notification("Mimic created (Instant Vore)")
					EndIf
					mimic = lib.PlaceBakaMimic(largeChest, 3)
				EndIf
				PlacedMimics[ PMI ] = mimic
				PlacedMimicLocs[ PMI ] = PlayerRef.GetParentCell()
				PMI += 1
				; TODO configurable
				DumpMimics()
				If PMI >= 128
					PMI = 0
					Error("Resetting placed mimics array")
				EndIf
			EndIf
		Else
			skipped += 1
		EndIf
		i += 1
	EndWhile
	Debug("Result - placed=" + placed + " checked=" + visited + " skipped=" + skipped)
EndFunction

; Function FixBakaMimicsInRadius()
; 	Debug("FixBakaMimicsInRadius()")
; 	Int fixed = 0
; 	FormList mimicForms = Game.GetFormFromFile(0x2901C, "GR_MimicPlacer.esp") As FormList ; TODO move to property
; 	ObjectReference[] mimics = PO3_SKSEFunctions.FindAllReferencesOfType(PlayerRef, mimicForms, ScanRadius)
; 	Int i = 0
; 	While i < mimics.Length
; 		BakaTrapMimic mimic = mimics[ i ] as BakaTrapMimic
; 		If mimic
; 			If !(mimic.GetNthLinkedRef(1) as BakaTrapTriggerBox) && \
; 			   ! mimic.GetLinkedRef(lib.BakaMimicDispenseKeyword) && \
; 			   ! mimic.GetLinkedRef(lib.BakaMimicPosKeyword)
; 				Debug("Mimic " + mimic.GetFormID() + " needs fixing")
; 				; lib.FixBakaMimic(mimic)
; 				fixed += 1
; 			EndIf
; 		EndIf
; 		i += 1
; 	EndWhile
; 	Debug(mimics.Length + " mimics found, " + fixed + " fixed...")
; EndFunction

Function DumpMimics()
	Debug("Placed Mimics")
	Int i = 0
	While i < 128
		String loc
		If PlacedMimicLocs[ i ]
			loc = PlacedMimicLocs[ i ].GetName()
		EndIf
		If !loc
			loc = "World"
		EndIf
		If PlacedMimics[ i ] != None
			Debug(i + ": " + PlacedMimics[ i ] as Form + " in " + loc)
		EndIf
		i += 1
	EndWhile
EndFunction

Function Trace(String msg)
	; lib.Debug("SCAN: " + msg)
EndFunction

Function Debug(String msg)
	lib.Debug("SCAN: " + msg)
EndFunction

Function Error(String msg)
	lib.Error("SCAN: " + msg)
EndFunction
