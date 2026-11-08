
extends Control

@onready var progress_bar: ProgressBar = get_node_or_null(
	"Main level page panel/main level page panel/Echo Diagnostics Panel3/ProgressBar"
) as ProgressBar

@onready var percentage: Label = get_node_or_null(
	"Main level page panel/main level page panel/Echo Diagnostics Panel3/Percentage Label"
) as Label


@export_group("Progress Animation")
@export var target_progress: float = 37.0
@export var progress_duration: float = 4.0
@export var percentage_fade_duration: float = 0.5


@export_group("Typewriter Settings")
@export var typing_speed: float = 0.007
@export var delay_between_labels: float = 0.08
@export var start_delay: float = 4.0


@export_group("Typewriter Options")
@export var animate_all_labels: bool = true
@export var animate_rich_text: bool = true


var label_list: Array[Node] = []
var animation_tweens: Array[Tween] = []


func _ready() -> void:

	_apply_review_mode()
	_prepare_progress()
	_prepare_all_text()

	await get_tree().create_timer(start_delay).timeout

	animate_progress()

	if animate_all_labels:
		await _play_typewriter()


func _prepare_progress() -> void:

	if progress_bar == null:
		push_warning("ProgressBar was not found.")
		return

	if percentage == null:
		push_warning("Percentage Label was not found.")
		return

	progress_bar.min_value = 0.0
	progress_bar.max_value = 100.0
	progress_bar.value = 0.0

	percentage.text = "0%"
	percentage.visible = true
	percentage.visible_characters = -1
	percentage.modulate.a = 0.0


func animate_progress() -> void:

	if progress_bar == null or percentage == null:
		return

	progress_bar.value = 0.0
	percentage.text = "0%"

	var progress_tween := create_tween()
	animation_tweens.append(progress_tween)

	progress_tween.set_trans(Tween.TRANS_LINEAR)
	progress_tween.set_ease(Tween.EASE_IN_OUT)

	progress_tween.tween_method(
		update_progress,
		0.0,
		target_progress,
		progress_duration
	)

	progress_tween.parallel().tween_property(
		percentage,
		"modulate:a",
		1.0,
		percentage_fade_duration
	)


func update_progress(value: float) -> void:

	if progress_bar == null or percentage == null:
		return

	progress_bar.value = value
	percentage.text = str(roundi(value)) + "%"


func _prepare_all_text() -> void:

	label_list.clear()

	if not animate_all_labels:
		return

	var labels := find_children("*", "Label", true, false)

	for node in labels:

		if not is_instance_valid(node):
			continue

		if node == percentage:
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


func _apply_review_mode() -> void:

	var review_mode: bool = get_tree().get_meta(
		"level_review_mode",
		false
	)

	var initiate_button := find_child(
		"Initiate Button",
		true,
		false
	) as BaseButton

	if initiate_button:
		initiate_button.disabled = review_mode

	get_tree().set_meta("level_review_mode", false)


func _on_return_to_terminall_button_pressed() -> void:
	$SFX/SFXClickPlayer.play()
	get_tree().change_scene_to_file(
		"res://Scenes/levels.tscn"
	)


func _on_initiate_button_pressed() -> void:
	$SFX/SFXClickPlayer.play()
