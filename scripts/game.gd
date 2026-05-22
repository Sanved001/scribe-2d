extends Node2D

@export var Level_Container:Node2D

var Current_Level:Node2D = null

func Load_Level(path_to_node, ClearPrevious:bool=false, ClearAll=false):
	if ClearPrevious == true:
		if Current_Level != null:
			Current_Level.remove_child(Current_Level)
			Current_Level.queue_free()
	if ClearAll == false:
		var Level_To_Load = load(path_to_node)
		Current_Level = Level_To_Load.instantiate()
		Level_Container.add_child(Current_Level)
		#print("Successfully loaded: %s" % Current_Level)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Load_Level('res://scenes/Levels/test_level.tscn')
	Load_Level('res://scenes/Levels/level_0.tscn')
	

var tempint:float = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
