extends Node2D
@export var orignal_health:float = 100
@export var root_node:Node2D
@export var parent_hurtbox:Area2D
@export var invinsible:bool = false


var orignal_pos:Vector2
var grace_period_is_active:bool = false
var damage_grace_period_is_active:bool = false
var calculated_damage:float = 0.0
var health:float = 100

func _ready() -> void:
	parent_hurtbox.area_entered.connect(_parent_hurtbox_area_entered)

	orignal_pos = root_node.position
	health = orignal_health
	if root_node is RigidBody2D:
		Log.log_warn("Parent Is A RigidBody", root_node)


func _process(delta: float) -> void:
	pass




func this_object_take_damage(damage: float,source_area: Area2D):
	if damage == 0:
		return
	if grace_period_is_active:
		return
		

	health -= damage


	if health <= 0:
		
		SignalBus.Respawn_Object.emit(root_node, false)
		health = orignal_health
		


func _parent_hurtbox_area_entered(area:Area2D):
	if area is Hitbox:
		if invinsible:
			return
		if damage_grace_period_is_active:
			return
		
		calculated_damage = area.entity_base_damage
		this_object_take_damage(calculated_damage, area)
