class_name ByteUtils

static func get_byte_change_to_set_bitflag_in_bytes(bit_index: int, on: bool, bytes: PackedByteArray) -> int:
	var byte_idx: int = which_byte_is_bit_in(bit_index)
	var byte: int = bytes[byte_idx]
	return set_bit_by_index_in_byte(get_bit_offset_within_byte(bit_index,byte_idx),byte,on)

static func get_byte_change_to_flip_bit_index_in_bytes(bit_index: int, bytes: PackedByteArray) -> int:
	var byte_idx: int = which_byte_is_bit_in(bit_index)
	var byte: int = bytes[byte_idx]
	return get_byte_with_flipped_bit_index(get_bit_offset_within_byte(bit_index,byte_idx),byte)

static func get_byte_with_flipped_bit(bit: int, byte: int) -> int:
	assert_valid_u8(bit)
	return byte^bit

static func get_byte_with_flipped_bit_index(bit_index: int, byte: int) -> int:
	return get_byte_with_flipped_bit(1<<bit_index,byte)

static func set_bit_in_byte(bit: int, byte: int, on: bool) -> int:
	assert_valid_u8(bit)
	if on:
		return byte | bit
	else:
		return byte & ~bit

static func set_bit_by_index_in_byte(bit_index: int, byte: int, on: bool) -> int:
	return set_bit_in_byte(1<<bit_index,byte,on)

static func get_bit_by_index(idx: int, bytes: PackedByteArray) -> bool:
	var byte_idx: int = which_byte_is_bit_in(idx)
	return bool(bytes[byte_idx] & (1 << get_bit_offset_within_byte(idx,byte_idx)))

static func set_bit_by_index(idx: int, bytes: PackedByteArray, on: bool) -> int:
	var byte_idx: int = which_byte_is_bit_in(idx)
	bytes[byte_idx] = set_bit_by_index_in_byte(get_bit_offset_within_byte(idx,byte_idx),bytes[byte_idx],on)
	return bytes[byte_idx]

static func get_bit_offset_within_byte(bit: int, byte_idx: int) -> int:
	return bit - byte_idx*8

static func is_multiple_of(a: int, b: int) -> bool:
	return a % b == 0

static func bit_has_flag(bit: int, flag: int) -> bool:
	return bool(bit&flag)

static func get_bit_by_index_in_byte(bit_index: int, byte: int) -> bool:
	return bit_has_flag(byte,1<<bit_index)

static func which_byte_is_bit_in(bit_offset: int) -> int:
	@warning_ignore("integer_division")
	return bit_offset/8+(bit_offset%8)/8

const max_u8 = 255
static func is_valid_u8(bit: int) -> bool:
	return bit <= max_u8 and bit >= 0

static func assert_valid_u8(bit: int) -> void:
	assert(is_valid_u8(bit),"Number %s is an invalid unsigned 8-bit int, from 0 to %s"%[bit,max_u8])

const max_u16 = 65535
static func is_valid_u16(num: int) -> bool:
	return num <= max_u16 and num >= 0

static func assert_valid_u16(num: int) -> void:
	assert(is_valid_u16(num),"Number %s is an invalid unisgned 16-bit int, from 0 to %s."%[num,max_u16])

static func wrap_u16(num: int) -> int:
	return wrapi(num,0,max_u16)

static func wrap_u8(num: int) -> int:
	return wrapi(num,0,max_u8)

static func dumbhash(bytes: PackedByteArray) -> int:
	var gaming: int
	for i in bytes.size():
		@warning_ignore("unassigned_variable_op_assign")
		gaming += bytes[i] * i
	return gaming

static func encode_v2(bytes: PackedByteArray, v2: Vector2, offset: int) -> PackedByteArray:
	bytes.encode_float(offset,v2.x)
	bytes.encode_float(offset+4,v2.y)
	return bytes

static func decode_v2(bytes: PackedByteArray, offset: int) -> Vector2:
	@warning_ignore("unassigned_variable")
	var v2: Vector2
	v2.x = bytes.decode_float(offset)
	v2.y = bytes.decode_float(offset+4)
	return v2

static func encode_v3(bytes: PackedByteArray, v3: Vector3, offset: int) -> PackedByteArray:
	bytes.encode_float(offset,v3.x)
	bytes.encode_float(offset+4,v3.y)
	bytes.encode_float(offset+8,v3.z)
	return bytes

static func decode_v3(bytes: PackedByteArray, offset: int) -> Vector3:
	@warning_ignore("unassigned_variable")
	var v3: Vector3
	v3.x = bytes.decode_float(offset)
	v3.y = bytes.decode_float(offset+4)
	v3.z = bytes.decode_float(offset+8)
	return v3

const usec_to_seconds_conversion_ratio = 0.000001
const seconds_to_usec_conversion_ratio = 1000000

static func usec_to_seconds(usec: int) -> float:
	return float(usec) * 0.000001

static func seconds_to_usec(seconds: float) -> int:
	return int(seconds*1000000)
