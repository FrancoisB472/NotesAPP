extends Resource
class_name Note

@export_category("Data")
@export_group("Text Data")
## Main title of the note viewed when seeing the album
@export var title : String 

## Actual text inside the note, goes to a RichTextLabel
@export var main_text : String

## Popup when mouse hovers over it
@export var summary : String

@export_group("Progress")
@export var is_completed : bool
@export var max_progress : float = 100.0
@export var min_progress : float = 0.0
@export var current_progress : float = 0.0

@export_category("UI")
@export var panel_tex : Texture2D
@export var button_textures : Dictionary[String, Texture2D]
@export var font : FontFile
@export var progress_bar_front : Texture2D
@export var progress_bar_fill : Texture2D
