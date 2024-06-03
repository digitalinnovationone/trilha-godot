extends Node3D


@export var damage: float = 25
@export var area: Area3D

var cooldown: float = 0.1
var ran: bool = false


func _physics_process(delta):
	if not ran:
		cooldown -= delta
		if cooldown < 0.0:
			_run()


func _run():
	ran = true
	var bodies = area.get_overlapping_bodies()
	for body in bodies:
		var hit_life_component: LifeComponent = body.get_node("LifeComponent")
		if hit_life_component and not hit_life_component.is_dead:
			hit_life_component.health -= damage
