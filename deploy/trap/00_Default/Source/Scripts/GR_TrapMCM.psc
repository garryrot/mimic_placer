Scriptname GR_TrapMCM extends SKI_ConfigBase

GR_TrapConfig Property TrapConfig Auto

Int _oidLoadConfig
Int _oidSaveConfig

Int _oidPatchedScripts
Int _oidStrugglingQTE
Int _oidZadAnimatinoFaction

Int _oidTrapEnabled
Int _oidTrapDamagePlayer
Int _oidTrapApproachChance
Int _oidTrapApproachMaxDistance
Int _oidTrapSexualisedDialogue

Int _oidSnareDropGold
Int _oidSnareDropGoldMin
Int _oidSnareDropGoldMax
Int _oidSnareDropWeapon
Int _oidSnareDropGoldChance
Int _oidSnareDropWeaponChance

Int _oidCreditsAuthor
Int _oidCreditsAbout

Int Function GetVersion()
    return 3
EndFunction

Event OnConfigInit()
    ModName = "TNTR: Extra Evil Traps"
    Pages = new String[3]
    Pages[0] = "Trap Outcomes"
    Pages[1] = "Debug"
    Pages[2] = "Credits"
EndEvent

Event OnPageReset(String page)
    SetTitleText("Trap Outcomes")
    SetCursorFillMode(TOP_TO_BOTTOM)

    If page == "Credits"
        AddHeaderOption("Credits")
        _oidCreditsAbout = AddTextOption("About", "")
        _oidCreditsAuthor = AddTextOption("Special Thanks", "")
        return

    ElseIf page == "Debug"
        AddHeaderOption("Bear Trap Dependencies")
        AddToggleOption("Patched TNTR scripts?", TrapConfig.PatchedBearScripts, OPTION_FLAG_DISABLED)
        _oidStrugglingQTE = AddToggleOption("Struggling QTE", IsStrugglingQteLoaded(), OPTION_FLAG_DISABLED)
        AddHeaderOption("Snare Trap")
        AddToggleOption("Patched Snare Trap scripts?", TrapConfig.PatchedSnareScripts, OPTION_FLAG_DISABLED)

        AddHeaderOption("Compatibility")
        _oidZadAnimatinoFaction = AddToggleOption("DD: Add ZadAnimationFaction", TrapConfig.AddZadAnimationFaction)
        return
    EndIf

    AddHeaderOption("Config")
    _oidLoadConfig = AddTextOption("Load config file...", "")
    _oidSaveConfig = AddTextOption("Store config file...", "")
    AddEmptyOption()

    AddHeaderOption("Approach")
    Int approachDependentFlags = 0
    If !GetBool(TrapConfig.GR_TrapEnabled)
        approachDependentFlags = OPTION_FLAG_DISABLED
    EndIf

    _oidTrapEnabled = AddToggleOption("Trap Enemy Approach", GetBool(TrapConfig.GR_TrapEnabled))
    _oidTrapApproachChance = AddSliderOption("Enemy Approach Chance", TrapConfig.GR_TrapApproachChance.GetValue(), "{2}", approachDependentFlags)
    _oidTrapDamagePlayer = AddToggleOption("Damage player", GetBool(TrapConfig.GR_TrapDamagePlayer), approachDependentFlags)
    _oidTrapSexualisedDialogue = AddToggleOption("Sexualised approach dialogue", GetBool(TrapConfig.GR_TrapSexualisedDialogue), approachDependentFlags)
    _oidTrapApproachMaxDistance = AddSliderOption("Approach max distance", TrapConfig.GR_TrapDefeatMaxDistance.GetValue(), "{0}", approachDependentFlags)

    SetCursorPosition(1)
    AddHeaderOption("Snare Trap")
    Int snareGoldDependentFlags = 0
    If !GetBool(TrapConfig.GR_TrapSnareDropGold)
        snareGoldDependentFlags = OPTION_FLAG_DISABLED
    EndIf

    _oidSnareDropGold = AddToggleOption("Drop gold", GetBool(TrapConfig.GR_TrapSnareDropGold))
    _oidSnareDropGoldMin = AddSliderOption("Drop gold min", TrapConfig.GR_TrapSnareDropGoldMin.GetValue(), "{0}", snareGoldDependentFlags)
    _oidSnareDropGoldMax = AddSliderOption("Drop gold max", TrapConfig.GR_TrapSnareDropGoldMax.GetValue(), "{0}", snareGoldDependentFlags)
    _oidSnareDropGoldChance = AddSliderOption("Drop gold chance", TrapConfig.GR_TrapSnareDropGoldChance.GetValue(), "{2}", snareGoldDependentFlags)

    Int waeaponDropDependentFlag = 0
    If !GetBool(TrapConfig.GR_TrapSnareDropWeapon)
        waeaponDropDependentFlag = OPTION_FLAG_DISABLED
    EndIf
    _oidSnareDropWeapon = AddToggleOption("Drop weapon", GetBool(TrapConfig.GR_TrapSnareDropWeapon))
    _oidSnareDropWeaponChance = AddSliderOption("Drop weapon chance", TrapConfig.GR_TrapSnareDropWeaponChance.GetValue(), "{2}", waeaponDropDependentFlag)
EndEvent

Event OnOptionSelect(Int option)
    If option == _oidLoadConfig
        TrapConfig.LoadConfig()
        ForcePageReset()
        Debug.MessageBox("Loading from config. Close MCM now...")
    ElseIf option == _oidSaveConfig
        TrapConfig.SaveConfig()
        Debug.MessageBox("Saving to config. Close MCM now...")
    ElseIf option == _oidTrapEnabled
        ToggleGlobal(TrapConfig.GR_TrapEnabled, _oidTrapEnabled)
        ForcePageReset()
    ElseIf option == _oidTrapDamagePlayer
        ToggleGlobal(TrapConfig.GR_TrapDamagePlayer, _oidTrapDamagePlayer)
    ElseIf option == _oidTrapSexualisedDialogue
        ToggleGlobal(TrapConfig.GR_TrapSexualisedDialogue, _oidTrapSexualisedDialogue)
    ElseIf option == _oidSnareDropGold
        ToggleGlobal(TrapConfig.GR_TrapSnareDropGold, _oidSnareDropGold)
        ForcePageReset()
    ElseIf option == _oidSnareDropWeapon
        ToggleGlobal(TrapConfig.GR_TrapSnareDropWeapon, _oidSnareDropWeapon)
    ElseIf option == _oidZadAnimatinoFaction
        TrapConfig.AddZadAnimationFaction = !TrapConfig.AddZadAnimationFaction
        SetToggleOptionValue(_oidZadAnimatinoFaction, TrapConfig.AddZadAnimationFaction)
    EndIf
EndEvent

Event OnOptionSliderOpen(Int option)
    If option == _oidTrapApproachChance
        SetSliderDialogStartValue(TrapConfig.GR_TrapApproachChance.GetValue())
        SetSliderDialogDefaultValue(0.55)
        SetSliderDialogRange(0.0, 1.0)
        SetSliderDialogInterval(0.01)
    ElseIf option == _oidTrapApproachMaxDistance
        SetSliderDialogStartValue(TrapConfig.GR_TrapDefeatMaxDistance.GetValueInt())
        SetSliderDialogDefaultValue(9000.0)
        SetSliderDialogRange(0.0, 50000.0)
        SetSliderDialogInterval(100.0)
    ElseIf option == _oidSnareDropGoldMin
        SetSliderDialogStartValue(TrapConfig.GR_TrapSnareDropGoldMin.GetValue())
        SetSliderDialogDefaultValue(5.0)
        SetSliderDialogRange(0.0, 200.0)
        SetSliderDialogInterval(1.0)
    ElseIf option == _oidSnareDropGoldMax
        SetSliderDialogStartValue(TrapConfig.GR_TrapSnareDropGoldMax.GetValue())
        SetSliderDialogDefaultValue(21.0)
        SetSliderDialogRange(0.0, 500.0)
        SetSliderDialogInterval(1.0)
    ElseIf option == _oidSnareDropGoldChance
        SetSliderDialogStartValue(TrapConfig.GR_TrapSnareDropGoldChance.GetValue())
        SetSliderDialogDefaultValue(0.7)
        SetSliderDialogRange(0.0, 1.0)
        SetSliderDialogInterval(0.01)
    ElseIf option == _oidSnareDropWeaponChance
        SetSliderDialogStartValue(TrapConfig.GR_TrapSnareDropWeaponChance.GetValue())
        SetSliderDialogDefaultValue(0.7)
        SetSliderDialogRange(0.0, 1.0)
        SetSliderDialogInterval(0.01)
    EndIf
EndEvent

Event OnOptionSliderAccept(Int option, Float value)
    If option == _oidTrapApproachChance
        TrapConfig.GR_TrapApproachChance.SetValue(value)
        SetSliderOptionValue(option, value, "{2}")
    ElseIf option == _oidTrapApproachMaxDistance
        TrapConfig.GR_TrapDefeatMaxDistance.SetValueInt(value as Int)
        SetSliderOptionValue(option, value, "{0}")
    ElseIf option == _oidSnareDropGoldMin
        TrapConfig.GR_TrapSnareDropGoldMin.SetValueInt(value as Int)
        SetSliderOptionValue(option, TrapConfig.GR_TrapSnareDropGoldMin.GetValue(), "{0}")
    ElseIf option == _oidSnareDropGoldMax
        TrapConfig.GR_TrapSnareDropGoldMax.SetValueInt(value as Int)
        SetSliderOptionValue(option, TrapConfig.GR_TrapSnareDropGoldMax.GetValue(), "{0}")
    ElseIf option == _oidSnareDropGoldChance
        TrapConfig.GR_TrapSnareDropGoldChance.SetValue(value)
        SetSliderOptionValue(option, value, "{2}")
    ElseIf option == _oidSnareDropWeaponChance
        TrapConfig.GR_TrapSnareDropWeaponChance.SetValue(value)
        SetSliderOptionValue(option, value, "{2}")
    EndIf
EndEvent

Event OnOptionHighlight(Int option)
    If option == _oidLoadConfig
        SetInfoText("Load all settings from json and overwrite ALL your local settings.")
    ElseIf option == _oidSaveConfig
        SetInfoText("Save all settings to json files in SKSE/Plugins/TrapDefeat/*.json")
    ElseIf option == _oidPatchedScripts
        SetInfoText("Patched bear-trap script is required for bear trap integration")
    ElseIf option == _oidStrugglingQTE
        SetInfoText("StrugglingQTE `AcheronExtensionLibrary.esp` is required for bear trap integration.")
    ElseIf option == _oidTrapEnabled
        SetInfoText("When enabled, enemies can notice you being trapped and may approach you when being trapped.")
    ElseIf option == _oidTrapDamagePlayer
        SetInfoText("Damage player health when trapped. If disabled, only stamina is damaged.")
    ElseIf option == _oidTrapSexualisedDialogue
        SetInfoText("Enables sexualised approach dialogue where applicable.")
    ElseIf option == _oidTrapApproachChance
        SetInfoText("Chance of being discovered by nearby enemies when trapped. The roll is done on a regular interval during entrapment.")
    ElseIf option == _oidTrapApproachMaxDistance
        SetInfoText("Enemies from this distance will approach you when trapped")
    ElseIf option == _oidSnareDropGold
        SetInfoText("Enable dropping gold when trapped by a snare trap.")
    ElseIf option == _oidSnareDropGoldMin
        SetInfoText("Minimum gold dropped by snare trap on each succesfull roll.")
    ElseIf option == _oidSnareDropGoldMax
        SetInfoText("Maximum gold dropped in snare trap on each succesfull roll")
    ElseIf option == _oidSnareDropWeapon
        SetInfoText("Enable weapon drop consequence for snare traps.")
    ElseIf option == _oidSnareDropGoldChance
        SetInfoText("Chance that you drop your gold when struggling in a snare traps.")
    ElseIf option == _oidSnareDropWeaponChance
        SetInfoText("Chance that you drop your weapon when struggling in a snare traps.")
    ElseIf option == _oidCreditsAbout
        SetInfoText("This is an unofficial TNTR extension by Gerroth1")
    ElseIf option == _oidCreditsAuthor
        SetInfoText("Special thanks to Bakafactory for creating the original TNTR mod.")
    ElseIf option == _oidZadAnimatinoFaction
        SetInfoText("Adds player to ZadAnimationFaction during entrapment to prevent DD animations interrupting trap progress. Beware: In unforgiving devices, this flag will also block controls during entrapment.")
    Else
    EndIf
EndEvent

Function ToggleGlobal(GlobalVariable gv, Int oid)
    Bool toggledValue = !GetBool(gv)
    If toggledValue
        gv.SetValueInt(1)
    Else
        gv.SetValueInt(0)
    EndIf
    SetToggleOptionValue(oid, toggledValue)
EndFunction

Bool Function GetBool(GlobalVariable gv)
    return gv.GetValueInt() != 0
EndFunction

Bool Function IsStrugglingQteLoaded()
    return Game.GetModByName("AcheronExtensionLibrary.esp") != 255
EndFunction

