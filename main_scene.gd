extends Control
class_name MainScene

var theme_data: GameThemeData

func apply_texture(tex: Texture2D) -> void:
	theme_data.container_texture = tex
	ThemeManager.apply(theme_data)

func save_theme_pressed() -> void:
	ResourceSaver.save(theme_data, "user://themes/my_theme.tres")
