Scriptname GR_TrapConfig extends Quest

String Property TrapApproachJson = "../TrapDefeat/TrapApproach.json" Auto
String Property TrapConsequenceJson = "../TrapDefeat/TrapConsequence.json" Auto
String Property TrapBakaMimicsJson = "../MimicPlacer/BakaMimics.json" Auto
String Property BearInteropJson = "../TrapDefeat/BearTrapPatch.json" Auto
String Property SnareInteropJson = "../TrapDefeat/SnareTrapPatch.json" Auto

; Interop
GlobalVariable Property GR_PatchedScripts Auto

; Generic
GlobalVariable Property GR_TrapEnabled Auto
GlobalVariable Property GR_TrapDamagePlayer Auto
GlobalVariable Property GR_TrapApproachChance Auto
GlobalVariable Property GR_TrapApproachMaxDistance Auto ; Deprecated
GlobalVariable Property GR_TrapDefeatMaxDistance Auto
GlobalVariable Property GR_TrapSexualisedDialogue Auto

; Snare
GlobalVariable Property GR_TrapSnareDropGoldChance Auto
GlobalVariable Property GR_TrapSnareDropGold Auto
GlobalVariable Property GR_TrapSnareDropGoldMin Auto
GlobalVariable Property GR_TrapSnareDropGoldMax Auto
GlobalVariable Property GR_TrapSnareDropWeaponChance Auto
GlobalVariable Property GR_TrapSnareDropWeapon Auto

; Patched
Bool Property PatchedBearScripts Auto
Bool Property PatchedSnareScripts Auto

; Compatibility
Bool Property AddZadAnimationFaction = False Auto 

Event OnInit()
    Debug("OnInit")
    RegisterForSingleUpdate(15.0) 
EndEvent

Event OnUpdate()
    LoadConfig()
EndEvent

Function Maintenance()
    Debug("Maintenance")
    PatchedBearScripts = JsonUtil.GetIntValue(BearInteropJson, "patched-script-bear") == 1
    PatchedSnareScripts = JsonUtil.GetIntValue(SnareInteropJson, "patched-script-snare") == 1
EndFunction

Function LoadConfig()
    Debug("LoadConfig " + GR_TrapEnabled + " " + GR_TrapDamagePlayer + " " + GR_TrapSexualisedDialogue + " " + GR_TrapApproachChance)
    Debug.Notification("Trap Outcomes: Loading configs...")

    GR_TrapEnabled.SetValueInt(JsonUtil.GetIntValue(TrapApproachJson, "approach-enabled"))
    GR_TrapDamagePlayer.SetValueInt(JsonUtil.GetIntValue(TrapApproachJson, "damage-player"))
    GR_TrapSexualisedDialogue.SetValueInt(JsonUtil.GetIntValue(TrapApproachJson, "sexualised-dialogue"))

    GR_TrapApproachChance.SetValue(JsonUtil.GetFloatValue(TrapApproachJson, "approach-chance"))
    GR_TrapDefeatMaxDistance.SetValue(JsonUtil.GetFloatValue(TrapApproachJson, "approach-max-distance"))

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
        + " approach-max-distance=" + GR_TrapDefeatMaxDistance.GetValue() \
        + " snare-drop-gold=" + GR_TrapSnareDropGold.GetValueInt() \
        + " snare-drop-gold-min=" + GR_TrapSnareDropGoldMin.GetValueInt() \
        + " snare-drop-gold-max=" + GR_TrapSnareDropGoldMax.GetValueInt() \
        + " snare-drop-weapon=" + GR_TrapSnareDropWeapon.GetValueInt() \
        + " snare-drop-gold-chance=" + GR_TrapSnareDropGoldChance.GetValue() \
        + " snare-drop-weapon-chance=" + GR_TrapSnareDropWeaponChance.GetValue() )
EndFunction


Function SaveConfig()
    Debug.Notification("Trap Outcomes: Saving configs...")

    JsonUtil.SetIntValue(TrapApproachJson, "approach-enabled", GR_TrapEnabled.GetValueInt())
    JsonUtil.SetIntValue(TrapApproachJson, "damage-player", GR_TrapDamagePlayer.GetValueInt())
    JsonUtil.SetIntValue(TrapApproachJson, "sexualised-dialogue", GR_TrapSexualisedDialogue.GetValueInt())
    JsonUtil.SetFloatValue(TrapApproachJson, "approach-chance", GR_TrapApproachChance.GetValue())
    JsonUtil.SetFloatValue(TrapApproachJson, "approach-max-distance", GR_TrapDefeatMaxDistance.GetValue())

    JsonUtil.SetIntValue(TrapConsequenceJson, "snare-drop-gold", GR_TrapSnareDropGold.GetValueInt())
    JsonUtil.SetIntValue(TrapConsequenceJson, "snare-drop-gold-min", GR_TrapSnareDropGoldMin.GetValueInt())
    JsonUtil.SetIntValue(TrapConsequenceJson, "snare-drop-gold-max", GR_TrapSnareDropGoldMax.GetValueInt())
    JsonUtil.SetIntValue(TrapConsequenceJson, "snare-drop-weapon", GR_TrapSnareDropWeapon.GetValueInt())
    JsonUtil.SetFloatValue(TrapConsequenceJson, "snare-drop-gold-chance", GR_TrapSnareDropGoldChance.GetValue())
    JsonUtil.SetFloatValue(TrapConsequenceJson, "snare-drop-weapon-chance", GR_TrapSnareDropWeaponChance.GetValue())

    JsonUtil.Save(TrapApproachJson)
    JsonUtil.Save(TrapConsequenceJson)

    Debug("saved approach-enabled=" + GR_TrapEnabled.GetValueInt() \
        + " damage-player=" + GR_TrapDamagePlayer.GetValueInt() \
        + " approach-chance=" + GR_TrapApproachChance.GetValue() \
        + " sexualised-dialogue=" + GR_TrapSexualisedDialogue.GetValueInt() \
        + " approach-max-distance=" + GR_TrapDefeatMaxDistance.GetValue() \
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
