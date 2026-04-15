extends Control
class_name VirtualWindow

@onready var panel: PanelContainer = $PanelContainer

var dragging := false
var drag_offset := Vector2.ZERO
const TITLE_BAR_HEIGHT := 30

var resizing := false
var resize_dir := Vector2.ZERO
const EDGE := 6

var last_mouse_pos := Vector2.ZERO
func _ready():
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	set_anchor(SIDE_RIGHT, 0, true)
	set_anchor(SIDE_BOTTOM, 0, true)

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var pos := get_local_mouse_position()
		var dir := _get_resize_dir(pos)
		if event.pressed:
			if dir != Vector2.ZERO:
				resizing = true
				resize_dir = dir
			else:
				dragging = true
				drag_offset = get_global_mouse_position() - global_position
		else:
			if dragging or resizing:
				_on_transform_ended()  # virtual — subclasses override this
			dragging = false
			resizing = false
	elif event is InputEventMouseMotion:
		if dragging:
			global_position = get_global_mouse_position() - drag_offset
		elif resizing:
			_resize(event.relative)
		else:
			_update_cursor(get_local_mouse_position())

# Virtual — override in subclasses that need to react to move/resize end
func _on_transform_ended() -> void:
	pass

func _resize(delta: Vector2):
	var new_size := size
	if resize_dir.x == 1:
		new_size.x += delta.x
	elif resize_dir.x == -1:
		new_size.x -= delta.x
		global_position.x += delta.x
	if resize_dir.y == 1:
		new_size.y += delta.y
	elif resize_dir.y == -1:
		new_size.y -= delta.y
		global_position.y += delta.y
	size = new_size.max(Vector2(150, 100))

func _get_resize_dir(pos: Vector2) -> Vector2:
	var dir = Vector2.ZERO
	var s := panel.size
	if pos.x <= EDGE:
		dir.x = -1
	elif pos.x >= s.x - EDGE:
		dir.x = 1
	if pos.y <= EDGE:
		dir.y = -1
	elif pos.y >= s.y - EDGE:
		dir.y = 1
	return dir

func _update_cursor(pos: Vector2):
	var dir = _get_resize_dir(pos)
	if dir == Vector2.ZERO:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	elif dir.x != 0 and dir.y != 0:
		Input.set_default_cursor_shape(Input.CURSOR_FDIAGSIZE)
	elif dir.x != 0:
		Input.set_default_cursor_shape(Input.CURSOR_HSIZE)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_VSIZE)
