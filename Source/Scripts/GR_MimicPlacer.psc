Scriptname GR_MimicPlacer extends Quest Hidden 

String Config = "../MimicPlacer/AdvancedSettings.json"
String DistributionConfig = "../MimicPlacer/Distribution.json"

; Boss Chests (Any form with Clutter\Ruins\Ruins_LargeChest)
FormList Property LargeChestForms Auto
Bool Property LockMimicPlacement = False Auto

; Keep track of processed chest reference IDs so that each chest is only 
; rolled for once, to prevent re-rolling until every chest is a mimic.
; Should work okay'ish as there's only 200 viable chests in the entire game
Int[] KnownChests
Int KCI
Int KnownChestBufferSize

; TNTR Forms
Keyword BakaMimicDispenseKeyword
Keyword BakaMimicPosKeyword
Form BakaMimicForm
Form BakaTrapTriggerBoxForm

Event OnInit()
	Maintenance()
EndEvent

Function Maintenance()
	Debug("Maintenace()")
	LockMimicPlacement = false ; Just in case it gets stuck

	If !KnownChests
		Debug("Init KnownChests array...")
		KnownChests = new Int[128]
		KCI = 0
		KnownChestBufferSize = 128
	Endif

	If JsonUtil.GetIntValue(Config, "add-debug-spell") == 1
	    Spell debugSpell = Game.GetFormFromFile(0xAA01, "GR_MimicPlacer.esp") as Spell
	    If !Game.GetPlayer().HasSpell(debugSpell)
			Game.GetPlayer().AddSpell(debugSpell)
	    EndIf

		debugSpell = Game.GetFormFromFile(0x23f14, "GR_MimicPlacer.esp") as Spell
	    If !Game.GetPlayer().HasSpell(debugSpell)
			Game.GetPlayer().AddSpell(debugSpell)
	    EndIf

		debugSpell = Game.GetFormFromFile(0x23f15, "GR_MimicPlacer.esp") as Spell
	    If !Game.GetPlayer().HasSpell(debugSpell)
			Game.GetPlayer().AddSpell(debugSpell)
	    EndIf
	EndIf

	BakaMimicForm = JsonUtil.GetFormValue(Config, "mimic")
	If !BakaMimicForm
        Error("BakaMimicForm not found")
	EndIf

	BakaTrapTriggerBoxForm = JsonUtil.GetFormValue(Config, "trap-trigger-box")
	If !BakaTrapTriggerBoxForm
        Error("BakaTrapTriggerBoxForm not found")
	EndIf

	BakaMimicDispenseKeyword = JsonUtil.GetFormValue(Config, "mimic-dispense-keyword") as Keyword
	If !BakaMimicDispenseKeyword
        Error("MimicDispenseKeyword not found" )
	EndIf

	BakaMimicPosKeyword = JsonUtil.GetFormValue(Config, "mimic-pos-keyword") as Keyword
	If !BakaMimicPosKeyword
        Error("BakaMimicPosKeyword not found")
	EndIf

	Debug("maintenance done")
EndFunction

Event OnUpdate()
EndEvent

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
		ObjectReference foundRef = Game.FindRandomReferenceOfAnyTypeInListFromRef(LargeChestForms, Game.GetPlayer(), scanRadius)
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
						Debug.Notification("Vore mimic created")
						PlaceMimic(foundRef, 1)
					ElseIf rollType < (weight1 + weight2)
						Debug.Notification("Sex mimic created")
						PlaceMimic(foundRef, 2)
					ElseIf rollType < (weight1 + weight2 + weight3)
						Debug.Notification("Instant mimic created")
						PlaceMimic(foundRef, 3)
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

; Types: 1: Vore, 2: Sex, 3: Instant-Vore
Function PlaceMimic(ObjectReference chest, Int mimicType)
	Debug("PlaceMimic(): " + chest + " type=" + mimicType)
	chest.DisableNoWait()
	BakaTrapMimic mimic = chest.PlaceAtMe(BakaMimicForm) as BakaTrapMimic
	mimic.MimicType = mimicType
	FixMimic(mimic)
EndFunction

Function FixMimicsInCurrentCell()
	Debug("FixMimicsInCurrentCell()")
	int rounds = 12
	float scanDistance = 4000.0
	int[] processed = new int[1]
	While rounds > 0
		BakaTrapMimic mimic = Game.FindRandomReferenceOfTypeFromRef(BakaMimicForm, Game.GetPlayer(), scanDistance) as BakaTrapMimic
		If mimic
			If processed.Find(mimic.GetFormID()) < 0
				Debug( mimic.GetFormID() +  " not in " + processed )
				processed = PapyrusUtil.PushInt(processed, mimic.GetFormID())
				Form f1 = mimic.GetNthLinkedRef(1) as BakaTrapTriggerBox
				Form f2 = mimic.GetLinkedRef(BakaMimicDispenseKeyword)
				Form f3 = mimic.GetLinkedRef(BakaMimicPosKeyword)
				If f1 == None || f2 == None || f3 == None
					Debug("Mimic " + mimic.GetFormID() + " needs fixing: " + f1 + "," + f2 + "," + f3)
					FixMimic(mimic)
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

ObjectReference Function FixMimic(ObjectReference mimic)
	BakaTrapTriggerBox box = Game.FindClosestReferenceOfTypeFromRef(BakaTrapTriggerBoxForm, mimic, 120.0) as BakaTrapTriggerBox
	If box == None
		Debug("New trigger box")
	 	box = mimic.PlaceAtMe(BakaTrapTriggerBoxForm) as BakaTrapTriggerBox
	EndIf
	box.TrapType = 2 ; Always 2 for Mimic
	box.VoreTrapref = mimic
	PO3_SKSEFunctions.SetLinkedRef(mimic, box)
	Debug("Placed trigger box " + box)

	ObjectReference dispenseXmarker = Game.FindClosestReferenceOfTypeFromRef(Game.GetForm(0x3B), mimic, 120.0)
	If dispenseXmarker == None
		Debug("New dispense marker")
		dispenseXmarker = mimic.PlaceAtMe(Game.GetForm(0x3B))
	EndIf
	PO3_SKSEFunctions.SetLinkedRef(mimic, dispenseXmarker, BakaMimicDispenseKeyword)
	Debug("Placed DispenseXMarker " + (dispenseXmarker as Form))

	ObjectReference posXmarkerHeading = Game.FindClosestReferenceOfTypeFromRef(Game.GetForm(0x34), mimic, 120.0)
	If posXmarkerHeading == None
		Debug("New pos marker")
		posXmarkerHeading = mimic.PlaceAtMe( Game.GetForm(0x34)) 
	EndIf
	PO3_SKSEFunctions.SetLinkedRef(mimic, posXmarkerHeading, BakaMimicPosKeyword)
	Debug("PositionXMarker " + (posXmarkerHeading as Form))
	return mimic
EndFunction

Function Debug(String msg)
	Debug.Trace("[GRMP] " + msg)
	; Debug.Notification("[GRMP] " + msg)
EndFunction

Function Error(String err)
	Debug.Trace("[GRMP] ERROR " + err)
EndFunction
