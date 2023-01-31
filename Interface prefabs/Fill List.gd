extends VBoxContainer
#class_name FillList

enum {TOEDGE, CUSTOMEXTENT}
@export_enum("To Edge", "Custom Amount") var fill_extent: int = 0
@export var extent: float = 0

func _ready() -> void:
	if fill_extent == TOEDGE:
			extent = size.x
	for child in get_children():
		if child is HBoxContainer:
			align_children(child, extent)

static func align_children(container: HBoxContainer, this_extent: float) -> void:
#	container.set_alignment(BoxContainer.ALIGN_BEGIN)
	set_separation(container, calc_separation(container.get_children(), this_extent))

static func get_children_size(children: Array) -> float:
	var total_size: float
	for child in children:
		total_size += (child as Control).size.x
	return total_size

static func calc_separation(children: Array, this_extent: float) -> int:
	return int((this_extent - get_children_size(children)) / (children.size() - 1))

# only works properly for hboxcontainers with 2 children
static func calc_separation_simple(children: Array, this_extent: float) -> int:
	return int(this_extent - get_children_size(children))

static func set_separation(container: BoxContainer, separation: int) -> void:
	container.add_theme_constant_override("separation", separation)
