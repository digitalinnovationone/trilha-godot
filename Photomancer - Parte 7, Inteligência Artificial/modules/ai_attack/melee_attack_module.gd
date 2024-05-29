extends AttackModule

@export_group("Setup")
@export var area: Area3D
@export var target_group: String = "friendly"
@export var interval: float = 2
@export var damage: int = 10
@export_group("Animation")
@export var animation_tree_name: String = "AnimationTree"
@export var attack_animation: String = "Attack"
@export var hit_delay: float = 0.5

var current_target: Node3D
var cooldown: float = 0.0
var animation_tree: AnimationTree
var state_machine: AnimationNodeStateMachinePlayback


# Called when the node enters the scene tree for the first time.
func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	animation_tree = get_parent().get_node(animation_tree_name)
	state_machine = animation_tree["parameters/playback"]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cooldown -= delta
	if cooldown <= 0.0 and current_target:
		cooldown = interval
		_attack()


func _attack():
	# Tocar animação
	state_machine.travel(attack_animation)
	
	# Esperar delay
	await get_tree().create_timer(hit_delay).timeout
	
	# Se ainda tivermos um alvo, atacar de verdade
	if current_target:
		
		# Disparar o evento
		Events.entity_attacked.emit(get_parent(), current_target, damage)


func _on_body_entered(body: Node3D):
	# Make sure body is in target group
	if not body.is_in_group(target_group): return
	
	# Make sure body is alive
	if not body.has_node("LifeComponent"): return
	
	# Set target
	current_target = body


func _on_body_exited(body: Node3D):
	# Make sure it's our current target
	if body == current_target:
		
		# Reset target
		current_target = null
		
		# Scan targets
		var overlapping_bodies = area.get_overlapping_bodies()
		for overlapping_body in overlapping_bodies:
			_on_body_entered(overlapping_body)


func is_attacking() -> bool:
	return cooldown > 0.0# and current_target != null
