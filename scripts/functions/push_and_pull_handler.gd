extends Node2D
@export var friction:float = 0.0 
@export var character_hold_marker:Marker2D
@export var piviot_node:Node2D
@export var wall_raycast:RayCast2D



var no_friction_materal:PhysicsMaterial
var orignal_material:PhysicsMaterial
var ParentRigidBody:RigidBody2D
var Player_Hold:bool = false
var push_or_pull_vector:Vector2 = Vector2(0,0)
var my_parent:Node
var my_character:CharacterBody2D = null
var character_joint:PinJoint2D
var object_can_move:bool = true
var player_move:bool = true
var orignal_damp:float = 0.0
var grab_offset_x:float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	my_parent = get_parent()
	if my_parent is RigidBody2D:
		if  OS.is_debug_build(): 
			print("Parent %s Is A RigidBody2D" % my_parent)
		ParentRigidBody = my_parent
		orignal_material = ParentRigidBody.physics_material_override
		
		no_friction_materal = PhysicsMaterial.new()
		no_friction_materal.friction = 0.0
		
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
			stop_player_movement_check()
			if object_can_move:
				
				var target_x = my_character.global_position.x + grab_offset_x
				var distance_correction = (target_x - ParentRigidBody.global_position.x) * 25.0

				ParentRigidBody.linear_velocity.x = my_character.intended_velocity.x + distance_correction
				
			else: 
				ParentRigidBody.linear_velocity.x = 0
			

		

func player_interact_movable_object(myobject:Node2D,CharacterNode:CharacterBody2D, is_holding:bool):
	if myobject == my_parent:
		my_character = CharacterNode
		#SignalBus.Input_Is_Busy.emit(is_holding)
		if not my_character.sprite_player.flip_h:
			piviot_node.scale.x = -1
		elif my_character.sprite_player.flip_h:
			piviot_node.scale.x = 1
		set_player_hold(is_holding)
		

		
		
		if OS.is_debug_build():
			print(Player_Hold)
			print("Signal Caputred Successfully")
			print("Recieved Object:", myobject, "\nMy Parnet:", my_parent, "Recieved Character: ", CharacterNode)
		
	else:
		pass
		

func set_player_hold(value:bool):
	Player_Hold = value
	ParentRigidBody.lock_rotation = value
	
	if Player_Hold:

		#my_character.global_position = character_hold_marker.global_position
		if ParentRigidBody:
			ParentRigidBody.linear_damp = 0.0
			
			ParentRigidBody.physics_material_override = no_friction_materal
			grab_offset_x = ParentRigidBody.global_position.x - my_character.global_position.x
		#character_joint = PinJoint2D.new()
		#
		#character_joint.disable_collision = false
		#
		#character_joint.global_position = character_hold_marker.global_position
		#character_joint.node_a = ParentRigidBody.get_path()
		#character_joint.node_b = my_character.get_path()
		#ParentRigidBody.add_child(character_joint)
		
			
	elif not Player_Hold:
		if ParentRigidBody:
				ParentRigidBody.linear_damp = orignal_damp
				ParentRigidBody.physics_material_override = orignal_material
		#if character_joint!= null:
			#character_joint.queue_free()
			
func stop_player_movement_check():
	
	# Make it so that if you push the object into an wall, you don't enter the object
	if wall_raycast.is_colliding():
		#object_can_move = false
		#player_move = false
		if my_character != null:
			pass
			#my_character.velocity.x = 0
	else:
		object_can_move = true
		player_move = true
		
	
	
