extends Node2D

@export var trigger_area_collider_size:Vector2 
@export var change_scene_to:String
@export var ClearPrevious:bool = false

@onready var trigger_area: Area2D = $TriggerArea
@onready var trigger_area_collider: CollisionShape2D = $TriggerArea/TriggerAreaCollider




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trigger_area_collider.shape.size =  trigger_area_collider_size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_trigger_area_area_entered(area: Area2D) -> void:
	SignalBus.ChangeCurrentScene.emit(change_scene_to, "change level", ClearPrevious)
