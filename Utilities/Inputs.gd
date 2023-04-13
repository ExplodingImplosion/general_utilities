extends Node

signal mouse_moved(relative)
signal pause_pressed

func _init() -> void:
	register_all_actions()

func is_mouse_connected_to_object() -> bool:
	return false if mouse_moved.get_connections().is_empty() else true

static func show_cursor() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

static func capture_cursor() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

static func is_mouse_captured() -> bool:
	return Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED

static func showhide_cursor_on_ui_cancel() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		showhide_cursor()

static func showhide_cursor() -> void:
	capture_cursor() if is_mouse_visible() else show_cursor()

static func is_mouse_visible() -> bool:
#	return true if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE else false
	match Input.get_mouse_mode():
		Input.MOUSE_MODE_VISIBLE:
			return true
		Input.MOUSE_MODE_CONFINED:
			return true
		_:
			return false

@warning_ignore("static_called_on_instance")
@onready var sens: float = getsens() * 0.01

const SENS_SETTING: StringName = "quack/controls/mouse/sensitivity"

static func getsens() -> float:
	return ProjectSettings.get_setting(SENS_SETTING)

func update_sens() -> void:
	@warning_ignore("static_called_on_instance")
	sens = getsens() * 0.01

func change_sens(newsens: float) -> void:
	ProjectSettings.set_setting(SENS_SETTING, newsens)
	sens = newsens * 0.01

func _input(event):
	if event is InputEventMouseMotion:
		emit_signal("mouse_moved", event.relative * sens)
	elif Input.is_action_just_pressed("ui_cancel"):
		emit_signal("pause_pressed")

# this is so dumb lmfao
static func mouse_to_aim(event: InputEventMouseMotion) -> Vector2:
	return event.relative

var action_events: PackedStringArray = []
var just_pressed_action_events: PackedStringArray = []

enum kb_actions {THROW}
var action_bitfields: PackedInt64Array = []
var just_pressed_action_bitfields: PackedInt64Array = []
## How many game-related button actions exist in the game. Same as calling
## [member action_bitfields].[method PackedInt64Array.size].
var action_count: int
## How many game-related button actions that are only register on the frame they
## were pressed exist in the game. Same as calling [member just_pressed_action_bitfields].[method PackedInt64Array.size].
var just_pressed_action_count: int

enum action_bitfields_enum {
}

enum {UP}

func action_pressed_as_bitflag(action: String, this_int: int) -> int:
	return this_int if Input.is_action_pressed(action) else UP

func action_just_pressed_as_bitflag(action: String, this_int: int) -> int:
	return this_int if Input.is_action_just_pressed(action) else UP

func get_keyboard_updowns() -> int:
	var updowns: int
	for action in action_count:
		@warning_ignore("unassigned_variable_op_assign")
		updowns |= action_pressed_as_bitflag(action_events[action], action_bitfields[action])
	for action in just_pressed_action_count:
		updowns |= action_just_pressed_as_bitflag(just_pressed_action_events[action], just_pressed_action_bitfields[action])
	return updowns

# if i catch anyone using these 2 funcs im going to personally shoot them
static func get_bool_from_action_pressed(action: String) -> bool:
	return Input.is_action_pressed(action)

static func get_bool_from_action_just_pressed(action: String) -> bool:
	return Input.is_action_just_pressed(action)

static func get_movement_from_keyboard() -> Vector2:
	return Input.get_vector("analog_left","analog_right","analog_forward","analog_back")

# INPUT REGISTRATION STUFF
# ////////////////////////////////////
## Returns if a string begins with "ui_"
static func is_ui_action(action: String) -> bool:
	return action.begins_with("ui_")

## Returns if a string begins with "analog_"
static func is_analog_action(action: String) -> bool:
	return action.begins_with("analog_")

static func is_just_pressed_action(action: String) -> bool:
	return action.begins_with("just_pressed_")

## Called once by [Quack] when the game starts up. Registers all game-related
## button actions in [member action_events] and [member action_bitfields]. 
func register_all_actions() -> void:
	for action in InputMap.get_actions():
		if !is_ui_action(action) and !is_analog_action(action):
			if is_just_pressed_action(action):
				just_pressed_action_events.append(action)
				just_pressed_action_bitfields.append(1<<action_count)
				just_pressed_action_count += 1
			else:
				action_events.append(action)
				action_bitfields.append(1<<action_count)
				action_count += 1

# lmk if this function has ever been used ever in the history of ever period
enum {UPDOWNS, ANGLE}
# PLAYER INPUT CLASS
# ////////////////////////////////////
class PlayerInputs:
	var inputs: int
	var previous_inputs: int
	var input_dir: Vector2
	var aim_angle: Vector2
	var events: PackedByteArray
	var serialized: PackedByteArray
	
	@warning_ignore("shadowed_variable")
	func _init(inputs: int, input_dir: Vector2) -> void:
		set_inputs(inputs,input_dir)
	
	static func get_local_playerinputs() -> PlayerInputs:
		return PlayerInputs.new(Inputs.get_keyboard_updowns(),Inputs.get_movement_from_keyboard())
	
	@warning_ignore("shadowed_variable")
	func set_inputs(inputs: int, input_dir: Vector2) -> void:
		self.inputs = inputs
		self.input_dir = input_dir
	
	func set_inputs_to_local_input() -> void:
		set_inputs(Inputs.get_keyboard_updowns(),Inputs.get_movement_from_keyboard())
	
	func update_previous_inputs() -> void:
		previous_inputs = inputs
	
	func aim_in_direction(direction: Vector2) -> void:
#		aim_angle.x -= deg_to_rad(direction.x)
		# maybe fmod or fposmod instead of wrapf
		aim_angle.x = wrapf(aim_angle.x - deg_to_rad(direction.x),0,TAU)
		aim_angle.y = clamp_vertical_aim(aim_angle.y - deg_to_rad(direction.y))
	
	const MIN_VERTICAL_ANGLE: float = -deg_to_rad(89.999)
	const MAX_VERTICAL_ANGLE: float = deg_to_rad(89.999)
	static func clamp_vertical_aim(value: float) -> float:
		return clamp(value, MIN_VERTICAL_ANGLE, MAX_VERTICAL_ANGLE)
	
	func serialize() -> PackedByteArray:
		return PackedByteArray()#Network.ClientState.serialize_client_state(inputs,input_dir,aim_angle,events)
	
	func get_serialized() -> PackedByteArray:
		if serialized.is_empty():
			serialized = serialize()
		return serialized
