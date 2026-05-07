extends Node

signal theme_change(theme: GameThemeData)

var themes: Array[GameThemeData] = []
var app_themes: Array[AppTheme] = []
var current_index: int = -1

func create_new_theme() -> int:
	var t := GameThemeData.new()
	themes.append(t)
	current_index = themes.size() - 1
	theme_change.emit(t)
	ThemeManager.apply_game_theme(t)
	return current_index

func ensure_valid_theme():
	if themes.is_empty():
		var t = GameThemeData.new()
		themes.append(t)
		current_index = 0

func add_themes(t: GameThemeData) -> void:
	themes.append(t)

func delete_theme(index: int):
	if index < 0 or index >= themes.size():
		return

	var path := "user://themes/theme_%d.tres" % index
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)

	themes.remove_at(index)

	if themes.is_empty():
		var t := GameThemeData.new()
		themes.append(t)
		current_index = 0
		theme_change.emit(t)
		ThemeManager.apply_game_theme(t)
		return

	if current_index >= themes.size():
		current_index = themes.size() - 1

	select_theme(current_index)

func select_theme(index: int):
	if themes.is_empty():
		ensure_valid_theme()

	if index < 0 or index >= themes.size():
		return

	current_index = index

	var t = themes[current_index]
	if t == null:
		t = GameThemeData.new()
		themes[current_index] = t

	theme_change.emit(t)
	ThemeManager.apply_game_theme(t)

func get_current() -> GameThemeData:
	if themes.is_empty():
		return null
	if current_index < 0 or current_index >= themes.size():
		return themes[0]
	return themes[current_index]

func save_all():
	DirAccess.make_dir_recursive_absolute("user://themes")
	for i in range(themes.size()):
		var t = themes[i]
		if t == null:
			continue
		ResourceSaver.save(t, "user://themes/theme_%d.tres" % i)

	DirAccess.make_dir_recursive_absolute("user://app_themes")
	for i in range(app_themes.size()):
		var a = app_themes[i]
		if a == null:
			continue
		ResourceSaver.save(a, "user://app_themes/app_theme_%d.tres" % i)

func load_all():
	themes.clear()

	var dir := DirAccess.open("user://themes")
	if dir != null:
		var files: Array[String] = []
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			if file.begins_with("theme_") and file.ends_with(".tres"):
				files.append(file)
			file = dir.get_next()
		dir.list_dir_end()
		files.sort()
		for f in files:
			var t = ResourceLoader.load("user://themes/" + f, "GameThemeData")
			if t is GameThemeData:
				themes.append(t as GameThemeData)

	app_themes.clear()

	var adir := DirAccess.open("user://app_themes")
	if adir != null:
		var afiles: Array[String] = []
		adir.list_dir_begin()
		var afile = adir.get_next()
		while afile != "":
			if afile.begins_with("app_theme_") and afile.ends_with(".tres"):
				afiles.append(afile)
			afile = adir.get_next()
		adir.list_dir_end()
		afiles.sort()
		for f in afiles:
			var a = ResourceLoader.load("user://app_themes/" + f, "AppTheme")
			if a is AppTheme:
				app_themes.append(a as AppTheme)
