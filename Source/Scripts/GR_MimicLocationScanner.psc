ScriptName GR_MimicLocationScanner extends Quest Hidden 

GR_MimicPlacer Property lib Auto ; GR_MimicPlacer
Actor Property PlayerRef Auto
FormList Property LargeChestForms Auto ; Boss Chests (Any form with Clutter\Ruins\Ruins_LargeChest)

String DistributionConfig = "../MimicPlacer/Distribution.json"

; Keep track of processed chest reference IDs so that each chest is only 
; rolled for once, to prevent re-rolling until every chest is a mimic.
; Should work okay'ish as there's only 200 viable chests in the entire game
Int[] KnownChests
Int KCI
Int KnownChestBufferSize

Int[] PlacedMimics
Int[] PlacedMimicLocs

Bool LockMimicPlacement = False

Event OnInit()
	Maintenance()
EndEvent

Function Maintenance()
    lib.Debug("Maintenance()")
	If !KnownChests
        ResetChests()
	Endif
	LockMimicPlacement = false ; Just in case it gets stuck
	
	RegisterForSingleUpdate(20.0)
EndFunction

Function ResetChests()
	Debug("ResetChests() - resetting known chest...")
	KnownChests = new Int[128]
	KCI = 0
	KnownChestBufferSize = 128
	PlacedMimics = new Int[128]
	PlacedMimicLocs = new Int[128]
EndFunction

Function ProcessCell()
	Debug("ProcessCell()")
    If !LockMimicPlacement
        LockMimicPlacement = true
        PlaceMimicsInCurrentCell()
        FixMimicsInCurrentCell()
        LockMimicPlacement = false
	Else
		Debug("Locked")
    EndIf
EndFunction

; Search for viable boss chests using 'FindRandomReference' and replace them with a mimic
Function PlaceMimicsInCurrentCell()
	int maxRounds = JsonUtil.GetIntValue(DistributionConfig, "scan-rounds")
	Float scanRadius = JsonUtil.GetFloatValue(DistributionConfig, "scan-radius")
	Float mimicChance = JsonUtil.GetFloatValue(DistributionConfig, "mimic-chance")
	Float weight1 = JsonUtil.GetFloatValue(DistributionConfig, "mimic-weight-vore")
	Float weight2 = JsonUtil.GetFloatValue(DistributionConfig, "mimic-weight-sex")
	Float weight3 = JsonUtil.GetFloatValue(DistributionConfig, "mimic-weight-instant")
	Debug("PlaceMimicsInCurrentCell(): rounds=" + maxRounds + " scan-radius=" + scanRadius + " mimic-chance=" + mimicChance)

	int rounds = maxRounds
	While rounds > 0
		ObjectReference foundRef = Game.FindRandomReferenceOfAnyTypeInListFromRef(LargeChestForms, PlayerRef, scanRadius)
		If foundRef
			Int foundFormId = foundRef.GetFormID()
		
			If KnownChests.Find(foundFormId) < 0 && !foundRef.IsDisabled() ; Should be always true
				KnownChests[ KCI ] = foundFormId
				KCI += 1
				If KCI >= KnownChestBufferSize
					KCI = 0
				EndIf

				Debug("Chest " + (foundRef as Form) + " viable for replacement")
				Float roll = Utility.RandomFloat()
				Debug("roll=" + roll)
				If roll < mimicChance
					Float rollType = Utility.RandomFloat(0.0, weight1 + weight2 + weight3)
					Debug("rollType=" + rollType + "/" + weight1 + weight2 + weight3)
					If rollType < weight1
						Debug.Notification("Mimic created (Vore)")
						lib.PlaceMimic(foundRef, 1)
					ElseIf rollType < (weight1 + weight2)
						Debug.Notification("Mimic created")
						lib.PlaceMimic(foundRef, 2)
					ElseIf rollType < (weight1 + weight2 + weight3)
						Debug.Notification("Mimic created (Instant Vore)")
						lib.PlaceMimic(foundRef, 3)
					EndIf
				EndIf
			Else 
				Debug("Chest " + (foundRef as Form) + " int=(" + foundRef.GetFormID() + ") already processed")
			EndIf
			rounds -= 1
		Else
			Debug("Nothing found")
			rounds = 0
		EndIf
	EndWhile
EndFunction

Function FixMimicsInCurrentCell()
	Debug("FixMimicsInCurrentCell()")

	int rounds = 12
	float scanDistance = 4000.0
	int[] processed = new int[1]
	While rounds > 0
		BakaTrapMimic mimic = Game.FindRandomReferenceOfTypeFromRef(lib.BakaMimicForm, PlayerRef, scanDistance) as BakaTrapMimic
		If mimic
			If processed.Find(mimic.GetFormID()) < 0
				Debug( mimic.GetFormID() +  " not in " + processed )
				processed = PapyrusUtil.PushInt(processed, mimic.GetFormID())
				Form f1 = mimic.GetNthLinkedRef(1) as BakaTrapTriggerBox
				Form f2 = mimic.GetLinkedRef(lib.BakaMimicDispenseKeyword)
				Form f3 = mimic.GetLinkedRef(lib.BakaMimicPosKeyword)
				If f1 == None || f2 == None || f3 == None
					Debug("Mimic " + mimic.GetFormID() + " needs fixing: " + f1 + "," + f2 + "," + f3)
					lib.FixMimic(mimic)
				Else
					Debug("Mimic is fine: " + (mimic as Form))
				EndIf
			EndIf
			rounds -= 1
		Else
			Debug("Nothing found")
			rounds = 0
		EndIf
	EndWhile
EndFunction

Function Debug(String msg)
	lib.Debug("Scanner: " + msg)
EndFunction