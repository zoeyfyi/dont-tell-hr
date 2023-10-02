class_name ProfileButton
extends VBoxContainer

@onready var button: Button = $Button

func set_profile(i: int):
	$Button.icon = load("res://assets/profiles%d.png" % (i + 1))
	$MarginContainer/Label.text = Main.names[i]
