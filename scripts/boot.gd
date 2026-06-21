######################################################
###    This File will be put to use a bit later    ###
######################################################




extends Node

var PATCH_PATH:String = OS.get_executable_path().get_base_dir().path_join("patch.pck")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Load_Update_pck()
	
	get_tree().change_scene_to_file("res://scenes/GUI/main_menu.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func Load_Update_pck():
	if FileAccess.file_exists(PATCH_PATH):
		ProjectSettings.load_resource_pack(PATCH_PATH)
