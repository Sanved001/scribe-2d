extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _physics_process(delta: float) -> void:
	pass

#func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	#var current_velocity = state.linear_velocity
	#current_velocity.y = 0
	#
#
	#state.linear_velocity = current_velocity
