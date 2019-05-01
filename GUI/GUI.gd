extends CanvasLayer

func _input(event):
	if event.is_action_released("backpack"):
		var n = find_node("Backpack")
		n.visible = !n.visible