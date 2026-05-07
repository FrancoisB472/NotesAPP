extends Control
class_name ThemeEditor

@onready var preview_root = $PanelContainer/VBoxContainer/HBoxContainer/PanelContainer2/MarginContainer/PreviewRoot
@onready var texture_drop = $PanelContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/ScrollContainer/LeftPanel/TextureDrop
@export var gallery: Gallery

@export var bg_picker: ColorPickerButton
@export var text_picker: ColorPickerButton
@export var button_picker: ColorPickerButton
@export var accent_picker: ColorPickerButton
@export var input_picker: ColorPickerButton
@export var progress_picker: ColorPickerButton

@onready var font_size_box: SpinBox = $PanelContainer/VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/ScrollContainer/LeftPanel/VBoxContainer/HBoxContainer7/SpinBox

@onready var delete_popup: PopupPanel = $DeletePopup
@onready var delete_label: Label = $DeletePopup/VBoxContainer/Label

@onready var font_file_dialog: FileDialog = $FontFileDialog
@onready var theme_file_dialog: FileDialog = $ThemeFileDialog
@onready var texture_file_dialog: FileDialog = $TextureFileDialog
@onready var __btn: BetterButton = $"PanelContainer/MarginContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer3/VBoxContainer/•Btn"

var theme_data: GameThemeData
var editing_index := -1
var pending_delete_index := -1
var pending_button_target := ""

enum DropTarget {
	CONTAINER,
	BUTTON_NORMAL,
	BUTTON_HOVER,
	BUTTON_PRESSED
}

var current_drop_target := DropTarget.CONTAINER

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

func _connect_signals():
	bg_picker.color_changed.connect(_on_bg_changed)
	text_picker.color_changed.connect(_on_text_changed)
	button_picker.color_changed.connect(_on_button_changed)
	accent_picker.color_changed.connect(_on_accent_changed)
	input_picker.color_changed.connect(_on_input_changed)
	progress_picker.color_changed.connect(_on_progress_changed)
	font_size_box.value_changed.connect(_on_font_size_changed)

func _apply():
	get_tree().root.theme = null
	await get_tree().process_frame
	ThemeManager.apply_game_theme(theme_data)

func _on_bg_changed(c): theme_data.container_bg = c; _apply()
func _on_text_changed(c): theme_data.text_colour = c; _apply()
func _on_button_changed(c): theme_data.button_bg = c; theme_data.button_hover = c.lightened(0.1); theme_data.button_pressed = c.darkened(0.1); _apply()
func _on_accent_changed(c): theme_data.progress_fill = c; _apply()
func _on_input_changed(c): theme_data.input_bg = c; _apply()
func _on_progress_changed(c): theme_data.progress_fill = c; _apply()
func _on_font_size_changed(value: float): theme_data.font_size = int(value); _apply()

func _on_button_normal_select_pressed():
	pending_button_target = "normal"
	_open_texture_dialog()

func _on_button_hover_select_pressed():
	pending_button_target = "hover"
	_open_texture_dialog()

func _on_button_pressed_select_pressed():
	pending_button_target = "pressed"
	_open_texture_dialog()

func _open_texture_dialog():
	texture_file_dialog.filters = PackedStringArray(["*.png ; PNG Images"])
	texture_file_dialog.popup_centered_ratio()

func handle_button_texture_drop(data: Dictionary):
	for f in data["files"]:
		if f.ends_with(".png"):
			var img = Image.load_from_file(f)
			var tex = ImageTexture.create_from_image(img)

			match current_drop_target:
				DropTarget.BUTTON_NORMAL:
					theme_data.button_texture_normal = tex
				DropTarget.BUTTON_HOVER:
					theme_data.button_texture_hover = tex
				DropTarget.BUTTON_PRESSED:
					theme_data.button_texture_pressed = tex
				_:
					return

			_apply()
			ThemeLibrary.themes[editing_index] = theme_data
			ThemeLibrary.save_all()

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.has("files")

func _drop_data(_pos: Vector2, data: Variant) -> void:
	if typeof(data) != TYPE_DICTIONARY or not data.has("files"):
		return

	for f in data["files"]:
		if f.ends_with(".png"):
			var img = Image.load_from_file(f)
			var tex = ImageTexture.create_from_image(img)
			theme_data.container_texture = tex
			_apply()
			ThemeLibrary.themes[editing_index] = theme_data
			ThemeLibrary.save_all()

func load_into_editor(index: int):
	editing_index = index
	theme_data = ThemeLibrary.themes[index]
	font_size_box.value = theme_data.font_size
	_apply()

func _on_delete_requested(index: int):
	pending_delete_index = index
	delete_label.text = "Delete Theme %d?" % index
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

func _on_texture_file_selected(path: String) -> void:
	if theme_data == null:
		return

	var img := Image.load_from_file(path)
	if img == null:
		return

	var tex := ImageTexture.create_from_image(img)

	match pending_button_target:
		"normal":
			theme_data.button_texture_normal = tex
		"hover":
			theme_data.button_texture_hover = tex
		"pressed":
			theme_data.button_texture_pressed = tex

	_apply()
	ThemeLibrary.themes[editing_index] = theme_data
	ThemeLibrary.save_all()

func _convert_theme_to_game_theme_data(res: Theme) -> GameThemeData:
	var data := GameThemeData.new()

	if res.has_font_size("font_size", "Label"):
		data.font_size = res.get_font_size("font_size", "Label")
	else:
		data.font_size = 16

	if res.has_stylebox("panel", "PanelContainer"):
		var sb = res.get_stylebox("panel", "PanelContainer")
		if sb is StyleBoxFlat:
			data.container_bg = sb.bg_color

	if res.has_stylebox("panel", "Panel"):
		var sb = res.get_stylebox("panel", "Panel")
		if sb is StyleBoxFlat:
			data.container_bg = sb.bg_color

	if res.has_stylebox("normal", "Button"):
		var sb = res.get_stylebox("normal", "Button")
		if sb is StyleBoxFlat:
			data.button_bg = sb.bg_color
			data.button_hover = sb.bg_color.lightened(0.1)
			data.button_pressed = sb.bg_color.darkened(0.1)

	if res.has_stylebox("normal", "LineEdit"):
		var sb = res.get_stylebox("normal", "LineEdit")
		if sb is StyleBoxFlat:
			data.input_bg = sb.bg_color

	if res.has_stylebox("fill", "ProgressBar"):
		var sb = res.get_stylebox("fill", "ProgressBar")
		if sb is StyleBoxFlat:
			data.progress_fill = sb.bg_color

	if res.has_color("font_color", "Label"):
		data.text_colour = res.get_color("font_color", "Label")

	return data

func _on_theme_file_dialog_file_selected(path: String) -> void:
	var res = _safe_load_theme(path)

	if res == null:
		push_warning("Could not load any usable data from: %s" % path)
		return

	var data: GameThemeData

	if res is GameThemeData:
		data = res as GameThemeData  # explicit cast
	elif res is Theme:
		data = _convert_theme_to_game_theme_data(res)
	else:
		push_warning("Unsupported resource type in file: %s" % path)
		return

	ThemeLibrary.themes.append(data)
	var new_index := ThemeLibrary.themes.size() - 1
	ThemeLibrary.current_index = new_index
	ThemeLibrary.save_all()
	gallery.refresh_gallery()
	load_into_editor(new_index)

func _safe_load_theme(path: String) -> Resource:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("Cannot open file: %s" % path)
		return null

	var text := file.get_as_text()
	file.close()

	if not ("res://" in text):
		# Pass type hint so Godot returns the correct typed resource
		var res = ResourceLoader.load(path, "GameThemeData")
		if res != null:
			return res
		# Fallback without type hint in case it's a plain Theme
		res = ResourceLoader.load(path, "Theme")
		if res != null:
			return res

	var data := GameThemeData.new()
	var found_anything := false

	for line in text.split("\n"):
		line = line.strip_edges()

		if line.begins_with("font_size"):
			var val = _parse_value(line)
			if val != "":
				data.font_size = int(val)
				found_anything = true

		elif "bg_color" in line or "background_color" in line:
			var c = _parse_color(line)
			if c != null:
				data.container_bg = c
				found_anything = true

		elif "font_color" in line or "text_color" in line:
			var c = _parse_color(line)
			if c != null:
				data.text_colour = c
				found_anything = true

		elif "button" in line.to_lower() and "color" in line.to_lower():
			var c = _parse_color(line)
			if c != null:
				data.button_bg = c
				data.button_hover = c.lightened(0.1)
				data.button_pressed = c.darkened(0.1)
				found_anything = true

	if not found_anything:
		push_warning("No usable theme data found in: %s" % path)
		return null

	return data

func _parse_value(line: String) -> String:
	var idx = line.find("=")
	if idx == -1:
		return ""
	return line.substr(idx + 1).strip_edges()

func _parse_color(line: String) -> Variant:
	var regex := RegEx.new()
	regex.compile("Color\\(([\\d.]+),\\s*([\\d.]+),\\s*([\\d.]+)(?:,\\s*([\\d.]+))?\\)")
	var result := regex.search(line)
	if result == null:
		return null

	var r := float(result.get_string(1))
	var g := float(result.get_string(2))
	var b := float(result.get_string(3))
	var a := float(result.get_string(4)) if result.get_string(4) != "" else 1.0

	return Color(r, g, b, a)

func _on_btn_select_pressed() -> void:
	theme_file_dialog.filters = PackedStringArray([
		"*.tres ; Theme Resources",
		"*.res ; Binary Resources"
	])
	theme_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	theme_file_dialog.popup_centered_ratio()
