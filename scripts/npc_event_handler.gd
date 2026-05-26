extends Node2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var interaction_Prompt: Control = $Interaction_Prompt

@export var Character_Sprite:Sprite2D
@export var npc_collision_padding:Vector2 = Vector2(0,0)
@export var npc_Animation_Player:AnimationPlayer 
#@export var npc_dialog_key:String = "default"


var Debug_Mode:bool = OS.is_debug_build()
var player_in_range:bool = false
var Character_Sprite_initial_position:Vector2 = Vector2(0,0)
var FIP_tween: Tween
var npc_root
var interaction_cooldown_active:bool = false
var Dialog_UI_Is_Busy:bool = false












# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	npc_root = get_parent()
	var npc_texture_size = Character_Sprite.texture.get_size()
	var npc_actual_size = npc_texture_size * Character_Sprite.scale
	
	if collision_shape_2d.shape is RectangleShape2D:
		collision_shape_2d.shape.size = npc_actual_size + npc_collision_padding
	else: print("ERROR: in npc_even_handler.gd: No Compatible Collision Shape [Compatible Collision Shapes: RectangleShape2d]")
	
	interaction_Prompt.visible = false
	interaction_Prompt.position.x = 0
	interaction_Prompt.position.y = -( npc_actual_size.y ) - 10
	
	Character_Sprite_initial_position = interaction_Prompt.position
	
	SignalBus.Dialog_UI_Is_Busy.connect(Is_Dialog_UI_Busy)

	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		if Debug_Mode:
			print("DEBUG: NPC Interact:", Character_Sprite.name)
		npc_interact()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if Debug_Mode:
			print("DEBUG: Player Entered Interaction Zone Of:", Character_Sprite.name)
	
	player_in_range = true
	npc_Animation_Player.play("glow_idle")
	interaction_Prompt.visible = true
	Floating_Interaction_Prompt()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if Debug_Mode:
			print("DEBUG: Player Exited Interaction Zone Of:", Character_Sprite.name)
	player_in_range = false
	npc_Animation_Player.play("idle")
	interaction_Prompt.visible = false
	
	# Kill the FIP_Tween to save resources
	if FIP_tween and FIP_tween.is_valid():
		FIP_tween.kill()
	
func Floating_Interaction_Prompt() -> void:
	if not interaction_Prompt:
		return
		
	# If The Tween is already running, kill it
	if FIP_tween and FIP_tween.is_valid():
		FIP_tween.kill()
		
	# FIP = Floating Interaction Prompt
	# Original y Position
	var FIP_base_y:float = Character_Sprite_initial_position.y
	# The lowest the Prompt will go with respect to orignal Y position
	var FIP_Lowest_y:float = FIP_base_y + 5
	# Loop
	FIP_tween = create_tween().set_loops()
	
	# Downwards; Start Slow -> Fast -> End Slow
	FIP_tween.tween_property(interaction_Prompt, "position:y", FIP_Lowest_y, 1)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	#Upwardss; Start SLow -> Fast -> End Slow
	FIP_tween.tween_property(interaction_Prompt, "position:y", FIP_base_y, 1)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		

func Is_Dialog_UI_Busy(value):
	if value == true:
		Dialog_UI_Is_Busy = true
	else:
		Dialog_UI_Is_Busy = true
		await get_tree().create_timer(2).timeout
		Dialog_UI_Is_Busy = false
		


func interaction_cooldown_start():
	interaction_cooldown_active = true
	await get_tree().create_timer(0.2).timeout
	interaction_cooldown_active = false

		
func npc_interact():
	if not interaction_cooldown_active:
		if not Dialog_UI_Is_Busy:
			if "npc_dialog" in npc_root:
				var my_dialog_array:Array[String] = []
				var npc_dialog_key = npc_root.dialog_key
				my_dialog_array.assign(npc_root.npc_dialog[npc_dialog_key])
				if Debug_Mode:
					print("DEBUG: Emitting npc_name:", npc_root.npc_name, " Emitting Dialog Array:", my_dialog_array)
				interaction_cooldown_start()
				SignalBus.Dialog_Request.emit(npc_root.npc_name, my_dialog_array)
