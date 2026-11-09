class_name PlayerStateCrouch
extends PlayerState

@export var deceleration_rate : float = 20


func _init() -> void:
	pass




func enter() -> void:
	player.animation_player.play("crouch")
	player.collision_stand.disabled = true
	player.collision_crouch.disabled = false
	player.da_stand.disabled = true
	player.da_crouch.disabled = false
	pass





func exit() -> void:
	player.collision_stand.set_deferred("disabled", false)
	player.collision_crouch.set_deferred("disabled", true)
	player.da_stand.set_deferred("disabled", false)
	player.da_crouch.set_deferred("disabled", true)
	pass


func handle_input(_event: InputEvent)-> PlayerState:
	if _event.is_action_pressed("dash") and player.can_dash():
		return dash
	if _event.is_action_pressed("jump"):
		if player.one_way_platform_shape_cast.is_colliding():
			player.position.y += 4.0
			return fall
	if _event.is_action_pressed("action")and player.can_morph():
		return ball
		return jump
	return next_state


func process(delta: float) -> PlayerState:
	if player.direction.y <= 0.5:
		return idle
	return next_state
	
	



func physics_process( _delta: float) -> PlayerState:
	player.velocity.x -= player.velocity.x * deceleration_rate * _delta
	if player.is_on_floor() == false:
		return fall
	return next_state
