extends Control

onready var main_node = get_node("/root").get_child(1)
onready var a_star = main_node.a_star

#func _draw():
#	var ctrans = get_canvas_transform()
#	var min_pos = -ctrans.get_origin() / ctrans.get_scale()
#	var view_size = get_viewport_rect().size / ctrans.get_scale()
#	var view_rect = Rect2(min_pos, view_size)
#	for p in a_star.get_points():
#		var v3 = a_star.get_point_position(p)
#		var v2 = Vector2(v3.x, v3.y)
#		if view_rect.has_point(v2):
#			draw_circle(v2, 1.0, ColorN("Green"))

func _on_Timer_timeout():
	update()