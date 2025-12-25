ScriptName GR_GameAEL extends ObjectReference  

Bool InGame = False
Bool StartingGame = False
Int lastStage = 0
ObjectReference lastTarget

Function StartGame(ObjectReference target, int stage)
	Debug.Trace("[GRMP] GR_GameAEL.StartGame()")
    lastTarget = target
	StartingGame = true
	lastStage = stage
	RegisterForSingleUpdate(0.75)
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
		int difficulty = ((90.0 - (lastStage as float * 5.0)) as int)
		AELStruggle.MakeGame(difficulty)
		Debug.Trace("[GRMP] Game Difficulaty " + lastStage + " " + difficulty)
		RegisterForModEvent("AEL_GameEnd", "OnGameEnd")
		RegisterForSingleUpdate(3.0)
	EndIf
EndEvent