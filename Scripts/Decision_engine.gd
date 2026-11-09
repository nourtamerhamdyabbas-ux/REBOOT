class_name DecisionEngine extends Node

var enemy : Enemy
var current_state : Enemystate
var blackboard : Blackboard


func _ready() -> void:
	while not enemy:
		await get_tree().process_frame
	enemy.change_direction(-1.0 if enemy.face_left_on_start else 1.0 )
	pass



func decide() -> Enemystate:
	# Decisions \ Conditions
	return null
