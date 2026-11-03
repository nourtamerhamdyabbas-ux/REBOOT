
extends Panel

@export_group("Card Entrance")
@export var entrance_duration: float = 0.45
@export var entrance_delay: float = 0.65
@export var starting_scale: float = 0.96

@export_group("Bar Animation")
@export var bar_fade_duration: float = 0.22
@export var bar_delay: float = 0.12

@onready var bar_panels: Array[PanelContainer] = [
	$"Hbox container/PanelContainer",
	$"Hbox container/PanelContainer2",
	$"Hbox container/PanelContainer3",
	$"Hbox container/PanelContainer4",
	$"Hbox container/PanelContainer5"
]


func _ready() -> void:
	play_intro_animation()


func play_intro_animation() -> void:
	modulate.a = 0.0
	scale = Vector2(starting_scale, starting_scale)
	for bar_panel in bar_panels:
		bar_panel.modulate.a = 0.0
	await get_tree().create_timer(entrance_delay).timeout
	var card_tween := create_tween()
	card_tween.set_parallel(true)

	card_tween.tween_property(
		self,
		"modulate:a",
		1.0,
		entrance_duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	card_tween.tween_property(
		self,
		"scale",
		Vector2.ONE,
		entrance_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await card_tween.finished
	for bar_panel in bar_panels:
		var bar_tween := create_tween()

		bar_tween.tween_property(
			bar_panel,
			"modulate:a",
			1.0,
			bar_fade_duration
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

		await bar_tween.finished

		await get_tree().create_timer(bar_delay).timeout
