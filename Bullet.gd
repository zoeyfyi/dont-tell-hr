class_name Bullet
extends Node2D

func _process(delta):
	var velocity = Vector2.RIGHT.rotated(global_rotation) * delta * 1200
	global_position += velocity
	
	
