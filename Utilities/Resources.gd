class_name Resources

static var resources: Array[Resource] = get_resource_list()
static var resource_id_map: Dictionary = get_resource_id_map()
static var networked_node_types: Dictionary = {}

enum {PLAYER, PERFOVERLAY, PARKOURPLAYER, DEBUGTRANSPARENTMATERIAL,
	MAX} # SHOULD ALWAYS BE THE MAX ENUM

const stringnames: Array[StringName] =[StringName("Player"),StringName("Parkour Player"),StringName("Perf Overlay")]
static func get_strings() -> PackedStringArray:
	return PackedStringArray([
		"res://Gameplay/Characters/Player Character/Player Character.tscn",
		"res://Interface/Performance Overlay/Performance Overlay.tscn",
		"res://Gameplay/Characters/Parkour Player Character.tscn",
		])

static func get_resource_id_map() -> Dictionary:
	var id_map: Dictionary = {}
	var strings: PackedStringArray = get_strings()
	for i in strings.size():
		id_map[strings[i].hash()] = i
	return id_map

static func get_resource_list() -> Array[Resource]:
	var rsources: Array[Resource] = []
	for string in get_strings():
		rsources.append(load(string))
	return rsources

static func get_node_resource_id(node: Node) -> int:
	return node.scene_file_path.hash()

static func get_resource(idx: int) -> Resource:
	return resources[idx]

static func get_resource_from_resource_id(id: int) -> Resource:
	return resources[resource_id_map[id]]
