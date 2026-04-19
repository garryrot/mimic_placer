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
        InitLoseArmor()
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

Function ConfigFindLoot()
    Debug("Init settings MimicLoot=" + GR_MimicLoot.GetValueInt() + \ 
            " MaxItemCount=" + GR_MimicLootMaxItemCount.GetValueInt() + \ 
            " MaxGoldCount=" + GR_MimicLootMaxGoldCount.GetValueInt() + \
            " ChanceAccumulates=" + GR_MimicLootChanceAccumulates.GetValueInt() + \
            " ChancePerTick=" + GR_MimicLootChancePerTick.GetValue() )
EndFunction

Function ProgressFindLoot()
    If GR_MimicLoot.GetValueInt() == 1
        Float lootChance = GR_MimicLootChancePerTick.GetValue()
        If GR_MimicLootChanceAccumulates.GetValueInt()
            lootChance = VoreTicks * GR_MimicLootChancePerTick.GetValue()
        EndIf
        If VoreTicks > 2 && FoundLoot < GR_MimicLootMaxItemCount.GetValueInt() && Utility.RandomFloat() < lootChance
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
        count = Utility.RandomInt(1, GR_MimicLootMaxGoldCount.GetValueInt())
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
        endwhile
    EndIf
    Debug("Moved '" + retrieved.GetName() + "' (" + count + ") to " + mimic)
EndFunction

String Function IdentifyStolenItemCategory(Form item)
    If item == HeadGear && StolenHeadGear
        return "Head"
    ElseIf item == BodyGear && StolenBodyGear
        return "Body"
    ElseIf item == HandsGear && StolenHandsGear
        return "Hands"
    ElseIf item == FeetGear && StolenFeetGear
        return "Feet"
    ElseIf item == ForeArm && StolenForeArm
        return "Forearm"
    ElseIf item == AmuletGear && StolenAmuletGear
        return "Amulet"
    ElseIf item == CircletGear && StolenCircletGear
        return "Circlet"
    ElseIf item == RingGear && StolenRingGear
        return "Ring"
    ElseIf item == Calves && StolenCalves
        return "Calves"
    ElseIf item == Slot49 && StolenSlot49
        return "Skirt"
    ElseIf item == Slot52 && StolenSlot52
        return "Panties"
    ElseIf item == ShieldGear && StolenShieldGear
        return "Shield"
    ElseIf item == WeaponRight && StolenWeaponRight
        return "WeaponRight"
    ElseIf item == WeaponLeft && StolenWeaponLeft
        return "WeaponLeft"
    EndIf
    return ""
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

Int ConfigMimicLoseArmorMinTicks = 5 ; At least wait until the player is swalloed

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

; Track which items were stolen for quest recovery tracking
Bool StolenHeadGear = False
Bool StolenBodyGear = False
Bool StolenHandsGear = False
Bool StolenFeetGear = False
Bool StolenForeArm = False
Bool StolenAmuletGear = False
Bool StolenCircletGear = False
Bool StolenRingGear = False
Bool StolenCalves = False
Bool StolenSlot49 = False
Bool StolenSlot52 = False
Bool StolenShieldGear = False
Bool StolenWeaponRight = False
Bool StolenWeaponLeft = False

Function ConfigLoseArmor()
    Debug("ConfigLoseArmor=" + GR_MimicLoseArmor.GetValueInt() + " ChancePerTick=" + GR_MimicLoseArmorChancePerTick.GetValue() + " MinTicks=" + ConfigMimicLoseArmorMinTicks)
EndFunction

Function InitLoseArmor()
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
    Debug("ProgressLoseArmor " + GR_MimicLoseArmor.GetValueInt() + " LostGear=" + LostGear)   
    If GR_MimicLoseArmor.GetValueInt() == 1 && LostGear == 0 && VoreTicks >= ConfigMimicLoseArmorMinTicks
        Float rand = Utility.RandomFloat()
        Debug(rand + "/" + GR_MimicLoseArmorChancePerTick.GetValue())
        If rand < GR_MimicLoseArmorChancePerTick.GetValue()
            StealWornGear()
            LostGear = 1
            ConsequenceCnt += 1
        EndIf
    EndIf
EndFunction

Function StealWornGear()
    If (MimicStolenQuest.IsCompleted())
        Debug("Stolen quest previously completed, restarting...")
        MimicStolenQuest.Stop()
        Utility.Wait(0.1)
    EndIf

    If !MimicStolenQuest.IsRunning()
        MimicStolenQuest.Start()
        MimicStolenQuest.ResetTracking()
    EndIf

    MimicStolenQuest.LootContainer.ForceRefTo(originalChest)
    Debug("ForcedRef " + MimicStolenQuest.LootContainer.GetRef())

    DropIfRandom(1.0, HeadGear, "Head")
    DropIfRandom(1.0, BodyGear, "Body")
    DropIfRandom(1.0, HandsGear, "Hands")
    DropIfRandom(1.0, FeetGear, "Feet")
    DropIfRandom(0.7, ForeArm, "Forearm")
    DropIfRandom(0.6, AmuletGear, "Amulet")
    DropIfRandom(0.6, CircletGear, "Circlet")
    DropIfRandom(0.6, RingGear, "Ring")
    DropIfRandom(0.7, Calves, "Calves")
    DropIfRandom(0.8, Slot49, "Skirt")
    DropIfRandom(0.8, Slot52, "Panties")
    DropIfRandom(1.0, ShieldGear, "Shield")
    If PlayerRef.GetEquippedWeapon(False)
        DropIfRandom(1.0, WeaponRight, "WeaponRight")
    EndIf
    If PlayerRef.GetEquippedWeapon(True)
        DropIfRandom(1.0, WeaponLeft, "WeaponLeft")
    EndIf
    Debug.Notification("The trap swallowed your clothes...")
EndFunction

Bool Function DropIfRandom(Float chance, Form item, String itemCategory)
    If item
        If Utility.RandomFloat() < chance
            ObjectReference droppedItem = PlayerRef.DropObject(item, 1)
            MimicStolenQuest.AddDroppedItemToAliasByCategory(itemCategory, droppedItem)
            originalChest.AddItem(droppedItem, 1)
            MimicStolenQuest.MarkItemStolen(itemCategory)

            If itemCategory == "Head"
                StolenHeadGear = True
            ElseIf itemCategory == "Body"
                StolenBodyGear = True
            ElseIf itemCategory == "Hands"
                StolenHandsGear = True
            ElseIf itemCategory == "Feet"
                StolenFeetGear = True
            ElseIf itemCategory == "Forearm"
                StolenForeArm = True
            ElseIf itemCategory == "Amulet"
                StolenAmuletGear = True
            ElseIf itemCategory == "Circlet"
                StolenCircletGear = True
            ElseIf itemCategory == "Ring"
                StolenRingGear = True
            ElseIf itemCategory == "Calves"
                StolenCalves = True
            ElseIf itemCategory == "Skirt"
                StolenSlot49 = True
            ElseIf itemCategory == "Panties"
                StolenSlot52 = True
            ElseIf itemCategory == "Shield"
                StolenShieldGear = True
            ElseIf itemCategory == "WeaponRight"
                StolenWeaponRight = True
            ElseIf itemCategory == "WeaponLeft"
                StolenWeaponLeft = True
            EndIf
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
Int ConfigMimicLoseGoldMinTicks = 5

Function ConfigLoseGold()
    Debug("ConfigLoseGold=" + GR_MimicLoseGold.GetValueInt() + \
            " Min=" + GR_MimicLoseGoldMin.GetValueInt() + \
            " Max=" + GR_MimicLoseGoldMax.GetValueInt() + \
            " LvlScale=" + GR_MimicLoseGoldScalePerLvl.GetValue() + \
            " Chance=" + GR_MimicLoseGoldChance.GetValue() + \
            " MinTicks=" + ConfigMimicLoseGoldMinTicks )
EndFunction

Function ProgressLoseGold()
    If GR_MimicLoseGold.GetValueInt() && LostGold == 0 && VoreTicks >= ConfigMimicLoseGoldMinTicks
        If Utility.RandomFloat() < GR_MimicLoseGoldChance.GetValue()
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

    Float scaleFactor = Math.pow(GR_MimicLoseGoldScalePerLvl.GetValue(), PlayerRef.GetLevel() as Float)
    int amount = Utility.RandomInt(GR_MimicLoseGoldMin.GetValueInt(), GR_MimicLoseGoldMax.GetValueInt())
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

Event VoreDeath(string eventName, string strArg, float numArg, form mimic)
    Debug("GR_VoreDeath " + eventName)
    BlackFade(true)
    Utility.Wait(3.0)

    If GR_MimicVoreBadEndSimpleSlavery.GetValueInt() == 1
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
    Debug(" VoreDeath=" + GR_MimicVoreBadEnd.GetValueInt() + \
          " VoreBadEndSimpleSlavery=" + GR_MimicVoreBadEndSimpleSlavery.GetValueInt() )
EndFunction

Function Debug(String msg)
	Debug.Trace("[omnom] CONS: " + msg)
EndFunction
