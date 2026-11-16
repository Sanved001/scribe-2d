extends CanvasLayer

@export var Health_Label:Label
@export var HealthBar_Foreground:ColorRect
@export var HealthBar_Background:ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.Update_Health_Label.connect(update_health_label)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update_health_label(health:float, anim:bool = true):
	Health_Label.text = "Health: %d" % health
	var healthPercent = health / 100.0
	
	if healthPercent <= .3:
		HealthBar_Foreground.color = Color("#FF5050")
	else:
		HealthBar_Foreground.color = Color("#50FF50")
	
	if anim:
		var fgAnimation = create_tween()
		fgAnimation.tween_property(HealthBar_Foreground, "scale", Vector2(healthPercent, 1.0), .4) \
			.set_trans(Tween.TRANS_LINEAR) \
			.set_ease(Tween.EASE_OUT)
			
		var bgAnimation = create_tween()
		bgAnimation.tween_property(HealthBar_Background, "scale", Vector2(healthPercent, 1.0), .4) \
			.set_trans(Tween.TRANS_LINEAR) \
			.set_ease(Tween.EASE_OUT) \
			.set_delay(0.4)
	else:
		HealthBar_Foreground.scale = Vector2(healthPercent, 1.0)
		HealthBar_Background.scale = Vector2(healthPercent, 1.0)
