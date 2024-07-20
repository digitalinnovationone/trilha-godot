extends Node


@export var player: Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.entity_died.connect(_on_entity_died)


func _on_entity_died(entity):
	if entity == player:
		Events.game_over.emit(player)
		Events.entity_died.disconnect(_on_entity_died)
