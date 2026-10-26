extends Button


@export var transition_duration: float = 0.18
@export var hover_lift: float = 3.0


var base_position: Vector2
var active_tween: Tween

var normal_bg: Color
var normal_border: Color
var normal_shadow: Color

var hover_bg: Color = Color("#2A1B3D")
var hover_border: Color = Color("#FF55C5")
var hover_shadow: Color = Color("#D900FF")

var pressed_bg: Color = Color("#007C91")
var pressed_border: Color = Color("#8DF7FF")
var pressed_shadow: Color = Color("#00E5FF")


var current_style: StyleBoxFlat

func _ready() -> void:
	base_position = position
	
	var original := get_theme_stylebox("normal") as StyleBoxFlat
	
	current_style = original.duplicate() as StyleBoxFlat
	add_theme_stylebox_override("normal", current_style)
	add_theme_stylebox_override("hover", current_style)
	add_theme_stylebox_override("pressed", current_style)
	
	
	normal_bg = current_style.bg_color
	normal_border = current_style.border_color
	normal_shadow = current_style.shadow_color
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	
func animate_state(bg: Color, border: Color, shadow: Color, target_y: float) -> void:
		if current_style == null:
			return
	
		if active_tween and active_tween.is_running():
			active_tween.kill()
		
		
		active_tween = create_tween()
		active_tween.set_parallel(true)
		active_tween.set_trans(Tween.TRANS_CUBIC)
		active_tween.set_ease(Tween.EASE_IN_OUT)
		
		
		active_tween.tween_property(current_style, "bg_color", bg, transition_duration)
		active_tween.tween_property(current_style, "border_color", border, transition_duration)
		active_tween.tween_property(current_style, "shadow_color", shadow, transition_duration)
		active_tween.tween_property(self, "position:y", target_y, transition_duration)
		
func _on_mouse_entered() -> void:
			if not button_pressed:
				animate_state(normal_bg, normal_border, normal_shadow, base_position.y - hover_lift)
func _on_mouse_exited() -> void:
			if not button_pressed:
				animate_state(normal_bg, normal_border, normal_shadow, base_position.y)
func _on_button_down() -> void:
				animate_state(pressed_bg, pressed_border, pressed_shadow, base_position.y + 1.0)
func _on_button_up() -> void:
	if is_hovered():
		animate_state(hover_bg, hover_border, hover_shadow, base_position.y - hover_lift)
	else:
		animate_state(normal_bg, normal_border, normal_shadow, base_position.y)
