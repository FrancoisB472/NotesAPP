extends Node

var current_data: GameThemeData
var current_theme: Theme

func _ready() -> void:
	OS.request_permissions()


func apply(data: GameThemeData):
	if data == null:
		return

	current_theme = ThemeBuilder.build(data)
	get_tree().root.theme = current_theme
