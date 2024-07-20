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
	var current_position = get_parent().global_position
	var position_diff = last_position - current_position
	var position_delta = position_diff.length()
	var velocity = position_delta / delta
	target_velocity_rate = clampf(velocity / speed, -1, 1)
	
	# Suavização
	velocity_rate = lerpf(velocity_rate, target_velocity_rate, 0.1)
	
	# Animação
	animation_tree.set("parameters/Movement/blend_position", velocity_rate)
	
	# Atualizar o last_position
	last_position = current_position
