class_name Player extends CharacterBody3D

@export_category("Player")
@export_range(1, 35, 1) var speed: float = 10 # m/s
@export_range(10, 400, 1) var acceleration: float = 100 # m/s^2

@export_range(0.1, 3.0, 0.1) var jump_height: float = 1 # m
@export_range(0.1, 3.0, 0.1, "or_greater") var camera_sens: float = 1

var jumping: bool = false
var mouse_captured: bool = false

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var move_dir: Vector2 # Input direction for movement
var look_dir: Vector2 # Input direction for look/aim

var walk_vel: Vector3 # Walking velocity 
var grav_vel: Vector3 # Gravity velocity 
var jump_vel: Vector3 # Jumping velocity

var movement_blend_position: Vector2

@onready var camera: Camera3D = $Camera
@onready var model_holder = $ModelHolder
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

@export_category("Modelo")
@export var model: Node3D
@onready var projectile_spawn_marker: Marker3D = model.get_node("%SpawnPosition")

# Parâmetros temporários do cajado
@export_category("Varinha Mágica")
var wand_cooldown: float = 0.0
@export var wand_type: WandType

@export_category("Outros")
@export var damage_flash_ui: Control
@onready var life_component = $LifeComponent

func _ready() -> void:
	capture_mouse()
	Events.health_changed.connect(_on_health_changed)
	if wand_type:
		Events.wand_equipped.emit(self, wand_type)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		if mouse_captured: _rotate_camera()
	if Input.is_action_just_pressed("jump"): jumping = true
	if Input.is_action_just_pressed("exit"): get_tree().quit()


func _process(delta):
	# Idle / Movement animation
	var blend_position = Vector2(move_dir.x, -move_dir.y)
	movement_blend_position = lerp(movement_blend_position, blend_position, 0.03)
	animation_tree.set("parameters/Movement/blend_position", movement_blend_position)
	
	# Shoot
	wand_cooldown -= delta
	if Input.is_action_pressed("shoot"): _shoot()
	
	# Soltar mouse
	if mouse_captured and is_dead():
		release_mouse()


func _physics_process(delta: float) -> void:
	if mouse_captured: _handle_joypad_camera_rotation(delta)
	velocity = _walk(delta) + _gravity(delta) + _jump(delta)
	move_and_slide()


func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false


func _rotate_camera(sens_mod: float = 1.0) -> void:
	if is_dead(): return
	camera.rotation.y -= look_dir.x * camera_sens * sens_mod
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod, -1.5, 1.5)
	model_holder.rotation.y = camera.rotation.y + PI
	model_holder.rotation.x = camera.rotation.x * -1


func _handle_joypad_camera_rotation(delta: float, sens_mod: float = 1.0) -> void:
	var joypad_dir: Vector2 = Input.get_vector("look_left","look_right","look_up","look_down")
	if joypad_dir.length() > 0:
		look_dir += joypad_dir * delta
		_rotate_camera(sens_mod)
		look_dir = Vector2.ZERO


func _walk(delta: float) -> Vector3:
	if is_dead(): return Vector3.ZERO
	move_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var speed_factor: float = 0.5 if move_dir.y > 0 else 1.0
	var _forward: Vector3 = camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	walk_vel = walk_vel.move_toward(walk_dir * speed * speed_factor * move_dir.length(), acceleration * delta)
	return walk_vel


func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel


func _jump(delta: float) -> Vector3:
	if is_dead(): return Vector3.ZERO
	
	if jumping:
		if is_on_floor(): jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
		jumping = false
		return jump_vel
	jump_vel = Vector3.ZERO if is_on_floor() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel


func _shoot() -> void:
	# Player morreu
	if is_dead(): return
	
	# Cooldown ainda não expirou
	if wand_cooldown > 0.0: return
	
	# Ignorar caso a gente não tenha um wand
	if not wand_type: return
		
	# Setar cooldown pro intervalo
	var fire_rate = wand_type.fire_rate
	wand_cooldown = 60 / fire_rate

	# Animar player
	animation_state_machine.start("Spellcast")
	
	# Criar projétil
	var projectile: Projectile = wand_type.projectile.instantiate()
	projectile.damage = wand_type.damage
	projectile.add_collision_exception_with(self)
	add_sibling(projectile)
	projectile.global_position = projectile_spawn_marker.global_position
	projectile.linear_velocity = camera.global_transform.basis * Vector3(0, 0, -wand_type.shooting_speed)


func _on_health_changed(entity, health, old_health, max_health):
	if entity == self:
		if health < old_health:
			if is_alive():
				var damage_flash_anim: AnimationPlayer = damage_flash_ui.get_node("AnimationPlayer")
				damage_flash_anim.play("hit")


func is_dead() -> bool:
	return life_component.is_dead


func is_alive() -> bool:
	return not is_dead()
