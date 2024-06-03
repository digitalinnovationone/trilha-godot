extends MovementModule


@export_group("Setup")
@export var area: Area3D
@export var target_group: String = "friendly"
@export var scan_interval: float = 2
@export var alert_time: float = 5
@export var agent: NavigationAgent3D
@export_range(10, 400, 1) var acceleration: float = 50 # m/s^2

var targets: Array[Node3D] = []
var scan_cooldown: float = 0
var alert_cooldown: float = 0
var current_target: Node3D
var walk_vel: Vector3 # Walking velocity 


# Called when the node enters the scene tree for the first time.
func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	Events.entity_died.connect(_on_entity_died)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Update alert
	if current_target:
		alert_cooldown = alert_time
	else:
		alert_cooldown -= delta
	
	# Scan target
	scan_cooldown -= delta
	if scan_cooldown <= 0.0:
		if _is_alert():
			scan_cooldown = scan_interval * 0.1
		else:
			scan_cooldown = scan_interval
		_scan()

	# Move entity
	if not agent.is_navigation_finished():
		var entity = get_parent()
		var current_position = entity.global_position
		var next_position = agent.get_next_path_position()
		if not paused:
			var walk_dir = (next_position - current_position).normalized()
			walk_vel = walk_vel.move_toward(walk_dir * speed, acceleration * delta)
			entity.global_position += walk_dir * speed * delta
		
		# Look at
		var offset = next_position - current_position
		offset.y = 0
		if not offset.is_zero_approx():
			var future_transform = entity.transform.looking_at(entity.global_position - offset, Vector3.UP)
			entity.transform = entity.transform.interpolate_with(future_transform, 0.1)


func _is_alert():
	return current_target != null or alert_cooldown > 0.0


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
			if is_path_free or closest_target == current_target:
				closest_target = target
				closest_distance = distance
	
	# Definir novo target
	current_target = closest_target
	
	# Tentar seguir
	_update_target_position()


func _update_target_position():
	var navigation_map = get_parent().get_world_3d().navigation_map
	if current_target:
		var destination = NavigationServer3D.map_get_closest_point(navigation_map, current_target.global_position)
		agent.target_position = destination


func _on_body_entered(body: Node3D):
	if body.is_in_group(target_group):
		var is_alive = true
		if body.has_node("LifeComponent"):
			var life_component: LifeComponent = body.get_node("LifeComponent")
			is_alive = not life_component.is_dead
		if is_alive:
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
