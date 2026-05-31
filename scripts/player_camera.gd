extends Camera2D
@onready var player: CharacterBody2D = $".."

@export var lerp_speed:float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
# Called every frame. 'delta' is the elapsed time since the previous frame.
	pass
	
func _process(delta: float) -> void:
	
	offset = offset.lerp(player.velocity, delta * lerp_speed)
	#if offset.x >= 50: offset.x = 50
	offset = offset.clamp(Vector2(-50,-50), Vector2(50,50))
