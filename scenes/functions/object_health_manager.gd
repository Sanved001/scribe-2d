extends Node2D
@export var orignal_health:float = 100
@export var root_node:Node2D
@export var parent_hurtbox:Area2D
@export var invinsible:bool = false


var orignal_pos:Vector2
var m_rigidbody_orignal_linear_velocity:Vector2 = Vector2.ZERO
var m_rigidbody_orignal_angular_velocity:float = 0.0
var grace_period_is_active:bool = false
var damage_grace_period_is_active:bool = false
var calculated_damage:float = 0.0
var health:float = 100

func _ready() -> void:
	SignalBus.Respawn.connect(parent_respawn)
	parent_hurtbox.area_entered.connect(_parent_hurtbox_area_entered)
	
	orignal_pos = root_node.position
	if root_node is RigidBody2D:
		m_rigidbody_orignal_linear_velocity = root_node.linear_velocity
		m_rigidbody_orignal_angular_velocity = root_node.angular_velocity
		
	health = orignal_health
	
func _process(delta: float) -> void:
	pass

func parent_respawn(hard_respawn:bool):
	health = orignal_health
	if root_node is RigidBody2D:
		root_node.linear_velocity = m_rigidbody_orignal_linear_velocity
		root_node.angular_velocity = m_rigidbody_orignal_angular_velocity
		
	elif root_node is CharacterBody2D:
		root_node.velocity = Vector2.ZERO
	else: 
		pass
	
	root_node.position = orignal_pos


func this_object_take_damage(damage: float,source_area: Area2D):
	if damage == 0:
		return
	if grace_period_is_active:
		return
		

	health -= damage


	if health <= 0:
		parent_respawn(false)

func _parent_hurtbox_area_entered(area:Area2D):
	if area is Hitbox:
		if invinsible:
			return
		if damage_grace_period_is_active:
			return
		
		calculated_damage = area.entity_base_damage
		this_object_take_damage(calculated_damage, area)
