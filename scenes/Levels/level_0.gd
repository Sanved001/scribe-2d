extends Node2D
@export var Plane_1:Node2D
@export var Plane_2:Node2D
@export var Plane_1_Tilemap_1:TileMapLayer
@export var Plane_2_Tilemap_1:TileMapLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.Plane_shift.connect(Plane_Shift)
	Plane_2.visible = false
	Plane_2.process_mode = Node.PROCESS_MODE_DISABLED
	Plane_2_Tilemap_1.enabled = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func Plane_Shift(value:bool):
	if value:
		Plane_1.visible = false
		Plane_1_Tilemap_1.enabled = false
		Plane_1.process_mode = Node.PROCESS_MODE_DISABLED
		
		Plane_2.process_mode = Node.PROCESS_MODE_INHERIT
		Plane_2.visible = true
		Plane_2_Tilemap_1.enabled = true

		
		
		
	else:
		Plane_2.visible = false
		Plane_2.process_mode = Node.PROCESS_MODE_DISABLED
		Plane_2_Tilemap_1.enabled = false
		
		Plane_1.process_mode = Node.PROCESS_MODE_INHERIT
		Plane_1.visible = true
		Plane_1_Tilemap_1.enabled = true

		
