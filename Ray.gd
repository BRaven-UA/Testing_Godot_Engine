extends RayCast2D

export (int) var max_l = 1000
var l = 0
var p = Vector2()
var pp = Vector2()
var n = Vector2()
signal got_smth
var c = Object()
onready var main = get_tree().current_scene
	
func _ready():
	cast_to = Vector2(0, max_l)
	
func _process(delta):
	c = null
	#main.dl5.text = "get_transform(): " + str(get_transform())
	#main.dl6.text = "get_global_transform(): " + str(get_global_transform())
	
func _physics_process(delta):
	if is_colliding():
		c = get_collider()
		if c:
			p = get_collision_point()
			pp = get_global_transform().xform_inv(p)
			#main.dl3.text = "collision_point(): " + str(p)
			#main.dl4.text = "get_global_transform().xform_inv(collision_point): " + str(pp)
	#		n = get_collision_normal()
	#		l = global_position.distance_to(p)	#(p - global_position).length()
	#		emit_signal("got_smth", c, p, n, global_rotation)
			main.dl6.text = "Collaider is: " + c.name + " at " + str(p.floor())
			#main.draw_circle(p, 6, ColorN('Red'))
	else:
		main.dl6.text = ""
#	update()

#func _draw():
#	if c:
#		draw_circle(pp, 6, ColorN('Red'))	# для отладки
#	pass