extends Control

# ==========================================
# CYBERPUNK TYPEWRITER ANIMATION
# GODOT 4.x
# ANIMATION ONLY
# ==========================================

@export var typing_speed: float = 0.035
@export var delay_between_labels: float = 0.15
@export var start_delay: float = 1.0

@export var animate_all_labels: bool = true
@export var animate_rich_text: bool = true

var label_list: Array[Node] = []
var animation_tweens: Array[Tween] = []


# ==========================================
# READY
# ==========================================

func _ready() -> void:

	# IMPORTANT:
	# Hide ALL text immediately when the scene opens.
	_prepare_all_text()

	# Wait before starting the animation.
	await get_tree().create_timer(start_delay).timeout

	# Start typing animation.
	if animate_all_labels:
		await _play_typewriter()


# ==========================================
# PREPARE TEXT
# HIDE ALL CHARACTERS IMMEDIATELY
# ==========================================

func _prepare_all_text() -> void:

	label_list.clear()

	# Find all ordinary Labels.
	var labels := find_children("*", "Label", true, false)

	for node in labels:

		if not is_instance_valid(node):
			continue

		if node.is_in_group("skip_typing"):
			continue

		label_list.append(node)

		# Hide the text, NOT the Label node.
		node.visible_characters = 0


	# Find all RichTextLabels separately.
	if animate_rich_text:

		var rich_labels := find_children(
			"*",
			"RichTextLabel",
			true,
		 false
		)

		for node in rich_labels:

			if not is_instance_valid(node):
				continue

			if node.is_in_group("skip_typing"):
				continue

			label_list.append(node)

			# Hide RichText text immediately.
			node.visible_characters = 0


# ==========================================
# TYPEWRITER ANIMATION
# ==========================================

func _play_typewriter() -> void:

	for node in label_list:

		if not is_instance_valid(node):
			continue

		var character_count: int = 0

		# Get Label character count.
		if node is Label:

			character_count = node.text.length()

		# Get RichTextLabel character count.
		elif node is RichTextLabel:

			character_count = (
				node.get_total_character_count()
			)

		if character_count <= 0:
			continue

		# Make sure the text starts hidden.
		node.visible_characters = 0

		# Calculate typing duration.
		var duration: float = (
			character_count * typing_speed
		)

		# Animate characters appearing.
		var tween := create_tween()

		tween.tween_property(
			node,
			"visible_characters",
			character_count,
			duration
		)

		animation_tweens.append(tween)

		# Wait until THIS label finishes typing.
		await tween.finished

		# Small pause before the next label.
		await get_tree().create_timer(
			delay_between_labels
		).timeout


# ==========================================
# RESET ANIMATION
# CALL TO REPLAY THE TYPING EFFECT
# ==========================================

func replay_typewriter() -> void:

	for node in label_list:

		if not is_instance_valid(node):
			continue

		node.visible_characters = 0

	await get_tree().create_timer(0.3).timeout

	await _play_typewriter()


# ==========================================
# SHOW ALL TEXT INSTANTLY
# ==========================================

func show_all_text() -> void:

	for node in label_list:

		if not is_instance_valid(node):
			continue

		node.visible_characters = -1


# ==========================================
# STOP ANIMATIONS
# ==========================================

func stop_all_animations() -> void:

	for tween in animation_tweens:

		if is_instance_valid(tween):
			tween.kill()

	animation_tweens.clear()
func _on_footer_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/levels.tscn")
