extends CharacterBody3D


@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var lerp_factor: float = 1.0
@export var rotation_lerp_factor: float = 0.025

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var camera: Camera3D
@export var model: Node3D

@onready var animation_tree: AnimationTree = model.get_node("AnimationTree")


func _process(delta):
	var local_velocity = (velocity * transform.basis) / SPEED
	animation_tree.set("parameters/Movement/blend_position", Vector2(local_velocity.x, local_velocity.z))


func _physics_process(delta):
	# Rotate
	rotate_to_face_velocity()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Animate jump
	animation_tree.set("parameters/conditions/jumping", not is_on_floor())

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, camera.rotation.y)
	#var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	velocity.x = lerp(velocity.x, direction.x * SPEED, lerp_factor)
	velocity.z = lerp(velocity.z, direction.z * SPEED, lerp_factor)

	move_and_slide()


func rotate_to_face_velocity():
	rotation.y = lerp_angle(rotation.y, atan2(velocity.x, velocity.z), rotation_lerp_factor)

