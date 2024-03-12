extends Node3D


@export var treasure_prefab: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready():
	# Esperar parent ficar pronto
	await(get_parent().ready)
	
	# Sortear posição
	var children = get_children()
	var child = children[randi_range(0, children.size() - 1)]
	var treasure_position = child.global_position
	
	# Criar um "Treasure" nessa posição
	var treasure: Node3D = treasure_prefab.instantiate()
	treasure.global_position = treasure_position
	add_sibling(treasure)
	
	# Deletar node
	queue_free()
