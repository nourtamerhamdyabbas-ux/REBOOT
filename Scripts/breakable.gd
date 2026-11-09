@tool
class_name Breakable
extends Node2D

signal destroyed

@export var hp: float = 3
@export var fixed_hit_count: bool = false

@export_category("Particles")
@export var emission_offset: Vector2 = Vector2.ZERO
@export var hit_particles: Array[HitParticleSettings]
@export var destroy_particles: Array[HitParticleSettings]

var is_destroying: bool = false


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	for c in get_children():
		if c is DamageArea:
			c.damage_taken.connect(_on_damage_taken)


func _on_damage_taken(attack_area: AttackArea) -> void:
	if is_destroying:
		return

	if fixed_hit_count:
		hp -= 1
	else:
		hp -= attack_area.damage

	var pos: Vector2 = global_position + emission_offset
	var dir: Vector2 = Vector2(-1, 1)

	if attack_area.global_position.x > global_position.x:
		dir.x *= -1

	if hp > 0:
		for p in hit_particles:
			if p != null:
				VisualEffects.hit_particles(pos, dir, p)
	else:
		is_destroying = true

		for p in destroy_particles:
			if p != null:
				VisualEffects.hit_particles(pos, dir, p)

		clear_collisions()
		destroyed.emit()

		var tween: Tween = create_tween()
		tween.tween_property(self, "modulate", Color(modulate, 0), 0.4)
		await tween.finished
		queue_free()


func clear_collisions() -> void:
	for c in get_children():
		if c is StaticBody2D:
			c.queue_free()


func _get_configuration_warnings() -> PackedStringArray:
	if not _check_for_damage_area():
		return ["Requires a DamageArea node!"]

	return []


func _check_for_damage_area() -> bool:
	for c in get_children():
		if c is DamageArea:
			return true

	return false
