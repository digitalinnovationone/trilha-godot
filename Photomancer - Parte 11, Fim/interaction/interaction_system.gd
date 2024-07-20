extends Node


@export var player: Player

@onready var camera: Camera3D = player.get_node("%Camera")
@onready var raycast: RayCast3D = player.get_node("%Raycast")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Player morreu
	if player.is_dead(): return
	
	# Usar raycast pra pegar um interactable
	var target = raycast.get_collider()
	var interactable: Interactable
	if target and target is Interactable:
		interactable = target
	elif target:
		var parent = target.get_parent()
		if parent and parent is Interactable:
			interactable = parent
	
	# Interação com objeto
	if interactable:
		if Input.is_action_just_pressed("interact"):
			interactable.interact(player)
