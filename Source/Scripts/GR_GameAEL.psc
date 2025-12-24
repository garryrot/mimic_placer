ScriptName GR_GameAEL extends ObjectReference  

Quest Property TNTRController Auto
TNTRMCM Property MCM Auto

{Type 1: Alphabet, Type 0: Normal struggle bar}
BakaTrapQTEWidgetEx Property StruggleBar Auto
ObjectReference Property VoreTrapref Auto Hidden
int RunningScenario
Sound Property BakaTrapDeathWormVoreStruggle auto
Int Property TrapType auto

{0 = Null, 1 = DeathWorm, 2 = Mimic, 3 = SnareRope}
Float FillDifficulty = 0.0
Float FillThreshold = 0.0
int Time = 0
Float DownedTime ; How much time the player will be stayed down.

; Custom code
; ########################################################

Bool InGame = False
Bool StartingGame = False
ObjectReference lastTarget

Function StartGame(ObjectReference target)
	Debug.Trace("[GRMP] GR_GameAEL.StartGame()")
    lastTarget = target
	StartingGame = true
	RegisterForSingleUpdate(1.0)
EndFunction

Event OnGameEnd(string eventName, string strArg, float numArg, form sender)
    UnregisterForModEvent("AEL_GameEnd")
	InGame = False
	StartingGame = False
    SPE_Interface.CloseCustomMenu()
    If numArg > 0
		SendModEvent("GR_GameSuccess", "", 0.0)
    Else
		SendModEvent("GR_GameFail", "", 0.0)
    EndIf
EndEvent

Event OnUpdate()
	If InGame
		SendModEvent("GR_GameTick", "", 0.0)
		RegisterForSingleUpdate(1.0)
	ElseIf StartingGame
		StartingGame = False
		InGame = True
		AELStruggle.MakeGame(100.0)
		RegisterForModEvent("AEL_GameEnd", "OnGameEnd")
		RegisterForSingleUpdate(1.0)
	EndIf
EndEvent
