extends Control
@onready var credits_text: RichTextLabel = $RichTextLabel
@onready var skip_button: Button = $"Back button"
@export var scroll_speed: float = 35.0
var scrolling := false
func _ready() -> void:
	skip_button.pressed.connect(_on_skip_pressed)
	await get_tree().process_frame
	credits_text.position.y = size.y
	scrolling = true
func _process(delta: float) -> void:
	if not scrolling:
		return
	credits_text.position.y -= scroll_speed * delta
	if credits_text.position.y + credits_text.size.y < 0:
		scrolling = false
func _on_skip_pressed() -> void:
	scrolling = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
