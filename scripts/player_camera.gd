extends Camera2D
@export var player:CharacterBody2D

@export var smooth_speed:float = 2
@export var lookahead_camera_enabled:bool = true
@export var lookahead_distance_x:float = 50
@export var lookahead_distance_y:float = 150

var max_velocity = Vector2(200, 300)
var target_offset: Vector2 = Vector2.ZERO



var starting_limit_left:int 
var starting_limit_right:int
var starting_limit_top:int
var starting_limit_bottom:int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#SignalBus.Respawn.connect(Respawn)
	SignalBus.Set_Camera_Limit.connect(Set_camera_limit)
	SignalBus.Reset_Camera_Limit.connect(Reset_Camera_Limit)

	if not lookahead_camera_enabled: 
		self.position_smoothing_enabled = false
	
	starting_limit_left = limit_left
	starting_limit_right = limit_right
	starting_limit_top = limit_top
	starting_limit_bottom = limit_bottom
	
	

func _process(delta: float) -> void:
	
	var x_ratio = clampf(player.velocity.x / max_velocity.x, -1.0, 1.0)
	var y_ratio = clampf(player.velocity.y / max_velocity.y, -1.0, 1.0)

	target_offset = Vector2(x_ratio*lookahead_distance_x, y_ratio*lookahead_distance_y)
	# frame rate independent weight for lerp
	var fps_independent_weight = 1.0 - exp(-smooth_speed * delta)

	offset = offset.lerp(target_offset, fps_independent_weight)
	offset.y = min(offset.y, lookahead_distance_y)
	
	
	
	# THEORY
	'''The Camera currently clips through limits because of Camera offset
	and we can't just clamp the camera to the values as it stutturs since the
	offset is trying to push into the wall but the clamp is dragging it back.
	So, the plan is: Having a buffer zone a few hundred pixels away from the 
	Limit and perform some calculations if the player is inside the buffer zone
	and moving towards the edge,
	
	First We take the full Distance Between the Buffer zone Edge and the camera Limit Edge ("Whole Distance"):
		
		
	Second We take the distance between the player and the camera limit Edge ("Part Distance")
		
		<example>
		Part Distance = mod(right_limit - Player.Global_Position.x)
		
	Third We perform the percentage calculation:
		
		slowing_percentage =  ( Part Distance / Whole Distance ) * 100
		(Done Independently for both the axes)
		
	Fourth We multiply the slowing percentage for both the lookahead Distances
	And DONE!
	
	BUT what about when the player is moving back towards the open room?
	'''
	
	
	
	
	
	
	
	
	
	
	
func Set_camera_limit(zone_rect:Rect2i):
	limit_left = zone_rect.position.x
	limit_right = zone_rect.end.x
	limit_top = zone_rect.position.y
	limit_bottom = zone_rect.end.y
	

func Reset_Camera_Limit(value:bool):
	if value == true:
		limit_left = starting_limit_left
		limit_right = starting_limit_right
		limit_top = starting_limit_top
		limit_bottom = starting_limit_bottom
	
