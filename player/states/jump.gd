class_name PlayerStateJump
extends PlayerState

@export var jump_velocity: float = 450

func init() -> void:
	pass




func enter() -> void:
	VisualEffects.jumb_dust(player.global_position)
	player.animation_player.play("jump")
	player.animation_player.pause()
	player.velocity.y = -jump_velocity
	player.add_debug_indicator(Color.LIME_GREEN)
	pass





func exit() -> void:
	player.add_debug_indicator(Color.YELLOW)
	pass


func handle_input(event: InputEvent)-> PlayerState:
	if event.is_action_pressed("attack"):
		return attack
	if event.is_action_pressed("jump"):

		return fall
	return next_state


func process(delta: float) -> PlayerState:
	set_jump_frame()
	return next_state
	
	



func physics_process(delta: float) -> PlayerState:
	if player.is_on_floor():
		return idle
	elif player.velocity.y >= 0:
		return fall
	player.velocity.x = player.direction.x * player.move_speed
	return next_state

func set_jump_frame()-> void:
	var frame: float = remap(player.velocity.y, -jump_velocity,0.0,0.0, 0.5)
	player.animation_player.seek(frame,true)
	pass
