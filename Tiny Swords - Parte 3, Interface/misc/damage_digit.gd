extends Node2D

@export var value: int = 0

func _ready():
	%Label.text = str(value)
