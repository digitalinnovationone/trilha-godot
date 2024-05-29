extends Interactable


var is_open: bool = false
@onready var animation_player = $AnimationPlayer
@export var navigation_link: NavigationLink3D


func interact(player: Player):
	is_open = not is_open
	
	# Tocar animação
	var animation_name = "open" if is_open else "close"
	animation_player.play(animation_name)
	
	# Habilitar ou desabilitar link de navegação
	if navigation_link:
		navigation_link.enabled = is_open
