extends Resource
class_name AppTheme

enum ThemeType {
	CUSTOM,
	GODOT
}

@export var type : ThemeType = ThemeType.CUSTOM

@export var custom_data : GameThemeData
@export var godot_theme : Theme
