extends Node
class_name HighPrecisionTimer
## Higher-precision version of the default [Timer] class.

## The time, in seconds, the timer waits before timing out
@export_range(0.001,INF) var wait_time: float = 1
## Whether the timer restarts after finishing, or if it simply stops.
@export var oneshot: bool
## Whether the timer starts as soon as it enters the scene tree.
@export var auto_start: bool

## The time, in microseconds, the timer started at
var start_time: int
## The physics frame during which the timer started
var start_frame: int
## How much time is left before the timer finishes
var time_left: float
## 0 to 1 value of how much of the timer has elapsed
var ratio: float

## Whether or not the timer is currently running
var running: bool

## Emitted with the amount remaining(?) whenever the timer times out
signal timeout(amount)

func _ready() -> void:
	assert(wait_time > 0, "Wait time %s <= 0."%[wait_time])
	set_processes(false)
	if auto_start:
		start()

## Sets [member start_time] to [method Time.get_ticks_usec], sets [member start_frame]
## to [method Engine.get_physics_frames] and [member running] to true. Also calls
## [method set_processes] passing true. On the next frame/physics frame, the
## timer will start updating.
func start() -> void:
	start_time = Time.get_ticks_usec()
	start_frame = Engine.get_physics_frames()
	running = true
	set_processes(true)

## Calls [method Node.set_process] and [method Node.set_physics_process] passing
## enable.
func set_processes(enable: bool) -> void:
	set_process(enable)
	set_physics_process(enable)

## Calls [method set_processes] passing false, sets [member running] to false, and sets
## [member time_left] to 0
func stop() -> void:
	set_processes(false)
	running = false
	time_left = 0

## Whether or not the timer is stopped. Returns false if the timer is paused.
## The timer is considered 'stopped' if [member running] is false, and [member time_left]
## is exactly 0.
func is_stopped() -> bool:
	return running == false and time_left == 0

## Unfinished. Currently just calls [method set_processes] passing false
func pause() -> void:
	set_processes(false)

## Unfinished. Currently just calls [method set_processes] passing true
func unpause() -> void:
	set_processes(true)

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	update_on_frame()

## Sets [member time_left] to [member wait_time] - diff_sec, and clamps it to
## positive values
func update_time_left(diff_sec: float) -> void:
#	var remainder: float = wait_time - diff_sec
	time_left = clamp(wait_time - diff_sec,0.0,INF) #clamp(remainder
#	return clamp(-remainder,0.0,INF)

## For internal use only. calls [method update_generic] using frame parameters.
func update_on_frame() -> void:
	update_generic(Time.get_ticks_usec(),start_time,0.000001)


## Unfinished. Sets [member start_time] and [member start_frame] to the current time, in
## microseconds and physics frames, respectively. Emits [signal timeout] if
## the time has timed out, along with the amount parameter. Maybe could be used
## outside of internal use, but probably a bad idea.
func on_timeout(amount: float) -> void:
	start_time = Time.get_ticks_usec()
	start_frame = Engine.get_physics_frames()
	emit_signal("timeout",amount)
	if oneshot:
		stop()
#	else:
#		update_rollover()

## Unfinished. For internal use only. Called whenever a non-oneshot timer times out with a
## remaining amount of time still running. Basically, if I use a 1 second timer
## and it takes 1.2 seconds for the game to update the timer, the timer's next
## [member time_remaining] will be 0.8 seconds.
func update_rollover(rollover_time: float) -> void:
	pass

## For internal use only. Handles shared code and updates values/triggers timeout
func update_generic(current_tick: int, start_tick: int, delta: float) -> void:
	var diff: int = current_tick - start_tick
	var diff_sec: float = float(diff)*delta
	var amount: float = floor(diff_sec/wait_time)
	update_time_left(diff_sec)#var remainder: float = 
	if !is_equal_approx(time_left,0.0):
		ratio = 1.0-(time_left/wait_time)
	else:
		ratio = 1.0
	if amount >= 1.0:
		on_timeout(amount)

## For internal use only. Calls [method update_generic] using physics frame
## parameters.
func update_on_physics_frame(delta: float) -> void:
	update_generic(Engine.get_physics_frames(),start_frame,delta)

func _physics_process(delta: float) -> void:
	update_on_physics_frame(delta)
