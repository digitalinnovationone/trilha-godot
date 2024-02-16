extends Node3D


@onready var area3d: Area3D = $Area3D

@export var force: float = 10.0

var exploded: bool = false


func _ready():
	area3d.body_entered.connect(on_body_entered)


func on_body_entered(body: Node3D):
	if body.is_in_group("Player"):
		kaboom()


func kaboom():
	if exploded: return
	
	var bodies = area3d.get_overlapping_bodies()
	for body in bodies:
		if body is RigidBody3D:
			var direction = (body.global_position - area3d.global_position).normalized()
			var impulse_vector = direction * force
			body.apply_central_impulse(impulse_vector)
	exploded = true
