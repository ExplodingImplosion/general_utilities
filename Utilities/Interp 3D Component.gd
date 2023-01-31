class_name Interp3D
# idk?
#extends WeakRef

var last: Vector3
var next: Vector3
var owner: Node3D
var diff: float

func _init(my_owner: Node3D) -> void:
	owner = my_owner
	# might cause a bug if player gets spawned outside of 0,0,0 and like
	# owner.global_transform.origin doesnt update to not 0,0,0 in time for
	# update_next and update_last
	update_next()
	update_last()

func update_last() -> void:
	last = next

func update_next() -> void:
	next = owner.global_transform.origin

func calc_diff() -> void:
	diff = last.distance_to(next)

func interpolate(frac: float) -> void:
	owner.global_transform.origin = last.move_toward(next, frac * diff)

func premove() -> void:
	update_last()
	owner.global_transform.origin = next

func postmove() -> void:
	update_next()
	calc_diff()

func move(move_func: Callable, delta: float) -> void:
	premove()
	move_func.call(delta)
	postmove()

func teleport() -> void:
	last = owner.global_transform.origin
	next = last
	diff = 0

func teleport_to(to: Vector3) -> void:
	owner.global_transform.origin = to
	# could just be teleport()
	last = to
	next = to
	diff = 0
