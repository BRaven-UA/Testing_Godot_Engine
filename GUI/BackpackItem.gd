# представление предмета из инвентаря для отображения в рюкзаке
extends TextureRect

const default_scale = Vector2(0.2, 0.2)
const Item = preload("res://Item.gd")	# чтобы иметь возможность указать класс предмета (сделано только ради облегчения работы в редакторе)
onready var main_node = get_tree().current_scene
onready var parent = get_parent()
var origin: Item	# ссылка на оригинальный предмет
var drag = false	# признак процесса перетаскивания

func _ready() -> void:
	name = origin.name
	connect("mouse_entered", main_node, "mouseover", [self, true])
	connect("mouse_exited", main_node, "mouseover", [self, false])
	rect_scale = default_scale
	rect_pivot_offset = rect_size / 2	# устанавливаем точку изменения размера объекта при масштабировании на его центр
	_from_displayed_rect(Vector2())	# устанавливаем начальную позицию с учетом масштаба объекта

func _displayed_rect():	# отображаемый прямоугольник предмета с учетом масштаба
	return Rect2(rect_position - rect_size * rect_scale / 2 + rect_pivot_offset, rect_size * rect_scale)

func _from_displayed_rect(v2):	# изменение реальной позиции предмета по позиции его отображаемого прямоугольника
	rect_position = v2 - rect_pivot_offset + rect_size * rect_scale / 2

func remove() -> void:
	emit_signal("mouse_exited")	# для скрытия тултипа
	queue_free()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_mask == 1:	# если нажата ТОЛЬКО левая кнопка мыши - поднимаем предмет
			drag = true
			emit_signal("mouse_exited")	# для скрытия тултипа
			raise()
			use_parent_material = true	# отключаем шейдер
			rect_scale = Vector2(1, 1)	# временно показываем изображение предмета в оригинальном масштабе, чтобы можно было хорошо его рассмотреть
		if event.button_mask & 1 == 0:	# если левая кнопка отжата - опускаем
			drag = false
			use_parent_material = false
			rect_scale = default_scale
			# корректируем положение предмета с учетом размеров рюкзака
			var rect = _displayed_rect()
			rect.position.x = max(0, rect.position.x)
			rect.position.y = max(0, rect.position.y)
			if rect.end.x > parent.rect_size.x: rect.position.x = parent.rect_size.x - rect.size.x
			if rect.end.y > parent.rect_size.y: rect.position.y = parent.rect_size.y - rect.size.y
			_from_displayed_rect(rect.position)
			emit_signal("mouse_entered")	# сразу же показываем тултип

	if event is InputEventMouseMotion and drag:
		rect_position += event.relative