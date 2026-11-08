extends Node
@onready var overlay: ColorRect = $CanvasLayer/ColorRect
const MAX_DARKNESS: float = 0.65
func _ready() -> void:
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.visible = true
	set_brightness(75.0)
func set_brightness(value: float) -> void:
	var darkness: float = (
		1.0 - clampf(value, 0.0, 100.0) / 100.0) * MAX_DARKNESS
	overlay.color = Color(0.0, 0.0, 0.0, darkness)
