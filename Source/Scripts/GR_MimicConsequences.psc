Scriptname GR_MimicConsequences extends Quest  

String ConsequenceType = "../MimicPlacer/ConsequenceType.json"

GR_MimicPlacer lib

; State
BakaTrapMimic currentMimic
BakaTrapTriggerBox currentTriggerBox
ObjectReference originalChest

Bool InVore = False
Bool IsSexVore = False

Event OnInit()
    lib = ((self as Form) as GR_MimicPlacer)
    lib.Debug("OnInit() GR_MimicConsequences")
	Maintenance()
EndEvent

Function Maintenance()
    UnregisterForAllModEvents()
    If JsonUtil.GetIntValue(ConsequenceType, "simple-consequences") == 1
        return
    EndIf

    lib.Debug("Using full consequences...")
    RegisterForModEvent("Mimic_StruggleStart", "OnMimicEvent")
    RegisterForModEvent("Mimic_StruggleFail", "OnMimicEvent")
    RegisterForModEvent("Mimic_StruggleSuccess", "OnMimicEvent")
    RegisterForModEvent("Mimic_VoreStart", "OnMimicEvent")
    RegisterForModEvent("Mimic_VoreEnd", "OnMimicEvent")
    RegisterForModEvent("Mimic_VoreContinue", "OnMimicEvent")
    RegisterForModEvent("Mimic_VoreStruggle", "OnMimicEvent")
    RegisterForModEvent("Mimic_VoreDeath", "OnMimicEvent")
EndFunction

Event OnMimicEvent(string eventName, string _, float mimicType, Form sender)
    lib.Debug(eventName + " " + mimicType + " sender: " + sender)
    currentMimic = sender as BakaTrapMimic
    IsSexVore = (mimicType as Int) == 2

    If eventName == "Mimic_VoreStart"
        If !InVore
            InVore = true
            originalChest = Game.FindClosestReferenceOfAnyTypeInListFromRef( lib.LargeChestForms, currentMimic, 10.0 )
            If !originalChest.IsDisabled()
                originalChest = None
            EndIf
            RegisterForSingleUpdate(8.0)
        EndIf
    ElseIf eventName == "Mimic_VoreEnd"
        InVore = false
    ElseIf eventName == "Mimic_VoreDeath"
        Game.FadeOutGame( true, true, 0.0, 20.0 )
        Utility.Wait(5.0)

        Debug.MessageBox("Worn down by the endless assault of the tentacles you no longer have the strength to fight back. " + \
                         "You are helplessly trapped, slowly being digested as your sanity and humanity fades away.")
    EndIf
EndEvent

Event OnUpdate()
    If InVore
        If originalChest != None
            If Utility.RandomFloat() < 0.20
                ConsFindLoot()
            EndIf
        Else
            lib.Debug("Container not found on mimic")
        EndIf
        RegisterForSingleUpdate(4.0)
    EndIf
EndEvent

Function ConsLooseMind()
    int roll = Utility.RandomInt(0, 3)
    Debug.Notification("Your sanity is waning, escaping becomes harder and harder...")
    ; TODO OnVoreContinue
EndFunction

Function ConsStealArmor()
    Actor player = Game.GetPlayer()
    ; Baka unequips armor on first round
EndFunction

Function ConsFindLoot()
    Form[] allItems = originalChest.GetContainerForms()
    lib.Debug("ConsFindLoot() " + allItems)

    int roll = Utility.RandomInt(1, 5)
    If roll == 1
        Debug.Notification("You find some junk in the creatures crevices")
    ElseIf roll == 3
        Debug.Notification("You find some valuables while being ravaged by the tentacles")
    ElseIf roll == 4
        Debug.Notification("Desperately probing for an escape, your hands grab an item")
    ElseIf roll == 5
        Debug.Notification("")
    EndIf

    Form retrieved = allItems[Utility.RandomInt(0, allItems.Length - 1)]
    Int count = 1
    If retrieved.GetFormID() == 0xf
        count = Utility.RandomInt(1,20)
    EndIf
    originalChest.RemoveItem(retrieved, count)
    Game.GetPlayer().AddItem(retrieved, count)
    lib.Debug("Retrieved " + retrieved + " x" + count)
EndFunction

