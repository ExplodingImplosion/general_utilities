extends Node

## Array that is filled on startup ith every resource in the game.
const resources: Array = []

## Time that the game had been running in seconds on the last frame.
var current_time: float = 0
## Time that the game has been running in seconds on the current frame.
var last_time: float = 0
## How much time has elapsed since the previous frame.
var delta_time: float = 0
## Same as calling [method Engine.get_physics_interpolation_fraction].
var interpfrac: float = 0

## Same as [member current_time] but is updated on a separate thread.
var current_time_thread: float = 0
#var last_time_thread: float = 0
## Same as [member delta_time] but is updated on a separate thread.
var delta_time_thread: float = 0
## Thread that updates [member current_time_thread].
var time_thread := Thread.new()

## Accessing this variable is the same as calling get_tree().get_root() on any node.
@onready var root: Viewport = get_root()
## Accessing this variable is the same as calling get_tree() on any node.
@onready var tree: SceneTree = get_tree()

## Only true if [method _process] has never been called on Quack.
func is_startup() -> bool:
	return current_time == 0

## Function that updates time on a separate thread other than the main thread.
func do_time_thread(n = null) -> void:
	for i in INF:
		current_time_thread = Time.get_ticks_usec() * 0.000001
		delta_time_thread = current_time_thread - last_time#_thread
#		print(delta_time_thread)
#		last_time_thread = current_time_thread
#		if current_time_thread != current_time:
#			print("thread: threaded time %s != %s"%[current_time_thread, current_time])

func _process(delta: float) -> void:
	current_time = Time.get_ticks_usec() * 0.000001
	delta_time = current_time - last_time
	last_time = current_time
	interpfrac = get_interpfrac()
#	if current_time_thread != current_time:
#		print("main: threaded time %s != %s"%[current_time_thread, current_time])

## Shortcut for printing the current time in microseconds.
static func printusec() -> void:
	print(Time.get_ticks_usec())

## idek lmfao
func tick_time_value_towards(value: float, towards: float) -> float:
	value += delta_time
	return towards - value

## idek lmfao
func tick_time_value_down(value: float) -> float:
	return value - delta_time

## idek lmfao
func tick_time_value_up(value: float) -> float:
	return value + delta_time

func _init() -> void:
	resources.append_array(Resources.get_resource_list())
	stupid_shader_cache_workaround()

## Spawns every [PackedScene]p in [member resources]
func stupid_shader_cache_workaround() -> void:
	for resource in resources:
		if resource is PackedScene:
			add_child(resource.instantiate())
		elif resource is Material:
			var mesh := MeshInstance3D.new()
			mesh.set_mesh(BoxMesh.new())
			mesh.mesh.surface_set_material(0,resource)
			add_child(mesh)
	for child in get_children():
		child.queue_free()

func get_resource(idx: int) -> Resource:
	return resources[idx]

#func get_debug_transparent_material() -> StandardMaterial3D:
#	return get_resource(Resources.DEBUGTRANSPARENTMATERIAL)

func _ready() -> void:
	setup_connections()
	setup_filepaths()
	WindowUtils.on_window_resized()
	return
	if time_thread.start(Callable(self,"do_time_thread")) != OK:
		print("fuck off")
		quit()
	# for some reason this crashes???
#	add_is_networked_meta_recursive(get_tree().current_scene)

## If the game has any dependencies on external directories, this function
## checks if they exist on the device. If not, this function also creates them.
func setup_filepaths() -> void:
	pass
#	Replays.setup_filepath()

## Sets up any constant connections that exist while the game runs. Currently
## sets up [member WindowUtils.on_window_resized] every time the window is
## resized.
func setup_connections() -> void:
	var resized_func := Callable(WindowUtils,"on_window_resized")
	root.connect("size_changed",resized_func)

## Gets the node that's at the bottom of the scene tree
func get_root_last_child() -> Node:
	return root.get_child(root.get_child_count() - 1)

## Returns the same value as calling get_tree().get_root() on any node.
func get_root() -> Window:
	return get_tree().get_root()

## Assigns [member root] to [method get_root()].
func refresh_root() -> void:
	root = get_root()

## Assigns [member tree] to [method get_tree()].
func refresh_tree() -> void:
	tree = get_tree()
#	refresh_root()

## Gets an Array of every node that's in a given group.
func get_nodes_in_group(group: StringName) -> Array[Node]:
	return tree.get_nodes_in_group(group)

## Gets the current active 3D camera.
func get_current_camera() -> Camera3D:
	return root.get_camera_3d()

## Changes the current scene to a given file name, and performs
## [method WindowUtils.on_window_resized] on the scene.
func change_scene(scene: String) -> void:
	tree.change_scene_to_file(scene)
	call_deferred("stupid_workaround")

## Stupid workaround that lets me call [method WindowUtils.on_window_resized],
## Which is a static function, via a signal connection, which requires an
## instance.
func stupid_workaround() -> void:
	WindowUtils.on_window_resized()

## Quits the game. lmao.
func quit() -> void:
#	Settings.save_settings()
	tree.quit()

## Same as calling [method Engine.get_physics_interpolation_fraction].
static func get_interpfrac() -> float:
	return Engine.get_physics_interpolation_fraction()

## Returns a Windows file system-compatible datetime string.
static func datetime_string() -> String:
	return Time.get_datetime_string_from_system(false, true).replace(":", "-")

## Same as calling [method Engine.get_physics_ticks_per_second].
static func get_tickrate() -> int:
	return Engine.get_physics_ticks_per_second()

## Same as calling [Engine.set_physics_ticks_per_second].
static func set_tickrate(rate: int) -> void:
	Engine.set_physics_ticks_per_second(rate)

## Returns the last index of an Array.
static func array_getlastidx(array: Array) -> int:
	return array.size() - 1

## I don't even fucking remember tbh.
static func global_orientation(obj: Node3D) -> Vector3:
	# tbh normailizing this changes like basically nothing so maybe its not worth doing
	# example: changes (-0.318499, -0.088899, 0.943740) into (-0.318501, -0.088899, 0.943745)
	return obj.global_transform.basis.z.normalized()

## Returns if the engine is NOT running from the editor.
static func is_exported() -> bool:
	return OS.has_feature("standalone")

## Returns true if a [Timer] is inactive or has finished.
static func is_timer_running(timer: Timer) -> bool:
	# if a timer is inactive it also returns 0, so this works no matter what :)
	return false if timer.get_time_left() == 0.0 else true

# Depreciated because I learned about "is_instance_valid" lmao
#static func is_freed_instance(obj: Object) -> bool:
#	return weakref(obj).get_ref() == null

## Creates a Dictionary with each key corresponding to the item's index it was at
## in the Array.
static func get_dict_from_array(array: Array) -> Dictionary:
	var dict: Dictionary
	for idx in array.size():
		dict[idx] = array[idx]
	return dict

## Turns every element from an array into a value in the dictionary, with a key
## corresponding to the item's index it was at in the Array.
static func apply_array_to_dict(dict: Dictionary, array: Array) -> void:
	for idx in array.size():
		dict[idx] = array[idx]

## Returns true if variants share the same type
static func types_are_same(var1: Variant, var2: Variant) -> bool:
	return typeof(var1) == typeof(var2)

## I forgor (skull emoji)
func setup_subwindow_size(subwindow: Window, size: Vector2i) -> void:
	if root.size.x < size.x:
		size.x = Quack.root.size.x - 60
	if root.size.y < size.y:
		size.y = Quack.root.size.y - 60
	subwindow.set_size(size)
	if subwindow.position.x > root.size.x or subwindow.position.x < root.position.x:
		subwindow.position.x = root.size.x - subwindow.size.x - 20
	if subwindow.position.y > root.size.y or subwindow.position.y < root.position.y:
		subwindow.position.y = root.size.y - subwindow.size.y - 20

## Returns if a is a multiple of b. lmao.
static func is_multiple_of(a: int, b: int) -> bool:
	return a % b == 0

## Prints the metadata of every node and its children.
static func print_meta_list_for_node_and_children(node: Node) -> void:
	for child in node.get_children():
		print("--------------")
		print(child.get_name())
		print("--------------")
		print(child.get_meta_list())
		print("-------------------------------")
		print_meta_list_for_node_and_children(child)
		print("-------------------------------")

## Prints the amount of time it takes to complete a function.
static func get_func_length(function: Callable) -> int:
	var time2: int
	var time: int = Time.get_ticks_usec()
	function.call()
	time2 = Time.get_ticks_usec()
	return time2 - time

## Prints the static memory usage and peak static memory usage.
static func printmem() -> void:
	prints(OS.get_static_memory_usage(),OS.get_static_memory_peak_usage())

## Returns the name of a file without its . extension at the end.
static func get_filename_without_extension(path: String) -> String:
	return path.get_file().rstrip(path.get_extension())

## Disconnects every signal from an Object. lmao.
static func disconnect_all_signals(obj: Object) -> void:
	for sig in obj.get_signal_list():
		disconnect_all_signal_connections(obj,sig.name)

## Disconnects every connection from an Object's signal. lmao.
static func disconnect_all_signal_connections(obj: Object, sig: String) -> void:
	var connections: Array = obj.get_signal_connection_list(sig)
	for connection in connections:
		obj.disconnect(sig,connection.callable)
