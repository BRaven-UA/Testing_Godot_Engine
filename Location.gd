extends Node2D

var pressed_count: int	# счетчик одновременно нажатых клавиш
onready var dl1 = $Debug.find_node("Label")
onready var dl2 = $Debug.find_node("Label2")
onready var dl3 = $Debug.find_node("Label3")
onready var dl4 = $Debug.find_node("Label4")
onready var dl5 = $Debug.find_node("Label5")
onready var dl6 = $Debug.find_node("Label6")
onready var ESC_menu = find_node("ESCMenu")
var tooltip
var a_star = AStar.new()
#var motion_result = Physics2DTestMotionResult.new()
#onready var a_size = int($Terrain/Ground.cell_size.x / 2)
var a_size = 26	# должно быть кратно 2
onready var back_poly = $Terrain.find_node("Background").polygon	# берем за основу размер текстуры-подложки
var back_rect = Rect2()
var last_time = OS.get_time()

func _notification(what: int) -> void:
	# если мышь ущла за рамки окна приложения или приложение потеряло фокус ввода
	if what == MainLoop.NOTIFICATION_WM_MOUSE_EXIT or what == MainLoop.NOTIFICATION_WM_FOCUS_OUT or what == MainLoop.NOTIFICATION_WM_UNFOCUS_REQUEST:
		Global.time_stopped = true
		pressed_count = 0

func _init():
	if Global.debug_mode: printt(OS.get_ticks_msec() / 1000.0, "Location init")

func _ready():
	if Global.debug_mode: printt(OS.get_ticks_msec() / 1000.0, "Location is ready")
	back_rect = Rect2(back_poly[0], back_poly[0].abs() + back_poly[2])
	randomize()
#	get_node("NPC").taking_damage(100, Vector2())
#	Astar_create()
	
#	for i in range(10):
#		var n = Preloader.get_resource("NPC").instance()
##		var n = Global.npc.instance()
#		add_child_below_node(n, $Player, true)
#		var v2 = Vector2()
##		var a_path = PoolVector2Array()
##		var p = $Terrain/Background.polygon
##		while !a_path:
##			v2 = Vector2(randf() * back_rect.size.x, randf() * back_rect.size.y) - back_rect.position.abs()
##			a_path = Astar_get_path(n, v2, $Player.global_position)
###			if !a_path:
###				v2 = Vector2()
#		while !v2:
#			v2 = Vector2(global_position.x + randf() * 1000 - 500, global_position.y + randf() * 1000 - 500)
#			if Global.check_collisions(n, v2, 0.0, 7):
#				v2 = Vector2()
#		n.position = v2
#		n.rotation = randf() * 2 * PI - PI
	pass

func _process(delta):
#	var query = Physics2DShapeQueryParameters.new()
#	query.set_shape($Player/CollisionShape2D.shape)
#	query.margin = $Player.get_safe_margin()
#	query.transform = get_transform().translated($Player.position)
#	query.motion = $Player.get_local_mouse_position().rotated($Player.rotation)
#	query.collision_layer = 7
#	query.exclude = [$Player]
#	result = get_world_2d().get_direct_space_state().collide_shape(query)
#	if last_time.second != OS.get_time().second:
#		last_time = OS.get_time()
	Global.time_stopped = not bool(pressed_count)
	update()

func _unhandled_input(event: InputEvent) -> void:
	# отслеживаем любые нажатия в игровом мире для управления течением внутриигрового времени
	if event is InputEventMouseButton or event is InputEventKey and !event.is_echo():
		if event.is_pressed():
			pressed_count += 1
		else:
			pressed_count = int(max(0, pressed_count - 1))	# на случай отрицательных значений

#	if event.is_action_pressed("ui_cancel"):
#		ESC_menu.visible = !ESC_menu.visible


func _draw():
#	if result:
#		draw_circle(get_global_mouse_position(), 18, ColorN('Yellow'))
#		draw_circle($Player.get_transform().xform(result.motion).rotated($Player.rotation), 2, ColorN('Blue'))
#	if point:
#		draw_circle(point, 6, ColorN('Red'))
	#	point = Vector2()
	if Global.debug_mode:
		var ctrans = get_canvas_transform()
		var min_pos = -ctrans.get_origin() / ctrans.get_scale()
		var view_size = get_viewport_rect().size / ctrans.get_scale()
		var view_rect = Rect2(min_pos, view_size + Vector2(a_size, a_size))
		for p in a_star.get_points():
			var v3 = a_star.get_point_position(p)
			var v2 = Vector2(v3.x, v3.y)
			if view_rect.has_point(v2):
				for ind in a_star.get_point_connections(p):
					v3 = a_star.get_point_position(ind)
					draw_line(v2, Vector2(v3.x, v3.y), ColorN("White"))
				draw_circle(v2, 1.0, ColorN("Green"))

func de_change(new_text, name):
	find_node(name).release_focus()

func Astar_create():
#	var shape = $Player/CollisionShape2D.shape
#	shape.radius += $Player.get_safe_margin()
	for y in range(floor(back_poly[0].y) + a_size / 2, back_poly[2].y, a_size):
		for x in range(floor(back_poly[0].x) + a_size / 2, back_poly[2].x, a_size):
			if !Global.check_collisions($Player, Vector2(x, y)):
				var i = a_star.get_available_point_id()
				a_star.add_point(i, Vector3(x, y, 0))
				Astar_connect_point(i)
	printt(OS.get_ticks_msec() / 1000.0, "AStar creation end")
	printt("AStar points:", a_star.get_points().size())

func Astar_connect_point(index, size = a_size):
	var v3 = a_star.get_point_position(index)
	var v2 = Vector2(v3.x, v3.y)
	for off in 	[Vector2(-size, 0), Vector2(0, -size)]:
		var v2_off = v2 + off	# смещение
		var v3_off = Vector3(v2_off.x, v2_off.y, 0)
		var ind = a_star.get_closest_point(v3_off)
		if ind != index and (a_star.get_point_position(ind) - v3_off).length() < size and !a_star.are_points_connected(ind, index):
				a_star.connect_points(index, ind)	# соединяем центральную точку со смещенной точкой

func Astar_get_path(object, start_point, end_point):
		start_point = start_point.floor()
		end_point = end_point.floor()
		var ind = a_star.get_available_point_id()
		a_star.add_point(ind, Vector3(start_point.x, start_point.y, 0))
		Astar_connect_point(ind, a_size / 2)
		a_star.add_point(ind + 1, Vector3(end_point.x, end_point.y, 0))
		var shape = object.get_node("CollisionShape2D").shape
#		shape.radius += object.get_safe_margin()
#		print(shape.radius)
		if !Global.check_collisions(object, end_point):
			Astar_connect_point(ind + 1, a_size / 2)
		var pa = a_star.get_point_path(ind, ind + 1)
		var path = PoolVector2Array()
		for p in pa:
			path.append(Vector2(p.x, p.y))
		a_star.remove_point(ind)
		a_star.remove_point(ind + 1)
		return path

func mouseover(object: Object, over: bool) -> void:
	if tooltip:	# убираем текущий тултип
		tooltip.queue_free()
		tooltip = null
	
	if object.is_in_group("Backpack_items"):
		object.use_parent_material = !over
		if over:
			tooltip = Preloader.get_resource("Item_Tooltip").instance()
			tooltip.item = object.linked_object
			$GUI.add_child(tooltip, true)
		return
	
	# отдельно объекты игровой локации
	var insight = Global.is_visible_to_player(object)
	
	if object.is_in_group("Items"):
		object.get_node("Sprite").use_parent_material = !over if insight else true
		if over and insight:	# проверка дальности до игрока
			tooltip = Preloader.get_resource("Item_Tooltip").instance()
#			tooltip = Global.item_tooltip.instance()
			tooltip.item = object
			$GUI.add_child(tooltip, true)
	
#	if object.name.begins_with("NPC"):
	if object.is_in_group("NPC"):
		object.get_node("Anim_top").use_parent_material = !over if insight else true