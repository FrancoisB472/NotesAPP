extends RefCounted
class_name ThemeBuilder

static func apply_radius(sb: StyleBoxFlat, r := 8) -> StyleBoxFlat:
	sb.corner_radius_top_left = r
	sb.corner_radius_top_right = r
	sb.corner_radius_bottom_left = r
	sb.corner_radius_bottom_right = r
	
	sb.expand_margin_bottom = r / 2
	sb.expand_margin_top = r / 2
	sb.expand_margin_left = r / 2
	sb.expand_margin_right = r / 2
	return sb

static func build(d: GameThemeData) -> Theme:
	var t = Theme.new()

	var base_color := d.container_bg
	var panel_color := base_color.darkened(0.12)

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
		t.set_stylebox("panel", cls, container_style.duplicate())

	t.set_stylebox("panel", "PanelContainer", panel.duplicate())

	# Font
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

	# Text colors
	for cls in ["Label", "RichTextLabel"]:
		t.set_color("font_color", cls, d.text_colour)
	t.set_color("font_color", "Button", d.text_colour)
	t.set_color("font_color", "LineEdit", d.text_colour)

	# Buttons
	for cls in ["Button", "OptionButton"]:
		var normal := StyleBoxTexture.new()
		normal.texture = d.button_texture_normal
		normal.texture_margin_left = 3
		normal.texture_margin_right = 3
		normal.texture_margin_top = 3
		normal.texture_margin_bottom = 3

		var hover := StyleBoxTexture.new()
		hover.texture = d.button_texture_hover
		hover.texture_margin_left = 3
		hover.texture_margin_right = 3
		hover.texture_margin_top = 3
		hover.texture_margin_bottom = 3

		var pressed := StyleBoxTexture.new()
		pressed.texture = d.button_texture_pressed
		pressed.texture_margin_left = 3
		pressed.texture_margin_right = 3
		pressed.texture_margin_top = 3
		pressed.texture_margin_bottom = 3

		var disabled := StyleBoxTexture.new()
		disabled.texture = d.button_texture_pressed
		disabled.texture_margin_left = 3
		disabled.texture_margin_right = 3
		disabled.texture_margin_top = 3
		disabled.texture_margin_bottom = 3

		t.set_stylebox("normal", cls, normal)
		t.set_stylebox("hover", cls, hover)
		t.set_stylebox("pressed", cls, pressed)
		t.set_stylebox("disabled", cls, disabled)

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
