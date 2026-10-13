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


func _on_button_respawn_pressed() -> void:
	SignalBus.Respawn.emit(false)



func _on_vsync_options_selector_item_selected(index: int) -> void:
	if index == 0: # Disabled (default)
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	elif index == 1: # Adaptive
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
	elif index == 2: # Enabled
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)


func _on_show_fps_check_box_toggled(toggled_on: bool) -> void:
	SignalBus.ShowFPS.emit(toggled_on)
