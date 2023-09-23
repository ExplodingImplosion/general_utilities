extends HSlider

@export var readout: LineEdit
var int_slider: bool

func _init() -> void:
	int_slider = !(float(int(step)) != step or step == 0.0)
	

func text_submitted(text: String) -> void:
	# i think this is inefficient but im tired breh
	if int_slider:
		var newval: int = clampi(int(text),min_value,max_value)
		value = float(newval)
		if !text.is_valid_int():
			text = str(newval)
	else:
		value = clampf(float(text),min_value,max_value)
		if !text.is_valid_float():
			text = str(value)
