class_name HurtBox
extends Area2D

var worker = null

signal hit(damage: int, pierce: bool)

func _ready():
	# find worker parent
	var node = get_parent()
	while not node.is_in_group("worker"):
		node = node.get_parent()
	worker = node
	
	area_entered.connect(func(area: Area2D):
		if worker == null or not area is HitBox:
			return
		if worker == area.worker:
			return	
		print(area, area.damage, area.pierce)
		hit.emit(area.damage, area.pierce)
		
		if area.get_parent() is Bullet:
			area.get_parent().queue_free()
	)
