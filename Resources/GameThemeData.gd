extends Resource
class_name GameThemeData

@export_group("Containers")
@export var container_bg : Color = Color(0.15,0.15,0.15)
@export var container_texture : Texture2D

@export_group("Font")
@export var font : Font
@export var text_colour : Color = Color.WHITE

@export_group("Accent")
@export var accent_colour : Color = Color(0.4, 0.7, 1.0)

@export_group("Buttons")
@export var button_bg : Color = Color(0.2,0.2,0.2)
@export var button_hover : Color = Color(0.3,0.3,0.3)
@export var button_pressed : Color = Color(0.1,0.1,0.1)

@export_group("Inputs")
@export var input_bg : Color = Color(0.18,0.18,0.18)
@export var input_caret_color = Color.WHITE

@export_group("Progress")
@export var progress_fill : Color = Color(0.4,0.7,1.0)
