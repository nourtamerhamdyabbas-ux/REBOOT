#class_name DecisionEngineBasic
extends DecisionEngine
#meta_name DecisionEngine
#meta-describtion: Boilerbiate descision engine script
#meta-default: true

#include in decsigion engine
#var enemy : Enemy
#var current_state : Enemystate
#var blackboard : Blackboard

func _ready() -> void:
	await super()
	
	pass

func decide() -> Enemystate:
	#if blackboard.damage_source:
		#if blackboard.health <=0:
			#return es_death
		#else:
			#return es_stun
	#if current_state is ESDeath or not blackgound.can_decide:
		#return null
	
	#if blackboard.target:
		#if blackboard.distance_to_target < 40:
			#return attack_state?
		return null #default state
		
	
	
