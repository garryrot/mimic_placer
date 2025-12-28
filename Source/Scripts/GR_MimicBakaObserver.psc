ScriptName GR_MimicBakaObserver extends Quest Hidden 

String Config = "../MimicPlacer/Settings.json"

GR_MimicPlacer Property lib Auto
Actor Property PlayerRef Auto
Perk Property ActivateMimicPerk Auto

BakaTrapMimic currentMimic
Bool maintenance = true
Bool activate = false
Bool mimicHasSoftRefs = false

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

	if CreateSoftRefsIfRequired(mimic)
        mimicHasSoftRefs = true
    EndIf
    
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
    If mimicHasSoftRefs
        ; This is important because linked refs can cause a CDT
        ; on reload if the linked object is gone
        RemoveSoftRefs(currentMimic)
        currentMimic = None
        mimicHasSoftRefs = false
    EndIf
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

Function RemoveSoftRefs(ObjectReference mimic)
    if !mimic || mimic.IsDeleted()
        return
    EndIf
	PO3_SKSEFunctions.SetLinkedRef(mimic, None)
	PO3_SKSEFunctions.SetLinkedRef(mimic, None, lib.BakaMimicDispenseKeyword)
	PO3_SKSEFunctions.SetLinkedRef(mimic, None, lib.BakaMimicPosKeyword)
EndFunction

bool Function CreateSoftRefsIfRequired(ObjectReference mimic)
	If !mimic || mimic.IsDeleted()
		return false
	EndIf
	If (mimic.GetNthLinkedRef(1) as BakaTrapTriggerBox)
		return false ; doesn't need soft refs
	EndIf
	Debug("fixing mimic " + mimic as Form)

	BakaTrapTriggerBox box = Game.FindClosestReferenceOfTypeFromRef(lib.BakaTrapTriggerBoxForm, mimic, 120.0) as BakaTrapTriggerBox
	If box == None
	 	box = mimic.PlaceAtMe(lib.BakaTrapTriggerBoxForm) as BakaTrapTriggerBox
		Debug("Placed trigger box " + box)
	EndIf

	box.TrapType = 2 ; Always 2 for Mimic
	box.VoreTrapref = mimic
	PO3_SKSEFunctions.SetLinkedRef(mimic, box)

	ObjectReference dispenseXmarker = Game.FindClosestReferenceOfTypeFromRef(Game.GetForm(0x3B), mimic, 120.0)
	If dispenseXmarker == None
		dispenseXmarker = mimic.PlaceAtMe(Game.GetForm(0x3B))
		Debug("Placed DispenseXMarker " + (dispenseXmarker as Form))
	EndIf
	PO3_SKSEFunctions.SetLinkedRef(mimic, dispenseXmarker, lib.BakaMimicDispenseKeyword)

	ObjectReference posXmarkerHeading = Game.FindClosestReferenceOfTypeFromRef(Game.GetForm(0x34), mimic, 120.0)
	If posXmarkerHeading == None
		posXmarkerHeading = mimic.PlaceAtMe( Game.GetForm(0x34)) 
		Debug("Placed PositionXMarker " + (posXmarkerHeading as Form))
	EndIf
	PO3_SKSEFunctions.SetLinkedRef(mimic, posXmarkerHeading, lib.BakaMimicPosKeyword)
	return true
EndFunction

Function Debug(String msg)
	lib.Debug("OBSR: " + msg)
EndFunction
