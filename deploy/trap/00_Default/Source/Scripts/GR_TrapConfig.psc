Scriptname GR_TrapConfig extends Quest

String Property TrapApproachJson = "../TrapDefeat/TrapApproach.json" Auto
String Property TrapConsequenceJson = "../TrapDefeat/TrapConsequence.json" Auto
String Property TrapBakaMimicsJson = "../MimicPlacer/BakaMimics.json" Auto
String Property TrapInteropJson = "../TrapDefeat/Interop.json" Auto

; Interop
GlobalVariable Property GR_PatchedScripts Auto

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

Event OnInit()
    Debug("OnInit")
    ; When no config files are found, default to disabled
    ; GR_TrapEnabled.SetValueInt(0)
    ; GR_TrapDamagePlayer.SetValueInt(1)
    ; GR_TrapSexualisedDialogue.SetValueInt(0)
    ; GR_TrapApproachChance.SetValue(0.55)
    ; GR_TrapApproachMaxDistance.SetValue(9000.0)
    ; GR_TrapSnareDropGold.SetValueInt(1)
    ; GR_TrapSnareDropGoldMin.SetValueInt(5)
    ; GR_TrapSnareDropGoldMax.SetValueInt(21)
    ; GR_TrapSnareDropWeapon.SetValueInt(0)
    ; GR_TrapSnareDropGoldChance.SetValue(0.7)
    ; GR_TrapSnareDropWeaponChance.SetValue(0.7)
EndEvent

Function Maintenance()
    LoadConfig()
EndFunction

Function LoadConfig()
    Debug("LoadConfig " + GR_TrapEnabled + " " + GR_TrapDamagePlayer + " " + GR_TrapSexualisedDialogue + " " + GR_TrapApproachChance)

    GR_PatchedScripts.SetValueInt(JsonUtil.GetIntValue(TrapInteropJson, "patched-scripts"))

    GR_TrapEnabled.SetValueInt(JsonUtil.GetIntValue(TrapApproachJson, "approach-enabled"))
    GR_TrapDamagePlayer.SetValueInt(JsonUtil.GetIntValue(TrapApproachJson, "damage-player"))
    GR_TrapSexualisedDialogue.SetValueInt(JsonUtil.GetIntValue(TrapApproachJson, "sexualised-dialogue"))

    GR_TrapApproachChance.SetValue(JsonUtil.GetFloatValue(TrapApproachJson, "approach-chance"))
    GR_TrapApproachMaxDistance.SetValue(JsonUtil.GetFloatValue(TrapApproachJson, "approach-max-distance"))

    GR_TrapSnareDropGold.SetValueInt(JsonUtil.GetIntValue(TrapConsequenceJson, "snare-drop-gold"))
    GR_TrapSnareDropGoldMin.SetValueInt(JsonUtil.GetIntValue(TrapConsequenceJson, "snare-drop-gold-min"))
    GR_TrapSnareDropGoldMax.SetValueInt(JsonUtil.GetIntValue(TrapConsequenceJson, "snare-drop-gold-max"))
    GR_TrapSnareDropWeapon.SetValueInt(JsonUtil.GetIntValue(TrapConsequenceJson, "snare-drop-weapon"))
    GR_TrapSnareDropGoldChance.SetValue(JsonUtil.GetFloatValue(TrapConsequenceJson, "snare-drop-gold-chance"))
    GR_TrapSnareDropWeaponChance.SetValue(JsonUtil.GetFloatValue(TrapConsequenceJson, "snare-drop-weapon-chance"))

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
        + " snare-drop-weapon-chance=" + GR_TrapSnareDropWeaponChance.GetValue() )
EndFunction

Function Debug(string msg)
    Debug.Trace("[omnom] TRAP.CNFG " + msg)
EndFunction
