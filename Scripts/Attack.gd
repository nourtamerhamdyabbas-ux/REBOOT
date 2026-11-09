class_name PlayerStateAttack
extends PlayerState


@export var combo_time_window: float = 0.2
@export var speed: float = 150
var timer: float = 0
var combo: int = 0

@onready var attack_sprite_2d: Sprite2D = %AttackSprite2D








func _ready() -> void:
	attack_sprite_2d.visible = false
	pass




func enter() -> void:
	do_attack()
	player.animation_player.animation_finished.connect(_on_animation_finished)
	pass





func exit() -> void:
	timer = 0 
	combo = 0
	player.animation_player.animation_finished.disconnect(_on_animation_finished)
	next_state = null
	attack_sprite_2d.visible = false
	pass


func handle_input(_event: InputEvent)-> PlayerState:
	if _event.is_action_pressed("dash") and player.can_dash():
		return dash
	if _event.is_action_pressed("attack"):
		timer = combo_time_window
	#if _event.is_action_pressed("jump"):
		#return jump
	return next_state


func process(_delta: float) -> PlayerState:
	timer -= _delta
	return next_state
	
	



func physics_process(_delta: float) -> PlayerState:
	player.velocity.x = player.direction.x * speed
	return null


func do_attack()->void:
	var anim_name: String = "Attack"
	if combo>0:
		anim_name = "Attack_2"
	player.animation_player.play(anim_name)
	player.attack_area.activate()
	pass

func _end_attack()->void:
	if timer>0:
		combo = wrapi(combo+1,0,2)
		do_attack()
	else:
		next_state = idle
	pass



func _on_animation_finished(_anim_name: String)->void:
	_end_attack()
	pass
