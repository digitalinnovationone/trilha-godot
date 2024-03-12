extends Node3D


@onready var area: Area3D = $Area3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


var triggered: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	area.body_entered.connect(on_body_entered)


func on_body_entered(body: Node3D):
	# Se o script já foi ativado, abortar missão
	if triggered: return
	
	# Checar se body é um player
	if not body.is_in_group("player"): return
	
	# Sucesso!
	
	# Desabilitar script
	triggered = true
	area.body_entered.disconnect(on_body_entered)
	
	# Tocar animação
	animation_player.play("appear")
