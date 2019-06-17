tool
extends EditorScript

const AAA = 10
var aaa = 55

func _run():
	print(get_scene().get_tree().set_auto_accept_quit(true))