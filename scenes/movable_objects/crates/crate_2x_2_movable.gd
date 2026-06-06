extends CharacterBody2D
@onready var player_detector: RayCast2D = $PlayerDetector
@onready var player_detector_2: RayCast2D = $PlayerDetector2


var direction:float = 0.0


const SPEED = 50.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
	direction = 0.0
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	player_is_pushing()
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
func player_is_pushing():
	if player_detector.is_colliding():
		var m_collider = player_detector.get_collider()
		if m_collider.is_in_group("player"):
			if Input.is_action_pressed("left"):
				direction = -1.0
	elif player_detector_2.is_colliding():
		var m_collider = player_detector_2.get_collider()
		if m_collider.is_in_group("player"):
			if Input.is_action_pressed("right"):
				direction = 1.0
