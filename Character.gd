# базовый класс для всех персонажей в игре
extends KinematicBody2D

class_name Character, "res://Character icon.png"

signal selected
onready var main_node = get_tree().current_scene
onready var cursor_hint = main_node.find_node("CursorHint")
#const Item = preload("res://Item.gd")	# чтобы иметь возможность указать класс предмета (сделано только ради облегчения работы в редакторе)
var lifebar: Control	# панель здаровья, находится в GUI/HUD

const SPEED = 128	# базовая скорость движения
const ANG_SPEED = PI	# базовая скорость поворота
const MAX_HEALTH: int = 100	# базовое количество здоровья
const SIGHT_RANGE: int = 1024	# базовая дальность зрения
const ACTIONS = ["Idle", "Turn", "Walk", "Attack", "Reload"]

var sight_range: int = SIGHT_RANGE setget _set_sight_range	# текущая дальность зрения
var dest_point = Vector2()	# место назначения движения
var turn_point = Vector2()	# точка, к которой нужно повернуться
var a_path = PoolVector2Array()	# маршрут, созданный алгоритмом AStar
var equiped_weapon: Item setget _set_equiped_weapon	# текущее экипированное оружие
var action = "Idle"
var max_health: int setget _set_max_health	# может изменяться под действием различных эффектов
var health: int setget _set_health
var busy = false	# признак выполнения какого-либо действия

func _set_sight_range(new_value) -> void:	# заготовка для перезаписи в дочерних классах
	pass

func _set_equiped_weapon(new_value) -> void:	# setter for equiped_weapon
	if equiped_weapon: equiped_weapon.equiped = false	# снимаем отметку у предыдущего оружия
	if new_value: new_value.equiped = true	# устанавливаем отметку у нового оружия
	equiped_weapon = new_value

func  _set_max_health(new_value: int) -> void:
	max_health = int(max(1, new_value))	# значение должнобыть положительным
	lifebar.set_max_value(max_health)

func  _set_health(new_value: int) -> void:
	if new_value > 0:
		health = new_value
		lifebar.set_value(health)
	else:
		death()

func _ready():
	lifebar = Preloader.get_resource("LifeBar").instance()
	lifebar.linked_object = self
	main_node.find_node("HUD").add_child(lifebar, true)
	self.max_health = MAX_HEALTH	# чтобы сработал setter
	self.health = max_health	# чтобы сработал setter

	var w = Global.create_item("Glock 17", $Inventory)
	Global.create_item("9 mm", $Inventory, 20)
	w.reload(null, true)
	self.equiped_weapon = Global.create_item("Knife", $Inventory)
	
	connect("selected", main_node.find_node("Debug"), "selection_changed")
	main_node.connect("draw", self, "draw_in_parent")







func death() -> void:
	pass