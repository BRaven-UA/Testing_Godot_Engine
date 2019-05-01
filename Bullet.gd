extends KinematicBody2D

onready var main_node = get_tree().current_scene
var damage
#var damage = {"5mm": 5, "10mm": 10, "grenade": 75, "rocket": 150}
#export(String) var ammo = "5mm"
var start_point = Vector2()

func _ready():
	start_point = global_position

func _physics_process(delta):
	var result = move_and_collide(Vector2(0, 2000).rotated(rotation) * delta)
	if result:	# было столкновение
		var c = result.collider
#		prints("Hit:", c.name, "at", result.position)
		var e = Preloader.get_resource("Explosion").instance()
#		var e = Global.explosion.instance()
		main_node.add_child(e, true)
		e.global_position = result.position
		e.get_node("AnimatedSprite").play()
		if c.has_method("taking_damage"):
#			prints("travel:", result.travel)
			c.taking_damage(damage, result.travel)
		if c.get_collision_layer_bit(1):	# деталь ландшафта
			pass
		queue_free()
	if (global_position - start_point).length() > 10000:
		queue_free()