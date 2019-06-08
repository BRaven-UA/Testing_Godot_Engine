# надстройка над классом, оперирующая сценой
extends Node2D
#class_name Class_Item, "res://item_icon.png"

signal item_ready

onready var main_node = get_tree().current_scene
var surface
var user_layer
onready var grandparent	# внутриигровой владелец предмета (игрок или другой предмет)

var attached_consumable setget _set_attached_consumable	# ссылка на загруженные расходники
var texture: Texture	# изображение предмета
var uid: Dictionary	# уникальный номер
var item_name: String = "Unnamed"
var type: String = ""
var subtype: String = ""
var consumable_type: String = ""	# тип используемых расходников
var position_offset: Vector2	# смещение позиции предмета при его экипировке
var weight: float = 0.0
var delay: float = 0.0	# задержка после применения
var damage: float = 0.0 setget _set_damage, _get_damage	# урон, который наносит предмет
var distance: int = 0	# дальность действия предмета
var capacity: int = 0	# вместимость
var loaded: int = 0 setget ,_get_loaded	# текущее количество загруженных расходников
var quantity: int setget _set_quantity	# количество. Значение по-умолчанию не ставлю, чтобы сработал setter при инициализации
var equiped: bool = false setget _set_equiped	# предмет экипирован
var busy: float = false setget _set_busy	# признак выполнения какого-либо действия предметом, хранит время в секундах начальной продолжительности
#export (Texture) var texture	# изображение предмета
#export (Dictionary) var uid	# уникальный номер
#export (String) var item_name = "Unnamed"
#export (String) var type = ""
#export (String) var subtype = ""
#export (String) var consumable_type = ""	# тип используемых расходников
#export (Vector2) var position_offset = Vector2(-11, 33)	# смещение позиции предмета при его экипировке
#export (float) var weight = 0.0
#export (float) var delay = 0.0	# задержка после применения
#export (int) var distance = 0	# дальность действия предмета
#export (int) var capacity = 0	# вместимость
#export (bool) var equiped = false #setget _set_equiped	# предмет экипирован
#export (bool) var busy = false	# признак выполнения какого-либо действия предметом
#export (float) var damage = 0.0 setget ,_get_damage	# урон, который наносит предмет
#export (int) var loaded = 0 setget ,_get_loaded	# текущее количество загруженных расходников
#export (int) var quantity setget _set_quantity	# количество. Значение по-умолчанию не ставлю, чтобы сработал setter при инициализации

var backpack_item	# ссылка на представление предмета в рюкзаке игрока
var nameplate	# ссылка на информационнцю планку предмета на поверхности
var nameplate_position	# используется при восстановлении из файла сохранения
var nameplate_label_position	# используется при восстановлении из файла сохранения
var exclude_targets: Array	# список целей, исключаемый при атаке

func _set_attached_consumable(new_value) -> void:
	attached_consumable = new_value
	if grandparent:
		if grandparent.name == "Player":
			MessageBus.send(self, "Buttons", ["attached_consumable", attached_consumable])

func _set_damage(new_value) -> void:
	damage = new_value

func _get_damage() -> float:	#getter for damage
	return (damage + attached_consumable.damage) if attached_consumable else damage

func _get_loaded() -> int:	#getter for loaded
	return attached_consumable.quantity if attached_consumable else loaded

func _set_quantity(new_value):	# setter for quantity
#	var positive_int_value = int(max(0, new_value))	# чтобы отсечь случайные отрицательные и вещественные числа
#	if get_parent().name == "Attachments":
#	if grandparent is Class_Item:	# предмет прикреплен к другому предмету
#		grandparent.loaded = positive_int_value
	quantity = int(max(0, new_value))	# чтобы отсечь случайные отрицательные и вещественные числа
	if grandparent:
		if grandparent.name == "Player":
			MessageBus.send(self, "Buttons", ["quantity", quantity])
		if grandparent.is_in_group("Items"):
			if grandparent.grandparent.name == "Player":
				MessageBus.send(grandparent, "Buttons", ["loaded", quantity])
	var texture_name: String
	match quantity:#positive_int_value:
		0:
			_unbound()
#			yield(main_node.get_tree(), "idle_frame")	# ждем окончания всех расчетов в текущем фрейме
			queue_free()
			return	# дальнейшее выполнение функции приведет к ошибке
		1: texture_name = item_name	# изображение одной единицы предмета
		_: texture_name = item_name + "_numerous"	# изображение нескольких предметов
#		1: texture = Preloader.get_resource(item_name)	# изображение одной единицы предмета
#		_: texture = Preloader.get_resource(item_name + "_numerous")	# изображение нескольких предметов
	if !texture_name: texture_name = "item_icon"
#	if !texture: texture = Preloader.get_resource("item_icon")
	texture = Preloader.get_resource(texture_name)
	$Sprite.texture = texture
#	texture_name += "_nm"
#	if Preloader.has_resource(texture_name):
#		$Sprite.normal_map = Preloader.get_resource(texture_name)	# некорректно отображается материал для LightOnly
	if backpack_item: backpack_item.texture = texture


func _set_equiped(new_value):	# setter for equiped
	if backpack_item:
		backpack_item.visible = !new_value	# скрываем представление предмета в инвентаре, если предмет экипирован
	equiped = new_value
	if grandparent.name == "Player":
		MessageBus.send(self, "Buttons", ["equiped", equiped])

func _set_busy(new_value) -> void:
	busy = new_value
	if grandparent:
		if grandparent.name == "Player":
			MessageBus.send(self, "Buttons", ["busy", busy])

func _exit_tree() -> void:	# предмет меняет владельца
	_unbound()

func _enter_tree() -> void:	# предмет получил нового владельца
	_bound()
#
func _ready() -> void:
	match subtype:
		"Handgun":
			position_offset = Vector2(-11.4, 32.8)
		"Rifle":
			position_offset = Vector2(-9.6, 37.5)
		_:
			position_offset = Vector2()
	if subtype == "Melee":
		$Melee_area/CollisionShape2D.shape.points = Global.arc_poly(Vector2(), distance, 90 - 60, 90 + 60)

func _add_nameplate():	# добавление информационного указателя к предмету на поверхности
	nameplate = Preloader.get_resource("Nameplate").instance()
#	nameplate = Global.nameplate.instance()
	nameplate.bind_to = self
#	$VisibilityNotifier2D.connect("screen_entered", nameplate, "_screen_entered")
#	$VisibilityNotifier2D.connect("screen_exited", nameplate, "_screen_exited")
	if nameplate_position: nameplate.rect_global_position = nameplate_position
	if nameplate_label_position: nameplate.find_node("Label").rect_global_position = nameplate_label_position
	nameplate.find_node("Label").text = "(%s) %s" % [str(quantity), item_name] if quantity > 1 else item_name
	main_node.find_node("HUD").add_child(nameplate, true)

func _bound() -> void:	# Привязка предмета к владельцу
	grandparent = get_parent().get_parent()
	# определяем куда попал предмет. Не используем match так как приходится проверять разные условия
	if grandparent.is_in_group("Items"):	# прикрипление к предмету
		if grandparent.consumable_type == item_name:	# предмет является расходником
			for i in get_parent().get_children():	# убираем другие расходники, кроме себя
				if grandparent.consumable_type == item_name and i != self:
					i.move_to(grandparent.get_parent())
			grandparent.attached_consumable = self
		position = Vector2(); rotation = 0	# восстанавливаем значения по-умолчанию
	elif grandparent is KinematicBody2D:	# игровой персонаж
		connect("item_ready", grandparent, "_on_equiped_item_ready")
		position = Vector2(); rotation = 0	# восстанавливаем значения по-умолчанию
#		exclude_targets = [grandparent]
		if grandparent.name == "Player":	# для игрока создаем представление предмета в рюкзаке
			backpack_item = Preloader.get_resource("BackpackItem").instance()
			backpack_item.linked_object = self
			backpack_item.texture = texture	# ставлю эту строку тут чтобы успел прописаться rect_size
			Global.backpack_content.add_child(backpack_item, true)
			if type in ["Weapon", "Tool"]:
				user_layer.call_deferred("create_button", self, texture, "DefaultActionBar")
	elif get_parent() == surface:	# предмет находится на игровой локации
		randomize()	# случайно смещаем позицию и поворот предмета чтобы много предметов не падали в одну точку
		position += Vector2(20 - randi() % 40, 20 - randi() % 40)
		rotation = PI - randf() * 2 * PI
		_add_nameplate()
	_on_ready("bound")

func _unbound() -> void:	# Отсоединение предмета от владельца
	Global.disconnect_all_signals(self)
	if grandparent.is_in_group("Items"):	# был прикреплен к предмету
		if grandparent.consumable_type == item_name:
			grandparent.attached_consumable = null	# убираем ссылку на этот предмет
	if grandparent.name == "Player":
		MessageBus.send(self, "Buttons", ["free"])
	if nameplate:	# убираем информационную планку
		nameplate.queue_free()
		nameplate = null
	if backpack_item:	# удаляем представление предмета в рюкзаке игрока
		backpack_item.remove()
		backpack_item = null
	_on_mouse_exited()	# убираем тултип и контур
#	exclude_targets = []
	equiped = false

func move_to(new_owner: Node2D) -> void:	# перемещение предмета в другое место
	if new_owner:
#		if busy: yield(self, "item_ready")	# ждем готовности предмета
		position = grandparent.global_position	# запоминаем глобальные координаты владельца
		get_parent().remove_child(self)
		new_owner.add_child(self, true)

func drop():	# бросание предмета на поверхность
	move_to(surface)

func split(piece: int) -> Node2D:	# разделение предмета, возвращает клон текущего предмета с указанным количеством
	if piece in range(1, quantity):
		var data = Global.get_variables(self)
		var new_item = Global.create_item(data, get_parent(), piece)
		self.quantity -= piece
		return new_item
	return null

func find_consumables(consumable: String = "") -> Array:	# возвращает массив расходников для текущего предмета по имени или первый попавшийся
	var list: Array = []
	for item in get_parent().get_children():
		if item.subtype == consumable_type:
			if !consumable: consumable = item.item_name
			if consumable == item.item_name: list.append(item)
	return list

func reload(new_consumable = null, silent = false) -> bool:	# перезарядка оружия указанными расходниками или первыми попавшимися из подходящих, возвращает признак успешной перезарядки
	if self.loaded == capacity or busy: return false	# перезарядка не требуется или невозможна в данный момент
	var list = find_consumables(new_consumable.item_name if new_consumable else "")	# список расходников подходящего типа
#	if !new_consumable and attached_consumable:	# если новые расходники не указаны, берем загруженные
#		new_consumable = attached_consumable
	for item in list:
#		if item == new_consumable: continue	# игнорируем себя
		if !new_consumable:
			new_consumable = item	# если расходники не указаны, берем первые попавшиеся
			continue
		if new_consumable.quantity < capacity:
			var amount = min(item.quantity, capacity - new_consumable.quantity)	# случай когда в наличии меньше чем требуется
			new_consumable.quantity += amount
			item.quantity -= amount
	if new_consumable:
#		self.attached_consumable = null	# обнуляем расходники чтобы корректно сработала инициализация
		if new_consumable.quantity > capacity:
			new_consumable.split(new_consumable.quantity - capacity)	# если расходников больше чем вместимость, отделяем лишнее
		new_consumable.move_to(get_node("Attachments"))	# прикрепляем новые расходники к предмету
		if !silent:	# если не требуется мгновенная перезарядка
			$Reload.play()	# звук перезарядки
			self.busy = $Reload.stream.get_length()
		return true
	return false

func shoot() -> bool:	# default attack with ranged weapon
	if busy: return false	# стрельба невозможна в данный момент
	if !self.loaded and type == "Weapon":	# нет патронов, звук осечки
		print("Out of ammo")	# TODO: добавить визуализацию
		$Fire_fail.play()
		self.busy = $Fire_fail.stream.get_length()
		return false
	var pos = grandparent.global_position + position_offset.rotated(grandparent.rotation)
	var flame = Preloader.get_resource("Flame").instance()	# вспышка от выстрела
#	var flame = Global.flame.instance()	# вспышка от выстрела
	flame.frame = 0
	flame.global_position = position_offset#.rotated(grandparent.rotation); flame.rotation = grandparent.rotation
	grandparent.add_child(flame, true)
#	flame.play(subtype)
	flame.play()
	$Bang.play()	# звук выстрела
	var bullet = Preloader.get_resource("Bullet").instance()	# пуля
#	var bullet = Global.bullet.instance()	# пуля
	bullet.global_position = pos;   bullet.rotation = grandparent.rotation;   bullet.damage = self.damage	# настраиваем параметры пули
	main_node.add_child(bullet, true)	# пуля не должна быть привязана к игроку чтобы не менять траекторию при движении
	$Timer.wait_time = delay
	$Timer.start()
	attached_consumable.quantity -= 1
	self.busy = delay
	return true

func swing() -> bool:	# default melee attack
	if busy: return false
	exclude_targets = [grandparent]	# сразу убираем себя из возможных целей (т.к. конус атаки начинается внутри колижн-модели персонажа)
	$Melee_area.monitoring = true
	$Melee_swing.play()
	# добавить звук удара и звук попадания
	$Timer.wait_time = 1.0	# заменить на скорость атаки игрока
	$Timer.start()
	self.busy = $Timer.wait_time
	return true

func attack() -> bool:
	if type == "Weapon":
		if subtype == "Melee": return swing()
		else: return shoot()
	return false

func use():	# использовать предмет
	pass

func create_action_list() -> Array:	# формирует список возможных действий для данного предмета
	var result: = []
	
	if equiped:
		match type:
			"Weapon": result.append({"Description": "Атаковать", "Target": Global.user_layer, "Method": "_generate_action", "Arguments": ["action_01"]})
			"Tool": result.append({"Description": "Использовать", "Target": Global.user_layer, "Method": "_generate_action", "Arguments": ["action_01"]})
		result.append({"Description": "Выбросить", "Target": Global.user_layer, "Method": "_generate_action", "Arguments": ["drop_item"]})
	else:
		result.append({"Description": "Экипировать", "Target": Global.player, "Method": "_set_equiped_weapon", "Arguments": [self]})
		result.append({"Description": "Выбросить", "Target": self, "Method": "drop", "Arguments": []})
		
	if quantity > 1:
		result.append({"Description": "Разделить", "Target": self, "Method": "split", "Arguments": []})
		
	if self.loaded < capacity:
		result.append({"Description": "Перезарядить", "Target": self, "Method": "reload", "Arguments": []})
	
	return result

func _on_ready(source: String = "Unknown") -> void:	# готовность предмета (источник нужен для отладки)
	$Melee_area.monitoring = false
	self.busy = 0.0
#	if grandparent.name == "Player" and grandparent.current_item == self: print(source)
	emit_signal("item_ready")

func _on_screen_entered() -> void:	# предмет в пределах экрана
	if nameplate:
		nameplate.set_process(true)
#		nameplate.visible = true	# отображаем информационную планку

func _on_screen_exited() -> void:	# предмет за пределами экрана
	if nameplate:
		nameplate.set_process(false)	# для увеличения производительности
		nameplate.visible = false	# скрываем информационную планку

func _on_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	main_node.mouseover(self, true)	# отображаем контур предмета и тултип

func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape()
	main_node.mouseover(self, false)	# убираем тултип и контур

func _on_Melee_area_body_entered(body):	# объект в поле поражения мили-оружия в момент удара
	if !body in exclude_targets:
		$Melee_swing.stop()	# прерываем звук замаха
		$Melee_hit.play()	# звук попадания по цели
		if body.collision_layer & 6:	# игрок или NPC
			var blood = Preloader.get_resource("BloodSpot").instance()
			blood.position = body.position
			blood.rotation = grandparent.rotation
			main_node.find_node("Floor").add_child(blood, true)
		exclude_targets.append(body)	# чтобы не попасть многократно в одну цень в течении одной атаки
		if body.has_method("taking_damage"):
			body.taking_damage(self.damage, body.position - grandparent.position)