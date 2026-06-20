extends Node2D
@export var animation_player:AnimationPlayer
@export var trigger_node:Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.Pressure_Plate_Click.connect(my_pressure_plate_click)
	#animation_player.play_backwards("open")
	#animation_player.speed_scale = 2
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func my_pressure_plate_click(m_node:Node2D, value:bool):
	if m_node == trigger_node:
		var current_time = animation_player.current_animation_position
		if value:
			animation_player.play("open")
			animation_player.speed_scale = 1
			animation_player.seek(current_time, true)
		else:
			animation_player.play_backwards("open")
			animation_player.speed_scale = 2
			animation_player.seek(current_time, true)
