extends Control

@onready var message_panel = $"Message Panel"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_first_appearance_button_pressed() -> void:
	$AnimationPlayer.play("press appearance button anim")


func _on_message_show_button_pressed() -> void:
	message_panel.open_panel()


func _on_leave_button_pressed() -> void:
	$QuitpopPanel.show()
	$DarkQuit.show()
	$AnimationPlayer.play("quitanimation")

func _on_disconnect_button_pressed() -> void:
	get_tree().quit()

func _on_not_yet_button_pressed() -> void:
	$QuitpopPanel.hide()
	$DarkQuit.hide()
