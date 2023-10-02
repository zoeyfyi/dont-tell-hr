class_name Elevator
extends Node2D

enum ElevatorDirection { UP, DOWN }

@export var direction: ElevatorDirection = ElevatorDirection.UP
@export_range(0, 2) var elevator_set: int = 0
@export_range(1, 20) var floor: int = 10

@onready var shader: ShaderMaterial = $Outline.material
@onready var main: Main = get_tree().get_first_node_in_group("main")

var is_mouse_over: bool = false
var is_open: bool = false
var in_range: bool = false
var should_open_door: bool = false

var locked_by = null

var target_elevator = null
var navigation_link: NavigationLink2D = null

func _is_locked() -> bool:
	return false
	return locked_by != null
	
func _set_lock(value: bool):
	return
	if value == true:
		locked_by = self
		target_elevator.locked_by = self
	else:
		locked_by = null
		for elevator in get_tree().get_nodes_in_group("elevator"):
			if elevator.locked_by == self:
				elevator.locked_by = null

func _teleport_players():
	if not target_elevator:
		return
		
	print("teleporting riders: ", get_riders())
		
	for worker in get_riders():
		worker.floor = target_elevator.floor
		var offset = worker.body.global_position - global_position
		worker.body.global_position = target_elevator.global_position + offset
		if worker == main.player.worker:
			get_viewport().get_camera_2d().reset_smoothing()

func _ready():
	$Arrow.global_rotation_degrees = 0.0 if direction == ElevatorDirection.UP else 180.0 
	$InteractionArea.mouse_entered.connect(func(): is_mouse_over = true)
	$InteractionArea.mouse_exited.connect(func(): is_mouse_over = false)
	$Timer.timeout.connect(_close_doors)
	
	%CallTooltip.rotation = -rotation
	%BusyTooltip.rotation = -rotation
	%FarTooltip.rotation = -rotation
	
	update_target_elevator()
	
	main.floors_closed.connect(func():
		update_target_elevator()
	)
	
func update_target_elevator():
	var target_floor = floor
	if direction == ElevatorDirection.UP:
		target_floor = floor + 1
	else:
		target_floor = floor - 1
	
	# skip closed floors
	if main.closed_floors.size() == 20:
		while target_floor < 20 and target_floor > 0 and main.closed_floors[target_floor-1]:
			if direction == ElevatorDirection.UP:
				target_floor += 1
			else:
				target_floor -= 1
	
	var target_direction = ElevatorDirection.UP
	if direction == ElevatorDirection.UP:
		target_direction = ElevatorDirection.DOWN
	else:
		target_direction = ElevatorDirection.UP
	
	var elevators = get_tree().get_nodes_in_group("elevator")
	for elevator in elevators:
		var e: Elevator = elevator as Elevator
		if e.direction == target_direction and e.floor == target_floor:
			target_elevator = elevator
			break
			
	if not target_elevator:
		return
		
	if navigation_link:
		navigation_link.queue_free()
		
	navigation_link = NavigationLink2D.new()
	navigation_link.set_global_start_position(global_position)
	navigation_link.set_global_end_position(target_elevator.global_position)
	navigation_link.bidirectional = false
	main.add_child.call_deferred(navigation_link)
	
	print("updated elevator link ", global_position, target_elevator.global_position)
	
func _process(delta):
	var width = 1.0 if target_elevator != null and is_mouse_over and not main.is_ui_active() and not is_open else 0.0
	shader.set_shader_parameter("width", width)
	
	var distance = main.player.worker.body.global_position.distance_to(position)
	in_range = distance < 1200
	
	%CallTooltip.visible = target_elevator != null and not _is_locked() and in_range and is_mouse_over
	%BusyTooltip.visible = target_elevator != null and _is_locked() and is_mouse_over
	%FarTooltip.visible = target_elevator != null and not _is_locked() and not in_range and is_mouse_over

func _input(event):
	if event.is_action_pressed("interact") and is_mouse_over and not is_open:
		open_elevator()
		
func open_elevator():
	if _is_locked(): return
	if target_elevator == null: return
	should_open_door = true
	_set_lock(true)
	_open_doors()
		
func _open_doors():
	var tween = create_tween()
	tween.tween_property($Void, "modulate", Color.TRANSPARENT, 2.0)
	tween.tween_property($LeftDoor, "scale", Vector2(0.0, 1.0), 1.0).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property($RightDoor, "scale", Vector2(0.0, 1.0), 1.0).set_trans(Tween.TRANS_CUBIC)
	tween.chain().tween_callback(func(): $Timer.start())
	is_open = true
	
# get everyone in the elevator
func get_riders() -> Array:
	var riders = []
	for body in $TeleportArea.get_overlapping_bodies():
		if body.get_parent() is Worker: 
			riders.append(body.get_parent())
	return riders
		
func _close_doors():
	var tween = create_tween()
	tween.tween_property($LeftDoor, "scale", Vector2.ONE, 1.0).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property($RightDoor, "scale", Vector2.ONE, 1.0).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(func(): 
		is_open = false
	)
	
	var elevator_workers = get_riders()
	var player_in_elevator: bool = elevator_workers.find(main.player.worker) != -1
	
	var workers = get_tree().get_nodes_in_group("worker")
	for w in elevator_workers: workers.erase(w) # remove everyone in elevator
	var elevators = get_tree().get_nodes_in_group("elevator")
	elevators.erase(self)
	elevators.erase(target_elevator)
	var map = get_tree().get_first_node_in_group("map")
	var objects = get_tree().get_first_node_in_group("objects")
	
	# fade world out
	if player_in_elevator:
		for worker in workers:
			tween.parallel().tween_property(worker, "modulate", Color.BLACK, 2.0)
		for elevator in elevators:
			tween.parallel().tween_property(elevator, "modulate", Color.BLACK, 2.0)
		tween.parallel().tween_property(map, "modulate", Color.BLACK, 2.0)
		tween.parallel().tween_property(objects, "modulate", Color.TRANSPARENT, 2.0)
	
	# open destination doors
	tween.parallel().tween_callback(func(): 
		if target_elevator and should_open_door: 
			target_elevator._open_doors()
		)

	tween.tween_callback(_teleport_players)
	tween.parallel().tween_property($Void, "modulate", Color.WHITE, 2.0)
	
	# fade world in
	if player_in_elevator:
		for worker in get_tree().get_nodes_in_group("worker"):
			tween.parallel().tween_property(worker, "modulate", Color.WHITE, 2.0)
		for elevator in get_tree().get_nodes_in_group("elevator"):
			tween.parallel().tween_property(elevator, "modulate", Color.WHITE, 2.0)
		tween.parallel().tween_property(map, "modulate", Color.WHITE, 2.0)
		tween.parallel().tween_property(objects, "modulate", Color.WHITE, 2.0)
		
	tween.tween_callback(func(): 
		if not should_open_door: _set_lock(false)
		should_open_door = false
	)
	
	
	
	
	
	
	
	
	
	
	
