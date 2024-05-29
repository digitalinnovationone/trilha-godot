extends Node


func _ready():
	Events.entity_attacked.connect(_on_entity_attacked)


func _on_entity_attacked(attacker: Node3D, victim: Node3D, damage: int):
	var victim_life_component: LifeComponent = victim.get_node("LifeComponent")
	if victim_life_component:
		victim_life_component.health -= damage
		print(victim.name, " took ", damage, " damage from ", attacker.name)
