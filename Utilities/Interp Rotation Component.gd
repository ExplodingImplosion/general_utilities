class_name InterpRotation

var last: Vector3
var next: Vector3
var owner: Node3D
var diff: float

func _init(my_owner: Node3D) -> void:
	owner = my_owner
	update_next()
	update_last()

func update_last() -> void:
	last = next

func update_next() -> void:
	next = owner.global_rotation

func calc_diff() -> void:
	diff = last.distance_to(next)

func interpolate(frac: float) -> void:
	owner.global_rotation = last.move_toward(next, frac * diff)

func preupdate() -> void:
	update_last()
	owner.global_rotation = next

func postupdate() -> void:
	update_next()
	calc_diff()

func update(update_func: Callable, delta: float) -> void:
	preupdate()
	update_func.call(delta)
	postupdate()

func snap() -> void:
	last = owner.global_rotation
	next = last
	diff = 0

func snap_to(to: Vector3) -> void:
	owner.global_rotation = to
	last = to
	next = to
	diff = 0
