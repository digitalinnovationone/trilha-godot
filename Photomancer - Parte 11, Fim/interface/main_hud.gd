class_name MainHud extends Control


@onready var health_bar: TextureProgressBar = %HealthBar
@onready var health_label: Label = %HealthLabel


func set_health(health, max_health):
	health_bar.max_value = max_health
	health_bar.value = health
	health_label.text = "%d / %d" % [health, max_health]
