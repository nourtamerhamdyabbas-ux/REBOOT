extends Node
const LEVEL_01_SCENE := "res://Scenes/level_1_page_for_main_menu.tscn"
@export var transition_duration: float = 0.4
var transition_overlay: ColorRect
var transition_layer: CanvasLayer
var transitioning: bool = false

func _ready() -> void:

	_create_transition_overlay()

	var levels_root := get_parent()

	if levels_root.has_signal("level_open_requested"):

		var callback := Callable(self, "_on_level_open_requested")

		if not levels_root.is_connected("level_open_requested", callback):
			levels_root.connect("level_open_requested", callback)

	else:
		push_error("Level Page Transition: level_open_requested signal was not found.")

func _create_transition_overlay() -> void:
	transition_layer = CanvasLayer.new()
	transition_layer.layer = 100
	add_child(transition_layer)

	transition_overlay = ColorRect.new()

	transition_overlay.color = Color("#080B18")
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	transition_overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	transition_overlay.modulate.a = 0.0

	transition_layer.add_child(transition_overlay)

func _on_level_open_requested(level_number: int) -> void:

	if transitioning:
		return

	if level_number != 1:
		return

	transitioning = true

	await _play_transition()

	var error := get_tree().change_scene_to_file(LEVEL_01_SCENE)

	if error != OK:
		push_error("Could not open Level 01 scene. Error: %s" % error)
		transitioning = false
func _play_transition() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(
		transition_overlay,
		"modulate:a",
		1.0,
		transition_duration
	)
	await tween.finished
