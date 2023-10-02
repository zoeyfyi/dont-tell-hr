extends Node2D

func _ready():
	%EmailButton.pressed.connect(func():
		$EmailAnimationPlayer.play("pop_in")
	)
	
	%Email.pressed.connect(func():
		$EmailAnimationPlayer.play_backwards("pop_in")
		$EmailAnimationPlayer.animation_finished.connect(func(name):
			get_tree().change_scene_to_file("res://FloorSelect.tscn")
		)
	)
	
	for w in $Workers.get_children():
		var worker = w as Worker
		worker.equip_item(ItemDB.StunPen)
