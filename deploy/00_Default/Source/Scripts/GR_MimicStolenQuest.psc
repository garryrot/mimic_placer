Scriptname GR_MimicStolenQuest extends Quest

ReferenceAlias Property LootContainer Auto

Event OnInit()
	Debug("OnInit")
EndEvent

Function Debug(String msg)
	Debug.Trace("[omnom] STOL: " + msg)
EndFunction
