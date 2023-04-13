extends Node

var resources: Array[Resource] = []
var resource_id_map: Dictionary = {}
var network_entity_types: Dictionary = {}
var removed_nodes: Dictionary = {}
var removed_node_ids: Dictionary = {}
var peer: ENetMultiplayerPeer
var num_users: int = 1
var physics_delta: float
#var has_internet_connection: bool

var current_time: int = 0
var last_time: int = 0
var delta_time: int = 0
var delta_time_float: float
var interpfrac: float

var current_time_physics: int = 0
var last_time_physics: int = 0
var delta_time_physics: int = 0
var physics_start_time: int = 0

var current_time_net_recieve: int = 0
var last_time_net_recieve: int = 0
var delta_time_net_recieve: int = 0
var net_recieve_start_time: int = 0

var current_time_thread: int = 0
#var last_time_thread: float = 0
var delta_time_thread: int = 0
var time_thread := Thread.new()

var username: String

@onready var root: Viewport = get_root()
@onready var tree: SceneTree = get_tree()
@onready var query: PhysicsDirectSpaceState3D = root.world_3d.direct_space_state

func is_startup() -> bool:
	return current_time == 0

@warning_ignore("unused_parameter")
func do_time_thread(n = null) -> void:
	for i in INF:
		current_time_thread = Time.get_ticks_usec()
		delta_time_thread = current_time_thread - last_time#_thread
#		print(delta_time_thread)
#		last_time_thread = current_time_thread
#		if current_time_thread != current_time:
#			print("thread: threaded time %s != %s"%[current_time_thread, current_time])

func update_net_recieve_time() -> void:
	current_time_net_recieve = Time.get_ticks_usec()
	delta_time_net_recieve = current_time_net_recieve - last_time_net_recieve
	last_time_net_recieve = current_time_net_recieve

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	current_time_physics = Time.get_ticks_usec()
	var gaming: int = delta_time_physics
	var gaming2: float = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
	delta_time_physics = current_time_physics - last_time_physics
	last_time_physics = current_time_physics
	if ByteUtils.usec_to_seconds(delta_time_physics) <= get_physics_process_delta_time()*0.75:
		Console.write(str(ByteUtils.usec_to_seconds(delta_time_physics)," ",ByteUtils.usec_to_seconds(gaming)," ",ByteUtils.usec_to_seconds(gaming-delta_time_physics),"  ",gaming2," ",Engine.get_physics_frames()," ",Engine.get_frames_drawn()))
	if gaming2 > get_physics_process_delta_time():
		Console.write(str(gaming2," ",Engine.get_physics_frames()," ",Engine.get_frames_drawn()))

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	current_time = Time.get_ticks_usec()
	delta_time = current_time - last_time
	delta_time_float = float(delta_time) * 0.000001
	last_time = current_time
	@warning_ignore("static_called_on_instance")
	interpfrac = get_interpfrac()
#	if current_time_thread != current_time:
#		print("main: threaded time %s != %s"%[current_time_thread, current_time])



static func printusec() -> void:
	print(Time.get_ticks_usec())

func tick_time_value_towards(value: float, towards: float) -> float:
	value += delta_time
	return towards - value

func tick_time_value_down(value: float) -> float:
	return value - delta_time

func tick_time_value_up(value: float) -> float:
	return value + delta_time

func _init() -> void:
	resources.append_array(Resources.get_resource_list())
	resource_id_map.merge(Resources.get_resource_id_map())
#	stupid_shader_cache_workaround()
	# Passing self cuz 'Quack' as a thing isnt initialized yet is is insanely stupid
#	Network.initialize(self)
	physics_start_time = Time.get_ticks_usec()
	last_time_physics = physics_start_time

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

func get_resource_from_resource_id(id: int) -> Resource:
	return resources[resource_id_map[id]]

func spawn_node(idx: int, parent: Node) -> Node:
	var node: Node = resources[idx].instantiate()
	parent.add_child(node)
	return node

# it's not that much faster, lmao
func spawn_node_fast(idx: int, parent: Node) -> void:
	parent.add_child(resources[idx].instantiate())

func _ready() -> void:
	setup_connections()
	setup_filepaths()
	WindowUtils.initialize_general_settings()
	Audio.initialize_settings()
	on_scene_changed()
	multiplayer.set_server_relay_enabled(false)
	call_deferred("assign_physics_delta")
	return
	@warning_ignore("unreachable_code")
	if time_thread.start(Callable(self,"do_time_thread")) != OK:
		print("fuck off")
		quit()

const USER_DIRECTORY: String = "user://"
const SETTING_FILEPATH: String = "override.cfg"
func _exit_tree() -> void:
	ProjectSettings.save_custom(SETTING_FILEPATH)

func setup_filepaths() -> void:
	@warning_ignore("static_called_on_instance")
	setup_directory(USER_DIRECTORY)
	# same as setup_directory(Replays.REPLAY_DIRECTORY)
	Replays.setup_filepath()

static func setup_directory(directory: String) -> void:
	if !DirAccess.dir_exists_absolute(directory):
		# maybe make_dir_recursive?
		DirAccess.make_dir_absolute(directory)

func setup_connections() -> void:
	root.connect("size_changed",on_window_resized)
	root.connect("focus_entered",on_window_focused)
	root.connect("focus_exited",on_window_unfocused)

enum {DEFAULT_WINDOW_SIZE_x = 1152,DEFAULT_WINDOW_SIZE_y = 648}
var on_window_resized: Callable = func on_window_resized() -> void:
	for child in root.get_children():
		if child is Control:
			child.set_scale(Vector2(root.size.x/float(DEFAULT_WINDOW_SIZE_x),
									root.size.y/float(DEFAULT_WINDOW_SIZE_y)))

var on_window_unfocused: Callable = func on_window_unfocused() -> void:
	Engine.set_max_fps(WindowUtils.get_oof_fps_cap())

var on_window_focused: Callable = func on_window_focused() -> void:
	Engine.set_max_fps(WindowUtils.get_game_fps_cap() if is_3D_scene() else WindowUtils.get_menu_fps_cap())

func get_root_last_child() -> Node:
	return root.get_child(root.get_child_count() - 1)

func get_root() -> Window:
	return get_tree().get_root()

func refresh_root() -> void:
	root = get_root()

func refresh_tree() -> void:
	tree = get_tree()
#	refresh_root()

func get_mp() -> MultiplayerAPI:
	return tree.get_multiplayer()

func get_local_mp_id() -> int:
	# same as get_mp().get_unique_id()
	if multiplayer:
		return multiplayer.get_unique_id()
	else:
		return 1

func get_current_scene() -> Node:
	return tree.current_scene

func get_nodes_in_group(group: StringName) -> Array:
	return tree.get_nodes_in_group(group)

func get_current_camera() -> Camera3D:
	return root.get_camera_3d()

func change_scene(scene: String) -> void:
	tree.change_scene_to_file(scene)
	call_deferred("on_scene_changed")

func change_scene_to_node(node: Node) -> void:
	tree.unload_current_scene()
	root.add_child(node)
	tree.set_current_scene(get_root_last_child())
	call_deferred("on_scene_changed")

func is_3D_scene() -> bool:
	return get_current_scene() is Node3D

func on_scene_changed() -> void:
#	tree.set_multiplayer_poll_enabled(!tree.current_scene is MultiplayerLevel)
	if is_3D_scene():
		WindowUtils.go_game_settings()
	else:
		WindowUtils.go_menu_settings()
	on_window_resized.call()

func quit() -> void:
#	Settings.save_settings()
	tree.quit()

static func get_interpfrac() -> float:
	return Engine.get_physics_interpolation_fraction()

static func get_datetime_string() -> String:
	return Time.get_datetime_string_from_system(false, true).replace(":", "-")

static func get_tickrate() -> int:
	return Engine.get_physics_ticks_per_second()

static func set_tickrate(rate: int) -> void:
	Engine.set_physics_ticks_per_second(rate)

func set_physics_simulation_rate(rate: int) -> void:
	set_tickrate(rate)
	call_deferred("assign_physics_delta")

func assign_physics_delta() -> void:
	physics_delta = get_physics_process_delta_time()

static func array_getlast(array: Array):
	return array[array.size() - 1]

static func array_getlastidx(array: Array) -> int:
	return array.size() - 1

static func global_orientation(obj: Node3D) -> Vector3:
	# tbh normailizing this changes like basically nothing so maybe its not worth doing
	# example: changes (-0.318499, -0.088899, 0.943740) into (-0.318501, -0.088899, 0.943745)
	return obj.global_transform.basis.z.normalized()

static func get_window_title() -> String:
	return "Movement test (DEBUG)" if OS.is_debug_build() else "Movement test"

static func is_exported() -> bool:
	return !OS.has_feature("editor")

func change_window_title(title: String) -> void:
	root.set_title(title)

func reset_window_title() -> void:
	@warning_ignore("static_called_on_instance")
	change_window_title(get_window_title())

func append_to_window_title(title: String) -> void:
	@warning_ignore("static_called_on_instance")
	change_window_title(get_window_title() + title)

static func is_timer_running(timer: Timer) -> bool:
	# if a timer is inactive it also returns 0, so this works no matter what :)
	return false if timer.get_time_left() == 0.0 else true

# Depreciated because I learned about "is_instance_valid" lmao
#static func is_freed_instance(obj: Object) -> bool:
#	return weakref(obj).get_ref() == null

static func get_dict_from_array(array: Array) -> Dictionary:
	@warning_ignore("unassigned_variable")
	var dict: Dictionary
	for idx in array.size():
		dict[idx] = array[idx]
	return dict

static func apply_array_to_dict(dict: Dictionary, array: Array) -> void:
	for idx in array.size():
		dict[idx] = array[idx]

static func types_are_same(var1: Variant, var2: Variant) -> bool:
	return typeof(var1) == typeof(var2)

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

static func print_meta_list_for_node_and_children(node: Node) -> void:
	for child in node.get_children():
		print("--------------")
		print(child.get_name())
		print("--------------")
		print(child.get_meta_list())
		print("-------------------------------")
		print_meta_list_for_node_and_children(child)
		print("-------------------------------")

static func get_func_length(function: Callable) -> int:
	var time2: int
	var time: int = Time.get_ticks_usec()
	function.call()
	time2 = Time.get_ticks_usec()
	return time2 - time

static func printmem() -> void:
	prints(OS.get_static_memory_usage(),OS.get_static_memory_peak_usage())

static func get_filename_without_extension(path: String) -> String:
	return path.get_file().rstrip(path.get_extension())

static func disconnect_all_signals(obj: Object) -> void:
	for sig in obj.get_signal_list():
		disconnect_all_signal_connections(obj,sig.name)

static func disconnect_all_signal_connections(obj: Object, sig: String) -> void:
	var connections: Array = obj.get_signal_connection_list(sig)
	for connection in connections:
		obj.disconnect(sig,connection.callable)

static func connect_signal_if_not_already(sig: Signal, callable: Callable) -> void:
	if !sig.is_connected(callable):
		sig.connect(callable)

func remove_node(node: Node) -> void:
	var instance_id: int = node.get_instance_id()
	node.get_parent().remove_child(node)
	removed_nodes[instance_id] = node
	removed_node_ids[node] = instance_id

func reinsert_node(node: Node, parent: Node) -> void:
	parent.add_child(node)
	var instance_id: int = removed_node_ids[node]
	erase_node_from_dicts(node,instance_id)

func erase_node_from_dicts(node: Node, instance_id: int) -> void:
	removed_nodes.erase(instance_id)
	removed_node_ids.erase(node)

func reinsert_node_by_id(instance_id: int, parent: Node) -> void:
	var node: Node = removed_nodes[instance_id]
	parent.add_child(node)
	erase_node_from_dicts(node,instance_id)

func assert_valid_number_of_users() -> void:
	assert(num_users < 5 and num_users > 0,"% is an invalid number of users. Number of users must be less than 5 or greater than 0."%[num_users])

#func setup_gamestate(max_players: int, max_spectators: int, max_clients: int) -> void:
#	assert(get_current_scene() is MultiplayerLevel,"Current scene %s must be a MultiplayerLevel."%[get_current_scene()])
#	get_current_scene().gamestate.setup_info(max_players,max_spectators,max_clients)

@rpc("authority","reliable") func recieve_server_info(map_filepath: String, max_players: int, max_spectators: int, tickrate: int) -> void:
	net_recieve_start_time = Time.get_ticks_usec()
	last_time_net_recieve = net_recieve_start_time
	@warning_ignore("static_called_on_instance")
	set_physics_simulation_rate(tickrate)
	change_scene(map_filepath)

# Server funcs
#@warning_ignore("shadowed_variable")
#var on_peer_connected: Callable = func on_peer_connected(peer: int) -> void:
#	Console.write("Peer %s connected."%[peer])
#	var scene: MultiplayerLevel = tree.current_scene
#	var gamestate: GameState = scene.gamestate
#	@warning_ignore("static_called_on_instance")
#	rpc_id(peer,"recieve_server_info",scene.scene_file_path,gamestate.max_players,gamestate.max_spectators,get_tickrate())

#@warning_ignore("shadowed_variable")
#var on_peer_disconnected: Callable = func on_peer_disconnected(peer: int) -> void:
#	Console.write("Peer %s disconnected."%[peer])
#	tree.current_scene.gamestate.remove_player(peer)

# Client connection funcs
#var on_connection_succeeded: Callable = func on_connection_succeeded() -> void:
#	Console.write("Connection succeeded!")
#	@warning_ignore("static_called_on_instance")
#	disconnect_all_signals(get_mp())
#	Network.setup_client_connections()

#var on_connection_failed: Callable = func on_connection_failed() -> void:
#	Console.write("Connection failed.")
#	Network.reset()

# Client funcs
#var on_server_disconnected: Callable = func on_server_disconnected() -> void:
#	Console.write("Server disconnected.")
#	Network.reset()
