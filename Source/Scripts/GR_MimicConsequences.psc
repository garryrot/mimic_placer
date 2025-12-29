Scriptname GR_MimicConsequences extends Quest  

GR_MimicPlacer Property lib Auto
Actor Property PlayerRef Auto

String ConfigConsequences = "../MimicPlacer/Consequences.json"

; Config
Int ConfigMimicLoot = 1
Int ConfigMimicLootMaxItemCount = 2
Int ConfigMimicLootMaxGoldCount = 20
Int ConfigMimicLootChanceAccumulates = 1
Float ConfigMimicLootChancePerTick = 0.5
Int ConfigMimicVoreBadEnd = 1
Int ConfigVoreBadEndMinTicks = 11
Int ConfigVoreBadEndSimpleSlavery = 1

; State
BakaTrapMimic currentMimic
BakaTrapTriggerBox currentTriggerBox
ObjectReference originalChest
Bool InVore = False
Int MimicType = 0
; The more ticks, the longer the player was in the belly of the mimic
Int VoreTicks = 0
Int FoundLoot = 0

Event OnInit()
	Maintenance()
EndEvent

Function Maintenance()
    Debug("Maintenance()")
    If !PlayerRef
        PlayerRef = Game.GetPlayer()
    EndIf
    UnregisterForAllModEvents()
    RegisterForModEvent("Mimic_VoreStart", "StartVore")
    RegisterForModEvent("Mimic_VoreEnd", "StopVore")

    Init = True
    RegisterForSingleUpdate(2.0)
EndFunction

Bool Init = True
Event OnUpdate()
    If Init
        Init = False
        ConfigMimicLoot = JsonUtil.GetIntValue(ConfigConsequences, "mimic-loot")
        ConfigMimicLootMaxItemCount = JsonUtil.GetIntValue(ConfigConsequences, "mimic-loot-max-item-count")
        ConfigMimicLootMaxGoldCount = JsonUtil.GetIntValue(ConfigConsequences, "mimic-loot-max-gold-count")
        ConfigMimicLootChanceAccumulates = JsonUtil.GetIntValue(ConfigConsequences, "mimic-loot-chance-accumulates")
        ConfigMimicLootChancePerTick = JsonUtil.GetFloatValue(ConfigConsequences, "mimic-loot-chance-per-tick")

        ConfigMimicVoreBadEnd = JsonUtil.GetIntValue(ConfigConsequences, "mimic-vore-bad-end")
        ConfigVoreBadEndMinTicks = JsonUtil.GetIntValue(ConfigConsequences, "mimic-vore-bad-end-min-ticks")
        ConfigVoreBadEndSimpleSlavery = JsonUtil.GetIntValue(ConfigConsequences, "mimic-vore-bad-end-simple-slavery")

        Debug("Init settings MimicLoot=" + ConfigMimicLoot + " MimicLootMaxItemCount=" + ConfigMimicLootMaxItemCount + \ 
             " MimicLootMaxGoldCount=" + ConfigMimicLootMaxGoldCount  + " MimicLootChanceAccumulates=" + \
             ConfigMimicLootChanceAccumulates + " MimicLootChancePerTick=" + ConfigMimicLootChancePerTick  + \
             " MimicVoreKills=" + ConfigMimicVoreBadEnd + " MimicVoreKillsAfterTicks=" + ConfigVoreBadEndMinTicks )
        return
    EndIf

    Debug("OnUpdate() MimicType=" + MimicType + " Ticks=" + VoreTicks + \
            " InVore=" + InVore + " FoundLoot=" + FoundLoot + " PairedLootChest=" + originalChest)
    If InVore
        FindChest()
        VoreTicks += 1
        If originalChest != None
            Float lootChance = ConfigMimicLootChancePerTick
            If ConfigMimicLootChanceAccumulates
                lootChance = VoreTicks * ConfigMimicLootChancePerTick
            EndIf
            If VoreTicks > 2 && FoundLoot < 2 && Utility.RandomFloat() < lootChance
                FoundLoot += 1
            EndIf
        EndIf
        If MimicType == 1 && ConfigMimicVoreBadEnd && VoreTicks > ConfigVoreBadEndMinTicks
            Debug("Vore killed the player VoreTicks=" + VoreTicks)
            ConsFadeOutAndDeath() 
        EndIf
        RegisterForSingleUpdate(8.0)
    EndIf
EndEvent

Event StartVore(string eventName, string strArg, float numArg, form mimic)
    Debug("Vore started" + mimic)
    currentMimic = mimic as BakaTrapMimic
    If !currentMimic
        lib.Error("Not a mimic" + mimic)
        return
    EndIf

    InVore = True
    VoreTicks = 0
    FoundLoot = 0
    MimicType = currentMimic.MimicType
    originalChest = None

    RegisterForSingleUpdate(8.0)
    ; DeathWormVoreSuccessLoop -> Worm Vore Failed
    ; SnareRopeUndoSelfFailEvent -> Snare Rope Failed
EndEvent

Function StopVore(string eventName, string strArg, float numArg, form mimic)
    Debug("Vore stopped")
    WrapupFindLoot()
    RegisterForSingleUpdate(8.0)
    InVore = False
    FoundLoot = 0
EndFunction

; ~~~   Loot   ~~~

Function FindChest()
    If !originalChest
        originalChest = Game.FindClosestReferenceOfAnyTypeInListFromRef( lib.LargeChestForms, currentMimic, 10.0 )
        If originalChest
            If !originalChest.IsDisabled()
                originalChest = None
            EndIf
        EndIf
    EndIf
EndFunction

Function WrapupFindLoot()
    int i = 0
    If FoundLoot > 0
        FindLootMessage()
    EndIf
    While i < FoundLoot
        ConsFindLoot()
        i += 1
    EndWhile
EndFunction

Function FindLootMessage()
    int roll = Utility.RandomInt(1, 5)
    If roll == 1
        Debug.Notification("Desperately probing for an escape, you held on to some items in the chest")
    ElseIf roll == 2
        Debug.Notification("While being ravaged by the tentacles you found some valuables")
    ElseIf roll == 3
        Debug.Notification("You found some valuables in the chest")
    ElseIf roll == 4
        Debug.Notification("Desperately probing for an escape, you held on to some items in the chest")
    ElseIf roll == 5
        Debug.Notification("You collected enough presence of mind to take some things from the chest")
    EndIf
EndFunction

Function ConsFindLoot()
    Form[] allItems = originalChest.GetContainerForms()
    lib.Debug("ConsFindLoot() " + allItems)
    Form retrieved = allItems[Utility.RandomInt(0, allItems.Length - 1)]
    Int count = 1
    If retrieved.GetFormID() == 0xf
        count = Utility.RandomInt(1,20)
    EndIf
    originalChest.RemoveItem(retrieved, count)
    Game.GetPlayer().AddItem(retrieved, count)
    lib.Debug("Retrieved " + retrieved + " x" + count)
EndFunction

; ~~~   Death   ~~~

Function ConsFadeOutAndDeath()
    currentMimic.MimicShake()
    InVore = False
    FoundLoot = 0
    Game.FadeOutGame(true, true, 0.0, 60.0)
    Utility.Wait(1.5)
    currentMimic.MimicShake()
    Utility.Wait(2.5)
    currentMimic.MimicShake()
    Utility.Wait(1.5)
    currentMimic.MimicShake()    
    Utility.Wait(2.5)
    currentMimic.MimicShake()
    Utility.Wait(5)
    currentMimic.MimicShake()
    Utility.Wait(12)
    currentMimic.MimicShake()
    Utility.Wait(9)

    If ConfigVoreBadEndSimpleSlavery == 1
        Debug.MessageBox("Too weak for any more attempts to fight back, you simply give in to the abuse. " + \
                        "As the tendrils explore every part of your body, your mind breaks and " + \
                        "you eventually pass out. You only awake as some strangers pull open the lid of the chest" + \ 
                        " and start dragging your helpless body away...")
        Utility.Wait(8.0)
        currentMimic.ResetTrap() ; Frees player
        SendModEvent("SSLV Entry")
    Else
        Debug.MessageBox("Worn down by the endless assault of the tentacles, you no longer have the strength to fight back. " + \
                        "You are helplessly trapped, slowly being digested as your sanity and consiousness fades away...")
        Utility.Wait(3)
        currentMimic.MimicShake()
        Game.GetPlayer().Kill()
    EndIf
EndFunction

Function Debug(String msg)
	lib.Debug("CONS: " + msg)
EndFunction
