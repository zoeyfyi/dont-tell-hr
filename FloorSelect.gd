extends Node2D

var profile_button_scene: PackedScene = preload("res://ProfileButton.tscn")
var floor_button_scene: PackedScene = preload("res://FloorButton.tscn")

var selected_floors: Array = []

var player_character = -1
var player_floor = -1

func _ready():	
	for i in 20: 
		var button = profile_button_scene.instantiate() as ProfileButton
		%ProfileGrid.add_child(button)
		button.set_profile(i)
		button.button.pressed.connect(func():
			player_character = i
			for b in %ProfileGrid.get_children():
				b.button.disabled = true
			$AnimationPlayer.play("floor_select")
		)
		

	for i in 20:
		var button = floor_button_scene.instantiate() as FloorButton
		button.set_floor(i + 1)
		%FloorGrid.add_child(button)
		button.button.pressed.connect(func():
			player_floor = i + 1
			selected_floors[i] += 1
			for b in %FloorGrid.get_children():
				b.button.disabled = true
			select_floors()
		)
		
	%StartButton.pressed.connect(func():
		$AnimationPlayer.play("start")
		$AnimationPlayer.animation_finished.connect(func(name):
			Settings.selected_floors = selected_floors
			Settings.player_floor = player_floor
			get_tree().change_scene_to_file("res://Main.tscn")	
		)
	)
		
	selected_floors.resize(20)
	selected_floors.fill(0)
	updated_selected_floors()

func updated_selected_floors():
	var total = 0
	for i in 20:
		var b = %FloorGrid.get_child(i)
		b.set_selected(selected_floors[i])
		total += selected_floors[i]
		
	if total == 20:
		%StartButton.disabled = false
		%StartButton.text = "Start Game"

func select_floors():
	for i in 29:
		var wait_time = randf_range(0.1, 0.25)
		await get_tree().create_timer(wait_time).timeout
		
		var floor = -1
		if randi_range(1,2) == 1:
			# check if there is an empty floor
			var top_floors = range(0,5)
			top_floors.shuffle()
			for f in top_floors:
				if selected_floors[f] == 0:
					floor = f
					break
			
			# otherwise, pick a random one
			if floor == -1:
				floor = randi_range(0, 4)
		else:
			# check if there is an empty floor
			var bottom_floors = range(5,20)
			bottom_floors.shuffle()
			for f in bottom_floors:
				if selected_floors[f] == 0:
					floor = f
					break
			if floor == -1:
				floor = randi_range(5,19)
		
		selected_floors[floor] += 1
		updated_selected_floors()
		
