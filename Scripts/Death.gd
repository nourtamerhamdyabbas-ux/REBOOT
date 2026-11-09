class_name PlayerStateDeath
extends PlayerState



func _init() -> void:
	pass




func enter() -> void:
	player.animation_player.play("death")
	await player.animation_player.animation_finished
	PlayerHud.show_game_over()
	
	pass





func exit() -> void:
	pass


func handle_input(_event: InputEvent)-> PlayerState:
	return next_state


func process(delta: float) -> PlayerState:
	return next_state
	
	



func physics_process(delta: float) -> PlayerState:
	player.velocity.x =0
	return null
