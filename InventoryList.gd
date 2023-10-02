class_name InventoryList
extends PanelContainer

var ItemScene: PackedScene = preload("res://Item.tscn")
@onready var main: Main = get_tree().get_first_node_in_group("main")

signal equip(item: Dictionary)

func populate_item_list(items: Array):
	for child in $VBoxContainer.get_children():
		$VBoxContainer.remove_child(child)
		child.queue_free()
	
	for item in items:
		var item_list_item = ItemScene.instantiate() as Button
		item_list_item.populate_item(item)
		item_list_item.pressed.connect(func(): 
			equip.emit(item)
			item_list_item.disabled = true
			item_list_item.queue_free()
		)
		$VBoxContainer.add_child(item_list_item)

func _input(event):
	if event.is_action_pressed("click"):
		var local_event: InputEventMouseButton = make_input_local(event) as InputEventMouseButton
		print(Rect2(Vector2.ZERO, size), ", ", local_event.position)
		if !Rect2(Vector2.ZERO, size).has_point(local_event.position):
			main.close_item_list(null)
	
