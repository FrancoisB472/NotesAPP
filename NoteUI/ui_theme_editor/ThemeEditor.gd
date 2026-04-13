extends Control

@onready var preview_root = $PreviewRoot
@onready var texture_drop = $LeftPanel/TextureDrop
@onready var gallery: Gallery = $Gallery

@onready var bg_picker = $LeftPanel/Color_BG
@onready var text_picker = $LeftPanel/Color_Text
@onready var button_picker = $LeftPanel/Color_Button
@onready var accent_picker = $LeftPanel/Color_Accent
@onready var input_picker = $LeftPanel/Color_Input
@onready var progress_picker = $LeftPanel/Color_Progress

var theme_data: GameThemeData:
	get:
		return ThemeLibrary.get_current()

var editing_index := -1

func _ready() -> void:
	_connect_signals()
	gallery.theme_selected.connect(load_into_editor)
	_apply()

## Signals
func _connect_signals():
	bg_picker.color_changed.connect(_on_bg_changed)
	text_picker.color_changed.connect(_on_text_changed)
	button_picker.color_changed.connect(_on_button_changed)
	accent_picker.color_changed.connect(_on_accent_changed)
	input_picker.color_changed.connect(_on_input_changed)
	progress_picker.color_changed.connect(_on_progress_changed)

## Update Live
func _apply():
	ThemeManager.apply(theme_data)

func _on_bg_changed(c): theme_data.container_bg = c; _apply()
func _on_text_changed(c): theme_data.text_colour = c; _apply()
func _on_button_changed(c): theme_data.button_bg = c; theme_data.button_hover = c.lightened(0.1); theme_data.button_pressed = c.darkened(0.1); _apply()
func _on_accent_changed(c): theme_data.progress_fill = c; _apply()
func _on_input_changed(c): theme_data.input_bg = c; _apply()
func _on_progress_changed(c): theme_data.progress_fill = c; _apply()

## Drag & Drop the texture
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.has("files")

func _drop_data(at_position: Vector2, data: Variant) -> void:
	for f in data["files"]:
		if f.ends_with(".png"):
			var img = Image.load_from_file(f)
			var tex = ImageTexture.create_from_image(img)
			theme_data.container_texture = tex
			_apply()

func load_into_editor(index: int):
	editing_index = index
	theme_data = ThemeLibrary.themes[index]
	_apply()

func _on_save_pressed() -> void:
	DirAccess.make_dir_recursive_absolute("user://themes")
	ResourceSaver.save(theme_data, "user://themes/theme.tres")

func _on_load_pressed() -> void:
	var t = load("user://themes/theme.tres") as GameThemeData
	if t == null:
		return

	ThemeLibrary.add_themes(t)
	ThemeLibrary.select_theme(ThemeLibrary.themes.size() - 1)


func refresh_ui() -> void:
	gallery.refresh_gallery()
