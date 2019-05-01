extends Control

onready var spec = find_node("Specification").get_node("VBoxContainer")
var spec_item = preload("res://GUI/Specification item.tscn")
var data = {}

func _ready():
	find_node("Name").text = data.Name
	var pic = load("res://tiles/items/%s.png" % data.Name)
	if pic: find_node("Picture").texture = pic
	else: find_node("PictureRect").visible = false
	find_node("Type").text = data.Type
	find_node("Subtype").text = data.Subtype if data.has("Subtype") else ""
	find_node("Quantity").text = str(data.Quantity) if data.has("Quantity") else ""
	find_node("Weight").text = str(data.Weight * data.Quantity if data.has("Quantity") else data.Weight) + " kg"
	
	# заполнение спецификации, для каждого предмета набор полей может быть разным
	for key in data:
		match key:
			"Damage": add_spec_item("Damage: " + str(data[key]))
			"Ammo": add_spec_item("Ammo: " + data[key])
			"Range": add_spec_item("Range: " + str(data[key]))
			"Delay":add_spec_item("Cooldown: %s s" % str(data[key]))
			"Capacity":add_spec_item("Load: %s / %s" % [str(data.Load), str(data[key])])

func _process(delta):
	# из-за причуд с автоподгонкой размера у контейнеров пришлось запихнуть корректировки позиции тултипа сюда
	var scr = get_viewport().get_visible_rect().size
	var pos = get_viewport().get_mouse_position() + Vector2(20, -50)
	var rect = $Container.rect_size
	rect_global_position.x = pos.x if (pos.x + rect.x) < scr.x else pos.x - rect.x - 40
	rect_global_position.y = pos.y if (pos.y + rect.y) < scr.y else scr.y - rect.y
	if rect_global_position.y < 0: rect_global_position.y = 0
	set_process(false)	# проверка нужна только один раз. Останавливаем процесс

func add_spec_item(text):
	var label = spec_item.instance()
	label.text = text
	spec.add_child(label, true)