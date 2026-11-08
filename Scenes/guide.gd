extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_movement_button_pressed() -> void:
	$AnimationPlayer.play("movement animation")
	$SFX/SFXClickPlayer.play()



func _on_dash_button_pressed() -> void:
	$AnimationPlayer.play("dash animation")
	$SFX/SFXClickPlayer.play()
	



func _on_jump_button_pressed() -> void:
	$AnimationPlayer.play("jump animation")
	$SFX/SFXClickPlayer.play()
	



func _on_attack_button_pressed() -> void:
	$AnimationPlayer.play("attack animation")
	$SFX/SFXClickPlayer.play()




func _on_back_button_pressed() -> void:
	$SFX/SFXClickPlayer.play()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
