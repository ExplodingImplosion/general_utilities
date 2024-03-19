
const quit_aliases: PackedStringArray = ["exit"]
static func quit_cmd() -> void:
	(Engine.get_main_loop() as SceneTree).quit()

static func max_fps_cmd(fps: int) -> void:
	WindowUtils.set_max_fps(fps)

static func max_game_fps_cmd(fps: int) -> void:
	WindowUtils.set_max_game_fps(fps)

static func max_menu_fps_cmd(fps: int) -> void:
	WindowUtils.set_max_menu_fps(fps)

static func max_fps_nofocus_cmd(fps: int) -> void:
	WindowUtils.set_max_out_of_focus_fps(fps)

static func res_game_cmd(_resx: int, _resy: int) -> void:
	doesntwork()

static func res_cmd(_resx: int, _resy: int) -> void:
	doesntwork()

static func res_menu_cmd(_resx: int, _resy: int) -> void:
	doesntwork()

static func change_scene_cmd(scene_path: String) -> void:
	(Engine.get_main_loop() as SceneTree).change_scene_to_file(scene_path)
	Quack.on_scene_changed.call_deferred()

static func potato_cmd() -> void:
	render_scale_cmd(0.2)
	max_fps_cmd(60)

const perf_menu: PackedScene = preload("res://Interface/Performance Overlay/Performance Overlay.tscn")
static var perf_overlay: CanvasLayer
const performance_overlay_aliases: PackedStringArray = ["perf_overlay"]
static func performance_overlay_cmd() -> void:
	if perf_overlay == null:
		perf_overlay = perf_menu.instantiate()
		# dumb hack
		Quack.root.add_child(perf_overlay)
	else:
		perf_overlay.queue_free()
		perf_overlay = null

static func toggle_fullscreen_cmd() -> void:
	WindowUtils.toggle_fullscreen()

static func set_fullscreen_cmd(toggle: bool) -> void:
	WindowUtils.set_fullscreen(toggle)

static func fullscreen_cmd() -> void:
	WindowUtils.go_fullscreen()

static func windowed_cmd() -> void:
	WindowUtils.go_windowed()

# maybe only make this work if its a debug build
static func change_setting_cmd(_setting: String, _newvalue: Variant) -> void:
	doesntwork()

static func get_setting_cmd(_setting: String) -> void:
	doesntwork()

static func get_setting_names_cmd() -> void:
	doesntwork()

static func get_all_settings_cmd() -> void:
	doesntwork()

const time_scale_aliases: PackedStringArray = ["set_time_scale","change_time_scale"]
static func time_scale_cmd(amnt: float) -> void:
	Engine.set_time_scale(amnt)

static func reset_time_scale_cmd() -> void:
	time_scale_cmd(1)

static func printmem_cmd() -> void:
	Console.write("Current memory usage: %s Bytes\nPeak memory usage: %s Bytes"%[OS.get_static_memory_usage(),OS.get_static_memory_peak_usage()])

static func printmem_gb_cmd() -> void:
	var static_mem: int = OS.get_static_memory_usage()
	var peak_static_mem: int = OS.get_static_memory_peak_usage()
	var static_mem_gb: float = ByteUtils.bytes_to_gigabytes(static_mem)
	var peak_static_mem_gb: float = ByteUtils.bytes_to_gigabytes(peak_static_mem)
	Console.write("Current memory usage: %s Gigabytes\nPeak memory usage: %s Gigabytes"%[static_mem_gb,peak_static_mem_gb])

static func printmem_mb_cmd() -> void:
	var static_mem: int = OS.get_static_memory_usage()
	var peak_static_mem: int = OS.get_static_memory_peak_usage()
	var static_mem_mb: float = ByteUtils.bytes_to_megabytes(static_mem)
	var peak_static_mem_mb: float = ByteUtils.bytes_to_megabytes(peak_static_mem)
	Console.write("Current memory usage: %s Megabytes\nPeak memory usage: %s Megabytes"%[static_mem_mb,peak_static_mem_mb])

static func printmem_verbose_cmd() -> void:
	printmem_cmd()
	Console.writeln()
	printmem_mb_cmd()
	Console.writeln()
	printmem_gb_cmd()
	Console.writeln()
	var meminfo: Dictionary = OS.get_memory_info()
	for key in meminfo:
		Console.write("%s: %s"%[key,meminfo[key]])

static func inst2dict2array(node: Node) -> Array:
	return inst_to_dict(node).values()

const kill_aliases: PackedStringArray = ["kill_me"]
static func kill_cmd() -> void:
	pass

static func reset_player_health() -> void:
	pass

const heal_me_aliases: PackedStringArray = ["heal_player"]
static func heal_me_cmd(_amount: int) -> void:
	pass

const hurt_me_aliases: PackedStringArray = ["hurt_player"]
static func hurt_me_cmd(_amount: int) -> void:
	pass

const change_health_by_aliases: PackedStringArray = ["change_health"]
static func change_health_by_cmd(_amount: int) -> void:
	doesntwork()

static func set_health_cmd(_health: int) -> void:
	doesntwork()

const respawn_aliases: PackedStringArray = ["restart"]
static func respawn_cmd() -> void:
	Console.write("Respawning player (by changing the scene to main.tscn lmao)")
	Console.get_tree().change_scene_to_file("res://main.tscn")

const render_scale_aliases: PackedStringArray = ["set_render_scale","set_renderscale"]
static func render_scale_cmd(scale: float) -> void:
	WindowUtils.set_render_scale(scale)

const set_volume_aliases: PackedStringArray = ["volume","master_volume","set_master_volume"]
static func set_volume_cmd(_scale: float) -> void:
	doesntwork()
	#Audio.change_master_volume(scale)

const upnp_test_aliases: PackedStringArray = ["test_upnp"]
static func upnp_test_cmd() -> void:
	var upnp_thread := Thread.new()
	upnp_thread.start(upnp_test)
	Console.write("Starting UPnP test...")

static func upnp_test() -> void:
	var upnp := UPNP.new()
	upnp.discover()
	var _devices: Array[UPNPDevice] = []
	var _gateway: UPNPDevice = upnp.get_gateway()
	Console.write("UPnP device detected.") if upnp.get_device_count() > 0 else Console.write("No UPnP device detected.")

const show_commands_aliases: PackedStringArray = ["show_all_commands","help","get_commands","commands"]
static func show_commands_cmd() -> void:
	Console.write("All commands and aliases:")
	for command in Console.commands:
		Console.write(Console.indent_string+command.get_command_name()+", aliases:")
		for alias in command.get_aliases():
			Console.write(Console.indent_string+Console.indent_string+alias)
		await Quack.await_if_out_of_time(0.1)
	Console.write("\nInput help_command [command] for more details about a specific command. Input help_advanced for more details about all commands.")

static func help_command_cmd(command_string: String) -> void:
	
	var command: Console.CommandInfo = Console.command_string_map.get(command_string)
	if command == null:
		return Console.write("Command %s does not exist."%[command_string])
	
	# Write command
	Console.write(BBCode.set_color("Command: "+command.get_command_name(),Color.YELLOW))
	
	# Write command arguments
	if command.has_args():
		Console.write(BBCode.set_color("Arguments:",Color.CHOCOLATE))
		for arg in command.args_info:
			Console.write("%s%s (%s)"%[Console.indent_string,arg[0],arg[1]])
	else:
		Console.write(BBCode.set_color("No arguments.",Color.GREEN*0.9))
	
	# WRite aliases
	Console.write(BBCode.set_color("Aliases:",Color.CYAN))
	for alias in command.get_aliases():
		Console.write(Console.indent_string+BBCode.set_color(alias,Color.CYAN * 0.7))

static func help_advanced_cmd() -> void:
	var command: Console.CommandInfo
	var num_commands: int = Console.commands.size()
	Console.writeln()
	for i in num_commands:
		command = Console.commands[i]
		help_command_cmd(command.get_command_name())
		# write 2 newlines until last command
		if i < num_commands - 1:
			Console.writeln()
		await Quack.await_if_out_of_time(0.1)

static func doesntwork() -> void:
	Console.writerr("doesnt work lmao")

static func change_physics_simulation_rate_cmd(_rate: int) -> void:
	doesntwork()

const run_code_test_aliases: PackedStringArray = ["code_test","test_code","test_function","test_func","function_test","func_test"]
static func run_code_test_cmd(test: String) -> void:
	if !Quack.is_exported():
		var tests: GDScript = load("res://Dev/Code Tests.gd")
		var methods: Array[Dictionary] = tests.get_script_method_list()
		var method_idx: int = -1
		for i in methods.size():
			if methods[i].name == test:
				method_idx = i
		if method_idx == -1:
			return Console.writerr("Test %s does not exist."%[test])
		if !methods[method_idx].args.is_empty():
			return Console.writerr("This function accepts arguments, which aren't supported for being called from the console.")
		tests.call(test)

const MAIN_MENU_SETTING_PATH = &"application/run/main_scene"
static var MAIN_MENU_FILEPATH: String = ProjectSettings.get_setting(MAIN_MENU_SETTING_PATH)
static func main_menu_cmd() -> void:
	assert(!MAIN_MENU_FILEPATH.is_empty(), "nvm i gotta change how i implement MAIN_MENU_FILEPATH cuz its empty rn")
	if (Engine.get_main_loop() as SceneTree).current_scene.scene_file_path == MAIN_MENU_FILEPATH:
		return Console.write("Already at main menu.")
	Console.write("Returning to main menu.")
	if Network.multiplayer_connected():
		disconnect_cmd()
	change_scene_cmd(MAIN_MENU_FILEPATH)

const clear_console_aliases: PackedStringArray = ["clear"]
static func clear_console_cmd() -> void:
	Console.readout.clear()

static func reset_window_cmd() -> void:
	var root: Window = Quack.root
	if root.get_mode() != Window.MODE_WINDOWED:
		root.set_mode(Window.MODE_WINDOWED)
	root.size = root.content_scale_size

static func play_cmd(levelname: String) -> void:
	play_custom_cmd(levelname,Engine.physics_ticks_per_second)

static func play_custom_cmd(levelname: String,tickrate: int) -> void:
	if Engine.get_physics_ticks_per_second() != tickrate:
		Engine.set_physics_ticks_per_second(tickrate)
	Quack.change_scene(Level.level_path_from_name(levelname))

static func host_cmd(levelname: String) -> void:
	host_custom_cmd(levelname,Engine.physics_ticks_per_second)

static func host_custom_cmd(levelname: String, tickrate: int) -> void:
	Network.host(Level.level_path_from_name(levelname),20,4,tickrate,-1,Network.DEFAULT_PORT)

static func get_ip_cmd() -> void:
	Console.write("Local IPv4: " + Network.get_hostname_desktop())

static func get_all_ip_cmd() -> void:
	var local_addys: PackedStringArray = IP.get_local_addresses()
	Console.write("List of all local addresses:")
	for addy in local_addys:
		Console.write(addy)

static func connect_cmd(ip: String) -> void:
	Network.connect_to_server(ip,Network.DEFAULT_PORT)

static func connect_with_port_cmd(ip: String, port: int) -> void:
	Network.connect_to_server(ip,port)

static func disconnect_cmd() -> void:
	Console.write("Disconnecting from server.")
	Network.reset()

static func go_fp_cmd() -> void:
	pass

static func dump_replay_cmd() -> void:
	pass

static func free_cam_cmd() -> void:
	pass

static func get_func_length(nodepath: String, function: String) -> void:
	@warning_ignore("static_called_on_instance")
	Console.write(str(Quack.get_func_length(Callable(Quack.root.get_node(NodePath(nodepath)),function))))

func pingtest_all_cmd() -> void:
	if Network.is_server():
		Console.write("Pinging all peers...")
		Console.receive_pingtest.rpc()
		Console.ping_start_time = Time.get_ticks_usec()

func pingtest_cmd(peer: int) -> void:
	if peer == Network.SERVER or Network.is_server():
		Console.write("Pinging peer %s"%[peer])
		Console.receive_pingtest.rpc_id(peer)
		Console.ping_start_time = Time.get_ticks_usec()

static func change_team_cmd(team_id: int) -> void:
	change_player_team_cmd(GameState.selfid,team_id)

static func change_player_team_cmd(_player_id: int, _team_id: int) -> void:
	var current_scene: Node = Quack.get_current_scene()
	# maybe change to be a Level
	if current_scene is MultiplayerLevel:
		if Network.is_server():
			breakpoint
#			current_scene.gamestate.rpc_id(Network.SERVER,"on_player_request_join_team",player_id,team_id)
		else:
			breakpoint
#			current_scene.gamestate.try_add_player_to_team(Network.SERVER,team_id)
	else:
		Console.write("Cannot change team if current scene is not a MultiplayerLevel.")

static func change_local_player_team_cmd(screen_idx: int, team_id: int) -> void:
	change_player_team_cmd(GameState.selfid+screen_idx,team_id)

static func sens_cmd(sens: float) -> void:
	Inputs.change_sens(sens)

static func get_net_info_cmd() -> void:
	if Network.multiplayer_connected():
		var client := GameState.local_client
		Console.write(
"Auth frame signature: %s
Input signature: %s
Used input signature: %s
Received input signature: %s
Frame delay: %s
Server input delay: %s
Network input delay: %s
Total input delay: %s"
%[
				client.last_acknowledged_frame,client.input_signature,
				client.last_used_input_signature,client.last_received_input_signature,
				client.frame_delay,client.get_server_input_delay(),
				client.get_network_input_delay(),client.get_total_input_delay()
			]
		)
	else:
		Console.write("Can't get net info if not connected to a multiplayer game.")

static func change_tickrate_cmd(rate: int) -> void:
	Tickrate.set_physics_simulation_rate(rate)

static func connect_debug_cmd(ip: String) -> void:
	if !NetDebug.lag_faker_active():
		NetDebug.start_lag_faker(ip)
	connect_cmd(ip)

static func start_lag_faker_cmd() -> void:
	NetDebug.start_lag_faker()

static func stop_net_debugger_cmd() -> void:
	if Network.multiplayer_connected():
		return Console.write("Cannot end debugger while connected to multiplayer.")
	NetDebug.stop_lag_faker()

static func fake_lag_cmd(amount: float) -> void:
	var lag_faker := NetDebug.get_lag_faker()
	if !lag_faker: return
	
	lag_faker.set_min_latency(TimeUtils.msecf_to_usec(amount))

static func fake_jitter_cmd(amount: float) -> void:
	var lag_faker := NetDebug.get_lag_faker()
	if !lag_faker: return
	
	lag_faker.set_jitter(TimeUtils.msecf_to_usec(amount))

static func fake_loss_cmd(frequency: int) -> void:
	var lag_faker := NetDebug.get_lag_faker()
	if !lag_faker: return
	
	lag_faker.set_loss(frequency)

static func fake_lag_client_cmd(amount: float) -> void:
	var lag_faker := NetDebug.get_lag_faker()
	if !lag_faker: return
	
	lag_faker.client_params.fake_min_latency_usec = TimeUtils.msecf_to_usec(amount)

static func fake_lag_server_cmd(amount: float) -> void:
	var lag_faker := NetDebug.get_lag_faker()
	if !lag_faker: return
	
	lag_faker.server_params.fake_min_latency_usec = TimeUtils.msecf_to_usec(amount)

static func fake_jitter_client_cmd(amount: float) -> void:
	var lag_faker := NetDebug.get_lag_faker()
	if !lag_faker: return
	
	lag_faker.client_params.fake_jitter_usec = TimeUtils.msecf_to_usec(amount)

static func fake_jitter_server_cmd(amount: float) -> void:
	var lag_faker := NetDebug.get_lag_faker()
	if !lag_faker: return
	
	lag_faker.server_params.fake_jitter_usec = TimeUtils.msecf_to_usec(amount)

static func fake_loss_client_cmd(frequency: int) -> void:
	var lag_faker := NetDebug.get_lag_faker()
	if !lag_faker: return
	
	lag_faker.client_params.fake_loss = frequency

static func fake_loss_server_cmd(frequency: int) -> void:
	var lag_faker := NetDebug.get_lag_faker()
	if !lag_faker: return
	
	lag_faker.server_params.fake_loss = frequency

static func check_net_node_types_cmd() -> void:
	Console.write("Networked node types:")
	var node_type: NetworkedNode.NetNodeInfo
	for key in Resources.networked_node_types.keys():
		await Quack.await_if_out_of_time(0.1)
		Console.writeln()
		Console.writevar(key)
		node_type = Resources.networked_node_types[key]
		for property in node_type.get_property_list():
			await Quack.await_if_out_of_time(0.1)
			if QuackMultiplayer.is_script_variable(property):
				Console.write("   "+property.name+": "+str(node_type[property.name]))

static func write_script_properties(object: Object,exceptions: PackedStringArray = [],prefix: String = "") -> void:
	for property in object.get_property_list():
		if QuackMultiplayer.is_script_variable(property) and !exceptions.has(property.name):
			Console.write(prefix+property.name+": "+str(object[property.name]))

const reload_neworked_node_types_aliases: PackedStringArray = ["reload_net_node_types","reload_net_nodes","reload_networked_scripts","reload_net_scripts"]
static func reload_networked_node_types_cmd() -> void:
	Console.write("Reloading networked node types...")
	Console.write("Clearing networked node types...")
	Resources.networked_node_types.clear()
	Console.write("Registering networked node types...")
	QuackMultiplayer.register_all_scripts()
	Console.write("Networked node types registered.")

const reload_console_commands_aliases: PackedStringArray = ["reload_console","refresh_commands","refresh_console"]
static func reload_console_commands_cmd() -> void:
	Console.reload_commands()
static func get_all_classes_info_cmd() -> void:
	var global_class_list: Array[Dictionary] = ProjectSettings.get_global_class_list()
	await Quack.await_if_out_of_time(0.1)
	for c in global_class_list:
		Console.write(String(c.class))
		write_script_info(load(c.path))

static func get_class_info_cmd(name: String) -> void:
	var global_class_list: Array[Dictionary] = ProjectSettings.get_global_class_list()
	await Quack.await_if_out_of_time(0.1)
	var script: Script
	for c in global_class_list:
		if c.class == name:
			script = load(c.path)
			break
		await Quack.await_if_out_of_time(0.1)
	if !script:
		return Console.write("%s not here lmao"%[name])
	
	write_script_info(script)

static func write_script_info(script: Script) -> void:
	var constant_map: Dictionary = script.get_script_constant_map()
	await Quack.await_if_out_of_time(0.1)
	Console.write("Constants:")
	for constant in constant_map:
		Console.write(Console.indent_string+"%s: %s"%[constant,str(constant_map[constant])])
		await Quack.await_if_out_of_time(0.1)
	Console.writelns(2)
	
	Console.write("Properties:")
	write_array_of_dicts(script.get_script_property_list())
	
	Console.write("Methods:")
	write_array_of_dicts(script.get_script_method_list())
	
	Console.write("Signals:")
	write_array_of_dicts(script.get_script_signal_list())

static func write_array_of_dicts(array: Array[Dictionary],await_frac: float = 0.1) -> void:
	for dict in array:
		write_dict_stringkeyonly(dict,await_frac)
		Console.writeln()

static func write_dict_stringkeyonly(dict: Dictionary,await_frac: float = 0.1) -> void:
	Quack.await_if_out_of_time(await_frac)
	for key in dict:
		Console.write(Console.indent_string+"%s: %s"%[key,str(dict[key])])
		await Quack.await_if_out_of_time(await_frac)

static func get_classes_cmd() -> void:
	var global_class_list: Array[Dictionary] = ProjectSettings.get_global_class_list()
	await Quack.await_if_out_of_time(0.1)
	for c in global_class_list:
		for property in c:
			Console.write("%s: %s"%[property,c[property]])
			await Quack.await_if_out_of_time(0.1)
		Console.writeln()
