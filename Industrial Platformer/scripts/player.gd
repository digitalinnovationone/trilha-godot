extends CharacterBody2D


@export var speed = 3.0
@export_range(0, 1) var lerp_factor = 0.5

@onready var sprite = %Sprite


func _physics_process(delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var target_velocity = direction * speed * 100.0
	velocity = lerp(velocity, target_velocity, lerp_factor)
	move_and_slide()
	
	var target_rotation = direction.x * 45.0
	sprite.rotation_degrees = lerp(sprite.rotation_degrees, target_rotation, lerp_factor)
