extends Node

signal mouse_moved(relative)
signal pause_pressed

## Calls [method register_all_actions] when the game starts.
func _init() -> void:
	register_all_actions()

## Returns if [signal mouse_moved] is connected to any callables.
func is_mouse_connected_to_object() -> bool:
	return !mouse_moved.get_connections().is_empty()

## Changes cursor mode to [member Input.MOUSE_MODE_VISIBLE].
static func show_cursor() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

## Changes cursor mode to [member Input.MOUSE_MODE_CAPTURED].
static func capture_cursor() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

## Returns true only if [member Input.mouse_mode] is [member Input.MOUSE_MODE_CAPTURED].
static func is_mouse_captured() -> bool:
	return Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED

## If ui_cancel has been pressed, calls [method showhide_cursor].
static func showhide_cursor_on_ui_cancel() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		showhide_cursor()

## If [method is_mouse_visible] is [code]true[/code], calls [method show_cursor].
## Otherwise, calls [method capture_cursor]. This function name is slightly
## misleading, because it captures the cursor instead of simply hiding it.
static func showhide_cursor() -> void:
	capture_cursor() if is_mouse_visible() else show_cursor()

## Returns if the current mouse mode is visible, regardless of whether the cursor
## is confined to the current window.
static func is_mouse_visible() -> bool:
	match Input.get_mouse_mode():
		Input.MOUSE_MODE_VISIBLE:
			return true
		Input.MOUSE_MODE_CONFINED:
			return true
		_:
			return false

## Emits [signal mouse_moved] with [arg event][code].relative[/code] if [arg event]
## is [InputEventMouseMotion], and emits [signal pause_pressed] if the pause action
## was just pressed.
func _input(event):
	if event is InputEventMouseMotion:
		emit_signal("mouse_moved", event.relative)
	elif Input.is_action_just_pressed("ui_cancel"):
		emit_signal("pause_pressed")

## Action events that should occur whenever the player is inputting them.
var action_events: PackedStringArray = []
## Action events that should only occur on the same frame the player inputted them.
var just_pressed_action_events: PackedStringArray = []

## Bitfields for each action in [member action_events].
var action_bitfields: PackedInt64Array = []
## Bitfields for each action in [member just_pressed_action_events].
var just_pressed_action_bitfields: PackedInt64Array = []
## How many game-related button actions exist in the game. Same as calling
## [member action_bitfields].[method PackedInt64Array.size].
var action_count: int
## How many game-related button actions that are only register on the frame they
## were pressed exist in the game. Same as calling [member just_pressed_action_bitfields].[method PackedInt64Array.size].
var just_pressed_action_count: int

## DOWN is never used, but this just helps with code readability for functions
## involving bitflags.
enum {UP,DOWN}

## Returns an int with the corresponding [arg this_int] bitfield toggled if
## [arg action] is being pressed.
func action_pressed_as_bitflag(action: String, this_int: int) -> int:
	return this_int if Input.is_action_pressed(action) else UP

## Returns an int with the corresponding [arg this_int] bitfield toggled if
## [arg action] is just pressed.
func action_just_pressed_as_bitflag(action: String, this_int: int) -> int:
	return this_int if Input.is_action_just_pressed(action) else UP

## Returns every current button in a bitfield.
func get_updowns() -> int:
	var updowns: int
	for action in action_count:
		@warning_ignore("unassigned_variable_op_assign")
		updowns |= action_pressed_as_bitflag(action_events[action], action_bitfields[action])
	for action in just_pressed_action_count:
		updowns |= action_just_pressed_as_bitflag(just_pressed_action_events[action], just_pressed_action_bitfields[action])
	return updowns

## Returns a Vector2 with whatever current 
static func get_movement_from_device() -> Vector2:
	return Input.get_vector("analog_left","analog_right","analog_forward","analog_back")

# INPUT REGISTRATION STUFF
# ////////////////////////////////////
## Returns if a string begins with "ui_"
static func is_ui_action(action: String) -> bool:
	return action.begins_with("ui_")

## Returns if a string begins with "analog_"
static func is_analog_action(action: String) -> bool:
	return action.begins_with("analog_")

## Returns if a string begins with "just_pressed_"
static func is_just_pressed_action(action: String) -> bool:
	return action.begins_with("just_pressed_")

## Called once when the game starts up. Registers all game-related
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
