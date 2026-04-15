extends Control

@onready var preview_root = $PanelContainer/VBoxContainer/HBoxContainer/PanelContainer2/MarginContainer/PreviewRoot
@onready var texture_drop = $PanelContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/ScrollContainer/LeftPanel/TextureDrop
@export var gallery: Gallery

@export var bg_picker : ColorPickerButton
@export var text_picker : ColorPickerButton
@export var button_picker : ColorPickerButton
@export var accent_picker : ColorPickerButton
@export var input_picker : ColorPickerButton
@export var progress_picker : ColorPickerButton
@onready var font_size_box: SpinBox = $PanelContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/ScrollContainer/LeftPanel/VBoxContainer/HBoxContainer7/SpinBox

@onready var delete_popup: PopupPanel = $DeletePopup
@onready var delete_label: Label = $DeletePopup/VBoxContainer/Label


@onready var font_file_dialog: FileDialog = $FontFileDialog

var theme_data: GameThemeData

var editing_index := -1
var pending_delete_index := -1

func _ready() -> void:
	_connect_signals()

	gallery.theme_selected.connect(load_into_editor)
	gallery.delete_requested.connect(_on_delete_requested)

	ThemeLibrary.ensure_valid_theme()
	ThemeLibrary.load_all()

	if ThemeLibrary.themes.size() > 0:
		ThemeLibrary.select_theme(0)
		load_into_editor(0)
	else:
		var idx = ThemeLibrary.create_new_theme()
		load_into_editor(idx)

	gallery.refresh_gallery()

	theme_data = ThemeLibrary.get_current()
	_apply()


## Signals
func _connect_signals():
	bg_picker.color_changed.connect(_on_bg_changed)
	text_picker.color_changed.connect(_on_text_changed)
	button_picker.color_changed.connect(_on_button_changed)
	accent_picker.color_changed.connect(_on_accent_changed)
	input_picker.color_changed.connect(_on_input_changed)
	progress_picker.color_changed.connect(_on_progress_changed)
	font_size_box.value_changed.connect(_on_font_size_changed)

## Update Live
func _apply():
	ThemeManager.apply(theme_data)

func _on_bg_changed(c): theme_data.container_bg = c; _apply()
func _on_text_changed(c): theme_data.text_colour = c; _apply()
func _on_button_changed(c): theme_data.button_bg = c; theme_data.button_hover = c.lightened(0.1); theme_data.button_pressed = c.darkened(0.1); _apply()
func _on_accent_changed(c): theme_data.progress_fill = c; _apply()
func _on_input_changed(c): theme_data.input_bg = c; _apply()
func _on_progress_changed(c): theme_data.progress_fill = c; _apply()
func _on_font_size_changed(value: float): theme_data.font_size = int(value); _apply()

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

	font_size_box.value = theme_data.font_size

	_apply()

func _on_delete_requested(index: int):
	pending_delete_index = index

	var theme_name = "Theme %d" % index
	delete_label.text = "Delete %s?" % theme_name

	delete_popup.popup_centered()

func _on_save_pressed() -> void:
	if theme_data == null:
		return

	ThemeLibrary.themes[editing_index] = theme_data

	ThemeLibrary.save_all()

func _on_load_pressed() -> void:
	ThemeLibrary.load_all()

	gallery.refresh_gallery()

	if ThemeLibrary.themes.size() > 0:
		ThemeLibrary.select_theme(0)
		load_into_editor(0)

func refresh_ui() -> void:
	gallery.refresh_gallery()


func _on_new_theme_pressed() -> void:
	var index = ThemeLibrary.create_new_theme()

	gallery.refresh_gallery()
	load_into_editor(index)


func _on_btn_yes_pressed() -> void:
	if pending_delete_index < 0:
		return

	ThemeLibrary.themes.remove_at(pending_delete_index)

	# Fix selection after deletion
	if ThemeLibrary.themes.is_empty():
		ThemeLibrary.ensure_valid_theme()

	ThemeLibrary.select_theme(clamp(pending_delete_index, 0, ThemeLibrary.themes.size() - 1))

	delete_popup.hide()
	gallery.refresh_gallery()
	load_into_editor(ThemeLibrary.current_index)

func _on_btn_no_pressed() -> void:
	pending_delete_index = -1
	delete_popup.hide()

func _on_font_file_button_pressed() -> void:
	font_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	font_file_dialog.filters = PackedStringArray(["*.ttf ; TrueType Font", "*.otf ; OpenType Font"])
	font_file_dialog.popup_centered_ratio()

func _on_font_file_dialog_file_selected(path: String) -> void:
	if theme_data == null:
		return

	theme_data.font_path = path
	_apply()
