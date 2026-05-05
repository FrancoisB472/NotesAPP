extends Control
class_name MainWindow

const NOTE_WINDOW := preload("res://NotesAPP/Notes/NoteUI.tscn")

@onready var fps: Label = $PanelContainer/MarginContainer/FPS
@onready var cycle: CycleTracker = $PanelContainer/MarginContainer/Panel/MarginContainer/TabContainer/Cycle
@onready var theme_editor: ThemeEditor = $PanelContainer/MarginContainer/Panel/MarginContainer/TabContainer/ThemeEditor

var theme_data: GameThemeData

func _ready():
	# Quit the app when the main window is closed.
	load_all_notes()

func _process(_delta: float) -> void:
	if fps:
		fps.text = "FPS: %d" % Engine.get_frames_per_second()

#  Note loading & spawning 

func load_all_notes():
	var dir := "user://notes/"
	DirAccess.make_dir_recursive_absolute(dir)

	var d := DirAccess.open(dir)
	if d == null:
		return

	d.list_dir_begin()
	var file := d.get_next()
	while file != "":
		if not d.current_is_dir() and file.ends_with(".tres"):
			var note := ResourceLoader.load(dir + file) as Note
			if note:
				spawn_note_window(note)
		file = d.get_next()
	d.list_dir_end()

func spawn_note_window(note: Note):
	var w := NOTE_WINDOW.instantiate()
	# Set note BEFORE add_child so NoteWindow._ready() can read it immediately.
	w.note = note
	get_tree().root.add_child.call_deferred(w)

func _on_button_pressed():
	create_note()

func create_note():
	var note := Note.new()
	note.id = str(Time.get_unix_time_from_system())
	note.title = "New Note"
	note.position = Vector2(100,100)
	note.size = Vector2(500, 330)
	spawn_note_window(note)

#  Theme 

func apply_texture(tex: Texture2D) -> void:
	theme_data.container_texture = tex
	ThemeManager.apply(theme_data)


func _on_button_2_pressed() -> void:
	pass # Replace with function body.
