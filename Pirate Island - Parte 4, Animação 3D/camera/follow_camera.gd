extends Camera3D

@export_group("Follow")
@export var follow_node: Node3D
@export var follow_lerp: float = 0.2

@export_group("Look At")
@export var look_at_node: Node3D
@export var look_at_offset: Vector3


# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = follow_node.global_position
	look_at(look_at_node.global_position + look_at_offset)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = lerp(global_position, follow_node.global_position, follow_lerp)
	look_at(look_at_node.global_position + look_at_offset)
