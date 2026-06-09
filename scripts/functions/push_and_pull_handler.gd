extends Node2D
@export var friction:float = 0.0 

var ParentRigidBody:RigidBody2D
var Player_Hold:bool = false
var push_or_pull_vector:Vector2 = Vector2(0,0)
var my_parent:Node
var my_character:CharacterBody2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	my_parent = get_parent()
	if my_parent is RigidBody2D:
		if  OS.is_debug_build(): 
			print("Parent %s Is A RigidBody2D" % my_parent)
		ParentRigidBody = my_parent
	elif not my_parent is RigidBody2D and OS.is_debug_build():
		print("Parent %s Is Not A RigidBody2D It may cause errors" % my_parent)
	
	SignalBus.Player_Interact_Movable_Object.connect(player_interact_movable_object)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
		#push_or_pull_vector = my_character.velocity
	#if Player_Hold:
		#if Input.is_action_pressed("right"):
			#ParentRigidBody.apply_force(push_or_pull_vector)
		#if Input.is_action_pressed("left"):
			#ParentRigidBody.apply_force(push_or_pull_vector)
			
			

func _physics_process(delta: float) -> void:
	if my_character != null:
		if Player_Hold:
			ParentRigidBody.linear_velocity.x = my_character.intended_velocity.x

func player_interact_movable_object(myobject:Node2D,CharacterNode:CharacterBody2D, is_holding:bool):
	if myobject == my_parent:
		set_player_hold(is_holding)
		if OS.is_debug_build():
			print(Player_Hold)
			print("Signal Caputred Successfully")
			print("Recieved Object:", myobject, "\nMy Parnet:", my_parent, "Recieved Character: ", CharacterNode)
		my_character = CharacterNode
		
	else:
		pass
		

func set_player_hold(value:bool):
	Player_Hold = value
