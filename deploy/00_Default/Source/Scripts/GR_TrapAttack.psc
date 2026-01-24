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

GR_TrapDefeat Property TrapDefeatQuest Auto
GR_TrapDefeatObserver Property TrapDefeatObserver Auto

; ==================================================
; INIT
; ==================================================

Event OnInit()
    Debug("OnInit")
EndEvent

; ==================================================
; MAIN
; ==================================================

Function StartTrapAttack()
    Actor follower = GetCurrentFollower()
    Debug("StartTrapAttack Teammate01=" + Teammate01 + " Follower=" + FollowerAlias)
    Debug("Enemies:" + Enemy01.GetActorRef() + " " + Enemy02.GetActorRef() + " " + Enemy03.GetActorRef() + " " + Enemy04.GetActorRef() + " " )
    If follower
        SetStage(10)
        RegisterForSingleUpdate(0.5)
    EndIf
EndFunction

; Stage 10 - Follower is approached for attack
; ^^^^^^^^
; Timeout can happen here

; Stage 20 - Follower is attacked
Function FollowerAttacked()
    Debug("FollowerAttacked")


    ; Teammate01.GetActorRef().StartCombat(Enemy01.GetActorRef())
    ; Enemy01.GetActorRef().StartCombat(Teammate01.GetActorRef())
    ; Enemy02.GetActorRef().StartCombat(Teammate01.GetActorRef())
    ; Enemy03.GetActorRef().StartCombat(Teammate01.GetActorRef())
    ; Enemy04.GetActorRef().StartCombat(Teammate01.GetActorRef())
    ; Enemy05.GetActorRef().StartCombat(Teammate01.GetActorRef())
EndFunction

; Stage 30
Function FollowerDefeated()
    Debug("FollowerDefeated")
    TrapAttackTeammateDefeatScene.ForceStart()
    RegisterForSingleUpdate(6.0)
EndFunction

Event OnUpdate()
    Debug("OnUpdate")
    If GetStage() == 10
        Debug("Attacking Teammate")
        TrapAttackTeammateScene.ForceStart()

        ; This doesn't work?
        Teammate01.GetActorRef().SetAttackActorOnSight()
        Utility.Wait(0.2)
    EndIf

    If GetStage() == 30
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

Function TestProperties()
    ; Debug("FollowerAlias " + FollowerAlias)
    ; If (FollowerAlias)
    ;     Debug("GetRef " + FollowerAlias.GetRef())
    ; EndIf
    ; Debug("Teammate01 " + Teammate01)
    ; If (Teammate01)
    ;     Debug("GetRef " + Teammate01.GetRef())
    ; EndIf
EndFunction

; ==================================================
; DEBUG
; ==================================================

Function Debug(string msg)
    Debug.Trace("[omnom] DEFT.ATTC " + msg)
EndFunction
