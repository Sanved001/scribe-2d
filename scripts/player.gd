extends CharacterBody2D
@export var my_animation_player:Node
@export var sprite_player:Node
@export var sword_animation_player:Node
@export var weaponpiviot:Node2D
@export var Wall_Climb_RayCast2D:RayCast2D
@export var Wall_Climb_RayCast2D2:RayCast2D
@export var Interaction_raycast:RayCast2D
@export var Interaction_Zone:Area2D
@export var Interaction_Zone_Piviot:Node2D
@export var player_camera:Camera2D
@onready var wall_contact_coyote_timer: Timer = $wall_contact_coyote_timer
@onready var wall_jump_lock_timer: Timer = $wall_jump_lock_timer


@onready var red_sword: Sprite2D = $WeaponPiviot/red_sword
@onready var red_sword_hitbox_collider: CollisionShape2D = $WeaponPiviot/red_sword/Hitbox/red_sword_hitbox_collider
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var coyote_jump_timer: Timer = $CoyoteJumpTimer


var Debug_Mode:bool = OS.is_debug_build()
var last_direction:float = 0.0
var input_is_busy:bool = false
var dash_count:int = 1
var player_is_dashing:bool = false
var damage_grace_period_is_active:bool = false
var health:float = 100
var damage_resistance_physical:float = 0.0
var damage_resistance_acid:float = 0.0
var calculated_damage:float
var block_weapon_input:bool = false
var dash_cooldown:bool = false
var last_animation_direction:float = 0.0
var Plane_Shift:bool = false
var intended_velocity:Vector2 = Vector2(0,0)
var player_is_holding_objects:Array[Node2D]
var Objects_In_Interaction_Zone:Array[Node2D]
var interaction_cooldown_is_active:bool = false
var jump_disabled:bool = false
var dialog_ui_is_busy:bool = false
var player_is_on_ground:bool = false
var coyote_jump:bool = false
var original_spawn_position:Vector2 = Vector2(0, 0)
var coyote_time_activated:bool = false

#var wall_contact_coyote:float = 0.0
#const WALL_CONTACT_COYOTE_TIME:float = 0.2
#
#var wall_jump_lock: float = 0.0
#const WALL_JUMP_LOCK_TIME:float = 0.05

var look_direction:int = 1

const SPEED = 200.0
const JUMP_VELOCITY = -350.0
const DASH_SPEED = 400.0
const FRICTION = 25
const ACCELERATION = 20
const WALL_JUMP_PUSH_FORCE = 500 


func _ready() -> void:
	sword_animation_player.speed_scale = 3
	SignalBus.Input_Is_Busy.connect(_is_my_input_busy)
	SignalBus.Dialog_UI_Is_Busy_To_Player.connect(is_dialog_ui_busy)
	SignalBus.Respawn.connect(Respawn_Player)
	SignalBus.Force_Object_Drop.connect(Force_Drop_Object)
	red_sword.visible = false
	red_sword_hitbox_collider.disabled = true
	original_spawn_position = self.global_position
	health = GameManager.player_health



func _physics_process(delta: float) -> void:
	if (is_on_floor() or is_on_wall()):
		last_animation_direction = 0.0
		if not player_is_dashing:
			dash_count = 1
	
	if is_on_floor():
		coyote_time_activated = false
	else: 
		if coyote_jump_timer.is_stopped() and not coyote_time_activated:
			coyote_jump_timer.start()
			coyote_time_activated = true
	
	#if is_on_floor():
		#player_is_on_ground = true
	#elif player_is_on_ground:
			#player_is_on_ground = false
			#if not coyote_jump:
				#coyote_jump_timer()
			
		
	
	


	
	
	# Add the gravity.
	if not is_on_floor() and not player_is_dashing:
		
		if velocity.y <= 0:
			velocity += get_gravity() * delta
		
		if is_on_wall() and velocity.y > 0 and (Input.is_action_pressed("left") or Input.is_action_pressed("right")):
			velocity.y = min(velocity.y , 25)
	
		elif velocity.y > 0:
			velocity.y += get_gravity().y * 1.25 * delta
			
	# Handle jump.
	
	if not input_is_busy and not jump_disabled:
		
		if Input.is_action_just_pressed("jump"):
			if jump_buffer_timer.is_stopped():
				jump_buffer_timer.start()
		
		if not jump_buffer_timer.is_stopped()\
		and (not coyote_jump_timer.is_stopped()\
		or is_on_floor()\
		or not wall_contact_coyote_timer.is_stopped()):
			velocity.y = JUMP_VELOCITY
			jump_buffer_timer.stop()
			coyote_jump_timer.stop()
			coyote_time_activated = true
			
			# WALL JUMP
			if not wall_contact_coyote_timer.is_stopped():
				velocity.x = -look_direction * WALL_JUMP_PUSH_FORCE
				wall_jump_lock_timer.start()
		
		#if Input.is_action_just_pressed("jump"):
			#if is_on_floor() or coyote_jump:
				#velocity.y = JUMP_VELOCITY
				#coyote_jump = false
		if Input.is_action_just_released("jump") and velocity.y < 0 or is_on_ceiling():
			velocity.y = velocity.y/4
		
		
	
			
	
	# NUDGE THE PLAYER TOWARDS LEFT OR RIGHT IF IT BARELY HITS SOMETHING ON THE TOP
	if velocity.y < JUMP_VELOCITY/2:
		var head_collision: Array = [$HeadNudgeRaycasts/LeftCorner_HeadNudge.is_colliding(),\
		$HeadNudgeRaycasts/Left_HeadNudge.is_colliding(),\
		$HeadNudgeRaycasts/RightCorner_HeadNudge.is_colliding(),\
		$HeadNudgeRaycasts/Right_HeadNudge.is_colliding()]
		if head_collision.count(true) == 1:
			if head_collision[0]:
				global_position.x += 2
			if head_collision[2]:
				global_position.x -= 2
	
	# IF THE PLAYER JUST BARELY MISSED THE PLATFORM WHILE JUMPING HELP HIM GET UP
	if velocity.y > -30 and velocity.y < -5 and abs(velocity.x) > 5:
		if $LedgeHopRaycasts/LeftBottom_LedgeHop.is_colliding()\
		and not $LedgeHopRaycasts/LeftTop_LedgeHop.is_colliding()\
		and velocity.x < 0:
			velocity.y += JUMP_VELOCITY/3.25
		if $LedgeHopRaycasts/RightBottom_LedgeHop.is_colliding()\
		and not $LedgeHopRaycasts/RightTop_LedgeHop.is_colliding()\
		and velocity.x > 0:
			velocity.y += JUMP_VELOCITY/3.25
	
	if not is_on_floor() and velocity.y > 0 and is_on_wall() and\
	Input.get_axis("left", "right") != 0:
		look_direction = Input.get_axis("left", "right")
		wall_contact_coyote_timer.start()
		velocity.y = 10

	
	
	#if not input_is_busy:
		#if not jump_disabled:
			## If player jumped while holding an object LET IT GO!
			#if Input.is_action_just_pressed("jump"):
				#if player_is_holding_objects.size() > 0:
					#var released_object = player_is_holding_objects[0]
					#player_is_holding_objects.erase(released_object)
					#SignalBus.Player_Interact_Movable_Object.emit(released_object, self, false)
				#
			#if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote_jump):
				#velocity.y = JUMP_VELOCITY
				#coyote_jump = false
				#player_is_on_ground = false
				#
			#elif Input.is_action_just_pressed("jump") and (is_on_wall() or coyote_jump):
				#if is_wall_climbable():
					#if Input.is_action_pressed("left"):
						#velocity.x += 50
						#velocity.y = JUMP_VELOCITY-10
						#input_cooldown(0.2)
						#
					#elif Input.is_action_pressed("right"):
						#velocity.x -= 50
						#velocity.y = JUMP_VELOCITY-10
						#input_cooldown(0.2)
				
				
		# PLANE SHIFTING
		if not input_is_busy:
			if Input.is_action_just_pressed("shift_plane"):
				if Plane_Shift:
					SignalBus.Plane_shift.emit(false)
					Plane_Shift = false
				else: 
					SignalBus.Plane_shift.emit(true)
					Plane_Shift = true

	if not input_is_busy:
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("left", "right")
		Change_Interaction_Zone_Piviot(direction)
		var velocity_weight: float = delta * (ACCELERATION if direction else FRICTION)
		# WALL JUMP
		
		if not wall_jump_lock_timer.is_stopped():
			velocity.x = lerp(velocity.x, direction * SPEED, velocity_weight*0.5)
		else:
			velocity.x = lerp(velocity.x, direction * SPEED, velocity_weight)
		
		intended_velocity.x = velocity.x
		if (direction != 0):
			last_animation_direction = direction
			last_direction = direction
			#RaycastPiviot.scale.x = 1
			#velocity.x = direction * SPEED
		else:
			#RaycastPiviot.scale.x = -1
			#velocity.x = move_toward(velocity.x, 0, SPEED)
			
			playanimation("" , 0.0)

		
		if dash_count != 0 and not dash_cooldown:
			
			if Input.is_action_just_pressed("dash") and last_direction != 0:
				dash_count -= 1
				velocity.x = DASH_SPEED * last_direction
				player_is_dashing_input_cooldown(0.2)
				dash_cooldown_start(1)
				
		if Input.is_action_just_pressed("interact"):
			if not interaction_cooldown_is_active:
				if player_is_holding_objects.size() > 0:
					var released_object = player_is_holding_objects[0]
					SignalBus.Player_Interact_Movable_Object.emit(released_object, self, false)
					player_is_holding_objects.clear()
				elif Objects_In_Interaction_Zone.size() != 0:
					SignalBus.Player_Interact_Movable_Object.emit(Objects_In_Interaction_Zone[0], self, true)
					player_is_holding_objects.append(Objects_In_Interaction_Zone[0])
					if Debug_Mode:
						print("DEBUG: Player Is Holding Objecs: %s " % player_is_holding_objects)
						print("DEBG: Objects in Interaction Zone: %s " % Objects_In_Interaction_Zone.size())
					
				Interaction_Cooldown_Start(0.1)
		
	if not block_weapon_input:
		if Input.is_action_just_pressed("attack"):
			if (last_direction > 0):
				if is_on_wall():
					weaponpiviot.scale.x = -1
				else: 
					weaponpiviot.scale.x = 1
			elif(last_direction < 0):
				if is_on_wall():
					weaponpiviot.scale.x = 1
				else: 
					weaponpiviot.scale.x = -1
			sword_animation_player.play('red_sword_swing_right')
			
			
			
	if Wall_Climb_RayCast2D.is_colliding() or Wall_Climb_RayCast2D2.is_colliding():
		if intended_velocity.x > 0:
			intended_velocity.x = -1.0
		elif intended_velocity.x < 0:
			intended_velocity.x = 1.0
	if input_is_busy and dialog_ui_is_busy:
		intended_velocity.x = 0.0
		velocity.x = 0.0 
		
		
	
	

	if Input.is_action_just_pressed("debug"):
		pass
		#SignalBus.ChangeCurrentScene.emit("res://scenes/Levels/level_0_boss.tscn", "change level", true)
		#SignalBus.Stop_Saw_Blade.emit($"../SawBlade", true, false)
	
	
	# limit max Y Downward velocity
	velocity.y = min(velocity.y, 600)
	
	#Log.write("Velocity: %s" % velocity, self)
	playanimation("", last_animation_direction)
	move_and_slide()

	
	
func Respawn_Player(hard_respawn:bool):
	if GameManager.last_checkpoint_position != Vector2.ZERO:
		self.global_position = GameManager.last_checkpoint_position
		health = 100
		SignalBus.Update_Health_Label.emit("Health: %s" % health)
	else: 
		self.global_position = original_spawn_position
		health = 100
		SignalBus.Update_Health_Label.emit("Health: %s" % health)
	velocity = Vector2.ZERO
	
	reset_physics_interpolation()
	player_camera.global_position = self.global_position
	player_camera.reset_smoothing()
		



func player_take_damage(damage:float, source_area:Area2D = null):
	if damage == 0:
		return
	else: 
		health -= damage
	
	
	
	if source_area != null:
		var knockback_direction = global_position - source_area.global_position
		knockback_direction = knockback_direction.normalized()
		velocity = knockback_direction * source_area.entity_knockback_strength
		velocity.y -= 1 # MAKE THE PLAYER JUMP EVEN IF AT 0 Y VELOCITY
		if velocity.x != 0:
			var sign_x = sign(velocity.x)
			if abs(velocity.x) < 200:
				velocity.x = sign_x * 200
		
		if velocity.y != 0:
			var sign_y = sign(velocity.y)
			if abs(velocity.y) < 200:
				velocity.y = sign_y * 200
		
		if velocity.y == 0:
			velocity.y = -200
		if velocity.x == 0:
			if global_position.x >= source_area.global_position.x:
				velocity.x = 200 # move right
			else: 
				velocity.x = -200 # move left
		
		Player_Flash()
		input_cooldown(0.2)
	
	if health <= 0:
		SignalBus.Slow_motion_start.emit(0.1)
		await get_tree().create_timer(0.2).timeout
		SignalBus.Slow_motion_stop.emit()
		#get_tree().call_deferred("reload_current_scene")
		SignalBus.Respawn.emit(false)
		


	SignalBus.Update_Health_Label.emit("Health: %s" % health)
	GameManager.player_health = health
	
	
	damage_grace_period_cooldown_start(0.1)
	
	
	


func playanimation(animation_name:String = "", m_direction:float = 0.0):
	if not animation_name == "":
		my_animation_player.play(animation_name)
	else:
		playanimation_direction(m_direction)


func playanimation_direction(direction:float):
	if not is_on_floor():
		# jump
		if not is_on_wall():
			my_animation_player.play('player_jump')
		elif is_on_wall():
			my_animation_player.play('player_wall_slide')
		
	elif direction != 0:
		my_animation_player.play('player_run')
			
	else: 
		my_animation_player.play("player_idle")
		
	if direction != 0:
		sprite_player.flip_h = (direction < 0)
		Wall_Climb_RayCast2D.rotation = PI if direction < 0 else 0.0
		Wall_Climb_RayCast2D2.rotation = PI if direction < 0 else 0.0
		Interaction_raycast.rotation = PI if direction < 0 else 0.0
	


func _is_my_input_busy(value:bool):
	input_is_busy = value
	
	

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if not area is Hitbox:
		return
	if area.entity_type == "Void":
		player_take_damage(area.entity_base_damage)
		return
	
	if damage_grace_period_is_active:
		return
	
	match area.entity_damage_type:
		"physical": 
			calculated_damage = area.entity_base_damage - (area.entity_base_damage * damage_resistance_physical)
			player_take_damage(calculated_damage, area)
		"acid":
			calculated_damage = area.entity_base_damage - (area.entity_base_damage * damage_resistance_acid)
			player_take_damage(calculated_damage, area)
		
		"god":
			player_take_damage(area.entity_base_damage, area)
		


func input_cooldown(cooldown_time, m_block_weapon_input:bool = false):
	input_is_busy = true
	block_weapon_input = m_block_weapon_input
	await get_tree().create_timer(cooldown_time).timeout
	block_weapon_input = false
	input_is_busy = false
func player_is_dashing_input_cooldown(value:float):
	velocity.y = 0
	player_is_dashing = true
	last_animation_direction = 0.0
	damage_grace_period_cooldown_start(value)
	await input_cooldown(value)
	player_is_dashing = false
func dash_cooldown_start(value:float = 1):
	dash_cooldown = true
	await get_tree().create_timer(value).timeout
	dash_cooldown = false
func damage_grace_period_cooldown_start(value:float):
	if damage_grace_period_is_active:
		return
	damage_grace_period_is_active = true
	await  get_tree().create_timer(value).timeout
	damage_grace_period_is_active = false
func Player_Flash(value:float = 0.2):
	sprite_player.material.set_shader_parameter('Flash_White', true)
	await get_tree().create_timer(value).timeout
	sprite_player.material.set_shader_parameter('Flash_White', false)
	
	

func is_wall_climbable():
	if Wall_Climb_RayCast2D.is_colliding():
		var tilemap = Wall_Climb_RayCast2D.get_collider()
		if tilemap is TileMapLayer:
			var climable_raycast2d_collision_point = Wall_Climb_RayCast2D.get_collision_point()
			var local_coordinate = tilemap.to_local(climable_raycast2d_collision_point)
			var tile_cordinate = tilemap.local_to_map(local_coordinate)
			# fix the grid being shifted by one to the right when facing left
			var m_collision_normal = Wall_Climb_RayCast2D.get_collision_normal()
			if m_collision_normal.x > 0:
				tile_cordinate.x -= 1
			
			
			if Debug_Mode:
				print("Next to valid tilemap: %s", tilemap)
				print("Local Coordinate: ", local_coordinate)
				print("Tile Coordinate: ", tile_cordinate)
				
			var climbable_tile_data = tilemap.get_cell_tile_data(tile_cordinate)
			if climbable_tile_data != null:
				var is_climbable = true
				var is_not_climbable:bool = climbable_tile_data.get_custom_data("not climbable")
				if is_not_climbable == true:
					is_climbable = false
				else:
					is_climbable = true
				if Debug_Mode:
					print("Tile ", climbable_tile_data, "is Climbable: ", is_climbable )
					
				return is_climbable
				
	elif Wall_Climb_RayCast2D2.is_colliding():
		var tilemap = Wall_Climb_RayCast2D2.get_collider()
		if tilemap is TileMapLayer:
			var climable_raycast2d2_collision_point = Wall_Climb_RayCast2D2.get_collision_point()
			var local_coordinate = tilemap.to_local(climable_raycast2d2_collision_point)
			var tile_cordinate = tilemap.local_to_map(local_coordinate)
			# fix the grid being shifted by one to the right when facing left
			var m_collision_normal = Wall_Climb_RayCast2D2.get_collision_normal()
			if m_collision_normal.x > 0:
				tile_cordinate.x -= 1
			
			
			if Debug_Mode:
				print("Next to valid tilemap: %s", tilemap)
				print("Local Coordinate: ", local_coordinate)
				print("Tile Coordinate: ", tile_cordinate)
				
			var climbable_tile_data = tilemap.get_cell_tile_data(tile_cordinate)
			if climbable_tile_data != null:
				var is_climbable = true
				var is_not_climbable:bool = climbable_tile_data.get_custom_data("not climbable")
				
				if is_not_climbable == true:
					is_climbable = false
				else:
					is_climbable = true
				if Debug_Mode:
					print("Tile ", climbable_tile_data, "is Climbable: ", is_climbable )
					
				return is_climbable


	




func _on_interaction_zone_body_entered(body: Node2D) -> void:
	Objects_In_Interaction_Zone.append(body)
	
	if Debug_Mode:
		print("DEBUG: Object %s Entered The Interaction Zone" % body)
		print("DEBUG: Objects In Interaction Zone: ", Objects_In_Interaction_Zone)
		print("DEBG: Objects in Interaction Zone: %s " % Objects_In_Interaction_Zone.size())
	


func _on_interaction_zone_body_exited(body: Node2D) -> void:
	Objects_In_Interaction_Zone.erase(body)
	
	if player_is_holding_objects.has(body):
		if Debug_Mode:
			print("DEBUG: Object lagged behind, ignoring drop")
		return

	SignalBus.Player_Interact_Movable_Object.emit(body, self, false)
	player_is_holding_objects.erase(body)
	if Debug_Mode:
		print("DEBUG: Object %s Left The Interaction Zone" % body)
		print("DEBUG: Objects In Interaction Zone: ", Objects_In_Interaction_Zone)
		print("DEBUG: Player Is Holding Objecs: %s " % player_is_holding_objects)
		print("DEUBG: Objects in Interaction Zone: %s " % Objects_In_Interaction_Zone.size())
		


func Force_Drop_Object(my_object:Node2D):
	if not is_instance_valid(my_object):
		return
	SignalBus.Player_Interact_Movable_Object.emit(my_object, self, false)
	player_is_holding_objects.erase(my_object)
	




func Change_Interaction_Zone_Piviot(direction:float):

		if player_is_holding_objects.size() == 0:
			if direction != 0:
				if direction > 0:
					Interaction_Zone_Piviot.scale.x = 1 
				else:
					Interaction_Zone_Piviot.scale.x = -1

func Interaction_Cooldown_Start(value:float):
	interaction_cooldown_is_active = true
	await get_tree().create_timer(value).timeout
	interaction_cooldown_is_active = false


func is_dialog_ui_busy(value:bool):
	dialog_ui_is_busy = value
	if dialog_ui_is_busy:
		is_dialog_ui_busy_reset_timer()


func is_dialog_ui_busy_reset_timer():
		await get_tree().create_timer(0.01).timeout
		dialog_ui_is_busy = false
		

func coyote_jump_timertwo():
	coyote_jump = true
	await get_tree().create_timer(0.2).timeout
	coyote_jump = false
