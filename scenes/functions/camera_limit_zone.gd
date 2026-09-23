extends Area2D
@onready var camera_limit_zone_collider: CollisionShape2D = $CameraLimitZoneCollider


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var zone_shape: RectangleShape2D = camera_limit_zone_collider.shape as RectangleShape2D
		if zone_shape:
			var zone_center = camera_limit_zone_collider.global_position
			var half_size = zone_shape.size * 0.5
			
			var zone_rect = Rect2i(
				int(zone_center.x - half_size.x),\
				int(zone_center.y - half_size.y),\
				int(zone_shape.size.x),
				int(zone_shape.size.y)
			)
			
			SignalBus.Set_Camera_Limit.emit(zone_rect)


func _on_body_exited(body: Node2D) -> void:
	pass
	#SignalBus.Reset_Camera_Limit.emit(true)
