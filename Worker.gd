class_name Worker
extends Node2D

@export var walk_speed = 600.0
@export var run_speed = 1000.0
@export var attack_speed = 300.0
@export var acceleration = 2500.0
@export var friction = 1500.0

@export var is_ai: bool = true
@export var show_ui: bool = true

@export var max_health: int = 20
@onready var health = max_health

var max_speed = walk_speed
var look_at_point: Vector2 = Vector2.ZERO
var direction = Vector2.ZERO

@onready var main: Main = get_tree().get_first_node_in_group("main")
@onready var body: CharacterBody2D = %Body

@onready var agent: NavigationAgent2D = $Body/NavigationAgent2D
@onready var player: Player = get_tree().get_first_node_in_group("player")

var floor: int = -1

var slot_equipment_map: Dictionary = {
	Main.Slot.SLOT_HEAD: null,
	Main.Slot.SLOT_CHEST: null,
	Main.Slot.SLOT_LEG: null,
	Main.Slot.SLOT_SHOE: null,
	Main.Slot.SLOT_WEAPON: null,
}

enum State { STATE_ATTACK, STATE_ESCAPE }
var state = State.STATE_ATTACK
var attack_target

func is_in_shock():
	return not $ShockTimer.is_stopped()
	
func has_ranged_weapon():
	return slot_equipment_map[Main.Slot.SLOT_WEAPON] and (not slot_equipment_map[Main.Slot.SLOT_WEAPON].has("pierce") or not slot_equipment_map[Main.Slot.SLOT_WEAPON]["pierce"])

func _ready():
	$UI.visible = show_ui
	
	update_armor()
	update_health()
	
	$MistTimer.timeout.connect(func():
		if main and main.closed_floors[floor - 1]:
			health -= 1
			update_health()
	)
	
	$Body/HurtBox.hit.connect(func(damage: int, pierce: bool):
		if pierce:
			$ShockTimer.start()
			$Body/EffectAnimationPlayer.play("shock")
			health -= damage
		else:
			var slot_idx = randi_range(0, 3)
			var equipment = slot_equipment_map.values()[slot_idx]
			if not equipment:
				health -= damage
			else:
				if not equipment.has("damage"):
					equipment["damage"] = 0
				
				var armor = equipment["armor"]	
				armor -= equipment["damage"]
				armor = max(armor, 0)
				
				damage -= armor
				equipment["damage"] += damage
				if damage > 0:
					health -= damage
				
			
		update_health()
	)
	
	$ShockTimer.timeout.connect(func():
		$Body/EffectAnimationPlayer.play("RESET")
		if state == State.STATE_ATTACK:
			state = State.STATE_ESCAPE
			$EscapeTimer.start()
	)
	
	$EscapeTimer.timeout.connect(func():
		if state == State.STATE_ESCAPE:
			state = State.STATE_ATTACK	
	)
	
func _process(delta):
	if is_ai:
		# interact with anything in front of you
		if $Body/InteractionRayCast.is_colliding():
			var collider = $Body/InteractionRayCast.get_collider()
			if collider and collider.get_parent():
				var obj_pp = collider.get_parent().get_parent()
				if obj_pp:
					if obj_pp is Door:
						(obj_pp as Door).open_door(self)
					if obj_pp is Elevator:
						(obj_pp as Elevator).open_elevator()
		
		if state == State.STATE_ATTACK:
			if not attack_target:
				var workers = get_tree().get_nodes_in_group("worker")
				workers.erase(self)
				var min_distance: float = INF
				for worker in workers:
					if worker.is_in_shock():
						continue
					
					var distance = worker.body.global_position.distance_to(body.global_position)
					if distance < min_distance:
						attack_target = worker
						min_distance = distance
			
			if not attack_target:
				return
				
			var distance = attack_target.body.global_position.distance_to(body.global_position)
			if distance < 400.0 and has_ranged_weapon():
				look_at_point = attack_target.body.global_position
				var did_attack = attack(attack_target.body.global_position)
				if did_attack:
					agent.target_position = $Body.global_position + Vector2(randf_range(-100, 100), randf_range(-100, 100))
					direction = agent.get_next_path_position() - $Body.global_position
					direction = direction.normalized()
			elif distance < 200.0 and not has_ranged_weapon():
				agent.target_position = attack_target.body.global_position
				look_at_point = attack_target.body.global_position
				attack(attack_target.body.global_position)
				attack_target = null
			else:
				agent.target_position = attack_target.body.global_position
				direction = agent.get_next_path_position() - $Body.global_position
				direction = direction.normalized()
				look_at_point = $Body.global_position + direction * 100.0
		elif state == State.STATE_ESCAPE:
			var workers_in_range = []
			var workers = get_tree().get_nodes_in_group("worker")
			workers.erase(self)
			
			# find all workers in range	
			for worker in workers:
				var distance = worker.body.global_position.distance_to(body.global_position)
				if distance < 1000:
					workers_in_range.append(worker.body.global_position)
				
			if workers_in_range.size() == 0:
				return
				
			# avg positions
			var avg_position = Vector2.ZERO
			for pos in workers_in_range:
				avg_position += pos
			avg_position /= workers_in_range.size()
			
			var danger_direction = avg_position - body.global_position
			direction = -danger_direction
			look_at_point = $Body.global_position + direction * 100.0
					
				
func _physics_process(delta):
	var target_speed = walk_speed
	if Input.is_action_pressed("run"):
		target_speed = run_speed
	if Input.is_action_pressed("click"):
		target_speed = attack_speed
	
	# move max speed towards target, i.e. smooth movement when going from run to walk
	if max_speed > target_speed:
		max_speed -= friction * delta
	else:
		max_speed = target_speed
	
	$Body.look_at(look_at_point)
	$Body/RightHandSprite.global_rotation = ($Body/RightHandSprite.global_position - look_at_point).angle() - deg_to_rad(90.0)
	
	#.- rad_to_deg(90.0)
	#/RightHandSprite
		
	if direction == Vector2.ZERO:
		if $Body.velocity.length() > (friction * delta):
			$Body.velocity -= $Body.velocity.normalized() * friction * delta
		else:
			$Body.velocity = Vector2.ZERO
	else:
		$Body.velocity += direction * acceleration * delta
	
	$Body.velocity = $Body.velocity.limit_length(max_speed)
	
	if not $ShockTimer.is_stopped():
		$Body.velocity = Vector2.ZERO
		
	if $Body.velocity.length() > 0:
		if not $Body/ActionAnimationPlayer.is_playing():
			$Body/ActionAnimationPlayer.play("run")
		if $Body/ActionAnimationPlayer.current_animation == "run":
			$Body/ActionAnimationPlayer.speed_scale = $Body.velocity.length() / walk_speed
	elif $Body.velocity.length() == 0 and $Body/ActionAnimationPlayer.current_animation == "run":
		$Body/ActionAnimationPlayer.play("RESET")
		
	if $Body.velocity.length() > 0:
		if not $Body/RunAudioPlayer.playing:
			$Body/RunAudioPlayer.playing = true
		$Body/RunAudioPlayer.pitch_scale = 1.2 * ($Body.velocity.length() / run_speed)
	else:
		$Body/RunAudioPlayer.playing = false
		
	$Body.move_and_slide()
	
	$UI.global_position = $Body.global_position
	
	
func equip_item(item: Dictionary) -> void:
	var slot = item["slot"]
	slot_equipment_map[slot] = item
	update_armor()
	
	if slot == main.Slot.SLOT_WEAPON and item.has("scene"):
		var weapon_scene: PackedScene = load(item["scene"]) as PackedScene
		var weapon = weapon_scene.instantiate()
	
		for child in %Weapon.get_children():
			%Weapon.remove_child(child)
		%Weapon.add_child(weapon)

func update_armor() -> void:
	var armor = 0
	var effective = 0
	for item in slot_equipment_map.values():
		if item and item.has("armor"):
			armor += item["armor"]
			var damage = 0
			if item.has("damage"):
				damage = item["damage"]
			effective += max(item["armor"] - damage, 0)
			
	%ArmorBar.max_value = armor
	%ArmorBar.value = effective
	
func update_health() -> void:
	if health <= 0:
		if self == player.worker:
			get_tree().change_scene_to_file("res://LoseScreen.tscn")
		else:
			queue_free()
	
	%HealthBar.max_value = max_health
	%HealthBar.value = health

func attack(target: Vector2) -> bool:
	if %Weapon.get_children().size() == 0: return false
	var weapon = %Weapon.get_child(0)
	if not weapon: return false
	var did_attack = weapon.attack(target)
	if weapon and did_attack: 
		$Body/ActionAnimationPlayer.speed_scale = 1.0
		$Body/ActionAnimationPlayer.play(weapon.attack_animation())
	return did_attack
	
