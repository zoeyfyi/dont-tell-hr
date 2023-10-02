class_name Main
extends Node2D

signal floors_closed

var current_inventory: Node2D = null

enum Slot { SLOT_HEAD, SLOT_CHEST, SLOT_LEG, SLOT_SHOE, SLOT_WEAPON }

@onready var player: Player = get_tree().get_first_node_in_group("player")

@onready var slot_texture_map: Dictionary = {
	Slot.SLOT_HEAD: %HeadTexture,
	Slot.SLOT_CHEST: %ChestTexture,
	Slot.SLOT_LEG: %LegTexture,
	Slot.SLOT_SHOE: %ShoeTexture,
	Slot.SLOT_WEAPON: %WeaponTexture,
}

static var names: Array = [
	"James",
	"Rob",
	"John",
	"Mike",
	"Dave",
	"Will",
	"Richard",
	"Joe",
	"Tom",
	"Charles",
	"Mary",
	"Pat",
	"Jen",
	"Linda",
	"Liz",
	"Barbara",
	"Susan",
	"Jess",
	"Sarah",
	"Karen",
]

var player_scene: PackedScene = preload("res://Player.tscn")
var worker_scene: PackedScene = preload("res://Worker.tscn")

var worker_count = 0

var close_count = 1
var closed_floors: Array = []
var closing: Array = []

func _ready():
	closed_floors.resize(20)
	closed_floors.fill(false)
	
	close_floors()
	
	$CloseTimer.timeout.connect(func():
		close_floors()	
		floors_closed.emit()
	)
	
	Settings.selected_floors[Settings.player_floor - 1] -= 1
	
	var spawns = []
	spawns.resize(20)
	spawns.fill([])
	for floor in get_tree().get_nodes_in_group("floor"):
		var f = int(String(floor.name))
		spawns[f - 1] = floor.get_node("Spawns").get_children()
		spawns[f - 1].shuffle()
		
	var player_spawn = spawns[Settings.player_floor - 1].pop_back()
	
	player = player_scene.instantiate()
	player.position = player_spawn.global_position
	player.get_node("Worker").floor = Settings.player_floor
	%Entities.add_child(player)

	for f in 20:
		for w in Settings.selected_floors[f]:
			var worker = worker_scene.instantiate() as Worker
			var spawn = spawns[f].pop_back()
			if spawn == null: continue
			worker.position = spawn.global_position
			worker.floor = f
			%Entities.add_child(worker)

	for worker in get_tree().get_nodes_in_group("worker"):
		if worker == player.worker:
			equip_item(ItemDB.StunPen)
		else:
			worker.equip_item(ItemDB.StunPen if randi_range(1,2) == 1 else ItemDB.BBGun)
		
func close_floors():
	# close floors
	for f in closing:
		closed_floors[f] = true
	closing.clear()
	
	# find floors yet to close	
	var candidates = []
	for i in 20:
		if not closed_floors[i]: candidates.append(i)
	candidates.shuffle()
	
	var prev_close_count = close_count
	
	# add candidates to closing
	while candidates.size() > 0 and close_count > 0:
		closing.append(candidates.pop_back())
		close_count -= 1
		
	close_count = prev_close_count * 2
		
	closing.sort()
	
func show_item_list(inventory: Inventory, items: Array):
	current_inventory = inventory
	$InventoryList.global_position = inventory.global_position
	$InventoryList.global_position.x -= $InventoryList.size.x / 2.0
	($InventoryList as InventoryList).populate_item_list(items)
	$InventoryList.visible = true
	$InventoryList.equip.connect(func(item: Dictionary):
		inventory.remove_item(item["id"])
		equip_item(item)
	)
	
func equip_item(item: Dictionary):
	var slot = item["slot"]
	slot_texture_map[slot].texture = item["texture"]
	player.worker.equip_item(item)
	
func close_item_list(inventory: Node2D):
	if inventory == null or current_inventory == inventory:
		current_inventory = null
		$InventoryList.visible = false

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		close_item_list(null)

func is_ui_active():
	return current_inventory != null
	
func update_armor(value: int, total: int):
	%ArmorBar.max_value = total
	%ArmorBar.value = value
	%ArmorBar/ArmorLabel.text = "%d / %d" % [value, total]

func _process(delta):
	var new_worker_count = get_tree().get_nodes_in_group("worker").size()
	if new_worker_count != worker_count:
		worker_count = new_worker_count
		%PlayersRemaining.text = "[center][color=red]%d[/color] PLAYERS REMAINING[/center]" % worker_count
		
		if new_worker_count == 1:
			get_tree().change_scene_to_file("res://WinScreen.tscn")

	if closing.size() > 0:
		var floor_strings: PackedStringArray = []
		for f in closing: floor_strings.append("%d" % (f+1))
		%TimeLeft.text = "%d seconds until floor(s) %s close" % [$CloseTimer.time_left, ", ".join(floor_strings)]
	else:
		%TimeLeft.text = "All floor's closed, good luck!"

	%Floor.text = "Floor %d" % player.worker.floor

	$CanvasLayer/Mist.visible = closed_floors[player.worker.floor - 1]
