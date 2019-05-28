extends Control

onready var main_node = get_tree().current_scene
onready var user_layer = main_node.find_node("UserLayer")
onready var lock_interface = find_node("LockInterface")

func _notification(what: int) -> void:
	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT and not OS.is_window_always_on_top():	# ставим на паузу, если окно игры потеряло фокус и не установлен режим поверх всех окон'
		visible = true

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		visible = !visible
		accept_event()
		if visible:
			warp_mouse($VBoxContainer.rect_global_position + Vector2($VBoxContainer.rect_size.x / 2, 20))

func _on_ESCMenu_visibility_changed():
	get_tree().paused = visible

func _on_ResumeGame_pressed() -> void:
	visible = false

func _on_LockInterface_toggled(button_pressed):
	if button_pressed:
		lock_interface.text = "Unlock interface"
		user_layer.edit_mode = false
	else:
		lock_interface.text = "Lock interface"
		user_layer.edit_mode = true
	
	visible = false

func _on_ExitButton_pressed() -> void:
	get_tree().quit()