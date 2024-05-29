extends Node


@export var animation_tree_name: String = "AnimationTree"
@export var death_animation: String = "Death"


var animation_tree: AnimationTree
var state_machine: AnimationNodeStateMachinePlayback


func _ready():
	animation_tree = get_parent().get_node(animation_tree_name)
	state_machine = animation_tree["parameters/playback"]
	Events.entity_died.connect(_on_entity_died)


func _on_entity_died(entity):
	if entity == get_parent():
		state_machine.start(death_animation)
		Events.entity_died.disconnect(_on_entity_died)

