Scriptname GR_MimicConsequences extends Quest  

GR_MimicPlacer Property lib Auto
Actor Property PlayerRef Auto
GR_MimicStolenQuest Property MimicStolenQuest Auto

String CONFIG_FILE_CONS = "../MimicPlacer/Consequences.json"

Int SLOT_RIGHTHAND = 0
Int SLOT_LEFTHAND = 1
Int SLOT_SHIELD = 0x200
Int SLOT_HEAD = 0x00000001
Int SLOT_BODY = 0x00000004
Int SLOT_HANDS = 0x00000008
Int SLOT_FEET = 0x00000080
int SLOT_FOREARMS = 0x00000010
int SLOT_AMULET = 0x00000020
int SLOT_CIRCLET = 0x00001000
int SLOT_RING = 0x00000040
; int SLOT_CALVES = 0x00000100
; int SLOT_TAIL = 0x00000400 
; int SLOT_LONGHAIR = 0x00000800
; int SLOT_EARS = 0x00002000
; int SLOT_44 = 0x00004000
; int SLOT_45 = 0x00008000
; int SLOT_46 = 0x00010000
; int SLOT_47 = 0x00020000
; int SLOT_48 = 0x00040000
; int SLOT_49 = 0x00080000
; int SLOT_50 = 0x00100000 ; DecapitateHead
; int SLOT_51 = 0x00200000 ; Decapitate
; int SLOT_52 = 0x00400000
; int SLOT_53 = 0x00800000
; int SLOT_54 = 0x01000000
; int SLOT_55 = 0x02000000
; int SLOT_56 = 0x04000000
; int SLOT_57 = 0x08000000
; int SLOT_58 = 0x10000000
; int SLOT_59 = 0x20000000
; int SLOT_60 = 0x40000000
; int SLOT_61 = 0x80000000 ; FX01

; Config
Int ConfigMimicLoot = 1
Int ConfigMimicLootMaxItemCount = 2
Int ConfigMimicLootMaxGoldCount = 20
Int ConfigMimicLootChanceAccumulates = 1
Float ConfigMimicLootChancePerTick = 0.05
Int ConfigMimicVoreBadEnd = 1
Int ConfigVoreBadEndMinTicks = 11
Int ConfigVoreBadEndSimpleSlavery = 0

Int ConfigMimicLoseGold = 1
Int ConfigMimicLoseGoldMin = 50
Int ConfigMimicLoseGoldMax = 300
Float ConfigMimicLoseGoldLvlScale = 1.08
Float ConfigMimicLoseGoldChance = 0.3

Int ConfigMimicLoseArmor = 1
Float ConfigMimicLoseArmorChancePerTick = 0.10

; State
BakaTrapMimic currentMimic
BakaTrapTriggerBox currentTriggerBox
ObjectReference originalChest
Int MimicType = 0

Form HeadGear
Form BodyGear
Form HandsGear
Form FeetGear
Form ForeArm
Form AmuletGear
Form CircletGear
Form RingGear
Form ShieldGear
Form WeaponRight
Form WeaponLeft

; The more ticks, the longer the player was in the belly of the mimic
Int VoreTicks = 0

Int FoundLoot = 0
Int LostGear = 0
Int LostGold = 0

Int ConsequenceCnt = 0

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
    RegisterForModEvent("Mimic_VoreProgress", "ProgressVore")
    RegisterForModEvent("Mimic_VoreEnd", "StopVore")

    Init = True
    RegisterForSingleUpdate(2.0)
EndFunction

Bool Init = True
Event OnUpdate()
    If Init
        Init = False
        ConfigMimicLoot = JsonUtil.GetIntValue(CONFIG_FILE_CONS, "mimic-loot")
        ConfigMimicLootMaxItemCount = JsonUtil.GetIntValue(CONFIG_FILE_CONS, "mimic-loot-max-item-count")
        ConfigMimicLootMaxGoldCount = JsonUtil.GetIntValue(CONFIG_FILE_CONS, "mimic-loot-max-gold-count")
        ConfigMimicLootChanceAccumulates = JsonUtil.GetIntValue(CONFIG_FILE_CONS, "mimic-loot-chance-accumulates")
        ConfigMimicLootChancePerTick = JsonUtil.GetFloatValue(CONFIG_FILE_CONS, "mimic-loot-chance-per-tick")

        ConfigMimicVoreBadEnd = JsonUtil.GetIntValue(CONFIG_FILE_CONS, "mimic-vore-bad-end")
        ConfigVoreBadEndMinTicks = JsonUtil.GetIntValue(CONFIG_FILE_CONS, "mimic-vore-bad-end-min-ticks")
        ConfigVoreBadEndSimpleSlavery = JsonUtil.GetIntValue(CONFIG_FILE_CONS, "mimic-vore-bad-end-simple-slavery")

        ConfigMimicLoseArmor = JsonUtil.GetIntValue(CONFIG_FILE_CONS, "mimic-lose-armor")
        ConfigMimicLoseArmorChancePerTick = JsonUtil.GetFloatValue(CONFIG_FILE_CONS, "mimic-lose-armor-chance-per-tick")
        
        ConfigMimicLoseGold = JsonUtil.GetIntValue(CONFIG_FILE_CONS, "mimic-lose-gold")
        ConfigMimicLoseGoldMin = JsonUtil.GetIntValue(CONFIG_FILE_CONS, "mimic-lose-gold-min")
        ConfigMimicLoseGoldMax = JsonUtil.GetIntValue(CONFIG_FILE_CONS, "mimic-lose-gold-max")
        ConfigMimicLoseGoldLvlScale = JsonUtil.GetFloatValue(CONFIG_FILE_CONS, "mimic-lose-gold-scale-per-lvl")
        ConfigMimicLoseGoldChance = JsonUtil.GetFloatValue(CONFIG_FILE_CONS, "mimic-lose-gold-chance")

        Debug("Init settings MimicLoot=" + ConfigMimicLoot + \ 
            " MimicLootMaxItemCount=" + ConfigMimicLootMaxItemCount + \ 
            " MimicLootMaxGoldCount=" + ConfigMimicLootMaxGoldCount + \
            " MimicLootChanceAccumulates=" + ConfigMimicLootChanceAccumulates + \
            " MimicLootChancePerTick=" + ConfigMimicLootChancePerTick + \ 
            " MimicVoreKills=" + ConfigMimicVoreBadEnd + \
            " MimicVoreKillsAfterTicks=" + ConfigVoreBadEndMinTicks + \
            " MimicLoseArmor=" + ConfigMimicLoseArmor + \
            " MimicLoseArmorChancePerTick=" + ConfigMimicLoseArmorChancePerTick + \
            " MimicLoseGold=" + ConfigMimicLoseGold + \
            " MimicLoseGoldMin=" + ConfigMimicLoseGoldMin + \
            " MimicLoseGoldMax=" + ConfigMimicLoseGoldMax + \
            " MimicLoseGoldLvlScale=" + ConfigMimicLoseGoldLvlScale + \
            " MimicLoseGoldChance=" + ConfigMimicLoseGoldChance )
        return
    EndIf
EndEvent

; Events

Event StartVore(string eventName, string strArg, float numArg, form mimic)
    Debug("Vore started" + mimic)
    currentMimic = mimic as BakaTrapMimic
    If !currentMimic
        lib.Error("Not a mimic" + mimic)
        return
    EndIf

    LostGold = 0
    LostGear = 0
    VoreTicks = 0
    FoundLoot = 0
    ConsequenceCnt = 0

    MimicType = currentMimic.MimicType
    originalChest = None
    StoreEquippedGear()

    RegisterForSingleUpdate(8.0)
EndEvent

Event ProgressVore(string eventName, string strArg, float numArg, form mimic)
    Debug("ProgressVore MimicType=" + MimicType + " Ticks=" + VoreTicks + \
            " FoundLoot=" + FoundLoot + " PairedLootChest=" + originalChest)

    FindChest()
    VoreTicks += 1

    If originalChest != None
        If ConfigMimicLoot == 1
            Float lootChance = ConfigMimicLootChancePerTick
            If ConfigMimicLootChanceAccumulates
                lootChance = VoreTicks * ConfigMimicLootChancePerTick
            EndIf
            If VoreTicks > 2 && FoundLoot < ConfigMimicLootMaxItemCount && Utility.RandomFloat() < lootChance
                FoundLoot += 1
                ConsequenceCnt += 1
            EndIf
        EndIf

        If ConfigMimicLoseGold && LostGold == 0
            If Utility.RandomFloat() < ConfigMimicLoseGoldChance
                LoseRandomGold()
                LostGold = 0 
                ConsequenceCnt += 1
            EndIf
        EndIf

        If ConfigMimicLoseArmor == 1 && LostGear == 0
            If Utility.RandomFloat() < ConfigMimicLoseArmorChancePerTick
                StealWornGear()
                LostGear = 1
                ConsequenceCnt += 1
            EndIf
        EndIf
    EndIf

    If MimicType == 1 && ConfigMimicVoreBadEnd && VoreTicks > ConfigVoreBadEndMinTicks
        Debug("Vore killed the player VoreTicks=" + VoreTicks)
        ConsFadeOutAndDeath() 
    EndIf
EndEvent

Function StopVore(string eventName, string strArg, float numArg, form mimic)
    Debug("Vore stopped")
    FindLootWrapup()
    RegisterForSingleUpdate(8.0)
    FoundLoot = 0
EndFunction

; Utility

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

; Consequences

; Consequences - FindLoot

Function FindLootWrapup()
    int i = 0
    If FoundLoot > 0
        FindLootMessage()
    EndIf
    While i < FoundLoot
        FindLootMoveToPlayer()
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

Function FindLootMoveToPlayer()
    Form[] allItems = originalChest.GetContainerForms()
    Debug("FindLootMoveToPlayer() " + allItems)
    Form retrieved = allItems[Utility.RandomInt(0, allItems.Length - 1)]
    Int count = 1
    If retrieved.GetFormID() == 0xf
        count = Utility.RandomInt(1, ConfigMimicLootMaxGoldCount)
    EndIf
    originalChest.RemoveItem(retrieved, count, false, PlayerRef)
    Debug("Moved " + retrieved + " (" + count + ") to player")
EndFunction

; Consequences - Lose Weapon

Function StoreEquippedGear()
    HeadGear = PlayerRef.GetWornForm(SLOT_HEAD)
    BodyGear = PlayerRef.GetWornForm(SLOT_BODY)
    HandsGear = PlayerRef.GetWornForm(SLOT_HANDS)
    FeetGear = PlayerRef.GetWornForm(SLOT_FEET)
    ForeArm = PlayerRef.GetWornForm(SLOT_FOREARMS)
    AmuletGear = PlayerRef.GetWornForm(SLOT_AMULET)
    CircletGear = PlayerRef.GetWornForm(SLOT_CIRCLET)
    RingGear = PlayerRef.GetWornForm(SLOT_RING)
    ShieldGear = PlayerRef.GetWornForm(SLOT_SHIELD)
    WeaponRight = PlayerRef.GetEquippedWeapon(False)
    WeaponLeft = PlayerRef.GetEquippedWeapon(True)
EndFunction

Function StealWornGear()
    DropIfRandom(1.0, HeadGear)
    DropIfRandom(1.0, BodyGear)
    DropIfRandom(1.0, HandsGear)
    DropIfRandom(1.0, FeetGear)
    DropIfRandom(0.7, ForeArm)
    DropIfRandom(0.6, AmuletGear)
    DropIfRandom(0.6, CircletGear)
    DropIfRandom(0.6, RingGear)
    DropIfRandom(1.0, ShieldGear)
    DropIfRandom(1.0, WeaponRight)
    DropIfRandom(1.0, WeaponLeft)
    Debug.Notification("The trap swallowed your clothes...")
    If !MimicStolenQuest.IsRunning()
        Debug("Starting quest... " + MimicStolenQuest)
        MimicStolenQuest.Start()
        MimicStolenQuest.LootContainer.ForceRefTo(originalChest)
        Debug("ForcedRef " + MimicStolenQuest.LootContainer.GetRef())
    Else
        Debug.Notification("Already running")
    EndIf
EndFunction

Bool Function DropIfRandom(Float chance, Form item)
    If item
        If Utility.RandomFloat() < chance
            PlayerRef.RemoveItem(item, 1, false, originalChest)
            return true
        EndIf
    EndIf
    return false
EndFunction

; Consequences - Lose Gold

MiscObject Property Septims Auto

Function LoseRandomGold()
    If !Septims
        Septims = Game.GetForm(0xF) as MiscObject
    EndIf
    int playerGold = PlayerRef.GetItemCount(Septims)
    if playerGold <= 0
        return
    endif

    Float scaleFactor = Math.pow(ConfigMimicLoseGoldLvlScale, PlayerRef.GetLevel() as Float)
    int amount = Utility.RandomInt(ConfigMimicLoseGoldMin, ConfigMimicLoseGoldMax)
    if amount > playerGold
        amount = playerGold
    endif
    amount = (amount * scaleFactor) as int
    PlayerRef.RemoveItem(Septims, amount, false, originalChest)

    Debug("Lost " + amount + " gold, scaleFactor=" + scaleFactor)
    Debug.Notification("Gold slips out of your bags...")
EndFunction

; Consequence - Vore Death

Function ConsFadeOutAndDeath()
    currentMimic.MimicShake()
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
	Debug.Trace("[omnom] CONS: " + msg)
EndFunction
