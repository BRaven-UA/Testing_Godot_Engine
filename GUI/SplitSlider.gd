# панель для разделения объекта на несколько частей
extends MarginContainer

onready var slider = find_node("Slider")
onready var line_edit = find_node("Current")
#onready var min_value = find_node("Min")
onready var max_value = find_node("Max")
onready var accept_button = find_node("Accept")
var linked_object	# ссылка на объект, который разделяем
var action	# действие, выполняемое при подтверджении разделения
var is_over_menu: bool	# флаг расположения этого узла поверх элемента меню, когда узел должен скрываться если мышь не над ним

func _ready() -> void:
	max_value.text = str(linked_object.quantity)
	slider.max_value = linked_object.quantity - 1

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_over_menu and not line_edit.has_focus() and not slider.has_focus():	# скрываем если это часть меню и мышь за пределами панели, но не когда происходит редактирование значения
		if !get_global_rect().has_point(get_global_mouse_position()):
			visible = false
	
	if event is InputEventMouseButton and visible:	# проверям клики мышью за пределами меню
		if !get_global_rect().has_point(get_global_mouse_position()):
			queue_free()

func _on_Accept_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		accept_button.use_parent_material = false

func _on_Accept_mouse_exited() -> void:
	accept_button.use_parent_material = true

func _on_Slider_value_changed(value: float) -> void:
	if slider.has_focus():	# чтобы не срабатывало на ввод в line_edit
		line_edit.text = str(value)

func _on_Current_focus_entered() -> void:
	line_edit.select_all()

func _on_Current_text_changed(new_text: String) -> void:
	var caret_pos = line_edit.caret_position
	line_edit.text = str(clamp(int(new_text), 1, int(max_value.text) - 1))	# отсекаем не числовые значения и выходящие за рамки диапазона
	line_edit.caret_position = caret_pos	# восстанавливаем положение курсора
	slider.value = int(new_text)

func _accepted(new_text) -> void:
	action.Arguments.append(int(line_edit.text))
	MessageBus.send(self, "ContextMenu", ["pressed", action], 0)
