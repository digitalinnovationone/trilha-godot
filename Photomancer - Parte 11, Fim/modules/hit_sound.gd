extends Node


@export var audio_stream: AudioStreamPlayer3D


func _ready():
	Events.health_changed.connect(_on_health_changed)


func _on_health_changed(entity, health: int, old_health: int, max_health: int):
	if entity == get_parent():
		if health < old_health:
			audio_stream.play()
