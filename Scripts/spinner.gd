extends Control

@export var radius: float = 38.0
@export var line_width: float = 4.0
@export var rotation_speed: float = 2.5

var current_angle: float = 0.0


func _process(delta: float) -> void:
	current_angle = wrapf(current_angle + rotation_speed * delta, 0.0, TAU)
	queue_redraw()


func _draw() -> void:
	var center := size / 2.0

	draw_arc(
		center,
		radius,
		0.0,
		TAU,
		64,
		Color("#49316D"),
		line_width,
		true
	)

	draw_arc(
		center,
		radius,
		current_angle,
		current_angle + TAU * 0.72,
		64,
		Color("#8DF7FF"),
		line_width,
		true
	)
