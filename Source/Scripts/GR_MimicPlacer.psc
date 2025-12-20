Scriptname GR_MimicPlacer extends Quest Hidden 

; AA01 -> Debug Spell

Event OnInit()
	Maintenance()
EndEvent

ObjectReference Function GetNextViableContainers()
  	Form chestForm = Game.GetForm(0x2064F)
	ObjectReference foundRef = Game.FindRandomReferenceOfTypeFromRef(chestForm, Game.GetPlayer(), 4000.0)
 	return foundRef
EndFunction

Function Maintenance()
    Debug.MessageBox("hi from on load")
EndFunction
