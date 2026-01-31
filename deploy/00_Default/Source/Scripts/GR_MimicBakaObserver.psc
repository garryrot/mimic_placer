ScriptName GR_MimicBakaObserver extends Quest Hidden 

String Config = "../MimicPlacer/Settings.json"

GR_MimicPlacer Property lib Auto

Actor Property PlayerRef Auto

Form Property BakaMimicAddonForm Auto
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
    UnregisterForAnimationEvent(PlayerRef, "MimicVoreSpitLoop")			
    UnregisterForAnimationEvent(PlayerRef, "FootLeft")
    UnregisterForAnimationEvent(PlayerRef, "FootRight")
    UnregisterForAnimationEvent(PlayerRef, "IdleForceDefaultState")
EndFunction

; Called by perk
Function OnActivateMimic(ObjectReference mimic)
    Debug("OnActivateMimic")
    currentMimic = mimic as BakaTrapMimic

    ; This might create a small stutter
	if !(mimic.GetNthLinkedRef(1) as BakaTrapTriggerBox)
        Error("Mimic is not referenced, SHOULD NOT HAPPEN " + mimic as Form)
        GR_BakaMimicAddon addon = mimic.PlaceAtMe(Game.GetFormFromFile(0x816, "GR_MimicPlacer.esp"), 1, true) as GR_BakaMimicAddon
		addon.lib = lib
		addon.AttachToMimic(mimic, None)
    EndIf
EndFunction

Function Error(String msg)
    Debug.Trace("[omnom] OBSV error: " + msg)
EndFunction

Function Debug(String msg)
	Debug.Trace("[omnom] OBSV: (NEVER CALLED)" + msg)
EndFunction
