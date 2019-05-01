extends Tree
var item_db
var item_db_copy
var root
var dir = Directory.new()
var icon_size = Vector2(128, 32)	# максимальный размер картинок

func _ready():
	
	# загружаем базу данных
	var file = File.new()
	var error = file.open("res://item_db.json", file.READ)
	if error: prints("ERROR opening file: ", error)
	item_db = JSON.parse(file.get_as_text()).result
	item_db_copy = item_db.duplicate()
	file.close()
	
	clear()
	make_titles()
	fill_tree()
	
func make_titles():	# настраиваем колонки под ключи из базы данных
	columns = item_db.Keys.size()
	for col in columns:
		set_column_title(col, item_db.Keys[col])
	set_column_titles_visible(true)
	
func fill_tree():	# формируем дерево предметов
	root = create_item()
	for item in item_db.Database:
		var line = create_item(root)
		var icon = "res://tiles/items/%s.png" % item.Name
		if dir.file_exists(icon):
			var image = load(icon).get_data()
			var ratio = min(icon_size.x / image.get_width(), icon_size.y / image.get_height())
			image.resize(image.get_width() * ratio, image.get_height() * ratio)
			icon = ImageTexture.new()
			icon.create_from_image(image, 0)
			line.set_icon(0, icon)
#			line.set_icon_max_width(0, icon_size.x)
		for col in columns:
			var key = get_column_title(col)
			if item.has(key):
				line.set_text(col, str(item[key]))
				line.set_text_align(col, TreeItem.ALIGN_CENTER)

func _on_Tree_item_activated():	# редактирование ячейки
	var line = get_selected()
	var col = get_selected_column()
	line.set_editable(col, true)
	line.set_text_align(col, TreeItem.ALIGN_CENTER)

func _on_Tree_item_edited():
	var line = get_selected()
	var col = get_selected_column()
	for item in item_db.Database:
		if item.ID == int(line.get_text(item_db.Keys.find("ID"))):
			item[get_column_title(col)] = line.get_text(col)

func _on_Button_Save_pressed():
	var file = File.new()
	var dt = OS.get_datetime()
	var datetime = str(dt.day).pad_zeros(2) + "." + str(dt.month).pad_zeros(2) + "." + str(dt.year) + "-" + str(dt.hour).pad_zeros(2) + "." + str(dt.minute).pad_zeros(2)
	
	# делаем резервную копию
#	var error = file.open_compressed("res://temp/Database backup/item_db_backup_%s.json" % datetime, file.WRITE)
	var error = file.open("res://temp/Database backup/item_db_backup_%s.json" % datetime, file.WRITE)
	if error: prints("ERROR saving backup file: ", error)
	file.store_string(to_json(item_db_copy))
	
	# коррекция числовых данных в базе
	for item in item_db.Database:
		for key in item.keys():
			if str(item[key]).is_valid_float(): item[key] = float(item[key])
	
	error = file.open("res://item_db.json", file.WRITE)
	if error: prints("ERROR saving file: ", error)
	file.store_string(to_json(item_db))
	file.close()

func _on_Button_Add_Item_pressed():
	var line = create_item(root)
	var ID = []
	for item in item_db.Database:
		ID.append(item.ID)
	ID.sort()
	var prev_id = 0
	var unoccupied_id
	for id in ID:
		if id == 0 or id == prev_id: prints("ID error !", id)
		if prev_id + 1 < id:
			unoccupied_id = prev_id + 1
			break
		prev_id = id
		unoccupied_id = id + 1
	item_db.Database.append({"ID": unoccupied_id})
	var col = item_db.Keys.find("ID")
	line.set_text(col, str(unoccupied_id))
	line.select(col)
	line.set_text_align(col, TreeItem.ALIGN_CENTER)
	ensure_cursor_is_visible()

func _on_Button_Remove_pressed():
	var line = get_selected()
	for item in item_db.Database:
		if item.ID == int(line.get_text(item_db.Keys.find("ID"))):
			item_db.Database.erase(item)
			break
	root.remove_child(line)

func _on_Button_Add_Col_pressed():
	item_db.Keys.append("")
	make_titles()

func _on_Tree_column_title_pressed(column):
	$Title_edit.rect_position = get_global_mouse_position()
	$Title_edit.text = get_column_title(column)
	$Title_edit.select_all()
	$Title_edit.visible = true
	$Title_edit.hint_tooltip = str(column)
	$Title_edit.grab_focus()

func _on_Title_edit_text_entered(new_text):
	var key = get_column_title(int($Title_edit.hint_tooltip))
	item_db.Keys[item_db.Keys.find(key)] = new_text
	for item in item_db.Database:
		if item.has(key):
			item[new_text] = item[key]
			item.erase(key)
	make_titles()
	$Title_edit.visible = false

func _on_Tree_item_selected():
	$Title_edit.visible = false

func _on_Button_Remove_Col_pressed():
	item_db.Keys.erase(get_column_title(get_selected_column()))
	clear()
	make_titles()
	fill_tree()

func _on_Button_Reload_pressed():
	_ready()