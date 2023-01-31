extends SpinBox
class_name IntRange

@export var font: Font
@export var font_size: int = 16

func _ready() -> void:
	if font:
		get_line_edit().set("theme_override_fonts/font",font)
	get_line_edit().set("theme_override_font_sizes/font_size",font_size)
