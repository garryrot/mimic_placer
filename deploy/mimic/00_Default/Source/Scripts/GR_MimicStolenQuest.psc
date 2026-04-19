Scriptname GR_MimicStolenQuest extends Quest

; Quest script to track retrieval of stolen items from the mimic chest
; Creates a task for each item stolen and completes quest when all are retrieved

; Properties - Individual aliases for each stolen item
ReferenceAlias Property LootContainer Auto
ReferenceAlias Property HeadGear Auto
ReferenceAlias Property BodyGear Auto
ReferenceAlias Property HandsGear Auto
ReferenceAlias Property FeetGear Auto
ReferenceAlias Property ForeArmGear Auto
ReferenceAlias Property AmuletGear Auto
ReferenceAlias Property CircletGear Auto
ReferenceAlias Property RingGear Auto
ReferenceAlias Property CalvesGear Auto
ReferenceAlias Property SkirtGear Auto
ReferenceAlias Property PantiesGear Auto
ReferenceAlias Property ShieldGear Auto
ReferenceAlias Property WeaponRight Auto
ReferenceAlias Property WeaponLeft Auto
Actor Property PlayerRef Auto

; Item categories and quest stages
Int Property STAGE_HEAD = 10 Auto
Int Property STAGE_BODY = 20 Auto
Int Property STAGE_HANDS = 30 Auto
Int Property STAGE_FEET = 40 Auto
Int Property STAGE_FOREARM = 50 Auto
Int Property STAGE_AMULET = 60 Auto
Int Property STAGE_CIRCLET = 70 Auto
Int Property STAGE_RING = 80 Auto
Int Property STAGE_CALVES = 90 Auto
Int Property STAGE_SKIRT = 100 Auto
Int Property STAGE_PANTIES = 110 Auto
Int Property STAGE_SHIELD = 120 Auto
Int Property STAGE_WEAPON_RIGHT = 130 Auto
Int Property STAGE_WEAPON_LEFT = 140 Auto
Int Property STAGE_COMPLETE = 200 Auto

Bool HeadGearFound = True
Bool BodyGearFound = True
Bool HandsGearFound = True
Bool FeetGearFound = True
Bool ForeArmFound = True
Bool AmuletFound = True
Bool CircletFound = True
Bool RingFound = True
Bool CalvesFound = True
Bool SkirtFound = True
Bool PantiesFound = True
Bool ShieldFound = True
Bool WeaponRightFound = True
Bool WeaponLeftFound = True

Event OnInit()
    if !PlayerRef
        PlayerRef = Game.GetPlayer()
    endIf
    InitializeQuest()
EndEvent

Int Property SLOT_HEAD = 0x00000001 Auto
Int Property SLOT_BODY = 0x00000004 Auto
Int Property SLOT_HANDS = 0x00000008 Auto
Int Property SLOT_FEET = 0x00000080 Auto
Int Property SLOT_FOREARMS = 0x00000010 Auto
Int Property SLOT_AMULET = 0x00000020 Auto
Int Property SLOT_CIRCLET = 0x00001000 Auto
Int Property SLOT_RING = 0x00000040 Auto
Int Property SLOT_CALVES = 0x00000100 Auto
Int Property SLOT_49 = 0x00080000 Auto
Int Property SLOT_52 = 0x00400000 Auto
Int Property SLOT_SHIELD = 0x200 Auto
Int SLOT_RIGHTHAND = -1
Int SLOT_LEFTHAND = -2

Function InitializeQuest()
    ; Quest starts with no objectives displayed
    Debug("GR_MimicStolenQuest initialized")
EndFunction

Int Function GetStageFromSlot(Int slotID)
    If slotID == SLOT_HEAD
        return STAGE_HEAD
    ElseIf slotID == SLOT_BODY
        return STAGE_BODY
    ElseIf slotID == SLOT_HANDS
        return STAGE_HANDS
    ElseIf slotID == SLOT_FEET
        return STAGE_FEET
    ElseIf slotID == SLOT_FOREARMS
        return STAGE_FOREARM
    ElseIf slotID == SLOT_AMULET
        return STAGE_AMULET
    ElseIf slotID == SLOT_CIRCLET
        return STAGE_CIRCLET
    ElseIf slotID == SLOT_RING
        return STAGE_RING
    ElseIf slotID == SLOT_CALVES
        return STAGE_CALVES
    ElseIf slotID == SLOT_49
        return STAGE_SKIRT
    ElseIf slotID == SLOT_52
        return STAGE_PANTIES
    ElseIf slotID == SLOT_SHIELD
        return STAGE_SHIELD
    ElseIf slotID == SLOT_RIGHTHAND
        return STAGE_WEAPON_RIGHT
    ElseIf slotID == SLOT_LEFTHAND
        return STAGE_WEAPON_LEFT
    EndIf
    return 0
EndFunction

ReferenceAlias Function GetAliasFromSlot(Int slotID)
    If slotID == SLOT_HEAD
        return HeadGear
    ElseIf slotID == SLOT_BODY
        return BodyGear
    ElseIf slotID == SLOT_HANDS
        return HandsGear
    ElseIf slotID == SLOT_FEET
        return FeetGear
    ElseIf slotID == SLOT_FOREARMS
        return ForeArmGear
    ElseIf slotID == SLOT_AMULET
        return AmuletGear
    ElseIf slotID == SLOT_CIRCLET
        return CircletGear
    ElseIf slotID == SLOT_RING
        return RingGear
    ElseIf slotID == SLOT_CALVES
        return CalvesGear
    ElseIf slotID == SLOT_49
        return SkirtGear
    ElseIf slotID == SLOT_52
        return PantiesGear
    ElseIf slotID == SLOT_SHIELD
        return ShieldGear
    ElseIf slotID == SLOT_RIGHTHAND
        return WeaponRight
    ElseIf slotID == SLOT_LEFTHAND
        return WeaponLeft
    EndIf
    return None
EndFunction

Bool Function SetFoundFlagFromSlot(Int slotID, Bool value)
    If slotID == SLOT_HEAD
        HeadGearFound = value
    ElseIf slotID == SLOT_BODY
        BodyGearFound = value
    ElseIf slotID == SLOT_HANDS
        HandsGearFound = value
    ElseIf slotID == SLOT_FEET
        FeetGearFound = value
    ElseIf slotID == SLOT_FOREARMS
        ForeArmFound = value
    ElseIf slotID == SLOT_AMULET
        AmuletFound = value
    ElseIf slotID == SLOT_CIRCLET
        CircletFound = value
    ElseIf slotID == SLOT_RING
        RingFound = value
    ElseIf slotID == SLOT_CALVES
        CalvesFound = value
    ElseIf slotID == SLOT_49
        SkirtFound = value
    ElseIf slotID == SLOT_52
        PantiesFound = value
    ElseIf slotID == SLOT_SHIELD
        ShieldFound = value
    ElseIf slotID == SLOT_RIGHTHAND
        WeaponRightFound = value
    ElseIf slotID == SLOT_LEFTHAND
        WeaponLeftFound = value
    EndIf
    return true
EndFunction

; Called from GR_MimicConsequences when items are stolen - displays the objective
Function MarkItemStolen(Int slotID)
    Debug("MarkItemStolen slot: " + slotID)
    Int stage = GetStageFromSlot(slotID)
    SetFoundFlagFromSlot(slotID, false)
    SetObjectiveDisplayed(stage, true)
EndFunction

; Called when items are recovered from the chest - marks objective complete
Function MarkItemRecovered(ObjectReference item)
    Debug("MarkItemRecovered: item: " + item)
    If item == HeadGear.GetReference()
		HeadGearFound = True
		SetObjectiveCompleted(STAGE_HEAD)
    ElseIf item == BodyGear.GetReference()
		BodyGearFound = True
		SetObjectiveCompleted(STAGE_BODY)
    ElseIf item == HandsGear.GetReference()
		HandsGearFound = True
		SetObjectiveCompleted(STAGE_HANDS)
    ElseIf item == FeetGear.GetReference()
		FeetGearFound = True
		SetObjectiveCompleted(STAGE_FEET)
    ElseIf item == ForeArmGear.GetReference()
		ForeArmFound = True
		SetObjectiveCompleted(STAGE_FOREARM)
    ElseIf item == AmuletGear.GetReference()
		AmuletFound = True
		SetObjectiveCompleted(STAGE_AMULET)
    ElseIf item == CircletGear.GetReference()
		CircletFound = True
		SetObjectiveCompleted(STAGE_CIRCLET)
    ElseIf item == RingGear.GetReference()
		RingFound = True
		SetObjectiveCompleted(STAGE_RING)
    ElseIf item == CalvesGear.GetReference()
		CalvesFound = True
		SetObjectiveCompleted(STAGE_CALVES)
    ElseIf item == SkirtGear.GetReference()
		SkirtFound = True
		SetObjectiveCompleted(STAGE_SKIRT)
    ElseIf item == PantiesGear.GetReference()
		PantiesFound = True
		SetObjectiveCompleted(STAGE_PANTIES)
    ElseIf item == ShieldGear.GetReference()
		ShieldFound = True
		SetObjectiveCompleted(STAGE_SHIELD)
    ElseIf item == WeaponRight.GetReference()
		WeaponRightFound = True
		SetObjectiveCompleted(STAGE_WEAPON_RIGHT)
    ElseIf item == WeaponLeft.GetReference()
		WeaponLeftFound = True
		SetObjectiveCompleted(STAGE_WEAPON_LEFT)
    EndIf
    CheckQuestComplete()
EndFunction

Function CheckQuestComplete()
    If HeadGearFound && BodyGearFound && HandsGearFound && FeetGearFound && ForeArmFound && \
        	AmuletFound && CircletFound && RingFound && CalvesFound && SkirtFound && \
        	PantiesFound && ShieldFound && WeaponRightFound && WeaponLeftFound
        Debug("All items retrieved! Completing quest.")
        SetObjectiveDisplayed(0, true)
        CompleteQuest()
    EndIf
EndFunction

Function ResetTracking()
    Debug("Resetting stolen items tracking")
    HeadGearFound = True
    BodyGearFound = True
    HandsGearFound = True
    FeetGearFound = True
    ForeArmFound = True
    AmuletFound = True
    CircletFound = True
    RingFound = True
    CalvesFound = True
    SkirtFound = True
    PantiesFound = True
    ShieldFound = True
    WeaponRightFound = True
    WeaponLeftFound = True
EndFunction

Function AddDroppedItemToAliasByCategory(Int slotID, ObjectReference droppedItem)
    ; Add dropped item reference to the appropriate alias based on slot ID
    Debug("Added " + droppedItem + " to slot " + slotID + " alias")
    ReferenceAlias targetAlias = GetAliasFromSlot(slotID)
    If targetAlias
        targetAlias.ForceRefTo(droppedItem)
    EndIf
EndFunction

Function Debug(String msg)
    Debug.Trace("[omnom] STOLEN_ITEMS: " + msg)
EndFunction