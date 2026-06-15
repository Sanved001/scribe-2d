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



@onready var red_sword: Sprite2D = $WeaponPiviot/red_sword
@onready var red_sword_hitbox_collider: CollisionShape2D = $WeaponPiviot/red_sword/Hitbox/red_sword_hitbox_collider


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


const SPEED = 200.0
const JUMP_VELOCITY = -350.0
const DASH_SPEED = 400.0


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
		
		#if velocity.x > 0 and velocity.x <= 200: velocity.x = 200
		#elif velocity.x < 0 and velocity.x >= -200: velocity.x = -200
		#if knockback_direction.y > 0:
			#if velocity.y > 0 and velocity.y <= 200:
				#velocity.y = 200
		#elif knockback_direction.y <= 0:
			#if velocity.y <= 0 and velocity.y >= -200:
				#velocity.y = -200
		Player_Flash()
		input_cooldown(0.2)
	
	if health <= 0:
		SignalBus.Slow_motion_start.emit(0.1)
		await get_tree().create_timer(0.2).timeout
		SignalBus.Slow_motion_stop.emit()
		get_tree().call_deferred("reload_current_scene")
		return
	SignalBus.Update_Health_Label.emit("Health: %s" % health)
	
	
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
	

func _ready() -> void:
	sword_animation_player.speed_scale = 3
	SignalBus.Input_Is_Busy.connect(_is_my_input_busy)
	red_sword.visible = false
	red_sword_hitbox_collider.disabled = true
	
	



func _physics_process(delta: float) -> void:
	
	if (is_on_floor() or is_on_wall()):
		last_animation_direction = 0.0
		if not player_is_dashing:
			dash_count = 1
	
	


	
	
	# Add the gravity.
	if not is_on_floor() and not player_is_dashing:
		
		if velocity.y <= 0:
			velocity += get_gravity() * delta
		
		if is_on_wall() and velocity.y > 0 and (Input.is_action_pressed("left") or Input.is_action_pressed("right")):
			velocity.y = min(velocity.y , 150)
	
		elif velocity.y > 0:
			velocity.y += get_gravity().y * 1.25 * delta
	# Handle jump.
	if not input_is_busy:
		if not jump_disabled:
			# If player jumped while holding an object LET IT GO!
			if Input.is_action_just_pressed("jump"):
				if player_is_holding_objects.size() > 0:
					var released_object = player_is_holding_objects[0]
					player_is_holding_objects.erase(released_object)
					SignalBus.Player_Interact_Movable_Object.emit(released_object, self, false)
				
			if Input.is_action_just_pressed("jump") and is_on_floor():
				velocity.y = JUMP_VELOCITY
				
			elif Input.is_action_just_pressed("jump") and is_on_wall():
				if is_wall_climbable():
					if Input.is_action_pressed("left"):
						velocity.x += 50
						velocity.y = JUMP_VELOCITY-10
						await input_cooldown(0.2)
						
					elif Input.is_action_pressed("right"):
						velocity.x -= 50
						velocity.y = JUMP_VELOCITY-10
						await input_cooldown(0.2)
				
				
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
			
		if (direction != 0):
			last_animation_direction = direction
			last_direction = direction
			#RaycastPiviot.scale.x = 1
			if direction:
				velocity.x = direction * SPEED
				intended_velocity.x = velocity.x
		else:
			#RaycastPiviot.scale.x = -1
			velocity.x = move_toward(velocity.x, 0, SPEED)
			intended_velocity.x = velocity.x
			playanimation("" , 0.0)

		
		if dash_count != 0 and not dash_cooldown:
			
			if Input.is_action_just_pressed("dash") and last_direction != 0:
				dash_count -= 1
				velocity.x = DASH_SPEED * last_direction
				player_is_dashing_input_cooldown(0.2)
				dash_cooldown_start(1)
				
		if Input.is_action_just_pressed("interact"):
			if not interaction_cooldown_is_active:
			
			
				#if not player_is_holding_object:
					# CODE TO BE RE WRITTEN 
					#if Interaction_raycast.is_colliding():
						#var interaction_collider = Interaction_raycast.get_collider()
						#if Debug_Mode:
							#print(Interaction_raycast, " Is Colliding With ", interaction_collider)
						#if interaction_collider is RigidBody2D:
							#SignalBus.Player_Interact_Movable_Object.emit(interaction_collider, self)
					# CODE TO BE RE WRITTEN/REPLACED TILL HERE ^^^^^^^^^^^^^^^^^^
				
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
			
			
			

	if Input.is_action_just_pressed("debug"):
		#SignalBus.ChangeCurrentScene.emit("res://scenes/Levels/level_0_boss.tscn", "change level", true)
		pass
		
	playanimation("", last_animation_direction)
	move_and_slide()

	
	


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
				var is_climbable:bool = climbable_tile_data.get_custom_data("climbable")
			
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
				var is_climbable:bool = climbable_tile_data.get_custom_data("climbable")
			
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
