extends CharacterBody2D


@export var player_detection_radius:float = 800.0
@onready var blob: Sprite2D = $blob

const SPEED = 100.0
const JUMP_VELOCITY = -400.0
const FRICTION = 800.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	
	
	var player = get_tree().get_first_node_in_group("player")
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player <= player_detection_radius:
		var direction:int = sign(player.global_position.x - global_position.x)
		if direction > 0: blob.flip_h = true
		else: blob.flip_h = false
			
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)


	move_and_slide()
