Scriptname GR_TrapDefeatObserver extends Quest

Actor Property PlayerRef Auto

GR_TrapDefeat Property TrapDefeatQuest Auto
GR_TrapAttack Property TrapAttackQuest Auto

Bool WaitingForTimeout = false
Float ApproachTimeout = 5.0
String notifyMessage = "The noise has alerted nearby enemies..."

; ==================================================
; INIT
; ==================================================

Event OnInit()
    Debug("OnInit")
    GoToState("Default")
EndEvent

; ==================================================
; EVENT REGISTRATION
; ==================================================

Function ResetEvents()
    UnregisterForAllModEvents()
    RegisterForModEvent("Mimic_VoreStart", "TrapEvent")
    RegisterForModEvent("Mimic_VoreProgress", "TrapEvent")
    RegisterForModEvent("Mimic_VoreEnd", "TrapEvent")
    RegisterForAnimationEvent(PlayerRef, "DeathWormVoreSuccessLoop") ; Doesn't work
    RegisterForAnimationEvent(PlayerRef, "SnareRopeUndoSelfFailEvent") ; Doesn't work
EndFunction

Function TransitionToApproach()
    Debug.Notification(notifyMessage)
    TrapAttackQuest.Start()
    Utility.Wait(0.5)

    TrapAttackQuest.TestProperties()
    If TrapAttackQuest.GetCurrentFollower()
        Debug("Has follower, starting attack...")
        GoToState("Attack")
    Else
        TrapAttackQuest.Stop()
        Debug("Doesn't have follower, starting deafeat...")
        GoToState("Approach")
    EndIf
EndFunction

Function FadeAndPlaceEnemies(Actor e1, Actor e2, Actor e3, Actor e4, Actor e5)
    Debug("FadeAndPlaceEnemies")
    Game.FadeOutGame(true, true, 0.0, 3.0)
    Utility.Wait(3.0)
    e1.MoveTo(PlayerRef, 75.0, 50)
    e2.MoveTo(PlayerRef, 75.0, -50)    
    e3.MoveTo(PlayerRef, 100.0, 50)
    ; e4.MoveTo(PlayerRef, 250.0, 50)
    ; e5.MoveTo(PlayerRef, 183.0, 102)
    Utility.Wait(3.0)
    Game.FadeOutGame(false, true, 0.0, 3.0)
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
            GoToState("Trapped")
        EndIf
    EndEvent

    Function OnAnimationEvent(ObjectReference source, String eventName)
        ; There's no way to detect the "trapped" state for death worm
        ; or snare rope right now, so just roll and transition right 
        ; to the approach or attack state
        If eventName == "DeathWormVoreSuccessLoop"
            Debug("Worm Vore Struggle Failed")
            TransitionToApproach()
            return
        ElseIf eventName == "SnareRopeUndoSelfFailEvent"
            Debug("Snare Rope Struggle Failed")
            TransitionToApproach()
        EndIf
    EndFunction
EndState

State Trapped
    Event OnBeginState()
        Debug("State: Trapped")
        If PlayerRef.GetCombatState() == 1
            Debug("Player already in combat")
            TransitionToApproach()
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
            TransitionToApproach()
        Else
            Debug("Roll Failed")
        EndIf
    EndFunction

    Function PlayerEnterCombat()
        Debug("PlayerEnterCombat")
        TransitionToApproach()
    EndFunction

    Event OnEndState()
        Debug("Leaving trapped")
    EndEvent
EndState

State Attack
    Event OnBeginState()
        Debug("State: Attack")
        WaitingForTimeout = false
        RegisterForSingleUpdate(0.5)
        PlayerRef.SetGhost(true)
    EndEvent

    Event OnUpdate()
        Debug("OnUpdate Attack")
        if !WaitingForTimeout
            TrapAttackQuest.StartTrapAttack()
            WaitingForTimeout = true
            RegisterForSingleUpdate(ApproachTimeout)
        Else
            Debug("Attack Timeout")
            
            If !TrapAttackQuest.IsRunning()
                Debug("ForceStarting TrapAttackQuest")
                TrapAttackQuest.Start()
                Utility.Wait(0.25)
            EndIf
            Actor e1 = TrapAttackQuest.Enemy01.GetActorRef()
            Actor e2 = TrapAttackQuest.Enemy02.GetActorRef()
            Actor e3 = TrapAttackQuest.Enemy03.GetActorRef()
            Actor e4 = TrapAttackQuest.Enemy04.GetActorRef()
            Actor e5 = TrapAttackQuest.Enemy05.GetActorRef()
            FadeAndPlaceEnemies(e1, e2, e3, e4, e5)
            ; Scene should finish on its own
        EndIf
    EndEvent

    Function AttackSuccess()
        Debug("State: Attack Success")
        Debug.Notification("")
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
        PlayerRef.SetGhost(false)
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
        RegisterForSingleUpdate(ApproachTimeout)
        Debug("Starting Quest " + trapDefeatQuest)
        trapDefeatQuest.Start()
    EndEvent

    Event TrapEvent(string eventName, string strArg, float numArg, form mimic)
        Debug("Event (Approach): " + eventName)
        If eventName == "Mimic_VoreEnd"
            GoToState("PostApproach")
            trapDefeatQuest.SetStage(20)
        EndIf
    EndEvent

    Event OnUpdate()
        Debug("Approach Timeout")
        If !TrapDefeatQuest.IsRunning()
            Debug("ForceStarting TrapDefeatQuest")
            TrapDefeatQuest.Start()
            Utility.Wait(0.25)
        EndIf
        Actor e1 = TrapDefeatQuest.Enemy01.GetActorRef()
        Actor e2 = TrapDefeatQuest.Enemy02.GetActorRef()
        Actor e3 = TrapDefeatQuest.Enemy03.GetActorRef()
        Actor e4 = TrapDefeatQuest.Enemy04.GetActorRef()
        Actor e5 = TrapDefeatQuest.Enemy05.GetActorRef()
        FadeAndPlaceEnemies(e1, e2, e3, e4, e5)
    EndEvent
EndState

State PostApproach
    Event OnBeginState()
        Debug("State: PostApproach")
        RegisterForSingleUpdate(10.0)
    EndEvent

    Event OnUpdate()
        Debug("OnUpdate Back to default" )
        GoToState("Default")
    EndEvent
EndState

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
    Debug.Trace("[omnom] DEFT.TRAP " + msg)
EndFunction
