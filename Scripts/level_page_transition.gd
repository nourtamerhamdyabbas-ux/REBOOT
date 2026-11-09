
extends Node

const LEVEL_01_SCENE := "res://Scenes/level_1_page_for_main_menu.tscn"
const LEVEL_02_SCENE := "res://Scenes/level_2_page_for_the_main_menu.tscn"
const LEVEL_03_SCENE := "res://Scenes/level_3_page_main_menu.tscn"

@export var transition_duration: float = 0.4

var transition_overlay: ColorRect
var transition_layer: CanvasLayer
var transitioning: bool = false


func _ready() -> void:

	_create_transition_overlay()

	var signal_source := _find_signal_source(get_tree().root)

	if signal_source:

		var callback := Callable(
			self,
			"_on_level_open_requested"
		)

		if not signal_source.is_connected(
			"level_open_requested",
			callback
		):
			signal_source.connect(
				"level_open_requested",
				callback
			)

	else:
		push_error(
			"Level Transition: level_open_requested signal was not found."
		)


func _find_signal_source(node: Node) -> Node:

	if node.has_signal("level_open_requested"):
		return node

	for child in node.get_children():

		var result := _find_signal_source(child)

		if result:
			return result

	return null


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

	match level_number:

		1:
			await _open_level_scene(
				LEVEL_01_SCENE,
				false
			)

		2:
			await _open_level_scene(
				LEVEL_02_SCENE,
				true
			)

		3:
			await _open_level_scene(
				LEVEL_03_SCENE,
				true
			)

		_:
			push_warning(
				"Level Transition: Unknown level number: %d" % level_number
			)


func _open_level_scene(
	scene_path: String,
	review_mode: bool
) -> void:

	if transitioning:
		return

	if not ResourceLoader.exists(scene_path):

		push_error(
			"Level Transition: Scene does not exist: " + scene_path
		)

		return

	transitioning = true

	get_tree().set_meta(
		"level_review_mode",
		review_mode
	)

	await _play_transition()

	var error := get_tree().change_scene_to_file(scene_path)

	if error != OK:

		push_error(
			"Level Transition: Could not open scene. Error: %s" % error
		)

		get_tree().set_meta(
			"level_review_mode",
			false
		)

		transitioning = false


func _play_transition() -> void:

	transition_overlay.modulate.a = 0.0

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
