
extends Control

signal level_open_requested(level_number: int)


@export_group("Terminal Colors")
@export var terminal_background: Color = Color("#160D30")
@export var terminal_border: Color = Color("#49316D")
@export var neon_magenta: Color = Color("#FF2EAB")
@export var neon_cyan: Color = Color("#8DF7FF")
@export var main_text_color: Color = Color("#F7FCFF")
@export var muted_text_color: Color = Color("#8B83AC")
@export var error_color: Color = Color("#FF3D67")
@export var success_color: Color = Color("#00E89B")

@export_group("Terminal Settings")
@export var typing_speed: float = 0.025
@export var output_font_size: int = 16

@export_group("Fonts")
@export var terminal_font: Font


@onready var terminal: Panel = $Terminal

var title_label: Label
var subtitle_label: Label
var chat_history: RichTextLabel
var command_line: LineEdit
var hint_panel: Control
var animation_player: AnimationPlayer



var level_status := {
	1: "AVAILABLE",
	2: "LOCKED",
	3: "LOCKED"
}

var command_history: Array[String] = []


func _ready() -> void:

	_find_nodes()

	if not _validate_nodes():
		return

	_setup_terminal()
	_setup_header()
	_setup_chat_history()
	_setup_command_line()

	_setup_hint_animation()

	_run_startup_sequence()


func _find_nodes() -> void:

	title_label = find_child("Title label", true, false) as Label
	subtitle_label = find_child("Subtitle", true, false) as Label
	chat_history = find_child("Chat History", true, false) as RichTextLabel
	command_line = find_child("Command Line", true, false) as LineEdit
	hint_panel = find_child("Hint Panel", true, false) as Control
	animation_player = find_child("AnimationPlayer", true, false) as AnimationPlayer


func _validate_nodes() -> bool:

	var valid := true

	if terminal == null:
		push_error("ECHO ERROR: Terminal Panel was not found.")
		valid = false

	if chat_history == null:
		push_error("ECHO ERROR: Chat History RichTextLabel was not found.")
		valid = false

	if command_line == null:
		push_error("ECHO ERROR: Command Line LineEdit was not found.")
		valid = false

	return valid


func _setup_terminal() -> void:

	var panel_style := StyleBoxFlat.new()

	panel_style.bg_color = terminal_background

	panel_style.border_color = terminal_border
	panel_style.set_border_width_all(2)

	panel_style.set_corner_radius_all(12)

	panel_style.shadow_color = Color("#D900FF", 0.15)
	panel_style.shadow_size = 12

	panel_style.content_margin_left = 18
	panel_style.content_margin_right = 18
	panel_style.content_margin_top = 18
	panel_style.content_margin_bottom = 18

	terminal.add_theme_stylebox_override("panel", panel_style)



func _setup_header() -> void:

	if title_label:
		title_label.text = "ECHO // TERMINAL"

		title_label.add_theme_color_override(
			"font_color",
			neon_magenta
		)

		title_label.add_theme_font_size_override(
			"font_size",
			25
		)

		if terminal_font:
			title_label.add_theme_font_override(
				"font",
				terminal_font
			)

	if subtitle_label:
		subtitle_label.text = "SECURE CONNECTION // LEVEL ACCESS"

		subtitle_label.add_theme_color_override(
			"font_color",
			muted_text_color
		)

		if terminal_font:
			subtitle_label.add_theme_font_override(
				"font",
				terminal_font
			)



func _setup_chat_history() -> void:

	chat_history.bbcode_enabled = true
	chat_history.scroll_active = true
	chat_history.scroll_following = true
	chat_history.selection_enabled = true

	chat_history.add_theme_color_override(
		"default_color",
		main_text_color
	)

	chat_history.add_theme_font_size_override(
		"normal_font_size",
		output_font_size
	)

	if terminal_font:
		chat_history.add_theme_font_override(
			"normal_font",
			terminal_font
		)

	chat_history.add_theme_stylebox_override(
		"normal",
		StyleBoxEmpty.new()
	)



func _setup_command_line() -> void:

	command_line.focus_mode = Control.FOCUS_ALL

	if not command_line.text_submitted.is_connected(_on_command_submitted):
		command_line.text_submitted.connect(_on_command_submitted)

func _setup_hint_animation() -> void:

	if animation_player == null:
		push_warning("ECHO: AnimationPlayer was not found.")
		return

	if animation_player.get_animation_list().is_empty():
		push_warning("ECHO: AnimationPlayer has no animations.")
		return


	animation_player.stop()
	animation_player.active = true


func _run_startup_sequence() -> void:

	var startup_messages: Array[String] = [
		"[color=#FF2EAB]ECHO BIOS v4.7.2[/color]",
		"[color=#8DF7FF]Initializing terminal interface...[/color]",
		"[color=#00E89B][OK][/color] Memory modules initialized.",
		"[color=#00E89B][OK][/color] Security protocols loaded.",
		"[color=#00E89B][OK][/color] Communication interface online.",
		"[color=#00E89B][OK][/color] ECHO core initialized.",
		"",
		"[color=#FF2EAB]SECURE CONNECTION ESTABLISHED[/color]",
		"[color=#00E89B][OK][/color] Type a command !"
	]

	for message in startup_messages:
		await _type_message(message)
		await get_tree().create_timer(0.15).timeout

	command_line.grab_focus()


func _type_message(message: String) -> void:

	var previous_count := chat_history.get_total_character_count()

	chat_history.append_text(message + "\n")

	var new_count := chat_history.get_total_character_count()

	chat_history.visible_characters = previous_count

	for i in range(previous_count, new_count):

		chat_history.visible_characters = i + 1

		await get_tree().create_timer(typing_speed).timeout

	chat_history.visible_characters = -1

	chat_history.scroll_to_line(chat_history.get_line_count())


func _on_command_submitted(command: String) -> void:

	var clean_command := command.strip_edges().to_upper()

	if clean_command.is_empty():
		return

	command_line.clear()

	command_history.append(clean_command)

	await _type_message(
		"[color=#8DF7FF]player@echo:~$ [/color]" + clean_command
	)

	await _process_command(clean_command)

	command_line.grab_focus()


func _process_command(command: String) -> void:

	match command:

		"LIST LEVELS":
			await _list_levels()

		"SYSTEM STATUS":
			await _system_status()

		"PLAYER INFO":
			await _player_info()

		"CLEAR":
			chat_history.clear()

		"OPEN LEVEL 01":
			await _open_level(1)

		"OPEN LEVEL 02":
			await _open_level(2)

		"OPEN LEVEL 03":
			await _open_level(3)

		_:
			await _type_message(
				"[color=#FF3D67]ECHO ERROR: Unknown command.[/color]"
			)

			await _type_message(
				"[color=#8B83AC]Check the command and try again.[/color]"
			)


func _list_levels() -> void:

	await _type_message("[color=#FF2EAB]AVAILABLE MISSIONS[/color]")
	await _type_message("")

	for level_number in level_status:

		var status: String = level_status[level_number]
		var status_color: String

		if status == "AVAILABLE":
			status_color = "#00E89B"
		else:
			status_color = "#FF3D67"

		await _type_message(
			"LEVEL %02d  [color=%s]%s[/color]" % [
				level_number,
				status_color,
				status
			]
		)

	await _type_message("")
	await _type_message(
		"[color=#8B83AC]Use OPEN LEVEL 01 to access an available mission.[/color]"
	)

func _system_status() -> void:

	await _type_message("[color=#FF2EAB]SYSTEM DIAGNOSTICS[/color]")
	await _type_message("[color=#00E89B][OK][/color] ECHO Core: ONLINE")
	await _type_message("[color=#00E89B][OK][/color] Terminal: ACTIVE")
	await _type_message("[color=#00E89B][OK][/color] Security: ENABLED")
	await _type_message("[color=#00E89B][OK][/color] Connection: SECURE")

func _player_info() -> void:

	await _type_message("[color=#FF2EAB]OPERATOR INFORMATION[/color]")
	await _type_message("Operator: PLAYER")
	await _type_message("Access level: STANDARD")
	await _type_message("Connection: ACTIVE")
	await _type_message("Mission access: RESTRICTED")

func _open_level(level_number: int) -> void:

	if not level_status.has(level_number):
		await _type_message(
			"[color=#FF3D67]ECHO ERROR: Level does not exist.[/color]"
		)
		return

	var status: String = level_status[level_number]

	if status != "AVAILABLE":

		await _type_message(
			"[color=#FF3D67]ACCESS DENIED[/color]"
		)

		await _type_message(
			"[color=#8B83AC]This mission is currently locked.[/color]"
		)

		return

	await _type_message(
		"[color=#00E89B]ACCESS GRANTED[/color]"
	)

	await _type_message(
		"[color=#8DF7FF]Opening LEVEL %02d...[/color]" % level_number
	)

	await get_tree().create_timer(0.5).timeout

	level_open_requested.emit(level_number)


func _on_hint_button_pressed() -> void:
	$AnimationPlayer.play("hint panel animation")


func _on_hide_button_pressed() -> void:
	$AnimationPlayer.play("hide button animation")
