extends Hitbox

#var entity_name:String
#var entity_type:String
#var entity_base_damage:int
#var entity_damage_type:String
#var entity_knockback_strength:float = 200.0




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	entity_name = "player"
	entity_type = "player"
	entity_base_damage = 10
	entity_damage_type = "physical"
	entity_knockback_strength = 200


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
