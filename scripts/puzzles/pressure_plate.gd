extends Node2D
@export var animation_player:AnimationPlayer
@export var player_press:bool = true
@export var entity_press:bool = true

var objets_in_area:Array[Node2D] = []
var is_pressed:bool = false

func Change_Animation():
	if objets_in_area.size() > 0:
		if not is_pressed:
			is_pressed = true
			animation_player.play("pressed")
			SignalBus.Pressure_Plate_Click.emit(self, true)
			if OS.is_debug_build():
				print("DEBUG: Pressure plate: ", self, " is Pressed")
	elif not objets_in_area.size() > 0:
		if is_pressed:
			is_pressed = false
			animation_player.play("not_pressed")
			SignalBus.Pressure_Plate_Click.emit(self, false)
			if OS.is_debug_build():
				print("DEBUG: Pressure plate: ", self, " is Lifted")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass





func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		if player_press == true:
			objets_in_area.append(area)
			Change_Animation()
	elif entity_press:
		objets_in_area.append(area)
		Change_Animation()

func _on_area_2d_area_exited(area: Area2D) -> void:
	objets_in_area.erase(area)
	Change_Animation()
