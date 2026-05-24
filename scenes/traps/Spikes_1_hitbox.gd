extends Hitbox

func _ready() -> void:
	entity_name = "spikes_1"
	entity_type = "trap"
	entity_base_damage = 10000
	entity_damage_type = "physical"
	entity_knockback_strength = 200
