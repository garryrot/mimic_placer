Scriptname GR_MimicConsequences extends Quest  

GR_MimicPlacer Property lib Auto
Actor Property PlayerRef Auto

String ConsequenceType = "../MimicPlacer/Consequences.json"

; State
BakaTrapMimic currentMimic
BakaTrapTriggerBox currentTriggerBox
ObjectReference originalChest

Bool InVore = False
Bool IsSexVore = False
Int MimicType = 0

; The more ticks, the longer the player was in the belly of the mimic
Int VoreTicks = 0
Int FoundLoot = 0

Int DeathAfterRounds = 12

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
    RegisterForModEvent("Mimic_VoreStart", "StopVore")
EndFunction

Event OnUpdate()
    Debug("OnUpdate() MimicType=" + MimicType + " Ticks=" + VoreTicks + \
            " InVore=" + InVore + " PairedChest=" + originalChest)
    If InVore
        FindChest()
        VoreTicks += 1

        If originalChest != None
            If Utility.RandomFloat() < 0.20
                ConsFindLoot()
            EndIf
        EndIf
        If !IsSexVore && VoreTicks > DeathAfterRounds
            ConsFadeOutAndDeath()
        EndIf
        RegisterForSingleUpdate(4.0)
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
    IsSexVore = currentMimic.MimicType == 2
    MimicType = currentMimic.MimicType
    originalChest = None

    RegisterForSingleUpdate(1.0)
    ; DeathWormVoreSuccessLoop -> Worm Vore Failed
    ; SnareRopeUndoSelfFailEvent -> Snare Rope Failed
EndEvent

Function StopVore()
    InVore = False
EndFunction

; ------------ Utilities

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

; -------------- Consequences

Function ConsFindLoot()
    Form[] allItems = originalChest.GetContainerForms()
    lib.Debug("ConsFindLoot() " + allItems)

    int roll = Utility.RandomInt(1, 5)
    If roll == 1
        Debug.Notification("You find some junk in the creatures crevices")
    ElseIf roll == 3
        Debug.Notification("You find some valuables while being ravaged by the tentacles")
    ElseIf roll == 4
        Debug.Notification("Desperately probing for an escape, your hands manage to grab an item")
    ElseIf roll == 5
        Debug.Notification("There are still things in this chest...")
    EndIf

    FoundLoot += 1
    Form retrieved = allItems[Utility.RandomInt(0, allItems.Length - 1)]
    Int count = 1
    If retrieved.GetFormID() == 0xf
        count = Utility.RandomInt(1,20)
    EndIf
    originalChest.RemoveItem(retrieved, count)
    Game.GetPlayer().AddItem(retrieved, count)
    lib.Debug("Retrieved " + retrieved + " x" + count)
EndFunction

Function ConsFadeOutAndDeath()
    currentMimic.MimicShake()
    ; This doesn't work
    Game.FadeOutGame(true, true, 0.0, 40.0)
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
    Utility.Wait(9)
    currentMimic.MimicShake()
    Debug.MessageBox("Worn down by the endless assault of the tentacles, you no longer have the strength to fight back. " + \
                    "You are helplessly trapped, slowly being digested as your sanity and consiousness fades away...")
    Utility.Wait(15)
    currentMimic.MimicShake()
    Game.GetPlayer().Kill()
EndFunction

; ---------------------------------------- Fallback

; Function Consequences()
;     ; SexVore = ~43 Ticks
;     float roll = Utility.RandomFloat()
;     lib.Debug("Consequences " + VoreTicks + " roll=" + roll + " type=" + IsSexVore)
;     If FoundLoot > 0
;         Debug.MessageBox("You managed to retrieve some things from the chest")
;     EndIf
; EndFunction

Function Debug(String msg)
	lib.Debug("Consequences: " + msg)
EndFunction
