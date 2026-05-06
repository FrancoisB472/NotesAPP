extends Node

var current_data: GameThemeData
var current_theme: Theme
var _last_button_color: Color = Color(-1, -1, -1)
var _buttons: Array[Button] = []

func _ready():
	OS.request_permissions()
	call_deferred("_cache_buttons")

func _collect_buttons(node: Node):
	if node is Button:
		_buttons.append(node)

	for c in node.get_children():
		_collect_buttons(c)

func apply(data: GameThemeData):
	if data == null:
		return

	current_data = data

	current_theme = ThemeBuilder.build(data)
	get_tree().root.theme = current_theme

	# only update button tint if needed
	if data.button_bg != _last_button_color:
		_last_button_color = data.button_bg
		_apply_button_tint(data.button_bg)

func _apply_button_tint(color: Color):
	for b in _buttons:
		var sb_normal = b.get_theme_stylebox("normal")
		var sb_hover = b.get_theme_stylebox("hover")
		var sb_pressed = b.get_theme_stylebox("pressed")

		if sb_normal is StyleBoxTexture:
			sb_normal.modulate_color = color

		if sb_hover is StyleBoxTexture:
			sb_hover.modulate_color = color.lightened(0.1)

		if sb_pressed is StyleBoxTexture:
			sb_pressed.modulate_color = color.darkened(0.1)
