Scriptname GR_TrapObserver extends Quest

GR_TrapDefeat Property TrapDefeatQuest Auto
GR_TrapAttack Property TrapAttackQuest Auto
GR_TrapMimicObserver Property TrapMimicObserverQuest Auto
GR_TrapConfig Property TrapConfig Auto

Actor Property PlayerRef Auto

; 0 -> mimic, 1 -> snare, 2 -> deathworm
GlobalVariable Property GR_TrapType Auto

GlobalVariable Property GR_TrapDefeatMaxDistance Auto
GlobalVariable Property GR_TrapSexDialogue Auto

; False if player was discovered via line of sight
Bool Property AlertPlayer Auto

Event OnInit()
    Debug("OnInit")
    Maintenance()
    GoToState("Default")
EndEvent

Function Maintenance()
    Debug("Maintenance")
    ResetEvents()
EndFunction

Function ResetEvents()
    UnregisterForAllModEvents()
    RegisterForModEvent("GR_TrapStart", "TrapEvent")
    RegisterForModEvent("GR_TrapProgress", "TrapEvent")
    RegisterForModEvent("GR_TrapEscape", "TrapEvent")
    
    If TrapConfig.GR_PatchedScripts.GetValueInt() == 0
        RegisterForAnimationEvent(PlayerRef, "StaggerStart") ; Escape SnareRope
        RegisterForAnimationEvent(PlayerRef, "SnareRopeUndoSelfFailEnd") ; Start Alert
        RegisterForAnimationEvent(PlayerRef, "SnareRopeUndoSelfLoop") ; Dmg stam/health
    Else 
        Debug("Scripts Patched")
    EndIf
EndFunction

String Function GetTrapType()
    Int trapTypeInt = GR_TrapType.GetValueInt()
    If trapTypeInt == 0
        return "mimic"
    ElseIf trapTypeInt == 1
        return "snare"
    ElseIf trapTypeInt == 2
        return "deathworm"
    ElseIf trapTypeInt == 3
        return "bear"
    EndIf
    return ""
EndFunction

Function SetTrapType(String trapType)
    If trapType == "mimic"
        GR_TrapType.SetValueInt(0)
    ElseIf trapType == "deathworm"
        GR_TrapType.SetValueInt(2)
    ElseIf trapType == "snare"
        GR_TrapType.SetValueInt(1)
    ElseIf trapType == "bear"
        GR_TrapType.SetValueInt(3)
    Else
        GR_TrapType.SetValueInt(-1)
    EndIf
EndFunction

Function OnAnimationEvent(ObjectReference source, String eventName)
    Debug("OnAnimationEvent Evt=" + eventName)
    If !TrapConfig.GR_TrapEnabled.GetValueInt()
        Debug("Approach disabled")
        return
    EndIf

    ; Fallback handler
    If eventName == "DeathWormVoreSuccessLoop"
        If GetState() == "Default"
            SendModEvent("GR_TrapStart", "deathworm")
        Else
            SendModEvent("GR_TrapProgress", "deathworm")
        EndIf
    ElseIf eventName == "SnareRopeUndoSelfLoop"
        If GetState() == "Default"
            SendModEvent("GR_TrapStart", "snare")
        Else
            SendModEvent("GR_TrapProgress", "snare")
        EndIf
    ElseIf eventName == "SnareRopeUndoSelfFailEnd"
        SendModEvent("GR_TrapProgress", "snare")
    ElseIf eventName == "StaggerStart"
        SendModEvent("GR_TrapEscape", GetTrapType())
    Else
        Debug("Unhandled Evt=" + eventName)
    EndIf
EndFunction

State Default
    Event OnBeginState()
        Debug("State: Default")
        ResetEvents()
        AlertPlayer = True
        If TrapDefeatQuest.IsRunning()
            Debug("Defeat quest did not terminate, stopping...")
            TrapDefeatQuest.Stop()
        EndIf
        If TrapAttackQuest.IsRunning()
            Debug("Attack quest did not terminate, stopping...")
            TrapAttackQuest.Stop()
        EndIf
    EndEvent

    Event TrapEvent(string eventName, string trapType, float numArg, form mimic)
        Debug("Event " + eventName + " TrapType=" + trapType)
        If !TrapConfig.GR_TrapEnabled.GetValueInt()
            Debug("Approach disabled")
            return
        EndIf
        If eventName == "GR_TrapStart" || eventName == "GR_TrapProgress"
            SetTrapType(trapType)
            GoToState("Trapped")
        EndIf
    EndEvent
EndState

; Trapped: Player is currently trapped but not detected by enemies
;          - If combat starts, transition to appraoch with pacified attackers
;          - If player escapes, transition to default
State Trapped
    Event OnBeginState()
        Debug("State: Trapped")
        If PlayerRef.GetCombatState() == 1
            Debug("Player already in combat")
            StartApproach()
        EndIf
    EndEvent

    Event TrapEvent(string eventName, string strArg, float numArg, Form trap)
        Debug("Event (Trapped): " + eventName + " TrapType=" + strArg)
        If eventName == "GR_TrapProgress"
            If strArg == "mimic"
                MimicProgress()
            ElseIf strArg == "snare"
                SnareProgress()
            EndIf
            ApproachIfDetected()
        ElseIf eventName == "GR_TrapEscape"
            Debug("Escaped before player was noticed")
            GoToState("PostEscape")
        EndIf
    EndEvent

    Function CombatStart()
        Debug("Player entered combat, goto approach")
        AlertPlayer = False
        StartApproach()
    EndFunction
EndState

; Attack: Player is detected by enemies but defended by follower
;         - Enemies are hostile and attack the follower
;         - OnEscape Transitions to Post-Approach
State Attack
    Event OnBeginState()
        Debug("State: Attack")
        RegisterForSingleUpdate(0.5)
    EndEvent

    Event OnUpdate()
        Debug("OnUpdate Attack")
        TrapAttackQuest.StartTrapAttack()
    EndEvent

    Function AttackSuccess()
        Debug("State: Attack Success")
        GoToState("Approach") ; Follower defeated 
    EndFunction

    Event TrapEvent(string eventName, string strArg, float numArg, form mimic)
        Debug("TrapEvent (Attack) Evt=" + eventName)
        If eventName == "GR_TrapEscape"
            GoToState("PostEscape")
        ElseIf eventName == "GR_TrapProgress"
            MimicProgress()
        EndIf
    EndEvent

    
    Event OnEndState()
        Debug("State: EndState Attack")
        UnregisterForUpdate()
    EndEvent
EndState

; Approach: Player is detected and follower is either defeated or doesn't exist
; Enemies are pacified and the defeat scene plays
State Approach
    Event OnBeginState()
        Debug("State: Approach")
        If trapDefeatQuest.IsRunning()
            Debug("DefeatQuest is already running, stopping it.")
            trapDefeatQuest.Stop()
            Utility.Wait(0.1)
        EndIf
        Debug("Starting Quest " + trapDefeatQuest)
        trapDefeatQuest.Start()
    EndEvent

    Event TrapEvent(string eventName, string strArg, float numArg, form trap)
        Debug("Event (Approach): " + eventName)
        If eventName == "GR_TrapEscape"
            GoToState("PostEscape")
        ElseIf eventName == "GR_TrapProgress"
            MimicProgress()
        EndIf
    EndEvent


    Event OnEndState()
        Debug("State: EndState Approach")
    EndEvent
EndState

; PostEscape: Player has escaped the trap
;   - Damage player stamina and returns to default
;   - If pacified, enemies remain pacified until stagger/get-up animation finishes
State PostEscape
    Event OnBeginState()
        Debug("State: PostEscape")
        If TrapDefeatQuest.IsRunning()
            trapDefeatQuest.SetStage(20)
        EndIf
        String trapType = ""
        If GR_TrapType.GetValueInt() == 1 ; Snare Rope
            trapType = "snare"
            RegisterForSingleUpdate(1.0)
        Else
            ; Mimic/VoreWorm has a longer get-up animation
            trapType = "mimic"
            RegisterForSingleUpdate(8.0)
        EndIf
    EndEvent

    Event TrapEvent(string eventName, string strArg, float numArg, form trap)
        Debug("Event (PostEscape): " + eventName + " TrapType=" + strArg)
        If eventName == "GR_TrapEscape"
            If strArg == "snare"
                SnareEscape()
            Else
                MimicEscape()
            EndIf
            GoToState("Default")
        EndIf
    EndEvent

    Event OnUpdate()
        Debug("OnUpdate Back to default" )
    EndEvent
EndState

; ==================================================
; TRANSITIONS
; ==================================================

Function StartApproach()
    Debug("StartApproach TrapType=" + GR_TrapType.GetValueInt())
    TrapAttackQuest.Start()
    Utility.Wait(0.5)

    If TrapAttackQuest.GetCurrentFollower()
        Debug("Has follower, starting attack...")
        GoToState("Attack")
    Else
        TrapAttackQuest.Stop()
        Debug("Doesn't have follower, starting deafeat...")
        GoToState("Approach")
    EndIf
EndFunction

Function FailAndResetToTrapped()
    ; Called by TrapDefat on missing enemies
    Debug("FailApproach")
    GoToState("Trapped")
EndFunction

; ==================================================
; UTILITY
; ==================================================

Bool Function ApproachIfDetected()
    If Utility.RandomFloat() < TrapConfig.GR_TrapApproachChance.GetValue()
        StartApproach()
        return true
    Else
        Debug("Roll Failed")
        return false
    EndIf
EndFunction


Function FadeAndPlaceEnemies(Actor target, Actor e1, Actor e2, Actor e3, Actor e4, Actor e5)
    Debug("FadeAndPlaceEnemies FadeToBlackImod")
    BlackFade(true)
    Utility.Wait(1.0)

    Float radius = 270.0
    Float angleStep = 360.0 / (count * 3)
    Float angle = target.GetAngleZ()
    Actor[] enemies = new Actor[5]
    enemies[ 0 ] = e1
    enemies[ 1 ] = e2
    enemies[ 2 ] = e3
    enemies[ 3 ] = e4
    enemies[ 4 ] = e5
    Int i = 0
    Int count = 3
    While i < count
        If enemies[i]
            Float xOffset = Math.Cos(angle) * radius
            Float yOffset = Math.Sin(angle) * radius
            enemies[i].MoveTo(PlayerRef, xOffset, yOffset, 0.0)
            Debug("Moving to " + xOffset + "," + yOffset + " at " + PlayerRef)
            enemies[i].EvaluatePackage()
        EndIf
        angle += angleStep
        i += 1
    EndWhile

    Utility.Wait(3.0)
    BlackFade(false)
EndFunction

; ==================================================
; NOOPs
; ==================================================

Event OnUpdate()
    Debug("OnUpdate noop")
EndEvent

Function AttackSuccess()
    Debug("AttackSuccess noop")
EndFunction

Function AttackFail()
    Debug("AttackFail noop")
EndFunction

Function CombatStart()
    Debug("CombatStart noop")
EndFunction

Event TrapEvent(string eventName, string strArg, float numArg, form sender)
    Debug("TrapEvent noop " + eventName)
EndEvent



Function PlayerEnterCombat()
    Debug("PlayerEnterCombat noop")
EndFunction

; ==================================================
; SNARE
; ==================================================

Function SnareProgress()
    DamageAV("Stamina", 1.0, 0)
    If TrapConfig.GR_TrapDamagePlayer.GetValueInt()
        DamageAV("Health", 0.2, 0.5)
    EndIf

    If TrapConfig.GR_TrapSnareDropGold.GetValueInt() && Utility.RandomFloat() < TrapConfig.GR_TrapSnareDropGoldChance.GetValue()
        DropRandomGoldScatter()
    EndIf
    If TrapConfig.GR_TrapSnareDropWeapon.GetValueInt() && Utility.RandomFloat() < TrapConfig.GR_TrapSnareDropWeaponChance.GetValue()
        DropEquippedWeapons()
    EndIf
EndFunction

Function SnareEscape()
    DamageAV("Stamina", 1.0, 0)
EndFunction

; ==================================================
; MIMIC
; ==================================================

Function MimicProgress()
    DamageAV("Stamina", 1.0, 0)
    If TrapConfig.GR_TrapDamagePlayer.GetValueInt()
        DamageAV("Magicka", 0.5, 0)
        DamageAV("Health", 0.2, 0.5)
    EndIf
EndFunction

Function MimicEscape()
    DamageAV("Stamina", 1.0, 0)
EndFunction

; ==================================================
; UTILITY
; ==================================================

MiscObject Property Septims Auto
Keyword Property MagicBoundWeapon Auto

Function DropRandomGoldScatter()
    If !Septims
        Septims = Game.GetForm(0xF) as MiscObject
    EndIf
    int playerGold = PlayerRef.GetItemCount(Septims)
    if playerGold <= 0
        return
    endif
    int totalGold = Utility.RandomInt(TrapConfig.GR_TrapSnareDropGoldMin.GetValueInt(), TrapConfig.GR_TrapSnareDropGoldMax.GetValueInt())
    if totalGold > playerGold
        totalGold = playerGold
    endif
    PlayerRef.RemoveItem(Septims, totalGold, false)
    int remaining = totalGold
    Debug.Notification("Gold drops out of your bag and scatters across the floor...")
    while remaining > 0
        int stackSize = Utility.RandomInt(1, 3)
        if stackSize > remaining
            stackSize = remaining
        endif
        ObjectReference goldRef = PlayerRef.PlaceAtMe(Septims, stackSize)
        goldRef.MoveTo(PlayerRef, Utility.RandomFloat(-30.0, 30.0), Utility.RandomFloat(-30.0, 30.0), 80.0)
        ; goldRef.ApplyHavokImpulse(Utility.RandomFloat(-0.3, 0.4), Utility.RandomFloat(-0.3, 0.3), Utility.RandomFloat(0.4, 1.7), Utility.RandomFloat(2.0, 5.0))
        remaining -= stackSize
    endwhile
EndFunction

Function DropEquippedWeapons()
    Weapon rightWeapon = PlayerRef.GetEquippedWeapon(false)
    Weapon leftWeapon  = PlayerRef.GetEquippedWeapon(true)

    Bool dropped = False
    if rightWeapon ;   !rightWeapon.HasKeyword(MagicBoundWeapon)
        PlayerRef.UnequipItem(rightWeapon)
        PlayerRef.RemoveItem(rightWeapon, 1, true)
        PlayerRef.PlaceAtMe(rightWeapon, 1).MoveTo(PlayerRef, 5, 7, 100)
        dropped = True
    endif

    if leftWeapon && leftWeapon != rightWeapon
        PlayerRef.UnequipItem(leftWeapon)
        PlayerRef.RemoveItem(leftWeapon, 1, true)
        PlayerRef.PlaceAtMe(leftWeapon, 1).MoveTo(PlayerRef, 5, 7, 100)
        dropped = True
    endif

    If dropped
        Debug.Notification("Your weapon drops to the ground...")
    EndIf
EndFunction

Function DamageAV(String avName, float percentage, float floor)
    Float value = Game.GetPlayer().GetActorValue(avName)
    Float maxValue = Game.GetPlayer().GetActorValueMax(avName)
    Float floorValue = maxValue * floor
    If value >= floorValue
        Game.GetPlayer().DamageAV(avName, maxValue * percentage)
    EndIf
    Debug("DamageAV " + value + " "  + maxValue + " " + floor + " " + floorValue)
EndFunction

Function BlackFade(bool fadeOut)
    if FadeOut
        Game.FadeOutGame(false, true, 60.0, 0.0)
    else
        Game.FadeOutGame(false, true, 0.2, 3.0)
    endIf
EndFunction

; ==================================================
; LOG
; ==================================================

Function Debug(string msg)
    Debug.Trace("[omnom] TRAP.OBSV " + msg)
EndFunction
