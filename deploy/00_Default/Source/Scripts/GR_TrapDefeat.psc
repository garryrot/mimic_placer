Scriptname GR_TrapDefeat extends Quest

; ==================================================
; PROPERTIES
; ==================================================

Actor Property PlayerRef Auto
Scene Property TrapApproachScene Auto
Scene Property TrapObserveScene Auto

ReferenceAlias Property PlayerAlias Auto

ReferenceAlias Property Enemy01 Auto
ReferenceAlias Property Enemy02 Auto
ReferenceAlias Property Enemy03 Auto
ReferenceAlias Property Enemy04 Auto
ReferenceAlias Property Enemy05 Auto
ReferenceAlias Property NearbyAlly Auto

ReferenceAlias[] Property EnemyAliases Auto

GlobalVariable Property GR_TrapDefeatTimeout Auto

GR_TrapDefeatObserver Property TrapDefeatObserver Auto

Int TrapTypeMimic = 1

; ==================================================
; QUEST START
; ==================================================

Event OnInit()
    Debug("OnInit")
EndEvent

; ==================================================
; MAIN LOGIC
; ==================================================

; Stage 0
Function StartPreApproach()
    ; TODO this is called again on approach, for some reason
    Debug("Stage 0 - PreApproach Enemies: " + Enemy01.GetActorRef() + " " + Enemy02.GetActorRef() + " " + Enemy03.GetActorRef() + " " + Enemy04.GetActorRef() + " ")

    Int i = 0
    While i < EnemyAliases.Length
        Actor akActor = EnemyAliases[i].GetRef() as Actor
        Debug("Handling enemy i=" + i + " actor: " + akActor)
        i += 1
    EndWhile
    Int validEnemies = 0
    i = 0
    While i < EnemyAliases.Length
        Actor akActor = EnemyAliases[i].GetRef() as Actor
        If IsValidEnemy(akActor)
            StopActorCombat(akActor)
            validEnemies += 1
        EndIf
        i += 1
    EndWhile
    
    If validEnemies > 0
        Debug("Starting scene " + TrapApproachScene)
        RegisterForSingleUpdate(0.5)
    Else
        Debug("Aborting approach, no viable enemies")
        Stop()
    EndIf
EndFunction

; Stage 10
Function StartApproach()
    Debug("Stage 10 - Approach")
    TrapApproachScene.Start()
    ; RegisterForSingleUpdate(30.0)
EndFunction

; Stage 15
Function StartObserve()
    Debug("Stage 15 - Observe")
    TrapObserveScene.Start()
EndFunction

; Stage 20 - Called by external trigger
Function PreEscaped()
    Debug("Stage 20 - PreEscaped")
    ; Wait for animation to finish
    Float maxStamina = Game.GetPlayer().GetActorValueMax("Stamina")
    Float maxHealth = Game.GetPlayer().GetActorValueMax("Health")
    Float maxMagicka = Game.GetPlayer().GetActorValueMax("Health")
    Game.GetPlayer().DamageAV("Magicka", maxMagicka* 0.5)
    Game.GetPlayer().DamageAV("Stamina", maxStamina * 1.0)
    Game.GetPlayer().DamageAV("Health", maxHealth * 0.3)
    RegisterForSingleUpdate(4.0)
EndFunction

; Stage 30
Function DamagePlayer()
    Debug("Stage 30 - Damage Stamina")
    Float maxStamina = Game.GetPlayer().GetActorValueMax("Stamina")
    Game.GetPlayer().DamageAV("Stamina", maxStamina * 0.3)
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
        ; Debug("Approach Timeout")
        ; Observe?
    ElseIf GetStage() == 20
        SetStage(30)
    ElseIf GetStage() == 30
        SetStage(100)
    Else
        Debug("Unknown state, resetting...")
        Stop()
    EndIf
EndEvent

; ==================================================
; VALIDATION
; ==================================================

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
; ACTOR HANDLING
; ==================================================

Function StopActorCombat(Actor akActor)
    Debug("Stopping combat: " + akActor)
    ; Teleport safely

    ; Hard stop combat
    akActor.StopCombat()
    akActor.StopCombatAlarm()

    ; Small delay to let AI settle
    Utility.Wait(0.2)
EndFunction

; ==================================================
; DEBUG
; ==================================================

Function Debug(string msg)
    Debug.Trace("[omnom] TRAP.DEFT " + msg)
EndFunction