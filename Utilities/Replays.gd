class_name Replays

const REPLAY_DIRECTORY := "user://replays/"

static func setup_filepath() -> void:
	@warning_ignore("static_called_on_instance")
	Quack.setup_directory(REPLAY_DIRECTORY)

static func make_file_name(title: String) -> String:
	return title + " " + get_generic_file_name()

static func get_generic_file_name() -> String:
	@warning_ignore("static_called_on_instance")
	return Quack.get_datetime_string() + " " + str(OS.get_unique_id()) + ".REPLAY"

static func open_at_replay_directory(name: String) -> FileAccess:
	return FileAccess.open(REPLAY_DIRECTORY + name,FileAccess.WRITE)

class Replay:
	var tickrate: int
	var snapshot_tickrate: int
	var compress_on_tick: bool
	var history: Array[PackedByteArray]
	var map: String
	enum {TICKRATE,SNAPSHOT_TICKRATE=2,COMPRESS_ON_TICK=10,MAP_SIZE,MAP=19}
	@warning_ignore("shadowed_variable")
	func _init(tickrate: int, snapshot_tickrate: int, compress_on_tick: bool, map: String) -> void:
		self.tickrate = tickrate
		self.snapshot_tickrate = snapshot_tickrate
		self.compress_on_tick = compress_on_tick
		self.map = map
	
	static func get_history_offset_in_bytes(serialized: PackedByteArray) -> int:
		return MAP+serialized.decode_u64(MAP_SIZE)
	
	static func get_map_from_bytes(serialized: PackedByteArray,map_end_offset: int) -> String:
		return bytes_to_var(serialized.slice(MAP,map_end_offset))
	
	static func get_history_from_bytes(serialized: PackedByteArray,history_offset: int) -> Array:
		return bytes_to_var(serialized.slice(history_offset))
	
	static func load_from_file(file_path: String) -> Replay:
		var buffer: PackedByteArray = FileAccess.get_file_as_bytes(file_path)
		var compressed_size: int = buffer.size()-8
		var size: int = buffer.decode_u64(compressed_size)
		buffer.resize(compressed_size)
		return deserialize(buffer.decompress(size,FileAccess.COMPRESSION_ZSTD))
	
	static func deserialize(serialized: PackedByteArray) -> Replay:
		breakpoint
		var replay: Replay
		@warning_ignore("shadowed_variable")
		var tickrate: int = serialized.decode_u16(TICKRATE)
		@warning_ignore("shadowed_variable")
		var snapshot_tickrate: int = serialized.decode_u64(SNAPSHOT_TICKRATE)
		@warning_ignore("shadowed_variable")
		var compress_on_tick: bool = bool(serialized.decode_u8(COMPRESS_ON_TICK))
		var history_offset: int = get_history_offset_in_bytes(serialized)
		@warning_ignore("shadowed_variable")
		var map: String = get_map_from_bytes(serialized,history_offset)
		replay = Replay.new(tickrate,snapshot_tickrate,compress_on_tick,map)
		# would totally wanna just assign replay.history to get_history_from_bytes,
		# but statically typed arrays are being cringe rn
		@warning_ignore("shadowed_variable")
		var history: Array = get_history_from_bytes(serialized,history_offset)
		replay.history.resize(history.size())
		for i in history.size():
			replay.history[i] = history[i]
		return replay
	
	func get_state(state: PackedByteArray) -> PackedByteArray:
		return state.compress(FileAccess.COMPRESSION_FASTLZ) if compress_on_tick else state
	
	func should_serialize_full_state() -> bool:
		# Returns true if history is not empty and snapshots are enabled and
		# the current tick is a valid tick
		return history.is_empty() or snapshot_tickrate != -1 and history.size() % snapshot_tickrate == 0
	func add(worldstate: WorldState, previous: WorldState.PreviousWorldState) -> void:
		var serialized: PackedByteArray = worldstate.get_serialized()
		if should_serialize_full_state():
			history.append(get_state(serialized))
		else:
			history.append(get_state(worldstate.strip_identical_values(previous)))
	func add_state(state: PackedByteArray) -> void:
		history.append(get_state(state))
	func add_by_tracker(tracker: WorldStateTracker) -> void:
		add(tracker.worldstate,tracker.get_most_recent_previous_worldstate())
	
	func length() -> int:
		return history.size()
	
	func length_seconds() -> float:
		return float(length())/tickrate
	
	func length_time(include_subseconds: bool = false) -> String:
		var replay_length: int = length()
		
		var days: int
		var hours: int
		var minutes: int
		var seconds: int
		
		var sub_seconds: int = replay_length%tickrate
		replay_length -= sub_seconds
		assert(replay_length % tickrate == 0, "No sub seconds must be left over.")
		
		@warning_ignore("integer_division")
		seconds = replay_length / tickrate
		@warning_ignore("integer_division")
		minutes = seconds / 60
		seconds = seconds % 60
		
		@warning_ignore("integer_division")
		hours = minutes / 60
		minutes = minutes % 60
		
		@warning_ignore("integer_division")
		days = hours / 24
		hours = hours % 24
		
		var result: String
		if days > 0:
			result = "%s:"%[days]
		if hours > 0:
			result += "%s:"%[hours]
		
		result += "%s:%s"%[minutes,seconds]
		
		if include_subseconds:
			result += ":%s"%[sub_seconds]
			if sub_seconds < 10:
				result = result.insert(result.length()-1,"0")
		
		return result
	
	func get_nearest_full_worldstate(idx: int) -> PackedByteArray:
		if snapshot_tickrate == -1:
			return history[0]
		else:
			@warning_ignore("integer_division", "unused_variable")
			var gaming: int = (idx/snapshot_tickrate)*snapshot_tickrate
			@warning_ignore("integer_division")
			assert(((idx/snapshot_tickrate)*snapshot_tickrate)%snapshot_tickrate == 0, "%s must be at a snapshot tickrate interval."%[(idx/snapshot_tickrate)*snapshot_tickrate])
			@warning_ignore("integer_division")
			return history[(idx/snapshot_tickrate)*snapshot_tickrate]
	
	func save(replay_name: String) -> void:
		if replay_name.is_empty():
			replay_name = Replays.get_generic_file_name()
		else:
			replay_name = Replays.make_file_name(replay_name)
		Console.write("Storing replay %s"%[replay_name])
		var file := Replays.open_at_replay_directory(replay_name)
		var buffer := PackedByteArray()
		buffer.resize(MAP)
		buffer.encode_u16(0,tickrate)
		buffer.encode_s64(SNAPSHOT_TICKRATE,snapshot_tickrate)
		buffer.encode_u8(COMPRESS_ON_TICK,int(compress_on_tick))
		var serialized_map: PackedByteArray = var_to_bytes(map)
		buffer.encode_u64(MAP_SIZE,serialized_map.size())
		buffer.append_array(serialized_map)
		buffer.append_array(var_to_bytes(history))
#		buffer = buffer.compress(FileAccess.COMPRESSION_GZIP)
#		prints(buffer.size(),buffer.compress(FileAccess.COMPRESSION_GZIP).size(),buffer.compress(FileAccess.COMPRESSION_ZSTD).size())
		var compressed: PackedByteArray = buffer.compress(FileAccess.COMPRESSION_ZSTD)
		var offset: int = compressed.size()
		compressed.resize(offset+8)
		compressed.encode_u64(offset,buffer.size())
		file.store_buffer(compressed)
		Console.write("Replay saved! Closing file...")
		# File closing now happens automatically
