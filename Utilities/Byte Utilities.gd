class_name ByteUtils

static func get_byte_change_to_set_bitflag_in_bytes(bit_index: int, on: bool, bytes: PackedByteArray) -> int:
	var byte: int = bytes[which_byte_is_bit_in(bit_index)]
	return set_bit_by_index_in_byte(get_bit_offset_within_byte(bit_index),byte,on)

static func get_byte_change_to_flip_bit_index_in_bytes(bit_index: int, bytes: PackedByteArray) -> int:
	var byte: int = bytes[which_byte_is_bit_in(bit_index)]
	return get_byte_with_flipped_bit_index(get_bit_offset_within_byte(bit_index),byte)

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

static func set_bit_in_int(bit: int, num: int, on: bool) -> int:
	if on:
		return num | bit
	else:
		return num & ~bit

static func set_bit_by_index_in_byte(bit_index: int, byte: int, on: bool) -> int:
	return set_bit_in_byte(1<<bit_index,byte,on)

static func set_bit_by_index_in_int(bit_index: int, num: int, on: bool) -> int:
	return set_bit_in_int(1<<bit_index,num,on)

static func get_bit_by_index(idx: int, bytes: PackedByteArray) -> bool:
	var byte_idx: int = which_byte_is_bit_in(idx)
	return bool(bytes[byte_idx] & (1 << get_bit_offset_within_byte(idx)))

static func set_bit_by_index(idx: int, bytes: PackedByteArray, on: bool) -> int:
	var byte_idx: int = which_byte_is_bit_in(idx)
	bytes[byte_idx] = set_bit_by_index_in_byte(get_bit_offset_within_byte(idx),bytes[byte_idx],on)
	return bytes[byte_idx]

static func get_bit_offset_within_byte(bit: int) -> int:
	assert(bit > -1, "Bits can't have negative values of %s. Must be 0 or greater."%str(bit))
	return bit%8

static func is_multiple_of(a: int, b: int) -> bool:
	return a % b == 0

static func bit_has_flag(bit: int, flag: int) -> bool:
	return bool(bit&flag)

static func get_bit_by_index_in_byte(bit_index: int, byte: int) -> bool:
	return bit_has_flag(byte,1<<bit_index)

static func which_byte_is_bit_in(bit_offset: int) -> int:
	@warning_ignore("integer_division")
	return bit_offset/8+(bit_offset%8)/8

static func get_num_bytes_to_hold_num_bits(num_bits: int) -> int:
	return which_byte_is_bit_in(num_bits) + 1

const max_u8 = 255
static func is_valid_u8(byte: int) -> bool:
	return byte <= max_u8 and byte >= 0

static func assert_valid_u8(byte: int) -> void:
	assert(is_valid_u8(byte),"Number %s is an invalid unsigned 8-bit int, from 0 to %s"%[byte,max_u8])

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
	var gaming: int = 0
	for i in bytes.size():
		gaming += bytes[i] * i
	return gaming

static func encode_v2(bytes: PackedByteArray, v2: Vector2, offset: int) -> PackedByteArray:
	bytes.encode_float(offset,v2.x)
	bytes.encode_float(offset+4,v2.y)
	return bytes

static func decode_v2(bytes: PackedByteArray, offset: int) -> Vector2:
	var v2 := Vector2.ZERO
	v2.x = bytes.decode_float(offset)
	v2.y = bytes.decode_float(offset+4)
	return v2

static func encode_v3(bytes: PackedByteArray, v3: Vector3, offset: int) -> PackedByteArray:
	bytes.encode_float(offset,v3.x)
	bytes.encode_float(offset+4,v3.y)
	bytes.encode_float(offset+8,v3.z)
	return bytes

static func decode_v3(bytes: PackedByteArray, offset: int) -> Vector3:
	var v3 := Vector3.ZERO
	v3.x = bytes.decode_float(offset)
	v3.y = bytes.decode_float(offset+4)
	v3.z = bytes.decode_float(offset+8)
	return v3

static func encode_v4(bytes: PackedByteArray, v4: Vector4, offset: int) -> PackedByteArray:
	bytes.encode_float(offset,v4.x)
	bytes.encode_float(offset+4,v4.y)
	bytes.encode_float(offset+8,v4.z)
	bytes.encode_float(offset+12,v4.w)
	return bytes

static func decode_v4(bytes: PackedByteArray, offset: int) -> Vector4:
	return Vector4(
		bytes.decode_float(offset),
		bytes.decode_float(offset+4),
		bytes.decode_float(offset+8),
		bytes.decode_float(offset+12)
	)

static func encode_v2i(bytes: PackedByteArray, v2: Vector2i, offset: int) -> PackedByteArray:
	bytes.encode_s32(offset,v2.x)
	bytes.encode_s32(offset+4,v2.y)
	return bytes

static func decode_v2i(bytes: PackedByteArray, offset: int) -> Vector2i:
	return Vector2i(bytes.decode_s32(offset),bytes.decode_s32(offset+4))

static func encode_v3i(bytes: PackedByteArray, v3: Vector3i, offset: int) -> PackedByteArray:
	bytes.encode_s32(offset,v3.x)
	bytes.encode_s32(offset+4,v3.y)
	bytes.encode_s32(offset+8,v3.z)
	return bytes

static func decode_v3i(bytes: PackedByteArray, offset: int) -> Vector3i:
	return Vector3i(
		bytes.decode_s32(offset),
		bytes.decode_s32(offset+4),
		bytes.decode_s32(offset+8)
	)

static func encode_v4i(bytes: PackedByteArray, v4: Vector4i, offset: int) -> PackedByteArray:
	bytes.encode_s32(offset,v4.x)
	bytes.encode_s32(offset+4,v4.y)
	bytes.encode_s32(offset+8,v4.z)
	bytes.encode_s32(offset+12,v4.w)
	return bytes

static func decode_v4i(bytes: PackedByteArray, offset: int) -> Vector4i:
	return Vector4i(
		bytes.decode_s32(offset),
		bytes.decode_s32(offset+4),
		bytes.decode_s32(offset+8),
		bytes.decode_s32(offset+12)
	)

static func turn_all_bits_on(buffer: PackedByteArray) -> void:
	buffer.fill(255)

static func encode_array(encode_to: PackedByteArray, array_to_encode: PackedByteArray, offset: int) -> void:
	assert(encode_to.size() >= array_to_encode.size() + offset, "Not enough room in array being encoded to of size %s. Array being encoded is of size %s and offset is %s, which encodes up to index %s."%[encode_to.size(),array_to_encode.size(),offset,array_to_encode.size()+offset])
	for i in array_to_encode.size():
		encode_to[offset+i] = array_to_encode[i]

static func get_all_bits_by_index(bytearray: PackedByteArray) -> Array[bool]:
	var bits: Array[bool] = []
	var bit_count: int = bytearray.size()*8
	bits.resize(bit_count)
	for i in bit_count:
		bits[i] = get_bit_by_index(i,bytearray)
	return bits


static func get_even_string(bytearray: PackedByteArray) -> String:
	var string: String = "["
	for byte in bytearray:
		for i in 3-get_digits(byte):
			string += "0"
		string += str(byte) + ", "
	string += "]"
	return string

# probably not efficient lol
static func get_digits(byte: int) -> int:
	if byte < 10:
		return 1
	if byte < 100:
		return 2
	return 3

const onemil = 1000000
const onemilfrac = 0.000001

const onebil = 1000000000
const onebilfrac = 0.000000001

static func bytes_to_megabytes(bytes: int) -> float:
	return float(bytes)*onemilfrac

static func bytes_to_gigabytes(bytes: int) -> float:
	return float(bytes)*onebilfrac

static func clamp_u16(value: int) -> int:
	return clampi(value,0,max_u16)
static func get_compressed(bytes: PackedByteArray, mode: FileAccess.CompressionMode, size_indicator_bytes: int) -> PackedByteArray:
	var compressed := bytes.compress(mode)
	var full := PackedByteArray()
	full.resize(size_indicator_bytes)
	match size_indicator_bytes:
		1:
			full[0] = size_indicator_bytes
		2:
			full.encode_u16(0,size_indicator_bytes)
		4:
			full.encode_u32(0,size_indicator_bytes)
		8:
			# maybe make it a s64
			full.encode_u64(0,size_indicator_bytes)
		_:
			@warning_ignore("assert_always_false")
			assert(false,"size indicator bytes %s is invalid."%size_indicator_bytes)
	full.append_array(compressed)
	return full

static func get_decompressed(bytes: PackedByteArray, mode: FileAccess.CompressionMode, size_indicator_bytes: int) -> PackedByteArray:
	match size_indicator_bytes:
		1:
			return bytes.decompress(bytes[0],mode)
		2:
			return bytes.decompress(bytes.decode_u16(0),mode)
		4:
			return bytes.decompress(bytes.decode_u32(0),mode)
		8:
			# maybe make it a s64
			bytes.decompress(bytes.decode_u64(0),mode)
	@warning_ignore("assert_always_false")
	assert(false,"size indicator bytes %s is invalid."%size_indicator_bytes)
	return []

static func get_pct(num: int, factor: int) -> float:
	return float(num*100)/factor

# based on https://www.reddit.com/r/godot/comments/l8ximk/comment/iuh97y0/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
static func to_binary_string(num: int) -> String:
	var str := ""
	var n : = num
	while n > 0:
		str = str(n&1) + str
		n = n>>1
	assert(str.bin_to_int() == num, "String %s.bin_to_int() number %s != %s."%[str,str.bin_to_int(),num])
	return str

static func to_binary_array(bytes: PackedByteArray) -> PackedStringArray:
	var strings := PackedStringArray()
	var size := bytes.size()
	strings.resize(size)
	
	for i in size:
		strings[i] = to_binary_string(bytes[i])
	
	return strings
