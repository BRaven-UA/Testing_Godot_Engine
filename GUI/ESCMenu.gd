extends Control

onready var main_node = get_tree().current_scene
onready var user_layer = main_node.find_node("UserLayer")
onready var lock_interface = find_node("LockInterface")

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		visible = !visible
		accept_event()

func _on_ESCMenu_visibility_changed():
	if visible:
		$ColorRect.visible = true
		get_tree().paused = true
	else:
		$ColorRect.visible = false
		get_tree().paused = false

func _on_LockInterface_toggled(button_pressed):
	if button_pressed:
		lock_interface.text = "Unlock interface"
		user_layer.edit_mode = false
	else:
		lock_interface.text = "Lock interface"
		user_layer.edit_mode = true
	
	visible = false