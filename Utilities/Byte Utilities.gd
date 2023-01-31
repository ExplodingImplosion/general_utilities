class_name ByteUtils

static func bit_has_flag(bit: int, flag: int) -> bool:
	return bool(bit&flag)

static func get_byte_change_to_set_bitflag_in_bytes(bit_index: int, on: bool, bytes: PackedByteArray) -> int:
	var byte_idx: int = which_byte_is_bit_in(bit_index)
	var byte: int = bytes[byte_idx]
	return set_bit_by_index_in_byte(get_bit_offset_within_byte(bit_index,byte_idx),byte,on)

static func get_byte_change_to_flip_bit_index_in_bytes(bit_index: int, bytes: PackedByteArray) -> int:
	var byte_idx: int = which_byte_is_bit_in(bit_index)
	var byte: int = bytes[byte_idx]
	return get_byte_with_flipped_bit_index(get_bit_offset_within_byte(bit_index,byte_idx),byte)

static func get_byte_with_flipped_bit(bit: int, byte: int) -> int:
	assert_bit_valid_uint8(bit)
	return byte^bit

static func get_byte_with_flipped_bit_index(bit_index: int, byte: int) -> int:
	return get_byte_with_flipped_bit(1<<bit_index,byte)

static func set_bit_in_byte(bit: int, byte: int, on: bool) -> int:
	assert_bit_valid_uint8(bit)
	if on:
		return byte | bit
	else:
		return byte & ~bit

static func set_bit_by_index_in_byte(bit_index: int, byte: int, on: bool) -> int:
	return set_bit_in_byte(1<<bit_index,byte,on)

static func get_bit_by_index(idx: int, bytes: PackedByteArray) -> bool:
	var byte_idx: int = which_byte_is_bit_in(idx)
	return bool(bytes[byte_idx] & get_bit_offset_within_byte(idx,byte_idx))

static func get_bit_offset_within_byte(bit: int, byte_idx: int) -> int:
	return bit - byte_idx*8

static func get_bit(bit: int, bytes: PackedByteArray) -> bool:
	var bits: int
	for i in 8:
		bits |= bytes[i] << i*8
	return bool(bits & bit)

static func which_byte_is_bit_in(bit_offset: int) -> int:
	# chatGPT told me x >> 3 is the same as x / 8 but might be more performant
	return bit_offset/8+int(bool(bit_offset%8))

const max_u8 = 255
static func is_bit_valid_uint8(bit: int) -> bool:
	return bit <= max_u8 and bit >= 0

static func assert_bit_valid_uint8(bit: int) -> void:
	assert(is_bit_valid_uint8(bit))

const max_u16 = 65535
static func is_valid_u16(num: int) -> bool:
	return num <= max_u16 and num >= 0

static func assert_valid_u16(num: int) -> void:
	assert(is_valid_u16(num))

static func wrap_u16(num: int) -> int:
	return wrapi(num,0,max_u16)

static func wrap_u8(num: int) -> int:
	return wrapi(num,0,max_u8)
