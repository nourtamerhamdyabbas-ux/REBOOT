extends Control

@onready var message_panel = $"Message Panel"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_first_appearance_button_pressed() -> void:
	$SFX/SFXClickPlayer.play()
	$AnimationPlayer.play("press appearance button anim")

func _on_message_show_button_pressed() -> void:
	message_panel.open_panel()
	$SFX/SFXClickPlayer.play()

func _on_leave_button_pressed() -> void:
	$QuitpopPanel.show()
	$DarkQuit.show()
	$AnimationPlayer.play("quitanimation")
	$SFX/SFXClickPlayer.play()
func _on_disconnect_button_pressed() -> void:
	$SFX/SFXClickPlayer.play()
	get_tree().quit()

func _on_not_yet_button_pressed() -> void:
	$QuitpopPanel.hide()
	$DarkQuit.hide()
	$SFX/SFXClickPlayer.play()

func _on_start_button_pressed() -> void:
	LoadingScreen.change_scene("res://Scenes/levels.tscn")
	$SFX/SFXClickPlayer.play()



func _on_settings_button_pressed() -> void:
	$SFX/SFXClickPlayer.play()
	LoadingScreen.change_scene("res://Scenes/settings.tscn")

func _on_guide_button_pressed() -> void:
	$SFX/SFXClickPlayer.play()
	LoadingScreen.change_scene("res://Scenes/guide.tscn")
func _on_credits_button_pressed() -> void:
	$SFX/SFXClickPlayer.play()
	LoadingScreen.change_scene("res://Scenes/credits.tscn")
func _on_previous_button_pressed() -> void:
	$SFX/SFXClickPlayer.play()

func _on_next_button_pressed() -> void:
	$SFX/SFXClickPlayer.play()
