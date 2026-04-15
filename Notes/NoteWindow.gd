extends VirtualWindow
@onready var theme_options: OptionButton = $PanelContainer/MarginContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/ThemeOptions
@onready var save_timer: Timer = $SaveTimer

#region UI Exports
@export var note : Note
@export var title_label : LineEdit
@export var desc : TextEdit
var is_dirty := false
#endregion
var theme_cache: Dictionary = {} # name -> path

func _ready():
	visible = true

	if note:
		position = note.position
		title_label.text = note.title
		desc.text = note.main_text

	title_label.text_changed.connect(_on_title_changed)
	desc.text_changed.connect(_on_desc_changed)

	# FIX 1: connect the timer signal

	load_available_themes()
	apply_initial_theme()

func save_timer_timeout():
	if not is_dirty:
		return
	is_dirty = false
	_on_save_pressed()

func _on_title_changed(new_text: String) -> void:
	if note:
		note.title = new_text
		is_dirty = true
		save_timer.start()  # FIX 2: start the debounce timer

func _on_desc_changed() -> void:
	if note:
		note.main_text = desc.text
		is_dirty = true         # FIX 3: mark dirty
		save_timer.start()      # FIX 3: start timer on desc changes too

func _on_title_lbl_text_submitted(new_text: String) -> void:
	pass

func resolve_theme(note: Note, global_theme: NoteTheme) -> NoteTheme:
	if note.theme_path != "":
		var t = load(note.theme_path)
		if t:
			return t
	return global_theme

func save_note(note: Note):
	var dir = "user://notes/"
	DirAccess.make_dir_recursive_absolute(dir)
	# FIX 4: consistent path with "note_" prefix
	ResourceSaver.save(note, dir + "note_" + note.id + ".tres")

func save_theme(theme: NoteTheme, id: String) -> String:
	var dir := "user://themes/NoteThemes/"
	DirAccess.make_dir_recursive_absolute(dir)
	var path := dir + "theme_" + id + ".tres"
	ResourceSaver.save(theme, path)
	return path

func load_available_themes() -> void:
	theme_options.clear()
	theme_cache.clear()

	var dir_path := "user://themes/NoteThemes/"
	DirAccess.make_dir_recursive_absolute(dir_path)

	var dir := DirAccess.open(dir_path)
	if dir == null:
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if !dir.current_is_dir() and file_name.ends_with(".tres"):
			var theme_name := file_name.get_basename()
			var full_path := dir_path + file_name
			theme_cache[theme_name] = full_path
			theme_options.add_item(theme_name)
		file_name = dir.get_next()

	dir.list_dir_end()

func load_theme(path: String) -> NoteTheme:
	if !FileAccess.file_exists(path):
		return null
	return ResourceLoader.load(path) as NoteTheme

func generate_theme(base: Color) -> NoteTheme:
	var t = NoteTheme.new()
	t.base_color = base
	t.panel_color = base
	t.panel_container_color = base.darkened(0.12)
	t.progress_fill_color = base.lightened(0.25)
	t.progress_bg_color = base.darkened(0.25).lerp(Color.BLACK, 0.2)
	var btn = base
	btn = btn.lightened(0.05)
	btn.s = clamp(btn.s * 0.85, 0.0, 1.0)
	t.button_color = btn
	t.button_hover_color = btn.lightened(0.12)
	t.input_color = base.darkened(0.18).lerp(Color.BLACK, 0.15)
	return t

func build_godot_theme(t: NoteTheme) -> Theme:
	var themea = Theme.new()

	var panel_sb = StyleBoxFlat.new()
	panel_sb.bg_color = t.panel_color
	var panel_container_sb = StyleBoxFlat.new()
	panel_container_sb.bg_color = t.panel_container_color
	themea.set_stylebox("panel", "Panel", panel_sb)
	themea.set_stylebox("panel", "PanelContainer", panel_container_sb)

	var button_normal = StyleBoxFlat.new()
	button_normal.bg_color = t.button_color
	var button_hover = StyleBoxFlat.new()
	button_hover.bg_color = t.button_hover_color
	themea.set_stylebox("normal", "Button", button_normal)
	themea.set_stylebox("hover", "Button", button_hover)

	var input_sb = StyleBoxFlat.new()
	input_sb.bg_color = t.input_color
	themea.set_stylebox("normal", "LineEdit", input_sb)
	themea.set_stylebox("normal", "TextEdit", input_sb)

	var progress_bg = StyleBoxFlat.new()
	progress_bg.bg_color = t.progress_bg_color
	var progress_fill = StyleBoxFlat.new()
	progress_fill.bg_color = t.progress_fill_color
	themea.set_stylebox("background", "ProgressBar", progress_bg)
	themea.set_stylebox("fill", "ProgressBar", progress_fill)

	return themea

func _on_color_picker_button_color_changed(color: Color) -> void:
	if note == null:
		return
	var note_theme := generate_theme(color)
	var path = save_theme(note_theme, "note_" + note.id)
	note.theme_path = path
	save_note(note)
	apply_theme(note_theme)

func apply_theme(t: NoteTheme) -> void:
	if t == null:
		return
	self.theme = build_godot_theme(t)

func _on_delete_pressed() -> void:
	if note == null:
		return
	# Delete note file
	var note_path := "user://notes/note_" + note.id + ".tres"
	if FileAccess.file_exists(note_path):
		DirAccess.remove_absolute(note_path)
	# Delete associated theme file
	if note.theme_path != "" and FileAccess.file_exists(note.theme_path):
		DirAccess.remove_absolute(note.theme_path)
	queue_free()

func _on_save_pressed() -> void:
	if note == null:
		return

	var note_dir := "user://notes/"
	var theme_dir := "user://themes/NoteThemes/"
	DirAccess.make_dir_recursive_absolute(note_dir)
	DirAccess.make_dir_recursive_absolute(theme_dir)

	# FIX 4: consistent path
	var note_path := note_dir + "note_" + note.id + ".tres"
	ResourceSaver.save(note, note_path)

	if note.theme_path != "":
		var themes := load(note.theme_path)
		if themes:
			var theme_id := note.theme_path.get_file().get_basename()
			var theme_path := theme_dir + theme_id + ".tres"
			ResourceSaver.save(themes, theme_path)  # FIX 5: was `theme`, now `themes`

func _on_theme_options_item_selected(index: int) -> void:
	var theme_name = theme_options.get_item_text(index)
	if !theme_cache.has(theme_name):
		return
	var path = theme_cache[theme_name]
	var theme_resource = load(path)
	if theme_resource == null:
		return
	if note:
		note.theme_path = path
		save_note(note)
	apply_theme(theme_resource)

func apply_initial_theme():
	if note == null:
		return
	if note.theme_path != "":
		var note_theme = load(note.theme_path)
		if note_theme:
			apply_theme(note_theme)
			# FIX 6: OptionButton has no get_item_index(name) — iterate manually
			var theme_name = note.theme_path.get_file().get_basename()
			for i in theme_options.item_count:
				if theme_options.get_item_text(i) == theme_name:
					theme_options.select(i)
					break

func load_note(id: String) -> Note:
	# FIX 4: consistent path with "note_" prefix
	var path := "user://notes/note_" + id + ".tres"
	if !FileAccess.file_exists(path):
		return null
	return ResourceLoader.load(path) as Note

func _on_transform_ended() -> void:
	if note == null:
		return
	note.position = global_position
	note.size = size
	DirAccess.make_dir_recursive_absolute("user://notes/")
	ResourceSaver.save(note, "user://notes/note_" + note.id + ".tres")
