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

Function InitializeQuest()
    ; Quest starts with no objectives displayed
    Debug("GR_MimicStolenQuest initialized")
EndFunction

; Called from GR_MimicConsequences when items are stolen - displays the objective
Function MarkItemStolen(String itemCategory)
    Debug("MarkItemStolen: " + itemCategory)
    If itemCategory == "Head"
		HeadGearFound = False
        SetObjectiveDisplayed(STAGE_HEAD, true)
    ElseIf itemCategory == "Body"
		BodyGearFound = False
        SetObjectiveDisplayed(STAGE_BODY, true)
    ElseIf itemCategory == "Hands"
		HandsGearFound = False
        SetObjectiveDisplayed(STAGE_HANDS, true)
    ElseIf itemCategory == "Feet"
		FeetGearFound = False
        SetObjectiveDisplayed(STAGE_FEET, true)
    ElseIf itemCategory == "Forearm"
		ForeArmFound = False
        SetObjectiveDisplayed(STAGE_FOREARM, true)
    ElseIf itemCategory == "Amulet"
		AmuletFound = False
        SetObjectiveDisplayed(STAGE_AMULET, true)
    ElseIf itemCategory == "Circlet"
		CircletFound = False
        SetObjectiveDisplayed(STAGE_CIRCLET, true)
    ElseIf itemCategory == "Ring"
		RingFound = False
        SetObjectiveDisplayed(STAGE_RING, true)
    ElseIf itemCategory == "Calves"
		CalvesFound = False
        SetObjectiveDisplayed(STAGE_CALVES, true)
    ElseIf itemCategory == "Skirt"
		SkirtFound = False
        SetObjectiveDisplayed(STAGE_SKIRT, true)
    ElseIf itemCategory == "Panties"
		PantiesFound = False
        SetObjectiveDisplayed(STAGE_PANTIES, true)
    ElseIf itemCategory == "Shield"
		ShieldFound = False
        SetObjectiveDisplayed(STAGE_SHIELD, true)
    ElseIf itemCategory == "WeaponRight"
		WeaponRightFound = False
        SetObjectiveDisplayed(STAGE_WEAPON_RIGHT, true)
    ElseIf itemCategory == "WeaponLeft"
		WeaponLeftFound = False
        SetObjectiveDisplayed(STAGE_WEAPON_LEFT, true)
    EndIf
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

Function AddDroppedItemToAliasByCategory(String itemCategory, ObjectReference droppedItem)
    ; Add dropped item reference to the appropriate alias based on category
    Debug("Added " + droppedItem + " to " + itemCategory + " alias")
    If itemCategory == "Head"
        HeadGear.ForceRefTo(droppedItem)
    ElseIf itemCategory == "Body"
        BodyGear.ForceRefTo(droppedItem)
    ElseIf itemCategory == "Hands"
        HandsGear.ForceRefTo(droppedItem)
    ElseIf itemCategory == "Feet"
        FeetGear.ForceRefTo(droppedItem)
    ElseIf itemCategory == "Forearm"
        ForeArmGear.ForceRefTo(droppedItem)
    ElseIf itemCategory == "Amulet"
        AmuletGear.ForceRefTo(droppedItem)
    ElseIf itemCategory == "Circlet"
        CircletGear.ForceRefTo(droppedItem)
    ElseIf itemCategory == "Ring"
        RingGear.ForceRefTo(droppedItem)
    ElseIf itemCategory == "Calves"
        CalvesGear.ForceRefTo(droppedItem)
    ElseIf itemCategory == "Skirt"
        SkirtGear.ForceRefTo(droppedItem)
    ElseIf itemCategory == "Panties"
        PantiesGear.ForceRefTo(droppedItem)
    ElseIf itemCategory == "Shield"
        ShieldGear.ForceRefTo(droppedItem)
    ElseIf itemCategory == "WeaponRight"
        WeaponRight.ForceRefTo(droppedItem)
    ElseIf itemCategory == "WeaponLeft"
        WeaponLeft.ForceRefTo(droppedItem)
    EndIf
EndFunction

Function Debug(String msg)
    Debug.Trace("[omnom] STOLEN_ITEMS: " + msg)
EndFunction