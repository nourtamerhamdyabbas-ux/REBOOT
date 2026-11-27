extends Node

var voice_id: String = ""
var voice_enabled: bool = true

var voice_volume: int = 100
var voice_pitch: float = 1.0
var voice_rate: float = 1.5


func _ready() -> void:
	var voices: PackedStringArray = DisplayServer.tts_get_voices_for_language("en")

	if not voices.is_empty():
		voice_id = voices[0]
		print("ECHO VOICE INITIALIZED: ", voice_id)
	else:
		push_warning("ECHO: No English TTS voices found.")


func speak(message: String) -> void:
	if not voice_enabled or voice_id.is_empty():
		return

	var clean_message := remove_bbcode(message).strip_edges()

	if clean_message.is_empty():
		return
	DisplayServer.tts_speak(
		clean_message,
		voice_id,
		voice_volume,
		voice_pitch,
		voice_rate,
		0,
		false
	)


func speak_batch(messages: PackedStringArray) -> void:
	var combined_message := " ".join(messages)
	speak(combined_message)


func remove_bbcode(message: String) -> String:
	var regex := RegEx.new()
	regex.compile("\\[/?[a-zA-Z][^\\]]*\\]")
	return regex.sub(message, "", true)


func stop_speaking() -> void:
	DisplayServer.tts_stop()


func set_voice_enabled(enabled: bool) -> void:
	voice_enabled = enabled

	if not voice_enabled:
		stop_speaking()


func set_voice_rate(rate: float) -> void:
	voice_rate = clampf(rate, 0.1, 10.0)


func set_voice_volume(volume: int) -> void:
	voice_volume = clampi(volume, 0, 100)


func set_voice_pitch(pitch: float) -> void:
	voice_pitch = clampf(pitch, 0.0, 2.0)
