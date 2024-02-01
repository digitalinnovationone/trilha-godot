extends Node2D

@export var creatures: Array[PackedScene]
@export var mobs_per_minute: float = 60.0

@onready var path_follow_2d: PathFollow2D = %PathFollow2D
var cooldown: float = 0.0


func _process(delta: float):
	# Temporizador
	cooldown -= delta
	if cooldown > 0: return
	
	# Frequência
	var interval = 60.0 / mobs_per_minute
	cooldown = interval

	# Instanciar uma criatura aleatória
	var index = randi_range(0, creatures.size() - 1)
	var creature_scene = creatures[index]
	var creature = creature_scene.instantiate()
	creature.global_position = get_point()
	get_parent().add_child(creature)


func get_point() -> Vector2:
	path_follow_2d.progress_ratio = randf()
	return path_follow_2d.global_position

