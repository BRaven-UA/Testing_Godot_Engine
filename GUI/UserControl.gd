# Базовый скрипт для узлов, в которых реализован механизм перемещения и изменения размеров
extends Control

onready var user_layer = get_tree().current_scene.find_node("UserLayer")
onready var content = find_node("Content")
var edit_mode = false setget _set_edit_mode	# флаг режима редактирования

func _set_edit_mode(new_value):
	edit_mode = new_value
	$Background.visible = edit_mode
	$ResizeCorner.visible = edit_mode

func _on_ResizeCorner_gui_input(event: InputEvent):	# изменение размеров кнопки
	if event is InputEventMouseMotion and Input.get_mouse_button_mask() == 1:
		rect_size += event.relative

func _on_Background_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_button_mask() == 1:
		rect_position += event.relative
		rect_global_position = Global.match_screen(get_global_rect())