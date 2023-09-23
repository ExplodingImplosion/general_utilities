class_name Movement

var speed: float
var acceleration: float
var decceleration: float

static func is_inputting_jump(inputs: int) -> bool:
	return Inputs.bit_has_flag(inputs,Inputs.action_bitfields_enum.JUMP)

static func get_collider_physics_material(collision: KinematicCollision3D) -> PhysicsMaterial:
	var collider: Object = collision.get_collider()
	return collider.physics_material_override as PhysicsMaterial if collider is PhysicsBody3D and not CharacterBody3D else PhysicsMaterial.new()

func _init(s: float, a: float, d: float) -> void:
	speed = s
	acceleration = a
	decceleration = d
