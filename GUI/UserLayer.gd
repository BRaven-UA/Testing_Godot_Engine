extends Control
# модуль обработки настраиваемых кнопок на экране

onready var main_node = get_tree().current_scene
onready var context_menu = main_node.find_node("ContextMenu")
onready var cursor_hint = main_node.find_node("CursorHint")
onready var player = main_node.find_node("Player")
var edit_mode = false setget _set_edit_mode	# флаг режима редактирования всех кнопок
var default_size: = 64	# размер пользовательских кнопок по-умолчанию

func _set_edit_mode(new_value):	# setter for edit_mode
	edit_mode = new_value
	for button in get_tree().get_nodes_in_group("Buttons"):
		button.edit_mode = edit_mode
	for container in get_tree().get_nodes_in_group("ButtonContainer"):
		container.edit_mode = edit_mode
	$TimeScale.visible = false

# создает кнопку пользовательского интерфейса. Каждая кнопка должна ссылаться на какой-нибудь узел. Если узел удаляется, кнопка будет также удалена
# если не задана конкретная область на экране, кнопка будет создана в общей массе и может перекрывать кнопки из областей
# позиция для кнопок из областей игнорируется
func create_button(linked_object: Object, picture: Texture, area: String = "", position: = Vector2() \
		, size: = Vector2(default_size, default_size)) -> void:
	var b = Preloader.get_resource("UserButton").instance()
	b.user_layer = self
	b.context_menu = context_menu
	b.cursor_hint = cursor_hint
	b.player = player
	b.get_node("Picture").texture = picture
#	b.UID = UID
	b.linked_object = linked_object
	b.rect_global_position = position
	b.rect_size = size
	if linked_object.name == "TimeScale":
		linked_object.button = b
	var parent = self
	if area: parent = find_node(area).content
	parent.add_child(b, true)

func _generate_action(action) -> void:	# генерирует событие ввода
	var event = InputEventAction.new()
#	event.set_as_action(action, true)
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)	# сначала эмуляция нажатия
	yield(get_tree().create_timer(0.1), "timeout")
	event.pressed = false
	Input.parse_input_event(event)	# после эмуляция отжатия