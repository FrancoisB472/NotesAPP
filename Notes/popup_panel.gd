extends PopupPanel

func _on_ok_btn_pressed() -> void:
	self.close_requested
	self.visible = false

func _on_cancel_btn_pressed() -> void:
	self.close_requested
	self.visible = false
