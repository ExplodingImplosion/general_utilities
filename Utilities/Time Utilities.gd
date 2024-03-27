class_name TimeUtils

## Current time, in usec, at which [Quack] ran its [method Quack._process] function.
static var process_time_usec: int
## Previous time, in usec, at which [Quack] ran its [method Quack._process] function.
## At almost all times, this should match [member current_time], since it's only
## used for calculating [member delta_time] in [method Quack._process].
static var prev_process_time_usec: int
## The time, in usec, between the current frame's [member current_time] and the previous
## frame's [member current_time].
static var process_delta_time_usec: int
## Same as [member delta_time] but converted to seconds as a float.
static var process_delta_time_float: float

## Current time, in usec, at which [Qauck] ran its [method Quack._physics_process] function.
static var physics_time_usec: int
## Previous time, in usec, at which [Quack] rant is [method Quack,_physics_process] function.
## At almost all times, this should match [member current_time_physics], since it's only
## used for calculating [member delta_time_physics] in [method Quack._physics_process].
static var prev_physics_time_usec: int
## The time, in usec, between the current physics frame's [member current_time_physics]
## and the previous physics frame's [member current_time_physics].
static var physics_delta_time_usec: int
## Used to calculate the proper time when [method Quack._physics_process] should be called.
## Updated once at [method Quack._init].
static var physics_start_time_usec: int

## The cached version of the engine's current interpolation fraction. Same as
## [method get_interpfrac]. Updated every [method _process] frame.
static var interpfrac: float

## [Thread] that updates as often as possible, polling [Time.get_ticks_usec],
## applying it to [member current_time_thread], and calculating [member delta_time_thread]
## by subtracting [member last_time_thread] from [member current_time_thread],
## and then storing the current time as the last time by applying
## [member current_time_thread] to [member last_time_thread]
static var time_thread := Thread.new()

## Used to calculate [delta_time_thread] when [member time_thread] updates.
## [member time_thread] is currently disabled.
static var current_time_thread: int = 0
## The last time, in usec, at which [member time_thread] updated.
## [member time_thread] is currently disabled.
static var last_time_thread: float = 0
## Delta time, in usec, between [member current_time_thread] and the last time
## [member time_thread] was updated. [member time_thread] is currently disabled.
static var delta_time_thread: int = 0

const usec_in_seconds = ByteUtils.onemil
static func usec_get_usec_offset_from_second(usec: int) -> int:
	return usec%usec_in_seconds

const seconds_in_usec = ByteUtils.onemilfrac
static func usec_to_seconds(usec: int) -> float:
	return float(usec) * seconds_in_usec

static func seconds_to_usec(seconds: float) -> int:
	return int(seconds*usec_in_seconds)

static func seconds_to_usecf(sec: float) -> float:
	return sec*usec_in_seconds

const usec_in_msec = 1000
static func msec_to_usec(msec: int) -> int:
	return msec*usec_in_msec

static func msecf_to_usec(msecf: float) -> int:
	@warning_ignore("narrowing_conversion")
	return msecf*usec_in_msec

const seconds_in_msec = 1.0 / usec_in_msec
static func msec_to_seconds(msec: int) -> float:
	return float(msec)*seconds_in_msec

const msec_in_sec = 1000
static func seconds_to_msec(seconds: float) -> int:
	@warning_ignore("narrowing_conversion")
	return seconds * msec_in_sec

static func seconds_to_msecf(seconds: float) -> float:
	return seconds*msec_in_sec

static func usec_get_sec_offset_from_second(usec: int) -> float:
	return usec_to_seconds(usec_get_usec_offset_from_second(usec))

## Updates [member process_time_usec], [member prev_process_time_usec] calculates
## [member process_delta_time_usec] by subtracting the former two, and calculates
## [member process_delta_time_float] by converting [method process_delta_time_usec] to a [float] and
## multiplying it by [const seconds_in_usec]. Called every time
## [method Quack._process] is called.
static func update_process_times() -> void:
	process_time_usec = Time.get_ticks_usec()
	process_delta_time_usec = process_time_usec - prev_process_time_usec
	prev_process_time_usec = process_time_usec
	interpfrac = Engine.get_physics_interpolation_fraction()
	process_delta_time_float = TimeUtils.usec_to_seconds(process_delta_time_usec)

## Updates [member physics_time_usec], [member prev_physics_time_usec]
## and calculates [member physics_delta_time_usec] by subtracting the former two.
## Called every time [method Quack._physics_process] is called.
static func update_physics_times() -> void:
	physics_time_usec = Time.get_ticks_usec()
	physics_delta_time_usec = physics_time_usec - prev_physics_time_usec
	prev_physics_time_usec = physics_time_usec

static func begin_physics_tracking() -> void:
	physics_start_time_usec = Time.get_ticks_usec()
	prev_physics_time_usec = physics_start_time_usec

static func start_time_thread() -> void:
	if time_thread.start(do_time_thread) != OK:
		print("fuck off")
		Quack.quit()

@warning_ignore("unused_parameter")
static func do_time_thread(n = null) -> void:
	for i in INF:
		current_time_thread = Time.get_ticks_usec()
		delta_time_thread = current_time_thread - prev_process_time_usec#_thread
#		print(delta_time_thread)
#		last_time_thread = current_time_thread
#		if current_time_thread != current_time:
#			print("thread: threaded time %s != %s"%[current_time_thread, current_time])

static func get_interpfrac() -> float:
	return Engine.get_physics_interpolation_fraction()

static func update_interpfrac() -> void:
	interpfrac = get_interpfrac()

## Returns [code]true[/code] if [member process_time_usec] is [code]0[/code]. Otherwise returns [code]false[/code].
static func is_startup() -> bool:
	return process_time_usec == 0

static func tick_time_value_towards(value: float, towards: float) -> float:
	value += process_delta_time_float
	return towards - value

static func tick_time_value_down(value: float) -> float:
	return value - process_delta_time_float

static func tick_time_value_up(value: float) -> float:
	return value + process_delta_time_float

static func frames_to_time(frames: int) -> float:
	return frames*Tickrate.physics_delta

static func frames_to_ms(frames: int) -> int:
	return seconds_to_msec(frames_to_time(frames))

static func frames_to_ms_f(frames: int) -> float:
	return seconds_to_msecf(frames_to_time(frames))

static func to_physics_frames(time: float) -> int:
	return int(time * Engine.physics_ticks_per_second)

static func frames_elapsed(since: int, time: int) -> bool:
	return Engine.get_physics_frames() >= since + time

static func get_time_left_in_frame_usec() -> int:
	var time: int = Time.get_ticks_usec()
	var target_time: int = WindowUtils.get_target_process_delta_usec()
	var next_time: int = process_time_usec + target_time
	return next_time - time

static func get_time_elapsed_in_frame_usec() -> int:
	return Time.get_ticks_usec() - process_time_usec

static func get_time_left_in_frame() -> float:
	return usec_to_seconds(get_time_left_in_frame_usec())

static func get_frame_frac() -> float:
	return float(get_time_elapsed_in_frame_usec()) / WindowUtils.get_target_process_delta_usec()

static func get_frame_frac_remainder() -> float:
	return 1.0 - get_frame_frac()

static func is_physics_frame_interval(interval: int) -> bool:
	return Engine.get_physics_frames() % interval == 0

static func is_physics_time_interval(interval: float) -> bool:
	return is_physics_frame_interval(to_physics_frames(interval))

static func get_time_usec() -> float:
	return usec_to_seconds(Time.get_ticks_usec())

static func get_time_msec() -> float:
	return msec_to_seconds(Time.get_ticks_usec())
