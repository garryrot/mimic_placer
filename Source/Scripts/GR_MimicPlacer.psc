ScriptName GR_MimicPlacer extends Quest Hidden 

String Config = "../MimicPlacer/AdvancedSettings.json"

Actor Property PlayerRef Auto

; Boss Chests (Any form with Clutter\Ruins\Ruins_LargeChest)
FormList Property LargeChestForms Auto 

Spell Property DebugSpellMimic Auto
Spell Property DebugSpellMimicVore Auto
Spell Property DebugSpellMimicInstant Auto

; TNTR Forms
Keyword Property BakaMimicDispenseKeyword Auto
Keyword Property BakaMimicPosKeyword Auto
Form Property BakaMimicForm Auto
Form Property BakaTrapTriggerBoxForm Auto

; Unused
Perk Property ActivateMimicPerk Auto

Bool Init = True

Event OnInit()
	Maintenance()
EndEvent

Function Maintenance()
	Debug("Maintenace()")
	If !PlayerRef
		PlayerRef = Game.GetPlayer() ; Just cause I'm paranoid
	EndIf

	If JsonUtil.GetIntValue(Config, "add-debug-spell") == 1
	    If !PlayerRef.HasSpell(DebugSpellMimic)
			PlayerRef.AddSpell(DebugSpellMimic)
	    EndIf

	    If !PlayerRef.HasSpell(DebugSpellMimicVore)
			PlayerRef.AddSpell(DebugSpellMimicVore)
	    EndIf

	    If !PlayerRef.HasSpell(DebugSpellMimicInstant)
			PlayerRef.AddSpell(DebugSpellMimicInstant)
	    EndIf
	EndIf

	If !BakaMimicForm
		BakaMimicForm = JsonUtil.GetFormValue(Config, "placed-mimic")
        Error("Fallback BakaMimicForm from json." + BakaMimicForm)
	EndIf

	If !BakaTrapTriggerBoxForm
		BakaTrapTriggerBoxForm = JsonUtil.GetFormValue(Config, "trap-trigger-box")
        Error("Fallback trap-trigger-box from json " + BakaTrapTriggerBoxForm)
	EndIf

	If !BakaMimicDispenseKeyword
		BakaMimicDispenseKeyword = JsonUtil.GetFormValue(Config, "mimic-dispense-keyword") as Keyword
        Error("Fallback mimic-dispense-keyword from json " + BakaTrapTriggerBoxForm)
	EndIf

	If !BakaMimicPosKeyword
		BakaMimicPosKeyword = JsonUtil.GetFormValue(Config, "mimic-pos-keyword") as Keyword
        Error("Fallback BakaMimicPosKeyword from json " + BakaMimicPosKeyword)
	EndIf
	
	Init = True
	RegisterForSingleUpdate(0.5)
	Debug("Maintenance() Done")
EndFunction

Event OnUpdate()
	If !Init
		return
	EndIf
	Init = False

	int extraMimicCount = JsonUtil.GetIntValue(Config, "extra-mimic-count");
	FormList mimics = Game.GetFormFromFile(0x2901C, "GR_MimicPlacer.esp") As FormList
	If mimics
		int i = 0
		While i < extraMimicCount
			Form add = JsonUtil.GetFormValue(Config, "extra-mimic-" + i)
			If mimics.Find(add) < 0
				Debug("Adding extra mimic-form " + i + ": " + add)
				mimics.AddForm(add)
			EndIf
			i += 1
		EndWhile
	EndIf
EndEvent

; Types: 1: Vore, 2: Sex, 3: Instant-Vore
Function PlaceMimic(ObjectReference chest, Int mimicType)
	Debug("PlaceMimic(): " + chest + " type=" + mimicType)
	chest.DisableNoWait()
	BakaTrapMimic mimic = chest.PlaceAtMe(BakaMimicForm) as BakaTrapMimic
	mimic.MimicType = mimicType
EndFunction

ObjectReference Function FixMimic(ObjectReference mimic)
	If (mimic.GetNthLinkedRef(1) as BakaTrapTriggerBox)
		return mimic ; doesn't need fixing
	EndIf
	Debug("fixing mimic")

	BakaTrapTriggerBox box = Game.FindClosestReferenceOfTypeFromRef(BakaTrapTriggerBoxForm, mimic, 120.0) as BakaTrapTriggerBox
	If box == None
	 	box = mimic.PlaceAtMe(BakaTrapTriggerBoxForm) as BakaTrapTriggerBox
		Debug("Placed trigger box " + box)
	EndIf

	box.TrapType = 2 ; Always 2 for Mimic
	box.VoreTrapref = mimic
	PO3_SKSEFunctions.SetLinkedRef(mimic, box)

	ObjectReference dispenseXmarker = Game.FindClosestReferenceOfTypeFromRef(Game.GetForm(0x3B), mimic, 120.0)
	If dispenseXmarker == None
		dispenseXmarker = mimic.PlaceAtMe(Game.GetForm(0x3B))
		Debug("Placed DispenseXMarker " + (dispenseXmarker as Form))
	EndIf
	PO3_SKSEFunctions.SetLinkedRef(mimic, dispenseXmarker, BakaMimicDispenseKeyword)

	ObjectReference posXmarkerHeading = Game.FindClosestReferenceOfTypeFromRef(Game.GetForm(0x34), mimic, 120.0)
	If posXmarkerHeading == None
		posXmarkerHeading = mimic.PlaceAtMe( Game.GetForm(0x34)) 
		Debug("Placed PositionXMarker " + (posXmarkerHeading as Form))
	EndIf
	PO3_SKSEFunctions.SetLinkedRef(mimic, posXmarkerHeading, BakaMimicPosKeyword)
	return mimic
EndFunction

Function Debug(String msg)
	Debug.Trace("[GRMP] " + msg)
	; Debug.Notification("[GRMP] " + msg)
EndFunction

Function Error(String err)
	Debug.Trace("[GRMP] ERROR " + err)
EndFunction
