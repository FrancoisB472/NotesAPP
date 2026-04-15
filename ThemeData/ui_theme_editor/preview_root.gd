extends Control

@onready var progress_bar: ProgressBar = $ScrollContainer/VBoxContainer/ProgressBar

func _ready() -> void:
	progress_bar.min_value = 0
	progress_bar.max_value = 100
	clamp(progress_bar.value, progress_bar.min_value, progress_bar.max_value)

var speed = 50
var filling = true

func _process(delta):
	if filling:
		progress_bar.value += speed * delta
		if progress_bar.value >= progress_bar.max_value:
			filling = false
	else:
		progress_bar.value -= speed * delta
		if progress_bar.value <= 0:
			filling = true
