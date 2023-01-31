extends Node

## Emitted every time the player moves their mouse.
signal mouse_moved(relative)
## Emitted every time the player presses the pause button.
signal pause_pressed

## Returns whether or not the mouse_moved signal calls any functions.
static func is_mouse_connected_to_object() -> bool:
	return false if mouse_moved.get_connections().is_empty() else true

## Shows the cursor. lmao.
static func show_cursor() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

## Makes the cursor invisible, confines it to the game window, and still
## sends InputEventMouseMotions.
static func capture_cursor() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

## Returns if the cursor is captured or not. lmao.
static func is_mouse_captured() -> bool:
	return Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED

## Calls [method showhide_cursor] if the ui_cancel button was just pressed.
static func showhide_cursor_on_ui_cancel() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		showhide_cursor()

## Captures the cursor if it's visible, or shows it if it isn't. lmao.
static func showhide_cursor() -> void:
	capture_cursor() if is_mouse_visible() else show_cursor()

## Returns true if the mouse is visible, or false if it isn't. lmao.
static func is_mouse_visible() -> bool:
#	return true if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE else false
	match Input.get_mouse_mode():
		Input.MOUSE_MODE_VISIBLE:
			return true
		Input.MOUSE_MODE_CONFINED:
			return true
		_:
			return false

## The player's mouse sensitivity
@onready var sens: float = getsens() * 0.01

## Constant String that corresponds to the sensitivity setting
const SENS_SETTING: StringName = "quack/controls/mouse/sensitivity"

## Gets the sensitivity setting with a fallback of 10
static func getsens() -> float:
	return ProjectSettings.get_setting(SENS_SETTING,10)

## Multiplies the player's sensitivity setting by 0.01 to get their actual sensitivity
## that the game will use in its calculations
func update_sens() -> void:
	sens = getsens() * 0.01

## Changes the player's sensitivity setting to a new value, and updates the
## [member sens] variable accordingly
func change_sens(newsens: float) -> void:
	ProjectSettings.set_setting("Sensitivty", newsens)
	sens = newsens * 0.01

func _input(event):
	if event is InputEventMouseMotion:
		emit_signal("mouse_moved", event.relative * sens)
	elif Input.is_action_just_pressed("ui_cancel"):
		emit_signal("pause_pressed")

# this is so dumb lmfao
## Equivalent to accessing [member InputEventMouseMotion.relative] from [code]event[/code]. 
static func mouse_to_aim(event: InputEventMouseMotion) -> Vector2:
	return event.relative

## Strings of every game-related button action in the game
const action_events: PackedStringArray = []

## Enumeration of every game-related button action in the game (this excludes
## UI actions and analog actions)
enum kb_actions {}
## Corresponding bitfields of every game-related button action in the game
var action_bitfields: PackedInt64Array = []
## How many game-related button actions exist in the game. Same as calling
## [member action_bitfields].[method PackedInt64Array.size].
var action_count: int

## 0
enum {UP}

## Returns the corresponding bitflag to the given action, either on or off,
## depending if the action is being pressed or not.
static func action_pressed_as_bitflag(action: String, this_int: int) -> int:
	return this_int if Input.is_action_pressed(action) else UP

## Returns the corresponding bitflag to the given action, either on or off,
## depending if the action was just pressed or not.
static func action_just_pressed_as_bitflag(action: String, this_int: int) -> int:
	return this_int if Input.is_action_just_pressed(action) else UP

## Returns if the given bitflag is being pressed in the current [code]inputs[/code]
## and was NOT being pressed in the [code]previous_inputs[/code].
static func is_button_just_pressed(input_bitflag: int, inputs: int, previous_inputs: int) -> bool:
	return ByteUtils.bit_has_flag(inputs, input_bitflag) and !ByteUtils.bit_has_flag(previous_inputs,input_bitflag)

## Returns if the given bitflag is both being pressed in the current [code]inputs[/code]
## and was being pressed in the [code]previous_inputs[/code].
static func is_button_being_held(input_bitflag: int, inputs: int, previous_inputs: int) -> bool:
	return ByteUtils.bit_has_flag(inputs, input_bitflag) and ByteUtils.bit_has_flag(previous_inputs, input_bitflag)

## Returns if the given bitflag is NOT being pressed in the current [code]inputs[/code]
## and was being pressed in the [code]previous_inputs[/code].
static func is_button_just_released(input_bitflag: int, inputs: int, previous_inputs: int) -> bool:
	return !ByteUtils.bit_has_flag(inputs, input_bitflag) and ByteUtils.bit_has_flag(previous_inputs, input_bitflag)

## Returns an [int] that represents all the actions the player is currently
## inputting on their keyboard.
func get_keyboard_updowns() -> int:
	var updowns: int
	for action in action_count:
		updowns |= action_pressed_as_bitflag(action_events[action], action_bitfields[action])
	return updowns

## Returns a [Vector2] with a length [code]1.0[/code] representing the movement
## direction the player is inputting.
static func get_movement_from_keyboard() -> Vector2:
	return Input.get_vector("analog_left","analog_right","analog_forward","analog_back")

func _init() -> void:
	register_all_actions()

# INPUT REGISTRATION STUFF
# ////////////////////////////////////
## Returns if a string begins with "ui_"
static func is_ui_action(action: String) -> bool:
	return action.begins_with("ui_")

## Returns if a string begins with "analog_"
static func is_analog_action(action: String) -> bool:
	return action.begins_with("analog_")

## Called once by [Quack] when the game starts up. Registers all game-related
## button actions in [member action_events] and [member action_bitfields]. 
func register_all_actions() -> void:
	for action in InputMap.get_actions():
		if !is_ui_action(action) and !is_analog_action(action):
			action_events.append(action)
			action_bitfields.append(1<<action_count)
			action_count += 1

# PLAYER INPUT CLASS
# ////////////////////////////////////
class PlayerInputs:
	var inputs: int
	var previous_inputs: int
	var input_dir: Vector2
	var aim_angle: Vector2
	
	func set_inputs(input_dir: Vector2, inputs: int) -> void:
		self.input_dir = input_dir
		self.inputs = inputs
	
	func set_inputs_to_local_input() -> void:
		set_inputs(Inputs.get_movement_from_keyboard(),Inputs.get_keyboard_updowns())
	
	func update_previous_inputs() -> void:
		previous_inputs = inputs
	
	func aim_in_direction(direction: Vector2) -> void:
		aim_angle.x -= deg_to_rad(direction.x)
		aim_angle.y = clamp_vertical_aim(aim_angle.y - deg_to_rad(direction.y))
	
	const MIN_VERTICAL_ANGLE: float = -deg_to_rad(89.999)
	const MAX_VERTICAL_ANGLE: float = deg_to_rad(89.999)
	static func clamp_vertical_aim(value: float) -> float:
		return clamp(value, MIN_VERTICAL_ANGLE, MAX_VERTICAL_ANGLE)
