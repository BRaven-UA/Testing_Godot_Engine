extends MarginContainer

var action: Dictionary

func _ready() -> void:
	$MarginContainer/Label.text = action.Description

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		# мышь находится над кнопкой, меняем текст подсказки
		Global.cursor_hint.set_hint()
#		accept_event()
	
	if event is InputEventMouseButton and Input.get_mouse_button_mask() == 1:
		MessageBus.send(self, "ContextMenu", ["pressed", action], 0)	# отылаем уведомление о нажатии на этот элемент (используем систему сообщений из-за необходимости незамедлительно удалить этот элемент)
#		Global.perform_action(action)

func _on_ContextMenuItem_mouse_entered() -> void:
	$Highlight.visible = true
	if action.Description == "Разделить":
		$SplitSlider.visible = true

func _on_ContextMenuItem_mouse_exited() -> void:
	$Highlight.visible = false