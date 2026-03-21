Scriptname GR_MimicMCM extends SKI_ConfigBase

GR_MimicConfig Property MimicConfig Auto

Int _oidLoadConfig
Int _oidSaveConfig
Int _oidAddDebugSpells
Int _oidDumpMimicsNow

; Distribution
Int _oidMimicDistributeMimics
Int _oidCheatNotifyMimics
Int _oidScanRadius
Int _oidScanInterval
Int _oidMimicChance
Int _oidMimicWeightVore
Int _oidMimicWeightSex
Int _oidMimicWeightInstant
Int _oidChestsMaxAllowedRescale

; Consequences
Int _oidHelpConsequencesDisabled

Int _oidMimicLoot
Int _oidMimicLootMaxItemCount
Int _oidMimicLootMaxGoldCount
Int _oidMimicLootChanceAccumulates
Int _oidMimicLootChancePerTick

Int _oidMimicVoreBadEnd
Int _oidMimicVoreBadEndMinTicks
Int _oidMimicVoreBadEndSimpleSlavery

Int _oidMimicLoseGold
Int _oidMimicLoseGoldMin
Int _oidMimicLoseGoldMax
Int _oidMimicLoseGoldChance
Int _oidMimicLoseGoldScalePerLvl

Int _oidMimicLoseArmor
Int _oidMimicLoseArmorChancePerTick


Int _oidCreditsAuthor
Int _oidCreditsAbout
Int _oidDestroyAllMimics

Int Function GetVersion()
    return 3
EndFunction

Event OnConfigInit()
    ModName = "TNTR: Not So Obvious Mimics"
    Pages = new String[3]
    Pages[0] = "Mimic Placement"
    Pages[1] = "Debug"
    Pages[2] = "Credits"
EndEvent

Event OnPageReset(String page)
    SetTitleText("TNTR: Not So Obvious Mimics")
    SetCursorFillMode(TOP_TO_BOTTOM)

    If page == "Credits"
        AddHeaderOption("Credits")
        _oidCreditsAuthor = AddTextOption("Special Thanks", "")
       _oidCreditsAbout = AddTextOption("About", "")
        return
    ElseIf page == "Debug"
        AddHeaderOption("Actions")
        _oidCheatNotifyMimics = AddToggleOption("Cheat notify mimics", GetBool(MimicConfig.GR_MimicCheatNotifyMimics))
        _oidDumpMimicsNow = AddTextOption("Dump placed mimics to papyrus...", "")
        _oidAddDebugSpells = AddTextOption("Add debug spells", "")

        AddHeaderOption("Danger Zone")
        _oidDestroyAllMimics = AddTextOption("Destroy ALL placed mimics", "")
        return
    EndIf

    Int distDependentFlags = 0
    If !GetBool(MimicConfig.GR_MimicDistributeMimics)
        distDependentFlags = OPTION_FLAG_DISABLED
    EndIf

    Int trapDefeatDependentFlags = 0
    If !HasLoadedMod("GR_TrapDefeat.esp")
        trapDefeatDependentFlags = OPTION_FLAG_DISABLED
    EndIf

    Int stealDependentFlags = trapDefeatDependentFlags
    If !GetBool(MimicConfig.GR_MimicLoseArmor)
        stealDependentFlags = OPTION_FLAG_DISABLED
    EndIf
    
    Int loseGoldDependentFlags = trapDefeatDependentFlags
    If !GetBool(MimicConfig.GR_MimicLoseGold)
        loseGoldDependentFlags = OPTION_FLAG_DISABLED
    EndIf

    Int badEndDependentFlags = trapDefeatDependentFlags
    If !GetBool(MimicConfig.GR_MimicVoreBadEnd)
        badEndDependentFlags = OPTION_FLAG_DISABLED
    EndIf

    Int findLootDependentFlags = trapDefeatDependentFlags
    If !GetBool(MimicConfig.GR_MimicLoot)
        findLootDependentFlags = OPTION_FLAG_DISABLED
    EndIf

    AddHeaderOption("Actions")
    _oidLoadConfig = AddTextOption("Load config file...", "")
    _oidSaveConfig = AddTextOption("Store config file...", "")
    AddEmptyOption()

    AddHeaderOption("Distribution")
    _oidMimicDistributeMimics = AddToggleOption("Distribute mimics", GetBool(MimicConfig.GR_MimicDistributeMimics))
    _oidScanRadius = AddSliderOption("Scan radius", MimicConfig.GR_MimicScanRadius.GetValue(), "{0}", distDependentFlags)
    _oidScanInterval = AddSliderOption("Scan interval", MimicConfig.GR_MimicScanInterval.GetValue(), "{1}", distDependentFlags)
    _oidMimicChance = AddSliderOption("Mimic chance", MimicConfig.GR_MimicChance.GetValue(), "{2}", distDependentFlags)
    _oidMimicWeightVore = AddSliderOption("Weight vore", MimicConfig.GR_MimicWeightVore.GetValue(), "{1}", distDependentFlags)
    _oidMimicWeightSex = AddSliderOption("Weight sex", MimicConfig.GR_MimicWeightSex.GetValue(), "{1}", distDependentFlags)
    _oidMimicWeightInstant = AddSliderOption("Weight instant", MimicConfig.GR_MimicWeightInstant.GetValue(), "{1}", distDependentFlags)
    _oidChestsMaxAllowedRescale = AddSliderOption("Max allowed chest rescale", MimicConfig.GR_MimicChestsMaxAllowedRescale.GetValue(), "{2}", distDependentFlags)

    SetCursorPosition(1)
    If trapDefeatDependentFlags
        _oidHelpConsequencesDisabled = AddTextOption("Consequences Disabled", "")
    EndIf

    AddHeaderOption("Mimics contain loot")
    _oidMimicLoot = AddToggleOption("Enable finding loot", GetBool(MimicConfig.GR_MimicLoot), trapDefeatDependentFlags)
    _oidMimicLootMaxItemCount = AddSliderOption("Max items", MimicConfig.GR_MimicLootMaxItemCount.GetValue(), "{0}",findLootDependentFlags)
    _oidMimicLootMaxGoldCount = AddSliderOption("Max gold", MimicConfig.GR_MimicLootMaxGoldCount.GetValue(), "{0}",findLootDependentFlags)
    _oidMimicLootChancePerTick = AddSliderOption("Loot chance (per tick)", MimicConfig.GR_MimicLootChancePerTick.GetValue(), "{2}",findLootDependentFlags)
    _oidMimicLootChanceAccumulates = AddToggleOption("Chance accumulates", GetBool(MimicConfig.GR_MimicLootChanceAccumulates),findLootDependentFlags)

    AddHeaderOption("Mimics steal loot")
    _oidMimicLoseArmor = AddToggleOption("Enable losing armor", GetBool(MimicConfig.GR_MimicLoseArmor), trapDefeatDependentFlags)
    _oidMimicLoseArmorChancePerTick = AddSliderOption("Lose armor chance per tick", MimicConfig.GR_MimicLoseArmorChancePerTick.GetValue(), "{2}", stealDependentFlags)

    _oidMimicLoseGold = AddToggleOption("Lose gold", GetBool(MimicConfig.GR_MimicLoseGold), stealDependentFlags)
    _oidMimicLoseGoldMin = AddSliderOption("Lose gold min", MimicConfig.GR_MimicLoseGoldMin.GetValue(), "{0}", loseGoldDependentFlags)
    _oidMimicLoseGoldMax = AddSliderOption("Lose gold max", MimicConfig.GR_MimicLoseGoldMax.GetValue(), "{0}", loseGoldDependentFlags)
    _oidMimicLoseGoldChance = AddSliderOption("Lose gold chance", MimicConfig.GR_MimicLoseGoldChance.GetValue(), "{2}", loseGoldDependentFlags)
    _oidMimicLoseGoldScalePerLvl = AddSliderOption("Lose gold scale per lvl", MimicConfig.GR_MimicLoseGoldScalePerLvl.GetValue(), "{2}", loseGoldDependentFlags)

    AddHeaderOption("Bad end")
    _oidMimicVoreBadEnd = AddToggleOption("Vore bad end", GetBool(MimicConfig.GR_MimicVoreBadEnd), trapDefeatDependentFlags)
    _oidMimicVoreBadEndMinTicks = AddSliderOption("Vore bad end min ticks", MimicConfig.GR_MimicVoreBadEndMinTicks.GetValue(), "{0}", badEndDependentFlags)
    _oidMimicVoreBadEndSimpleSlavery = AddToggleOption("Vore bad end simple slavery", GetBool(MimicConfig.GR_MimicVoreBadEndSimpleSlavery), badEndDependentFlags)
EndEvent

Event OnOptionSelect(Int option)
    If option == _oidLoadConfig
        MimicConfig.LoadConfig()
        ForcePageReset()
        Debug.MessageBox("Loading from config. Close MCM now...")
    ElseIf option == _oidSaveConfig
        MimicConfig.SaveConfig()
        Debug.MessageBox("Saving to config. Close MCM now...")
    ElseIf option == _oidAddDebugSpells
        MimicConfig.AddDebugSpells()
    ElseIf option == _oidDumpMimicsNow
        MimicConfig.MimicScanner.DumpMimics()
        Debug.Notification("Dumping mimics...")
    ElseIf option == _oidDestroyAllMimics
        MimicConfig.MimicScanner.DestroyAllMimics()
        Debug.MessageBox("Destroying all Mimics. Close MCM and wait for notification...")
    ElseIf option == _oidMimicDistributeMimics
        ToggleGlobal(MimicConfig.GR_MimicDistributeMimics, _oidMimicDistributeMimics)
        ForcePageReset()
    ElseIf option == _oidCheatNotifyMimics
        ToggleGlobal(MimicConfig.GR_MimicCheatNotifyMimics, _oidCheatNotifyMimics)
    ElseIf option == _oidMimicLoot
        ToggleGlobal(MimicConfig.GR_MimicLoot, _oidMimicLoot)
        ForcePageReset()
    ElseIf option == _oidMimicLootChanceAccumulates
        ToggleGlobal(MimicConfig.GR_MimicLootChanceAccumulates, _oidMimicLootChanceAccumulates)
    ElseIf option == _oidMimicLoseArmor
        ToggleGlobal(MimicConfig.GR_MimicLoseArmor, _oidMimicLoseArmor)
        ForcePageReset()
    ElseIf option == _oidMimicLoseGold
        ToggleGlobal(MimicConfig.GR_MimicLoseGold, _oidMimicLoseGold)
        ForcePageReset()
    ElseIf option == _oidMimicVoreBadEnd
        ToggleGlobal(MimicConfig.GR_MimicVoreBadEnd, _oidMimicVoreBadEnd)
        ForcePageReset()
    ElseIf option == _oidMimicVoreBadEndSimpleSlavery
        ToggleGlobal(MimicConfig.GR_MimicVoreBadEndSimpleSlavery, _oidMimicVoreBadEndSimpleSlavery)
    EndIf
EndEvent

Event OnOptionSliderOpen(Int option)
    If option == _oidScanRadius
        SetSliderDialogStartValue(MimicConfig.GR_MimicScanRadius.GetValue())
        SetSliderDialogDefaultValue(18000.0)
        SetSliderDialogRange(100.0, 60000.0)
        SetSliderDialogInterval(100.0)
    ElseIf option == _oidScanInterval
        SetSliderDialogStartValue(MimicConfig.GR_MimicScanInterval.GetValue())
        SetSliderDialogDefaultValue(30.0)
        SetSliderDialogRange(1.0, 600.0)
        SetSliderDialogInterval(1.0)
    ElseIf option == _oidMimicChance
        SetSliderDialogStartValue(MimicConfig.GR_MimicChance.GetValue())
        SetSliderDialogDefaultValue(0.28)
        SetSliderDialogRange(0.0, 1.0)
        SetSliderDialogInterval(0.01)
    ElseIf option == _oidMimicWeightVore
        SetSliderDialogStartValue(MimicConfig.GR_MimicWeightVore.GetValue())
        SetSliderDialogDefaultValue(30.0)
        SetSliderDialogRange(0.0, 100.0)
        SetSliderDialogInterval(1.0)
    ElseIf option == _oidMimicWeightSex
        SetSliderDialogStartValue(MimicConfig.GR_MimicWeightSex.GetValue())
        SetSliderDialogDefaultValue(60.0)
        SetSliderDialogRange(0.0, 100.0)
        SetSliderDialogInterval(1.0)
    ElseIf option == _oidMimicWeightInstant
        SetSliderDialogStartValue(MimicConfig.GR_MimicWeightInstant.GetValue())
        SetSliderDialogDefaultValue(30.0)
        SetSliderDialogRange(0.0, 100.0)
        SetSliderDialogInterval(1.0)
    ElseIf option == _oidChestsMaxAllowedRescale
        SetSliderDialogStartValue(MimicConfig.GR_MimicChestsMaxAllowedRescale.GetValue())
        SetSliderDialogDefaultValue(0.2)
        SetSliderDialogRange(0.0, 1.0)
        SetSliderDialogInterval(0.01)
    ElseIf option == _oidMimicLootMaxItemCount
        SetSliderDialogStartValue(MimicConfig.GR_MimicLootMaxItemCount.GetValue())
        SetSliderDialogDefaultValue(3.0)
        SetSliderDialogRange(0.0, 20.0)
        SetSliderDialogInterval(1.0)
    ElseIf option == _oidMimicLootMaxGoldCount
        SetSliderDialogStartValue(MimicConfig.GR_MimicLootMaxGoldCount.GetValue())
        SetSliderDialogDefaultValue(40.0)
        SetSliderDialogRange(0.0, 500.0)
        SetSliderDialogInterval(1.0)
    ElseIf option == _oidMimicLootChancePerTick
        SetSliderDialogStartValue(MimicConfig.GR_MimicLootChancePerTick.GetValue())
        SetSliderDialogDefaultValue(0.08)
        SetSliderDialogRange(0.0, 1.0)
        SetSliderDialogInterval(0.01)
    ElseIf option == _oidMimicLoseArmorChancePerTick
        SetSliderDialogStartValue(MimicConfig.GR_MimicLoseArmorChancePerTick.GetValue())
        SetSliderDialogDefaultValue(1.0)
        SetSliderDialogRange(0.0, 1.0)
        SetSliderDialogInterval(0.01)
    ElseIf option == _oidMimicLoseGoldMin
        SetSliderDialogStartValue(MimicConfig.GR_MimicLoseGoldMin.GetValue())
        SetSliderDialogDefaultValue(10.0)
        SetSliderDialogRange(0.0, 2000.0)
        SetSliderDialogInterval(1.0)
    ElseIf option == _oidMimicLoseGoldMax
        SetSliderDialogStartValue(MimicConfig.GR_MimicLoseGoldMax.GetValue())
        SetSliderDialogDefaultValue(350.0)
        SetSliderDialogRange(0.0, 5000.0)
        SetSliderDialogInterval(1.0)
    ElseIf option == _oidMimicLoseGoldChance
        SetSliderDialogStartValue(MimicConfig.GR_MimicLoseGoldChance.GetValue())
        SetSliderDialogDefaultValue(0.05)
        SetSliderDialogRange(0.0, 1.0)
        SetSliderDialogInterval(0.01)
    ElseIf option == _oidMimicLoseGoldScalePerLvl
        SetSliderDialogStartValue(MimicConfig.GR_MimicLoseGoldScalePerLvl.GetValue())
        SetSliderDialogDefaultValue(1.05)
        SetSliderDialogRange(1.0, 2.0)
        SetSliderDialogInterval(0.01)
    ElseIf option == _oidMimicVoreBadEndMinTicks
        SetSliderDialogStartValue(MimicConfig.GR_MimicVoreBadEndMinTicks.GetValue())
        SetSliderDialogDefaultValue(11.0)
        SetSliderDialogRange(0.0, 60.0)
        SetSliderDialogInterval(1.0)
    EndIf
EndEvent

Event OnOptionSliderAccept(Int option, Float value)
    If option == _oidScanRadius
        MimicConfig.GR_MimicScanRadius.SetValue(value)
        SetSliderOptionValue(option, value, "{0}")
    ElseIf option == _oidScanInterval
        MimicConfig.GR_MimicScanInterval.SetValue(value)
        SetSliderOptionValue(option, value, "{1}")
    ElseIf option == _oidMimicChance
        MimicConfig.GR_MimicChance.SetValue(value)
        SetSliderOptionValue(option, value, "{2}")
    ElseIf option == _oidMimicWeightVore
        MimicConfig.GR_MimicWeightVore.SetValue(value)
        SetSliderOptionValue(option, value, "{1}")
    ElseIf option == _oidMimicWeightSex
        MimicConfig.GR_MimicWeightSex.SetValue(value)
        SetSliderOptionValue(option, value, "{1}")
    ElseIf option == _oidMimicWeightInstant
        MimicConfig.GR_MimicWeightInstant.SetValue(value)
        SetSliderOptionValue(option, value, "{1}")
    ElseIf option == _oidChestsMaxAllowedRescale
        MimicConfig.GR_MimicChestsMaxAllowedRescale.SetValue(value)
        SetSliderOptionValue(option, value, "{2}")
    ElseIf option == _oidMimicLootMaxItemCount
        MimicConfig.GR_MimicLootMaxItemCount.SetValueInt(value as Int)
        SetSliderOptionValue(option, value, "{0}")
    ElseIf option == _oidMimicLootMaxGoldCount
        MimicConfig.GR_MimicLootMaxGoldCount.SetValueInt(value as Int)
        SetSliderOptionValue(option, value, "{0}")
    ElseIf option == _oidMimicLootChancePerTick
        MimicConfig.GR_MimicLootChancePerTick.SetValue(value)
        SetSliderOptionValue(option, value, "{2}")
    ElseIf option == _oidMimicLoseArmorChancePerTick
        MimicConfig.GR_MimicLoseArmorChancePerTick.SetValue(value)
        SetSliderOptionValue(option, value, "{2}")
    ElseIf option == _oidMimicLoseGoldMin
        MimicConfig.GR_MimicLoseGoldMin.SetValueInt(value as Int)
        SetSliderOptionValue(option, value, "{0}")
    ElseIf option == _oidMimicLoseGoldMax
        MimicConfig.GR_MimicLoseGoldMax.SetValueInt(value as Int)
        SetSliderOptionValue(option, value, "{0}")
    ElseIf option == _oidMimicLoseGoldChance
        MimicConfig.GR_MimicLoseGoldChance.SetValue(value)
        SetSliderOptionValue(option, value, "{2}")
    ElseIf option == _oidMimicLoseGoldScalePerLvl
        MimicConfig.GR_MimicLoseGoldScalePerLvl.SetValue(value)
        SetSliderOptionValue(option, value, "{2}")
    ElseIf option == _oidMimicVoreBadEndMinTicks
        MimicConfig.GR_MimicVoreBadEndMinTicks.SetValueInt(value as Int)
        SetSliderOptionValue(option, value, "{0}")
    EndIf
EndEvent

Event OnOptionHighlight(Int option)
    If option == _oidLoadConfig
        SetInfoText("Load settings from json. This will override all your local settings in MCM and globals.")
    ElseIf option == _oidSaveConfig
        SetInfoText("Save all local/MCM settings to json. This allows you to reload them later.")
    ElseIf option == _oidAddDebugSpells
        SetInfoText("Adds spells for mimic creation / destruction to the player.")
    ElseIf option == _oidDumpMimicsNow
        SetInfoText("This lists every single placed mimic (in the entire world) and dumps them to Papyrus log.")
    ElseIf option == _oidCheatNotifyMimics
        SetInfoText("Show a notification whenever a mimic is created (this is kind of a cheat)")
    ElseIf option == _oidMimicDistributeMimics
        SetInfoText("Replace boss chests in nearby loaded cell with mimics.")
    ElseIf option == _oidScanRadius
        SetInfoText("Search radius for candidate chests.")
    ElseIf option == _oidScanInterval
        SetInfoText("Interval between mimic placement scans (seconds).")
    ElseIf option == _oidMimicChance
        SetInfoText("Chance for a chest to become a mimic. This is done once for every chest.")
    ElseIf option == _oidMimicWeightVore
        SetInfoText("Relative weight for 'vore' mimic type when created. Hint: These mimics can have fatal outcomes when enabled.")
    ElseIf option == _oidMimicWeightSex
        SetInfoText("Relative weight for 'sex' mimic type when a mimic is created. Hint: These mimics have a long sexualised animation.")
    ElseIf option == _oidMimicWeightInstant
        SetInfoText("Relative weight for 'vore-instant' mimic type when a mimic is created. Hint: These skip the intro battle")
    ElseIf option == _oidChestsMaxAllowedRescale
        SetInfoText("Ignore chests outside this allowed rescale threshold.")
    ElseIf option == _oidMimicLoot
        SetInfoText("Enable retrieving chest loot. This only works for Mimics placed by this mod, that replace a chest.")
    ElseIf option == _oidMimicLootMaxItemCount
        SetInfoText("Maximum number of item retrievals per mimic event.")
    ElseIf option == _oidMimicLootMaxGoldCount
        SetInfoText("Maximum gold amount for a single retrieved gold stack.")
    ElseIf option == _oidMimicLootChancePerTick
        SetInfoText("Base chance per progress tick to find loot while trapped.")
    ElseIf option == _oidMimicLootChanceAccumulates
        SetInfoText("If enabled, loot chance increases with each additional tick.")
    ElseIf option == _oidMimicLoseArmor
        SetInfoText("Enable losing gear and moving them into the mimic's container. Hint: Will only work for Mimics placed by this mod.")
    ElseIf option == _oidMimicLoseArmorChancePerTick
        SetInfoText("Each 'tick' the player remains trapped in a mimic, this chance is rolled to check if gear gets stolen.")
    ElseIf option == _oidMimicLoseGold
        SetInfoText("Enable player losing fold while in mimic.")
    ElseIf option == _oidMimicLoseGoldMin
        SetInfoText("Minimum gold amount to lose.")
    ElseIf option == _oidMimicLoseGoldMax
        SetInfoText("Maximum gold amount to lose")
    ElseIf option == _oidMimicLoseGoldChance
        SetInfoText("Chance per tick to trigger gold loss. This is ")
    ElseIf option == _oidMimicLoseGoldScalePerLvl
        SetInfoText("Level scaling multiplier applied to lost gold amount.")
    ElseIf option == _oidMimicVoreBadEnd
        SetInfoText("Enable fatal bad end for vore mimic type.")
    ElseIf option == _oidMimicVoreBadEndMinTicks
        SetInfoText("Minimum vore progress ticks before bad end can trigger.")
    ElseIf option == _oidMimicVoreBadEndSimpleSlavery
        SetInfoText("Use the simple slavery outcome text for vore bad end instead of dying...")
    ElseIf option == _oidCreditsAbout
        SetInfoText("This is an unofficial TNTR extension by Gerroth1")
    ElseIf option == _oidCreditsAuthor
        SetInfoText("Special thanks for Bakafactory for creating the original TNTR mod.")
    ElseIf option == _oidDestroyAllMimics
        SetInfoText("This remove ALL placed mimics in the entire world and restore them back to original containers." \
        + " Use this for uninstalling the mod or when specifically prompted.")
    ElseIf option == _oidHelpConsequencesDisabled
        SetInfoText("Mimic consequences require `EET - Extra Evil Traps`. Assure that GR_TrapDefeat.esp is present and loaded.")
    Else
        SetInfoText("")
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

Bool Function HasLoadedMod(String pluginName)
    return Game.GetModByName(pluginName) != 255
EndFunction
