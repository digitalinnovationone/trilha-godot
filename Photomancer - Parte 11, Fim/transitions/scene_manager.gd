extends Control

@onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.play_backwards("fade")

func transition_to(scene_path: String):
	animation_player.play("fade")
	await animation_player.animation_finished
	get_tree().change_scene_to_file(scene_path)
	animation_player.play_backwards("fade")
