extends Node2D
@onready var checkpoint_sprite: Sprite2D = $CheckpointSprite
@onready var checkpoint_interaction_area: Area2D = $"Checkpoint Interaction Area"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.Player_Interact.connect(Player_Interact)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func Player_Interact(interact_object:Node, value:bool):
	if interact_object == checkpoint_interaction_area:
		Activate_Checkpoint()
		if OS.is_debug_build():
			print("DEBUG: Successfully recieved Interaction signal for Interaction_Object: ", interact_object, "\nMy Area: ", checkpoint_interaction_area)
	


func Activate_Checkpoint():
	checkpoint_sprite.frame = 0
	GameManager.last_checkpoint_position = self.position
