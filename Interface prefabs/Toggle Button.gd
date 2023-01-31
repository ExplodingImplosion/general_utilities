extends Button
class_name ToggleButton

@export var ontext: String = "Enabled"
@export var offtext: String = "Disabled"

func _ready() -> void:
	_on_Toggle_Button_toggled(button_pressed)

func _on_Toggle_Button_toggled(toggled: bool):
	set_text(ontext) if toggled else set_text(offtext)
