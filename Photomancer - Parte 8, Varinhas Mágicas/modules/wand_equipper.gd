extends Node


@export var attachment: BoneAttachment3D
var wand_model: Node3D


func _ready():
	Events.wand_equipped.connect(_on_wand_equipped)


func _on_wand_equipped(entity: Node3D, wand_type: WandType):
	# Ignorar outras entidades
	if entity != get_parent(): return
	
	# Destruir cajado atual
	if wand_model:
		wand_model.queue_free()
		wand_model = null
	
	# Criar novo cajado
	var wand_model_prefab = wand_type.wand_model
	if wand_model_prefab:
		wand_model = wand_type.wand_model.instantiate()
		attachment.add_child(wand_model)
	
	# Setar "wand_type"
	if "wand_type" in entity:
		entity.wand_type = wand_type
