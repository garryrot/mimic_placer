ScriptName GR_GameQTEText extends ObjectReference  

Bool InGame = False
Bool StartingGame = False
Int lastStage = 0
ObjectReference lastTarget
Quest Property TNTRController Auto; as TNTRControllerScript

Function StartGame(ObjectReference target, int stage)
	Debug.Trace("[GRMP] GR_GameQTEText.StartGame()")
	If TNTRController as TNTRControllerScript
		RegisterForSingleUpdate(0.75)
		InGame = True
		Bool result = (TNTRController as TNTRControllerScript).StartQTEText(10.0 - stage, 20.0 + stage)
		InGame = False
		If result
			SendModEvent("GR_GameSuccess", "", 0.0)	
		Else
			SendModEvent("GR_GameFail", "", 0.0)
		EndIf
	Else
	EndIf
EndFunction

Event OnUpdate()
	If InGame
		SendModEvent("GR_GameTick", "", 0.0)
		RegisterForSingleUpdate(1.0)
	EndIf
EndEvent
