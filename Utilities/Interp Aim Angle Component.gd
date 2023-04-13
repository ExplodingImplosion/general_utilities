class_name InterpAimAngle

var last: Vector2
var next: Vector2
var owner: PlayerCharacter
var diff: float

func _init(my_owner: Node3D) -> void:
	owner = my_owner
	update_next()
	update_last()

func update_last() -> void:
	last = next

func update_next() -> void:
	next = owner.aim_angle

func calc_diff() -> void:
	diff = last.distance_to(next)

func interpolate(frac: float) -> void:
	owner.update_aim(last.move_toward(next, frac * diff))

func preupdate() -> void:
	update_last()
	owner.update_aim(next)

func postupdate() -> void:
	update_next()
	calc_diff()

func update(update_func: Callable, delta: float) -> void:
	preupdate()
	update_func.call(delta)
	postupdate()

func snap() -> void:
	last = owner.aim_angle
	next = last
	diff = 0

func snap_to(to: Vector2) -> void:
	owner.update_aim(to)
	last = to
	next = to
	diff = 0
