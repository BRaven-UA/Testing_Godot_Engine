# персонаж игрока
extends Character

onready var user_layer = main_node.find_node("UserLayer")

var test_motion = []	# массив данных о возможности двигаться из текущего местоположения
var l	# для отладки
var rays	# для отладки
var current_item	# для отладки

func _set_sight_range(new_value) -> void:	# перезапись классового метода
	sight_range = new_value
	$SightRange.texture_scale = new_value

func _init():
	if Global.debug_mode: printt(OS.get_ticks_msec() / 1000.0, "Player init")

func _ready():
	Global.create_item("7.62 mm", $Inventory, 100)
	var a = Global.create_item("AK-47", $Inventory)
	a.reload(null, true)
	current_item = a
	
	if Global.debug_mode: printt(OS.get_ticks_msec() / 1000.0, "Player is ready")

func _process(delta):
	var direction = Vector2()	# направление движения
	var acceleration = 1.0	# коэффициент изменения базовой скорости
#	torque = 0.0
	if !busy: action = "Idle"
	
	if Global.debug_mode:
		var angle_from = main_node.find_node("angle_from")
		var angle_to = main_node.find_node("angle_to")
		angle_from.get_node("Label").text = str(angle_from.value) + "  (" + str(global_rotation_degrees)
		angle_to.get_node("Label").text = str(angle_to.value)
		rays = Global.raycast_around(Vector2(), 1000, angle_from.value, angle_to.value, get_global_transform(), 5)

#	if a_path.size() > 2:	# оптимизируем маршрут в реальном времени
#		var i = a_path.size()
#		while i > 2:
#			i -= 1
#			if !test_move(transform, get_transform().xform_inv(a_path[i]).rotated(rotation)):
#				for j in i - 1:
#					a_path.remove(1)
#				i = 0
#	if a_path:
#		if (a_path[1] - a_path[0]).length() < 3:
#			a_path.remove(0)
#		if a_path.size() == 1:
#			astar_clear_path()
#		else:
#			a_path[0] = global_position
#			dest_angle = get_transform().xform_inv(a_path[1]).rotated(-PI/2).angle()
#			if abs(dest_angle) > 0.005:
#				is_rotated = true
#			if abs(dest_angle) < PI / 4:
#				direction = get_transform().xform_inv(a_path[1]).rotated(rotation)

	if Input.is_action_pressed("move_up"):
		direction += Vector2.UP
	if Input.is_action_pressed("move_down"):
		direction += Vector2.DOWN
	if Input.is_action_pressed("move_left"):
		direction += Vector2.LEFT
	if Input.is_action_pressed("move_right"):
		direction += Vector2.RIGHT

	if dest_point:
		var possible_moves = Global.look_around(self, dest_point)
		l = possible_moves	# для отладки
		if position.distance_to(dest_point) > 1 and possible_moves.closest_point:
			direction = get_transform().xform_inv(possible_moves.closest_point).rotated(rotation)
			turn_point = position + direction
		else:
			dest_point = Vector2()
			astar_clear_path()
	
	if turn_point:
#		var dest_angle = get_transform().xform_inv(turn_point).rotated(-PI/2).angle()
#		if abs(dest_angle) > 0.005:
#			if $Fire_rate.time_left < 0.001: action = "Turn"
#			rotate(sign(dest_angle) * min(abs(dest_angle), ANG_SPEED) * delta * 10)
#			rotate((ANG_SPEED * delta if ANG_SPEED * delta < abs(dest_angle) else dest_angle) * sign(dest_angle))
#			if ANG_SPEED * delta < abs(dest_angle): rotate(sign(dest_angle) * ANG_SPEED * delta)
#			else: look_at(to_local(turn_point))
#		else:
#			turn_point = Vector2()
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
		acceleration = 1.0 if a > 0.5 else (a + 1) / 3 + 0.5	# в конусе 90 град скорость 100%
			#, в обратном направлении скорость линейно падает вплоть до 50%
		move_and_collide(direction.normalized() * SPEED * acceleration * delta)

	if Input.is_action_just_pressed("reload") and equiped_weapon and !busy:
		if equiped_weapon.reload():
			action = "Reload"
			busy = true

	if Input.is_action_pressed("action_01") and equiped_weapon and !busy:
		if equiped_weapon.attack():
			action = "Attack"
			busy = true
			$Anim_top.frame = 0

	if Input.is_action_just_pressed("drop_item") and equiped_weapon and !busy:
		equiped_weapon.drop()
		for item in $Inventory.get_children():
			if item.type == "Weapon":
				self.equiped_weapon = item


	$Anim_top.frames.set_animation_speed(equiped_weapon.subtype + "Walk", int(10 * acceleration))
	$Anim_feet.frames.set_animation_speed("Walk", int(15 * acceleration))
	$Anim_top.play(equiped_weapon.subtype + action)
	$Anim_feet.play(action)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and !event.pressed:
			turn_point = Vector2()
	
		if event.button_index == BUTTON_LEFT and event.pressed and event.shift:	# автодвижение в указанную точку
			dest_point = get_global_mouse_position()
	#		astar_clear_path()
	#		a_path = main_node.Astar_get_path(self, global_position, get_global_mouse_position())
	#		if a_path:
			if dest_point:
				main_node.get_node("Dest_point").position = dest_point
				main_node.get_node("Dest_point").visible = true
				main_node.get_node("TimelessAnimationPlayer").play("Dest_point")
				get_tree().set_input_as_handled()
	
	if event is InputEventMouseMotion and event.button_mask == 1:
		turn_point = get_global_mouse_position()
	
	if event.is_action_pressed("ui_cancel") and dest_point:
		astar_clear_path()
		dest_point = Vector2()
		get_tree().set_input_as_handled()

func _draw():
#	if a_path:
#		draw_line(Vector2(), get_transform().xform_inv(a_path[2]), ColorN("Yellow"), 3)
	pass

func draw_in_parent():
	if Global.debug_mode:
		if l:
			main_node.draw_circle(l.closest_point, 3, ColorN('Red'))
			for i in l.motion_results:
				main_node.draw_line(position, position + i.motion, ColorN("Yellow"), 1)
				if i.collider:
					main_node.draw_circle(position + i.motion, 18, Color(1, 1, 0, 0.5))
#					main_node.draw_circle(i.collision_point, 2, ColorN('Blue'))
			for i in l.temp:
				main_node.draw_line(dest_point, dest_point + i.motion, ColorN("Yellow"), 1)
			for i in l.temp2:
				main_node.draw_circle(i, 2, ColorN('Blue'))
			l = {}
	#	if direction:
	#		main_node.draw_line(global_position, global_position + direction.normalized() * 100, ColorN("Blue"), 3)
		if a_path:
			main_node.draw_polyline(a_path, Color(1, 0, 0, 1), 2, true)
			a_path = PoolVector2Array()
		if rays:
#			for i in rays:
			main_node.draw_colored_polygon(rays, ColorN("White", 0.3))
	pass

#func taking_damage(value, direction):
#	$Life_bar.value -= value

func astar_clear_path():
	main_node.get_node("Dest_point").visible = false
	main_node.get_node("TimelessAnimationPlayer").stop(true)
	a_path = PoolVector2Array()
#	is_rotated = false

#func add_item(new_item):
#	var owned = find_items({"ID": new_item.ID, "Quantity": null})
#	if owned: owned[0].Quantity += new_item.Quantity
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
#	data.position_x = position.x
#	data.position_y = position.y
#	data.rotation = rotation
#	data.health = $Life_bar.value
#	data.dest_point_x = dest_point.x
#	data.dest_point_y = dest_point.y
#	data.dest_point_visible = get_parent().get_node("Dest_point").visible
#	data.turn_point_x = turn_point.x
#	data.turn_point_y = turn_point.y
#	data.a_path = Array(a_path)
##	data.items = items
#	data.equiped_weapon = equiped_weapon
#	data.action = action
#	return data
#
#func data_to_load(data):	# восстанавливает данные из сохранения
#	position = Vector2(data.position_x, data.position_y)
#	rotation = data.rotation
#	$Life_bar.value = data.health
#	dest_point = Vector2(data.dest_point_x, data.dest_point_y)
#	get_parent().get_node("Dest_point").visible = data.dest_point_visible
#	turn_point = Vector2(data.turn_point_x, data.turn_point_y)
#	a_path = PoolVector2Array(data.a_path)
##	items = data.items
#	equiped_weapon = data.equiped_weapon
#	action = data.action

func _on_Player_input_event(viewport, event, shape_idx):
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		emit_signal("selected", self)

func _on_Life_bar_value_changed(value):
	if value <= 0.0:
		print("GAME OVER")
		get_tree().paused = true

func _on_equiped_item_ready():
	busy = false