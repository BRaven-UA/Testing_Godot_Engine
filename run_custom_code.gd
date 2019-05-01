tool
extends EditorScript
var item_db

func _run():
	var file = File.new()
	var error = file.open("res://item_db.json", file.READ)
	if error: prints("ERROR opening item database file: ", error)
	item_db = JSON.parse(file.get_as_text()).result
	file.close()
	item_db.Database.sort_custom(self, "sort")
	for i in item_db.Database:
		print(i)

#	printt(OS.get_ticks_msec() / 1000.0, "start")
#	var image = load("res://tiles/items/Glock 17.png").get_data()
#	image.lock()
#	print(image.get_format())
#	var points = PoolVector2Array()
#	for x in image.get_width():
#		for y in image.get_height():
#			if image.get_pixel(x, y).a > 0.2: points.append(Vector2(x, y))
#	var polygon = Geometry.convex_hull_2d(points)
#	print(polygon)
#	var new_image = Image.new()
#	new_image.create(image.get_width(), image.get_height(), false, 5)
#	new_image.fill(Color(0, 0, 0, 1))
#	new_image.lock()
#	for point in polygon:
#		new_image.set_pixel(point.x, point.y, Color(1, 1, 1, 1))
#	print(new_image.save_png("res://test.png"))
#	var ar = []
#	for x in image.get_width():
#		ar.append([])
#		ar[x - 1].resize(image.get_height())
#	var w = 3
#	var h = 2
#	var x = 0
#	var y = 0
#	var dx = 0
#	var dy = -1
#	for i in pow(max(w, h), 2):
#		if abs(x) > (w / 2) or abs(y) > (h / 2):
#			var t = dx
#			dx = -dy
#			dy = t
#			x = -y + dx
#			y = x + dy
#		if x == y or (x < 0 and x == -y) or (x > 0 and x == 1-y):
#			var t = dx
#			dx = -dy
#			dy = t
#		prints(x, y)
#		x += dx
#		y += dy
#	print(rect.grow_individual(-d.x, -d.y, d.x, d.y))
#	var rect = Rect2(Vector2(), Vector2(4, 3))
#	var pos = Vector2()
#	var delta = Vector2(1, 0)
##	for i in pow(max(rect.size.x, rect.size.y), 2):
#	for i in rect.size.x * rect.size.y:
#		prints(pos, delta, rect)
#		if !rect.has_point(pos + delta):
#			delta = delta.rotated(PI / 2).round()
#			rect = rect.grow_individual(delta.x, -delta.y, delta.x, delta.y)
#		pos += delta
#
#	printt(OS.get_ticks_msec() / 1000.0, "end")
	
func find_item(conditions):	# поиск предмета в инвентаре по имени или по другим параметрам
	# например, данные по экипированному оружию: find_item({"Equiped":true, "Type":"Weapon"})
	if conditions:
		if typeof(conditions) == TYPE_STRING: conditions = {"Name":conditions}
		for item in item_db.Database:
			var hits = 0
			for c in conditions.keys():
				if item.has(c):
					if item[c] == conditions[c]: hits += 1
			if hits == conditions.size():
				return item

func sort(a, b):
	return (a.ID > b.ID)