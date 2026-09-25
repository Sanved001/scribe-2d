extends Camera2D
@export var player:CharacterBody2D

@export var smooth_speed:float = 2
@export var lookahead_camera_enabled:bool = true
@export var lookahead_distance_x:float = 50
@export var lookahead_distance_y:float = 150
@export var Buffer_Wall_Distance:float = 100

var max_velocity = Vector2(200, 300)
var target_offset: Vector2 = Vector2.ZERO



var starting_limit_left:int 
var starting_limit_right:int
var starting_limit_top:int
var starting_limit_bottom:int
var slowing_percentage_x:float = 1.0
var slowing_percentage_y:float = 1.0

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
	queue_redraw()
	slowing_percentage_x = 1.0
	slowing_percentage_y = 1.0
	var half_width = (get_viewport_rect().size.x / zoom.x) * 0.5
	
	var x_ratio = clampf(player.velocity.x / max_velocity.x, -1.0, 1.0)
	var y_ratio = clampf(player.velocity.y / max_velocity.y, -1.0, 1.0)

	target_offset = Vector2(x_ratio*lookahead_distance_x, y_ratio*lookahead_distance_y)
	# frame rate independent weight for lerp
	var fps_independent_weight = 1.0 - exp(-smooth_speed * delta)

	
	
	
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
	
	# What Direction is the player moving
	if player.velocity.x > 0:
		# Moving right
		# Check if player has passed the buffer wall
		if player.global_position.x > (limit_right - half_width) - Buffer_Wall_Distance:
			# get part distance
			var part_distance:float = (limit_right - half_width) - player.global_position.x
			# Check if the player is outside the limit zone
			# part_distance will be negative if that is the case
			if part_distance >= 0:
				slowing_percentage_x = (part_distance / Buffer_Wall_Distance)
	
	elif player.velocity.x < 0:
		# Moving Left
		# Check if player has passed buffer wall
		if player.global_position.x < (limit_left + half_width) + Buffer_Wall_Distance:
			#get part distance
			var part_distance:float = (limit_left + half_width) - player.global_position.x
			# Check if the player is outside the limit zone
			# part_distance will be negative if that is the case
			if part_distance <= 0:
				slowing_percentage_x = (part_distance / Buffer_Wall_Distance)
		
	
	
	
	
	target_offset = Vector2(target_offset.x * slowing_percentage_x, target_offset.y * slowing_percentage_y)
	
	var min_allowed_offset_x = minf(0.0, (limit_left + half_width) - player.global_position.x)
	var max_allowed_offset_x = maxf(0.0, (limit_right - half_width) - player.global_position.x)

	offset = offset.lerp(target_offset, fps_independent_weight)
	offset.y = min(offset.y, lookahead_distance_y )
	offset.x = min(offset.x, lookahead_distance_x )
	offset.x = clampf(offset.x, min_allowed_offset_x, max_allowed_offset_x)
	
	
	
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

func _draw():
	var half_width = (get_viewport_rect().size.x / zoom.x) * 0.5
	var left_x = ((limit_left + half_width) + Buffer_Wall_Distance)
	var right_x = ((limit_right - half_width) - Buffer_Wall_Distance)
	
	draw_line(to_local(Vector2(left_x, 900)), to_local(Vector2(left_x, -900)), "RED", 1, 0)
	draw_line(to_local(Vector2(right_x, 900)), to_local(Vector2(right_x, -900)), "BLUE", 1, 0)
