extends Camera2D
@export var player:CharacterBody2D

@export var smooth_speed:float = 2
@export var lookahead_camera_enabled:bool = true
@export var lookahead_distance_x:float = 100
@export var lookahead_distance_y:float = 150

var max_velocity = Vector2(200, 300)
var target_offset: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#SignalBus.Respawn.connect(Respawn)

	if not lookahead_camera_enabled: 
		self.position_smoothing_enabled = false

func _process(delta: float) -> void:
	#target_offset = Vector2.ZERO
	

	#if player.velocity.x > 0:
		#target_offset.x = lookahead_distance_x
	#elif player.velocity.x < 0: 
		#target_offset.x = -lookahead_distance_x
#
	#if player.velocity.y > 0:
		#target_offset.y = lookahead_distance_y
	#elif player.velocity.y < 0:
		#target_offset.y = -lookahead_distance_y
		
	
	
	var x_ratio = clampf(player.velocity.x / max_velocity.x, -1.0, 1.0)
	var y_ratio = clampf(player.velocity.y / max_velocity.y, -1.0, 1.0)
	
	target_offset = Vector2(x_ratio*lookahead_distance_x, y_ratio*lookahead_distance_y)
	# frame rate independent weight for lerp
	var fps_independent_weight = 1.0 - exp(-smooth_speed * delta)
	
	offset = offset.lerp(target_offset, fps_independent_weight)
	offset.y = min(offset.y, 140)
	#if lookahead_camera_enabled:
		#offset = offset.lerp(player.velocity, delta * lerp_speed)
		#offset = offset.clamp(Vector2(-50,-50), Vector2(50,50))

#func Respawn(hard_respawn:bool):
	#self.global_position = player.global_position
	#reset_smoothing()
