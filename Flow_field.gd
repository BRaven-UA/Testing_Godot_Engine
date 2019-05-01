extends Area2D

var occ = false
signal checked

#func _process(delta):
#	if monitoring:
#		emit_signal("checked", occ)
#		occ = false

func _on_Flow_field_body_entered(body):
	occ = true
	printt(body.name, OS.get_ticks_msec())
	emit_signal("checked", occ)