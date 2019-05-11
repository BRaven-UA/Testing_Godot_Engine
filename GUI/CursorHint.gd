extends Label

#var debug_rect: Rect2
#var debug_mouse: Rect2

func _process(delta: float) -> void:
	var mouse: Vector2 = get_viewport().get_mouse_position()
#	debug_rect = Rect2(mouse - Vector2(rect_size.x / 2, -20), rect_size)
#	debug_mouse = Rect2(mouse - Vector2(5, 5), Vector2(22, 27))
#	rect_global_position = Global.match_screen(debug_rect, debug_mouse)
	rect_global_position = Global.match_screen(Rect2(mouse - Vector2(rect_size.x / 2, -20), rect_size) \
			, Rect2(mouse - Vector2(5, 5), Vector2(22, 27)))
#	update()

#func _draw() -> void:
#	draw_rect(debug_rect, ColorN('Yellow', 0.25))
#	draw_rect(debug_mouse, ColorN('Red', 0.5))

func pop_up(new_text) -> void:
	text = new_text
	rect_size = Vector2()	# принуждаем включиться авторазмер
	visible = true
	set_process(true)

func hide() -> void:
	visible = false
	set_process(false)	# немного экономим производительность :)
#	debug_rect = Rect2()
#	debug_mouse = Rect2()