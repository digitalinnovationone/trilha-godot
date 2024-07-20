extends PhysicsBody3D


@export var attack_module: AttackModule
@export var movement_module: MovementModule
@export var wand_type: WandType

var hit_cooldown: float = 0
var hit_freeze_time: float = 0.5


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.entity_died.connect(_on_entity_died)
	Events.health_changed.connect(_on_health_changed)
	if wand_type:
		Events.wand_equipped.emit(self, wand_type)


func _on_entity_died(entity):
	if entity != self: return
	
	# Cancelar módulos quando o enemy morrer
	if attack_module:
		attack_module.queue_free()
		attack_module = null
	if movement_module:
		movement_module.queue_free()
		movement_module = null
	
	# Remover física
	collision_layer = 0
	collision_mask = 0
	
	# Desconectar listener
	Events.entity_died.disconnect(_on_entity_died)


func _on_health_changed(entity, health: int, old_health: int, max_health: int):
	if entity == self:
		if health < old_health:
			hit_cooldown = hit_freeze_time


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Atualizar cooldown
	hit_cooldown -= delta
	
	# Pausar o movimento durante o ataque
	if attack_module and movement_module:
		movement_module.paused = attack_module.is_attacking() or hit_cooldown > 0.0
