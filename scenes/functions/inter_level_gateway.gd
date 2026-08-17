extends Node2D
@export var change_scene_to:String
@onready var interact_area: Area2D = $InteractArea

var player_near:bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.Player_Interact.connect(Player_Interact)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#if player_near:
		#if Input.is_action_just_pressed("interact"):
			#SignalBus.ChangeCurrentScene.emit("res://scenes/Levels/test_level.tscn", true, true)


#signal Player_Interact(interact_object:Node, value:bool)
func Player_Interact(interact_object:Node, value:bool):
	if interact_object == interact_area:
		Log.write("Player Interact recieved", self)
		SignalBus.ChangeCurrentScene.emit(change_scene_to, "idk", true, false)
	

func _on_interact_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	player_near = true
	Log.write("Player entered Interaction Zone", self)


func _on_interact_area_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	player_near = false
	Log.write("Player left Interaction Zone", self)
