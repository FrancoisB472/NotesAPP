# ThemeBuilder.gd
extends RefCounted
class_name ThemeBuilder

static func build(d: GameThemeData) -> Theme:
	var t = Theme.new()

	# Containers
	var base = StyleBoxFlat.new()
	base.bg_color = d.container_bg

	var tex = StyleBoxTexture.new()
	if d.container_texture:
		tex.texture = d.container_texture

	var container_style = tex if d.container_texture else base

	for cls in ["Panel", "VBoxContainer", "HBoxContainer", "MarginContainer", "ScrollContainer", "TabContainer", "PopupPanel"]:
		t.set_stylebox("panel", cls, container_style)

	# Text
	t.set_color("font_color", "Label", d.text_colour)
	t.set_color("font_color", "RichTextLabel", d.text_colour)
	t.set_font("font", "Label", d.font)

	# Buttons
	var normal = StyleBoxFlat.new()
	normal.bg_color = d.button_bg

	var hover = StyleBoxFlat.new()
	hover.bg_color = d.button_hover

	var pressed = StyleBoxFlat.new()
	pressed.bg_color = d.button_pressed

	for cls in ["Button", "OptionButton"]:
		t.set_stylebox("normal", cls, normal)
		t.set_stylebox("hover", cls, hover)
		t.set_stylebox("pressed", cls, pressed)

	# Inputs
	var input = StyleBoxFlat.new()
	input.bg_color = d.input_bg

	for cls in ["LineEdit", "SpinBox"]:
		t.set_stylebox("normal", cls, input)
		t.set_stylebox("focus", "LineEdit", input)

	t.set_color("caret_color", "LineEdit", d.input_caret_color)

	# Progress
	var fill = StyleBoxFlat.new()
	fill.bg_color = d.progress_fill
	t.set_stylebox("fill", "ProgressBar", fill)

	return t
