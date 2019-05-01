extends Node2D

var item_db
var item = preload("res://Item.tscn")


func _ready():
	var file = File.new()
	var error = file.open("res://item_db.json", file.READ)
	if error: prints("ERROR opening item database file: ", error)
	item_db = JSON.parse(file.get_as_text()).result
	file.close()
	
	create_item("Knife")

func find_item(name):	# поиск предмета в базе данных
	if name:
		for item in item_db.Database:
			if item.item_name == name: return item.duplicate()

func create_item(name):	# добавление уникальной копии предмета в игровой мир
	if name:
		var base_item = find_item(name)
		var new_item = item.instance()
		for key in base_item:
			new_item.set(key, base_item[key])
		add_child(new_item, true)
