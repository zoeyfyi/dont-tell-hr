class_name Item
extends Button

@onready var main: Main = get_tree().get_first_node_in_group("main")

func populate_item(item: Dictionary) -> void:
	%TextureRect.texture = item["texture"]
	%Label.text = item["text"]
