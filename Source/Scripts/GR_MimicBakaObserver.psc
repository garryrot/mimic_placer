ScriptName GR_MimicBakaObserver extends Quest Hidden 

String Config = "../MimicPlacer/Settings.json"

GR_MimicPlacer Property lib Auto
Actor Property PlayerRef Auto
Perk Property ActivateMimicPerk Auto

BakaTrapMimic currentMimic
Bool maintenance = true
Bool activate = false

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
    If maintenance
        If !PlayerRef.HasPerk(ActivateMimicPerk)
            PlayerRef.AddPerk(ActivateMimicPerk)
            Debug("Added activate mimic perk to player: " + PlayerRef.HasPerk(ActivateMimicPerk))
        EndIf
        maintenance = False
    Else
        Debug("observing vore " + currentMimic + " type=" + currentMimic.MimicType)
        currentMimic.SendModEvent("Mimic_VoreStart")
        RegisterForAnimationEvent(PlayerRef, "MimicVoreSpitLoop")			
        RegisterForAnimationEvent(PlayerRef, "FootLeft")
        RegisterForAnimationEvent(PlayerRef, "FootRight")
        RegisterForAnimationEvent(PlayerRef, "IdleForceDefaultState")
    EndIf
EndEvent


; Called by perk
Function OnActivateMimic(ObjectReference mimic)
	Debug("OnActivateMimic(" + mimic as Form + ")")
    currentMimic = mimic as BakaTrapMimic
	lib.FixBakaMimic(mimic)
    
    ; Just estimate the duration of the struggle and intro 
    ; animations based on the mimic type worst case the 
    ; calculation of consequences is just not accurate
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
        lib.Debug("Player escaped from mimic")
        currentMimic.SendModEvent("Mimic_VoreEnd")
        StopObserving()
	EndIf
    If eventName == "FootLeft" || eventName == "FootRight" || eventName == "IdleStop" 
        lib.Debug("Player won struggle")
        currentMimic.SendModEvent("Mimic_VoreEnd")
        StopObserving()
    EndIf
EndFunction

Function Debug(String msg)
	lib.Debug("OBSR: " + msg)
EndFunction
