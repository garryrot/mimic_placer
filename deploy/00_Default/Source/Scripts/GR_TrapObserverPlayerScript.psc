Scriptname GR_TrapObserverPlayerScript extends ReferenceAlias

Event OnPlayerLoadGame()
    Debug("OnPlayerLoadGame")
EndEvent

Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
    Debug("OnCombatStateChanged " + aeCombatState)
    if (aeCombatState == 0)
        Debug("Left combat")
    elseif (aeCombatState == 1)
        Debug("Player in combat")
    elseif (aeCombatState == 2)
        Debug("Player is serached")
    endIf
endEvent

Function Debug(string msg)
    Debug.Trace("[omnom] DEFT.OBSV " + msg)
EndFunction

