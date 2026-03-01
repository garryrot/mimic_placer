ScriptName GR_MimicPlacer extends Quest Hidden 

String Config = "../MimicPlacer/Settings.json"
String ConfigBakaMimics = "../MimicPlacer/BakaMimics.json"

Actor Property PlayerRef Auto

; Boss Chests (Any form with Clutter\Ruins\Ruins_LargeChest)
FormList Property LargeChestForms Auto
FormList Property MimicActivatorForms Auto

Spell Property DebugSpellMimic Auto
Spell Property DebugSpellMimicVore Auto
Spell Property DebugSpellMimicInstant Auto
Spell Property DebugDestroyMimic Auto

; TNTR Forms
Keyword Property BakaMimicDispenseKeyword Auto
Keyword Property BakaMimicPosKeyword Auto
Form Property BakaMimicForm Auto
Form Property BakaTrapTriggerBoxForm Auto

; Unused
Perk Property ActivateMimicPerk Auto

Bool Init = True
Int Version = 4 ; 0.1.0

Event OnInit()
	Maintenance()
	Debug.Notification("OMNOMS: Not so Obvious Mimics for Skyrim is starting...")
EndEvent

Function Maintenance()
	Debug("Maintenace() v" + Version)
	If Version < 4
		Debug.Notification("OMNOMS: Upgrading to v0.1.0")
		Version = 4
		If PlayerRef.HasPerk(ActivateMimicPerk)
			PlayerRef.RemovePerk(ActivateMimicPerk)
			Debug.Notification("OMNOMS: Removing legacy perk")
		EndIf
	EndIf
	If !PlayerRef
		PlayerRef = Game.GetPlayer()
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
		If !PlayerRef.HasSpell(DebugDestroyMimic)
			PlayerRef.AddSpell(DebugDestroyMimic)
		EndIf
	EndIf

	If !BakaMimicForm
		BakaMimicForm = JsonUtil.GetFormValue(ConfigBakaMimics, "placed-mimic")
        Error("Fallback BakaMimicForm from json." + BakaMimicForm)
	EndIf

	If !BakaTrapTriggerBoxForm
		BakaTrapTriggerBoxForm = JsonUtil.GetFormValue(ConfigBakaMimics, "trap-trigger-box")
        Error("Fallback trap-trigger-box from json " + BakaTrapTriggerBoxForm)
	EndIf

	If !BakaMimicDispenseKeyword
		BakaMimicDispenseKeyword = JsonUtil.GetFormValue(ConfigBakaMimics, "mimic-dispense-keyword") as Keyword
        Error("Fallback mimic-dispense-keyword from json " + BakaTrapTriggerBoxForm)
	EndIf

	If !BakaMimicPosKeyword
		BakaMimicPosKeyword = JsonUtil.GetFormValue(ConfigBakaMimics, "mimic-pos-keyword") as Keyword
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

	int extraMimicCount = JsonUtil.GetIntValue(ConfigBakaMimics, "extra-mimic-form-count");
	int i = 0
	While i < extraMimicCount
		Form add = JsonUtil.GetFormValue(ConfigBakaMimics, "extra-mimic-" + i)
		If MimicActivatorForms.Find(add) < 0
			Debug("Adding extra mimic-form " + i + ": " + add)
			MimicActivatorForms.AddForm(add)
		EndIf
		i += 1
	EndWhile
EndEvent

; Types: 1: Vore, 2: Sex, 3: Instant-Vore
GR_BakaMimicAddon Function PlaceBakaMimic(ObjectReference chest, Int mimicType)
	Debug("PlaceMimic(): " + chest + " type=" + mimicType)
	chest.DisableNoWait()
	BakaTrapMimic mimic = chest.PlaceAtMe(BakaMimicForm, 1, true) as BakaTrapMimic
	mimic.MimicType = mimicType
	If mimic
		GR_BakaMimicAddon addon = mimic.PlaceAtMe(Game.GetFormFromFile(0x816, "GR_MimicPlacer.esp"), 1, true) as GR_BakaMimicAddon
		addon.lib = self
		addon.AttachToMimic(mimic, chest)
		return addon
	EndIf
	return None
EndFunction

ObjectReference Function PlaceBakaMimicClosestChest(Int mimicType)
	ObjectReference result = Game.FindClosestReferenceOfAnyTypeInListFromRef(LargeChestForms, Game.GetPlayer(), 500.0)
	If result && !result.IsDisabled()
		return PlaceBakaMimic(result, mimicType)
	EndIf
EndFunction

bool Function RemoveBakaMimicClosest()
	GR_BakaMimicAddon addon = Game.FindClosestReferenceOfTypeFromRef(Game.GetFormFromFile(0x816, "GR_MimicPlacer.esp"), Game.GetPlayer(), 400.0) as GR_BakaMimicAddon
	If addon
		; This will not remove chests from turned mimic list
		addon.DestroyMimicAndRestoreChest()
		return True
	EndIf
	return False
EndFunction

ObjectReference Function FindPairedChest(ObjectReference mimic)
    ObjectReference originalChest = Game.FindClosestReferenceOfAnyTypeInListFromRef(LargeChestForms, mimic, 10.0)
    If originalChest
		If !originalChest.IsDisabled()
			originalChest = None
		EndIf
	EndIf
	return originalChest
EndFunction

Function Debug(String msg)
	Debug.Trace("[omnom] MAIN: " + msg)
EndFunction

Function Error(String err)
	Debug.Trace("[omnom] MAIN error: " + err)
EndFunction
