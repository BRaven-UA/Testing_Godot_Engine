extends Button

signal New_game

func _on_Button_New_button_up():
	emit_signal("New_game")
