extends PanelContainer

signal pressed

func _gui_input(event):
	if event is InputEventMouseButton:
		pressed.emit()
