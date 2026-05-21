extends CanvasLayer


@onready var name_label: Label = $PanelContainer/MarginContainer/VBoxContainer/NameLabel
@onready var body_label: Label = $PanelContainer/MarginContainer/VBoxContainer/BodyLabel
var Debug_Mode:bool = false





var Current_Lines: Array[String] = []
var Is_Active: bool = false
var Line_Index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	SignalBus.Dialog_Request.connect(_on_dialog_recieved)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_dialog_recieved(Speaker_Name:String, Dialog_Lines:Array[String]):
	if Is_Active:
		print("Dialog already running")
		return
		
	if Debug_Mode:
		print("DEBUG: Dialog Recieved from:", Speaker_Name, " With Data:", Dialog_Lines)
	
	if Dialog_Lines.size() == 0:
		print("ERROR: Dialog signal recieved but the Dialog Arrey is Empty!")
		return
		
	SignalBus.Input_Is_Busy.emit(true)
	SignalBus.Dialog_UI_Is_Busy.emit(false)
	Is_Active = true
	visible = true
	Current_Lines = Dialog_Lines.duplicate()
	Line_Index = 0
	
	name_label.text = Speaker_Name
	update_dialog_box()
	
func update_dialog_box():
	body_label.text = Current_Lines[Line_Index]
	
	
func _input(event: InputEvent) -> void:
	if not Is_Active:
		return
	
	
	if Input.is_action_just_pressed("interact"):
		get_viewport().set_input_as_handled()
		Line_Index += 1
		
		# If lines are remaining, goto next line
		if Line_Index < Current_Lines.size():
			update_dialog_box()
		else:
			# No more lines Left
			close_dialog_box()
			
			
func close_dialog_box() -> void:
	Is_Active = false
	visible = false
	Current_Lines.clear()
	SignalBus.Input_Is_Busy.emit(false)
	SignalBus.Dialog_UI_Is_Busy.emit(false)
