extends Node2D
@onready var object_respawn: Node2D = $Object_Respawn
@onready var object_rigid_body_2d_respawn: Node2D = $Object_RigidBody2D_Respawn


@export var root_node:Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.Respawn_Object.connect(respawn_object)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func respawn_object(my_object:Node,hard_respawn:bool):
	if not my_object is RigidBody2D:
		object_respawn.respawn_object(my_object,hard_respawn)
	elif my_object is RigidBody2D:
		pass
