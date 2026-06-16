extends Node2D
@export var animation_player:AnimationPlayer

var objets_in_area:Array[Node2D] = []

func Change_Animation():
	if objets_in_area.size() > 0:
		animation_player.play("pressed")
		SignalBus.Pressure_Plate_Click.emit(self, true)
	elif objets_in_area.size() == 0:
		animation_player.play("not_pressed")
		SignalBus.Pressure_Plate_Click.emit(self, false)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass





func _on_area_2d_area_entered(area: Area2D) -> void:
	objets_in_area.append(area)
	Change_Animation()

func _on_area_2d_area_exited(area: Area2D) -> void:
	objets_in_area.erase(area)
	Change_Animation()
