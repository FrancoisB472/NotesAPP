# ThemeManager.gd
extends Node

var current_data: GameThemeData

func apply(data: GameThemeData):
	current_data = data
	get_tree().root.theme = ThemeBuilder.build(data)
