extends Node2D
@onready var object_respawn_root: Node2D = $".."

var root_node = null


var orignal_pos = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.Respawn_Object.connect(respawn_object)
	root_node = object_respawn_root.root_node
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#signal Respawn_Object(object:Node, hard_respawn:bool, respawn_node:Node)
func respawn_object(my_object:Node,hard_respawn:bool):
	Log.write("Me Root node",root_node)
	if my_object == root_node:
		if my_object is CharacterBody2D:
			my_object.velocity = Vector2.ZERO
		else: 
			pass
		
		my_object.position = orignal_pos
