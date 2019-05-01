extends Control

onready var main_node = get_tree().current_scene
var bind_to	# объект, к которому привязана эта информационная планка

func _ready():
	if !rect_global_position:	# для первой генерации, иначе берем значение из файла сохранения
		rect_global_position = bind_to.get_global_transform_with_canvas().origin	# размещаем планку на экране
		var plates = get_tree().get_nodes_in_group("Nameplates")
		plates.sort_custom(self, "sort_by_y")
		for obj in plates:
			if obj != self:	# исключаем себя из перебора
				var rect = obj.get_node("Label").get_global_rect().grow(1)
				if rect.intersects($Label.get_global_rect()):	# если текст накладывается на текст существующей планки...
					# корректируем его положение по вертикали
					$Label.rect_global_position.y = rect.position.y + rect.size.y if\
						rect.position.y < $Label.rect_global_position.y else rect.position.y - $Label.rect_size.y
	
	# подстраиваем линию под размеры и положение текстового поля
	$Line2D.points[1] = $Label.rect_position + Vector2(-1, $Label.rect_size.y + 1)
	$Line2D.points[2] = $Line2D.points[1] + Vector2($Label.rect_size.x + 3, 0)

	$Label.connect("mouse_entered", main_node, "mouseover", [bind_to, true])
	$Label.connect("mouse_exited", main_node, "mouseover", [bind_to, false])

func _process(delta):
	if Global.is_visible_to_player(bind_to):	# если предмет в пределах видимости
		# корректируем положение планки на экране в реальном времени
		rect_global_position = bind_to.get_global_transform_with_canvas().origin
		show()
	else: hide()

func _gui_input(event):
	if event is InputEventMouseButton:	# клик по планке
		var player = main_node.find_node("Player")
		if event.button_index == 1 and event.pressed and (bind_to.global_position - player.global_position).length() < 50:	# расстояние до предмета
			bind_to.move_to(player.get_node("Inventory"))

func sort_by_y (a, b):	# сортировка существующих планок по вертикали
	return a.get_node("Label").rect_global_position.y < b.get_node("Label").rect_global_position.y
#
#func _on_visibility_changed() -> void:
#	set_process(visible)