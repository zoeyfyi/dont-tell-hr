class_name Door
extends Node2D

@export var interaction_distance: int = 200

@onready var main: Main = get_tree().get_first_node_in_group("main")

var is_mouse_over_door: bool = false
var is_open = false
var in_range: bool = false
var tween: Tween = null

const tooltip_open_door = "[center]Open door [b][color=yellow][lb]E[rb][/color][/b][/center]"
const tooltip_to_far = "[center]to far[/center]"

func _ready():
	%InteractArea.mouse_entered.connect(func(): is_mouse_over_door = true)
	%InteractArea.mouse_exited.connect(func(): is_mouse_over_door = false)

func _process(delta):
	var outline_width = 0.0
	if is_mouse_over_door and not main.is_ui_active():
		outline_width = 1.0
	
	var shader: ShaderMaterial = %DoorBody/Sprite2D.material
	shader.set_shader_parameter("width", outline_width)

	var distance = main.player.worker.body.global_position.distance_to(global_position)
	in_range = distance < interaction_distance
	
	%OpenTooltip.visible = is_mouse_over_door and in_range and not is_open and not main.is_ui_active()
	%CloseTooltip.visible = is_mouse_over_door and in_range and is_open and not main.is_ui_active()
	%FarTooltip.visible = is_mouse_over_door and not in_range and not main.is_ui_active()
	
func _input(event):
	if event.is_action_pressed("interact") and is_mouse_over_door and in_range:
		print("player opening door")
		open_door(main.player.worker)
		
func open_door(worker: Worker):
	if tween and tween.is_running():
		return
	
	var inward_distance = %InwardArea.global_position.distance_to(worker.body.global_position)
	var outward_distance = %OutwardArea.global_position.distance_to(worker.body.global_position)
	
	var final_rotation = 0.0
	if not is_open and inward_distance < outward_distance:
		final_rotation = -90.0
	elif not is_open and inward_distance > outward_distance:
		final_rotation = 90.0
		
	is_open = not is_open
	
	tween = create_tween()
	tween.tween_property(%Pivot, "rotation", deg_to_rad(final_rotation), 0.5).set_trans(Tween.TRANS_CUBIC)

