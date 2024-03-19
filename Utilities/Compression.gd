class_name Compression

enum {
	TIMES_COMPRESSED, # 0
	BEGIN_UNCOMPRESSED, # 1
	SIZE_INDICATOR_BEGIN = 1 # 1
}
const SIZE_INDICATOR_BYTES = 2

static func is_compressed(bytes: PackedByteArray) -> bool:
	return bytes[TIMES_COMPRESSED]

static func get_num_times_compressed(bytes: PackedByteArray) -> int:
	return bytes[TIMES_COMPRESSED]

static func get_begin_offset(bytes: PackedByteArray) -> int:
	return TIMES_COMPRESSED + bytes[TIMES_COMPRESSED] * 2 + 1

static func get_contents_decompressed_size(times_compressed: int, bytes: PackedByteArray) -> int:
	return bytes.decode_u16(SIZE_INDICATOR_BYTES + (times_compressed - 1) * SIZE_INDICATOR_BYTES)

static func get_contents(bytes: PackedByteArray) -> PackedByteArray:
	return bytes.slice(get_begin_offset(bytes))

static func get_bytes_decompressed(times_compressed: int, bytes: PackedByteArray, contents: PackedByteArray) -> PackedByteArray:
	return contents.decompress(get_contents_decompressed_size(times_compressed,bytes),FileAccess.COMPRESSION_FASTLZ)

static func repeated_compress(bytes: PackedByteArray, compression_mode: FileAccess.CompressionMode = FileAccess.COMPRESSION_FASTLZ) -> PackedByteArray:
	var final: PackedByteArray = [0]
	var num_times_compressed: int
	var compressed: PackedByteArray
	
	while true:
		compressed = bytes.compress(compression_mode)
		if compressed.size() < bytes.size():
			num_times_compressed += 1
			add_compression(final,final.size(),bytes.size())
			bytes = compressed
		else:
			break
	
	ByteUtils.assert_valid_u8(num_times_compressed)
	final[0] = num_times_compressed
	final.append_array(bytes)
	return final

static func add_compression(final: PackedByteArray, offset: int, compressed_size: int) -> void:
	final.resize(offset+SIZE_INDICATOR_BYTES)
	final.encode_u16(offset,compressed_size)

static func repeated_decompress(bytes: PackedByteArray) -> PackedByteArray:
	if !is_compressed(bytes):
		return bytes.slice(BEGIN_UNCOMPRESSED)
	var num_times_compressed: int = get_num_times_compressed(bytes)
	assert(num_times_compressed, "trying to decompress packet that's not been compressed, byte at idx %s is %s."%[TIMES_COMPRESSED,num_times_compressed])
	var contents: PackedByteArray = get_contents(bytes)
	for i in num_times_compressed:
		contents = get_bytes_decompressed(num_times_compressed - i,bytes,contents)
	return contents
