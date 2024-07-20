extends Node

@onready var press_any_button_label = %PressAnyButtonLabel

var listening = true


func _input(event):
	if not listening:
		return
	
	if event is InputEventKey:
		if event.pressed:
			press_any_button_label.visible = false
			SceneManager.transition_to("res://game.tscn")
