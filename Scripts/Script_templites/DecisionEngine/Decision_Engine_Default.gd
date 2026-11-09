#class_name DecisionEngineName
extends DecisionEngine
#meta_name DecisionEngine
#meta-describtion: Boilerbiate descision engine script
#meta-default: true

#include in decsigion engine
#var enemy : Enemy
#var current_state : Enemystate
#var blackboard : Blackboard

@onready var es_walk: Enemystate = $ESWalk
@onready var es_stun: Enemystate = $ESStun
@onready var es_death: Enemystate = $ESDeath




func _ready() -> void:
	await super()
	
	pass

func decide() -> Enemystate: 
	if blackboard.damage_source:
		if blackboard.health <=0:
			return es_death
		else:
			return es_stun
	
	if current_state is ESDeath or not blackboard.can_decide:
		return null
	
	if blackboard.edge_detected:
		enemy.change_dir(-blackboard.dir)
	
	return es_walk
		
	
	
