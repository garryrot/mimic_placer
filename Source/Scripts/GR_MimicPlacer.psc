Scriptname GR_MimicPlacer extends Quest Hidden 

String Config = "../MimicPlacer/AdvancedSettings.json"
String DistributionConfig = "../MimicPlacer/Distribution.json"

; Boss Chests (Any form with Clutter\Ruins\Ruins_LargeChest)
FormList Property LargeChestForms Auto  

; Keep track of processed chest reference IDs so that each chest is only 
; rolled for once to prevent re-rolling on cell load until every chest is 
; a trap
Int[] KnownChestsRingbuffer
Int KCI
Int KnownChestBufferSize

; Base Game
Actor PlayerRef
Form XMarkerForm
Form XMarkerHeadingForm

; Error

; TNTR Forms
Keyword BakaMimicDispenseKeyword
Keyword BakaMimicPosKeyword
Form BakaMimicForm
Form BakaTrapTriggerBoxForm

Event OnInit()
	KnownChestsRingbuffer = new Int[127]
	KCI = 0
	KnownChestBufferSize = 127
	Maintenance()
EndEvent

Function Maintenance()
	PlayerRef = Game.GetPlayer()
	XMarkerForm = Game.GetForm(0x3B)
	XMarkerHeadingForm = Game.GetForm(0x34)

	If JsonUtil.GetIntValue(Config, "add-debug-spell") == 1
	    Spell debugSpell = Game.GetFormFromFile(0xAA01, "GR_MimicPlacer.esp") as Spell
	    If !Game.GetPlayer().HasSpell(debugSpell)
			Game.GetPlayer().AddSpell(debugSpell)
	    EndIf
	EndIf

	String explanation = "Mimic placament & fixing will not work, adapt AdvancedSettings.json with correct form IDs..."
	BakaMimicForm = JsonUtil.GetFormValue(Config, "mimic")
	If !BakaMimicForm
        Error("BakaMimicForm not found. " + explanation)
	EndIf

	BakaTrapTriggerBoxForm = JsonUtil.GetFormValue(Config, "trap-trigger-box")
	If !BakaTrapTriggerBoxForm
        Error("BakaTrapTriggerBoxForm not found. " + explanation)
	EndIf

	BakaMimicDispenseKeyword = JsonUtil.GetFormValue(Config, "mimic-dispense-keyword") as Keyword
	If !BakaMimicDispenseKeyword
        Error("MimicDispenseKeyword not found. " + explanation)
	EndIf

	BakaMimicPosKeyword = JsonUtil.GetFormValue(Config, "mimic-pos-keyword") as Keyword
	If !BakaMimicPosKeyword
        Error("BakaMimicPosKeyword not found. " + explanation)
	EndIf

	Debug("maintenance done")
EndFunction
	
Function PrepareCell()
	Debug.Notification("Preparing cell...")
	int maxRounds = JsonUtil.GetIntValue(DistributionConfig, "scan-rounds")
	Float scanRadius = JsonUtil.GetFloatValue(DistributionConfig, "scan-radius")
	Float mimicChance = JsonUtil.GetFloatValue(DistributionConfig, "mimic-chance")
	Debug("PrepareCell: rounds=" + maxRounds + " scan-radius=" + scanRadius + " mimic-chance=" + mimicChance)

	; Int[] processed = new int[1]
	int rounds = maxRounds
	While rounds > 0
		ObjectReference foundRef = Game.FindRandomReferenceOfAnyTypeInListFromRef(LargeChestForms, PlayerRef, scanRadius)
		If foundRef
			Int foundFormId = foundRef.GetFormID()
		
			If KnownChestsRingbuffer.Find(foundFormId) < 0 && !foundRef.IsDisabled() ; Should be always true
				KnownChestsRingbuffer[ KCI ] = foundFormId
				KCI += 1
				If KCI >= KnownChestBufferSize
					KCI = 0
				EndIf

				Debug("Chest " + (foundRef as Form) + " viable for replacement")

					Float roll = Utility.RandomFloat()
					Debug("roll=" + roll)
					If roll < mimicChance
						Debug.Notification("Mimic created")
						ReplaceWithMimic(foundRef, Utility.RandomInt(1,3))
					EndIf
				; EndIf
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

Function FixMimicsInCell()
	Debug("Fixing mimics without markers...")
	int rounds = 8
	float scanDistance = 4000.0
	int[] processed = new int[1]
	While rounds > 0
		BakaTrapMimic mimic = Game.FindRandomReferenceOfTypeFromRef(BakaMimicForm, PlayerRef, scanDistance) as BakaTrapMimic
		If mimic
			If processed.Find(mimic.GetFormID()) < 0
				PapyrusUtil.PushInt(processed, mimic.GetFormID())
				Form f1 = mimic.GetNthLinkedRef(1) as BakaTrapTriggerBox
				Form f2 = mimic.GetLinkedRef(BakaMimicDispenseKeyword)
				Form f3 = mimic.GetLinkedRef(BakaMimicPosKeyword)
				If f1 == None || f2 == None || f3 == None
					Debug("Mimic " + mimic.GetFormID() + " needs fixing: " + f1 + "," + f2 + "," + f3)
					FixMimic(mimic)
				Else
					Debug("Mimic is fine: " + (mimic as Form))
				EndIf
				rounds -= 1
			Else
				Debug("already processed")
			EndIf
		Else
			Debug("Nothing found")
			rounds = 0
		EndIf
	EndWhile
EndFunction

; Types: 1: Vore, 2: Sex, 3: Instant-Vore
Function ReplaceWithMimic(ObjectReference chest, Int mimicType)
	Debug("Replacing chest with mimic... " + chest + " type=" + mimicType)
	chest.DisableNoWait()
	BakaTrapMimic mimic = chest.PlaceAtMe(BakaMimicForm) as BakaTrapMimic
	mimic.MimicType = mimicType
	FixMimic(mimic)

	; TODO Hotfix nearby sling traps?
EndFunction

ObjectReference Function FixMimic(ObjectReference mimic)
	BakaTrapTriggerBox box = mimic.PlaceAtMe(BakaTrapTriggerBoxForm) as BakaTrapTriggerBox
	box.TrapType = 2 ; Always 2 for Mimic
	box.VoreTrapref = mimic
	PO3_SKSEFunctions.SetLinkedRef(mimic, box)
	Debug("Placed trigger box " + box)

	ObjectReference DispenseXmarker = mimic.PlaceAtMe(XMarkerForm)
	ObjectReference x = PO3_SKSEFunctions.SetLinkedRef(mimic, DispenseXmarker, BakaMimicDispenseKeyword)
	Debug("DispenseXMarker " + (DispenseXmarker as Form) )

	ObjectReference PosXmarker = mimic.PlaceAtMe(XMarkerHeadingForm) 
	x = PO3_SKSEFunctions.SetLinkedRef(mimic, PosXmarker, BakaMimicPosKeyword)
	Debug("PositionXMarker " + (PosXmarker as Form))
	return mimic
EndFunction

Function Debug(String msg)
	Debug.Trace("[GRMP] " + msg)
	; Debug.Notification("[GRMP] " + msg)
EndFunction

Function Error(String err)
	Debug.Trace("[GRMP] ERROR " + err)
EndFunction

