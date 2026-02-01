Scriptname GR_TrapDefeat extends Quest

GR_TrapDefeatObserver Property TrapDefeatObserver Auto

ReferenceAlias Property PlayerAlias Auto
Actor Property PlayerRef Auto

ReferenceAlias Property Enemy01 Auto
ReferenceAlias Property Enemy02 Auto
ReferenceAlias Property Enemy03 Auto
ReferenceAlias Property Enemy04 Auto
ReferenceAlias Property Enemy05 Auto
ReferenceAlias Property NearbyAlly Auto

ReferenceAlias[] Property EnemyAliases Auto

GlobalVariable Property GR_TrapType Auto

Scene Property TrapObserveScene Auto

Bool Property NotifyPlayer Auto

Float ApproachTimeout = 60.0

Event OnInit()
    Debug("OnInit")
EndEvent

; Stage 0
Function StartPreApproach()
    Debug("Stage 0 - PreApproach Enemies: " + Enemy01.GetActorRef() + " " + Enemy02.GetActorRef() + " " + Enemy03.GetActorRef() + " " + Enemy04.GetActorRef() + " ")

    PrintEnemies()

    If ! PrepareEnemies()
        Debug("Aborting approach, no viable enemies")
        TrapDefeatObserver.FailAndReset()
        Stop()
        return
    EndIf

    If TrapDefeatObserver.AlertPlayer
        TrapDefeatObserver.AlertPlayer = False
        Debug.Notification("The noise has alerted nearby enemies...")
    Else 
        Debug("Skipping alert: " + TrapDefeatObserver.AlertPlayer)
    EndIf

    RegisterForSingleUpdate(0.5)
EndFunction

Function PrintEnemies()
    Int i = 0
    While i < EnemyAliases.Length
        Actor akActor = EnemyAliases[i].GetRef() as Actor
        Debug("Handling enemy i=" + i + " actor: " + akActor)
        i += 1
    EndWhile
EndFunction

Bool Function PrepareEnemies()
    Bool valid = False
    Int i = 0
    While i < EnemyAliases.Length
        Actor akActor = EnemyAliases[i].GetRef() as Actor
        If IsValidEnemy(akActor)
            valid = True
            StopActorCombat(akActor)
        EndIf
        i += 1
    EndWhile
    return valid
EndFunction

; Stage 10
Function StartApproach()
    Debug("Stage 10 - Approach")
    TrapObserveScene.ForceStart()
    RegisterForSingleUpdate(ApproachTimeout)
EndFunction

; Stage 10 -> 15 Timeout
Function ApproachTimeout()
    Debug("ApproachTimeout")
    Actor e1 = Enemy01.GetActorRef()
    Actor e2 = Enemy02.GetActorRef()
    Actor e3 = Enemy03.GetActorRef()
    Actor e4 = Enemy04.GetActorRef()
    Actor e5 = Enemy05.GetActorRef()
    TrapDefeatObserver.FadeAndPlaceEnemies(PlayerRef, e1, e2, e3, e4, e5)
    SetStage(15)
EndFunction

; Stage 15 - Player Discovered and Observed
Function StartObserve()
    UnregisterForUpdate()
    Debug("Stage 15 - Observe")
    Utility.Wait(0.3)
    Utility.Wait(0.3)
    Debug("TrapObserveScene Started: " + TrapObserveScene)
EndFunction

; Stage 20 - Called by external trigger
Function PreEscaped()
    Debug("Stage 20 - PreEscaped")
    ; Wait for animation to finish
    RegisterForSingleUpdate(4.0)
EndFunction

; Stage 30
Function DamagePlayer()
    Debug("Stage 30 - Damage Stamina")
    RegisterForSingleUpdate(1.0)
EndFunction

; Stage 100
Function RestartCombat()
    Debug("Stage 100 - Restarting Combat")
    Stop()
    Reset()
EndFunction

Event OnUpdate()
    Debug("OnUpdate " + GetStage())
    If GetStage() == 0
        SetStage(10)
    ElseIf GetStage() == 10
        ApproachTimeout()
    ElseIf GetStage() == 20
        SetStage(30)
    ElseIf GetStage() == 30
        SetStage(100)
    Else
        Debug("Unknown state, resetting...")
        Stop()
    EndIf
EndEvent

Bool Function IsValidEnemy(Actor akActor)
    If !akActor
        Debug("Object not found")
        Return False
    EndIf

    If akActor.IsDead() || akActor.IsDisabled()
        Debug("Not valid enemy or dead")
        Return False
    EndIf

    Return True
EndFunction

Function StopActorCombat(Actor akActor)
    Debug("Stopping combat: " + akActor)
    akActor.StopCombat()
    akActor.StopCombatAlarm()
    Utility.Wait(0.2)
EndFunction

Function Debug(string msg)
    Debug.Trace("[omnom] TRAP.DEFT " + msg)
EndFunction
