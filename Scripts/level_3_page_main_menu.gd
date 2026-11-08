
extends Control

@onready var main_panel: Control = get_node_or_null(
	"main level page container/main panel level page container"
) as Control

var progress_bar: ProgressBar
var percentage: Label


@export_group("Progress Animation")
@export var target_progress: float = 12.0
@export var progress_duration: float = 4.0
@export var percentage_fade_duration: float = 0.5


@export_group("Typewriter Settings")
@export var typing_speed: float = 0.007
@export var delay_between_labels: float = 0.08
@export var start_delay: float = 3.2


@export_group("Typewriter Options")
@export var animate_all_labels: bool = true
@export var animate_rich_text: bool = true


var label_list: Array[Node] = []
var animation_tweens: Array[Tween] = []


func _ready() -> void:

	_find_level_nodes()
	_apply_review_mode()
	_prepare_progress()
	_prepare_all_text()

	await get_tree().create_timer(start_delay).timeout

	animate_progress()

	if animate_all_labels:
		await _play_typewriter()


func _find_level_nodes() -> void:

	if main_panel == null:
		push_warning("Main level page container was not found.")
		return

	var diagnostics_panel := main_panel.find_child(
		"ECHO DIAGNOSTIC Panel3",
		true,
		false
	) as Control

	if diagnostics_panel == null:
		push_warning("ECHO DIAGNOSTIC Panel3 was not found.")
		return

	progress_bar = diagnostics_panel.find_child(
		"ProgressBar",
		true,
		false
	) as ProgressBar

	percentage = diagnostics_panel.find_child(
		"Signal percentage Label",
		true,
		false
	) as Label

	if progress_bar == null:
		push_warning("ProgressBar was not found.")

	if percentage == null:
		push_warning("Signal percentage Label was not found.")


func _prepare_progress() -> void:

	if progress_bar == null:
		return

	progress_bar.min_value = 0.0
	progress_bar.max_value = 100.0
	progress_bar.value = 0.0

	if percentage != null:
		percentage.text = "0%"
		percentage.visible = true
		percentage.visible_characters = -1
		percentage.modulate.a = 0.0


func animate_progress() -> void:

	if progress_bar == null:
		return

	progress_bar.value = 0.0

	if percentage != null:
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

	if percentage != null:
		progress_tween.parallel().tween_property(
			percentage,
			"modulate:a",
			1.0,
			percentage_fade_duration
		)


func update_progress(value: float) -> void:

	if progress_bar == null:
		return

	progress_bar.value = value

	if percentage != null:
		percentage.text = str(roundi(value)) + "%"


func _prepare_all_text() -> void:

	label_list.clear()

	if not animate_all_labels or main_panel == null:
		return

	var labels := main_panel.find_children(
		"*",
		"Label",
		true,
		false
	)

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

		var rich_labels := main_panel.find_children(
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


func _on_rtm_button_pressed() -> void:
	$SFX/SFXClickPlayer.play()
	get_tree().change_scene_to_file("res://Scenes/levels.tscn")

func _apply_review_mode() -> void:

	var review_mode: bool = get_tree().get_meta(
		"level_review_mode",
		false
	)

	var initiate_button := find_child(
		"IFM Button2",
		true,
		false
	) as BaseButton

	if initiate_button:
		initiate_button.disabled = review_mode

	get_tree().set_meta("level_review_mode", false)


func _on_ifm_button_2_pressed() -> void:
	$SFX/SFXClickPlayer.play()
