extends CharacterBody2D



const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const FRICTION = 800.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)


	move_and_slide()
