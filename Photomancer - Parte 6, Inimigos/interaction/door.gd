extends Interactable


var is_open: bool = false
@onready var animation_player = $AnimationPlayer


func interact():
	is_open = not is_open
	var animation_name = "open" if is_open else "close"
	animation_player.play(animation_name)
