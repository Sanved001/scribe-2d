extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.Player_Interact.connect(Player_Interact)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func Player_Interact(interact_object:Node, value:bool):
	if interact_object == self:
		pass
