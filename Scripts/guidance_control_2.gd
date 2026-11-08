extends Control

@export_group("Guidance Text")
@export var guidance_title: String = "ECHO // GUIDANCE SYSTEM"
@export_multiline var guidance_message: String = "HI, OPERATOR. I AM ECHO, YOUR IN-GAME GUIDANCE SYSTEM. I'M HERE TO HELP YOU NAVIGATE THE GAME AND OPERATE ITS SYSTEMS. TO ACCESS THE MAIN MENU, PRESS THE BUTTON BELOW."

@export_group("Typing Animation")
@export var typing_speed: float = 0.035
@export var title_typing_speed: float = 0.05
@export var start_delay: float = 2.6

@onready var title_label: Label = $"Guidance message Panel/title guidance message Label"
@onready var guidance_label: Label = $"Guidance message Panel/core guidance message Label2"


func _ready() -> void:
	title_label.text = guidance_title
	guidance_label.text = guidance_message

	title_label.visible_characters = 0
	guidance_label.visible_characters = 0

	await get_tree().create_timer(start_delay).timeout

	await play_title_animation()
	await play_typing_animation()


func play_title_animation() -> void:
	title_label.visible_characters = 0

	var character_count := guidance_title.length()
	var tween := create_tween()

	tween.tween_property(
		title_label,
		"visible_characters",
		character_count,
		character_count * title_typing_speed
	).set_trans(Tween.TRANS_LINEAR)

	await tween.finished


func play_typing_animation() -> void:
	guidance_label.visible_characters = 0

	var character_count := guidance_message.length()
	var tween := create_tween()

	tween.tween_property(
		guidance_label,
		"visible_characters",
		character_count,
		character_count * typing_speed
	).set_trans(Tween.TRANS_LINEAR)

	await tween.finished


func replay_guidance() -> void:
	title_label.visible_characters = 0
	guidance_label.visible_characters = 0

	await play_title_animation()
	await play_typing_animation()


func show_complete_message() -> void:
	title_label.visible_characters = -1
	guidance_label.visible_characters = -1
