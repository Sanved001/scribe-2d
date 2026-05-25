extends Node2D
@onready var hurt_box_collision_shape: CollisionShape2D = $entity_hurtbox/HurtBoxCollisionShape

@export var entity_hurtbox_collider_size:Vector2 
@export var health:float = 100
@export var Damage_Ressistance_physical:float = 0.0
@export var Damage_Ressistance_acid:float = 0.0



var grace_period_is_active:bool = false
var calculated_damage:float = 0.0
var entity_velocity = Vector2(0.0, 0.0)









# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hurt_box_collision_shape.shape.size = entity_hurtbox_collider_size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass








func this_entity_take_damage(damage: float,source_area: Area2D):
	if damage == 0:
		return
	if grace_period_is_active:
		return
		

	health -= damage
	if source_area != null:
		var knockback_direction = global_position - source_area.global_position
		knockback_direction = knockback_direction.normalized()
		entity_velocity = knockback_direction * source_area.entity_knockback_strength
		entity_velocity.y -= 1 # MAKE THE PLAYER JUMP EVEN IF AT 0 Y VELOCITY
		if entity_velocity.x != 0:
			var sign_x = sign(entity_velocity.x)
			if abs(entity_velocity.x) < 200:
				entity_velocity.x = sign_x * 200
		
		if entity_velocity.y != 0:
			var sign_y = sign(entity_velocity.y)
			if abs(entity_velocity.y) < 200:
				entity_velocity.y = sign_y * 200
		
		if entity_velocity.y == 0:
			entity_velocity.y = -200
		if entity_velocity.x == 0:
			if global_position.x >= source_area.global_position.x:
				entity_velocity.x = 200 # move right
			else: 
				entity_velocity.x = -200 # move left

	if health <= 0:
		pass

	
	






func _on_entity_hurtbox_area_entered(area: Area2D) -> void:
	if not area is Hitbox:
		return
	if grace_period_is_active:
		return
	if area.damage_type == "fixed":
		this_entity_take_damage(area.entity_base_damage, area)
	elif area.damage_type == "god":
		this_entity_take_damage(area.entity_base_damage, area)
	
	match area.damage_type:
		"physical": 
			calculated_damage = area.entity_base_damage - (area.entity_base_damage * Damage_Ressistance_physical)
			this_entity_take_damage(calculated_damage, area)
		"acid":
			calculated_damage = area.entity_base_damage - (area.entity_base_damage * Damage_Ressistance_acid)
			this_entity_take_damage(calculated_damage, area)
