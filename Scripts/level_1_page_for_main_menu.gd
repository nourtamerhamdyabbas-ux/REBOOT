
extends Control

@export_group("Typewriter Settings")
@export var typing_speed: float = 0.025
@export var delay_between_labels: float = 0.08
@export var start_delay: float = 0.45

@export_group("Page Entrance")
@export var animate_all_labels: bool = true
@export var animate_rich_text: bool = true
@export var animate_buttons: bool = true
@export var button_delay: float = 0.12
@export var button_fade_duration: float = 0.3

var label_list: Array[Node] = []
var button_list: Array[Button] = []
var animation_tweens: Array[Tween] = []
var animation_started := false


func _ready() -> void:
	_prepare_all_text()
	_prepare_buttons()

	await get_tree().create_timer(start_delay).timeout

	if animate_all_labels:
		await _play_typewriter()

	if animate_buttons:
		await _animate_buttons()


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


func _prepare_buttons() -> void:
	button_list.clear()

	if not animate_buttons:
		return

	var buttons := find_children("*", "Button", true, false)

	for node in buttons:
		if not is_instance_valid(node):
			continue

		if node.is_in_group("skip_entrance"):
			continue

		button_list.append(node)
		node.modulate.a = 0.0


func _play_typewriter() -> void:
	for node in label_list:
		if not is_instance_valid(node):
			continue

		var character_count := 0

		if node is Label:
			character_count = node.text.length()
		elif node is RichTextLabel:
			character_count = node.get_total_character_count()

		if character_count <= 0:
			node.visible_characters = -1
			continue

		node.visible_characters = 0

		var duration := character_count * typing_speed

		var tween := create_tween()
		animation_tweens.append(tween)

		tween.tween_property(
			node,
			"visible_characters",
			character_count,
			duration
		).set_trans(Tween.TRANS_LINEAR)

		await tween.finished

		await get_tree().create_timer(
			delay_between_labels
		).timeout


func _animate_buttons() -> void:
	for button in button_list:
		if not is_instance_valid(button):
			continue

		var tween := create_tween()
		animation_tweens.append(tween)

		tween.tween_property(
			button,
			"modulate:a",
			1.0,
			button_fade_duration
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

		await get_tree().create_timer(button_delay).timeout


func replay_typewriter() -> void:
	stop_all_animations()

	for node in label_list:
		if is_instance_valid(node):
			node.visible_characters = 0

	await get_tree().create_timer(0.3).timeout
	await _play_typewriter()


func show_all_text() -> void:
	for node in label_list:
		if is_instance_valid(node):
			node.visible_characters = -1


func stop_all_animations() -> void:
	for tween in animation_tweens:
		if is_instance_valid(tween):
			tween.kill()

	animation_tweens.clear()


func _on_footer_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/levels.tscn")
