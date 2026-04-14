extends Control


class_name MainScene

var theme_data: GameThemeData

func _ready():
	ThemeLibrary.load_all()
	# Ensure theme system is active
	if ThemeLibrary.themes.size() > 0:
		ThemeManager.apply(ThemeLibrary.get_current())

func apply_texture(tex: Texture2D) -> void:
	theme_data.container_texture = tex
	ThemeManager.apply(theme_data)
