extends Node2D

@export var particles: Array[HitParticleSettings]
@export var base_wooble_angle: float = 4.0
@export var wooble_speed: float = 0.1

var tween: Tween

@onready var body_sprite: Sprite2D = $BodySprite
@onready var damage_area: DamageArea = $DamageArea


func _ready() -> void:
	damage_area.damage_taken.connect(_on_damage_taken)


func _on_damage_taken(attack_area: AttackArea) -> void:
	var dir: float = 1.0

	if attack_area.global_position.x > global_position.x:
		dir = -1.0

	var pos: Vector2 = global_position + Vector2(0, -30)

	for p in particles:
		if p != null:
			VisualEffects.hit_particles(pos, Vector2(dir, 0), p)

	wooble(dir)


func wooble(dir: float) -> void:
	if tween:
		tween.kill()

	body_sprite.rotation_degrees = 0.0

	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	for i in range(4):
		var direction: float = dir if i % 2 == 0 else -dir
		var angle: float = base_wooble_angle * (4 - i)

		tween.tween_property(
			body_sprite,
			"rotation_degrees",
			angle * direction,
			wooble_speed
		)

	tween.tween_property(body_sprite, "rotation_degrees", 0.0, wooble_speed)
