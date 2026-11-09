
extends Control

@onready var main_panel: Control = get_node_or_null(
	"main level page container/main panel level page container"
) as Control

@export_group("Difficulty Animation")
@export var difficulty_panel_fade_duration: float = 0.4
@export var difficulty_bar_fade_duration: float = 0.3
@export var difficulty_bar_delay: float = 0.08

@export_group("Progress Animation")
@export var target_progress: float = 12.0
@export var progress_duration: float = 2.0

@export_group("Panel Entrance")
@export var animate_panels: bool = true
@export var panel_fade_duration: float = 0.4
@export var panel_delay: float = 0.06

@export_group("Typewriter Settings")
@export var typing_speed: float = 0.007
@export var delay_between_labels: float = 0.08

@export_group("Button Entrance")
@export var animate_buttons: bool = true
@export var button_delay: float = 0.12
@export var button_fade_duration: float = 0.35

@export_group("Page Entrance")
@export var animate_all_labels: bool = true
@export var animate_rich_text: bool = true


var difficulty_panel: Control
var difficulty_row: HBoxContainer

var diagnostics_panel: Control
var progress_bar: ProgressBar
var percentage: Label

var mission_objective_panel: Control

var label_list: Array[Node] = []
var button_list: Array[Control] = []
var panel_list: Array[Control] = []
var difficulty_bars: Array[Control] = []
var animation_tweens: Array[Tween] = []


func _ready() -> void:
	_find_level_nodes()
	_prepare_main_panel()
	_prepare_difficulty()
	_prepare_progress()
	_prepare_panels()
	_prepare_all_text()
	_prepare_buttons()
	_apply_review_mode()
	await _animate_main_panel()

	var difficulty_tween := _animate_difficulty()
	var panels_tween := _animate_panels()

	await difficulty_tween.finished

	if animate_panels:
		await panels_tween.finished

	animate_progress()

	if animate_all_labels:
		await _play_typewriter()

	if animate_buttons:
		await _animate_buttons()


func _find_level_nodes() -> void:

	if main_panel == null:
		push_warning("Main level page container was not found.")
		return

	difficulty_panel = main_panel.find_child(
		"Difficulty Panel",
		true,
		false
	) as Control

	if difficulty_panel != null:
		difficulty_row = difficulty_panel.find_child(
			"HBoxContainer",
			true,
			false
		) as HBoxContainer

	diagnostics_panel = main_panel.find_child(
		"ECHO DIAGNOSTIC Panel3",
		true,
		false
	) as Control

	mission_objective_panel = main_panel.find_child(
		"Mission objective Panel2",
		true,
		false
	) as Control

	if diagnostics_panel != null:

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


func _prepare_main_panel() -> void:

	if main_panel == null:
		push_warning("Main panel was not found.")
		return

	main_panel.modulate.a = 0.0


func _animate_main_panel() -> void:

	if main_panel == null:
		return

	var tween := create_tween()
	animation_tweens.append(tween)

	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		main_panel,
		"modulate:a",
		1.0,
		panel_fade_duration
	)

	await tween.finished


func _prepare_difficulty() -> void:

	difficulty_bars.clear()

	if difficulty_panel == null:
		push_warning("Difficulty Panel was not found.")
		return

	difficulty_panel.modulate.a = 0.0

	if difficulty_row == null:
		push_warning("Difficulty HBoxContainer was not found.")
		return

	for child in difficulty_row.get_children():

		if child is Control:

			var bar := child as Control

			difficulty_bars.append(bar)
			bar.modulate.a = 0.0


func _animate_difficulty() -> Tween:

	var tween := create_tween()
	animation_tweens.append(tween)

	if difficulty_panel == null:
		return tween

	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		difficulty_panel,
		"modulate:a",
		1.0,
		difficulty_panel_fade_duration
	)

	for bar in difficulty_bars:

		if not is_instance_valid(bar):
			continue

		tween.tween_interval(difficulty_bar_delay)

		tween.tween_property(
			bar,
			"modulate:a",
			1.0,
			difficulty_bar_fade_duration
		)

	return tween


func _prepare_progress() -> void:

	if progress_bar == null:
		return

	progress_bar.value = clampf(
		0.0,
		progress_bar.min_value,
		progress_bar.max_value
	)

	if percentage != null:
		percentage.text = "0%"
		percentage.visible = true
		percentage.visible_characters = -1
		percentage.modulate.a = 1.0


func animate_progress() -> void:

	if progress_bar == null:
		return

	var start_value := clampf(
		0.0,
		progress_bar.min_value,
		progress_bar.max_value
	)

	var end_value := clampf(
		target_progress,
		progress_bar.min_value,
		progress_bar.max_value
	)

	progress_bar.value = start_value

	if percentage != null:
		percentage.text = "0%"

	var progress_tween := create_tween()
	animation_tweens.append(progress_tween)

	progress_tween.set_trans(Tween.TRANS_CUBIC)
	progress_tween.set_ease(Tween.EASE_OUT)

	progress_tween.tween_method(
		update_progress,
		start_value,
		end_value,
		progress_duration
	)


func update_progress(value: float) -> void:

	if progress_bar == null:
		return

	progress_bar.value = value

	if percentage != null:
		percentage.text = str(roundi(value)) + "%"


func _prepare_panels() -> void:

	panel_list.clear()

	if not animate_panels or main_panel == null:
		return

	var panels := main_panel.find_children(
		"*",
		"PanelContainer",
		true,
		false
	)

	var regular_panels := main_panel.find_children(
		"*",
		"Panel",
		true,
		false
	)

	for node in panels:
		_add_panel(node)

	for node in regular_panels:
		_add_panel(node)

	_add_panel(diagnostics_panel)
	_add_panel(mission_objective_panel)


func _add_panel(node: Node) -> void:

	if not is_instance_valid(node):
		return

	if not node is Control:
		return

	if node.is_in_group("skip_panel_fade"):
		return

	if node == difficulty_panel:
		return

	if difficulty_panel != null:
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

		if difficulty_panel != null:
			if difficulty_panel.is_ancestor_of(node):
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


func _prepare_buttons() -> void:

	button_list.clear()

	if not animate_buttons or main_panel == null:
		return

	var button_names := [
		"RTM Button",
		"> O IFM Button control"
	]

	for button_name in button_names:

		var button := main_panel.find_child(
			button_name,
			true,
			false
		) as Control

		if button == null:
			push_warning(button_name + " was not found.")
			continue

		if button.is_in_group("skip_entrance"):
			continue

		if button_list.has(button):
			continue

		button_list.append(button)
		button.modulate.a = 0.0


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

		await tween.finished

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


func _on_footer_button_pressed() -> void:

	get_tree().change_scene_to_file(
		"res://Scenes/levels.tscn"
	)


func _on_rtm_button_pressed() -> void:
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
