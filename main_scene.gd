extends Control
class_name MainScene

const NOTE_WINDOW := preload("res://NotesAPP/Notes/NoteUI.tscn")
const GENERIC_WINDOW := preload("res://NotesAPP/tool_window.tscn")

@onready var desktop: Control = $Desktop
@onready var fps: Label = $Desktop/ToolWindow/PanelContainer/MarginContainer/FPS

var theme_data: GameThemeData
var pool: Array[VirtualWindow] = []

var desktop_offset: Vector2i = Vector2i.ZERO


func _ready():
	ThemeLibrary.load_all()
	if ThemeLibrary.themes.size() > 0:
		ThemeManager.apply(ThemeLibrary.get_current())

	_setup_multiscreen_desktop()

	desktop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	load_all_notes()


func _setup_multiscreen_desktop() -> void:
	var screens := DisplayServer.get_screen_count()

	var min_x := INF
	var min_y := INF
	var max_x := -INF
	var max_y := -INF

	for i in range(screens):
		var pos: Vector2i = DisplayServer.screen_get_position(i)
		var size: Vector2i = DisplayServer.screen_get_size(i)

		min_x = min(min_x, pos.x)
		min_y = min(min_y, pos.y)
		max_x = max(max_x, pos.x + size.x)
		max_y = max(max_y, pos.y + size.y)

	desktop_offset = Vector2i(min_x, min_y)
	var total_size := Vector2i(max_x - min_x, max_y - min_y)

	DisplayServer.window_set_position(desktop_offset)
	DisplayServer.window_set_size(total_size)

	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)


func to_desktop_space(p: Vector2) -> Vector2:
	return p - Vector2(desktop_offset)


func load_all_notes() -> void:
	var dir_path := "user://notes/"
	DirAccess.make_dir_recursive_absolute(dir_path)

	var dir := DirAccess.open(dir_path)
	if dir == null:
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var full_path := dir_path + file_name
			var note := ResourceLoader.load(full_path) as Note
			if note:
				spawn_note_window(note)

		file_name = dir.get_next()

	dir.list_dir_end()


func spawn_note_window(note: Note) -> void:
	var w := NOTE_WINDOW.instantiate()
	w.note = note
	desktop.add_child(w)

	if note.position != Vector2.ZERO:
		w.position = to_desktop_space(note.position)
	else:
		w.position = Vector2(200 + randi() % 300, 100 + randi() % 200)

	w.title_label.text = note.title
	w.desc.text = note.main_text

	call_deferred("update_passthrough")


func _process(_delta: float) -> void:
	if fps:
		fps.text = "FPS: %d" % Engine.get_frames_per_second()


#region window pool / focus

func focus(w):
	for i in pool:
		i.modulate.a = 0.9
	w.modulate.a = 1.0


func bring_to_front(w: Control):
	w.get_parent().move_child(w, -1)


func release_window(w: VirtualWindow):
	w.visible = false
	w.get_parent().remove_child(w)
	pool.append(w)


func get_window_from_pool() -> VirtualWindow:
	if pool.size() > 0:
		return pool.pop_back()
	return NOTE_WINDOW.instantiate()

#endregion


func apply_texture(tex: Texture2D) -> void:
	theme_data.container_texture = tex
	ThemeManager.apply(theme_data)


func create_note() -> void:
	var note := Note.new()
	note.id = str(Time.get_unix_time_from_system())
	note.title = "New Note"
	note.main_text = "Write something in here!"
	note.position = Vector2(200 + randi() % 300, 100 + randi() % 200)

	spawn_note_window(note)


func _on_button_pressed() -> void:
	create_note()
