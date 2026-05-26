extends Node2D

# LAYER 1: Player Hurtbox
# LAYER 2: ENEMY HITBOX
# LAYER 3: ENEMY HURTBOX
# LAYER 4: ENEMY COLLISIONSHAPE
# LAYER 5: PLAYER HITBOX




@onready var camera_2d: Camera2D = $player/Camera2D
@onready var player: CharacterBody2D = $player
@export var Level_Container:Node2D

var Current_Level:Node2D = null
var Slow_motion_is_active:bool = false


#const CAMERA_MOVE_SPEED = 100

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
	SignalBus.Slow_motion_start.connect(slow_motion_start)
	SignalBus.Slow_motion_stop.connect(slow_motion_stop)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
#https://forum.godotengine.org/t/create-a-slow-motion-effect-with-only-a-few-lines-of-code/36098
# This will make the game play at half-speed by default.
func slow_motion_start(scale: float = 0.5) -> void:
	if Slow_motion_is_active:
		return
	Engine.time_scale = scale
	AudioServer.playback_speed_scale = scale
	Slow_motion_is_active = true
# Run the game at normal speed.
func slow_motion_stop() -> void:
	if not Slow_motion_is_active:
		return
	Engine.time_scale = 1.0
	AudioServer.playback_speed_scale = 1.0
	Slow_motion_is_active  =false
# URL Content End 
