extends Camera3D

@onready var animation_player = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.game_over.connect(_on_game_over)


func _on_game_over(player: Node3D):
	animation_player.play("Death")
	Events.game_over.disconnect(_on_game_over)
