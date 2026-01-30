Scriptname GR_TrapDefeatObserver extends Quest

Actor Property PlayerRef Auto

GR_TrapDefeat Property TrapDefeatQuest Auto
GR_TrapAttack Property TrapAttackQuest Auto

ImageSpaceModifier Property FadeToBlack Auto

String notifyMessage = "The noise has alerted nearby enemies..."
Int trapType = 0 ; 0 -> Mimic, 1 -> SnareLoop, 2 -> DeathWorm

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
    ; RegisterForModEvent("SnareLoop_Progress", "TrapEvent")

    RegisterForAnimationEvent(PlayerRef, "SnareRopeUndoSelfFailEnd") ; Start Alert
    RegisterForAnimationEvent(PlayerRef, "SnareRopeUndoSelfLoop") ; Dmg stam/health
    UnregisterForAnimationEvent(PlayerRef, "staggerStart") ; Release
EndFunction

Function TransitionToApproach(bool showNotification = false)
    If (showNotification)
        Debug.Notification(notifyMessage)
    EndIf
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

; ==================================================
; STATES
; ==================================================

State Default
    Event OnBeginState()
        Debug("State: Default")
        ResetEvents()
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
            trapType = 0 ; Mimic
            GoToState("Trapped")
        EndIf
    EndEvent

    Function OnAnimationEvent(ObjectReference source, String eventName)
        ; There's no way to detect the "trapped" state for death worm
        ; or snare rope right now, so just roll and transition right 
        ; to the approach or attack state
        If eventName == "DeathWormVoreSuccessLoop"
            Debug("Worm Vore Struggle Failed")
            trapType = 2 ; Deathworm
            TransitionToApproach(true)
            return

        ElseIf eventName == "SnareRopeUndoSelfFailEnd"
            Debug("Snare Rope Struggle - TrapDefeatObserver!")
            RegisterForAnimationEvent(PlayerRef, "staggerStart")

            trapType = 1 ; SnareRope
            TransitionToApproach(true)
        ElseIf eventName == "SnareRopeUndoSelfLoop"
            DamageAV("Stamina", 1.0, 0)
            DamageAV("Health", 0.2, 0.5)
        Else
            Debug("UNKNOWN ANIM EVENT " + eventName + " src " + source)
        EndIf
    EndFunction
EndState

State Trapped
    Event OnBeginState()
        Debug("State: Trapped")
        If PlayerRef.GetCombatState() == 1
            Debug("Player already in combat")
            TransitionToApproach(false)
        Else
            RollForNotify()
        EndIf
    EndEvent

    Event TrapEvent(string eventName, string strArg, float numArg, Form trap)
        Debug("Event (Trapped): " + eventName)
        If eventName == "Mimic_VoreProgress"
            RollForNotify()
        ElseIf eventName == "Mimic_VoreEnd"
            Debug("Escaped before player was noticed")
            GoToState("Default")
        EndIf
    EndEvent
    
    Function RollForNotify()
        If Utility.RandomFloat() < 1.0
            TransitionToApproach(true)
        Else
            Debug("Roll Failed")
        EndIf
    EndFunction

    Function CombatStart()
        Debug("Player entered combat, goto approach")
        TransitionToApproach(false)
    EndFunction
EndState

State Attack
    Event OnBeginState()
        Debug("State: Attack")
        RegisterForSingleUpdate(0.5)
        PlayerRef.SetGhost(true)
    EndEvent

    Event OnUpdate()
        Debug("OnUpdate Attack")
        TrapAttackQuest.StartTrapAttack()
    EndEvent

    Function AttackSuccess()
        Debug("State: Attack Success")
        ; Follower defeated 
        GoToState("Approach")
        PlayerRef.SetGhost(false)
    EndFunction

    Event TrapEvent(string eventName, string strArg, float numArg, form mimic)
        Debug("Event (Attack): " + eventName)
        If eventName == "Mimic_VoreEnd"
            ; Escaped before attack was succesfull
            GoToState("Default")
            PlayerRef.SetGhost(false)
        EndIf
    EndEvent

    Event OnEndState()
        Debug("State: EndState Attack")
        UnregisterForUpdate()
    EndEvent
EndState

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
        If eventName == "Mimic_VoreEnd"
            GoToState("PostApproach")
        ElseIf eventName == "Mimic_VoreProgress"
        EndIf
    EndEvent

    Function OnAnimationEvent(ObjectReference source, String eventName)
        Debug("OnAnimationEvent Approach Evt=" + eventName + " Src=" + source)
        If eventName == "staggerStart"
            Debug("Ending...")
            UnregisterForAnimationEvent(PlayerRef, "staggerStart")
            GoToState("PostApproach")
        ElseIf eventName == "SnareRopeUndoSelfLoop"
            DamageAV("Stamina", 1, 0)
            DamageAV("Health", 0.2, 0.5)
        EndIf
    EndFunction

    Event OnEndState()
        Debug("State: EndState Approach")
    EndEvent
EndState

State PostApproach
    Event OnBeginState()
        Debug("State: PostApproach")
        trapDefeatQuest.SetStage(20)
        If trapType == 1
            RegisterForSingleUpdate(1.0)
        Else
            ; Long Get-Up Animation for Vore
            RegisterForSingleUpdate(10.0)
        EndIf
    EndEvent

    Event OnUpdate()
        Debug("OnUpdate Back to default" )
        GoToState("Default")
    EndEvent
EndState

; ==================================================
; UTILITY
; ==================================================

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

Function RollForNotify()
    Debug("RollForNotify noop")
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
