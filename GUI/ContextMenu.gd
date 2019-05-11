extends MarginContainer

var linked_object	# ссылка на объект, для которого сформировано это меню
onready var main_node = get_tree().current_scene
onready var cursor_hint = main_node.find_node("CursorHint")
#onready var user_layer = main_node.find_node("UserLayer")
onready var container = $VBoxContainer

func _notification(what: int) -> void:
	if what > MessageBus.INDEX_OFFSET:
		var message = MessageBus.receive(what)
		if message.Content[0] == "pressed":
			visible = false
			linked_object.perform_action(message.Content[1])


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:	# проверям клики мышью за пределами меню
		if !get_global_rect().has_point(get_global_mouse_position()):
			visible = false

func pop_up(object: Object, item_list: = []) -> void:
	if item_list.size() > 1:
		linked_object = object
		cursor_hint.visible = false
		
		rect_size = Vector2()
		for item in item_list:
			var line = Preloader.get_resource("ContextMenuItem").instance()
			line.data = item
			container.add_child(line, true)
		
		var mouse = get_global_mouse_position()
		rect_position = Global.match_screen(Rect2(mouse - Vector2(10, 10), rect_size))
		visible = true

func _on_Timer_timeout() -> void:
	visible = false

func _on_ContextMenu_hide() -> void:
	for line in container.get_children():
		line.free()	