extends Node


signal Dialog_Request(npc_name:String, text:Array[String])
signal Input_Is_Busy(value:bool)
signal Dialog_UI_Is_Busy(value:bool)
signal Update_Health_Label(new_label_text:String)
signal Slow_motion_start(scale:float)
signal Slow_motion_stop()
