extends CanvasLayer

@export var Health_Label:Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.Update_Health_Label.connect(update_health_label)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update_health_label(text_to_update:String):
	Health_Label.text = text_to_update
