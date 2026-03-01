ScriptName GR_TrapMimicObserver extends Quest Hidden 

Actor Property PlayerRef Auto
Perk Property ActivateMimicPerk Auto
GR_TrapConfig Property TrapConfig Auto

; Used by perk to detect mimic activation
FormList Property MimicActivatorForms Auto

ObjectReference currentMimic
Bool maintenance = false

Bool startVore = false
Bool voreStarted = false

int trapExtraMimicFormCount = 0

Event OnInit()
    Debug("OnInit")
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
            Debug("Added activate mimic perk to player")
        EndIf
        InitActivatorForms()
        maintenance = false
    ElseIf voreStarted
        RegisterForSingleUpdate(8.0)
        Debug("Sending progress...")
        currentMimic.SendModEvent("GR_TrapProgress", "mimic")
    ElseIf startVore
        startVore = false
        voreStarted = true
        Debug("observing vore " + currentMimic + " type=" + (currentMimic as BakaTrapMimic).MimicType)

        currentMimic.SendModEvent("GR_TrapStart", "mimic")
        RegisterForAnimationEvent(PlayerRef, "MimicVoreSpitLoop")			
        RegisterForAnimationEvent(PlayerRef, "FootLeft")
        RegisterForAnimationEvent(PlayerRef, "FootRight")
        RegisterForAnimationEvent(PlayerRef, "IdleForceDefaultState")
        RegisterForSingleUpdate(8.0)
    EndIf
EndEvent

Function InitActivatorForms()
    Debug("InitActivatorForms")
    int extraMimicCount = JsonUtil.GetIntValue(TrapConfig.TrapBakaMimicsJson, "extra-mimic-form-count")
	int i = 0
	While i < extraMimicCount
        Form add = JsonUtil.GetFormValue(TrapConfig.TrapBakaMimicsJson, "extra-mimic-" + i)
		If MimicActivatorForms.Find(add) < 0
			Debug("Adding extra mimic-form " + i + ": " + add)
			MimicActivatorForms.AddForm(add)
		EndIf
		i += 1
	EndWhile
EndFunction

; Called by perk
Function OnActivateMimic(ObjectReference mimic)
    Debug("OnActivateMimic")
    currentMimic = mimic

    ; Just estimate the duration of the struggle and intro 
    ; animations based on the mimic type worst case the 
    ; calculation of consequences is just not accurate
    startVore = True
    If (mimic as BakaTrapMimic).MimicType == 3
        ; Instant Mimic
        RegisterForSingleUpdate(1.0)
    ElseIf (mimic as BakaTrapMimic).MimicType == 1
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
        currentMimic.SendModEvent("GR_TrapEscape", "mimic")
        StopObserving()
    ElseIf eventName == "FootLeft" || eventName == "FootRight" || eventName == "IdleStop" 
        Debug("Player won struggle")
        voreStarted = false
        currentMimic.SendModEvent("GR_TrapEscape", "mimic")
        StopObserving()
    Else
        Debug("Unknown event " + eventName)
    EndIf
EndFunction

Function Error(String msg)
    Debug.Trace("[omnom] TRAP.MIMC error: " + msg)
EndFunction

Function Debug(String msg)
	Debug.Trace("[omnom] TRAP.MIMC: " + msg)
EndFunction
