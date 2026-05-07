extends Node

var current_theme_resource: AppTheme
var current_theme: Theme
var _buttons: Array[Button] = []

func _ready():
	OS.request_permissions()
	call_deferred("_cache_buttons")

func _cache_buttons():
	_buttons.clear()
	_collect_buttons(get_tree().root)

func _collect_buttons(node: Node):
	if node is Button:
		_buttons.append(node)
	for c in node.get_children():
		_collect_buttons(c)

func apply(app_theme: AppTheme):
	if app_theme == null:
		return
	current_theme_resource = app_theme
	match app_theme.type:
		AppTheme.ThemeType.CUSTOM:
			_apply_custom(app_theme.custom_data)
		AppTheme.ThemeType.GODOT:
			_apply_godot(app_theme.godot_theme)

func apply_game_theme(data: GameThemeData):
	if data == null:
		return
	_apply_custom(data)

func _apply_custom(data: GameThemeData):
	if data == null:
		return
	var theme = ThemeBuilder.build(data)
	get_tree().root.theme = theme
	_cache_buttons()  # refresh before tinting — nodes may have changed
	_apply_button_tint(data.button_bg)

func _apply_godot(theme: Theme):
	if theme == null:
		return
	get_tree().root.theme = theme

func _apply_button_tint(color: Color):
	# Rebuild a clean list, skipping any freed instances
	var live: Array[Button] = []
	for b in _buttons:
		if is_instance_valid(b):
			live.append(b)
	_buttons = live

	for b in _buttons:
		var sb_normal = b.get_theme_stylebox("normal")
		var sb_hover  = b.get_theme_stylebox("hover")
		var sb_pressed = b.get_theme_stylebox("pressed")

		if sb_normal is StyleBoxTexture:
			sb_normal.modulate_color = color
		if sb_hover is StyleBoxTexture:
			sb_hover.modulate_color = color.lightened(0.1)
		if sb_pressed is StyleBoxTexture:
			sb_pressed.modulate_color = color.darkened(0.1)
