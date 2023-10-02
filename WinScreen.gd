extends CanvasLayer

func _ready():
	$Button.pressed.connect(func():
		get_tree().change_scene_to_file("res://menu.tscn")	
	)
