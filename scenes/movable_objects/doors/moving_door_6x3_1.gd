extends Node2D
@export var animation_player:AnimationPlayer
@export var trigger_node:Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.Pressure_Plate_Click.connect(my_pressure_plate_click)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func my_pressure_plate_click(m_node:Node2D, value:bool):
	if m_node == trigger_node:
		if value:
			animation_player.play("open")
		else:
			animation_player.play("close")
