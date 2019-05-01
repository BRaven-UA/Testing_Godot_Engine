extends Button

var UID	# уникальный код для кнопки
var bind_to	# ссылка на прдставляемый кнопкой объект
var action	# текущее действие
var main_action	# действие по нажатию кнопки
var action_list = []	# список действий для меню кнопки
var edit_mode = false setget _set_edit_mode	# флаг режима редактирования

func _set_edit_mode(new_value):	# setter for edit_mode
	$ResizeCorner.visible = new_value
	$CloseCorner.visible = new_value
	disabled = new_value
	mouse_default_cursor_shape = Control.CURSOR_MOVE if new_value else Control.CURSOR_ARROW
	edit_mode = new_value

func _on_ResizeCorner_gui_input(ev):	# изменение размеров кнопки
	if ev is InputEventMouseMotion and Input.get_mouse_button_mask() == 1:
		rect_size += ev.relative
		accept_event()

func _on_CloseCorner_pressed():	# удаление кнопки
	queue_free()

func _on_UserButton_mouse_entered():	# курсор мыши над кнопкой
#	$Background.visible = true
	$Border.visible = true

func _on_UserButton_mouse_exited():	# курсор мыши не над кнопкой
#	$Background.visible = false
	$Border.visible = false

func _on_UserButton_gui_input(ev):	# основной обработчик ввода кнопки
	# передвижение кнопки в режиме редактирования
	if ev is InputEventMouseMotion and Input.get_mouse_button_mask() == 1 and edit_mode:
		raise()	# делаем кнопку последней в списке (поверх всех остальных)
		rect_position += ev.relative
	# вызов контекстного меню по правой кнопке
	if ev is InputEventMouseButton and ev.button_index == BUTTON_RIGHT and ev.pressed and !edit_mode:
		# добавить позиционирование для разных частей экрана
		$Menu.visible = true

func _on_Picture_gui_input() -> void:
	print(name, "'s picture is pressed")