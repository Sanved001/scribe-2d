extends CharacterBody2D
@export var my_animation_player:Node
@export var sprite_player_run:Node
@export var sword_animation_player:Node
@export var weaponpiviot:Node2D
@onready var red_sword: Sprite2D = $WeaponPiviot/red_sword

var last_direction:float = 0.0
var input_is_busy:bool = false
var dash_count:int = 1
var player_is_dashing:bool = false
var damage_grace_period_is_active:bool = false
var health:int = 100
var damage_resistance_physical:float = 0.0
var calculated_damage:float
var block_weapon_input:bool = false
var dash_cooldown:bool = false
var last_animation_direction:float = 0.0




const SPEED = 300.0
const JUMP_VELOCITY = -350.0
const DASH_SPEED = 600.0


func player_take_damage(damage:int, source_area:Area2D = null):
	if damage == 0:
		return
	else: 
		health -= damage
	
	if source_area != null:
		var knockback_direction = global_position - source_area.global_position
		knockback_direction = knockback_direction.normalized()
		velocity = knockback_direction * source_area.entity_knockback_strength
	
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
		sprite_player_run.flip_h = (direction < 0)
	
		
func _is_my_input_busy(value:bool):
	input_is_busy = value
	

func _ready() -> void:
	sword_animation_player.speed_scale = 3
	SignalBus.Input_Is_Busy.connect(_is_my_input_busy)
	red_sword.visible = false



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
			velocity.y += get_gravity().y * 1.5 * delta
	# Handle jump.
	if not input_is_busy:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			
		elif Input.is_action_just_pressed("jump") and is_on_wall():
			if Input.is_action_pressed("left"):
				velocity.x += 50
				velocity.y = JUMP_VELOCITY-10
				await input_cooldown(0.2)
				
			elif Input.is_action_pressed("right"):
				velocity.x -= 50
				velocity.y = JUMP_VELOCITY-10
				await input_cooldown(0.2)

	if not input_is_busy:
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("left", "right")
	
		if (direction != 0):
			last_animation_direction = direction
			last_direction = direction
			if direction:
				velocity.x = direction * SPEED

		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			playanimation("" , 0.0)

		
		if dash_count != 0 and not dash_cooldown:
			
			if Input.is_action_just_pressed("dash") and last_direction != 0:
				dash_count -= 1
				velocity.x = DASH_SPEED * last_direction
				player_is_dashing_input_cooldown(0.2)
				dash_cooldown_start(1)

		
		 
		
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
			calculated_damage = roundi(area.entity_base_damage - (area.entity_base_damage * damage_resistance_physical))
			player_take_damage(calculated_damage, area)
		
		"god":
			player_take_damage(area.entity_base_damage, area)
		
		"fixed":
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
