extends Control
class_name Menu

var current_layer: Node
var last_layer: Node

@export var default_layer: Node
@export var background: Node
@export var other_exceptions: Array[NodePath]
@export var sub_layer_paths: Array[NodePath]

var sub_layers: Array[Control]

func _ready() -> void:
	if default_layer:
		current_layer = default_layer
	for item in get_children():
		if item is CanvasItem:
			item.hide()
	if current_layer:
		current_layer.show()
	if background:
		background.show()
	for each_exception in other_exceptions:
		var exception = get_node_or_null(each_exception)
		if exception:
			exception.show()
	var i: int
	for layer in sub_layer_paths:
		sub_layers[i] = get_node(layer)
		@warning_ignore("unassigned_variable_op_assign")
		i += 1


func _go_to_layer(to: Node) -> void:
	current_layer.hide()
	last_layer = current_layer
	to.show()
	current_layer = to

func is_current_layer_sublayer() -> bool:
	return sub_layers.has(current_layer)

func go_up_a_layer_maybe_wont_work() -> void:
	_go_to_layer(last_layer)
	if is_current_layer_sublayer():
		last_layer = get_parent()

func is_on_default_layer() -> bool:
	return current_layer == default_layer

func go_to_default_layer() -> void:
	_go_to_layer(default_layer)

#func _input(event):
#	if (Input.is_action_just_pressed("ui_cancel")):
#		match current_layer:
#			:
#				_go_to_layer(main)
