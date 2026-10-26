
extends Control



@onready var header_label: Label = $"message panel main header"
@onready var subtitle_label: Label = $"SubTitle for the panel main header"
@onready var space_bar_color_panel: Panel = $"Space bar color Panel"
@onready var online_panel: Control = $OnlinePanel
@onready var title_label: Label = $"Message main Label"
@onready var message_label: Label = $"Core Message Label"
@onready var counter_label: Label = $"Counting message Label"

@onready var previous_button: Button = $PreviousButton
@onready var next_button: Button = $NextButton



const TYPE_SPEED: float = 0.025

const OPEN_DURATION: float = 0.35
const CLOSE_DURATION: float = 0.20

const CLOSED_SCALE: Vector2 = Vector2(0.88, 0.88)

var current_message: int = 0
var typing: bool = false

var typing_tween: Tween
var panel_tween: Tween




var conversation: Array[Dictionary] = [
	{
		"speaker": "SECURE CHANNEL // 01",
		"title": "CONNECTION ESTABLISHED",
		"message": "Hello, Player. This is ECHO, your onboard system assistant. I've detected an unusual signal nearby, and I need your help investigating it."
	},
	{
		"speaker": "SECURE CHANNEL // 02",
		"title": "A STRANGE SIGNAL",
		"message": "An unknown transmission has appeared on my sensors. Its origin is hidden, and I cannot identify its source."
	},
	{
		"speaker": "SECURE CHANNEL // 03",
		"title": "YOUR MISSION",
		"message": "I need you to investigate the signal. Explore the area, overcome the obstacles, and discover what is waiting for you."
	},
	{
		"speaker": "SECURE CHANNEL // 04",
		"title": "UNSTABLE CONNECTION",
		"message": "The signal is interfering with my systems. Stay alert, Player. There may be more to this transmission than we understand."
	},
	{
		"speaker": "SECURE CHANNEL // 05",
		"title": "READY TO BEGIN?",
		"message": "All systems are ready. I'll be here if you need me. Your adventure begins when you are ready."
	}
]




func _ready() -> void:
	hide()

	pivot_offset = size / 2.0

	scale = CLOSED_SCALE
	modulate.a = 0.0

	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	previous_button.pressed.connect(_on_previous_pressed)
	next_button.pressed.connect(_on_next_pressed)

	resized.connect(_update_pivot)


func _update_pivot() -> void:
	pivot_offset = size / 2.0




func open_panel() -> void:
	if panel_tween and panel_tween.is_running():
		panel_tween.kill()

	if typing_tween and typing_tween.is_running():
		typing_tween.kill()

	typing = false

	show()

	current_message = 0

	scale = CLOSED_SCALE
	modulate.a = 0.0
	pivot_offset = size / 2.0

	show_message()

	panel_tween = create_tween()
	panel_tween.set_parallel(true)

	panel_tween.tween_property(
		self,
		"modulate:a",
		1.0,
		OPEN_DURATION
	)

	panel_tween.tween_property(
		self,
		"scale",
		Vector2.ONE,
		OPEN_DURATION
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)




func show_message() -> void:
	var data: Dictionary = conversation[current_message]

	subtitle_label.text = str(data["speaker"])
	title_label.text = str(data["title"])

	counter_label.text = "MESSAGE %02d / %02d" % [
		current_message + 1,
		conversation.size()
	]

	previous_button.disabled = current_message == 0

	if current_message == conversation.size() - 1:
		next_button.text = "FINISH >>"
	else:
		next_button.text = "NEXT >>"

	type_message(str(data["message"]))




func type_message(text_to_type: String) -> void:
	if typing_tween and typing_tween.is_running():
		typing_tween.kill()

	message_label.text = text_to_type
	message_label.visible_characters = 0

	typing = true

	typing_tween = create_tween()

	var duration: float = maxf(
		float(text_to_type.length()) * TYPE_SPEED,
		0.1
	)

	typing_tween.tween_property(
		message_label,
		"visible_characters",
		text_to_type.length(),
		duration
	)

	typing_tween.finished.connect(_on_typing_finished)


func _on_typing_finished() -> void:
	typing = false
	message_label.visible_characters = -1


func finish_typing() -> void:
	if typing_tween and typing_tween.is_running():
		typing_tween.kill()

	message_label.visible_characters = -1
	typing = false




func _on_previous_pressed() -> void:
	if typing:
		finish_typing()
		return

	if current_message > 0:
		current_message -= 1
		show_message()




func _on_next_pressed() -> void:
	if typing:
		finish_typing()
		return

	if current_message < conversation.size() - 1:
		current_message += 1
		show_message()
	else:
		close_panel()




func close_panel() -> void:
	if typing_tween and typing_tween.is_running():
		typing_tween.kill()

	typing = false

	if panel_tween and panel_tween.is_running():
		panel_tween.kill()

	panel_tween = create_tween()
	panel_tween.set_parallel(true)

	panel_tween.tween_property(
		self,
		"modulate:a",
		0.0,
		CLOSE_DURATION
	)

	panel_tween.tween_property(
		self,
		"scale",
		CLOSED_SCALE,
		CLOSE_DURATION
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	panel_tween.chain().tween_callback(hide)
