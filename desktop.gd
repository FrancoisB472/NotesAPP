extends Control
@export var click_mask_texture: Texture2D

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if _is_click_through(event.position):
			accept_event()
			get_viewport().set_input_as_handled()

func _is_click_through(local_pos: Vector2) -> bool:
	if click_mask_texture == null:
		return false

	var img := click_mask_texture.get_image()
	if img == null:
		return false

	var uv := local_pos / size
	var px := Vector2i(uv.x * img.get_width(), uv.y * img.get_height())

	if px.x < 0 or px.y < 0 or px.x >= img.get_width() or px.y >= img.get_height():
		return true

	var alpha := img.get_pixel(px.x, px.y).a
	return alpha < 0.1
