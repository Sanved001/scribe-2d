extends Node
# None = 0
# Error = 1
# Warn = 2
# log_text = 3
# Notify Player = 4

# All = 999


var Log_Level:int = 999
var Log_Level_Array:Array[String] = ["NONE", "ERROR", "WARN", "LOG", "NOTIFY PLAYER"]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func logging_function(log_text:String, function_level:int, sender:Node,):
	if Log_Level >= function_level:
		print(Log_Level_Array[function_level], ": ", "[%s] " % sender.name ,log_text)



func log_error(log_text:String, sender:Node):
	logging_function(log_text, 1, sender)
	
func log_warn(log_text:String, sender:Node):
	logging_function(log_text, 2, sender)

func write(log_text:String, sender:Node):
	logging_function(log_text, 3, sender)

func notify_player(log_text:String, sender:Node):
	logging_function(log_text,4, sender)
