ScriptName GR_MimicScanner extends Quest Hidden 

GR_MimicPlacer Property lib Auto
Actor Property PlayerRef Auto

; Debugging
GlobalVariable Property GR_MimicCheatNotifyMimics Auto

; Scanning
GlobalVariable Property GR_MimicDistributeMimics Auto
GlobalVariable Property GR_MimicScanRadius Auto
GlobalVariable Property GR_MimicScanInterval Auto
GlobalVariable Property GR_MimicChestsMaxAllowedRescale Auto

; Placing
GlobalVariable Property GR_MimicChance Auto
GlobalVariable Property GR_MimicWeightVore Auto
GlobalVariable Property GR_MimicWeightSex Auto
GlobalVariable Property GR_MimicWeightInstant Auto

; Keep track of processed chest reference IDs so that each chest is only 
; rolled for once, to prevent re-rolling until every chest is a mimic.
; Should work okay'ish as there's only 200 viable chests in the entire game
Int[] KnownChests 
Int KCI = 0
Int KnownChestBufferSize = 128
Int KCI_Overflows = 0

; Keep track of all created mimics, this is exclusively for debugging 
; and potential cleanup
GR_BakaMimicAddon[] PlacedMimics
Int PMI = 0
Int PMI_Overflows = 0

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
		If !GR_MimicScanRadius
			Error("Mimic globals are not set. Using defaults.")
		EndIf
		Debug("Init settings ScanInterval=" + GR_MimicScanInterval.GetValue() + " ScanRadiusInterior=" + GR_MimicScanRadius.GetValue() + " MimicChance=" + GR_MimicChance.GetValue())

		; DestroyAllMimics()
	Else
		If GR_MimicDistributeMimics.GetValueInt() == 0
			Debug("Distribution disabled")
		ElseIf Utility.GetCurrentRealTime() - lastProcessCells > GR_MimicScanInterval.GetValue()
			ProcessCell()
		Else
			Float secUntil = GR_MimicScanInterval.GetValue() - (Utility.GetCurrentRealTime() - lastProcessCells)
			Debug("last scna too early, scanning in " + secUntil + "s current-time=" + Utility.GetCurrentRealTime() + " last-scan=" + lastProcessCells)
			RegisterForSingleUpdate(secUntil)
		EndIf
	EndIf
	UnregisterForUpdate()
	RegisterForSingleUpdate(GR_MimicScanInterval.GetValue())
EndEvent

; This will reset all "visited" vanilla chests making them
; viable for mimic-fication 
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
	Debug("PlaceMimicsInRadius(): scan-radius=" + GR_MimicScanRadius.GetValue() + " mimic-chance=" + GR_MimicChance.GetValue())
	Int visited = 0
	Int skipped = 0
	Int unusable = 0
	Int placed = 0
	ObjectReference[] largeChests = PO3_SKSEFunctions.FindAllReferencesOfType(PlayerRef, lib.LargeChestForms, GR_MimicScanRadius.GetValue())
	Int i = 0
	While i < largeChests.Length
		ObjectReference largeChest = largeChests[i]
		If !largeChest.IsDisabled() && KnownChests.Find(largeChest.GetFormID()) < 0
			KnownChests[ KCI ] = largeChest.GetFormID()
			KCI += 1
			If KCI >= KnownChestBufferSize
				KCI = 0
				KCI_Overflows += 1
			EndIf
			visited += 1
			Debug("Processing chest " + largeChest as Form)

			Bool viable = true
			If largeChest.GetEnableParent()
				Debug("Chest " + largeChest as Form + " controlled by enable-parent and cannot be disabled, will be ignored...")
				viable = false
				unusable += 1
			ElseIf largeChest.GetScale() < (1.0 - GR_MimicChestsMaxAllowedRescale.GetValue()) || largeChest.GetScale() > (1.0 + GR_MimicChestsMaxAllowedRescale.GetValue())
				Debug("Ignoring rescaled chest, scale=" + largeChest.GetScale())
				viable = false
				unusable += 1
			EndIf
			
			If viable && Utility.RandomFloat() < GR_MimicChance.GetValue()
				placed += 1
				Float weightVore = GR_MimicWeightVore.GetValue()
				Float weightSex = GR_MimicWeightSex.GetValue()
				Float weightInstant = GR_MimicWeightInstant.GetValue()
				Float rollType = Utility.RandomFloat(0.0, weightVore + weightSex + weightInstant)
				GR_BakaMimicAddon guard
				If rollType < weightVore
					If GR_MimicCheatNotifyMimics.GetValueInt() > 0
						Debug.Notification("Mimic created (Vore)")
					EndIf
					guard = lib.PlaceBakaMimic(largeChest, 1)
				ElseIf rollType < (weightVore + weightSex)
					If GR_MimicCheatNotifyMimics.GetValueInt() > 0
						Debug.Notification("Mimic created")
					EndIf
					guard = lib.PlaceBakaMimic(largeChest, 2)
				Else
					If GR_MimicCheatNotifyMimics.GetValueInt() > 0
						Debug.Notification("Mimic created (Instant Vore)")
					EndIf
					guard = lib.PlaceBakaMimic(largeChest, 3)
				EndIf
				PlacedMimics[ PMI ] = guard
				PMI += 1
				If PMI >= 128
					PMI = 0
					PMI_Overflows += 1
					Error("Placed mimics ringbuffer restarts")
				EndIf
			EndIf
		Else
			skipped += 1
		EndIf
		i += 1
	EndWhile
	Debug("Result - placed=" + placed + " checked=" + visited + " skipped=" + skipped + " unusable=" + unusable)
EndFunction

; This is for uninstalling the mod completely or for a clean re-install
; when transitionong during (potentially) breaking version jumps 
Function DestroyAllMimics()
	Debug("DestroyAllMimics() " + PlacedMimics.Length)
	Int j = 0
	While j < PlacedMimics.Length
		If PlacedMimics[ j ] != None
			Cell c = PlacedMimics[ j ].GetParentCell()
			Debug("Destroying Mimic " + PlacedMimics + " in " + PlacedMimics[ j ].GetCell())
			PlacedMimics[ j ].DestroyMimicAndRestoreChest()
		EndIf
		j += 1
	EndWhile
	ResetChests()
EndFunction

Function FixMimicsOnGameLoad()
	Debug("FixMimicsOnGameLoad()")
	Int fixed = 0
	ObjectReference[] mimics = PO3_SKSEFunctions.FindAllReferencesOfType(PlayerRef, lib.MimicActivatorForms, GR_MimicScanRadius.GetValue())
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
	Int cntVisit = KCI + (128 * KCI_Overflows)
	Int cntTurned = PMI + (128 * PMI_Overflows)
	Debug("Complete List:")
	Int i = 0
	While i < 128
		If PlacedMimics[ i ] != None
			Debug(i + ": " + PlacedMimics[ i ] as Form + " Type=" + PlacedMimics[ i ].GetMimicType() + " in " + PlacedMimics[ i ].GetCell())
		EndIf
		i += 1
	EndWhile
	Debug("Stats:")
	Debug("  Chests visited: " + cntVisit)
	Debug("  Chests turned mimics: " + cntTurned)
EndFunction

Function Trace(String msg)
	; lib.Debug("SCAN: " + msg)
EndFunction

Function Debug(String msg)
	Debug.Trace("[omnom] SCAN: " + msg)
EndFunction

Function Error(String msg)
	Debug.Trace("[omnom] SCAN error: " + msg)
EndFunction
