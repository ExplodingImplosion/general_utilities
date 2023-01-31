class_name Collision

static func assert_node_has_collision_layers(node: Node3D) -> void:
	assert(node is CollisionObject3D or node is CSGShape3D or node is SoftBody3D or node is GridMap)

enum {WORLD=1,DAMAGE=2,KNOCKBACK=4,NETWORK=8,AIM_ASSIST=16,INTERACTION=32}
static func is_damageable(node: Node3D) -> bool:
	assert_node_has_collision_layers(node)
	return Quack.bit_has_flag(node.collision_layer,DAMAGE)

static func accepts_damage(node: Node3D) -> bool:
	return is_damageable(node)

static func can_be_damaged(node: Node3D) -> bool:
	return is_damageable(node)

static func can_damage_happen(from: Node3D, to: Node3D) -> bool:
	return can_node_damage(from) and is_damageable(to)

static func collides_with_world(node: Node3D) -> bool:
	assert_node_has_collision_layers(node)
	return Quack.bit_has_flag(node.collision_layer,WORLD) # maybe change this to collision_layer and collision_mask?
										# maybe even just collision_mask? Because the mask is
										# what determines 'scanning' for collisions and layer is what
										# what determines 'recieving' collisions

static func accepts_knockback(node: Node3D) -> bool:
	assert_node_has_collision_layers(node)
	return Quack.bit_has_flag(node.collision_layer,KNOCKBACK)

static func can_be_knocked_back(node: Node3D) -> bool:
	return accepts_knockback(node)

static func can_knockback_happen(from: Node3D, to: Node3D) -> bool:
	return can_node_knockback(from) and accepts_knockback(to)

static func network_collision(node: Node3D) -> bool:
	assert_node_has_collision_layers(node)
	return Quack.bit_has_flag(node.collision_mask,NETWORK)

static func can_node_damage(node: Node3D) -> bool:
	assert_node_has_collision_layers(node)
	return Quack.bit_has_flag(node.collision_mask,DAMAGE)

static func collision_damages(node: Node3D) -> bool:
	return can_node_damage(node)

static func can_node_knockback(node: Node3D) -> bool:
	assert_node_has_collision_layers(node)
	return Quack.bit_has_flag(node.collision_mask,KNOCKBACK)

static func collision_knockbacks(node: Node3D) -> bool:
	return can_node_knockback(node)

static func can_aim_assist_target(node: Node3D) -> bool:
	assert_node_has_collision_layers(node)
	return Quack.bit_has_flag(node.collision_layer,AIM_ASSIST)

static func can_interact(node: Node3D) -> bool:
	assert_node_has_collision_layers(node)
	return Quack.bit_has_flag(node.collision_layer,INTERACTION)

static func is_interactable(node: Node3D) -> bool:
	return can_interact(node)

static func get_collision_dimensions(collider: CollisionShape3D) -> Vector3:
	var shape: Shape3D = collider.shape
	var rotation: Vector3 = collider.global_rotation
#	if rotation != Vector3.ZERO:
#		assert(false)
	var scale: Vector3 = collider.scale
	assert_is_valid_3D_shape(shape)
	if shape is BoxShape3D:
		return shape.size*2*scale
	elif shape is CapsuleShape3D:
		# capsules are weird in godot 3
		if shape.height >= 1:
			return Vector3(shape.radius,shape.radius,shape.height)*2*scale
		else:
			return Vector3(shape.radius*2,shape.radius*2,1)*scale
	elif shape is SphereShape3D:
		return shape.radius*2*scale
	elif shape is CylinderShape3D:
		return Vector3(shape.radius*2,shape.height,shape.radius*2)*scale
	else:
		return Vector3.ZERO

static func get_collisionshape_height(collider: CollisionShape3D,scale: Vector3) -> float:
	var shape: Shape3D = collider.shape
	if shape is BoxShape3D:
		return shape.size.y*scale.y
	elif shape is CapsuleShape3D or shape is CylinderShape3D:
		return shape.height*scale.y
	elif shape is SphereShape3D:
		return shape.radius*scale.y
#	elif shape is CylinderShape3D:
#		return 
	else:
		return 0.0

static func get_center_of_mass(position: Vector3, scale: Vector3, collider: CollisionShape3D) -> Vector3:
	return Vector3(position.x,Collision.get_collisionshape_height(collider,scale)/2,position.z)

static func assert_is_valid_3D_shape(shape: Shape3D) -> void:
	assert(shape is BoxShape3D or shape is CapsuleShape3D or shape is SphereShape3D or shape is CylinderShape3D)

#static func test(params: PhysicsShapeQueryParameters3D,max_results: int = 32) -> Array:
#	return qNetwork.query.intersect_shape(params,max_results)

static func setup_params(exclusions: Array, collider: CollisionShape3D, collision_mask: int, collide_with_bodies: bool, collide_with_areas: bool) -> PhysicsShapeQueryParameters3D:
	var params := PhysicsShapeQueryParameters3D.new()
	params.exclude = exclusions
	params.set_shape(collider.shape)
	params.collision_mask = collision_mask
	params.collide_with_bodies = collide_with_bodies
	params.collide_with_areas = collide_with_areas
	return params
