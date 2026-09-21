extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		if not visible:
			visible = true
		else:
			visible = false


func _on_enable_crosshair_check_box_toggled(toggled_on: bool) -> void:
	SignalBus.EnableDebugCrosshair.emit(toggled_on)
