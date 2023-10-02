class_name Player
extends Node2D

var player_camera: PackedScene = preload("res://PlayerCamera.tscn")
@onready var worker: Worker = $Worker

func _ready():
	worker.body.add_child(player_camera.instantiate())

func _process(delta):
	worker.look_at_point = get_global_mouse_position()
	worker.direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if Input.is_action_pressed("click"):
		worker.attack(get_global_mouse_position())
