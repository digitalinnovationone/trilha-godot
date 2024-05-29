extends Node


@export var animation_tree_name: String = "AnimationTree"
@export var movement_module: MovementModule

var last_position: Vector3
var animation_tree: AnimationTree
var velocity_rate: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	last_position = get_parent().global_position
	animation_tree = get_parent().get_node(animation_tree_name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Pegar velocidade
	var speed = movement_module.speed if movement_module != null else 1.0
	
	# Calcular target_velocity_rate
	var target_velocity_rate: float = 0.0
	var position_diff = last_position - get_parent().global_position
	if position_diff.is_zero_approx():
		target_velocity_rate = 0
	else:
		var position_delta2 = position_diff.length_squared()
		var velocity2 = position_delta2 / delta
		var speed2 = speed * speed
		target_velocity_rate = clampf(velocity2 / speed2, -1, 1)
	
	# Suavização
	velocity_rate = lerpf(velocity_rate, target_velocity_rate, 0.1)
	
	# Animação
	animation_tree.set("parameters/Movement/blend_position", velocity_rate)
