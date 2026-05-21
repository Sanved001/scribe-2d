extends CharacterBody2D
@export var my_animation_player:Node
@export var sprite_player_run:Node
@export var sword_animation_player:Node
@export var weaponpiviot:Node2D

var last_direction:float = 1.0
var input_is_busy:bool = false
var wall_jump:int = 1
var damage_grace_period_is_active:bool = false
var health:int = 100
var damage_resistance_physical:float = 0.0
var calculated_damage:float



const SPEED = 300.0
const JUMP_VELOCITY = -300.0


func player_take_damage(damage:int):
	if damage == 0:
		return
	else: 
		health -= damage
	if health <= 0:
		get_tree().reload_current_scene()
		
	SignalBus.Update_Health_Label.emit("Health: %s" % health)
	
	




func playanimation(direction:float, weapon_slash:bool = false):
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


func _physics_process(delta: float) -> void:
	


	
	
	# Add the gravity.
	if not is_on_floor():
		
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
				velocity.x += 200
				velocity.y = JUMP_VELOCITY
				
			elif Input.is_action_pressed("right"):
				velocity.x -= 200
				velocity.y = JUMP_VELOCITY

	if not input_is_busy:
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("left", "right")
	
		if (direction != 0):
			last_direction = direction
			if direction:
				velocity.x = direction * SPEED

		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		playanimation(direction)
		 

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
			
			
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		playanimation(0.0)

	if Input.is_action_just_pressed("debug"):
		pass


	move_and_slide()
	
	


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if not area is Hitbox:
		return
	if damage_grace_period_is_active:
		return
	
	match area.entity_damage_type:
		"physical": 
			calculated_damage = roundi(area.entity_base_damage - (area.entity_base_damage * damage_resistance_physical))
			print("Calculated Damage: %s" % calculated_damage)
			player_take_damage(calculated_damage)
			print("Health: %s" % health)
		
		"god":
			player_take_damage(area.entity_base_damage)
		
		"fixed":
			player_take_damage(area.entity_base_damage)
