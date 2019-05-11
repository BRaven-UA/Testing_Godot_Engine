extends MarginContainer

var data: Dictionary

func _ready() -> void:
	$MarginContainer/Label.text = data["Description"]

func _on_ContextMenuItem_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and Input.get_mouse_button_mask() == 1:
		MessageBus.send(self, "ContextMenu", ["pressed", data], 0)

func _on_ContextMenuItem_mouse_entered() -> void:
	$Highlight.visible = true

func _on_ContextMenuItem_mouse_exited() -> void:
	$Highlight.visible = false