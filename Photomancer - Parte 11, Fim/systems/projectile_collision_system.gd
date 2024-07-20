extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.projectile_collided.connect(_on_projectile_collided)


func _on_projectile_collided(projectile: Projectile, collided_with: Node):
	var hit_life_component: LifeComponent = collided_with.get_node("LifeComponent")
	if hit_life_component and not hit_life_component.is_dead:
		hit_life_component.health -= projectile.damage
