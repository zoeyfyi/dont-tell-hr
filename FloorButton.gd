class_name FloorButton
extends VBoxContainer

@onready var button = $Button

func set_floor(floor: int):
	$Button.text = "%d" % floor

func set_selected(count: int):
	if count == 0:
		$MarginContainer/Label.text = " "
	else:
		$MarginContainer/Label.text = "X".repeat(count)
