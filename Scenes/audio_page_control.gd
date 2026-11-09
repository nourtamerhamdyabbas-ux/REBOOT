
extends Control

@onready var master_slider: HSlider = $MasterVolumeSlider
@onready var master_value: Label = $MasterVolumeValue

@onready var music_slider: HSlider = $MusicVolumeSlider
@onready var music_value: Label = $MusicVolumeValue

@onready var sfx_slider: HSlider = $SFXVolumeSlider
@onready var sfx_value: Label = $SFXVolumeValue

@onready var mute_button: CheckButton = $MuteCheckButton


func _ready() -> void:

	master_slider.min_value = 0
	master_slider.max_value = 100
	master_slider.step = 1

	music_slider.min_value = 0
	music_slider.max_value = 100
	music_slider.step = 1

	sfx_slider.min_value = 0
	sfx_slider.max_value = 100
	sfx_slider.step = 1

	master_slider.value = 100
	music_slider.value = 80
	sfx_slider.value = 100

	master_slider.value_changed.connect(_on_master_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)

	mute_button.toggled.connect(_on_mute_changed)

	_update_labels()

	_apply_volume("Master", master_slider.value)
	_apply_volume("Music", music_slider.value)
	_apply_volume("SFX", sfx_slider.value)


func _update_labels() -> void:

	master_value.text = "%d%%" % roundi(master_slider.value)
	music_value.text = "%d%%" % roundi(music_slider.value)
	sfx_value.text = "%d%%" % roundi(sfx_slider.value)


func _on_master_changed(value: float) -> void:

	master_value.text = "%d%%" % roundi(value)
	_apply_volume("Master", value)


func _on_music_changed(value: float) -> void:

	music_value.text = "%d%%" % roundi(value)
	_apply_volume("Music", value)


func _on_sfx_changed(value: float) -> void:

	sfx_value.text = "%d%%" % roundi(value)
	_apply_volume("SFX", value)


func _apply_volume(bus_name: String, value: float) -> void:

	var index := AudioServer.get_bus_index(bus_name)

	if index == -1:
		push_warning("Missing audio bus: " + bus_name)
		return

	var volume_db := -80.0

	if value > 0:
		volume_db = linear_to_db(value / 100.0)

	AudioServer.set_bus_volume_db(index, volume_db)


func _on_mute_changed(enabled: bool) -> void:

	var index := AudioServer.get_bus_index("Master")

	if index != -1:
		AudioServer.set_bus_mute(index, enabled)
