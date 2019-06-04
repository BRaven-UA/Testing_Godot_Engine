extends CanvasLayer

func _input(event):
	if event.is_action_released("backpack"):
		find_node("Backpack").toggle()
		get_tree().set_input_as_handled()