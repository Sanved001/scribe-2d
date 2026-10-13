extends CanvasLayer

@export var FPS_counter:Label


@onready var pre_fpsv_seperator: VSeparator = $VBoxContainer/HBoxContainer/PreFPSVSeperator
@onready var fpsv_seperator: VSeparator = $VBoxContainer/HBoxContainer/FPSVSeperator




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.ShowFPS.connect(ShowFPS)
	
	FPS_counter.visible = false
	pre_fpsv_seperator.visible = false
	fpsv_seperator.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	FPS_counter.text = "FPS: %s" % Engine.get_frames_per_second()
	

func ShowFPS(value:bool):
	FPS_counter.visible = value
	pre_fpsv_seperator.visible = true
	fpsv_seperator.visible = true
