extends Window

const postfix := "_cmd"
const toggle := "console"
const up := "ui_up"
const down := "ui_down"
const UP := -1
const DOWN := 1
const MINSIZE := Vector2i(200,100)
const DEFAULTSIZE := Vector2i(600,650)
const DEFAULTPOS := Vector2i(40,40)
const convert_args := true
var label := RichTextLabel.new()
var line := LineEdit.new()
var c := VBoxContainer.new()

var current := 0
var history := []
var commands := {
	"sens" = PackedStringArray(["set_sensitivity","set_sens","sensitivity"]),
	"quit" = PackedStringArray(),
	"change_tickrate" = PackedStringArray(["tickrate","set_tickrate"]),
	"max_fps" = PackedStringArray(),
	"max_game_fps" = PackedStringArray(),
	"max_menu_fps" = PackedStringArray(),
	"max_fps_nofocus" = PackedStringArray(),
	"res" = PackedStringArray(["resolution","set_res","set_resloution"]),
	"res_game" = PackedStringArray(["game_resolution","resolution_game","set_game_res","set_game_resolution","set_resolution_game"]),
	"res_menu" = PackedStringArray(["menu_resolution","resolution_menu","set_menu_res","set_menu_resolution","set_resolution_menu"]),
	"change_scene" = PackedStringArray(),
	"play" = PackedStringArray(),
	"play_custom" = PackedStringArray(),
	"host" = PackedStringArray(),
	"host_custom" = PackedStringArray(),
	"get_ip" = PackedStringArray(["local_address","get_net_address","net_address","get_local_address"]),
	"get_all_ip" = PackedStringArray(["get_local_addresses","get_net_addresses","get_all_addresses","get_all_local_addresses"]),
	"connect" = PackedStringArray(["join"]),
	"connect_with_port" = PackedStringArray(["join_with_port"]),
	"disconnect" = PackedStringArray(["dc","leave","leavegame","leave_game"]),
	"go_fp" = PackedStringArray(["firstperson","go_first_person","fp"]),
	"potato" = PackedStringArray(),
	"performance_overlay" = PackedStringArray(["perf_overlay"]),
	"toggle_fullscreen" = PackedStringArray(),
	"windowed" = PackedStringArray(["go_windowed"]),
	"fullscreen" = PackedStringArray(["go_fullscreen"]),
	"change_setting" = PackedStringArray(["set_setting"]),
	"get_setting" = PackedStringArray(),
	"get_setting_names" = PackedStringArray(["get_all_setting_names"]),
	"get_all_settings" = PackedStringArray(["get_settings"]),
	"dump_replay" = PackedStringArray(),
	"freecam" = PackedStringArray(["free_cam"]),
	"timescale" = PackedStringArray(["set_timescale","set_time_scale","host_timescale","time_scale"]),
	"reset_timescale" = PackedStringArray(),
	"render_scale" = PackedStringArray(["set_render_scale","renderscale","setrenderscale","set_renderscale"]),
	"set_volume" = PackedStringArray(["change_volume","set_master_volume","change_master_volume","volume"]),
	"control" = PackedStringArray(),
	"upnp_test" = PackedStringArray(["upnptest","upnp"]),
	"get_func_length" = PackedStringArray(["get_funclength","funclength"]),
	"change_health_by" = PackedStringArray(),
	"set_health" = PackedStringArray(["health","sethealth"]),
	"respawn" = PackedStringArray(["force_respawn"]),
	"kill" = PackedStringArray(["killme"]),
	"printmem" = PackedStringArray(["print_mem"]),
	"show_commands" = PackedStringArray(["help","show_all_commands","commands"]),
	"pingtest" = PackedStringArray(),
	"pingtest_all" = PackedStringArray(),
	"change_physics_simulation_rate" = PackedStringArray(["set_physics_simulation_rate","change_physics_sim_rate","physics_simulation_rate","physics_sim_rate"]),
}
var cmd_args_amount := {}

func _init():
	setup_commands()
	setup_window()
	
	add_child(c)
	@warning_ignore("static_called_on_instance")
	setup_margins(c)
	
	setup_label()
	
	setup_line()
	hide()

func setup_window() -> void:
	set_title("Console")
	set_min_size(MINSIZE)
	set_position(DEFAULTPOS)
#	call_deferred("setup_window_size")

func setup_window_size() -> void:
	Quack.setup_subwindow_size(self,DEFAULTSIZE)

func setup_c() -> void:
	add_child(c)
	@warning_ignore("static_called_on_instance")
	setup_margins(c)

static func setup_margins(container: VBoxContainer) -> void:
#	return
	# this shit is broken lol
#	container.margin_bottom = 0
#	container.margin_left = 0
#	container.margin_top = 0
#	container.margin_right = 0
	container.anchor_bottom = 1
	container.anchor_left = 0
	container.anchor_top = 0
	container.anchor_right = 1

func setup_label() -> void:
	@warning_ignore("static_called_on_instance")
	setup_label_properties(label)
	c.add_child(label)
	label.set_focus_mode(Control.FOCUS_NONE)

static func setup_label_properties(this_label: RichTextLabel) -> void:
	this_label.set_use_bbcode(true)
	this_label.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	this_label.set_scroll_follow(true)
	this_label.set_selection_enabled(true)

func setup_line() -> void:
	@warning_ignore("static_called_on_instance")
	setup_line_properties(line, self)
	c.add_child(line)

static func setup_line_properties(this_line: LineEdit, console: Window) -> void:
	this_line.connect("text_submitted", Callable(console, "command"))
	this_line.set_clear_button_enabled(true)

func toggle_activation() -> void:
	disable() if is_visible() else activate()

func activate() -> void:
	popup()
	line.grab_focus()
	@warning_ignore("static_called_on_instance")
	Inputs.show_cursor()
#	if position.x > Quack.root.size.x or position.y > Quack.root.size.y:
	setup_window_size()
	# functionally the same as:
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func disable() -> void:
	hide()
	line.clear()
	# this might get depreciated if the console/menu disconnects the mouse
	# from getting captured
	if Inputs.is_mouse_connected_to_object():
		@warning_ignore("static_called_on_instance")
		Inputs.capture_cursor()

func reconnect_nodes() -> void:
	pass

func move_in_history(amount: int) -> void:
	current = int(clamp(current + amount, 0, history.size() - 1))
	line.set_text(history[current])
	line.caret_column = line.get_text().length()

func is_line_focused() -> bool:
	return true if gui_get_focus_owner() == line else false

func can_history_move() -> bool:
	return true if is_line_focused() and !history.is_empty() else false

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if Input.is_action_just_pressed(toggle) or is_visible() and Input.is_action_just_pressed("ui_cancel"):
		toggle_activation()
	if Input.is_action_just_pressed(up):
		if can_history_move():
			move_in_history(UP)
	if Input.is_action_just_pressed(down):
		if can_history_move():
			move_in_history(DOWN)

static func prop_list_has_commands(properties: Array[Dictionary]) -> int:
	return list_has_name(properties,"commands")

@warning_ignore("shadowed_variable_base_class")
static func list_has_name(list: Array[Dictionary], name: String) -> int:
	for i in list.size():
		if list[i].name == name:
			return i
	return -1

@warning_ignore("shadowed_variable")
func add_command(alias: String, command: String, num_args: int) -> void:
	commands[alias] = command
	cmd_args_amount[alias] = num_args

func setup_commands() -> void:
	var properties: Array[Dictionary] = get_property_list()
	@warning_ignore("static_called_on_instance")
	if prop_list_has_commands(properties):
		var methods: Array[Dictionary] = get_method_list()
		var aliases: PackedStringArray
		@warning_ignore("shadowed_variable")
		for command in commands.keys():
			@warning_ignore("static_called_on_instance")
			var method_idx: int = list_has_name(methods,command+postfix)
			assert(method_idx != -1,"Console methods does not include command %s."%[command])
			var num_args: int = methods[method_idx].args.size()
			aliases = commands[command]
			add_command(command,command,num_args)
			for alias in aliases:
				add_command(alias,command,num_args)
	else:
		@warning_ignore("assert_always_false")
		assert(false,"Trying to connect an incompatible node! (Doesn't have commands property).")

func disconnect_node(node: Node) -> void:
	for key in commands.keys():
		if commands[key] == node:
			commands.erase(key)
			cmd_args_amount.erase(key)

func writeln() -> void:
	label.append_text("\n")
	print("\n")

func write(s: String) -> void:#, bbcode = null) -> void:
	label.append_text(s + "\n")
	print(s)

func writerr(s: String) -> void:#, bbcode = null) -> void:
	label.append_text(s + "\n")
	printerr(s)

#func bbcode_wrap(s: String, bbcode = null) -> String:
#	return str(s) if bbcode == null else str("[bbcode c=", bbcode, "]", s, "[/bbcode]")

func command(cmd: String):
	if cmd == "":
		return
	line.clear()
	write(str("> ", cmd))#, "line")
	var args: Array = Array(cmd.split(" "))
	@warning_ignore("shadowed_variable")
	var command: String = args.pop_front()
	if convert_args:
		for i in args.size():
			if args[i] == "false":
				args[i] = false
			elif args[i] == "true":
				args[i] = true
			elif args[i].is_valid_float():
				args[i] = args[i].to_float()
			elif args[i].is_valid_int():
				args[i] = args[i].to_int()
			elif "_" in args[i]:
				args[i] = str(args[i]).replace("_", " ")
	if commands.get(command) != null:
		args.resize(cmd_args_amount[command])
		callv(commands[command]+postfix, args)
	else:
		command_not_found(command)
	history.append(cmd)
	current = history.size()

@warning_ignore("shadowed_variable")
func command_not_found(command: String) -> void:
	write(str("Command '", command, "' not found"))#, "error")



#///////////////////////////////////////////////////////////////////////////////
# CONSOLE COMMANDS
#///////////////////////////////////////////////////////////////////////////////

func sens_cmd(sens: float) -> void:
	Inputs.change_sens(sens)

func quit_cmd() -> void:
	Quack.quit()

func change_tickrate_cmd(tickrate: int) -> void:
	@warning_ignore("static_called_on_instance")
	Quack.set_tickrate(tickrate)

func max_fps_cmd(fps: int) -> void:
	WindowUtils.set_max_game_fps(fps) if Quack.is_3D_scene() else WindowUtils.set_max_menu_fps(fps)

func max_game_fps_cmd(fps: int) -> void:
	WindowUtils.set_max_game_fps(fps)

func max_menu_fps_cmd(fps: int) -> void:
	WindowUtils.set_max_menu_fps(fps)

func max_fps_nofocus_cmd(fps: int) -> void:
	WindowUtils.set_max_out_of_focus_fps(fps)


func res_game_cmd(rex: int, resy: int) -> void:
	pass

func res_cmd(resx: int, resy: int) -> void:
	doesntwork()
#	Settings.change_setting(Quack.video_settings_string,"Resolution",Vector2i(resx,resy))

func res_menu_cmd(resx: int, resy: int) -> void:
	doesntwork()
#	Settings.change_setting(Quack.video_settings_string,"MenuResolution",Vector2i(resx,resy))

func change_scene_cmd(scene_path: String) -> void:
	write("If you included any spaces in that string, it's not gonna work lol")
	Quack.change_scene(scene_path)

func play_cmd(levelname: String) -> void:
	play_custom_cmd(levelname,Engine.physics_ticks_per_second)

func play_custom_cmd(levelname: String,tickrate: int) -> void:
	doesntwork()
#	@warning_ignore("static_called_on_instance")
#	if Quack.get_tickrate() != tickrate:
#		Quack.set_tickrate(tickrate)
#	Quack.change_scene(Level.level_path_from_name(levelname))

func host_cmd(levelname: String) -> void:
	host_custom_cmd(levelname,Engine.physics_ticks_per_second)

func host_custom_cmd(levelname: String, tickrate: int) -> void:
	doesntwork()
#	Network.host(Level.level_path_from_name(levelname),20,4,tickrate,-1,Network.DEFAULT_PORT)

func get_ip_cmd() -> void:
	doesntwork()
#	write("Local IPv4: " + Network.get_hostname_desktop())

func get_all_ip_cmd() -> void:
	var local_addys: PackedStringArray = IP.get_local_addresses()
	write("List of all local addresses:")
	for addy in local_addys:
		write(addy)

func connect_cmd(ip: String) -> void:
	doesntwork()
#	Network.connect_to_server(ip,Network.DEFAULT_PORT)

func connect_with_port_cmd(ip: String, port: int) -> void:
	doesntwork()
#	Network.connect_to_server(ip,port)

func disconnect_cmd() -> void:
	doesntwork()
#	write("Disconnecting from server.")
#	Network.reset()

func go_fp_cmd(player: int) -> void:
	doesntwork()
#	if Network.get_entities().has(player) and Network.get_entity(player) is PlayerCharacter:
#		Network.get_entity(player).go_first_person()

func potato_cmd() -> void:
	render_scale_cmd(0.2)
	max_fps_cmd(60)

var perf_menu: PackedScene = Quack.get_resource(Resources.PERFOVERLAY)
var perf_overlay: CanvasLayer
func performance_overlay_cmd() -> void:
	if perf_overlay == null:
		perf_overlay = perf_menu.instantiate()
		Quack.root.add_child(perf_overlay)
	else:
		perf_overlay.queue_free()
		perf_overlay = null

func toggle_fullscreen_cmd() -> void:
	WindowUtils.set_fullscreen(!WindowUtils.is_root_windowed())

@warning_ignore("shadowed_variable")
func set_fullscreen_cmd(toggle: bool) -> void:
	WindowUtils.set_fullscreen(toggle)

func fullscreen_cmd() -> void:
	WindowUtils.go_fullscreen()

func windowed_cmd() -> void:
	WindowUtils.go_windowed()

# maybe only make this work if its a debug build
func change_setting_cmd(setting: String,newvalue: Variant) -> void:
	doesntwork()
#	match Settings.find_and_change_setting(setting,newvalue):
##		these lines are insanely stupid because of an engine bug where enums arent considered
##		to be constants if they're from other scripts...
##		Settings.console_settings_change.SUCCESS:
#		0:
#			write("Changed %s to %s. Setting has not been applied."%[setting,newvalue])
##		Settings.console_settings_change.COULDNT_FIND:
#		1:
#			write("Couldn't find requested setting %s."%[setting])
##		Settings.console_settings_change.WRONG_TYPE:
#		2:
#			write("Couldn't change %s to %s. %s is an incompatible type with %s."%[setting,newvalue,newvalue,setting])

func get_setting_cmd(setting: String) -> void:
	doesntwork()
#	write("%s is %s"%[setting,Settings.find_and_get_setting_as_string(setting)])

func get_setting_names_cmd() -> void:
	doesntwork()
#	for section in Settings._config.get_sections():
#		write("\n\n%s:\n"%[section])
#		for key in Settings._config.get_section_keys(section):
#			write("%s\n"%[key])

func get_all_settings_cmd() -> void:
	doesntwork()
#	for section in Settings._config.get_sections():
#		write("\n\n%s:\n"%[section])
#		for key in Settings._config.get_section_keys(section):
#			write("%s: %s\n"%[key,Settings.get_setting(section,key)])

func dump_replay_cmd() -> void:
	doesntwork()

func freecam_cmd() -> void:
	doesntwork()
#	var currentcam: Camera3D = Quack.get_current_camera()
#	if currentcam is FreeCam:
#		currentcam.queue_free()
#	else:
#		var pos: Vector3
#		var angle: Vector2
#		if currentcam:
#			# LMFAO
#			pos = currentcam.global_transform.basis.get_euler()
#			angle = Vector2(pos.x,pos.y)
#			pos = currentcam.global_transform.origin
#		# maybe do this differently but maybe this is good cuz of environments and stuff
#		if Network.map:
#			Network.map.add_child(FreeCam.new().create(pos,angle))

func timescale_cmd(amnt: float) -> void:
	Engine.set_time_scale(amnt)

func reset_timescale_cmd() -> void:
	timescale_cmd(1)

func printmem_cmd() -> void:
	write("%s %s"%[OS.get_static_memory_usage(),OS.get_static_memory_peak_usage()])

func get_func_length_cmd(nodepath: String, function: String) -> void:
	@warning_ignore("static_called_on_instance")
	write(str(Quack.get_func_length(Callable(Quack.root.get_node(NodePath(nodepath)),function))))

func inst2dict2array(node: Node) -> Array:
	return inst_to_dict(node).values()

func kill_cmd() -> void:
	doesntwork()
#	if is_server_and_self_exists():
#		get_self().kill()

func change_health_by_cmd(amount: float) -> void:
	doesntwork()
	return
#	if is_server_and_self_exists():
#		get_self().modify_health(amount)

func set_health_cmd(health: float) -> void:
	doesntwork()
#	if is_server_and_self_exists():
#		get_self().set_health(health)

func respawn_cmd() -> void:
	doesntwork()
#	if Network.is_server():
#		Network.on_manual_respawn_requested(Network.selfid)

func force_respawn_cmd() -> void:
	respawn_cmd()

func render_scale_cmd(scale: float) -> void:
	WindowUtils.set_render_scale(scale)

func set_volume_cmd(scale: float) -> void:
	Audio.change_master_volume(scale)

func control_cmd(node_path: String) -> void:
	doesntwork()
#	var scene: Node = Quack.tree.current_scene
#	var node: Node = scene.get_node_or_null(node_path)
#	if node:
#		if node is PlayerCharacter:
#			node.take_local_control()
#			if scene.name == "Dev Level":
#				scene.player = node

func upnp_test_cmd() -> void:
	var upnp_thread := Thread.new()
	upnp_thread.start(upnp_test)
	write("Starting UPnP test...")

var upnp_test: Callable = func upnp_test() -> void:
	var upnp := UPNP.new()
	upnp.discover()
	var devices: Array[UPNPDevice]
	var gateway: UPNPDevice = upnp.get_gateway()
	write("UPnP device detected.") if upnp.get_device_count() > 0 else write("No UPnP device detected.")

func show_commands_cmd() -> void:
	write("All commands and aliases:")
	@warning_ignore("shadowed_variable")
	for command in commands.keys():
		write("   "+command)

func doesntwork() -> void:
	writerr("doesnt work lmao")

func pingtest_all_cmd() -> void:
	doesntwork()
#	if Network.is_server():
#		Console.write("Pinging all peers...")
#		rpc("recieve_pingtest")
#		ping_start_time = Time.get_ticks_usec()

func pingtest_cmd(peer: int) -> void:
	doesntwork()
#	if peer == Network.SERVER or Network.is_server():
#		Console.write("Pinging peer %s"%[peer])
#		rpc_id(peer,"recieve_pingtest")
#		ping_start_time = Time.get_ticks_usec()

var ping_start_time: int
@rpc("any_peer","unreliable") func recieve_pingtest() -> void:
	rpc_id(multiplayer.get_remote_sender_id(),"update_ping_time")

@rpc("any_peer","unreliable") func update_ping_time() -> void:
	var time_recieved_at: int = Time.get_ticks_usec()
	var ping: int = time_recieved_at - ping_start_time
	Console.write("Peer %s pinged back after %s usec (%s seconds)."%[multiplayer.get_remote_sender_id(),ping,float(ping)*0.000001])

func change_physics_simulation_rate_cmd(rate: int) -> void:
	Quack.set_physics_simulation_rate(rate)
