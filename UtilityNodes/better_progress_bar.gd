extends ProgressBar
class_name BetterProgressBar

@export var tween_duration : float = 0.35

func set_smooth_value(changed_value: float) -> void:
	changed_value = clamp(changed_value, min_value, max_value)
	
	var tween : Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.set_parallel(false)
	
	tween.tween_property(self, "value", changed_value, 0.5)
