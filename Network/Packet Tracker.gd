class_name PacketTracker

var history: Array[PackedByteArray]
var history_offset: int = -1

func _init(size: int) -> void:
	history.resize(size)

func add_to_history(packet: PackedByteArray) -> void:
	increment_history_offset()
	history[history_offset] = packet

func get_history_offset_incremented() -> int:
	return wrapi(history_offset + 1, 0, history.size())

func increment_history_offset() -> void:
	history_offset = get_history_offset_incremented()

func get_previous_packet(frames_behind: int) -> PackedByteArray:
	assert(frames_behind >= 0, "frames_behind must be a positive number, but is %s."%[frames_behind])
	# maybe change this to some kind of wrapi
	return history[history_offset - frames_behind]

func get_most_recent_packet() -> PackedByteArray:
	return history[history_offset]
