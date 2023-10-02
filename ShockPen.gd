class_name ShockPen
extends Node2D

func attack(target: Vector2) -> bool:
	if not $CooldownTimer.is_stopped():
		return false
	$CooldownTimer.start()
	$AnimationPlayer.play("jab")
	$AudioStreamPlayer2D.play()
	return true	

func attack_animation() -> String:
	return "jab"
