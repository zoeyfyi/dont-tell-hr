class_name BBGun
extends Node2D

var bullet_scene: PackedScene = preload("res://Bullet.tscn")

var worker = null

func _ready():
	var node = get_parent()
	while not node.is_in_group("worker"):
		node = node.get_parent()
	worker = node

func attack(target: Vector2) -> bool:
	if not $CooldownTimer.is_stopped():
		return false
	$CooldownTimer.start()
	var bullet = bullet_scene.instantiate()
	get_tree().get_first_node_in_group("root").add_child(bullet)
	bullet.get_child(1).worker = worker
	bullet.global_position = $Barrel.global_position
	bullet.look_at(target)
	
	$AudioStreamPlayer2D.play()
	return true	

func attack_animation() -> String:
	return "shoot"
