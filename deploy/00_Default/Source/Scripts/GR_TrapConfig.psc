Scriptname GR_TrapConfig extends Quest

String Property GR_TrapApproachJson = "../TrapDefeat/TrapApproach.json" Auto
String Property GR_TrapConsequenceJson = "../TrapDefeat/TrapConsequence.json" Auto
String Property GR_TrapBakaMimicsJson = "../MimicPlacer/BakaMimics.json" Auto

; Generic
GlobalVariable Property GR_TrapEnabled Auto
GlobalVariable Property GR_TrapDamagePlayer Auto
GlobalVariable Property GR_TrapApproachChance Auto
GlobalVariable Property GR_TrapApproachMaxDistance Auto
GlobalVariable Property GR_TrapSexualisedDialogue Auto

; Snare
GlobalVariable Property GR_TrapSnareDropGoldChance Auto
GlobalVariable Property GR_TrapSnareDropGold Auto
GlobalVariable Property GR_TrapSnareDropGoldMin Auto
GlobalVariable Property GR_TrapSnareDropGoldMax Auto
GlobalVariable Property GR_TrapSnareDropWeaponChance Auto
GlobalVariable Property GR_TrapSnareDropWeapon Auto

; Mimic
int Property GR_TrapExtraMimicFormCount Auto

Event OnInit()
    Debug("OnInit")
    ; When no config files are found, default to disabled
    GR_TrapEnabled.SetValueInt(0)

    GR_TrapDamagePlayer.SetValueInt(1)
    GR_TrapSexualisedDialogue.SetValueInt(0)
    GR_TrapApproachChance.SetValue(0.55)
    GR_TrapApproachMaxDistance.SetValue(9000.0)

    GR_TrapSnareDropGold.SetValueInt(1)
    GR_TrapSnareDropGoldMin.SetValueInt(5)
    GR_TrapSnareDropGoldMax.SetValueInt(21)
    GR_TrapSnareDropWeapon.SetValueInt(0)
    GR_TrapSnareDropGoldChance.SetValue(0.7)
    GR_TrapSnareDropWeaponChance.SetValue(0.7)
EndEvent

Function Maintenance()
    LoadConfig()
EndFunction

Function LoadConfig()
    Debug("LoadConfig " + GR_TrapEnabled + " " + GR_TrapDamagePlayer + " " + GR_TrapSexualisedDialogue + " " + GR_TrapApproachChance)
    GR_TrapEnabled.SetValueInt(JsonUtil.GetIntValue(GR_TrapApproachJson, "approach-enabled"))
    GR_TrapDamagePlayer.SetValueInt(JsonUtil.GetIntValue(GR_TrapApproachJson, "damage-player"))
    GR_TrapSexualisedDialogue.SetValueInt(JsonUtil.GetIntValue(GR_TrapApproachJson, "sexualised-dialogue"))

    GR_TrapApproachChance.SetValue(JsonUtil.GetFloatValue(GR_TrapApproachJson, "approach-chance"))
    GR_TrapApproachMaxDistance.SetValue(JsonUtil.GetFloatValue(GR_TrapApproachJson, "approach-max-distance"))

    GR_TrapSnareDropGold.SetValueInt(JsonUtil.GetIntValue(GR_TrapConsequenceJson, "snare-drop-gold"))
    GR_TrapSnareDropGoldMin.SetValueInt(JsonUtil.GetIntValue(GR_TrapConsequenceJson, "snare-drop-gold-min"))
    GR_TrapSnareDropGoldMax.SetValueInt(JsonUtil.GetIntValue(GR_TrapConsequenceJson, "snare-drop-gold-max"))
    GR_TrapSnareDropWeapon.SetValueInt(JsonUtil.GetIntValue(GR_TrapConsequenceJson, "snare-drop-weapon"))
    GR_TrapSnareDropGoldChance.SetValue(JsonUtil.GetFloatValue(GR_TrapConsequenceJson, "snare-drop-gold-chance"))
    GR_TrapSnareDropWeaponChance.SetValue(JsonUtil.GetFloatValue(GR_TrapConsequenceJson, "snare-drop-weapon-chance"))

    GR_TrapExtraMimicFormCount = JsonUtil.GetIntValue(GR_TrapBakaMimicsJson, "extra-mimic-form-count")

    Debug("approach-enabled=" + GR_TrapEnabled.GetValueInt() \
        + " damage-player=" + GR_TrapDamagePlayer.GetValueInt() \
        + " approach-chance=" + GR_TrapApproachChance.GetValue() \
        + " sexualised-dialogue=" + GR_TrapSexualisedDialogue.GetValueInt() \
        + " approach-max-distance=" + GR_TrapApproachMaxDistance.GetValue() \
        + " snare-drop-gold=" + GR_TrapSnareDropGold.GetValueInt() \
        + " snare-drop-gold-min=" + GR_TrapSnareDropGoldMin.GetValueInt() \
        + " snare-drop-gold-max=" + GR_TrapSnareDropGoldMax.GetValueInt() \
        + " snare-drop-weapon=" + GR_TrapSnareDropWeapon.GetValueInt() \
        + " snare-drop-gold-chance=" + GR_TrapSnareDropGoldChance.GetValue() \
        + " snare-drop-weapon-chance=" + GR_TrapSnareDropWeaponChance.GetValue() \
        + " extra-mimic-form-count=" + GR_TrapExtraMimicFormCount )
EndFunction

Function Debug(string msg)
    Debug.Trace("[omnom] TRAP.CNFG " + msg)
EndFunction
