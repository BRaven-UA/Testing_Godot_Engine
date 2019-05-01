extends KinematicBody2D

signal selected
onready var main_node = get_tree().current_scene
const Item = preload("res://Item.gd")	# чтобы иметь возможность указать класс предмета (сделано только ради облегчения работы в редакторе)

const SPEED = 128	# базовая скорость движения
const ANG_SPEED = PI	# базовая скорость поворота
var dest_point = Vector2()	# место назначения движения
var turn_point = Vector2()	# точка, к которой нужно повернуться
var a_path = PoolVector2Array()	# маршрут, созданный алгоритмом AStar
var explored_area = PoolVector2Array()	# область, которую уже видел персонаж (используется для поиска цели)
var equiped_weapon: Item setget _set_equiped_weapon	# текущее экипированное оружие
var states = ["Patrol", "Hunt", "Cover", "Escape", "Follow"]
var state = "Patrol"
var actions = ["Idle", "Turn", "Walk", "Attack", "Reload"]
var action = "Idle"
var detect_radius = 499
var busy = false	# признак выполнения какого-либо действия
#var target

func _set_equiped_weapon(new_value) -> void:	# setter for equiped_weapon
	if equiped_weapon: equiped_weapon.equiped = false	# снимаем отметку у предыдущего оружия
	if new_value: new_value.equiped = true	# устанавливаем отметку у нового оружия
	equiped_weapon = new_value

func _ready():
	set_process(false)
	var k = Global.create_item("Knife", $Inventory)
	var w = Global.create_item("Glock 17", $Inventory)
	var a = Global.create_item("9 mm", $Inventory)
	a.quantity = 3
	w.reload(null, true)
	self.equiped_weapon = w

	connect("selected", main_node.find_node("Debug"), "selection_changed")
	connect("mouse_entered", main_node, "mouseover", [self, true])
	connect("mouse_exited", main_node, "mouseover", [self, false])
	main_node.connect("draw", self, "draw_in_parent")
	randomize()

func _process(delta):
	var direction = Vector2()	# направление движения
	var acceleration = 1.0	# коэффициент изменения базовой скорости
#	var in_sight = false	# цель в поле зрения
	if !busy: action = "Idle"

	if $Ray1.in_sight:
		state = "Hunt" if ($Life_bar.value > 30 and equiped_weapon) else "Escape"
		$Wait.stop()
		explored_area = PoolVector2Array()
	
	match state:
		"Patrol":	# рандомные передижения по местности
			acceleration /= 3.0	# идем и поворачиваемся неспеша
			if detect_radius != 500:
				detect_radius = 500
				$Detect_radius/CollisionShape2D.shape.points = Global.arc_poly(Vector2(), detect_radius, 90 - 60, 90 + 60)
			if !dest_point and !$Wait.time_left:	# выбор действия
				if action == "Walk" or action == "Turn":	# пауза после движения или поворота
					action = "Idle"
				else:
					randomize()
					action = actions[randi() % 3]	# выбираем следующее действие
##				prints("current action is", action)
				match action:
					"Idle":
						$Wait.wait_time = 2 + randi() % 9
						$Wait.start()
					"Turn":
						turn_point = Vector2(0, 1).rotated(rand_range(-PI, PI))
						$Wait.wait_time = 2
						$Wait.start()
					"Walk":
						var m = Global.look_around(self, Vector2(), 16, 500)
						dest_point = m.motion_results[randi() % m.motion_results.size()].motion + position
		"Hunt":	# преследование цели
			if detect_radius != 1000:
				detect_radius = 1000
				$Detect_radius/CollisionShape2D.shape.points = Global.arc_poly(Vector2(), detect_radius, 90 - 60, 90 + 60)
			if $Ray1.in_sight and abs(($Ray1.target.position - position).length()) <= equiped_weapon.distance - 20:	# 20 - запас по дистанции, чтобы не подходить каждый фрейм
				dest_point = Vector2()
				turn_point = $Ray1.target.position
			else:	# цель вне поля зрения или вне досягаемости действия оружия
				if !$Wait.time_left:	# начинаем преследование
					var m = Global.look_around(self, $Ray1.last_seen)
					dest_point = m.closest_point	# ближайшая доступная для движения точка
					$Wait.wait_time = 20	# время на поиски
					$Wait.start()
				for v2 in $Detect_radius/CollisionShape2D.shape.points:
					explored_area.append(v2.rotated(rotation) + position)
				explored_area = Geometry.convex_hull_2d(explored_area)
				if !dest_point:	# начинаем поиски в окрестностях места, где цель видели в последний раз
					dest_point = $Ray1.last_seen
					var ways = Global.look_around(self, Vector2(), 8, detect_radius + 30)
					for w in ways.motion_results:
						var point = w.motion + position
						var ea = explored_area
						ea.append(point)
						if explored_area != Geometry.convex_hull_2d(ea):
							dest_point = Global.closest_point(dest_point, point, $Ray1.last_seen)
#			a_path = PoolVector2Array() if $Ray1.sight else main_node.Astar_get_path(self, global_position, dest_point)
		"Escape":	# спасаться бегством
			if detect_radius != 250:
				detect_radius = 250
				$Detect_radius/CollisionShape2D.shape.points = Global.arc_poly(Vector2(), detect_radius, 90 - 60, 90 + 60)
			if !$Wait.time_left:
				$Wait.wait_time = 60
				$Wait.start()
#			var v2 = -(target.global_position - global_position).normalized()
#			while !a_path:
#				dest_point = global_position + v2.rotated(randf() * PI / 4 - PI / 8) * randf() * 100
#				a_path = main_node.Astar_get_path(self, global_position, dest_point)

#	if a_path.size() > 2:	# оптимизируем маршрут в реальном времени
#		var i = a_path.size()
#		while i > 2:
#			i -= 1
#			if !test_move(transform, get_transform().xform_inv(a_path[i]).rotated(rotation)):
#				for j in i - 1:
#					a_path.remove(1)
#				i = 0
#	if a_path:
#		if (a_path[1] - a_path[0]).length() < 1:
#			a_path.remove(0)
#		if a_path.size() == 1:
#			a_path = PoolVector2Array()
#			is_rotated = false
#		else:
#			a_path[0] = global_position
#			dest_angle = get_transform().xform_inv(a_path[1]).rotated(-PI/2).angle()
#			if abs(dest_angle) > 0.005:
#				is_rotated = true
#			if abs(dest_angle) < PI / 4:
#				direction = get_transform().xform_inv(a_path[1]).rotated(rotation)
#				action = "Walk"
#				if $Bump.is_colliding():
#					direction = direction.rotated(PI / 4)	# обход случайной преграды
#					var p = get_world_2d().get_direct_space_state().intersect_point(dest_point)
#					# проверяем наличие объектов в точке назначения
#					if p:
#						var c = $Bump.get_collider()
#						for d in p:
#							if d.collider == c:	# точка назначения занята объектом с которым в данный момент столкнулись
#								a_path = PoolVector2Array()
#								direction = Vector2()
#								action = "Idle"
#				var a = get_transform().y.dot(direction.normalized())	# угол между направлением тела и направлением движения (-1 < a < 1)
#				acceleration = 1.0 if a > 0.5 else (a + 1) / 3 + 0.5	# в конусе 90 град скорость 100%
#					#, в обратном направлении скорость линейно падает вплоть до 50%
#	
#	if dest_point and $Bump.is_colliding():
#		var colliders_array = Global.check_collisions(self, dest_point, 0.0, 7)
#		# проверяем наличие объектов в точке назначения
#		if colliders_array:
#			var c = $Bump.get_collider()
#			for d in colliders_array:
#				if d.collider == c:	# точка назначения занята объектом с которым в данный момент столкнулись
#					dest_point = Vector2()
#					action = "Idle"
	
	if dest_point:
		var possible_moves = Global.look_around(self, dest_point)
		if position.distance_to(dest_point) > 1 and possible_moves.closest_point:
			# точка назначения не достигнута, задаем направление движения с учетом возможных препятствий
			direction = get_transform().xform_inv(possible_moves.closest_point).rotated(rotation)
			turn_point = position + direction
		else:	# точка назначения достигнута или не может быть достигнута
			dest_point = Vector2()
#			$Ray1.last_seen = Vector2()

	if turn_point:
		var dest_angle = get_transform().xform_inv(turn_point).rotated(-PI/2).angle()
		if !busy: action = "Turn"
		if ANG_SPEED * delta < abs(dest_angle):
			rotate(sign(dest_angle) * ANG_SPEED * delta)
		else:
			rotate(dest_angle)
			turn_point = Vector2()
	
	if direction:
		if !busy: action = "Walk"
		var a = get_transform().y.dot(direction.normalized())	# угол между направлением тела и направлением движения (-1 < a < 1)
		acceleration *= 0.0 if a < 0.5 else a
		# движение только если поворот меньше 45 град, скорость линейно возрастает до 100% по мере поворота к точке движения
		move_and_collide(direction.normalized() * SPEED * acceleration * delta)
	
	if equiped_weapon:
		if equiped_weapon.capacity and !busy and\
		(!equiped_weapon.loaded or (equiped_weapon.loaded < equiped_weapon.capacity and state != "Hunt")):	# нужна перезарядка оружия
			if equiped_weapon.reload():
				action = "Reload"
				busy = true
			if !equiped_weapon.loaded:
				change_weapon()

	if $Ray1.in_sight and !turn_point and !busy:
		# есть цель в прямой видимости, корпус повернут к ней и персонаж не занят
		if equiped_weapon.attack():
			action = "Attack"
			busy = true
			$Anim_top.frame = 0
	
	$Anim_top.frames.set_animation_speed(equiped_weapon.subtype + "Walk", int(10 * acceleration))
	$Anim_feet.frames.set_animation_speed("Walk", int(15 * acceleration))
	$Anim_top.animation = equiped_weapon.subtype + action
	$Anim_top.play(equiped_weapon.subtype + action)
	$Anim_feet.play(action)
	update()
#	if $PopupDialog.visible:
#		$PopupDialog/VBoxContainer/X.text = "x = " + str(position.x)
#		$PopupDialog/VBoxContainer/Y.text = "y = " + str(position.y)
#		$PopupDialog/VBoxContainer/Rotation.text = "a = " + str(rad2deg(floor(rotation * 10)/10))


func _draw():
	if Global.debug_mode:
		if dest_point:
			draw_circle(get_global_transform().xform_inv(dest_point), 3, ColorN("Red"))	# для отладки

func draw_in_parent():
	if Global.debug_mode:
	#	if direction:
	#		main_node.draw_line(global_position, global_position + direction.normalized() * 100, ColorN("Blue"), 3)
		if a_path:
			main_node.draw_polyline(a_path, Color(1, 0, 0, .2), 10, true)
		if explored_area:
			main_node.draw_colored_polygon(explored_area, ColorN("Yellow", .5))

func change_weapon(new_weapon: Node2D = null):	# смена оружия на указанное, либо на лучшее из имеющегося
	if !new_weapon:
		var suitable_weapons = []	# список подходящего оружия (для которого есть расходники и они не нужны)
		for i in $Inventory.get_children():
			if i.type == "Weapon":
				var suitable = true
				if i.capacity and !i.loaded:
					suitable = not i.find_consumables().empty()	# если расходников нет, помечаем как неподходящее
				if suitable:
					suitable_weapons.append(i)
					new_weapon = i	# сразу выбираем любое подходящее
		for i in suitable_weapons:
			if i.distance > new_weapon.distance:	# выбираем наиболее дальнодействующее
				new_weapon = i
	self.equiped_weapon = new_weapon

func taking_damage(value, direction):
	$Life_bar.value -= value
	state = "Hunt"
	$Ray1.last_seen = position - direction.normalized() * 500

func death():
	emit_signal("selected", null)
	var surface = main_node.find_node("Surface")
	var s = $Remains	# переподчиняем изображение останков
	remove_child(s)
	surface.add_child(s, true)
	s.owner = surface
	s.position = global_position
	s.rotation = global_rotation + PI / 2
	s.visible = true
	for item in $Inventory.get_children():	# бросаем на землю предметы
		item.drop()
	
	queue_free()

func _on_Life_bar_value_changed(value):
	if value <= 0:	# смерть
		death()

func _on_Wait_timeout():
	if state == "Escape" or state == "Hunt":	# время на поиск или бегство вышло, возвращаемся к патрулированию
#		target = null
		explored_area = PoolVector2Array()
		state = "Patrol"

func _on_NPC_input_event(viewport, event, shape_idx):	# объект выделен мышью
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		emit_signal("selected", self)

#func _on_NPC_mouse_entered():	# объект под указателем мыши
#	$PopupDialog.popup()
#
#func _on_NPC_mouse_exited():	# указатель мыши больше не над объектом
#	$PopupDialog.hide()
#
#func add_item(new_item):
#	var owned = find_items({"ID": new_item.ID, "Quantity": null})[0]
#	if owned: owned.Quantity += new_item.Quantity
#	else: items.append(new_item)

#func find_items(conditions):	# поиск предметов в инвентаре по имени или по другим параметрам в виде словаря
#	# Возвращает массив из найденных предметов. Указание значения параметра null равносильно любому значению
#	# Упрощенный вариант - поиск по имени в виде строки: find_items("Knife")
#	# например, данные по экипированному оружию: find_items({"Equiped":true, "Type":"Weapon"})
#	var result = []
#	if conditions:
#		if typeof(conditions) == TYPE_STRING: conditions = {"Name":conditions}
#		for item in items:
#			var hits = 0
#			for c in conditions.keys():
#				if item.has(c):
#					if item[c] == conditions[c] or conditions[c] == null: hits += 1
#			if hits == conditions.size(): result.append(item)
#	return result

#func data_to_save():	# формирует словарь данных для сохранения
#	var data = {}
#	data.name = name
#	data.position_x = position.x
#	data.position_y = position.y
#	data.rotation = rotation
#	data.health = $Life_bar.value
#	data.dest_point_x = dest_point.x
#	data.dest_point_y = dest_point.y
#	data.turn_point_x = turn_point.x
#	data.turn_point_y = turn_point.y
#	data.a_path = Array(a_path)
#	data.explored_area = Array(explored_area)
##	data.items = items
#	data.equiped_weapon = equiped_weapon
#	data.state = state
#	data.action = action
#	data.ray_cast_to_x = $Ray1.cast_to.x
#	data.ray_cast_to_y = $Ray1.cast_to.y
#	if $Ray1.target: data.ray_target_name = $Ray1.target.name
#	data.ray_in_sight = $Ray1.in_sight
#	data.ray_last_seen_x = $Ray1.last_seen.x
#	data.ray_last_seen_y = $Ray1.last_seen.y
#	return data
#
#func data_to_load(data):	# восстанавливает данные из сохранения
#	name = data.name
#	position = Vector2(data.position_x, data.position_y)
#	rotation = data.rotation
#	$Life_bar.value = data.health
#	dest_point = Vector2(data.dest_point_x, data.dest_point_y)
#	turn_point = Vector2(data.turn_point_x, data.turn_point_y)
#	a_path = PoolVector2Array(data.a_path)
#	explored_area = PoolVector2Array(data.explored_area)
##	items = data.items
#	equiped_weapon = data.equiped_weapon
#	state = data.state
#	action = data.action
#	$Ray1.cast_to = Vector2(data.ray_cast_to_x, data.ray_cast_to_y)
#	if data.has("ray_target_name"): $Ray1.target = main_node.find_node(data.ray_target_name)
#	$Ray1.in_sight = data.ray_in_sight
#	$Ray1.last_seen = Vector2(data.ray_last_seen_x, data.ray_last_seen_y)

func _on_equiped_item_ready():
	busy = false