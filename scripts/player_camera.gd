extends Camera2D
@onready var player: CharacterBody2D = $".."

@export var lerp_speed:float = 1.0
@export var lookahead_camera_enabled:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.Respawn.connect(Respawn)

	if not lookahead_camera_enabled: 
		self.position_smoothing_enabled = false
		#self.drag_left_margin = 1.0
		#self.drag_top_margin = 1.0
		#self.drag_right_margin = 1.0
		#self.drag_bottom_margin = 1.0
func _process(delta: float) -> void:
	if lookahead_camera_enabled:
		offset = offset.lerp(player.velocity, delta * lerp_speed)
		#if offset.x >= 50: offset.x = 50
		offset = offset.clamp(Vector2(-50,-50), Vector2(50,50))

func Respawn(hard_respawn:bool):
	self.global_position = player.global_position
