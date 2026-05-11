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
    RegisterForModEvent("GR_TrapStart", "PlayerTrapped")
    RegisterForModEvent("GR_TrapEscape", "PlayerEscape")
EndFunction

Event PlayerTrapped(string eventName, string trapType, float numArg, form sender)
    Debug("PlayerTrapped " + eventName + " " + trapType + " sender=" + sender)
    If trapType == "mimic"  
        currentMimic = sender as ObjectReference

        ; Just estimate the duration of the struggle and intro 
        ; animations based on the mimic type worst case the 
        ; calculation of consequences is just not accurate
        startVore = True
        If (currentMimic as BakaTrapMimic).MimicType == 3
            ; Instant Mimic
            RegisterForSingleUpdate(1.0)
        ElseIf (currentMimic as BakaTrapMimic).MimicType == 1
            ; Vore Mimic
            RegisterForSingleUpdate(12.0)
        Else
            RegisterForSingleUpdate(20.0)
        EndIf
        RegisterForAnimationEvent(PlayerRef, "MimicVoreSpitLoop")		
        RegisterForAnimationEvent(PlayerRef, "FootLeft")
        RegisterForAnimationEvent(PlayerRef, "FootRight")
        RegisterForAnimationEvent(PlayerRef, "IdleForceDefaultState")	
    EndIf
EndEvent

Event PlayerEscape(string eventName, string trapType, float numArg, form mimic)
    Debug("PlayerEscaped " + eventName + " " + trapType)
    If trapType == "mimic"  
        Debug("Assuming player escape")
        UnregisterForAnimationEvent(PlayerRef, "MimicVoreSpitLoop")			
        UnregisterForAnimationEvent(PlayerRef, "FootLeft")
        UnregisterForAnimationEvent(PlayerRef, "FootRight")
        UnregisterForAnimationEvent(PlayerRef, "IdleForceDefaultState")
        voreStarted = false
        startVore = false
    EndIf
EndEvent

Event OnUpdate()
    Debug("OnUpdate")
    If maintenance
        If !PlayerRef.HasPerk(ActivateMimicPerk)
            PlayerRef.AddPerk(ActivateMimicPerk)
            Debug("Added activate mimic perk to player")
        EndIf
        InitActivatorForms()
        maintenance = false
        RegisterForModEvent("GR_MimicAssault", "MimicAssault")
    ElseIf voreStarted
        RegisterForSingleUpdate(11.0)
        Debug("Progressing vore...")
        currentMimic.SendModEvent("GR_TrapProgress", "mimic")
    ElseIf startVore
        startVore = false
        voreStarted = true
        Debug("Assuming player swallowed " + currentMimic + " type=" + (currentMimic as BakaTrapMimic).MimicType)
        currentMimic.SendModEvent("GR_TrapProgress", "mimic")
        RegisterForSingleUpdate(11.0)
    EndIf
EndEvent

Event MimicAssault(string eventName, string trapType, float numArg, form mimic)
    Debug("MimicAssault")
    OnActivateMimic(mimic as ObjectReference)
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
    mimic.SendModEvent("GR_TrapStart", "mimic")
EndFunction

Function OnAnimationEvent(ObjectReference source, String eventName)
    If eventName == "MimicVoreSpitLoop"	||  eventName == "FootLeft" ||  eventName == "FootRight" ||  eventName == "IdleForceDefaultState"
        Debug("Player escaped from mimic evt=" + eventName)
        voreStarted = false
        currentMimic.SendModEvent("GR_TrapEscape", "mimic")
    EndIf
EndFunction

Function Error(String msg)
    Debug.Trace("[omnom] TRAP.MIMC error: " + msg)
EndFunction

Function Debug(String msg)
	Debug.Trace("[omnom] TRAP.MIMC: " + msg)
EndFunction
