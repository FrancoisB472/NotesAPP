extends Button
class_name BetterButton

func _ready() -> void:
	await get_tree().process_frame
	pivot_offset = size / 2
	pressed.connect(play_tween)

func play_tween():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)
