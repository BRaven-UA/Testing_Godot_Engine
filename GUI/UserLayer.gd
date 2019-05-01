extends Control
# модуль обработки настраиваемых кнопок на экране

var edit_mode = false setget _set_edit_mode	# флаг режима редактирования всех кнопок

func _set_edit_mode(new_value):	# setter for edit_mode
	for child in get_children():
#		if child.has("edit_mode"):	# удалить когда настрою все внопки по одному шаблону
		child.set("edit_mode", new_value)
	edit_mode = new_value

func create_button(UID, picture, origin, main_action, action_list = [], position = get_viewport_rect().size / 2, size = Vector2(64, 64)):
	var b = Preloader.get_resource("UserButton").instance()
#	var b = Global.user_button.instance()
	b.get_node("Picture").texture = load(picture)
	b.UID = UID
	b.origin = origin
	b.main_action = main_action
	b.action_list = action_list
	b.rect_global_position = position
	b.rect_size = size
	b.connect("pressed", self, "button_action", [b.action])
	add_child(b, true)


func button_action(action):
	match action:
		"backpack": Input.action_press("backpack")