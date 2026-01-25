Scriptname GR_TrapAttackFollowerBleedout extends ReferenceAlias

Event OnEnterBleedout()
    ; Not called for some reason
    Actor follower = GetActorRef()
    if follower
        Debug("Follower entered bleedout: " + follower)
        (GetOwningQuest() as GR_TrapAttack).SetStage(30)
    endif
EndEvent

Event OnHit(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, \
    bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    Float followerHealth = GetActorRef().GetAVPercentage("Health")
    If followerHealth < 0.2
        GR_TrapAttack trapAttack = GetOwningQuest() as GR_TrapAttack
        If trapAttack.GetStage() == 10 || trapAttack.GetStage() == 20 
            Debug("Follower entered bleedout by health %" + followerHealth)
            trapAttack.SetStage(30)
        EndIf 
    EndIf
EndEvent

; ==================================================
; DEBUG
; ==================================================

Function Debug(string msg)
    Debug.Trace("[omnom] TRAP.ATTC (FollowerAlias) " + msg)
EndFunction
