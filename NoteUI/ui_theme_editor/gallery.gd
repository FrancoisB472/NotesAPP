extends GridContainer
class_name Gallery

signal theme_selected(index: int)

func refresh_gallery():
	for c in get_children():
		c.queue_free()

	for i in ThemeLibrary.themes.size():
		var btn = Button.new()
		btn.text = "Theme %d" % i

		btn.pressed.connect(func():
			ThemeLibrary.select_theme(i)
			theme_selected.emit(i)
		)

		add_child(btn)
