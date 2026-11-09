extends CanvasLayer

@onready var loading_label: Label = $CenterContainer/LoadingVBox/LoadingLabel
@onready var progress_bar: ProgressBar = $CenterContainer/LoadingVBox/ProgressBar

var is_loading: bool = false


func _ready() -> void:
	layer = 100
	hide()

	progress_bar.min_value = 0
	progress_bar.max_value = 100
	progress_bar.value = 0

	loading_label.text = "ECHO // LOADING SYSTEM..."


func change_scene(scene_path: String) -> void:
	if is_loading:
		return

	is_loading = true

	show()

	loading_label.text = "ECHO // LOADING SYSTEM..."
	progress_bar.value = 0

	await get_tree().process_frame

	var error := ResourceLoader.load_threaded_request(scene_path)

	if error != OK:
		push_error("ECHO // FAILED TO REQUEST SCENE: " + scene_path)
		hide()
		is_loading = false
		return

	var progress: Array = []
	var status := ResourceLoader.load_threaded_get_status(
		scene_path,
		progress
	)

	while status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		if not progress.is_empty():
			progress_bar.value = progress[0] * 100.0

		await get_tree().process_frame

		status = ResourceLoader.load_threaded_get_status(
			scene_path,
			progress
		)

	if status != ResourceLoader.THREAD_LOAD_LOADED:
		push_error("ECHO // SCENE LOADING FAILED: " + scene_path)
		hide()
		is_loading = false
		return

	var packed_scene := ResourceLoader.load_threaded_get(scene_path) as PackedScene

	if packed_scene == null:
		push_error("ECHO // INVALID SCENE: " + scene_path)
		hide()
		is_loading = false
		return

	loading_label.text = "ECHO // CONNECTING TO ENVIRONMENT..."
	progress_bar.value = 100

	var change_error := get_tree().change_scene_to_packed(packed_scene)

	if change_error != OK:
		push_error("ECHO // SCENE TRANSITION FAILED")
		hide()
		is_loading = false
		return

	await get_tree().process_frame

	hide()
	is_loading = false
