extends Node2D
@onready var object_respawn_root: Node2D = $".."
var root_node:Node2D

var original_linear_velocity:Vector2 = Vector2.ZERO
var original_angular_velocity:float = 0.0
var original_linear_damp:float = 0.0
var original_angular_damp:float = 0.0
var original_is_sleeping = false
var original_global_transform:Transform2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	root_node = object_respawn_root.root_node
	if root_node is RigidBody2D:
	
		original_angular_velocity = root_node.angular_velocity 
		original_linear_damp = root_node.linear_damp
		original_angular_damp = root_node.angular_damp
		original_linear_velocity = root_node.linear_velocity
		original_is_sleeping = root_node.sleeping
		original_global_transform = root_node.global_transform

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#signal Respawn_Object(object:Node, hard_respawn:bool, respawn_node:Node)
func respawn_object(my_object:Node,hard_respawn:bool):
	if not is_instance_valid(root_node):
		return
	SignalBus.Force_Object_Drop.emit(my_object)
	
	root_node.linear_damp = original_linear_damp
	root_node.angular_damp = original_angular_damp
	root_node.sleeping = original_is_sleeping
	
	root_node.constant_force = Vector2.ZERO
	root_node.constant_torque = 0.0
	
	# Get the physical Resource ID (RID) of the body
	var body_rid = root_node.get_rid()
	
	# Reset the RigidBody2D
	PhysicsServer2D.body_set_state(body_rid, PhysicsServer2D.BODY_STATE_TRANSFORM, original_global_transform)
	PhysicsServer2D.body_set_state(body_rid, PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY, original_linear_velocity)
	PhysicsServer2D.body_set_state(body_rid, PhysicsServer2D.BODY_STATE_ANGULAR_VELOCITY, original_angular_velocity)
