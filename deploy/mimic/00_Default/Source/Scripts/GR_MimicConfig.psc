Scriptname GR_MimicConfig extends Quest

String Property DistributionJson = "../MimicPlacer/Distribution.json" Auto
String Property ConsequencesJson = "../MimicPlacer/Consequences.json" Auto

GR_MimicPlacer Property MimicPlacer Auto
GR_MimicScanner Property MimicScanner Auto

; Debugging / Info
GlobalVariable Property GR_MimicCheatNotifyMimics Auto ; Int

; Scanning 
GlobalVariable Property GR_MimicDistributeMimics Auto ; Int
GlobalVariable Property GR_MimicScanRadius Auto
GlobalVariable Property GR_MimicScanInterval Auto
GlobalVariable Property GR_MimicChestsMaxAllowedRescale Auto

; Mimic Placement
GlobalVariable Property GR_MimicChance Auto
GlobalVariable Property GR_MimicWeightVore Auto
GlobalVariable Property GR_MimicWeightSex Auto
GlobalVariable Property GR_MimicWeightInstant Auto

; Consequences Drop Loot
GlobalVariable Property GR_MimicLoot Auto ; Int
GlobalVariable Property GR_MimicLootMaxItemCount Auto ; Int
GlobalVariable Property GR_MimicLootMaxGoldCount Auto ; Int
GlobalVariable Property GR_MimicLootChanceAccumulates Auto ; Int
GlobalVariable Property GR_MimicLootChancePerTick Auto

; Consequences Bad End
GlobalVariable Property GR_MimicVoreBadEnd Auto ; Int
GlobalVariable Property GR_MimicVoreBadEndMinTicks Auto ; Int
GlobalVariable Property GR_MimicVoreBadEndSimpleSlavery Auto ; Int

; Consequences Drop Gold
GlobalVariable Property GR_MimicLoseGold Auto ; Int
GlobalVariable Property GR_MimicLoseGoldMin Auto ; Int
GlobalVariable Property GR_MimicLoseGoldMax Auto ; Int
GlobalVariable Property GR_MimicLoseGoldChance Auto ; Int
GlobalVariable Property GR_MimicLoseGoldScalePerLvl Auto

; Lose Armor
GlobalVariable Property GR_MimicLoseArmor Auto ; Int
GlobalVariable Property GR_MimicLoseArmorChancePerTick Auto

Event OnInit()
    Debug("OnInit")
    RegisterForSingleUpdate(15.0)
EndEvent

Event OnUpdate()
    LoadConfig()
EndEvent

Function Maintenance()
    Debug("Maintenance")
EndFunction

Function LoadConfig()
    Debug.Notification("Mimic Placer: Loading configs...")

    ; Distribution (scan-radius-outside intentionally skipped)
    GR_MimicCheatNotifyMimics.SetValueInt(JsonUtil.GetIntValue(DistributionJson, "cheat-notify-mimics"))
    GR_MimicDistributeMimics.SetValueInt(JsonUtil.GetIntValue(DistributionJson, "distribute-mimics"))
    GR_MimicScanRadius.SetValue(JsonUtil.GetFloatValue(DistributionJson, "scan-radius"))
    GR_MimicScanInterval.SetValue(JsonUtil.GetFloatValue(DistributionJson, "scan-interval"))
    GR_MimicChance.SetValue(JsonUtil.GetFloatValue(DistributionJson, "mimic-chance"))
    GR_MimicWeightVore.SetValue(JsonUtil.GetFloatValue(DistributionJson, "mimic-weight-vore"))
    GR_MimicWeightSex.SetValue(JsonUtil.GetFloatValue(DistributionJson, "mimic-weight-sex"))
    GR_MimicWeightInstant.SetValue(JsonUtil.GetFloatValue(DistributionJson, "mimic-weight-instant"))
    GR_MimicChestsMaxAllowedRescale.SetValue(JsonUtil.GetFloatValue(DistributionJson, "chests-max-allowed-rescale"))

    ; Consequences
    ; Receive Loot
    GR_MimicLoot.SetValueInt(JsonUtil.GetIntValue(ConsequencesJson, "mimic-loot"))
    GR_MimicLootMaxItemCount.SetValueInt(JsonUtil.GetIntValue(ConsequencesJson, "mimic-loot-max-item-count"))
    GR_MimicLootMaxGoldCount.SetValueInt(JsonUtil.GetIntValue(ConsequencesJson, "mimic-loot-max-gold-count"))
    GR_MimicLootChanceAccumulates.SetValueInt(JsonUtil.GetIntValue(ConsequencesJson, "mimic-loot-chance-accumulates"))
    GR_MimicLootChancePerTick.SetValue(JsonUtil.GetFloatValue(ConsequencesJson, "mimic-loot-chance-per-tick"))

    ; Lose Armor
    GR_MimicLoseArmor.SetValueInt(JsonUtil.GetIntValue(ConsequencesJson, "mimic-lose-armor"))
    GR_MimicLoseArmorChancePerTick.SetValue(JsonUtil.GetFloatValue(ConsequencesJson, "mimic-lose-armor-chance-per-tick"))
    
    ; Lose Gold
    GR_MimicLoseGold.SetValueInt(JsonUtil.GetIntValue(ConsequencesJson, "mimic-lose-gold"))
    GR_MimicLoseGoldMin.SetValueInt(JsonUtil.GetIntValue(ConsequencesJson, "mimic-lose-gold-min"))
    GR_MimicLoseGoldMax.SetValueInt(JsonUtil.GetIntValue(ConsequencesJson, "mimic-lose-gold-max"))
    GR_MimicLoseGoldChance.SetValue(JsonUtil.GetFloatValue(ConsequencesJson, "mimic-lose-gold-chance"))
    GR_MimicLoseGoldScalePerLvl.SetValue(JsonUtil.GetFloatValue(ConsequencesJson, "mimic-lose-gold-scale-per-lvl"))

    ; Bad End
    GR_MimicVoreBadEnd.SetValueInt(JsonUtil.GetIntValue(ConsequencesJson, "mimic-vore-bad-end"))
    GR_MimicVoreBadEndMinTicks.SetValueInt(JsonUtil.GetIntValue(ConsequencesJson, "mimic-vore-bad-end-min-ticks"))
    GR_MimicVoreBadEndSimpleSlavery.SetValueInt(JsonUtil.GetIntValue(ConsequencesJson, "mimic-vore-bad-end-simple-slavery"))

EndFunction

Function SaveConfig()
    Debug.Notification("Mimic Placer: Saving configs...")

    ; Distribution (scan-radius-outside intentionally not written)
    JsonUtil.SetIntValue(DistributionJson, "cheat-notify-mimics", GR_MimicCheatNotifyMimics.GetValueInt())
    JsonUtil.SetIntValue(DistributionJson, "distribute-mimics", GR_MimicDistributeMimics.GetValueInt())
    JsonUtil.SetFloatValue(DistributionJson, "scan-radius", GR_MimicScanRadius.GetValue())
    JsonUtil.SetFloatValue(DistributionJson, "scan-interval", GR_MimicScanInterval.GetValue())
    JsonUtil.SetFloatValue(DistributionJson, "mimic-chance", GR_MimicChance.GetValue())
    JsonUtil.SetFloatValue(DistributionJson, "mimic-weight-vore", GR_MimicWeightVore.GetValue())
    JsonUtil.SetFloatValue(DistributionJson, "mimic-weight-sex", GR_MimicWeightSex.GetValue())
    JsonUtil.SetFloatValue(DistributionJson, "mimic-weight-instant", GR_MimicWeightInstant.GetValue())
    JsonUtil.SetFloatValue(DistributionJson, "chests-max-allowed-rescale", GR_MimicChestsMaxAllowedRescale.GetValue())

    ; Consequences
    JsonUtil.SetIntValue(ConsequencesJson, "mimic-loot", GR_MimicLoot.GetValueInt())
    JsonUtil.SetIntValue(ConsequencesJson, "mimic-loot-max-item-count", GR_MimicLootMaxItemCount.GetValueInt())
    JsonUtil.SetIntValue(ConsequencesJson, "mimic-loot-max-gold-count", GR_MimicLootMaxGoldCount.GetValueInt())
    JsonUtil.SetIntValue(ConsequencesJson, "mimic-loot-chance-accumulates", GR_MimicLootChanceAccumulates.GetValueInt())
    JsonUtil.SetFloatValue(ConsequencesJson, "mimic-loot-chance-per-tick", GR_MimicLootChancePerTick.GetValue())

    JsonUtil.SetIntValue(ConsequencesJson, "mimic-vore-bad-end", GR_MimicVoreBadEnd.GetValueInt())
    JsonUtil.SetIntValue(ConsequencesJson, "mimic-vore-bad-end-min-ticks", GR_MimicVoreBadEndMinTicks.GetValueInt())
    JsonUtil.SetIntValue(ConsequencesJson, "mimic-vore-bad-end-simple-slavery", GR_MimicVoreBadEndSimpleSlavery.GetValueInt())

    JsonUtil.SetIntValue(ConsequencesJson, "mimic-lose-gold", GR_MimicLoseGold.GetValueInt())
    JsonUtil.SetIntValue(ConsequencesJson, "mimic-lose-gold-min", GR_MimicLoseGoldMin.GetValueInt())
    JsonUtil.SetIntValue(ConsequencesJson, "mimic-lose-gold-max", GR_MimicLoseGoldMax.GetValueInt())
    JsonUtil.SetFloatValue(ConsequencesJson, "mimic-lose-gold-chance", GR_MimicLoseGoldChance.GetValue())
    JsonUtil.SetFloatValue(ConsequencesJson, "mimic-lose-gold-scale-per-lvl", GR_MimicLoseGoldScalePerLvl.GetValue())

    JsonUtil.SetIntValue(ConsequencesJson, "mimic-lose-armor", GR_MimicLoseArmor.GetValueInt())
    JsonUtil.SetFloatValue(ConsequencesJson, "mimic-lose-armor-chance-per-tick", GR_MimicLoseArmorChancePerTick.GetValue())

    JsonUtil.Save(DistributionJson)
    JsonUtil.Save(ConsequencesJson)
EndFunction

Function AddDebugSpells()
    If MimicPlacer
        MimicPlacer.AddDebugSpells()
    EndIf
EndFunction

Function Debug(string msg)
    Debug.Trace("[omnom] MIMIC.CNFG " + msg)
EndFunction
