extends CanvasLayer
@onready var main_panel: Panel = $"Main Panel"
@onready var credits_node: Control= $"Credits Node"

var credit_scroll_speed:int = 60
var are_credits_playing:bool = false
var can_play_credits:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	
	
	if can_play_credits:
		credit_scroll_speed = 60
		if Input.is_action_pressed("dash"):
			credit_scroll_speed = 180
		if Input.is_action_just_pressed("escape"):
			main_panel.visible = true
			credits_node.position.y = 650
			can_play_credits = false
			
		
	if can_play_credits:
		play_credits(delta)


func play_credits(delta:float):
	main_panel.visible = false
	credits_node.position.y -= credit_scroll_speed * delta


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _on_credits_pressed() -> void:
	can_play_credits = true


func _on_quit_pressed() -> void:
	get_tree().quit()
