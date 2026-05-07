extends VirtualWindow

# Paths match NoteUI.tscn exactly.
@onready var theme_options: OptionButton = $PanelContainer/MarginContainer/Panel/MarginContainer/VBoxContainer/ThemeOptions
@onready var save_timer: Timer = $SaveTimer
@onready var title_label: LineEdit = $PanelContainer/MarginContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/Title_Lbl
@onready var desc: TextEdit = $PanelContainer/MarginContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer3/SpellcheckTextEdit
@onready var progress_bar: BetterProgressBar= $PanelContainer/MarginContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer2/ProgressBar
@onready var popup_panel: PopupPanel = $PopupPanel
@onready var font_spin_box: SpinBox = $PanelContainer/MarginContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer/HBoxContainer/SpinBox

@export var note: Note

var is_dirty := false
var theme_cache: Dictionary = {}
var completed : bool = false

var faces : Array[String] = [
	"(☞ ͡° ͜ʖ ͡°)☞",
	"( ͡° ͜ʖ ͡°)",
	"( •̯́ ₃ •̯̀)",
	"(*ᴗ͈ˬᴗ͈)ꕤ*.ﾟ",
	"ദ്ദി ˉ͈̀꒳ˉ͈́ )✧",
	"◉‿◉",
	"(¬_¬\")",
	"▶• ılıılıılıılıılıılı. 0",
	"(づ ᴗ _ᴗ)づ♡",
	"(⊙_⊙)",
	"≽^•⩊•^≼",
	"ᐠ( ᐛ )ᐟ",
	"(╥﹏╥)",
	"˙◠˙",
	"☆⋆｡𖦹°‧★",
	"⋆˖⁺‧₊☽◯☾₊‧⁺˖⋆",
	"🐮",
	"🦖",
	"🦕",
	"🐍",
	"💀",
	"ඞ",
	"🦍💨",
]
var random_face : String

func _ready():
	super()
	random_face = faces[randi() % faces.size()]
	if note:
		position = Vector2i(note.position)
		if note.size != Vector2.ZERO:
			size = Vector2i(note.size)
		title = note.title
		title_label.text = note.title
		desc.text = note.main_text

	title_label.text_changed.connect(_on_title_changed)
	desc.text_changed.connect(_on_desc_changed)
	save_timer.timeout.connect(_on_save_timer_timeout)

	# Persist when the OS window moves/resizes/closes.
	close_requested.connect(_on_close_requested)
	size_changed.connect(_on_window_size_changed)
	clamp(progress_bar.value, 0, 100)

	load_available_themes()
	apply_initial_theme()

#  Persistence 

func _process(_delta: float) -> void:
	if progress_bar.value == 100.0 and completed == false:
		popup_panel.visible = true
		completed = true

func _on_save_timer_timeout():
	if is_dirty:
		is_dirty = false
		_on_save_pressed()

func _on_title_changed(new_text: String):
	if note:
		note.title = str("%s %s" % [random_face, new_text])
		title = str("%s %s" % [random_face, new_text])
		is_dirty = true
		save_timer.start()

func _on_desc_changed():
	if note:
		note.main_text = desc.text
		is_dirty = true
		save_timer.start()

func _on_window_size_changed():
	if note:
		note.size = Vector2(size)
		is_dirty = true
		save_timer.start()

func _on_close_requested():
	if note:
		note.position = Vector2(position)
		note.size = Vector2(size)
		_on_save_pressed()
	queue_free()

func _on_save_pressed():
	if note == null:
		return
	note.position = Vector2(position)
	note.size = Vector2(size)
	var dir := "user://notes/"
	DirAccess.make_dir_recursive_absolute(dir)
	ResourceSaver.save(note, dir + "note_" + note.id + ".tres")

#  Theme helpers 

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
			theme_cache[theme_name] = dir_path + file_name
			theme_options.add_item(theme_name)
		file_name = dir.get_next()
	dir.list_dir_end()

func generate_theme(base: Color) -> NoteTheme:
	var t = NoteTheme.new()
	t.base_color = base
	t.panel_color = base
	t.panel_container_color = base.darkened(0.12)
	t.progress_fill_color = base.lightened(0.25)
	t.progress_bg_color = base.darkened(0.25).lerp(Color.BLACK, 0.2)
	var btn = base.lightened(0.05)
	btn.s = clamp(btn.s * 0.85, 0.0, 1.0)
	t.button_color = btn
	t.button_hover_color = btn.lightened(0.12)
	t.input_color = base.darkened(0.18).lerp(Color.BLACK, 0.15)
	return t

func build_godot_theme(t: NoteTheme) -> Theme:
	var themea = Theme.new()
	var panel_sb = StyleBoxFlat.new(); panel_sb.bg_color = t.panel_color
	var panel_c_sb = StyleBoxFlat.new(); panel_c_sb.bg_color = t.panel_container_color
	themea.set_stylebox("panel", "Panel", panel_sb)
	themea.set_stylebox("panel", "PanelContainer", panel_c_sb)
	var btn_n = StyleBoxFlat.new(); btn_n.bg_color = t.button_color
	var btn_h = StyleBoxFlat.new(); btn_h.bg_color = t.button_hover_color
	themea.set_stylebox("normal", "Button", btn_n)
	themea.set_stylebox("hover", "Button", btn_h)
	var input_sb = StyleBoxFlat.new(); input_sb.bg_color = t.input_color
	themea.set_stylebox("normal", "LineEdit", input_sb)
	themea.set_stylebox("normal", "TextEdit", input_sb)
	var pb_bg = StyleBoxFlat.new(); pb_bg.bg_color = t.progress_bg_color
	var pb_fill = StyleBoxFlat.new(); pb_fill.bg_color = t.progress_fill_color
	themea.set_stylebox("background", "ProgressBar", pb_bg)
	themea.set_stylebox("fill", "ProgressBar", pb_fill)
	
	themea.set_font_size("font_size", "Label", font_spin_box.value)
	
	return themea

func save_theme(t: NoteTheme, id: String) -> String:
	var dir := "user://themes/NoteThemes/"
	DirAccess.make_dir_recursive_absolute(dir)
	var path := dir + "theme_" + id + ".tres"
	ResourceSaver.save(t, path)
	return path

func save_note(n: Note):
	var dir = "user://notes/"
	DirAccess.make_dir_recursive_absolute(dir)
	ResourceSaver.save(n, dir + "note_" + n.id + ".tres")

func apply_theme(t: NoteTheme) -> void:
	if t == null:
		return
	self.theme = build_godot_theme(t)

func apply_initial_theme():
	if note == null or note.theme_path == "":
		return
	var note_theme = load(note.theme_path)
	if note_theme:
		apply_theme(note_theme)
		var theme_name = note.theme_path.get_file().get_basename()
		for i in theme_options.item_count:
			if theme_options.get_item_text(i) == theme_name:
				theme_options.select(i)
				break

#  UI signals 

func _on_color_picker_button_color_changed(color: Color) -> void:
	if note == null:
		return
	var note_theme := generate_theme(color)
	var path = save_theme(note_theme, "note_" + note.id)
	note.theme_path = path
	save_note(note)
	apply_theme(note_theme)

func _on_delete_pressed() -> void:
	if note == null:
		return
	var note_path := "user://notes/note_" + note.id + ".tres"
	if FileAccess.file_exists(note_path):
		DirAccess.remove_absolute(note_path)
	if note.theme_path != "" and FileAccess.file_exists(note.theme_path):
		DirAccess.remove_absolute(note.theme_path)
	queue_free()

func _on_theme_options_item_selected(index: int) -> void:
	var theme_name = theme_options.get_item_text(index)
	if !theme_cache.has(theme_name):
		return
	var theme_resource = load(theme_cache[theme_name])
	if theme_resource == null:
		return
	if note:
		note.theme_path = theme_cache[theme_name]
		save_note(note)
	apply_theme(theme_resource)

func resolve_theme(n: Note, global_theme: NoteTheme) -> NoteTheme:
	if n.theme_path != "":
		var t = load(n.theme_path)
		if t: return t
	return global_theme

func load_note(id: String) -> Note:
	var path := "user://notes/note_" + id + ".tres"
	if !FileAccess.file_exists(path): return null
	return ResourceLoader.load(path) as Note

func save_timer_timeout():
	if not is_dirty: return
	is_dirty = false
	_on_save_pressed()

func _on_add_prog_btn_pressed() -> void:
	progress_bar.set_smooth_value(progress_bar.value + 10)

func _on_rem_prog_btn_pressed() -> void:
	progress_bar.set_smooth_value(progress_bar.value - 10)

func _on_spin_box_value_changed(value: float) -> void:
	var toolWindow : MainWindow = get_tree().root.get_node("/root/ToolWindow")
	toolWindow.theme_editor.font_size_box.value = value

func _on_dotbtn_pressed() -> void:
	desc.insert_text_at_caret("	•	")
