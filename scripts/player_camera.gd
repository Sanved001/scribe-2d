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
var ActiveCameraZones:Array[Area2D] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#SignalBus.Respawn.connect(Respawn)
	SignalBus.Add_Active_CameraZone.connect(add_Active_CameraZone)

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
	
	var Active_CameraZoneCollider:CollisionShape2D
	for i in ActiveCameraZones[0].get_children():
		if i is CollisionShape2D:
			Active_CameraZoneCollider = i
	
	# ACZC = Active_CameraZoneCollider
	# GET THE TOP, BOTTOM, LEFT, RIGHT of the Active_CameraZoneCollider
	var ACZC_extents = Active_CameraZoneCollider.shape.size / 2
	var ACZC_left = Active_CameraZoneCollider.position.x
	var ACZC_right = null
	var ACZC_top = Active_CameraZoneCollider.position.y
	var ACZC_bottom = null
	
	
	global_position.clamp(to_global(Vector2(ACZC_left, ACZC_top)),\
	to_global(Vector2(ACZC_right, ACZC_bottom)))
	
	
	

func Sort_Active_CameraZone(zone_a:Area2D, zone_b:Area2D):
	# If A's priority is higher, move it before B
	return zone_a.zone_priority > zone_b.zone_priority

func add_Active_CameraZone(zone:Area2D):
	ActiveCameraZones.append(zone)
	ActiveCameraZones.sort_custom(Sort_Active_CameraZone)
	



	
#func Set_camera_limit(zone_rect:Rect2i):
	#
	## THEORY TIME!!!!!!!! YAY!! (cries)
	#'''
	#SO, The camera first goes horizontal then starts moving diagonally..
	#It's cuz at first only the horizontal boundaries are pusing on it
	#but after a while the vertical ones catch up and start pushing too
	#SO, how do we fix that?
	#
	#'''
	#
	#
	#
	##Reset_Camera_Limit(true)
	##var camera_limit_tween = self.create_tween()
	###camera_position_tween.tween_property(self, "position", Vector2(zone_rect.get_center()) , 1)
	###camera_position_tween.tween_property(self, "position:x", zone_rect.get_center().x , 1)
	###camera_position_tween.parallel().tween_property(self, "position:y", zone_rect.get_center().y, 1)
	##camera_limit_tween.tween_property(self, "limit_left", zone_rect.position.x, 2)
	##camera_limit_tween.parallel().tween_property(self, "limit_right", zone_rect.end.x, 2)
	##camera_limit_tween.parallel().tween_property(self, "limit_top", zone_rect.position.y, 2)
	##camera_limit_tween.parallel().tween_property(self, "limit_bottom", zone_rect.end.y, 2)
	#
	##limit_left = zone_rect.position.x
	##limit_right = zone_rect.end.x
	##limit_top = zone_rect.position.y
	##limit_bottom = zone_rect.end.y
	#
#
#func Reset_Camera_Limit(value:bool):
	#if value == true:
		#limit_left = starting_limit_left
		#limit_right = starting_limit_right
		#limit_top = starting_limit_top
		#limit_bottom = starting_limit_bottom
	
