extends RefCounted
class_name ThemeBuilder

static func apply_radius(sb: StyleBoxFlat, r := 8) -> StyleBoxFlat:
	sb.corner_radius_top_left = r
	sb.corner_radius_top_right = r
	sb.corner_radius_bottom_left = r
	sb.corner_radius_bottom_right = r
	return sb


static func build(d: GameThemeData) -> Theme:
	var t = Theme.new()

	# Base colors
	var base_color := d.container_bg
	var panel_color := base_color.darkened(0.12)

	# Containers
	var panel := apply_radius(StyleBoxFlat.new())
	panel.bg_color = panel_color

	var base := apply_radius(StyleBoxFlat.new())
	base.bg_color = d.container_bg

	var tex := StyleBoxTexture.new()
	if d.container_texture:
		tex.texture = d.container_texture

	d.id = str(Time.get_unix_time_from_system())

	var container_style = tex if d.container_texture else base

	var normal_container_classes = [
		"Panel",
		"VBoxContainer",
		"HBoxContainer",
		"MarginContainer",
		"ScrollContainer",
		"TabContainer",
		"PopupPanel"
	]

	for cls in normal_container_classes:
		t.set_stylebox("panel", cls, base.duplicate())

	# PanelContainer (darker)
	t.set_stylebox("panel", "PanelContainer", panel.duplicate())

	# Text
	
	var font: Font = null

	if d.font_path != "":
		var f := FontFile.new()
		if f.load_dynamic_font(d.font_path) == OK:
			font = f

	var fv := FontVariation.new()
	fv.base_font = font

	t.default_font = fv
	for cls in ["Label", "Button", "LineEdit", "OptionButton", "RichTextLabel"]:
		t.set_font("font", cls, fv)
		t.set_font_size("font_size", cls, d.font_size)

	# Buttons
	var normal := apply_radius(StyleBoxFlat.new())
	normal.bg_color = d.button_bg

	var hover := apply_radius(StyleBoxFlat.new())
	hover.bg_color = d.button_hover

	var pressed := apply_radius(StyleBoxFlat.new())
	pressed.bg_color = d.button_pressed

	for cls in ["Button", "OptionButton"]:
		t.set_stylebox("normal", cls, normal.duplicate())
		t.set_stylebox("hover", cls, hover.duplicate())
		t.set_stylebox("pressed", cls, pressed.duplicate())

	# Inputs
	var input := apply_radius(StyleBoxFlat.new())
	input.bg_color = d.input_bg

	for cls in ["LineEdit", "SpinBox"]:
		t.set_stylebox("normal", cls, input.duplicate())
		t.set_stylebox("focus", cls, input.duplicate())

	t.set_color("caret_color", "LineEdit", d.input_caret_color)

	# Progress
	var fill := apply_radius(StyleBoxFlat.new())
	fill.bg_color = d.progress_fill
	t.set_stylebox("fill", "ProgressBar", fill.duplicate())

	return t
