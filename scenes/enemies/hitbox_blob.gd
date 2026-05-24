extends Hitbox


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	entity_name = "Blob"
	entity_type = "acid"
	entity_base_damage = 20
	entity_damage_type = "acid"
	entity_knockback_strength = 200



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
