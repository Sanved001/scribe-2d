extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.EnableDebugCrosshair.connect(EnableDebugCrosshair)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func EnableDebugCrosshair(value:bool):
	visible = value
