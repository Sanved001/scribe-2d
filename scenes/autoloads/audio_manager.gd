extends Node2D
@export var bgm_player:AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func play_bgm(bgm_path: String):
	if not ResourceLoader.exists(bgm_path):
		Log.log_error("Audio File missing: %s" % bgm_path, self)
		return
	
	var bgm = load(bgm_path)
	if bgm_player.stream != bgm:
		bgm_player.stream = bgm
		bgm_player.play()
		
