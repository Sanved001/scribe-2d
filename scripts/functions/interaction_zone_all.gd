extends Area2D

var things_in_interaction_zone:Array[Node] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		if things_in_interaction_zone.size() > 0:
			SignalBus.Player_Interact.emit(things_in_interaction_zone[0], true)
			if OS.is_debug_build():
				print("DEBUG: emitted signal Player_Interact with node: ", things_in_interaction_zone[0], " and value: True")


func _on_area_entered(area: Area2D) -> void:
	if area == null:
		return
	things_in_interaction_zone.append(area)
	if OS.is_debug_build():
		print("DEBUG: Object %s entered Interactopm Zone and appended" % area)


func _on_area_exited(area: Area2D) -> void:
	things_in_interaction_zone.erase(area)
