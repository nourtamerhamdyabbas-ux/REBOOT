extends Control

var audio_button: Button
var display_button: Button
var audio_page: Control
var display_page: Control
var back_button: Button
var reset_button: Button
var apply_button: Button

const DEFAULT_MASTER_VOLUME := 100.0
const DEFAULT_MUSIC_VOLUME := 80.0
const DEFAULT_SFX_VOLUME := 100.0
const DEFAULT_RESOLUTION_INDEX := 2
const DEFAULT_BRIGHTNESS := 75.0
const DEFAULT_VSYNC := true


func _ready() -> void:
	audio_button = find_child("AudioButton", true, false) as Button
	display_button = find_child("Display Button", true, false) as Button

	audio_page = find_child("Audio page Control", true, false) as Control
	display_page = find_child("Display Control", true, false) as Control

	back_button = find_child("Back button", true, false) as Button
	reset_button = find_child("Reset button", true, false) as Button
	apply_button = find_child("Apply button", true, false) as Button

	if not _check_nodes():
		return

	audio_button.pressed.connect(_show_audio_page)
	display_button.pressed.connect(_show_display_page)
	back_button.pressed.connect(_on_back_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	apply_button.pressed.connect(_on_apply_pressed)

	_show_audio_page()


func _check_nodes() -> bool:
	var nodes := [
		audio_button,
		display_button,
		audio_page,
		display_page,
		back_button,
		reset_button,
		apply_button
	]

	for node in nodes:
		if node == null:
			push_error("Settings: A required node was not found. Check the node names.")
			return false

	return true


func _show_audio_page() -> void:
	audio_page.visible = true
	display_page.visible = false
	$SFX/SFXClickPlayer.play()


func _show_display_page() -> void:
	audio_page.visible = false
	display_page.visible = true
	$SFX/SFXClickPlayer.play()


func _on_apply_pressed() -> void:
	_apply_audio_settings()
	_apply_display_settings()

	print("ECHO // SETTINGS APPLIED")

	$SFX/SFXClickPlayer.play()
	$"Saved changes Panel".show()
	$AnimationPlayer.play("apply animation")


func _apply_audio_settings() -> void:
	var master := find_child("MasterVolumeSlider", true, false) as HSlider
	var music := find_child("MusicVolumeSlider", true, false) as HSlider
	var sfx := find_child("SFXVolumeSlider", true, false) as HSlider
	var mute := find_child("MuteCheckButton", true, false) as CheckButton

	if master:
		_set_bus_volume("Master", master.value)

	if music:
		_set_bus_volume("Music", music.value)

	if sfx:
		_set_bus_volume("SFX", sfx.value)

	var master_index := AudioServer.get_bus_index("Master")

	if master_index != -1 and mute:
		AudioServer.set_bus_mute(master_index, mute.button_pressed)


func _set_bus_volume(bus_name: String, value: float) -> void:
	var index := AudioServer.get_bus_index(bus_name)

	if index == -1:
		push_warning("Missing audio bus: " + bus_name)
		return

	AudioServer.set_bus_volume_db(
		index,
		linear_to_db(value / 100.0) if value > 0.0 else -80.0
	)


func _apply_display_settings() -> void:
	var resolution := find_child("ResolutionOption", true, false) as OptionButton
	var brightness := find_child("BrightnessSlider", true, false) as HSlider
	var vsync := find_child("VSyncCheckButton", true, false) as CheckButton

	var resolutions: Array[Vector2i] = [
		Vector2i(1280, 720),
		Vector2i(1600, 900),
		Vector2i(1920, 1080)
	]

	var window := get_window()
	window.mode = Window.MODE_FULLSCREEN

	if resolution:
		var index := resolution.selected
		if index >= 0 and index < resolutions.size():
			window.content_scale_size = resolutions[index]

	if brightness:
		Brightness.set_brightness(brightness.value)

	if vsync:
		DisplayServer.window_set_vsync_mode(
			DisplayServer.VSYNC_ENABLED if vsync.button_pressed
			else DisplayServer.VSYNC_DISABLED
		)


func _on_reset_pressed() -> void:
	var master := find_child("MasterVolumeSlider", true, false) as HSlider
	var music := find_child("MusicVolumeSlider", true, false) as HSlider
	var sfx := find_child("SFXVolumeSlider", true, false) as HSlider
	var mute := find_child("MuteCheckButton", true, false) as CheckButton
	var resolution := find_child("ResolutionOption", true, false) as OptionButton
	var brightness := find_child("BrightnessSlider", true, false) as HSlider
	var vsync := find_child("VSyncCheckButton", true, false) as CheckButton

	$SFX/SFXClickPlayer.play()
	$"Reset changes Panel".show()
	$AnimationPlayer.play("reset animation")

	if master:
		master.value = DEFAULT_MASTER_VOLUME

	if music:
		music.value = DEFAULT_MUSIC_VOLUME

	if sfx:
		sfx.value = DEFAULT_SFX_VOLUME

	if mute:
		mute.button_pressed = false

	if resolution:
		resolution.select(DEFAULT_RESOLUTION_INDEX)

	if brightness:
		brightness.value = DEFAULT_BRIGHTNESS

	if vsync:
		vsync.button_pressed = DEFAULT_VSYNC

	_update_value_labels()
	_apply_audio_settings()
	_apply_display_settings()

	print("ECHO // DEFAULT SETTINGS RESTORED")


func _update_value_labels() -> void:
	var master := find_child("MasterVolumeSlider", true, false) as HSlider
	var music := find_child("MusicVolumeSlider", true, false) as HSlider
	var sfx := find_child("SFXVolumeSlider", true, false) as HSlider
	var brightness := find_child("BrightnessSlider", true, false) as HSlider

	var master_value := find_child("MasterVolumeValue", true, false) as Label
	var music_value := find_child("MusicVolumeValue", true, false) as Label
	var sfx_value := find_child("SFXVolumeValue", true, false) as Label
	var brightness_value := find_child("BrightnessValue", true, false) as Label

	if master and master_value:
		master_value.text = "%d%%" % roundi(master.value)

	if music and music_value:
		music_value.text = "%d%%" % roundi(music.value)

	if sfx and sfx_value:
		sfx_value.text = "%d%%" % roundi(sfx.value)

	if brightness and brightness_value:
		brightness_value.text = "%d%%" % roundi(brightness.value)


func _on_back_pressed() -> void:
	$SFX/SFXClickPlayer.play()
	LoadingScreen.change_scene("res://Scenes/main_menu.tscn")
func _on_v_sync_check_button_pressed() -> void:
	$SFX/SFXClickPlayer.play()
func _on_display_mode_option_pressed() -> void:
	$SFX/SFXClickPlayer.play()
func _on_display_mode_option_item_selected(index: int) -> void:
	$SFX/SFXClickPlayer.play()
func _on_resolution_option_pressed() -> void:
	$SFX/SFXClickPlayer.play()
func _on_resolution_option_item_selected(index: int) -> void:
	$SFX/SFXClickPlayer.play()
