extends Node2D
@export var animation_player:AnimationPlayer
@export var animation_speed:float = 1.0

var animation_playing_speed:float = 0.0
var stop_animation_at_start:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.Stop_Saw_Blade.connect(m_Stop_Saw_Blade)
	animation_player.play("move")
	animation_player.speed_scale = animation_speed
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if stop_animation_at_start:
		if animation_player.current_animation_position <= 0.01:
			animation_playing_speed = animation_player.get_playing_speed()
			animation_player.stop()


func m_Stop_Saw_Blade(m_saw_blade:Node2D, value:bool, stop_at_start:bool):
	if m_saw_blade == self:
		if value:
			if stop_at_start:
				stop_animation_at_start = true
			else:
				animation_playing_speed = animation_player.get_playing_speed()
				animation_player.pause()
		else:
			if animation_playing_speed > 0:
				stop_animation_at_start = false
				animation_player.play("move")
			if animation_playing_speed < 0:
				stop_animation_at_start = false
				animation_player.play_backwards("move")
