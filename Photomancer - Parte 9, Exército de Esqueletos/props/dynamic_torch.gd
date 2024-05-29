@tool
extends Node

@export_range(0, 50, 0.1, "or_greater") var range: float = 5:
	set(new_range):
		range = new_range
		light.omni_range = range

@export var color: Color = Color.WHITE:
	set(new_color):
		color = new_color
		light.light_color = color

@export_range(0, 16, 0.1, "or_greater") var energy: float = 1:
	set(new_energy):
		energy = new_energy
		light.light_energy = energy

@export_category("Internals")
@export var light: OmniLight3D
