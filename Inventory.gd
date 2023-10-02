class_name Inventory
extends Area2D

@export var interaction_distance: int = 200
@export var search_time: float = 2.0
@export var sprite: Sprite2D

var is_mouse_over_inventory: bool = false
var in_range: bool = false
var searched: bool = false

@onready var main: Main = get_tree().get_first_node_in_group("main")

var items = {}

func remove_item(id: String) -> void:
	items.erase(id)

func _ready():	
	var top_floor = global_position.y < 6000 
	var item_count = randi_range(0, 1) if not top_floor else randi_range(1, 3)
	
	if randi_range(1,5) == 1:
		items = ItemDB.roll_weapons(item_count)
	else:
		items = ItemDB.roll_armor(item_count)
	
	%SearchTimer.wait_time = search_time
	%SearchTimer.timeout.connect(_on_search_complete)
	
	%SearchProgressBar.max_value = search_time
	
	mouse_entered.connect(func(): is_mouse_over_inventory = true)
	mouse_exited.connect(func(): is_mouse_over_inventory = false)
	
	$Tooltips.global_rotation = 0

func _input(event):
	if event.is_action_pressed("interact") and is_mouse_over_inventory and in_range:
		if not searched:
			%SearchTimer.start()
		else:
			open_inventory()

func open_inventory():
	main.show_item_list(self, items.values())

func _on_search_complete():
	print("searched")
	searched = true
	open_inventory()

func _process(delta):
	%SearchProgressBar.visible = not %SearchTimer.is_stopped()
	%SearchProgressBar.value = search_time - %SearchTimer.time_left
	
	var outline_width = 0.0
	if is_mouse_over_inventory and not main.is_ui_active():
		outline_width = 2.0

	var shader: ShaderMaterial = sprite.material
	shader.set_shader_parameter("width", outline_width)

	var distance = main.player.worker.body.global_position.distance_to(global_position)
	in_range = distance < 400
	
	%SearchTooltip.visible = is_mouse_over_inventory and in_range and not searched and not main.is_ui_active()
	%FarTooltip.visible = is_mouse_over_inventory and not in_range and not main.is_ui_active()
	%OpenTooltip.visible = is_mouse_over_inventory and in_range and searched and not main.is_ui_active()

	if searched and not in_range:
		main.close_item_list(self)
