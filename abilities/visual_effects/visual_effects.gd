extends Node

const DUST_EFFECT = preload("uid://b2v6dkapkjw4j")

signal camera_shook(strength: float)





func _create_dust_effect( pos : Vector2) -> DustEffect:
	var dust: DustEffect = DUST_EFFECT.instantiate()
	add_child(dust)
	dust.global_position = pos
	return dust
	pass


func jumb_dust( pos : Vector2) ->void:
	var dust: DustEffect = _create_dust_effect( pos )
	dust.start(DustEffect.TYPE.JUMP)
	pass



func land_dust( pos : Vector2) ->void:
	var dust: DustEffect = _create_dust_effect( pos )
	dust.start(DustEffect.TYPE.LAND)
	pass

func hit_dust( pos : Vector2) ->void:
	var dust: DustEffect = _create_dust_effect( pos )
	dust.start(DustEffect.TYPE.HIT)
	pass


func hit_particles()->void:
	pass




func camera_shake(strength: float = 1.0)->void:
	camera_shook.emit(strength)
	pass
