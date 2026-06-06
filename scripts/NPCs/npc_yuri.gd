extends Node2D


@export var dialog_key:String = 'default'
var npc_name:String = "Yuri"
var npc_dialog:Dictionary[String, Array] = {
	'default': ["I Love Cake",
		"I want to eat cake all day long",
		"uh.. who are you?",
		"OH! You're the new traveler!",
		"Congratulations on completing this map!",
		"There's nothing ahead as of now",
		"More things will be added to this tutorial map as features increase and time goes on",
		"Well then, I'll see you in the next update!"],
	'fall': ["Did you know that you can fall?",
		"so you did? meh"],
	'dash': ["Did you know that you're invincible while dashing?",
		"Well, Now you do!"],
	'try_pressing_F': ["Maybe try pressing 'F'"],
}
