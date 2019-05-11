tool
extends Button

var user_layer
var context_menu
var cursor_hint
var player
const Item = preload("res://Item.gd")	# чтобы иметь возможность указать класс предмета (сделано только ради облегчения работы в редакторе)
#var UID	# уникальный код для кнопки
var linked_object	# ссылка на представляемый кнопкой объект
var main_action	# действие по нажатию кнопки
var action_list = []	# список действий для меню кнопки. Представляет собой массив словарей с полями: описание, вызываемый объект, вызываемый метод, аргументы вызова
var edit_mode = false setget _set_edit_mode	# флаг режима редактирования

func _ready() -> void:
	_update()
	if linked_object is Item:
#		$Picture.rect_size = rect_size * 0.8
		$Background.visible = true
		if linked_object.equiped:
			$Corners.visible = true

func _notification(what: int) -> void:
	if what > MessageBus.INDEX_OFFSET:	# если это не системное сообщение
		var message = MessageBus.receive(what)	# получаем данные о сообщении
		if message.Sender == linked_object:	# если это сообщение от связанного объекта
			match message.Content[0]:	# смотрим на содержание сообщения
				"equiped":
					$Corners.visible = message.Content[1]	# предмет изменил состояние экипированности
					_update()
				"quantity", "loaded", "attached_consumable":
					_update()
#					$Quantity.text = str(linked_object.loaded if linked_object.capacity else linked_object.quantity)
				"free":	# связанный объект удаляется
					linked_object = null
					queue_free()

func _set_edit_mode(new_value):	# setter for edit_mode
	if get_parent() == user_layer:	# только если кнопка в "свободной зоне", а не в каком-нибудь контейнере
		$ResizeCorner.visible = new_value
		$CloseCorner.visible = new_value
		disabled = new_value
		mouse_default_cursor_shape = Control.CURSOR_MOVE if new_value else Control.CURSOR_ARROW
		edit_mode = new_value

# создает список действий для кнопки, основываясь на свойствах связанного с ней объекта
func create_action_list() -> Array:
	var result: = []
	if linked_object.name == "Backpack":
		result.append({"Description": "Рюкзак", "Target": linked_object, "Method": "toggle", "Arguments": []})
	if linked_object.name == "TimeScale":
		result.append({"Description": "Скорость времени", "Target": linked_object, "Method": "toggle", "Arguments": []})
	if linked_object is Item:
		if linked_object.equiped: match linked_object.type:
			"Weapon": result.append({"Description": "Атаковать", "Target": user_layer, "Method": "_generate_action", "Arguments": ["action_01"]})
			"Tool": result.append({"Description": "Использовать", "Target": user_layer, "Method": "_generate_action", "Arguments": ["action_01"]})
		else: result.append({"Description": "Экипировать", "Target": player, "Method": "_set_equiped_weapon", "Arguments": [linked_object]})
		if linked_object.quantity > 1:
			# доделать интерфейс с вводом ползунка разделения и drag-and-drop отделенной части
			result.append({"Description": "Разделить", "Target": linked_object, "Method": "split", "Arguments": []})
		if linked_object.loaded < linked_object.capacity: result.append({"Description": "Перезарядить", "Target": linked_object, "Method": "reload", "Arguments": []})
		result.append({"Description": "Выбросить", "Target": user_layer, "Method": "_generate_action", "Arguments": ["drop_item"]} if linked_object.equiped else \
				{"Description": "Выбросить", "Target": linked_object, "Method": "drop", "Arguments": []})
	return result

func perform_action(action: Dictionary = main_action) -> void:	# вызывает метод у объекта. Ссылка на объект, название метода и его аргументы хранятся в словаре
	var r = action["Target"].callv(action["Method"], action["Arguments"])

func _update() -> void:
	if linked_object is Item:
		if linked_object.capacity:	# предмет имеет расходники
			$QuantityBar.max_value = linked_object.capacity
			$QuantityBar.value = linked_object.loaded
			$QuantityText.text = str(linked_object.loaded)
			$QuantityText/Consumable.texture = Preloader.get_resource(linked_object.attached_consumable.item_name \
					if linked_object.attached_consumable else linked_object.consumable_type)
#		else:	# предмет не имеет расходников
#			if linked_object.typr in ["Weapon", "Tool"]:
				
	action_list = create_action_list()
	main_action = action_list[0]
	cursor_hint.text = main_action["Description"]

func _on_ResizeCorner_gui_input(ev):	# изменение размеров кнопки
	if ev is InputEventMouseMotion and Input.get_mouse_button_mask() == 1:
		rect_size += ev.relative
		accept_event()

func _on_CloseCorner_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and Input.get_mouse_button_mask() == 1:
		queue_free()	# удаление кнопки

func _on_UserButton_mouse_entered():	# курсор мыши над кнопкой
#	$Background.visible = true
	$Border.visible = true
	cursor_hint.pop_up(main_action["Description"])

func _on_UserButton_mouse_exited():	# курсор мыши не над кнопкой
#	$Background.visible = false
	$Border.visible = false
	cursor_hint.hide()

func _on_UserButton_gui_input(ev):	# основной обработчик ввода кнопки
	# передвижение кнопки в режиме редактирования
	if ev is InputEventMouseMotion and Input.get_mouse_button_mask() == 1 and edit_mode:
		raise()	# делаем кнопку последней в списке (поверх всех остальных)
		rect_position += ev.relative
	# вызов контекстного меню по правой кнопке
	if ev is InputEventMouseButton and ev.button_index == BUTTON_RIGHT and ev.pressed and !edit_mode:
		context_menu.pop_up(self, action_list)