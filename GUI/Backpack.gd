extends Control

#const Item = preload("res://Item.gd")	# чтобы иметь возможность указать класс предмета (сделано только ради облегчения работы в редакторе)
#onready var main_node = get_tree().current_scene
#onready var inventory = main_node.find_node("Player").get_node("Inventory")
#onready var content = find_node("Content")
#var drag = false


#func refresh_content():	# обновление содержимого рюкзака
#	var backpack_items = content.get_children()
#	var items = inventory.get_children()

#	for i in items:
#		var item: Item = i	# чтобы иметь возможность указать класс предмета (сделано только ради облегчения работы в редакторе)
#		if item.equiped: break	# экипированное снаряжение не должно отображаться в рюкзаке
#		var current

#		for b in backpack_items:
#			if item.uid == b.get_meta("data").uid:	# найдено соответсвие
#				current = b
#				backpack_items.erase(b)	# исключаем из дальнейшего поиска
#				break

#		if !current:
#			current = Preloader.get_resource("BackpackItem").instance()
#			content.add_child(current, true)
#			current.set_meta("is_new", true)
#			current.connect("mouse_entered", main_node, "mouseover", [current, true])
#			current.connect("mouse_exited", main_node, "mouseover", [current, false])
#			current.connect("gui_input", self, "_on_BackpackItem_gui_input", [current])

		# допилить!


#		current.set_meta("data", Global.get_variables(item))
#		var name = item.Name
#		if item.has("Quantity"):
#			if item.Quantity > 1: name += "_numerous"
#		current.texture = load("res://tiles/items/%s.png" % name)
#		current.texture = item.texture
#		current.rect_pivot_offset = current.rect_size / 2
#
#		if current.get_meta("is_new"):	# задержка в инициализации control-объекта
#			current.visible = false
#			if current.rect_size:	# инициализация пройдена
#				BackpackItem_from_displayed_rect(current, Vector2())
#				current.set_meta("is_new", false)
#				current.visible = true

#		if !drag:
#			var rect = BackpackItem_displayed_rect(current)
#			rect.position.x = max(0, rect.position.x)
#			rect.position.y = max(0, rect.position.y)
#			if rect.end.x > content.rect_size.x: rect.position.x = content.rect_size.x - rect.size.x
#			if rect.end.y > content.rect_size.y: rect.position.y = content.rect_size.y - rect.size.y
#			BackpackItem_from_displayed_rect(current, rect.position)

#	for b in backpack_items:	# объекты рюкзака, для которых не нашлось соответствия среди предметов
#		b.queue_free()

#func BackpackItem_displayed_rect(object):	# отображаемый прямоугольник предмета с учетом масштаба
#	return Rect2(object.rect_position - object.rect_size * object.rect_scale / 2 + object.rect_pivot_offset, object.rect_size * object.rect_scale)
#
#func BackpackItem_from_displayed_rect(object, v2):	# изменение реальной позиции предмета по позиции его отображаемого прямоугольника
#	object.rect_position = v2 - object.rect_pivot_offset + object.rect_size * object.rect_scale / 2

func _on_HSlider_gui_input(ev):
	if ev is InputEventMouseMotion and Input.get_mouse_button_mask() == 1:
		$Main.rect_size.y += ev.relative.y

func _on_VSlider_gui_input(ev):
	if ev is InputEventMouseMotion and Input.get_mouse_button_mask() == 1:
		$Main.rect_size.x += ev.relative.x

func _on_Control_gui_input(ev):
	if ev is InputEventMouseMotion and Input.get_mouse_button_mask() == 1:
		$Main.rect_size += ev.relative

func _on_Main_gui_input(ev):
	if ev is InputEventMouseMotion and Input.get_mouse_button_mask() == 1:
		var rect = $Main.get_global_rect().grow(-20)
		if rect.has_point(ev.global_position - ev.relative):
			rect_position += ev.relative
			$Main.accept_event()

#func _on_BackpackItem_gui_input(ev, object):
#	if ev is InputEventMouseButton:
#		if ev.button_mask == 1:	# если нажата ТОЛЬКО левая кнопка мыши - поднимаем предмет
#			drag = true
#			object.emit_signal("mouse_exited")	# для скрытия тултипа
#			object.raise()
#			object.use_parent_material = true
#			object.rect_scale = Vector2(1, 1)
#		if ev.button_mask & 1 == 0:	# если левая кнопка отжата - опускаем
#			drag = false
#			object.use_parent_material = false
#			object.rect_scale = Vector2(0.2, 0.2)
##			refresh_content()
#
#	if ev is InputEventMouseMotion and drag:
#		object.rect_position += ev.relative

#func _on_Backpack_visibility_changed():
#	if visible:
##		refresh_content()
#		$Refresh.start()	# обновление содержимого по таймеру
#	else: $Refresh.stop()