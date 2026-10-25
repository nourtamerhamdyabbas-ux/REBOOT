extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	$"../AnimationPlayer".play("press appearance button anim")
	await $"../AnimationPlayer".animation_finished
	$"../AnimationPlayer".play("After press main menu animation")
	
	visible = false
	disabled = true
