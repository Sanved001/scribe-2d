extends Node2D
@export var max_left:float = 0.0
@export var max_right:float = 0.0
@export var max_top:float = 0.0
@export var max_bottom:float = 0.0
enum  starting_position_enum {max_left, max_right, max_top, max_bottom}
@export var starting_position: starting_position_enum = starting_position_enum.max_left 
@export var travel_time:float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x = starting_position
	animate_sawblade()

func animate_sawblade() -> void:
	var tween = create_tween()
	
	# Set the tween to loop infinitely
	tween.set_loops()
	
	# Step 1: Move to max_right (Smooth start, smooth stop)
	tween.tween_property(self, "position:x", max_right, travel_time)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN_OUT)
		
	# Step 2: Move back to max_left (Smooth start, smooth stop)
	tween.tween_property(self, "position:x", max_left, travel_time)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN_OUT)
