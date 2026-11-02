extends Control

@export var typing_speed: float = 0.020
@export var delay_between_labels: float = 0.05
@export var start_delay: float = 0.5

@export var animate_all_labels: bool = true
@export var animate_rich_text: bool = true

var label_list: Array[Node] = []
var animation_tweens: Array[Tween] = []

func _ready() -> void:
	_prepare_all_text()

	await get_tree().create_timer(start_delay).timeout

	if animate_all_labels:
		await _play_typewriter()

func _prepare_all_text() -> void:

	label_list.clear()

	var labels := find_children("*", "Label", true, false)

	for node in labels:

		if not is_instance_valid(node):
			continue

		if node.is_in_group("skip_typing"):
			continue

		label_list.append(node)

		node.visible_characters = 0

	if animate_rich_text:

		var rich_labels := find_children(
			"*",
			"RichTextLabel",
			true,
		 false
		)

		for node in rich_labels:

			if not is_instance_valid(node):
				continue

			if node.is_in_group("skip_typing"):
				continue

			label_list.append(node)

			node.visible_characters = 0


func _play_typewriter() -> void:

	for node in label_list:

		if not is_instance_valid(node):
			continue

		var character_count: int = 0

		if node is Label:

			character_count = node.text.length()

		elif node is RichTextLabel:

			character_count = (
				node.get_total_character_count()
			)

		if character_count <= 0:
			continue

		node.visible_characters = 0

		var duration: float = (
			character_count * typing_speed
		)

		var tween := create_tween()

		tween.tween_property(
			node,
			"visible_characters",
			character_count,
			duration
		)

		animation_tweens.append(tween)

		await tween.finished

		await get_tree().create_timer(
			delay_between_labels
		).timeout

func replay_typewriter() -> void:

	for node in label_list:

		if not is_instance_valid(node):
			continue

		node.visible_characters = 0

	await get_tree().create_timer(0.3).timeout

	await _play_typewriter()

func show_all_text() -> void:

	for node in label_list:

		if not is_instance_valid(node):
			continue

		node.visible_characters = -1

func stop_all_animations() -> void:

	for tween in animation_tweens:

		if is_instance_valid(tween):
			tween.kill()

	animation_tweens.clear()
func _on_footer_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/levels.tscn")
