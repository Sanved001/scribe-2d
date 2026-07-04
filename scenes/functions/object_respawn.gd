extends Node2D
@onready var object_respawn_root: Node2D = $".."
var root_node:Node2D



var original_pos:Vector2 = Vector2.ZERO
var original_velocity:Vector2 = Vector2.ZERO
var original_rotation:float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	root_node = object_respawn_root.root_node
	original_pos = root_node.position
	original_rotation = root_node.rotation
	if root_node is CharacterBody2D:
		original_velocity = root_node.velocity


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#signal Respawn_Object(object:Node, hard_respawn:bool, respawn_node:Node)
func respawn_object(my_object:Node2D,hard_respawn:bool):
	if my_object is CharacterBody2D:
		my_object.velocity = original_velocity
	else: 
		pass
		
	my_object.position = original_pos
	my_object.rotation = original_rotation
