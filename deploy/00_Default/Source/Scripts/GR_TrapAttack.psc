Scriptname GR_TrapAttack extends Quest

Quest Property DialogueFollower Auto

Actor Property PlayerRef Auto

Scene Property TrapAttackTeammateScene Auto
Scene Property TrapAttackTeammateDefeatScene Auto

ReferenceAlias Property FollowerAlias Auto
ReferenceAlias Property Teammate01 Auto
ReferenceAlias Property Enemy01 Auto
ReferenceAlias Property Enemy02 Auto
ReferenceAlias Property Enemy03 Auto
ReferenceAlias Property Enemy04 Auto
ReferenceAlias Property Enemy05 Auto
ReferenceAlias[] Property EnemyAliases Auto

GR_TrapDefeat Property TrapDefeatQuest Auto
GR_TrapDefeatObserver Property TrapDefeatObserver Auto

Idle Property SurrenderIdle Auto

Bool Property NotifyPlayer Auto

Float AttackTimeout = 120.0

Event OnInit()
    Debug("OnInit")
EndEvent

; Stage 0
; noop

; Stage 0 (called actively)
Function StartTrapAttack()
    Actor follower = GetCurrentFollower()
    Debug("StartTrapAttack Teammate01=" + Teammate01 + " Follower=" + FollowerAlias)
    Debug("Enemies - e1:" + Enemy01.GetActorRef() + " e2:" + Enemy02.GetActorRef() + " e3:" + Enemy03.GetActorRef() + \
            " e4:" + Enemy04.GetActorRef() + " e5:" + Enemy05.GetActorRef())

    If !HasValidEnemies()
        Debug("Aborting attack, no viable follower or enemies")
        TrapDefeatObserver.FailAndResetToTrapped()
        return
    EndIf

    If follower
        RegisterForSingleUpdate(0.5)
        If (TrapDefeatObserver.AlertPlayer)
            TrapDefeatObserver.AlertPlayer = False
            Debug.Notification("The noise has alerted nearby enemies...")
        Else
            Debug("Skipping alert: " + TrapDefeatObserver.AlertPlayer)
        EndIf
    EndIf
EndFunction

Bool Function HasValidEnemies()
    Int i = 0
    While i < EnemyAliases.Length
        Actor akActor = EnemyAliases[i].GetRef() as Actor
        If IsValidEnemy(akActor)
            return True
        EndIf
        i += 1
    EndWhile
    return False
EndFunction

; Stage 10 (Follower is attacked)

; Stage 10 -> 20 Timeout (called actively)
Function TrapAttackTimeout()
    Debug("TrapAttackTimeout")
    Actor e1 = Enemy01.GetActorRef()
    Actor e2 = Enemy02.GetActorRef()
    Actor e3 = Enemy03.GetActorRef()
    Actor e4 = Enemy04.GetActorRef()
    Actor e5 = Enemy05.GetActorRef()
    TrapDefeatObserver.FadeAndPlaceEnemies(Teammate01.GetActorRef(), e1, e2, e3, e4, e5)
    ; Happens automatically
    ; SetStage(20) 
EndFunction

; Stage 20 - Follower is attacked
Function FollowerAttacked()
    Debug("FollowerAttacked - Cancelling Timeout")
    UnregisterForUpdate()
EndFunction

; Stage 30 - Follower Bleeds out
Function FollowerDefeated()
    Debug("FollowerDefeated")
    RegisterForSingleUpdate(1.0)
EndFunction

Event OnUpdate()
    Debug("OnUpdate")
    If GetStage() == 0
        Debug("Attacking Teammate")
        SetStage(10)
        TrapAttackTeammateScene.ForceStart()
        RegisterForSingleUpdate(AttackTimeout)
    ElseIf GetStage() == 10
        Debug("Attacking Timeout")
        TrapAttackTimeout()
    ElseIf GetStage() == 30
        Debug.Notification("Your follower surrenders...")
        ; Teammate01.GetActorRef().SetUnconscious(true)
        ; Teammate01.GetActorRef().SetRestrained(true)    
        ; Teammate01.GetActorRef().PlayIdle(SurrenderIdle)    
        TrapDefeatObserver.AttackSuccess()
        Stop()
    EndIf
EndEvent

; ==================================================
; UTILITY
; ==================================================

Actor Function GetCurrentFollower()
    if FollowerAlias && FollowerAlias.GetActorRef()
        return FollowerAlias.GetActorRef()
    endif
    If Teammate01 && Teammate01.GetActorRef()
        return Teammate01.GetActorRef()
    EndIf
    return None
EndFunction

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

; ==================================================
; DEBUG
; ==================================================

Function Debug(string msg)
    Debug.Trace("[omnom] TRAP.ATTC " + msg)
EndFunction
