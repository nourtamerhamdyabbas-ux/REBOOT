class_name EnemyStateMachine extends Node

var enemy : Enemy
var blackboard: Blackboard
var states: Array[ Enemystate]
var current_state: Enemystate :
	get():
		return states.front()
var prev_state : Enemystate :
	get():
		return states.get( 1 )


func setup(e : Enemy,b : Blackboard) -> void:
	blackboard = b
	enemy = e
	for c in get_children():
		if c is Enemystate:
			c.enemy = e
			c.blackboard = b
			c.statemachine = self
			states.append( c )
	current_state.enter()
	pass



func change_state( new_state : Enemystate) -> void:
	if not new_state:
		return
	
	if new_state == current_state:
		current_state.re_enter()
		return
	
	if current_state:
		current_state.exit()
	
	states.push_front( new_state )
	current_state.enter()
	if enemy:
		enemy.decision_engine.current_state = new_state
	states.resize( 2 )
	pass


##Called from enemies _physics_process
func _physics_update( _delta: float) -> void:
	if current_state:
		current_state._physics_uodate( _delta )
	pass
