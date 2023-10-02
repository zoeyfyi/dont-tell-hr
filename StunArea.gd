class_name HitBox
extends Area2D

@export var damage: int = 1
@export var pierce: bool = false

var worker = null

func _ready():
	var node = get_parent()
	if node:
		while node and not node.is_in_group("worker"):
			node = node.get_parent()		
		worker = node
