extends HBoxContainer
class_name Gallery

const THEME_ITEM = preload("uid://dlju8da0p0mla")

signal theme_selected(index: int)
signal delete_requested(index: int)

func refresh_gallery():
	for c in get_children():
		c.queue_free()

	for i in range(ThemeLibrary.themes.size()):
		var item := THEME_ITEM.instantiate() as ThemeItem

		add_child(item)

		item.call_deferred("set_them", ThemeLibrary.themes[i], i)

		item.select_requested.connect(func(idx):
			ThemeLibrary.select_theme(idx)
			theme_selected.emit(idx)
		)

		item.request_delete.connect(func(idx):
			ThemeLibrary.delete_theme(idx)
			refresh_gallery()
		)
