class_name ESStun
extends Enemystate

#@export var animation_name : String = "idle" 
#var statemachine : EnemyStateMachine
#var enemy : Enemy
#var blackboard : Blackboard

@export var knockback_strengh : float = 100 
var vel_x : float = 0
var duraition : float = 0
var timer : float = 0

func start() -> void:
	var anim : String =animation_name if animation_name else "stun"
	if enemy.animation.current_animation == anim:
		enemy.animation.seek(0)
	else:
		enemy.play_animation(anim)
	duraition = enemy.animation.current_animation_length
	timer = 0
	#_calc_velocity( blackboard.damage_source )
	blackboard.damage_source = null
	blackboard.can_decide = false
	
	pass


func enter() -> void:
	start()
	pass

func re_enter() -> void:
	start()
	pass

func exit() -> void:
	blackboard.can_decide = true
	pass

func physics_update(delta: float) -> void:
	timer += delta
	enemy.velocity.x = vel_x * (1- timer / duraition)
	if timer >= duraition:
		blackboard.can_decide = true
	pass


func _calc_velocity( a : AttackArea ) -> void:
	vel_x = 1
	if a.global_position.x > enemy.global_position.x:
		vel_x = -1
	vel_x *= knockback_strengh
	pass
