extends HBoxContainer
#class_name HBoxLabelPair

@export var font: Font
@export var font_size: int = 12
@export var label_1_text: String
@export var label_2_text: String

var label1: Label
var label2: Label

func _ready() -> void:
	assert(get_child_count() == 0,"Maybe you did this intentionally. idk. if you did, feel free
	 to get rid of this. but otherwise, why the hell did you add a child of an HBoxLabelPair?")
	
	@warning_ignore("shadowed_variable")
	var label1 := Label.new()
	@warning_ignore("shadowed_variable")
	var label2 := Label.new()
	
	self.label1 = label1
	self.label2 = label2
	
	label1.text = label_1_text
	label2.text = label_2_text
	
	add_child(label1)
	add_child(label2)
	
	assign_label_properties(label1)
	assign_label_properties(label2)

func assign_label_properties(label: Label) -> void:
	if font != null:
		label.font = font
	label.font_size = font_size
