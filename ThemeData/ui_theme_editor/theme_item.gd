extends Control
class_name ThemeItem

signal select_requested(index: int)
signal request_delete(index: int)

var theme_data: GameThemeData
var index: int

@onready var preview_panel: Panel = $PreviewPanel
@onready var label: Label = $Label

func set_them(data: GameThemeData, i: int) -> void:
	theme_data = data
	index = i

	if label:
		label.text = "Theme %d" % i

	_apply_preview()

func _on_delete_pressed() -> void:
	request_delete.emit(index)

func _apply_preview():
	if theme_data == null:
		return

	# Build a mini preview Theme (lightweight)
	var t := Theme.new()

	var box := StyleBoxFlat.new()
	box.bg_color = theme_data.container_bg

	t.set_stylebox("panel", "Panel", box)
	t.set_color("font_color", "Label", theme_data.text_colour)

	preview_panel.theme = t


func _on_btn_select_pressed() -> void:
	select_requested.emit(index)
