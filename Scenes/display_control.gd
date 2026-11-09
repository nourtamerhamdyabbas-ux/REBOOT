extends Control

@onready var resolution_option: OptionButton = $ResolutionOption
@onready var display_mode_option: OptionButton = $DisplayModeOption

@onready var brightness_slider: HSlider = $BrightnessSlider
@onready var brightness_value: Label = $BrightnessValue

@onready var vsync_button: CheckButton = $VSyncCheckButton

const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080)
]

const DEFAULT_BRIGHTNESS: float = 75.0

var changing_resolution: bool = false

func _ready() -> void:

	_setup_resolution_options()
	_setup_display_modes()
	_setup_brightness()
	_setup_vsync()

	_style_option_popup(resolution_option)
	_style_option_popup(display_mode_option)

	resolution_option.item_selected.connect(_on_resolution_selected)
	display_mode_option.item_selected.connect(_on_display_mode_selected)

	brightness_slider.value_changed.connect(_on_brightness_changed)
	vsync_button.toggled.connect(_on_vsync_toggled)

func _style_option_popup(option: OptionButton) -> void:

	option.add_theme_font_size_override("font_size", 20)

	option.add_theme_color_override(
		"font_color",
		Color("#8DF7FF")
	)

	var popup: PopupMenu = option.get_popup()

	popup.add_theme_font_size_override("font_size", 18)

	popup.add_theme_color_override(
		"font_color",
		Color("#F7FCFF")
	)

	popup.add_theme_color_override(
		"font_hover_color",
		Color("#8DF7FF")
	)

	popup.add_theme_color_override(
		"font_disabled_color",
		Color("#8B83AC")
	)

	var panel_style := StyleBoxFlat.new()

	panel_style.bg_color = Color("#160D30")
	panel_style.border_color = Color("#49316D")

	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(8)

	panel_style.content_margin_left = 12
	panel_style.content_margin_right = 12
	panel_style.content_margin_top = 8
	panel_style.content_margin_bottom = 8

	popup.add_theme_stylebox_override(
		"panel",
		panel_style
	)

	var hover_style := StyleBoxFlat.new()

	hover_style.bg_color = Color("#49316D")
	hover_style.set_corner_radius_all(5)

	popup.add_theme_stylebox_override(
		"hover",
		hover_style
	)

	popup.add_theme_constant_override(
		"v_separation",
		5
	)

func _setup_resolution_options() -> void:

	resolution_option.clear()

	for resolution in RESOLUTIONS:

		resolution_option.add_item(
			"%d × %d" % [resolution.x, resolution.y]
		)

	var window := get_window()

	var current_size: Vector2i = window.content_scale_size

	if current_size.x <= 0 or current_size.y <= 0:
		current_size = Vector2i(1920, 1080)

	var selected_index := RESOLUTIONS.find(current_size)

	if selected_index == -1:
		selected_index = 2

	resolution_option.select(selected_index)


func _on_resolution_selected(index: int) -> void:

	if changing_resolution:
		return

	if index < 0 or index >= RESOLUTIONS.size():
		return

	changing_resolution = true

	var selected_resolution: Vector2i = RESOLUTIONS[index]

	var window := get_window()

	window.content_scale_size = selected_resolution

	await get_tree().process_frame

	changing_resolution = false

func _setup_display_modes() -> void:

	display_mode_option.clear()

	display_mode_option.add_item("Windowed")
	display_mode_option.add_item("Fullscreen")

	var current_mode := DisplayServer.window_get_mode()

	if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN \
	or current_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:

		display_mode_option.select(1)

	else:

		display_mode_option.select(0)


func _on_display_mode_selected(index: int) -> void:

	match index:

		0:
			DisplayServer.window_set_mode(
				DisplayServer.WINDOW_MODE_WINDOWED
			)

		1:
			DisplayServer.window_set_mode(
				DisplayServer.WINDOW_MODE_FULLSCREEN
			)

func _setup_brightness() -> void:

	brightness_slider.min_value = 0
	brightness_slider.max_value = 100
	brightness_slider.step = 1
	brightness_slider.value = DEFAULT_BRIGHTNESS

	_apply_brightness(brightness_slider.value)


func _on_brightness_changed(value: float) -> void:

	_apply_brightness(value)


func _apply_brightness(value: float) -> void:

	brightness_value.text = "%d%%" % roundi(value)

	Brightness.set_brightness(value)

func _setup_vsync() -> void:

	var current_vsync := DisplayServer.window_get_vsync_mode()

	vsync_button.button_pressed = (
		current_vsync != DisplayServer.VSYNC_DISABLED
	)


func _on_vsync_toggled(enabled: bool) -> void:

	if enabled:

		DisplayServer.window_set_vsync_mode(
			DisplayServer.VSYNC_ENABLED
		)

	else:

		DisplayServer.window_set_vsync_mode(
			DisplayServer.VSYNC_DISABLED
		)
