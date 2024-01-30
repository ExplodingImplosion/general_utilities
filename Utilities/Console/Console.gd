extends Window

const console_commands_filepath := "Console Commands.gd"
const console_comamnds_script: GDScript = preload(console_commands_filepath)
const CONSOLE_TRANSPARENCY_SETTING_PATH = "quack/console/transparency"
## Delimiter used to check for command aliases in [method parse_commands_script]
const alias_delimiter = "_aliases"
const err_color: Color = Color.RED
# so stupid that this needs to be a var instead of a const
var err_bbcode: String = err_color.to_html(false)

## Input action string to check for to toggle popping up the console.
const toggle := "console"
## Input action string to check for to toggle moving up through console
## history.
const up := "ui_up"
## Input action string to check for to toggle moving down through console history.
const down := "ui_down"
## Direction through [member history] array to go "up" (previous inputs) through history.
const UP := -1
## Direction through [member history] array to go "down" (more recent inputs) through history.
const DOWN := 1
## Minimum size of console window.
const MINSIZE := Vector2i(200,100)
## Default size, on startup, of console window.
const DEFAULTSIZE := Vector2i(600,488)
## Default position, on startup, of console window, relative to the top-right of
## the game's main window.
const DEFAULTPOS := Vector2i(40,40)
## Maximum number of commands that history can contain
const HISTORY_MAX_SIZE = 999
## Maximum offset/index in [member history]. Always equal to
## [member HISTORY_MAX_SIZE][code] - 1[/code].
const HISTORY_MAX_OFFSET = HISTORY_MAX_SIZE - 1
var readout := RichTextLabel.new()
var command_line := LineEdit.new()
var container := VBoxContainer.new()

## Number of commands that have been inputted. Used to check whether to overwrite
## old commands.
var hist_offset := 0
## Current position in history ([code]0[/code] = no commands have been inputted).
var current := 0
## Commands that have been previously inputted.
@warning_ignore("static_called_on_instance")
var history: PackedStringArray = setup_history()
## Whether or not a command has been inputted. Used in [method can_history_move].
var hist_empty: bool

var command_string_map: Dictionary
var commands: Array[CommandInfo]

static func setup_history() -> PackedStringArray:
	var hist: PackedStringArray = []
	hist.resize(HISTORY_MAX_SIZE)
	return hist

func _init():
	setup_transparency()
	parse_commands()
	
	setup_window()
	setup_children()
	
	hide()
	write_cmdline_args()
	write_cmdline_user_args()

## Literally just 3 spaces lol
const indent_string = "   " # 3 spaces

func write_cmdline_args() -> void:
	write("Command line args:")
	for arg in OS.get_cmdline_args():
		write(indent_string+arg)
	writeln()

func write_cmdline_user_args() -> void:
	write("User command line args:")
	for arg in OS.get_cmdline_user_args():
		write(indent_string+arg)
	writeln()

func set_background(box: StyleBox) -> void:
	set("theme_override_styles/embedded_border",box)

func set_opacity(opacity: float) -> void:
	transparent_bg = true
	var box := StyleBoxFlat.new()
	setup_stylebox(opacity,box)
	set_background(box)

func setup_stylebox(opacity: float, box: StyleBoxFlat) -> void:
	var color = RenderingServer.get_default_clear_color()
	color.a = opacity
	box.bg_color = color
	#box.border_color = color
	box.corner_detail = 5
	box.set_corner_radius_all(3)
	box.expand_margin_left = 8
	box.expand_margin_right = 8
	box.expand_margin_top = 32
	box.expand_margin_bottom = 6
	
	box.content_margin_left = 10
	box.content_margin_top = 28
	box.content_margin_right = 10
	box.content_margin_bottom = 8

func set_transparent() -> void:
	transparent_bg = true
	set_background(StyleBoxEmpty.new())

func setup_transparency() -> void:
	var transparency: float = ProjectSettings.get_setting(CONSOLE_TRANSPARENCY_SETTING_PATH,0.0)
	if transparency == 0.0:
		return
		#set_background(StyleBoxFlat.new())
	elif transparency == 1.0:
		set_transparent()
	else:
		set_opacity(1.0-transparency)

func setup_window() -> void:
	set_title("Console")
	set_min_size(MINSIZE)
	set_position(DEFAULTPOS)
	setup_window_size.call_deferred()

func setup_children() -> void:
	setup_container()
	setup_label()
	setup_line()

func setup_window_size() -> void:
	Quack.setup_subwindow_size(self,DEFAULTSIZE)

func setup_container() -> void:
	add_child(container)
	@warning_ignore("static_called_on_instance")
	setup_margins(container)

@warning_ignore("shadowed_variable")
static func setup_margins(container: VBoxContainer) -> void:
	@warning_ignore("shadowed_variable")
	container.anchor_bottom = 1
	container.anchor_left = 0
	container.anchor_top = 0
	container.anchor_right = 1

func setup_label() -> void:
	@warning_ignore("static_called_on_instance")
	setup_label_properties(readout)
	container.add_child(readout)
	readout.set_focus_mode(Control.FOCUS_NONE)

static func setup_label_properties(this_label: RichTextLabel) -> void:
	this_label.set_use_bbcode(true)
	this_label.set_v_size_flags(Control.SIZE_EXPAND_FILL)
	this_label.set_scroll_follow(true)
	this_label.set_selection_enabled(true)

func setup_line() -> void:
	@warning_ignore("static_called_on_instance")
	setup_line_properties(command_line)
	container.add_child(command_line)

static func setup_line_properties(this_line: LineEdit) -> void:
	this_line.text_submitted.connect(execute_command)
	this_line.set_clear_button_enabled(true)

func toggle_activation() -> void:
	disable() if is_visible() else activate()

func activate() -> void:
	popup()
	command_line.grab_focus()
	@warning_ignore("static_called_on_instance")
	Inputs.show_cursor()
#	if position.x > Quack.root.size.x or position.y > Quack.root.size.y:
	setup_window_size()
	# functionally the same as:
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func disable() -> void:
	hide()
	command_line.clear()
	# this might get depreciated if the console/menu disconnects the mouse
	# from getting captured
	if Inputs.is_mouse_connected_to_object():
		@warning_ignore("static_called_on_instance")
		Inputs.capture_cursor()

func move_in_history(amount: int) -> void:
	current = int(clamp(current + amount, 0, history.size() - 1))
	command_line.set_text(history[current])
	command_line.caret_column = command_line.get_text().length()

func is_command_line_focused() -> bool:
	return gui_get_focus_owner() == command_line

func can_history_move() -> bool:
	return is_command_line_focused() and !hist_empty

func _process(_delta: float) -> void:
	parse_inputs()

func parse_inputs() -> void:
	if Input.is_action_just_pressed(toggle) or is_visible() and Input.is_action_just_pressed("ui_cancel"):
		toggle_activation()
	if Input.is_action_just_pressed(up):
		if can_history_move():
			move_in_history(UP)
	if Input.is_action_just_pressed(down):
		if can_history_move():
			move_in_history(DOWN)
	if !is_visible():
		parse_shortcuts()

var shortcuts: Array[StringName]
func parse_shortcuts() -> void:
	for shortcut in shortcuts:
		if Input.is_action_just_pressed(shortcut):
			execute_command(shortcut)

func add_shortcut(shortcut: StringName) -> void:
	InputMap.add_action(shortcut)
	shortcuts.append(shortcut)

func parse_commands() -> void:
	@warning_ignore("static_called_on_instance")
	parse_commands_script(console_comamnds_script, command_string_map, commands)
	# other scripts can go here

func reload_commands() -> void:
	command_string_map.clear()
	parse_commands()

## Writes a new line to the console and prints it in the editor console/logs it.
func writeln() -> void:
	readout.append_text("\n")
	print("\n")

func add_msg(s: String) -> void:
	readout.append_text(s + "\n")

## Shorthand to write a string and a variant.
func writereadout(s: String, v: Variant) -> void:
	write(s + str(v))

## Writes str([param v]) to the console and prints it in the editor/logs it.
func writevar(v: Variant) -> void:
	write(str(v))

## Writes [param s] to the console and prints it in the editor console/logs it,
## ONLY IF [method TimeUtils.is_physics_time_interval] [param i] is true.
func write_on_interval(s: String, i: float) -> void:
	if TimeUtils.is_physics_time_interval(i):
		write(s)

## Writes [param s] to the console and prints it in the editor console/logs it.
func write(s: String) -> void:
	add_msg(s)
	print(s)

## Writes [param s] to the console and prints it in the editor console/logs it as
## an error.
func writerr(s: String) -> void:
	add_err_msg(s)
	printerr(s)

## Writes [param s] to the console and pushes an error in the editor
func push_err(s: String) -> void:
	add_err_msg(s)
	push_error(s)

func add_err_msg(s: String) -> void:
	@warning_ignore("static_called_on_instance")
	add_msg(BBCode.add_bbcode(s,err_bbcode))

## Executes the inputted command and its arguments, given as [param input]. The
## command is parsed as the first string delimited by a space, and 
func execute_command(input: String):
	if input == "":
		return
	
	command_line.clear()
	write(str("> ", input))
	
	var args: Array[Variant] = Array(input.split(" "))
	var command_string: String = args.pop_front()
	var command_info: CommandInfo = command_string_map.get(command_string)
	
	@warning_ignore("static_called_on_instance")
	convert_args(args)
	
	if command_info != null:
		var err: int = args.resize(command_info.num_args)
		assert(err == OK, "Ayo wtf")
		command_info.callable.callv(args)
	else:
		command_not_found(command_string)
	
	increment_history(input)

func increment_history(input: String) -> void:
	history[hist_offset] = input
	hist_offset = wrapi(hist_offset+1,0,HISTORY_MAX_OFFSET)
	current = hist_offset

static func convert_args(args: Array[Variant]) -> void:
	for i in args.size():
		args[i] = convert_arg(args[i] as String)

static func convert_arg(arg: String) -> Variant:
	var lowercase_arg: String = arg.to_lower()
	if lowercase_arg == "false":
		return false
	elif lowercase_arg == "true":
		return true
	elif arg.is_valid_float():
		return arg.to_float()
	elif arg.is_valid_int():
		return arg.to_int()
	else:
		return arg

@warning_ignore("shadowed_variable")
func command_not_found(command_string: String) -> void:
	write(str("Command '", command_string, "' not found"))

var ping_start_time: int
@rpc("any_peer","unreliable") func receive_pingtest() -> void:
	update_ping_time.rpc_id(multiplayer.get_remote_sender_id())

@rpc("any_peer","unreliable") func update_ping_time() -> void:
	var time_received_at: int = Time.get_ticks_usec()
	var ping: int = time_received_at - ping_start_time
	Console.write("Peer %s pinged back after %s usec (%s seconds)."%[multiplayer.get_remote_sender_id(),ping,float(ping)*0.000001])

static func get_method_names(script_methods: Array[Dictionary]) -> PackedStringArray:
	var method_names: PackedStringArray = []
	var script_methods_size: int = script_methods.size()
	
	method_names.resize(script_methods_size)
	
	for i in script_methods_size:
		method_names[i] = script_methods[i].name
	
	return method_names

# Do not look at the badness beyond this point, please

class CommandInfo:
	var callable: Callable
	var args: PackedByteArray
	const COMMAND_NAME_IDX = 0
	var aliases: PackedStringArray
	var num_args: int
	var args_info: Array[PackedStringArray]
	enum {ARG_NAME, ARG_TYPE_NAME}
	
	func _init(cmd: Callable, command_name: String) -> void:
		callable = cmd
		aliases.append(command_name)
	
	func get_command_name() -> String:
		return aliases[COMMAND_NAME_IDX]
	
	# the arg_types naming convention is hella stupid
	func add_args(arg_types: Array) -> void:
		num_args = arg_types.size()
		args.resize(num_args)
		var arg_info: Dictionary
		for i in num_args:
			arg_info = arg_types[i]
			args[i] = arg_types[i].type
			args_info.append(CommandInfo.get_arg_info(arg_info))
	
	static func get_arg_info(arg_info: Dictionary) -> PackedStringArray:
		var info: PackedStringArray = []
		info.resize(2)
		info[ARG_NAME] = arg_info.name
		#var gaming1 = type_string(arg_info.type)
		#var gaming2 = arg_info.class_name
		#var gaming3 = arg_info.class_name.is_empty()
		#breakpoint
		info[ARG_TYPE_NAME] = type_string(arg_info.type) if arg_info.class_name.is_empty() else arg_info.class_name
		return info
	
	func add_shortened_aliases(string_map: Dictionary) -> void:
		var alias: String
		var shortened: String
		for i in aliases.size():
			alias = aliases[i]
			shortened = alias.replace("_","")
			if alias != shortened and !aliases.has(shortened):
				aliases.append(shortened)
				assert(!string_map.has(shortened),"Command String Map already has key %s."%[shortened])
				string_map[shortened] = self
	
	func get_aliases() -> PackedStringArray:
		return aliases.slice(1)
	
	func has_args() -> bool:
		return num_args > 0

static func get_command_info(script: GDScript, script_method_name: String) -> CommandInfo:
	assert(script_method_name.ends_with(cmd_prefix),"Can't strip _cmd from script method %s if it doesn't end with _cmd."%script_method_name)
	return CommandInfo.new(Callable(script,script_method_name),script_method_name.trim_suffix(cmd_prefix))

const cmd_prefix = "_cmd"
const alias_prefix = "_aliases"
static func parse_commands_script(script: GDScript, string_map: Dictionary, command_list: Array[CommandInfo]) -> void:
	var script_methods: Array[Dictionary] = script.get_script_method_list()
	var script_consts: Dictionary = script.get_script_constant_map()
	#var method_names: PackedStringArray = get_method_names(script_methods)

	for method in script_methods:
		try_add_command(script,method,string_map,command_list)
	for constant_name in script_consts.keys():
		if constant_name.ends_with(alias_prefix):
			var constant_value: Variant = script_consts[constant_name]
			if constant_value is PackedStringArray:
				try_add_command_aliases(constant_name,constant_value,string_map)
	
	for info in string_map.values():
		(info as CommandInfo).add_shortened_aliases(string_map)

static func try_add_command(script: GDScript, method: Dictionary, string_map: Dictionary, command_list: Array[CommandInfo]) -> void:
	if !(method.name as String).ends_with(cmd_prefix):
		return
	
	var command_info: CommandInfo = get_command_info(script,method.name)
	assert(!string_map.has(command_info.get_command_name()),"Tried to add a redundant command. string_map already has command %.s"%command_info.get_command_name())
	string_map[command_info.get_command_name()] = command_info
	command_list.append(command_info)
	command_info.add_args(method.args)

static func try_add_command_aliases(aliases_name: String, aliases: PackedStringArray, string_map: Dictionary) -> void:
	var command_name: String = aliases_name.trim_suffix(alias_prefix)
	if !string_map.has(command_name):
		return
	
	var command_info: CommandInfo = string_map[command_name]
	command_info.aliases.append_array(aliases)
	for alias in aliases:
		string_map[alias] = command_info
