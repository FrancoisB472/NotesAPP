extends Button
class_name BetterButton


func _ready() -> void:
	resized.connect(_update_pivot)
	pressed.connect(play_tween)
	_update_pivot()

func _update_pivot() -> void:
	pivot_offset = size * 0.5

func play_tween() -> void:
	var tween = create_tween()
	tween.set_parallel(false)

	# smooth press down
	tween.tween_property(self, "scale", Vector2(0.5, 0.5), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# smooth release
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
