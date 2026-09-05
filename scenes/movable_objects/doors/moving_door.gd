extends Node2D
@export var trigger_node:Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trigger_node.pressed.connect(my_pressure_plate_click)

	#animation_player.play_backwards("open")
	#animation_player.speed_scale = 2
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func my_pressure_plate_click(value:bool):
	var current_time = animation_player.current_animation_position
	if value:
		animation_player.play("open")
		animation_player.speed_scale = 1
		animation_player.seek(current_time, true)
	else:
		animation_player.play_backwards("open")
		animation_player.speed_scale = 2
		animation_player.seek(current_time, true)
