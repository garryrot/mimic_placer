ScriptName GR_MimicBakaObserver extends Quest Hidden 

String Config = "../MimicPlacer/Settings.json"

GR_MimicPlacer Property lib Auto
Form Property BakaMimicAddonForm Auto
Actor Property PlayerRef Auto
Perk Property ActivateMimicPerk Auto

BakaTrapMimic currentMimic
Bool maintenance = true

Bool startVore = false
Bool voreStarted = false

Event OnInit()
    Maintenance()
EndEvent

Function Maintenance()
    Debug("Maintenance()")
    If !PlayerRef
        PlayerRef = Game.GetPlayer()
    EndIf
    maintenance = true
    RegisterForSingleUpdate(0.5)
EndFunction

Event OnUpdate()
    Debug("OnUpdate")
    If maintenance
        If !PlayerRef.HasPerk(ActivateMimicPerk)
            PlayerRef.AddPerk(ActivateMimicPerk)
            Debug("Added activate mimic perk to player: " + PlayerRef.HasPerk(ActivateMimicPerk))
        EndIf
        maintenance = false
        RegisterForAnimationEvent(PlayerRef, "DeathWormVoreSuccessLoop")
        RegisterForAnimationEvent(PlayerRef, "SnareRopeUndoSelfFailEvent") 
    ElseIf voreStarted
        RegisterForSingleUpdate(8.0)
        Debug("Sending progress...")
        currentMimic.SendModEvent("Mimic_VoreProgress")
    ElseIf startVore
        startVore = false
        voreStarted = true
        Debug("observing vore " + currentMimic + " type=" + currentMimic.MimicType)

        currentMimic.SendModEvent("Mimic_VoreStart")
        RegisterForAnimationEvent(PlayerRef, "MimicVoreSpitLoop")			
        RegisterForAnimationEvent(PlayerRef, "FootLeft")
        RegisterForAnimationEvent(PlayerRef, "FootRight")
        RegisterForAnimationEvent(PlayerRef, "IdleForceDefaultState")
            
        RegisterForSingleUpdate(8.0)
    EndIf
EndEvent

; Called by perk
Function OnActivateMimic(ObjectReference mimic)
    currentMimic = mimic as BakaTrapMimic

    ; This might create a small stutter
	if !(mimic.GetNthLinkedRef(1) as BakaTrapTriggerBox)
        Error("Mimic is not referenced, SHOULD NOT HAPPEN " + mimic as Form)
        GR_BakaMimicAddon addon = mimic.PlaceAtMe(Game.GetFormFromFile(0x816, "GR_MimicPlacer.esp"), 1, true) as GR_BakaMimicAddon
		addon.lib = lib
		addon.AttachToMimic(mimic, None)
    EndIf
    
    ; Just estimate the duration of the struggle and intro 
    ; animations based on the mimic type worst case the 
    ; calculation of consequences is just not accurate
    startVore = True
    If currentMimic.MimicType == 3
        ; Instant Mimic
        RegisterForSingleUpdate(1.0)
    ElseIf currentMimic.MimicType == 1
        ; Vore Mimic
        RegisterForSingleUpdate(12.0)
    Else
        RegisterForSingleUpdate(20.0)
    EndIf
EndFunction

Function StopObserving()
    Debug("StopObserving()")
    UnregisterForAnimationEvent(PlayerRef, "MimicVoreSpitLoop")			
    UnregisterForAnimationEvent(PlayerRef, "FootLeft")
    UnregisterForAnimationEvent(PlayerRef, "FootRight")
    UnregisterForAnimationEvent(PlayerRef, "IdleForceDefaultState")
EndFunction

Function OnAnimationEvent(ObjectReference source, String eventName)
	If eventName == "MimicVoreSpitLoop"
        Debug("Player escaped from mimic")
        voreStarted = false
        currentMimic.SendModEvent("Mimic_VoreEnd")
        StopObserving()
    ElseIf eventName == "FootLeft" || eventName == "FootRight" || eventName == "IdleStop" 
        Debug("Player won struggle")
        voreStarted = false
        currentMimic.SendModEvent("Mimic_VoreEnd")
        StopObserving()
    ElseIf eventName == "DeathWormVoreSuccessLoop"
        Debug("Death worm failed - Anim Event")
    ElseIf eventName == "SnareRopeUndoSelfFailEvent"
        Debug("Snare loop failed - Anim Event")
    EndIf
EndFunction

Function Error(String msg)
    Debug.Trace("[omnom] OBSV error: " + msg)
EndFunction

Function Debug(String msg)
	Debug.Trace("[omnom] OBSV: " + msg)
EndFunction
