# представление предмета из инвентаря для отображения в рюкзаке
extends TextureRect

const default_scale = Vector2(0.2, 0.2)
const Item = preload("res://Item.gd")	# чтобы иметь возможность указать класс предмета (сделано только ради облегчения работы в редакторе)
onready var main_node = get_tree().current_scene
onready var parent = get_parent()
var linked_object: Item	# ссылка на оригинальный предмет
var drag = false	# признак процесса перетаскивания
var initial_position: Vector2	# начальная позиция при перетаскивании

func _ready() -> void:
	name = linked_object.name
	connect("mouse_entered", main_node, "mouseover", [self, true])
	connect("mouse_exited", main_node, "mouseover", [self, false])
	rect_scale = default_scale
	rect_pivot_offset = rect_size / 2	# устанавливаем точку изменения размера объекта при масштабировании на его центр
	_from_displayed_rect(Vector2())	# устанавливаем начальную позицию с учетом масштаба объекта

func _pick_up() -> void:	# поднимаем предмет, начинаем перетаскивание
	drag = true
	grab_focus()	# чтобы отслеживались нажатия клавиш (например, отмена)
	emit_signal("mouse_exited")	# для скрытия тултипа
	raise()
	use_parent_material = true	# отключаем шейдер
	initial_position = rect_position
	rect_scale = Vector2(1, 1)	# временно показываем изображение предмета в оригинальном масштабе, чтобы можно было хорошо его рассмотреть

func _put_down() -> void:	# опускаем предмет, заканчивая перетаскивание
	drag = false
	release_focus()
	use_parent_material = false
	rect_scale = default_scale

func _displayed_rect():	# отображаемый прямоугольник предмета с учетом масштаба
	return Rect2(rect_position - rect_size * rect_scale / 2 + rect_pivot_offset, rect_size * rect_scale)

func _from_displayed_rect(v2):	# изменение реальной позиции предмета по позиции его отображаемого прямоугольника
	rect_position = v2 - rect_pivot_offset + rect_size * rect_scale / 2

func remove() -> void:
	emit_signal("mouse_exited")	# для скрытия тултипа
	queue_free()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_mask == 1 and not drag:	# если нажата ТОЛЬКО левая кнопка мыши - поднимаем предмет
			_pick_up()
		if event.button_mask & 1 == 0 and drag:	# если левая кнопка отжата - опускаем
			_put_down()
			# если предмет находится за пределами рюкзака
			if find_parent("Main").get_global_rect().clip(get_global_rect()):
				# возвращаем предмет в рюкзак и корректируем положение предмета с учетом размеров рюкзака
				var rect = _displayed_rect()
				rect.position.x = max(0, rect.position.x)
				rect.position.y = max(0, rect.position.y)
				if rect.end.x > parent.rect_size.x: rect.position.x = parent.rect_size.x - rect.size.x
				if rect.end.y > parent.rect_size.y: rect.position.y = parent.rect_size.y - rect.size.y
				_from_displayed_rect(rect.position)
				initial_position = rect_position	# перетаскивание состоялось, запоминаем новую позицию
				emit_signal("mouse_entered")	# сразу же показываем тултип
			else:	# середина предмета за пределами рюкзака
				if Global.user_layer.edit_mode: 	# интерфейс пользователя разблокирован, создаем кнопку для предмета
					var area: String
					# проверяем все доступные контейнеры для кнопок
					for container in get_tree().get_nodes_in_group("ButtonContainer"):
						if container.get_global_rect().has_point(rect_global_position):
							area = container.name
					Global.user_layer.create_button(linked_object, linked_object.texture, area, rect_global_position)
					rect_position = initial_position
				else:	# выбрасываем предмет в игровой мир
					linked_object.drop()
					remove()
		if event.button_index == BUTTON_RIGHT and event.pressed and not drag:	# правая кнопка мыши - контекстное меню
			Global.context_menu.pop_up(linked_object, linked_object.create_action_list())

	if event is InputEventMouseMotion and drag:
		rect_position += event.relative
#		rect_global_position = Global.match_screen(Rect2(rect_global_position + event.relative, rect_size))
	
	if event.is_action_pressed("ui_cancel") and drag:	# отмена перетаскивания
		accept_event()
		rect_position = initial_position
		_put_down()