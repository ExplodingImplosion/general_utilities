class_name Tickrate

## How fast the engine is running relative to the physics rate the game is normally
## running at. For instnace, running at a [member target_physics_rate] of 60 and
## using a [member relative_speed] of 0.95 means the engine is currently simulating
## 57 times a second.
static var relative_speed: float = 1.0
## Target 'real' physics rate that the game simulates at, if it's not trying
## to deliberately simulate faster/slower than a server. Assigned first on the
## first idle frame, and when creating/connecting to a server.
static var target_physics_rate: int = Engine.get_physics_ticks_per_second()

## The delta time for physics running at [member target_physics_rate]. Use
## instead of [method Node.get_physics_process_delta_time], in case the game needs
## to simulate at a rate faster/slower than a server. Assigned first on the first
## idle frame and when creating/connecting to a server.
static var physics_delta: float = get_physics_delta()

## The "true" time_scale of the engine. Access this instead of Engine.time_scale, since the engine's
## time_scale is used to change physics process delta values
static var time_scale: float = 1.0

static func get_physics_delta() -> float:
	return 1.0 / target_physics_rate

static func initialize() -> void:
	assert(relative_speed == 1.0,'bruh do static vars not get auto initialized? thats OD')
	assert(target_physics_rate == Engine.physics_ticks_per_second, "bruhhhhhhh")
	assert(physics_delta == 1.0 / target_physics_rate and physics_delta == 1.0 / Engine.physics_ticks_per_second, "howww... either physics delta %s != %s or %s."%
	[physics_delta,1.0/target_physics_rate,1.0 / Engine.physics_ticks_per_second])

static func is_running_at_target_tickrate() -> bool:
	return target_physics_rate == Engine.physics_ticks_per_second

static func modify_physics_sim_speed(frac: float) -> void:
	assert(frac > 0.0, "Fraction must be above 0.")
	var frac_rate: int = int(frac*target_physics_rate)
	var frac_delta: float = 1.0/frac_rate
	# maybe assign physics_delta to frac_delta
	relative_speed = float(frac_rate) / target_physics_rate
	Console.write("Frac delta %s, frac rate: %s"%[frac_delta,frac_rate])
	if frac_rate == Engine.physics_ticks_per_second:
		assert(frac_delta == Quack.get_physics_process_delta_time(),"frac_delta %s != physics process delta time %s"%[frac_delta, Quack.get_physics_process_delta_time()])
	Engine.set_physics_ticks_per_second(frac_rate)
	assign_time_scale()

static func reset_physics_sim_speed() -> void:
	modify_physics_sim_speed(1.0)

static func set_physics_simulation_rate(rate: int) -> void:
	Engine.set_physics_ticks_per_second(rate)
	assign_physics_delta(1.0/rate,rate)

static func assign_physics_delta(delta: float, rate: int) -> void:
	physics_delta = delta
	target_physics_rate = rate
	relative_speed = 1.0

static func auto_assign_physics_delta() -> void:
	# this creates an issue if u do stuff from the menu... which is dumb as fuck and I hate it.
	# might eventually move to just doing division manually, but i want the values of
	# get_physics_process_delta_time() and physics_delta to be EXACTLY correct, and idk if doing
	# manual division might cause their values to differ...
	assign_physics_delta(Quack.get_physics_process_delta_time(),Engine.physics_ticks_per_second)

static func change_tickrate(rate: int) -> void:
	if is_running_at_target_tickrate():
		Engine.set_physics_ticks_per_second(rate)
		auto_assign_physics_delta()
	else:
		target_physics_rate = rate
		physics_delta = 1.0 / rate
		modify_physics_sim_speed(relative_speed)

static func change_time_scale(scale: float) -> void:
	time_scale = scale
	assign_time_scale()

static func assign_time_scale() -> void:
	Engine.set_time_scale(relative_speed * time_scale)
