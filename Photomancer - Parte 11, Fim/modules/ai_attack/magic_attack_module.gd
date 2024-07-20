extends AttackModule

@export_group("Setup")
@export var area: Area3D
@export var target_group: String = "friendly"
@export var interval: float = 5
@export var projectile_spawn_marker: Node3D
# TODO: Pegar varinha
@export_group("Animation")
@export var animation_tree_name: String = "AnimationTree"
@export var attack_animation: String = "Attack"
@export var hit_delay: float = 0.5

var targets: Array[Node3D] = []
var current_target: Node3D
var cooldown: float = 0.0
var animation_tree: AnimationTree
var state_machine: AnimationNodeStateMachinePlayback


# Called when the node enters the scene tree for the first time.
func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	Events.entity_died.connect(_on_entity_died)
	animation_tree = get_parent().get_node(animation_tree_name)
	state_machine = animation_tree["parameters/playback"]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var entity = get_parent()
	
	# Update attack cooldown
	cooldown -= delta
	if cooldown <= 0.0:
		_scan()
		if current_target:
			cooldown = interval
			_attack()

	# Look at
	if current_target and not is_attacking():
		var offset = current_target.global_position - entity.global_position
		offset.y = 0
		if not offset.is_zero_approx():
			var future_transform = entity.transform.looking_at(entity.global_position - offset, Vector3.UP)
			entity.transform = entity.transform.interpolate_with(future_transform, 0.3)






func _scan():
	var parent_position: Vector3 = get_parent().global_position
	var space_state = get_parent().get_world_3d().direct_space_state
	
	# Obter alvo mais próximo
	var closest_target: Node3D
	var closest_distance: float
	for target in targets:
		# Check distance
		var target_position = target.global_position
		var distance = parent_position.distance_squared_to(target_position)
		if closest_target == null or distance < closest_distance:
			# Raycast
			var query = PhysicsRayQueryParameters3D.create(parent_position, target_position)
			query.exclude = [get_parent(), target]
			var result = space_state.intersect_ray(query)
			var is_path_free = result.is_empty()
			if is_path_free:
				closest_target = target
				closest_distance = distance
	
	# Definir novo target
	current_target = closest_target


func _attack():
	var entity = get_parent()
	
	# Tocar animação
	state_machine.travel(attack_animation)
	
	# Esperar delay
	await get_tree().create_timer(hit_delay).timeout
	
	# Se ainda tivermos um alvo, atacar de verdade
	if current_target:
		
		# Obter varinha
		var wand_type: WandType
		if "wand_type" in entity:
			wand_type = entity.wand_type
		if not wand_type:
			return
		
		# Criar projétil
		var projectile: Projectile = wand_type.projectile.instantiate()
		projectile.damage = wand_type.damage
		projectile.add_collision_exception_with(entity)
		entity.add_sibling(projectile)
		projectile.global_position = projectile_spawn_marker.global_position
		var diff: Vector3 = ((current_target.global_position + Vector3(0, wand_type.target_offset_y, 0)) - entity.global_position)
		var velocity = diff.normalized() * wand_type.shooting_speed
		projectile.linear_velocity = velocity


func _on_body_entered(body: Node3D):
	# Make sure body is in target group
	if not body.is_in_group(target_group): return
	
	# Make sure body is alive
	if not body.has_node("LifeComponent"): return
	var life_component: LifeComponent = body.get_node("LifeComponent")
	if life_component.is_dead: return
	
	# Add target
	targets.append(body)


func _on_body_exited(body: Node3D):
	if body.is_in_group(target_group):
		targets.erase(body)
		if body == current_target:
			current_target = null


func _on_entity_died(entity: Node3D):
	if entity.is_in_group(target_group):
		targets.erase(entity)
		if entity == current_target:
			current_target = null


func is_attacking() -> bool:
	var cooldown_rate = cooldown / interval
	return cooldown_rate >= 0.5
