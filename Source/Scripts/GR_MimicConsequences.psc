Scriptname GR_MimicConsequences extends Quest  

String ConsequenceType = "../MimicPlacer/ConsequenceType.json"

GR_MimicPlacer lib
Actor PlayerRef

; State
BakaTrapMimic currentMimic
BakaTrapTriggerBox currentTriggerBox
ObjectReference originalChest

Bool FallbackHandling = False
Bool InVore = False
Bool IsSexVore = False

; The more ticks, the longer the player stayed in the 
; belly of the mimic
Int VoreTicks = 0
Int FoundLoot = 0

Event OnInit()
    lib = ((self as Form) as GR_MimicPlacer)
    lib.Debug("OnInit() GR_MimicConsequences")
	Maintenance()
EndEvent

Function Maintenance()
    UnregisterForAllModEvents()

    If !PlayerRef
        PlayerRef = Game.GetPlayer()
    EndIf

    If JsonUtil.GetIntValue(ConsequenceType, "simple-consequences") != 1
        lib.Debug("Patched mimic observation...")
        FallbackHandling = False

        ; RegisterForModEvent("Mimic_StruggleStart", "OnMimicEvent")
        ; RegisterForModEvent("Mimic_StruggleFail", "OnMimicEvent")
        ; RegisterForModEvent("Mimic_StruggleSuccess", "OnMimicEvent")
        RegisterForModEvent("Mimic_VoreStart", "OnMimicEvent")
        RegisterForModEvent("Mimic_VoreEnd", "OnMimicEvent")
        ; RegisterForModEvent("Mimic_VoreContinue", "OnMimicEvent")
        ; RegisterForModEvent("Mimic_VoreStruggle", "OnMimicEvent")
        RegisterForModEvent("Mimic_VoreDeath", "OnMimicEvent")
    Else
        lib.Debug("Fallback mimic observation...")
        FallbackHandling = True
        RegisterForModEvent("GR_MimicActivated", "StartVore")
    EndIf

EndFunction

Event OnMimicEvent(string eventName, string _, float mimicType, Form sender)
    lib.Debug(eventName + " " + mimicType + " sender: " + sender)
    currentMimic = sender as BakaTrapMimic
    IsSexVore = (mimicType as Int) == 2
    If eventName == "Mimic_VoreStart"
        If !InVore
            InVore = true
            VoreTicks = 0
            FoundLoot = 0
            originalChest = none
            RegisterForSingleUpdate(8.0)
        EndIf
    ElseIf eventName == "Mimic_VoreEnd"
        InVore = false
    ElseIf eventName == "Mimic_VoreDeath"
    EndIf
EndEvent

; ----------------------------------------

Event OnUpdate()
    lib.Debug("OnUpdate() Consequence Fallback=" + FallbackHandling + " Ticks=" + VoreTicks + " InVore=" + InVore + " Chest=" + originalChest)
    If InVore
        FindChest()
        VoreTicks += 1
        If originalChest != None
            If Utility.RandomFloat() < 0.20
                ConsFindLoot()
            EndIf
        Else
            lib.Debug("Container not found on mimic")
        EndIf
        If !IsSexVore && VoreTicks > 12
            ConsFadeOutAndDeath()
        EndIf
        RegisterForSingleUpdate(4.0)
    Else
        Consequences()
    EndIf
EndEvent

Function FindChest()
    If !originalChest
        originalChest = Game.FindClosestReferenceOfAnyTypeInListFromRef( lib.LargeChestForms, currentMimic, 10.0 )
        If originalChest
            If !originalChest.IsDisabled()
                lib.Debug("Found paired container")
                originalChest = None
            EndIf
        EndIf
    EndIf
EndFunction

; -------------------------------------- Consequences

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
        Debug.Notification("There's are still things in this crate...")
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
    Utility.Wait(15)
    currentMimic.MimicShake()
    Debug.MessageBox("Worn down by the endless assault of the tentacles, you no longer have the strength to fight back. " + \
                        "You are helplessly trapped, slowly being digested as your sanity and consiousness fades away...")
    Utility.Wait(5)
    Game.GetPlayer().Kill()
EndFunction

; ---------------------------------------- Fallback

Function Consequences()
    ; SexVore = ~43 Ticks
    float roll = Utility.RandomFloat()
    lib.Debug("Consequences " + VoreTicks + " roll=" + roll + " type=" + IsSexVore)
    If FoundLoot > 0
        Debug.MessageBox("You managed to retrieve some things from the chest")
    EndIf
EndFunction

Event StartVore(string _, string __, float ___, form sender)
    lib.Debug("Player activated mimic " + sender)
    currentMimic = sender as BakaTrapMimic
    If !currentMimic
        lib.Error("Not a mimic" + sender)
        return
    EndIf

    InVore = True
    VoreTicks = 0
    IsSexVore = currentMimic.MimicType == 2
    originalChest = None

    RegisterForAnimationEvent(PlayerRef, "MimicVoreSpitLoop")			
    RegisterForAnimationEvent(PlayerRef, "FootLeft")
    RegisterForAnimationEvent(PlayerRef, "FootRight")
    RegisterForAnimationEvent(PlayerRef, "IdleStop")

    ; Just estimate that the struggle scene takes this long
    If currentMimic.MimicType == 3
        ; Instant Mimic
        RegisterForSingleUpdate(1.0)
    ElseIf currentMimic.MimicType == 1
        ; Vore Mimic
        RegisterForSingleUpdate(10.0)
    Else
        RegisterForSingleUpdate(20.0)
    EndIf

    ; DeathWormVoreSuccessLoop -> Worm Vore Failed
    ; SnareRopeUndoSelfFailEvent -> Snare Rope Failed
EndEvent

Function StopVore()
    lib.Debug("Unregistering events...")
    InVore = False
    UnRegisterForAnimationEvent(PlayerRef, "MimicVoreSpitLoop")			
    UnRegisterForAnimationEvent(PlayerRef, "FootLeft")
    UnRegisterForAnimationEvent(PlayerRef, "FootRight")
    UnRegisterForAnimationEvent(PlayerRef, "IdleStop")
EndFunction

Function OnAnimationEvent(ObjectReference source, String eventName)
	If eventName == "MimicVoreSpitLoop"
        lib.Debug("Player escaped from mimic")
        StopVore()
	EndIf
    If eventName == "FootLeft" || eventName == "FootRight" || eventName == "IdleStop" 
        lib.Debug("Player won struggle")
        StopVore()
    EndIf
EndFunction