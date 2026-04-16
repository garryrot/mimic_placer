Scriptname GR_MimicConsequences extends Quest  

GR_MimicPlacer Property lib Auto
Actor Property PlayerRef Auto
GR_MimicStolenQuest Property MimicStolenQuest Auto

GlobalVariable Property GR_MimicLoot Auto
GlobalVariable Property GR_MimicLootMaxItemCount Auto
GlobalVariable Property GR_MimicLootMaxGoldCount Auto
GlobalVariable Property GR_MimicLootChanceAccumulates Auto
GlobalVariable Property GR_MimicLootChancePerTick Auto

GlobalVariable Property GR_MimicVoreBadEnd Auto
GlobalVariable Property GR_MimicVoreBadEndMinTicks Auto ; Unused
GlobalVariable Property GR_MimicVoreBadEndSimpleSlavery Auto

GlobalVariable Property GR_MimicLoseGold Auto
GlobalVariable Property GR_MimicLoseGoldMin Auto
GlobalVariable Property GR_MimicLoseGoldMax Auto
GlobalVariable Property GR_MimicLoseGoldChance Auto
GlobalVariable Property GR_MimicLoseGoldScalePerLvl Auto

GlobalVariable Property GR_MimicLoseArmor Auto
GlobalVariable Property GR_MimicLoseArmorChancePerTick Auto

; State
BakaTrapMimic currentMimic
BakaTrapTriggerBox currentTriggerBox
ObjectReference originalChest
Int MimicType = 0
Int VoreTicks = 0
Int ConsequenceCnt = 0
Bool LoseArmorStarted = false

Event OnInit()
	Maintenance()
EndEvent

Function Maintenance()
    Debug("Maintenance()")
    If !PlayerRef
        PlayerRef = Game.GetPlayer()
    EndIf
    UnregisterForAllModEvents()
    RegisterForModEvent("GR_TrapStart", "StartVore")
    RegisterForModEvent("GR_TrapProgress", "ProgressVore")
    RegisterForModEvent("GR_TrapEscape", "StopVore")
    RegisterForModEvent("GR_VoreDeath", "VoreDeath")
    RegisterForModEvent("GR_MimicDispense", "MimicDispense")
    RegisterForSingleUpdate(2.0)
EndFunction

Event OnUpdate()
    ConfigFindLoot()
    ConfigBadEnd()
    ConfigLoseArmor()
    ConfigLoseGold()
EndEvent

; ==================================================
; EVENTS
; ==================================================

Event MimicDispense(string eventName, string strArg, float numArg, form mimic)
    currentMimic = mimic as BakaTrapMimic
    originalChest = None
    FindChest()
    Debug("MimicDispense " + mimic + " as " + currentMimic + " chest=" + originalChest)
    If currentMimic
		GR_BakaMimicAddon addon = Game.FindClosestReferenceOfTypeFromRef(Game.GetFormFromFile(0x816, "GR_MimicPlacer.esp"), currentMimic, 10.0) as GR_BakaMimicAddon
        If (addon) ; addon is unused but this only works for converted mimics
            FindLootMoveToReference(currentMimic, false)
        EndIf
    EndIf
EndEvent

Event StartVore(string eventName, string trapType, float numArg, form mimic)
    If trapType != "mimic"
        return
    EndIf

    Debug("StartVore " + mimic)
    currentMimic = mimic as BakaTrapMimic
    If !currentMimic
        lib.Error("Not a mimic" + mimic)
        return
    EndIf

    LostGold = 0
    VoreTicks = 0
    FoundLoot = 0
    ConsequenceCnt = 0
    LoseArmorStarted = 0

    MimicType = currentMimic.MimicType
    originalChest = None
EndEvent

Event ProgressVore(string eventName, string trapType, float numArg, form mimic)
    If trapType != "mimic"
        return
    EndIf

    FindChest()
    Debug("ProgressVore MimicType=" + MimicType + " Ticks=" + VoreTicks + " PairedLootChest=" + originalChest)

    If LoseArmorStarted == 0
        StartLoseArmor()
        LoseArmorStarted = 1
    ElseIf originalChest != None
        ProgressLoseArmor()
    EndIf

    VoreTicks += 1
    If originalChest != None
        ProgressFindLoot()
        ProgressLoseGold()
    EndIf

    ; ProgressBadEnd()
EndEvent

Function StopVore(string eventName, string trapType, float numArg, form mimic)
    If trapType != "mimic"
        return
    EndIf
    Debug("StopVore")
    StopFindLoot()
EndFunction

; ==================================================
; UTILITY
; ==================================================

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

; ==================================================
; CONSEQUENCE - FIND LOOT
; ==================================================

Int FoundLoot = 0
Int ConfigMimicLoot = 1
Int ConfigMimicLootMaxItemCount = 2
Int ConfigMimicLootMaxGoldCount = 20
Int ConfigMimicLootChanceAccumulates = 1
Float ConfigMimicLootChancePerTick = 0.05

Function ConfigFindLoot()
    ConfigMimicLoot = GR_MimicLoot.GetValueInt()
    ConfigMimicLootMaxItemCount = GR_MimicLootMaxItemCount.GetValueInt()
    ConfigMimicLootMaxGoldCount = GR_MimicLootMaxGoldCount.GetValueInt()
    ConfigMimicLootChanceAccumulates = GR_MimicLootChanceAccumulates.GetValueInt()
    ConfigMimicLootChancePerTick = GR_MimicLootChancePerTick.GetValue()

    Debug("Init settings MimicLoot=" + ConfigMimicLoot + \ 
            " MaxItemCount=" + ConfigMimicLootMaxItemCount + \ 
            " MaxGoldCount=" + ConfigMimicLootMaxGoldCount + \
            " ChanceAccumulates=" + ConfigMimicLootChanceAccumulates + \
            " ChancePerTick=" + ConfigMimicLootChancePerTick )
EndFunction

Function ProgressFindLoot()
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
EndFunction

Function StopFindLoot()
    int i = 0
    If FoundLoot > 0
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
    EndIf
    While i < FoundLoot
        FindLootMoveToReference(None, true)
        i += 1
    EndWhile
    FoundLoot = 0
EndFunction

Function FindLootMoveToReference(ObjectReference mimic, Bool moveToPlayer)
    Form[] allItems = originalChest.GetContainerForms()
    Debug("FindLootMoveToPlayer() " + allItems)
    Form retrieved = allItems[Utility.RandomInt(0, allItems.Length - 1)]
    Int count = 1
    If retrieved.GetFormID() == 0xf
        count = Utility.RandomInt(1, ConfigMimicLootMaxGoldCount)
    EndIf
    If moveToPlayer
        originalChest.RemoveItem(retrieved, count, false, PlayerRef)
    Else
        float plusX = -35
        float plusY = -55
        float angZ = mimic.GetAngleZ()
        float moveX = (Math.sin(angZ) * plusY) + (Math.cos(angZ) * plusX)
        float moveY = (Math.cos(angZ) * plusY) - (Math.sin(angZ) * plusX)
        int i = 0
        while i < count
            int amount = Utility.RandomInt(1,4)
            if amount + i > count
                amount = count - i
            EndIf
            ObjectReference dropped = originalChest.DropObject(retrieved, amount)
            dropped.MoveTo(mimic, moveX + Utility.RandomInt(-5, 5), moveY +  Utility.RandomInt(-5, 5), 35)
            Debug.Notification("The chest ejected " + retrieved.GetName())
            i += amount
        endWhile
    EndIf
    Debug("Moved '" + retrieved.GetName() + "' (" + count + ") to " + mimic)
EndFunction

; ==================================================
; CONSEQUENCE - STEAL ARMOR
; ==================================================

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
int SLOT_CALVES = 0x00000100
int SLOT_49 = 0x00080000      ; Skirt
int SLOT_52 = 0x00400000      ; Panties

; int SLOT_TAIL = 0x00000400 
; int SLOT_LONGHAIR = 0x00000800
; int SLOT_EARS = 0x00002000
; int SLOT_44 = 0x00004000
; int SLOT_45 = 0x00008000
; int SLOT_46 = 0x00010000
; int SLOT_47 = 0x00020000
; int SLOT_48 = 0x00040000
; int SLOT_50 = 0x00100000 ; DecapitateHead
; int SLOT_51 = 0x00200000 ; Decapitate
; int SLOT_53 = 0x00800000
; int SLOT_54 = 0x01000000
; int SLOT_55 = 0x02000000
; int SLOT_56 = 0x04000000
; int SLOT_57 = 0x08000000
; int SLOT_58 = 0x10000000
; int SLOT_59 = 0x20000000
; int SLOT_60 = 0x40000000
; int SLOT_61 = 0x80000000 ; FX01

Int ConfigMimicLoseArmor = 1
Int ConfigMimicLoseArmorMinTicks = 5 ; At least wait until the player is swalloed
Float ConfigMimicLoseArmorChancePerTick = 0.10

Int LostGear = 0
Form HeadGear
Form BodyGear
Form HandsGear
Form FeetGear
Form ForeArm
Form AmuletGear
Form CircletGear
Form RingGear
Form Calves
Form Slot49
Form Slot52

Form ShieldGear
Form WeaponRight
Form WeaponLeft

Function ConfigLoseArmor()
    ConfigMimicLoseArmor = GR_MimicLoseArmor.GetValueInt()
    ConfigMimicLoseArmorChancePerTick = GR_MimicLoseArmorChancePerTick.GetValue()
    Debug("ConfigLoseArmor=" + ConfigMimicLoseArmor + " ChancePerTick=" + ConfigMimicLoseArmorChancePerTick + " MinTicks=" + ConfigMimicLoseArmorMinTicks)
EndFunction

Function StartLoseArmor()
    LostGear = 0
    HeadGear = GetWornFormNonDD(SLOT_HEAD)
    BodyGear = GetWornFormNonDD(SLOT_BODY)
    HandsGear = GetWornFormNonDD(SLOT_HANDS)
    FeetGear = GetWornFormNonDD(SLOT_FEET)
    ForeArm = GetWornFormNonDD(SLOT_FOREARMS)
    AmuletGear = GetWornFormNonDD(SLOT_AMULET)
    CircletGear = GetWornFormNonDD(SLOT_CIRCLET)
    RingGear = GetWornFormNonDD(SLOT_RING)
    Calves = GetWornFormNonDD(SLOT_CALVES)
    Slot49 = GetWornFormNonDD(SLOT_49) ; Skirt
    Slot52 = GetWornFormNonDD(SLOT_52) ; Panties

    ShieldGear = PlayerRef.GetWornForm(SLOT_SHIELD)
    WeaponRight = PlayerRef.GetEquippedWeapon(False)
    WeaponLeft = PlayerRef.GetEquippedWeapon(True)
EndFunction

Form Function GetWornFormNonDD(int slot)
    Form formItem = PlayerRef.GetWornForm(slot)
    If formItem
        If formItem.HasKeywordString("zad_InventoryDevice")
            return None
        EndIf
        If formItem.HasKeywordString("zad_Lockable")
            return None
        EndIf
    EndIf
    return formItem
EndFunction

Function ProgressLoseArmor()  
    Debug("ProgressLoseArmor " + ConfigMimicLoseArmor + " LostGear=" + LostGear)   
    If ConfigMimicLoseArmor == 1 && LostGear == 0 && VoreTicks >= ConfigMimicLoseArmorMinTicks
        Float rand = Utility.RandomFloat()
        Debug(rand + "/" + ConfigMimicLoseArmorChancePerTick)
        If rand < ConfigMimicLoseArmorChancePerTick
            StealWornGear()
            LostGear = 1
            ConsequenceCnt += 1
        EndIf
    EndIf
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
    DropIfRandom(0.7, Calves)
    DropIfRandom(0.8, Slot49)
    DropIfRandom(0.8, Slot52)
    DropIfRandom(1.0, ShieldGear)
    If PlayerRef.GetEquippedWeapon(False)
        DropIfRandom(1.0, WeaponRight)
    EndIf
    If PlayerRef.GetEquippedWeapon(True)
        DropIfRandom(1.0, WeaponLeft)
    EndIf
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

; ==================================================
; CONSEQUENCE - LOSE GOLD
; ==================================================

MiscObject Property Septims Auto

Int LostGold = 0

Int ConfigMimicLoseGold = 1
Int ConfigMimicLoseGoldMinTicks = 5
Int ConfigMimicLoseGoldMin = 50
Int ConfigMimicLoseGoldMax = 300
Float ConfigMimicLoseGoldLvlScale = 1.08
Float ConfigMimicLoseGoldChance = 0.3

Function ConfigLoseGold()
    ConfigMimicLoseGold = GR_MimicLoseGold.GetValueInt()
    ConfigMimicLoseGoldMin = GR_MimicLoseGoldMin.GetValueInt()
    ConfigMimicLoseGoldMax = GR_MimicLoseGoldMax.GetValueInt()
    ConfigMimicLoseGoldLvlScale = GR_MimicLoseGoldScalePerLvl.GetValue()
    ConfigMimicLoseGoldChance = GR_MimicLoseGoldChance.GetValue()

    Debug("ConfigLoseGold=" + ConfigMimicLoseGold + \
            " Min=" + ConfigMimicLoseGoldMin + \
            " Max=" + ConfigMimicLoseGoldMax + \
            " LvlScale=" + ConfigMimicLoseGoldLvlScale + \
            " Chance=" + ConfigMimicLoseGoldChance + \
            " MinTicks=" + ConfigMimicLoseGoldMinTicks )
EndFunction

Function ProgressLoseGold()
    If ConfigMimicLoseGold && LostGold == 0 && VoreTicks >= ConfigMimicLoseGoldMinTicks
        If Utility.RandomFloat() < ConfigMimicLoseGoldChance
            LoseRandomGold()
            LostGold = 0 
            ConsequenceCnt += 1
        EndIf
    EndIf
EndFunction

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

; ==================================================
; CONSEQUENCE - BAD END
; ==================================================

Int ConfigMimicVoreBadEnd = 1
Int ConfigVoreBadEndSimpleSlavery = 0

Event VoreDeath(string eventName, string strArg, float numArg, form mimic)
    Debug("GR_VoreDeath " + eventName)
    BlackFade(true)
    Utility.Wait(3.0)

    If ConfigVoreBadEndSimpleSlavery == 1
        Debug.MessageBox("Too weak for any more attempts to struggle, you simple give in to the abuse. " + \
                        "As the tendrils explore your body, gradually, your mind breaks and " + \
                        "you eventually pass out. You only awake as some strangers pull open the lid of the chest" + \ 
                        " and start dragging your helpless body away...")
        Utility.Wait(1.0)
        currentMimic.ResetTrap() ; Frees player
        SendModEvent("GR_TrapEscape", "mimic") ; Force all update handling to stop
        SendModEvent("SSLV Entry")
    Else
        Debug.MessageBox("Worn down by the endless assault of the tentacles, you no longer have the strength to fight back. " + \
                        "You are helplessly trapped, slowly being digested as your sanity and consiousness fades away...")
        Game.GetPlayer().Kill()
        Game.GetPlayer().DamageAV("Health", 10000)
        Utility.Wait(1.0)
        currentMimic.ResetTrap()
        SendModEvent("GR_TrapEscape", "mimic") ; Force all update handling to stop
    EndIf

    Utility.Wait(3.0)
    BlackFade(false)
EndEvent

Function BlackFade(bool fadeOut)
    if FadeOut
        Game.FadeOutGame(false, true, 60.0, 0.0)
    else
        Game.FadeOutGame(false, true, 0.2, 3.0)
    endIf
EndFunction

Function ConfigBadEnd()
    ConfigMimicVoreBadEnd = GR_MimicVoreBadEnd.GetValueInt()
    ConfigVoreBadEndSimpleSlavery = GR_MimicVoreBadEndSimpleSlavery.GetValueInt()

    Debug(" VoreDeath=" + ConfigMimicVoreBadEnd + \
          " VoreBadEndSimpleSlavery=" + ConfigVoreBadEndSimpleSlavery )
EndFunction

Function Debug(String msg)
	Debug.Trace("[omnom] CONS: " + msg)
EndFunction
