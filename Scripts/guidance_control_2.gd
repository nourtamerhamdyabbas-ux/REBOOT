extends Control

@export_group("Guidance Text")
@export var guidance_title: String = "ECHO // GUIDANCE SYSTEM"
@export_multiline var guidance_message: String = "TO INITIALIZE THE ECHO TERMINAL, PRESS THE POWER ON BUTTON BELOW. IF YOU REQUIRE ASSISTANCE WITH TERMINAL COMMANDS, SELECT THE COMMAND HELP BUTTON LOCATED BESIDE THE TERMINAL."

@export_group("Typing Animation")
@export var typing_speed: float = 0.035
@export var title_typing_speed: float = 0.05
@export var start_delay: float = 2.6

@export_group("Voice Settings")
@export var enable_guidance_voice: bool = true
@export var stop_voice_on_replay: bool = true

@onready var title_label: Label = $"Guidance message Panel/title guidance message Label"
@onready var guidance_label: Label = $"Guidance message Panel/core guidance message Label2"

var guidance_session: int = 0


func _ready() -> void:
	title_label.text = guidance_title
	guidance_label.text = guidance_message

	title_label.visible_characters = 0
	guidance_label.visible_characters = 0

	await get_tree().create_timer(start_delay).timeout

	if not is_inside_tree():
		return

	await play_title_animation()

	if not is_inside_tree():
		return

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
	guidance_session += 1
	var current_session := guidance_session

	guidance_label.visible_characters = 0
	if enable_guidance_voice:
		EchoVoice.speak(guidance_message)

	var character_count := guidance_message.length()
	var tween := create_tween()

	tween.tween_property(
		guidance_label,
		"visible_characters",
		character_count,
		character_count * typing_speed
	).set_trans(Tween.TRANS_LINEAR)

	await tween.finished

	if current_session != guidance_session:
		return


func replay_guidance() -> void:
	guidance_session += 1

	if stop_voice_on_replay:
		EchoVoice.stop_speaking()

	title_label.visible_characters = 0
	guidance_label.visible_characters = 0

	await play_title_animation()
	await play_typing_animation()


func show_complete_message() -> void:
	guidance_session += 1

	title_label.visible_characters = -1
	guidance_label.visible_characters = -1


func stop_guidance_voice() -> void:
	EchoVoice.stop_speaking()
