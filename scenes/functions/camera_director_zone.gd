extends Node2D


@export var zone_size:Vector2 = Vector2(400,100)


@onready var director_zone_collider: CollisionShape2D = $DirectorZoneArea/DirectorZoneCollider


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	director_zone_collider.shape.extents = zone_size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
