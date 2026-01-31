Scriptname GR_TrapDefeatObserver extends Quest

GR_TrapDefeat Property TrapDefeatQuest Auto
GR_TrapAttack Property TrapAttackQuest Auto
GR_TrapMimicObserver Property TrapMimicObserverQuest Auto

Actor Property PlayerRef Auto

; 0 -> Mimic, 1 -> SnareLoop, 2 -> DeathWorm
GlobalVariable Property GR_TrapType Auto

; False if player was discovered via line of sight
Bool Property AlertPlayer Auto

; ==================================================
; INIT
; ==================================================

Event OnInit()
    Debug("OnInit")
    ResetEvents()
    GoToState("Default")
EndEvent

Function Maintenance()
    Debug("Maintenance")
    ResetEvents()
EndFunction

; ==================================================
; EVENT REGISTRATION
; ==================================================

Function ResetEvents()
    UnregisterForAllModEvents()
    RegisterForModEvent("Mimic_VoreStart", "TrapEvent")
    RegisterForModEvent("Mimic_VoreProgress", "TrapEvent")
    RegisterForModEvent("Mimic_VoreEnd", "TrapEvent")

    RegisterForAnimationEvent(PlayerRef, "staggerStart") ; Escape SnareRope
    RegisterForAnimationEvent(PlayerRef, "SnareRopeUndoSelfFailEnd") ; Start Alert
    RegisterForAnimationEvent(PlayerRef, "SnareRopeUndoSelfLoop") ; Dmg stam/health
EndFunction

; ==================================================
; STATES
; ==================================================

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

    Event TrapEvent(string eventName, string strArg, float numArg, form mimic)
        Debug("Event " + eventName)
        If eventName == "Mimic_VoreStart"
            GR_TrapType.SetValueInt(0) ; Mimic
            GoToState("Trapped")
        EndIf
    EndEvent

    Function OnAnimationEvent(ObjectReference source, String eventName)
        Debug("OnAnimationEvent (Default) Evt=" + eventName)
        If eventName == "DeathWormVoreSuccessLoop"
            GR_TrapType.SetValueInt(2) ; Deathworm
            If !ApproachIfDetected()
                GoToState("Trapped")
            EndIf
            return
        ElseIf eventName == "SnareRopeUndoSelfLoop"
            GR_TrapType.SetValueInt(1) ; SnareRope
            DamageAV("Stamina", 1.0, 0)
            DamageAV("Health", 0.2, 0.5)
            GoToState("Trapped")
        Else
            Debug("Unhandled Evt=" + eventName)
        EndIf
    EndFunction
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
        Else
            ApproachIfDetected()
        EndIf
    EndEvent

    Event TrapEvent(string eventName, string strArg, float numArg, Form trap)
        Debug("Event (Trapped): " + eventName)
        If eventName == "Mimic_VoreProgress"
            DamageAV("Stamina", 1.0, 0)
            DamageAV("Magicka", 0.5, 0)
            DamageAV("Health", 0.2, 0.5)
            ApproachIfDetected()
        ElseIf eventName == "Mimic_VoreEnd"
            Debug("Escaped before player was noticed")
            GoToState("PostEscape")
        EndIf
    EndEvent

    Function OnAnimationEvent(ObjectReference source, String eventName)
        Debug("OnAnimationEvent (Trapped) Evt=" + eventName)
        If eventName == "DeathWormVoreSuccessLoop" ; Will probably never happen
            ApproachIfDetected()
        ElseIf eventName == "SnareRopeUndoSelfFailEnd"
            ApproachIfDetected()
        ElseIf eventName == "staggerStart"
            GoToState("PostEscape")
        ElseIf eventName == "SnareRopeUndoSelfLoop"
            DamageAV("Stamina", 1.0, 0)
        Else
            Debug("Unhandled Evt=" + eventName)
        EndIf
    EndFunction

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
        If eventName == "Mimic_VoreEnd"
            GoToState("PostEscape")
        ElseIf eventName == "Mimic_VoreProgress"
            DamageAV("Stamina", 1.0, 0)
            DamageAV("Magicka", 0.5, 0)
            DamageAV("Health", 0.2, 0.5)
        EndIf
    EndEvent

    Function OnAnimationEvent(ObjectReference source, String eventName)
        Debug("OnAnimationEvent (Attack) Evt=" + eventName)
        If eventName == "staggerStart"
            GoToState("PostEscape")
        ElseIf eventName == "SnareRopeUndoSelfLoop"
            DamageAV("Stamina", 1, 0)
            DamageAV("Health", 0.1, 0.5)
        EndIf
    EndFunction
    
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
        ; TODO TrapDefeatQuest.NotifyPlayer = True
        trapDefeatQuest.Start()
    EndEvent

    Event TrapEvent(string eventName, string strArg, float numArg, form trap)
        Debug("Event (Approach): " + eventName)
        If eventName == "Mimic_VoreEnd"
            GoToState("PostEscape")
        ElseIf eventName == "Mimic_VoreProgress"
            DamageAV("Stamina", 1, 0)
            DamageAV("Magicka", 0.5, 0)
            DamageAV("Health", 0.2, 0.5)
        EndIf
    EndEvent

    Function OnAnimationEvent(ObjectReference source, String eventName)
        Debug("OnAnimationEvent Approach Evt=" + eventName + " Src=" + source)
        If eventName == "staggerStart"
            GoToState("PostEscape")
        ElseIf eventName == "SnareRopeUndoSelfLoop"
            DamageAV("Stamina", 1, 0)
            DamageAV("Health", 0.1, 0.5)
        EndIf
    EndFunction

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
        DamageAV("Stamina", 1, 0)
        If GR_TrapType.GetValueInt() == 1 ; Snare Rope
            RegisterForSingleUpdate(1.0)
        Else
            ; Mimic/VoreWorm has a longer get-up animation
            RegisterForSingleUpdate(8.0)
        EndIf
    EndEvent

    Event OnUpdate()
        Debug("OnUpdate Back to default" )
        GoToState("Default")
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

Function FailAndReset()
    ; Called by TrapDefat on missing enemies
    Debug("FailApproach")
    GoToState("Default")
EndFunction

; ==================================================
; UTILITY
; ==================================================

Bool Function ApproachIfDetected()
    If Utility.RandomFloat() < 1.0
        StartApproach()
        return true
    Else
        Debug("Roll Failed")
        return false
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
    ; e1.MoveTo(target, 75.0, 50)
    ; e2.MoveTo(target, 75.0, -50)    
    ; e3.MoveTo(target, 100.0, 50)
    ; e4.MoveTo(target, 250.0, 50)
    ; e5.MoveTo(target, 183.0, 102)

    Utility.Wait(3.0)
    BlackFade(false)
EndFunction

; ==================================================
; NOOPs
; ==================================================

Event OnUpdate()
    Debug("OnUpdate noop")
EndEvent

Function RollIfDetected()
    Debug("RollIfDetected noop")
EndFunction

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

Function OnAnimationEvent(ObjectReference source, String eventName)
    Debug("OnAnimationEvent noop evt=" + eventName + " src=" + source)
EndFunction

Function PlayerEnterCombat()
    Debug("PlayerEnterCombat noop")
EndFunction

; ==================================================
; DEBUG
; ==================================================

Function Debug(string msg)
    Debug.Trace("[omnom] TRAP.OBSV " + msg)
EndFunction

Function BlackFade(bool fadeOut = true)
    if FadeOut
        Game.FadeOutGame(false, true, 60.0, 0.0)
    else
        Game.FadeOutGame(false, true, 0.2, 3.0)
    endIf
EndFunction
