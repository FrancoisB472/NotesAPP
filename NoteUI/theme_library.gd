extends Node

signal theme_change(theme: GameThemeData)

var themes : Array[GameThemeData] = []
var current_index: int = -1

func add_themes(t : GameThemeData) -> void:
	themes.append(t)

func select_theme(index: int) -> void:
	if index < 0 or index >= themes.size():
		return
	
	current_index = index
	theme_change.emit(themes[index])
	ThemeManager.apply(themes[index])

func get_current() -> GameThemeData:
	if current_index == -1:
		return null
	return themes[current_index]

func save_all():
	DirAccess.make_dir_recursive_absolute("user://themes")

	for i in themes.size():
		ResourceSaver.save(themes[i], "user://themes/theme_%d.tres" % i)

func load_all():
	themes.clear()

	var dir = DirAccess.open("user://themes")
	if dir == null:
		return

	dir.list_dir_begin()
	var file = dir.get_next()

	while file != "":
		if file.ends_with(".tres"):
			var t = load("user://themes/" + file)
			if t:
				themes.append(t)
		file = dir.get_next()

	dir.list_dir_end()

	if themes.size() > 0:
		select_theme(0)

	theme_change.emit(themes[0])
