extends CanvasLayer

var progress = []
var scene = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scene = GameManager.next_scene
	ResourceLoader.load_threaded_request(scene)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var status = ResourceLoader.load_threaded_get_status(scene, progress)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		set_process(false)
		await get_tree().create_timer(0.8).timeout
		
		var scene_payload = ResourceLoader.load_threaded_get(scene)
		get_tree().change_scene_to_packed(scene_payload)
