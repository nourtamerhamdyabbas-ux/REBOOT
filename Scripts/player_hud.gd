extends CanvasLayer

@onready var hp_margin_container: MarginContainer = %HPMarginContainer
@onready var hp_bar: TextureProgressBar = %HPBar

@onready var game_over: Control = $Control/GameOver
@onready var main_menu_button: Button = $Control/GameOver/HBoxContainer/MainMenuButton
@onready var replay_button: Button = $Control/GameOver/HBoxContainer/ReplayButton




func _ready() -> void:
	Messsages.player_health_changed.connect(update_health_bar)
	game_over.visible = false
	replay_button.pressed.connect(_on_replay_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	pass


func update_health_bar(hp: float, max_hp: float)->void:
	var value: float = (hp/max_hp)*100
	hp_bar.value = value
	hp_margin_container.size.x = max_hp + 22
	
	pass

func show_game_over()->void:
	main_menu_button.visible = false
	replay_button.visible = false
	game_over.modulate.a = 0
	game_over.visible = true
	
	var tween: Tween = create_tween()
	tween.tween_property(game_over,"modulate",Color.WHITE, 3.0)
	await tween.finished
	replay_button.visible = true
	main_menu_button.visible = true
	replay_button.grab_focus()
	pass


func clear_game_over()->void:
	main_menu_button.visible = false
	replay_button.visible = false
	#await (loading scene)
	game_over.visible = false
	var player: Player = get_tree().get_first_node_in_group("Player") 
	player.queue_free()
	pass









func _on_replay_pressed()->void:
	#replay the game
	clear_game_over()
	pass

func _on_main_menu_pressed()->void:
	#go to main menu
	clear_game_over()
	pass
