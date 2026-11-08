extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_audio_button_pressed() -> void:
	$SFX/SFXClickPlayer.play()

func _on_display_button_pressed() -> void:
	$SFX/SFXClickPlayer.play()
