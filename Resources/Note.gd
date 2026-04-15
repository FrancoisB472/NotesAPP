extends Resource
class_name Note

@export_category("Data")
@export var position : Vector2 = Vector2.ZERO
@export_group("Text Data")
@export var id : String
@export var size: Vector2 = Vector2(300, 200)  # add this alongside title, main_text, etc.
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

@export_group("UI")
@export var theme_path: String = ""
