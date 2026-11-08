extends Control

@onready var overlay: ColorRect = $TransitionOverlay

var transitioning := false

const FADE_OUT_DURATION := 1
const BLACK_SCREEN_DURATION := 0.5
const FADE_IN_DURATION := 1


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.modulate.a = 0.0


func change_scene_with_transition(scene_path: String) -> void:
	if transitioning:
		return

	transitioning = true
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var fade_out := create_tween()
	fade_out.set_trans(Tween.TRANS_CUBIC)
	fade_out.set_ease(Tween.EASE_IN_OUT)
	fade_out.tween_property(
		overlay,
		"modulate:a",
		1.0,
		FADE_OUT_DURATION
	)

	await fade_out.finished
	await get_tree().create_timer(BLACK_SCREEN_DURATION).timeout
	var error := get_tree().change_scene_to_file(scene_path)

	if error != OK:
		push_error("Scene transition failed: " + scene_path)
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		transitioning = false
		return

	await get_tree().scene_changed
	var fade_in := create_tween()
	fade_in.set_trans(Tween.TRANS_CUBIC)
	fade_in.set_ease(Tween.EASE_IN_OUT)
	fade_in.tween_property(
		overlay,
		"modulate:a",
		0.0,
		FADE_IN_DURATION
	)

	await fade_in.finished

	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transitioning = false
