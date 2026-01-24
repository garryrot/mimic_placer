;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 11
Scriptname QF_GR_TrapAttack_09033DAF Extends Quest Hidden

;BEGIN ALIAS PROPERTY Enemy02
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy02 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Enemy04
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy04 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Enemy01
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy01 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Follower
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY PlayerAlias
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_PlayerAlias Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Teammate01
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Teammate01 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Enemy03
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy03 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Enemy05
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy05 Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_10
Function Fragment_10()
;BEGIN AUTOCAST TYPE GR_TrapAttack
Quest __temp = self as Quest
GR_TrapAttack kmyQuest = __temp as GR_TrapAttack
;END AUTOCAST
;BEGIN CODE
; Follower is defeated
Debug.Trace("[OMNOM] TRAP.ATTC Stage 30")
kmyQuest.FollowerDefeated()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN AUTOCAST TYPE GR_TrapAttack
Quest __temp = self as Quest
GR_TrapAttack kmyQuest = __temp as GR_TrapAttack
;END AUTOCAST
;BEGIN CODE
;
Debug.Trace("[OMNOM] TRAP.ATTC Stage 0")
kmyQuest.TestProperties();
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN AUTOCAST TYPE GR_TrapAttack
Quest __temp = self as Quest
GR_TrapAttack kmyQuest = __temp as GR_TrapAttack
;END AUTOCAST
;BEGIN CODE
;
Debug.Trace("[OMNOM] TRAP.ATTC Stage 10")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_7
Function Fragment_7()
;BEGIN AUTOCAST TYPE GR_TrapAttack
Quest __temp = self as Quest
GR_TrapAttack kmyQuest = __temp as GR_TrapAttack
;END AUTOCAST
;BEGIN CODE
; Follower is attacked
Debug.Trace("[OMNOM] TRAP.ATTC Stage 20")
kmyQuest.FollowerAttacked()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
