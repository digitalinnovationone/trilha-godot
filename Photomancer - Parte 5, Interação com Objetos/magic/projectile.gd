extends RigidBody3D

@export var impact_prefab: PackedScene
@onready var animation_player: AnimationPlayer = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node):
	animation_player.play("death")
	
	if impact_prefab:
		var impact = impact_prefab.instantiate()
		add_sibling(impact)
		impact.global_position = global_position

