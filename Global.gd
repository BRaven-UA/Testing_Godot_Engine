extends Node2D

var debug_mode = false
var item_db = []
var save_dir = "res://saved game"
onready var main_node = get_tree().current_scene
onready var player = main_node.get_node("Player")
onready var debug = main_node.find_node("Debug")
onready var backpack_content = main_node.find_node("Backpack").find_node("Content")
onready var user_layer = main_node.find_node("UserLayer")
onready var surface = main_node.get_node("Surface")

func _init():
	if debug_mode: printt(OS.get_ticks_msec() / 1000.0, "Global init")
	
func _ready():
	var file = File.new()
	var error = file.open("res://item_db.json", file.READ)
	if error: prints("ERROR opening item database file: ", error)
#	item_db = JSON.parse(file.get_as_text()).result
	item_db = str2var(file.get_as_text())
	file.close()

	if debug_mode: printt(OS.get_ticks_msec() / 1000.0, "Global is ready")

func get_item_from_DB(name: String) -> Dictionary:	# поиск предмета в базе данных
	if name:
		for item in item_db.Database:
			if item.item_name == name: return item.duplicate()	# защита от случайного изменения в базе
	return {}

func create_item(data, destination: Node = null) -> bool:	# добавление уникальной копии предмета по имени или по словарю параметров в игровой мир
	if destination:
		var dict = data if data is Dictionary else get_item_from_DB(data)
		var new_item = Preloader.get_resource("Item").instance()
		for key in dict:
			new_item.set(key, dict[key])
	#	new_item.get_node("Sprite").texture = new_item.texture
		randomize()
		new_item.user_layer = user_layer
		new_item.surface = surface
		new_item.uid = OS.get_datetime()	# сохраняем время создания
		new_item.uid.RND = randf()	# добавляем случайное число чтобы избежать одинаковых UID для предметов, созданных с разницей во времени менее 1 сек.
		new_item.name = new_item.item_name + " " + String(new_item.uid.hash())	# даем предмету уникальное имя, включающее хэш его UID
		if !new_item.quantity: new_item.quantity = 1 	# нужно чтобы сработал setter
		destination.add_child(new_item, true)
		return new_item
	else: return false

func get_variables(object) -> Dictionary:	# возвращает словарь с именами переменных и их значениями
	var data: Dictionary = {}
	var variables_section: bool
	for p in object.get_property_list():
		if variables_section:
			data[p.name] = object.get(p.name)
		if p.usage == PROPERTY_USAGE_CATEGORY and variables_section: variables_section = false
		if p.name == "Script Variables": variables_section = true
	return data

func disconnect_all_signals(object: Object) -> void:
	for s in object.get_signal_list():	# список всех сигналов
		for c in object.get_signal_connection_list(s.name):	# список всех соединений сигнала
			object.disconnect(s.name, c.target, c.method)	# отключаем все соединения сигнала

func is_visible_to_player(object: Object) -> bool:	# объект в пределах видимости игрока
	if !object: return false
	var distance_to_player = (object.global_position - player.global_position).length()
	return distance_to_player < 1024 * player.sight_range

func closest_point(point_a, point_b, center = Vector2(), exclude_center = true):
	# возвращает ближайшую к центру точку. Если 'exclude_center' не задан, точки, совпадающие с центром игнорируются
#	var result
#	var a = (point_a - center).length()
#	var b = (point_b - center).length()
	var result = point_a if (point_a - center).length() < (point_b - center).length() else point_b
	if exclude_center and point_b == center:
		result = point_a 
	if exclude_center and point_a == center:
		result = point_b 
	return result

# Вычисляет оптимальное положение на экране для заданного прямоугольника, позволяющее ему оставаться полностью в пределах экрана
# Если задан второй параметр, будет также учитываться зона на экране, которую не будет задевать прямоугольник
# Если на экране нет места чтобы не было пересечения с "мертвой зоной", то она игнорируется
# Оба параметра задаются в глобальных координатах. Результат - новая позиция для прямоугольника
func match_screen(initial_rect: Rect2, dead_zone: = Rect2()) -> Vector2:
	var screen = get_viewport().get_visible_rect()
	var result = _match_rectangle(initial_rect, screen)
	
	if result.intersects(dead_zone):	# если исходный прямоугольник пересекает "мертвую зону"
		# определение четырех зон, в пределах которых нет пересечения с "мертвой зоной"
		var zones = [Rect2(0, 0, screen.size.x, dead_zone.position.y) \
				, Rect2(dead_zone.end.x, 0, screen.end.x - dead_zone.end.x, screen.size.y) \
				, Rect2(0, dead_zone.end.y, screen.size.x, screen.end.y - dead_zone. end.y) \
				, Rect2(0, 0, dead_zone.position.x, screen.size.y)]
		var results = []	# список всех подходящих вариантов расположения
		var best_result: Rect2	# лучший вариант расположения (ближайший к исходному прямоугольнику)
		for zone in zones:
			var res = _match_rectangle(initial_rect, zone)	# находим положение для каждой зоны
			# если найденное положение находится в пределах экрана и не пересекается с "мертвой зоной"
			if screen.encloses(res.grow(-1)) and !res.intersects(dead_zone):
				results.append(res)
				best_result = res
		for res in results:
			# находим наименьшее расстояние до исходного прямоугольника
			if (res.position - initial_rect.position).length() < (best_result.position - initial_rect.position).length():
				best_result = res
		if best_result:
			result = best_result
			
	return result.position

# Вспомогательная функция для match_screen_dimensions. Корректирует позицию первого прямоугольника, вписывая его во второй прямоугольник
func _match_rectangle(what: Rect2, where: Rect2) -> Rect2:
	where.size -= what.size
	var x = clamp(what.position.x, where.position.x, where.end.x)
	var y = clamp(what.position.y, where.position.y, where.end.y)
	what.position = Vector2(x, y)
	return what

func arc_poly(center, radius, angle_from, angle_to):	# базис (1, 0)
	var nb_points = int(14 * (abs(angle_from) + abs(angle_to)) / 360 * (1 + radius / 1000)) + 2	# подстаиваем для плавности окружности
	var points_arc = PoolVector2Array()
	points_arc.append(center)

	for i in range(nb_points + 1):
		var angle_point = angle_from + i * (angle_to-angle_from) / nb_points
		points_arc.append(center + Vector2(cos(deg2rad(angle_point)), sin(deg2rad(angle_point))) * radius)
	return points_arc

func image_to_poly(image, centered = true):	# создает очень грубый полигон из всех непрозрачных пикселей изображения
	# точка отсчета от левого верхнего угла или от центра изображения
	var offset = (image.get_size() / 2).round() if centered else Vector2()
	var points = PoolVector2Array()
	image.lock()
	for x in image.get_width():
		for y in image.get_height():
			if image.get_pixel(x, y).a != 0:
				points.append(Vector2(x, y) - offset)
	image.unlock()
	return Geometry.convex_hull_2d(points)

func image_contour(image, color = ColorN("White")):	# возвращает картинку с контуром в один пиксель по периметру
	# всех непрозрачных пикселей исходного изображения. Цвет контура по-умолчанию белый
	var rect = Rect2(Vector2(), image.get_size())
	var inner_rect = rect.grow(-1) if min(image.get_width(), image.get_height()) > 2 else rect
	var arr = []
	var stack = []
	var pos = Vector2()
	var delta = Vector2(1, 0)
	
	arr.resize(image.get_width())	# двумерный массив временных значений
	for i in arr.size():
		arr[i] = []
		arr[i].resize(image.get_height())

	image.lock()
	for i in (rect.size.x + rect.size.y - 2) * 2:	# точки по периметру изображения являются базисными
		if image.get_pixel(pos.x, pos.y).a > 0:
			arr[pos.x][pos.y] = 1
		else:
			stack.push_back(pos)
			while stack:
				var point = stack.pop_back()
				arr[point.x][point.y] = 0
				var side = Vector2(1, 0)
				for j in [Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1)]:
					# проверка соседних пикселей
					var next = point + j
					if inner_rect.has_point(next) and arr[next.x][next.y] == null:
						if image.get_pixel(next.x, next.y).a == 0:	# прозрачный пиксель
							stack.push_back(next)
						else: arr[next.x][next.y] = 1	# не прозрачный пиксель
		
		if !rect.has_point(pos + delta):
			delta = delta.rotated(PI / 2).round()	# поворот направления движения на 90 град
		pos += delta

	image.fill(Color(0, 0, 0, 0))	# очистка изображения
	image.lock()
	for x in image.get_width():	# заполнение пикселями контура
		for y in image.get_height():
			if arr[x][y] == 1: image.set_pixel(x, y, color)
	return image

func check_collisions(object, point, margin = 0.0, layers = 1):
	# возвращает массив объектов, с которыми контактирует заданный объект
	var query = Physics2DShapeQueryParameters.new()
	query.set_shape(object.get_node("CollisionShape2D").shape)

	if !margin:
		query.margin = object.get_safe_margin()
	query.transform = main_node.get_transform().translated(point)
	query.collision_layer = layers
	return main_node.get_world_2d().get_direct_space_state().intersect_shape(query)

func test_motion(object, motion, point_from = Vector2()):	# возвращает результат движения объекта в заданном направлении (в локальных координатах)
	var motion_result = Physics2DTestMotionResult.new()
	var transform = Transform2D(0.0, point_from) if point_from else object.get_transform()

	Physics2DServer.body_test_motion(object, transform, motion, false, object.get_safe_margin(), motion_result)
	return motion_result

func look_around(object, point = Vector2(), var rays = 32, distance = 2000, exclude_player = true):
	# возвращает массив результатов движения объекта и ближайшую доступную точку к заданной точке.
	# Задается количество лучей и дальность для проверки окружения. Можно исключить из проверки игрока
#	printt(OS.get_ticks_msec() / 1000.0, "look start")
	var collision_mask = object.collision_mask
	var motion_results = []
	var temp = []	# для отладки
	var temp2 = []	# для отладки
	var closest_point = Vector2()
	var v2 = Vector2(0, distance)

	if exclude_player:
		object.set_collision_layer_bit(1, false)

	for i in range(rays):	# создаем массив лучей для объекта
		motion_results.append(test_motion(object, v2))
		v2 = v2.rotated(2 * PI / rays)
#	printt(OS.get_ticks_msec() / 1000.0, "look first step")

	closest_point = point
	if point and Global.test_motion(object, point - object.position).collider:
		# если точка вне прямой видимости
		v2 = Vector2(0, distance)
		var length = distance * 2
		for i in range(rays):	# создаем лучи для точки назначения
			var point_test = test_motion(object, v2, point)
			temp.append(point_test)
			var pm = point_test.motion + point
			for j in motion_results:	# проверяем пересечение лучей объекта с лучами точки
				var om = j.motion + object.position
				var p = Geometry.segment_intersects_segment_2d(point, pm, object.position, om)
				if p:
					temp2.append(p)
					var l = (p - object.position).length() + (p - point).length()
					if l < length:	# выбираем кратчайший путь
						length = l
						closest_point = p
			v2 = v2.rotated(2 * PI / rays)
#		printt(OS.get_ticks_msec() / 1000.0, "look second step")

	object.collision_mask = collision_mask
	return {"motion_results": motion_results, "closest_point": closest_point, "temp": temp, "temp2": temp2}

func raycast_around(center = Vector2(), distance = 1000, angle_from = 0, angle_to = 0, transform = Transform2D(), layers = 2147483647):
	# возвращает полигон видимости из заданой точки. Базис (0, 1), углы в градусах относительно базиса
	var results = PoolVector2Array()
	var rays = int(abs(angle_from) + abs(angle_to)) + 1 if angle_from or angle_to else 360
	var v2 = Vector2(0, distance).rotated(deg2rad(angle_from))

	if transform:
		center +=transform.origin
		angle_from += rad2deg(transform.get_rotation())
		angle_to += rad2deg(transform.get_rotation())
		v2 = v2.rotated(transform.get_rotation())

	if rays < 360:	# для секторальных просмотров добавляем в полигон центральную точку
		results.append(center)

	for i in range(rays):	# создаем массив лучей
		var r = main_node.get_world_2d().get_direct_space_state().intersect_ray(center, center + v2, [], layers)
		results.append(r.position if r else v2 + center)
		v2 = v2.rotated(PI / 180)	# поворот всегда на 1 градус

	if results.size() < 3:	# слишком мало точек чтобы быть полигоном
		results = PoolVector2Array()
	return results

func save_game():
	var game_data = {}
	var settings = {}
	settings.window_size_x = OS.window_size.x
	settings.window_size_y = OS.window_size.y
	settings.window_position_x = OS.window_position.x
	settings.window_position_y = OS.window_position.y
	settings.window_maximized = OS.window_maximized
	settings.datetime = OS.get_datetime()
	game_data.settings = settings
	
	game_data.Player = get_tree().current_scene.get_node("Player").data_to_save()

	game_data.NPC = []
	game_data.Drops = []
	for n in get_tree().get_nodes_in_group("Save"):
		if n.name.begins_with("NPC"): game_data.NPC.append(n.data_to_save())
		if n.name.begins_with("Item"): game_data.Drops.append(n.data_to_save())
	
	var dt = OS.get_datetime()
	var datetime = str(dt.day).pad_zeros(2) + "." + str(dt.month).pad_zeros(2) + "." + str(dt.year) + "-" + str(dt.hour).pad_zeros(2) + "." + str(dt.minute).pad_zeros(2)

	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	var image = get_tree().root.get_texture().get_data()
	image.flip_y()
#	var ratio = min(640.0 / image.get_width(), 480.0 / image.get_height())
#	image.resize(image.get_width() * ratio, image.get_height() * ratio)
	image.save_png(save_dir + "/save_%s.png" % datetime)
	
	var file = File.new()
	var error = file.open(save_dir + "/save_%s.json" % datetime, file.WRITE)
	if error: prints("ERROR saving game: ", error)
	else:
		file.store_string(to_json(game_data).md5_text() + to_json(game_data))
		print("Game saved")
	file.close()

func load_game(filename):
	var error = true
	if filename:
		var file = File.new()
		error = file.open(save_dir + "/" + filename, file.READ)
		if error: prints("ERROR loading game: ", error)
		else:
			var text = file.get_as_text()
			var pos = text.find("{")
			if text.left(pos) == text.right(pos).md5_text():
				var game_data = JSON.parse(text.right(pos)).result
				
				OS.window_size = Vector2(game_data.settings.window_size_x, game_data.settings.window_size_y)
				OS.window_position = Vector2(game_data.settings.window_position_x, game_data.settings.window_position_y)
				OS.window_maximized = game_data.settings.window_maximized

				var player = main_node.get_node("Player")
				player.data_to_load(game_data.Player)

				for n in get_tree().get_nodes_in_group("Save"):
					n.queue_free()
					
#				for n in game_data.Drops:
#					var node = item.instance()
#					main_node.find_node("Surface").add_child(node, true)
#					node.data_to_load(n)
					
				for n in game_data.NPC:
					var node = Preloader.get_resource("NPC").instance()
					main_node.add_child_below_node(player, node, true)
					node.data_to_load(n)

				error = false
			else:
				print("Loading error. The file has wrong structure")
		file.close()
	return error
