;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 26
Scriptname QF_GR_TrapDefeat_01000D62 Extends Quest Hidden

;BEGIN ALIAS PROPERTY Enemy01
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy01 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Enemy05
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy05 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Enemy04
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy04 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Enemy02
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy02 Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY PlayerAlias
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_PlayerAlias Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Enemy03
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Enemy03 Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN AUTOCAST TYPE GR_TrapDefeat
Quest __temp = self as Quest
GR_TrapDefeat kmyQuest = __temp as GR_TrapDefeat
;END AUTOCAST
;BEGIN CODE
kmyQuest.StartPreApproach()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_13
Function Fragment_13()
;BEGIN AUTOCAST TYPE GR_TrapDefeat
Quest __temp = self as Quest
GR_TrapDefeat kmyQuest = __temp as GR_TrapDefeat
;END AUTOCAST
;BEGIN CODE
kmyQuest.StartApproach()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_19
Function Fragment_19()
;BEGIN AUTOCAST TYPE GR_TrapDefeat
Quest __temp = self as Quest
GR_TrapDefeat kmyQuest = __temp as GR_TrapDefeat
;END AUTOCAST
;BEGIN CODE
kmyQuest.DamagePlayer()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_24
Function Fragment_24()
;BEGIN AUTOCAST TYPE GR_TrapDefeat
Quest __temp = self as Quest
GR_TrapDefeat kmyQuest = __temp as GR_TrapDefeat
;END AUTOCAST
;BEGIN CODE
kmyQuest.StartObserve()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_22
Function Fragment_22()
;BEGIN AUTOCAST TYPE GR_TrapDefeat
Quest __temp = self as Quest
GR_TrapDefeat kmyQuest = __temp as GR_TrapDefeat
;END AUTOCAST
;BEGIN CODE
kmyQuest.RestartCombat()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_18
Function Fragment_18()
;BEGIN AUTOCAST TYPE GR_TrapDefeat
Quest __temp = self as Quest
GR_TrapDefeat kmyQuest = __temp as GR_TrapDefeat
;END AUTOCAST
;BEGIN CODE
kmyQuest.PreEscaped()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
