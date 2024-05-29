extends Interactable


@export var wand_type: WandType


func interact(player: Player):
	# Disparar evento
	Events.wand_equipped.emit(player, wand_type)
	
	# Destruir objeto
	queue_free()

