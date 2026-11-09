class_name PlayerStateGroundSlam
extends PlayerState

@onready var damage_area: DamageArea = %DamageArea
@onready var ground_slam_shape_cast: ShapeCast2D = $"../../GroundSlamShapeCast"
@onready var ground_slam_attack_area: AttackArea = %GroundSlamAttackArea

@export var velocity: float = 400
@export var effect_delay: float = 0.075
var effect_timer: float = 0

func _init() -> void:
	pass




func enter() -> void:
	player.animation_player.play("ground_slam")
	player.sprite.tween_color()
	damage_area.start_invulnerable()
	ground_slam_attack_area.set_active()
	pass





func exit() -> void:
	VisualEffects.camera_shake(10.0)
	VisualEffects.hit_dust(player.global_position)
	VisualEffects.land_dust(player.global_position)
	damage_area.end_invulnerable()
	ground_slam_attack_area.set_active(false)
	pass


func handle_input(_event: InputEvent)-> PlayerState:

	return next_state


func process(_delta: float) -> PlayerState:
#	check_collisions(_delta)
	effect_timer -= _delta
	if effect_timer <0:
		effect_timer = effect_delay
		player.sprite.ghost() 
	return next_state
	
	



func physics_process(_delta: float) -> PlayerState:
	player.velocity = Vector2(0, velocity)
	if player.is_on_floor():
#		if not check_collisions(_delta):
			return idle
	return next_state

#func check_collisions(_delta: float)->bool:
#	ground_slam_shape_cast.target_position.y = velocity * _delta
#	ground_slam_shape_cast.force_shapecast_update()
#	if ground_slam_shape_cast.is_colliding():
#		for i in ground_slam_shape_cast.get_collision_cast(i):
#			var c = ground_slam_shape_cast.get_collider(i)
#			if c.get_parent() is Breakable:
#				var b: Breakable = c.queue_free()
#				b.queue_free()
#			else:
#				c.queue_free()
#				return true
#	return false
