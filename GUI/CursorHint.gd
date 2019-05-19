extends Label

func _process(delta: float) -> void:
	var mouse: Vector2 = get_global_mouse_position()
	# корректируем текущее положение посказки на экране, чтобы не перекрывала курсор
	rect_global_position = Global.match_screen(Rect2(mouse - Vector2(rect_size.x / 2, -20), rect_size) \
			, Rect2(mouse - Vector2(5, 5), Vector2(22, 27)))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		text = ""	# если событие мыши никто из GUI-элементов не принял, очищаем подсказку