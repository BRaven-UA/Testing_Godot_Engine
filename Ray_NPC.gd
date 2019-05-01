extends RayCast2D

onready var me = get_parent()
var target
var in_sight = false	# цель в прямой видимости
var last_seen = Vector2()

func _physics_process(delta):
	in_sight = false
	if target:
		cast_to = (target.position - me.position).rotated(-me.rotation)
#		force_raycast_update()
		if is_colliding() and get_collider() == target:
			in_sight = true
#			me.target = target
			last_seen = target.position
#	else:
#		last_seen = Vector2()

func _detected(body):	# срабатывает когда кто-то попал в конус зрения
	if body.name == "Player":
		target = body
#		enabled = true

func _exited(body):	# срабатывает когда кто-то вышел из конуса зрения
	if body == target:
		target = null
#		enabled = false
		cast_to = Vector2()
#		dest_point = target.position
