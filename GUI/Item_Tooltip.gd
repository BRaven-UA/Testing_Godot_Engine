extends Control

onready var spec = find_node("Specification").get_node("VBoxContainer")
var item#: Class_Item

func _ready():
	find_node("Name").text = item.item_name
	find_node("Picture").texture = item.texture
#	else: find_node("PictureRect").visible = false
	find_node("Type").text = item.type
	find_node("Subtype").text = item.subtype
	find_node("Quantity").text = str(item.quantity)
	find_node("Weight").text = str(item.weight * item.quantity) + " kg"
	
	# заполнение спецификации, для каждого предмета набор полей может быть разным
	if item.damage: add_spec_item("Damage: " + str(item.damage))
	if item.consumable_type: add_spec_item("Ammo: " + item.consumable_type)
	if item.distance: add_spec_item("Range: " + str(item.distance))
	if item.delay: add_spec_item("Cooldown: %s s" % str(item.delay))
	if item.capacity: add_spec_item("Load: %s / %s" % [str(item.loaded), str(item.capacity)])

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
	var label = Preloader.get_resource("Specification item").instance()
#	var label = Global.spec_item.instance()
	label.text = text
	spec.add_child(label, true)