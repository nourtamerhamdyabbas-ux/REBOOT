
extends Control

@onready var difficulty_panel: Control = get_node_or_null(
	"Main level page panel/main level page panel/Difficulty Panel2"
) as Control

@onready var difficulty_row: HBoxContainer = get_node_or_null(
	"Main level page panel/main level page panel/Difficulty Panel2/HBoxContainer"
) as HBoxContainer

@onready var progress_bar: ProgressBar = get_node_or_null(
	"Main level page panel/main level page panel/Echo Diagnostics Panel3/ProgressBar"
) as ProgressBar

@onready var percentage: Label = get_node_or_null(
	"Main level page panel/main level page panel/Echo Diagnostics Panel3/Percentage Label"
) as Label


@export_group("Difficulty Animation")
@export var difficulty_panel_fade_duration: float = 0.35
@export var difficulty_bar_fade_duration: float = 0.22
@export var difficulty_bar_delay: float = 0.06


@export_group("Progress Animation")
const TARGET_PROGRESS: float = 37.0
const PROGRESS_DURATION: float = 4.0
const PERCENTAGE_FADE_DURATION: float = 4.0


@export_group("Panel Entrance")
@export var animate_panels: bool = true
@export var panel_fade_duration: float = 0.35
@export var panel_delay: float = 0.05


@export_group("Typewriter Settings")
@export var typing_speed: float = 0.007
@export var delay_between_labels: float = 0.08


@export_group("Page Entrance")
@export var animate_all_labels: bool = true
@export var animate_rich_text: bool = true
@export var animate_buttons: bool = true
@export var button_delay: float = 0.08
@export var button_fade_duration: float = 0.3


var label_list: Array[Node] = []
var button_list: Array[Button] = []
var panel_list: Array[Control] = []
var animation_tweens: Array[Tween] = []


func _ready() -> void:

	_prepare_difficulty()
	_prepare_progress()
	_prepare_panels()
	_prepare_all_text()
	_prepare_buttons()
	_apply_review_mode()

	await get_tree().process_frame

	animate_progress()

	var difficulty_tween := _animate_difficulty()
	var panels_tween := _animate_panels()

	await difficulty_tween.finished

	if animate_panels and panels_tween != null:
		await panels_tween.finished

	if animate_all_labels:
		await _play_typewriter()

	if animate_buttons:
		await _animate_buttons()


func _prepare_difficulty() -> void:

	if difficulty_panel == null:
		push_warning("Difficulty Panel2 was not found.")
		return

	if difficulty_row == null:
		push_warning("Difficulty HBoxContainer was not found.")
		return

	difficulty_panel.modulate.a = 0.0

	for child in difficulty_row.get_children():

		if child is PanelContainer:
			child.modulate.a = 0.0


func _animate_difficulty() -> Tween:

	var tween := create_tween()
	animation_tweens.append(tween)

	if difficulty_panel == null or difficulty_row == null:
		return tween

	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		difficulty_panel,
		"modulate:a",
		1.0,
		difficulty_panel_fade_duration
	)

	for child in difficulty_row.get_children():

		if not child is PanelContainer:
			continue

		tween.tween_interval(difficulty_bar_delay)

		tween.tween_property(
			child,
			"modulate:a",
			1.0,
			difficulty_bar_fade_duration
		)

	return tween


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
		TARGET_PROGRESS,
		PROGRESS_DURATION
	)

	progress_tween.parallel().tween_property(
		percentage,
		"modulate:a",
		1.0,
		PERCENTAGE_FADE_DURATION
	)


func update_progress(value: float) -> void:

	if progress_bar == null or percentage == null:
		return

	progress_bar.value = value
	percentage.text = str(roundi(value)) + "%"


func _prepare_panels() -> void:

	panel_list.clear()

	if not animate_panels:
		return

	var panels := find_children("*", "PanelContainer", true, false)
	var regular_panels := find_children("*", "Panel", true, false)

	for node in panels:
		_add_panel_to_list(node)

	for node in regular_panels:
		_add_panel_to_list(node)


func _add_panel_to_list(node: Node) -> void:

	if not is_instance_valid(node):
		return

	if not node is Control:
		return

	if node.is_in_group("skip_panel_fade"):
		return

	if difficulty_panel != null:
		if node == difficulty_panel:
			return

		if difficulty_panel.is_ancestor_of(node):
			return

	var panel := node as Control

	if panel_list.has(panel):
		return

	panel_list.append(panel)
	panel.modulate.a = 0.0


func _animate_panels() -> Tween:

	var tween := create_tween()
	animation_tweens.append(tween)

	if not animate_panels:
		return tween

	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

	for panel in panel_list:

		if not is_instance_valid(panel):
			continue

		tween.tween_interval(panel_delay)

		tween.tween_property(
			panel,
			"modulate:a",
			1.0,
			panel_fade_duration
		)

	return tween


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

		if difficulty_panel != null:
			if difficulty_panel.is_ancestor_of(node):
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

			if difficulty_panel != null:
				if difficulty_panel.is_ancestor_of(node):
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

		await get_tree().create_timer(
			button_delay
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
	get_tree().change_scene_to_file("res://Scenes/levels.tscn")
