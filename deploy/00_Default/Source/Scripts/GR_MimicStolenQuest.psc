Scriptname GR_MimicStolenQuest extends Quest

ReferenceAlias Property LootContainer Auto

Bool Property StolenChest Auto
Bool Property Stolen Auto

Event OnInit()
	Debug("OnInit")
EndEvent

Function Debug(String msg)
	Debug.Trace("[omnom] STOL: " + msg)
EndFunction
