ScriptName GR_MimicScanner extends Quest Hidden 

GR_MimicPlacer Property lib Auto ; GR_MimicPlacer
Actor Property PlayerRef Auto

String DistributionConfig = "../MimicPlacer/Distribution.json"

; Config
Float ScanInterval = 30.0
Float ScanRadiusInterior = 10000.0
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
GR_BakaMimicAddon[] PlacedMimics ; JContainers?
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
		ScanRadiusInterior = JsonUtil.GetFloatValue(DistributionConfig, "scan-radius")
		ScanRadiusExterior = JsonUtil.GetFloatValue(DistributionConfig, "scan-radius-outside")
		ScanInterval = JsonUtil.GetFloatValue(DistributionConfig, "scan-interval")
		MimicChance = JsonUtil.GetFloatValue(DistributionConfig, "mimic-chance")
		Weight1Vore = JsonUtil.GetFloatValue(DistributionConfig, "mimic-weight-vore")
		Weight2Vore = JsonUtil.GetFloatValue(DistributionConfig, "mimic-weight-sex")
		Weight3Vore = JsonUtil.GetFloatValue(DistributionConfig, "mimic-weight-instant")
		Debug("Init settings ScanInterval=" + ScanInterval + " ScanRadiusInterior=" + ScanRadiusInterior + " MimicChance=" + MimicChance)
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
	PlacedMimics = new GR_BakaMimicAddon[128]
EndFunction

Bool ProcessCellLock = False
Float lastProcessCells = 0.0
Function ProcessCell()
    If !ProcessCellLock
        ProcessCellLock = true
        PlaceMimicsInRadius()
		lastProcessCells = Utility.GetCurrentRealTime()
        ProcessCellLock = false
	Else
		Debug("Locked")
    EndIf
EndFunction

; Search for viable boss chests using 'FindRandomReference' and replace them with a mimic
Function PlaceMimicsInRadius()
	Debug("PlaceMimicsInRadius(): scan-radius=" + ScanRadiusInterior + " mimic-chance=" + MimicChance)
	Int visited = 0
	Int skipped = 0
	Int placed = 0

	ObjectReference[] largeChests = PO3_SKSEFunctions.FindAllReferencesOfType(PlayerRef, lib.LargeChestForms, ScanRadiusInterior)
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
				GR_BakaMimicAddon guard
				If rollType < Weight1Vore
					If cheatNotifyMimics > 0
						Debug.Notification("Mimic created (Vore)")
					EndIf
					guard = lib.PlaceBakaMimic(largeChest, 1)
				ElseIf rollType < (Weight1Vore + Weight2Vore)
					If cheatNotifyMimics > 0
						Debug.Notification("Mimic created")
					EndIf
					guard = lib.PlaceBakaMimic(largeChest, 2)
				Else
					If cheatNotifyMimics > 0
						Debug.Notification("Mimic created (Instant Vore)")
					EndIf
					guard = lib.PlaceBakaMimic(largeChest, 3)
				EndIf
				PlacedMimics[ PMI ] = guard
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

Function FixMimicsOnGameLoad()
	Debug("FixMimicsOnGameLoad()")
	Int fixed = 0
	ObjectReference[] mimics = PO3_SKSEFunctions.FindAllReferencesOfType(PlayerRef, lib.MimicActivatorForms, ScanRadiusInterior)
	Int i = 0
	While i < mimics.Length
		GR_BakaMimicAddon addon = Game.FindClosestReferenceOfTypeFromRef(Game.GetFormFromFile(0x816, "GR_MimicPlacer.esp"), mimics[i], 10.0) as GR_BakaMimicAddon
		If addon && addon.LinkRefsIfRequired()
			fixed += 1
		EndIf
		i += 1
	EndWhile
	Debug(mimics.Length + " mimics found, " + fixed + " fixed...")
EndFunction

Function DumpMimics()
	Debug("Dumping places mimics...")
	Int i = 0
	While i < 128
		If PlacedMimics[ i ] != None
			Debug(i + ": " + PlacedMimics[ i ] as Form + " in " + PlacedMimics[ i ].GetCell() + " MimicType=" + PlacedMimics[ i ].GetMimicType())
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
