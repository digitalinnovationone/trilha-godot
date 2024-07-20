class_name LifeComponent extends Node


@export var health: int = 100: set = _set_health
var max_health: int = 100: set = _set_max_health
var is_dead: bool = false: set = _set_dead


func _ready():
	max_health = health


func _set_health(value):
	if is_dead: return
	var old_health = health
	health = clampi(value, 0, max_health)
	_on_health_changed(old_health)


func _set_max_health(value):
	if is_dead: return
	var old_health = health
	max_health = value
	if health > max_health: health = max_health
	_on_health_changed(old_health)


func _set_dead(value):
	is_dead = value
	if is_dead:
		Events.entity_died.emit(get_parent())


func _on_health_changed(old_health: int):
	Events.health_changed.emit(get_parent(), health, old_health, max_health)
	if health == 0: is_dead = true

