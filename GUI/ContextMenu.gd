extends MarginContainer

#const appear_duration := 0.5
#var start_time : int
#var final_alpha : float
var linked_object	# ссылка на объект, для которого сформировано это меню
onready var main_node = get_tree().current_scene
onready var cursor_hint = main_node.find_node("CursorHint")
#onready var user_layer = main_node.find_node("UserLayer")
onready var container = $VBoxContainer

func _notification(what: int) -> void:
	if what > MessageBus.INDEX_OFFSET:
		var message = MessageBus.receive(what)
		# нажат один из элементов меню, очищаем меню и применяем действие
		if message.Content[0] == "pressed":
			visible = false
#			appear(false)
			Global.perform_action(message.Content[1])

#func _process(delta: float) -> void:
#	var passed_time = (OS.get_ticks_msec() - start_time) / 1000.0
#	if passed_time < appear_duration:
#		modulate.a = lerp(float(!bool(final_alpha)), final_alpha, passed_time / appear_duration)
#	else:
#		modulate.a = final_alpha
#		if !final_alpha:
#			visible = false
#		set_process(false)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:	# проверям клики мышью за пределами меню
		if !get_global_rect().has_point(get_global_mouse_position()):
			visible = false
#			appear(false)

# формирует пункты меню для заданного объекта по заданному списку действий. Отображает меню на экране
func pop_up(object: Object, item_list: = []) -> void:
	if item_list.size() > 1:
		linked_object = object
#		cursor_hint.set_hint()
		
		for item in item_list:
			var line = Preloader.get_resource("ContextMenuItem").instance()
			line.action = item
			container.add_child(line, true)
			if item.Description == "Разделить":	# добавляем панель для разделения предметов, и скрываем ее
				var split = Preloader.get_resource("SplitSlider").instance()
				split.linked_object = linked_object
				split.action = item
				split.is_over_menu = true
				split.visible = false
				line.add_child(split, true)
		
		var mouse = get_global_mouse_position()
		rect_size = Vector2()
		rect_position = Global.match_screen(Rect2(mouse - Vector2(10, 10), rect_size))
#		appear(true)
		visible = true

#func appear(state: bool) -> void:
#	start_time = OS.get_ticks_msec()
#	final_alpha = float(state)
#	visible = true
#	set_process(true)

func _on_ContextMenu_hide() -> void:
	for line in container.get_children():
		line.free()