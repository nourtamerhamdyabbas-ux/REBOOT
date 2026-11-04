extends Control

@export var difficulty_level: int = 3
@export var target_progress: float = 37.0
@export var animation_duration: float = 0.5

@onready var progress_bar: ProgressBar = $"Main level page panel/main level page panel/Echo Diagnostics Panel3/ProgressBar"
@onready var percentage: Label = $"Main level page panel/main level page panel/Echo Diagnostics Panel3/Percentage Label"

func _ready() -> void:
	animate_progress()

func animate_progress() -> void:
	progress_bar.value = 0
	percentage.text = "0%"

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_method(update_progress, 0.0, target_progress, 1.8)

	await tween.finished

func update_progress(value: float) -> void:
	progress_bar.value = value
	percentage.text = str(roundi(value)) + "%"
