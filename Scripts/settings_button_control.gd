
extends Control

@onready var left_icon: TextureRect = $"LEFT ICON2"
@onready var right_icon: TextureRect = $"RIGHT ICON2"
@onready var settings_button: Button =  $"Settings Button"

var icon_tween: Tween

const HIDDEN_OFFSET := 12.0
const VISIBLE_OFFSET := 24.0
const HOVER_TIME := 0.22
const PRESS_TIME := 0.08
const PRESS_INWARD_DISTANCE := 30.0

var left_home: Vector2
var right_home: Vector2


func _ready() -> void:
	left_home = left_icon.position
	right_home = right_icon.position

	left_icon.modulate.a = 0.0
	right_icon.modulate.a = 0.0

	left_icon.position = left_home + Vector2(HIDDEN_OFFSET, 0)
	right_icon.position = right_home - Vector2(HIDDEN_OFFSET, 0)

	settings_button.mouse_entered.connect(_on_mouse_entered)
	settings_button.mouse_exited.connect(_on_mouse_exited)
	settings_button.button_down.connect(_on_button_down)
	settings_button.button_up.connect(_on_button_up)


func _animate_icons(show_icons: bool, pressed: bool = false) -> void:
	if icon_tween and icon_tween.is_running():
		icon_tween.kill()

	icon_tween = create_tween()
	icon_tween.set_parallel(true)
	icon_tween.set_trans(Tween.TRANS_SINE)
	icon_tween.set_ease(Tween.EASE_OUT)

	var duration := PRESS_TIME if pressed else HOVER_TIME
	var target_alpha := 1.0 if show_icons else 0.0
	var left_target := left_home + Vector2(HIDDEN_OFFSET, 0)
	var right_target := right_home - Vector2(HIDDEN_OFFSET, 0)
	var target_scale := Vector2.ONE

	if show_icons:
		left_target = left_home - Vector2(VISIBLE_OFFSET, 0)
		right_target = right_home + Vector2(VISIBLE_OFFSET, 0)

	if pressed:
		left_target = left_home + Vector2(PRESS_INWARD_DISTANCE, 0)
		right_target = right_home - Vector2(PRESS_INWARD_DISTANCE, 0)
		target_scale = Vector2(0.85, 0.85)

	icon_tween.tween_property(left_icon, "modulate:a", target_alpha, duration)
	icon_tween.parallel().tween_property(right_icon, "modulate:a", target_alpha, duration)
	icon_tween.parallel().tween_property(left_icon, "position", left_target, duration)
	icon_tween.parallel().tween_property(right_icon, "position", right_target, duration)
	icon_tween.parallel().tween_property(left_icon, "scale", target_scale, duration)
	icon_tween.parallel().tween_property(right_icon, "scale", target_scale, duration)


func _on_mouse_entered() -> void:
	_animate_icons(true)


func _on_mouse_exited() -> void:
	_animate_icons(false)


func _on_button_down() -> void:
	_animate_icons(true, true)


func _on_button_up() -> void:
	if settings_button.is_hovered():
		_animate_icons(true)
	else:
		_animate_icons(false)
