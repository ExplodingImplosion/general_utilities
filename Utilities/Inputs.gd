extends Node

signal mouse_moved(relative)
signal pause_pressed

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
		mouse_moved.emit(event.relative*sens)
	elif Input.is_action_just_pressed("ui_cancel"):
		pause_pressed.emit()

# this is so dumb lmfao
static func mouse_to_aim(event: InputEventMouseMotion) -> Vector2:
	return event.relative

const action_events: Array[StringName] = ["crouch", "run", "attack", "alt_attack",
					"item_1", "item_2", "item_3", "last_item", "jump", "drop",
					"interact"]

enum kb_actions {CROUCH, RUN, ATTACK, ALT_ATTACK, ITEM1, ITEM2, ITEM3,
				LASTITEM, JUMP, DROP, INTERACT}
const action_bitfields: PackedInt64Array = [1<<kb_actions.CROUCH,
1<<kb_actions.RUN, 1<<kb_actions.ATTACK, 1<<kb_actions.ALT_ATTACK,
1<<kb_actions.ITEM1, 1<<kb_actions.ITEM2, 1<<kb_actions.ITEM3,
1<<kb_actions.LASTITEM, 1<<kb_actions.JUMP, 1<<kb_actions.DROP,
1<<kb_actions.INTERACT]

enum action_bitfields_enum {
	CROUCH = 1<<kb_actions.CROUCH,
	WALK = 1<<kb_actions.RUN,
	SHOOT = 1<<kb_actions.ATTACK,
	ADS = 1<<kb_actions.ALT_ATTACK,
	ITEM1 = 1<<kb_actions.ITEM1,
	ITEM2 = 1<<kb_actions.ITEM2,
	ITEM3 = 1<<kb_actions.ITEM3,
	LASTITEM = 1<<kb_actions.LASTITEM,
	JUMP = 1<<kb_actions.JUMP,
	DROP = 1<<kb_actions.DROP,
	INTERACT = 1<<kb_actions.INTERACT
}

enum {UP}

# 5
const pressed: int = kb_actions.ITEM1
# 13
const just_pressed: int = kb_actions.INTERACT
# should be 9
const diff: int = just_pressed - pressed + 1

static func action_pressed_as_bitflag(action: String, this_int: int) -> int:
	return this_int if Input.is_action_pressed(action) else UP

static func action_just_pressed_as_bitflag(action: String, this_int: int) -> int:
	return this_int if Input.is_action_just_pressed(action) else UP

static func get_keyboard_updowns() -> int:
	var updowns: int = 0
	for action in pressed:
		updowns |= action_pressed_as_bitflag(action_events[action], action_bitfields[action])
	var thisaction: int = 0
	for action in diff:
		thisaction = action + pressed
		updowns |= action_just_pressed_as_bitflag(action_events[thisaction], action_bitfields[thisaction])
	return updowns

# if i catch anyone using these 2 funcs im going to personally shoot them
static func get_bool_from_action_pressed(action: String) -> bool:
	return Input.is_action_pressed(action)

static func get_bool_from_action_just_pressed(action: String) -> bool:
	return Input.is_action_just_pressed(action)

static func get_movement_from_keyboard() -> Vector2:
	return Input.get_vector(&"left",&"right",&"forward",&"back")

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
		@warning_ignore("static_called_on_instance")
		return PlayerInputs.new(Inputs.get_keyboard_updowns(),Inputs.get_movement_from_keyboard())
	
	@warning_ignore("shadowed_variable")
	func set_inputs(inputs: int, input_dir: Vector2) -> void:
		self.inputs = inputs
		self.input_dir = input_dir
	
	func set_inputs_to_local_input() -> void:
		@warning_ignore("static_called_on_instance")
		set_inputs(Inputs.get_keyboard_updowns(),Inputs.get_movement_from_keyboard())
	
	func update_previous_inputs() -> void:
		previous_inputs = inputs
	
	func get_input_dir_strength() -> float:
		return input_dir.length()
	
	func aim_in_direction(direction: Vector2) -> void:
#		aim_angle.x -= deg_to_rad(direction.x)
		# maybe fmod or fposmod instead of wrapf
		aim_angle.x = wrapf(aim_angle.x - deg_to_rad(direction.x),0,TAU)
		@warning_ignore("static_called_on_instance")
		aim_angle.y = clamp_vertical_aim(aim_angle.y - deg_to_rad(direction.y))
	
	const MIN_VERTICAL_ANGLE: float = -deg_to_rad(89.999) # using the evaluated 1.57078 results in precision error for asserts lmao
	const MAX_VERTICAL_ANGLE: float = deg_to_rad(89.999) # using the evaluated 1.57078 results in precision error for asserts lmao
	static func clamp_vertical_aim(value: float) -> float:
		return clamp(value, MIN_VERTICAL_ANGLE, MAX_VERTICAL_ANGLE)
	
	func serialize() -> PackedByteArray:
		return InputEncoder.serialize_player_state(inputs,input_dir,aim_angle,events)
	
	func get_serialized() -> PackedByteArray:
		if serialized.is_empty():
			serialized = serialize()
		return serialized.duplicate()

class InputEncoder:
#	const signature_end_offset = 8
#
#	const inputs_offset = signature_end_offset
	const inputs_end_offset = 8 # inputs_offset + 8
	
	const input_dir_offset = inputs_end_offset
	const input_dir_end_offset = input_dir_offset + 8
	
	const aim_angle_offset = input_dir_end_offset
	const aim_angle_end_offset = aim_angle_offset + 8
	
	const events_offset = aim_angle_end_offset
	
	const min_client_state_size = events_offset
	
	static func serialize_player_state(inputs: int, input_dir: Vector2, aim_angle: Vector2, events: PackedByteArray) -> PackedByteArray:
		var client_state: PackedByteArray = []
		client_state.resize(min_client_state_size)
		if !events.is_empty():
			client_state.append_array(events)
		
		client_state.encode_s64(0,inputs)
		
		ByteUtils.encode_v2(client_state,input_dir,input_dir_offset)
		
		ByteUtils.encode_v2(client_state,aim_angle,aim_angle_offset)
		
		return client_state
	
	static func get_inputs(packet: PackedByteArray) -> int:
		return packet.decode_s64(0)
	
	static func get_input_dir(packet: PackedByteArray) -> Vector2:
		# slightly slower this way than to manually decode floats
		return ByteUtils.decode_v2(packet,input_dir_offset)
	
	static func get_aim_angle(packet: PackedByteArray) -> Vector2:
		return ByteUtils.decode_v2(packet,aim_angle_offset)
	
	static func get_client_events(packet: PackedByteArray) -> PackedByteArray:
		return packet.slice(events_offset)
	
	static func deserialize(packet: PackedByteArray) -> Inputs.PlayerInputs:
		# same as calling get_inputs(packet)
		var inputs: Inputs.PlayerInputs = Inputs.PlayerInputs.new(packet.decode_s64(0),get_input_dir(packet))
		inputs.aim_angle = get_aim_angle(packet)
		inputs.events = get_client_events(packet)
		inputs.serialized = packet
		return inputs
	
	static func deserialize_to_inputs(packet: PackedByteArray, inputs: Inputs.PlayerInputs) -> void:
		inputs.inputs = packet.decode_s64(0)
		inputs.input_dir = get_input_dir(packet)
		inputs.aim_angle = get_aim_angle(packet)
		inputs.events = get_client_events(packet)
		inputs.serialized = packet
