extends Hitbox
	

func _ready() -> void:
		entity_name = "saw_blade"
		entity_type = "trap"
		entity_base_damage = 100
		entity_damage_type = "physical"
		entity_knockback_strength = 200
