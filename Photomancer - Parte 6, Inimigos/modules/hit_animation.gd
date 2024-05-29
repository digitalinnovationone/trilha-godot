extends Node


@export var animation_tree_name: String = "AnimationTree"
@export var animation: String = "Hit"


var animation_tree: AnimationTree
var state_machine: AnimationNodeStateMachinePlayback


func _ready():
	animation_tree = get_parent().get_node(animation_tree_name)
	state_machine = animation_tree["parameters/playback"]
	Events.health_changed.connect(_on_health_changed)


func _on_health_changed(entity, health: int, old_health: int, max_health: int):
	if entity == get_parent():
		if health < old_health:
			state_machine.start(animation)

