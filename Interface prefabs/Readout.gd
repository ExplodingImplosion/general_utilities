extends HBoxContainer
class_name Readout

@export var font: Font
@export var font_size: int = 12
@export var label_1_text: String
@export var suffix: String = ":"
@export var min_size: float
@export_enum("Left","Center","Right","Fill") var readout_alignment: int

var label1: Label
var label2: Label

#@warning_ignore("shadowed_variable")
#func _init(font: Font, font_size: int, label_1_text: String = "") -> void:
#	self.font = font
#	self.font_size = font_size
#	self.label_1_text = label_1_text

func _ready() -> void:
	assert(get_child_count() == 0,"Maybe you did this intentionally. idk. if you did, feel free
	 to get rid of this. but otherwise, why the hell did you add a child of an HBoxLabelPair?")
	
	@warning_ignore("shadowed_variable")
	var label1 := Label.new()
	@warning_ignore("shadowed_variable")
	var label2 := Label.new()
	
	self.label1 = label1
	self.label2 = label2
	
	if label_1_text.is_empty():
		label_1_text = name
	if !label_1_text.ends_with(suffix):
		label_1_text += suffix
	label1.text = label_1_text
	
	label2.horizontal_alignment = readout_alignment
	label2.custom_minimum_size.x = min_size
	
	add_child(label1)
	add_child(label2)
	
	assign_label_properties(label1)
	assign_label_properties(label2)

func assign_label_properties(label: Label) -> void:
	if font != null:
		LabelUtils.set_font(label,font)
	LabelUtils.set_font_size(label,font_size)
