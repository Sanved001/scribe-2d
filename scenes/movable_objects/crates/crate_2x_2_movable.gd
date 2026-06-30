extends RigidBody2D
var origin_pos:Vector2
var m_orignal_velocity
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	origin_pos = position
	m_orignal_velocity = linear_velocity
	SignalBus.Respawn.connect(Crate_Respawn)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func Crate_Respawn(hard_respawn:bool):
	linear_velocity = m_orignal_velocity
	position = origin_pos
