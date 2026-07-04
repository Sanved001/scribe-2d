extends Node2D
@onready var object_respawn_root: Node2D = $".."




var orignal_pos = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#signal Respawn_Object(object:Node, hard_respawn:bool, respawn_node:Node)
func respawn_object(my_object:Node,hard_respawn:bool):
	if my_object is CharacterBody2D:
		my_object.velocity = Vector2.ZERO
	else: 
		pass
		
	my_object.position = orignal_pos
