class_name Resources

enum { PERFOVERLAY,
	MAX} # SHOULD ALWAYS BE THE MAX ENUM

const stringnames: Array[StringName] =[StringName("Perf Overlay")]
static func get_strings() -> PackedStringArray:
	return PackedStringArray([
		"res://Performance Overlay/Performance Overlay.tscn",
		])

static func get_resource_id_map() -> Dictionary:
	@warning_ignore("unassigned_variable")
	var resource_id_map: Dictionary
	var strings: PackedStringArray = get_strings()
	for i in strings.size():
		resource_id_map[strings[i].hash()] = i
	return resource_id_map

static func get_resource_list() -> Array[Resource]:
	@warning_ignore("unassigned_variable")
	var resources: Array[Resource]
	for string in get_strings():
		resources.append(load(string))
	return resources

static func get_node_resource_id(node: Node) -> int:
	return node.scene_file_path.hash()
